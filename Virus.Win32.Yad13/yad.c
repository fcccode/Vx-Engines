/* YAD 0.13 (Yet Another Disassembler) (x) herm1t@vx.netlux.org, 2008 */
#include "yad.h"
#include "yad_data.h"

#ifdef	YAD_PACK6
static uint16_t fetch(uint32_t i) {
	uint32_t t = *(uint32_t*)(yad_data + (((i << 1) + i) >> 2));
	if ((i &= 3) == 0)
		t >>= 2;
	else if (--i == 0)
		t = ((t & 3) << 4) | ((t >> 12) & 15);
	else if (--i == 0)
		t = ((t & 15) << 2) | ((t >> 14) & 3);
	t = (t & 63) << 1;
	return *(uint16_t*)(yad_data + YAD_VALUES_OFFSET + t);
}
#endif

int yad(uint8_t *opcode, yad_t *diza)
{
	uint8_t c, *p, datasize, addrsize;
	uint16_t flags;
	uint32_t j, i, mod, rm, reg;
#ifndef	YAD_PACK6
	uint16_t *yad_table = (uint16_t*)(yad_data + YAD_VALUES_OFFSET);
#define	fetch(x)	yad_table[yad_data[x]]
#endif
	for (i = 0; i < sizeof(yad_t); i++)
		*((char*)diza + i) = 0;
	datasize = addrsize = 4; p = opcode; flags = 0; 
	if (*(uint16_t*)p == 0x0000 || *(uint16_t*)p == 0xffff)
		diza->flags |= C_BAD;
	/* prefixes */
	for (;;) {
		c = *p++;
#define	GET_PREFIX(cond,field,expr)	\
if (cond) { if (diza->field) goto bad; diza->field = c; expr; continue; }
		GET_PREFIX(c == 0x66, p_66, datasize = 2)
		GET_PREFIX(c == 0x67, p_67, addrsize = 2)
		GET_PREFIX((c & 0xfe) == 0x64 || (c & 0xe7) == 0x26, p_seg, c=c)
		GET_PREFIX((c & 0xfe) == 0xf2, p_rep, c=c)
		GET_PREFIX(c == 0xf0, p_lock, c=c)
		break;
bad:		diza->flags |= C_BAD;
#undef	GET_PREFIX
	}
	/* opcode */
	if ((diza->opcode = c) == 0x0f) {
		diza->opcode2 = *p++;
		j = 256 + diza->opcode2;
	} else {
		j = c;
	}
	/* instruction flags by opcode */
	if ((flags = fetch(j)) == C_ERROR)
		return 0;
	/* parse ModRM and SIB, (prefix) groups, FPU */
	if (flags & (C_MODRM|C_GROUP|C_PREGRP)) {
		diza->modrm = c = *p++;
		mod = c >> 6;
		reg = (c >> 3) & 7;
		rm = c & 7;

#ifdef	CHECK_LOCK
		/* check lock prefix */
		if (diza->p_lock) {
			if (mod == 3)
				return 0;
			/* two byte opcodes */
			if (diza->opcode2) {
				c = diza->opcode2;
				/* BT BTS BTR BTC*/
				if (c == 0xba && reg > 4)
					goto lock_ok;
				/* CMPXCHG */
				if (c == 0xc7 && reg == 1)
					goto lock_ok;
				/* BTS XADD XADD CMPXCHG CMPXCHG BTR BTC */
				/* ab c0 c1 b0 b1 b3 bb */
				if (c == 0xab || ((c & 0xfc) == 0xb0 &&
				c != 0xb2) || (c & 0xfe) == 0xc0 || c == 0xbb)
					goto lock_ok;
				/* f0 0f 20/22 MOV Rd,CR8D / MOV CR8D,Rd */
				if (c == 0x20 || c == 0x22)
					goto lock_ok;
			} else {
				c = diza->opcode & 0xfe;
				/* 00 01 08 09 10 11 18 19 20 21 28 29 30 31 */
				if ((c & 7) == 0 && (c >> 3) < 7)
					goto lock_ok;
				/* 86 87 */
				if (c == 0x86)
					goto lock_ok;
				if (c == 0xf6 && (reg & 0xfe) == 2)
					goto lock_ok;
				if (c == 0xfe && (reg & 0xfe) == 0)
					goto lock_ok;
				/* group1 */
				if ((diza->opcode & 0xfc) == 0x80 && reg != 7)
					goto lock_ok;
			}
			return 0;			
		}
lock_ok:
#endif	/* CHECK_LOCK */
		/* after lock, f0 0f 20 ... */
		/* https://forums.symantec.com/syment/blog/article?message.uid=305479 */
		if ((j & 0xfffc) == 0x120)
			mod = 3;
		if (flags & (C_GROUP|C_PREGRP)) {
			flags = C_MODRM | fetch((flags & YAD_GROUP_MASK) +
				(flags & C_GROUP ? reg :
				(diza->p_rep == 0xf3 ? 1 :
				(diza->p_66 ? 2 :
				(diza->p_rep == 0xf2 ? 3 : 0)))));
			/* fixes for groups 13-15 */
			c = diza->opcode2;
			if ((c & 0xfc) == 0x70 && c != 0x70) {
				if (diza->p_rep)
					return 0;
				/* PSRLDQ / PSLLDQ VRo, Ib */
				if (c == 0x73 && diza->p_66 && (reg == 3 || reg == 7))
					flags = C_DATA1;
#ifdef	CHECK_ARGS
				if (mod != 3)
					return 0;
#endif
			}
			if (flags == C_ERROR)
				return 0;
		} else
		/* check FPU instructions */
		if ((c = diza->opcode) >= 0xd9 && c <= 0xdf) {
			/* d8 is fully allocated */
			c = ((c - 0xd9) << 3) + (uint8_t)reg;
			if (mod == 3) {
				if (yad_data[YAD_FLOAT_OFFSET + c] & (1 << rm))
					return 0;
			} else {
				if (	(c == 0x01) ||	/* d9 /1 */
					(c == 0x14) ||	/* db /4 */
					(c == 0x16) ||	/* db /6 */
					(c == 0x25) )	/* dd /5 */
				return 0;
			}
		}
		/* ModRM and SIB */
		if (mod != 3) {
			if (diza->p_67) {
				if (mod == 0 && rm == 6)
					goto sf;
			} else {
				if (rm == 4) {
					c = *p++;
					flags |= C_SIB;
					diza->sib = c;
				}
				if (mod == 0 && (rm == 5 || (diza->sib & 7) == 5))
					goto sf;
			} 
			if (mod == 1)
				flags |= C_ADDR1;
			if (mod == 2)
sf:				flags |= C_ADDR67;
#ifdef	CHECK_ARGS
			if ((c = diza->opcode2) != 0)  {
				if (	((diza->p_rep == 0) && (
						/* MOVMSKPS / MOVMSKPD */
						(c == 0x50) ||
						/* PEXTRW */
						(c == 0xc5) ||
						/* PMOVMSKB */
						(c == 0xd7) ||
						/* MASKMOVQ / MASKMOVDQU */
						(c == 0xf7) )) ||
					/* MOVQ2DQ / MOVDQ2Q */
					((diza->p_rep != 0 ) &&
						(c == 0xd6) )
				)
				return 0;
			}
#endif	/* CHECK ARGS */
		} else {
#ifdef	CHECK_ARGS
			/* mod == 11, check operands, the code was taken from HDE32 */
			if (diza->opcode2) {
				c = diza->opcode2;
				if (	/* group#7 0f 01 SGDT/SIDT/LGDT/LIDT Ms/../../../INVLPG M */
					(c == 0x01 && (reg < 4 || reg == 7)) ||
					/* group#9 0f c7 CMPXCHG Mq */
					(c == 0xc7 && reg == 1) ||
					/* 0f b2 LSS Gz,Mp */
					/* 0f b4 LFS Gz,Mp */
					/* 0f b5 LGS Gz,Mp */
					(c == 0xb2 || c == 0xb4 || c == 0xb5) ||
					/* group#16 0f ae FXSAVE M512 / FXRSTOR M512 / LDMXCSR Md / STMXCSR Md / XSAVE M */
					(c == 0xae && reg < 5) ||
					/* FIXME: more checks here, SSE... */
					/* MOVLPD / MOVHPD / CVTPI2PD / MOVQ / MOVNTDQ */
					(diza->p_66 && (c == 0x12 || c == 0x16 || c == 0xe7)) ||
					/* MOVLPS,MOVLPD / MOVHPS, MOVHPD / MOVNTPS, MOVNTPD */
					(diza->p_rep == 0 && (c == 0x13 || c == 0x17 || c == 0x2b)) ||
					/* LDDQU */
					(diza->p_rep == 0xf2 && c == 0xf0) ||
					/* MOVNTI */
					(c == 0xc3)
				)
				return 0;
                	} else {
				c = diza->opcode;
				if (
					/* 62 BOUND Gv,Ma */
					/* 8d LEA Gv,M */
					/* c4 LES Gz,Mp */
					/* c5 LDS Gz,Mp */
					(c == 0x62 || c == 0x8d || (c & 0xfe) == 0xc4) ||
					/* group#5 CALL Mp, JMP Mp */
					(c == 0xff && (reg == 3 || reg == 5))
				)
				return 0;
			}
#endif	/* CHECK_ARGS */
		} /* mod == 3 */
#ifdef	CHECK_ARGS
		c = diza->opcode;
		if (
			/* MOV Sw, Mw/Rv */
			(c == 0x8e && (reg == 1 || reg > 5)) ||
			/* MOV Mw/Rv, Sw */
			(c == 0x8c && (reg >= 6))
		) return 0;
		c = diza->opcode2;
		if (
			/* MOV Rd,Dd / MOV Dd/Rd */
			((c & 0xfd) == 0x21 && (reg == 4 || reg == 5)) ||
			/* MOV Rd,Cd / MOV Cd/Rd */
			((c & 0xfd) == 0x22 && (reg == 1 || reg == 5 || reg == 6))
		) return 0;
#endif
	} /* modrm */
	diza->flags |= flags;
#define	COPY_ARG(size,flag,var,save)	\
{ uint8_t a = size;			\
if (flags & flag)			\
	a += var;			\
diza->var = a;				\
for (i = 0; i < a; i++)			\
	*(&save + i) = *p++;		\
}
	COPY_ARG((flags >> 3) & 1, C_ADDR67, addrsize, diza->addr1);
	COPY_ARG(flags & 3, C_DATA66, datasize, diza->data1);
#undef	COPY_ARG
	/* check 3D Now suffix */
	if (diza->opcode == 0x0f && diza->opcode2 == 0x0f) {
		i = diza->data1;
		if (yad_data[YAD_3DNOW_OFFSET + (i >> 3)] & (1 << (i & 7)))
			return 0;
	}
	/* check opcode length */
	if ((diza->len = p - opcode) > 15)
		return 0;
	return diza->len;
#ifndef	PACK6
#undef	fetch
#endif
}

#ifdef	YAD_ASM
int yad_asm(uint8_t *opcode, yad_t *diza)
{
	int i;
	uint8_t *p = opcode;
	for (i = 0; i < 5; i++)
		if (*(&diza->p_seg + i))
			*p++ = *(&diza->p_seg + i);		
	*p++ = diza->opcode;
	if (diza->opcode == 0x0f)
		*p++ = diza->opcode2;
	if (diza->flags & C_MODRM)
		*p++ = diza->modrm;
	if (diza->flags & C_SIB)
		*p++ = diza->sib;
	for (i = 0; i < diza->addrsize; i++)
		*p++ = *(&diza->addr1 + i);
	for (i = 0; i < diza->datasize; i++)
		*p++ = *(&diza->data1 + i);
	return p - opcode;
}
#endif
