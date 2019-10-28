#define	_V	(char*)
#define	__	0

#define OP_A    0x0100	/* direct address; no mod R/M; address of operand is encoded in instruction; no SIB */
#define OP_C    0x0200	/* reg field of mod R/M byte selects a control register */
#define OP_D    0x0300	/* reg field of mod R/M byte selects a debug register */
#define OP_E    0x0400	/* mod R/M byte follows opcode and specifies operand; operand is either a general register or a memory address; */
#define	OP_F	0x0500	/* flags register */
#define OP_G    0x0600	/* reg field of mod R/M byte selects a general register */
#define OP_I    0x0700	/* immediate data; value of operand is encoded in subsequent bytes of instruction */
#define OP_J    0x0800	/* instruction contains a relative offset to be added to the instruction pointer register */
#define OP_M    0x0900	/* mod R/M byte may refer only to memory */
#define OP_O    0x0a00	/* direct offset; no mod R/M byte; offset of operand is encoded in instruction; no SIB */
#define OP_P    0x0b00	/* reg field of mod R/M byte selects a MMX register */
#define OP_PR   0x0c00	/* r/m field of mod R/M byte selects a MMX register; mod field of mod R/M byte must be 11b */
#define OP_Q    0x0d00	/* mod R/M byte follows opcode and specifies operand; operand is either an MMX register or a memory address; */
#define OP_R    0x0e00	/* r/m field of mod R/M byte selects a general register; mod field of mod R/M byte should be 11b */
#define OP_S    0x0f00	/* reg field of mod R/M byte selects a segment register */
#define	OP_T	0x1000	/* reg field of mod R/M byte selects a test register */
#define	OP_VD	0x1100	/* dst field of DREX byte selects a XMM register */
#define OP_V    0x1200	/* reg field of mod R/M byte selects a XMM register */
#define OP_VR   0x1300	/* r/m field of mod R/M byte selects a XMM register; mod field of mod R/M byte must be 11b */
#define OP_W    0x1400	/* mod R/M byte follows opcode and specifies operand; operand is either a XMM register or a memory address; */
#define	OP_X	0x1500	/* memory addressed by DS:SI register pair; eg. MOVS, CMPS, OUTS, LODS */
#define	OP_Y	0x1600	/* memory addressed by ES:DI register pair; eg. MOVS, CMPS, INS, STOS, SCAS */

#define	OP_REG	0x1700

#define ST	0
#define ST0	0
#define STi	0
#define	Mt	0

#define	b_b	0x0001	/* byte (regardless of operand size attribute) */
#define	b_w 	0x0002	/* word (regardless of operand size attribute) */
#define	b_d 	0x0003	/* dword (regardless of operand size attribute) */
#define	b_q 	0x0004	/* qword (regardless of operand size attribute) */
#define	b_o 	0x0005	/* oword (regardless of operand size attribute) */
#define	b_v 	0x0006	/* word or dword or qword, depending on operand size attribute */
#define	b_z 	0x0007	/* word or dword or dword, depending on operand size attribute */
#define	b_a 	0x0008	/* two word or two doubleword operands in memory, depending on operand size attribute (used only by BOUND) */
#define	b_p 	0x0009	/* 32-bit or 48-bit pointer, depending on operand size attribute */
#define	b_s 	0x000a	/* six-byte pseudo-descriptor */
#define	b_t 	0x000b	/* ten-byte pseudo-descriptor */

#define	AL	0x1700
#define	CL	0x1701
#define	DL	0x1702
#define	BL	0x1703
#define	AH	0x1704
#define	CH	0x1705
#define	DH	0x1706
#define	BH	0x1707

#define	rAX	0x1710
#define	rCX	0x1711
#define	rDX	0x1712
#define	rBX	0x1713
#define	rSI	0x1714
#define	rDI	0x1715
#define	rSP	0x1716
#define	rBP	0x1717

#define	eAX	0x1720
#define	eCX	0x1721
#define	eDX	0x1722
#define	eBX	0x1723
#define	eSI	0x1724
#define	eDI	0x1725
#define	eSP	0x1726
#define	eBP	0x1727

#define	AX	0x1730
#define	CX	0x1731
#define	DX	0x1732
#define	BX	0x1733
#define	SI	0x1734
#define	DI	0x1735
#define	SP	0x1736
#define	BP	0x1737

#define	ES	0x1740
#define	CS	0x1741
#define	SS	0x1742
#define	DS	0x1743
#define	FS	0x1744
#define	GS	0x1745

/* OPCODE FLAGS */
#define	PRE	0x080000	/* depend on prefixes */
#define	GRP	0x100000	/* group */
#define	REL	0x200000
#define	STOP	0x400000

#define	Vo	OP_V|b_o
#define	Vd	OP_V|b_d
#define	Vq	OP_V|b_q
#define	Wo	OP_W|b_o
#define	Wd	OP_W|b_d
#define	Wq	OP_W|b_q
#define	Mq	OP_M|b_q
#define	Mo	OP_M|b_o
#define	Gd	OP_G|b_d
#define	VRo	OP_VR|b_o
#define	VRq	OP_VR|b_q
#define	Pq	OP_P|b_q
#define	Pd	OP_P|b_d
#define	Qd	OP_Q|b_d
#define	Qq	OP_Q|b_q
#define	Ed	OP_E|b_d
#define	Md	OP_M|b_d
#define	Mw	OP_M|b_w
#define	Ib	OP_I|b_b
#define	Iw	OP_I|b_w
#define	PRq	OP_PR|b_q
#define	Eb	OP_E|b_b
#define	Gb	OP_G|b_b
#define	Ev	OP_E|b_v
#define	Gv	OP_G|b_v
#define	Iz	OP_I|b_z
#define	Ew	OP_E|b_w
#define	Gw	OP_G|b_w
#define	Ma	OP_M|b_a
#define	Mp	OP_M|b_p
#define	Jb	OP_J|b_b
#define	E	OP_E
#define	Sw	OP_S|b_w
#define	M	OP_M
#define	Ap	OP_A|b_p
#define	Ob	OP_O|b_b
#define	Ov	OP_O|b_v
#define	Iv	OP_I|b_v
#define	Gz	OP_G|b_z
#define	Jz	OP_J|b_z
#define	Ms	OP_M|b_s
#define	Rd	OP_R|b_d
#define	Cd	OP_C|b_d
#define	Dd	OP_D|b_d
#define	M512	OP_M
#define	Fv	OP_F|b_v
#define	Xb	OP_X|b_b
#define	Xz	OP_X|b_z
#define	Yb	OP_Y|b_b
#define	Yz	OP_Y|b_z
#define	Yv	OP_Y|b_v
#define	Xv	OP_X|b_v

typedef	struct {
	char	*name;
	uint32_t	op1,op2,op3;
} opcode_t;

/* GROUPS */
opcode_t group1[8] = {
{ "ADD",	__,__,__ },
{ "OR",		__,__,__ },
{ "ADC",	__,__,__ },
{ "SBB",	__,__,__ },
{ "AND",	__,__,__ },
{ "SUB",	__,__,__ },
{ "XOR",	__,__,__ },
{ "CMP",	__,__,__ }};
opcode_t group2[8] = {
{ "ROL",	__,__,__ },
{ "ROR",	__,__,__ },
{ "RCL",	__,__,__ },
{ "RCR",	__,__,__ },
{ "SHL",	__,__,__ },
{ "SHR",	__,__,__ },
{ "SAL",	__,__,__ },
{ "SAR",	__,__,__ }};
opcode_t group3_F6[8] = {
{ "TEST",	Eb,Ib,__ },
{ "TEST",	Eb,Ib,__ },
{ "NOT",	Eb,__,__ },
{ "NEG",	Eb,__,__ },
{ "MUL",	rAX,__,__ },
{ "IMUL",	rAX,__,__ },
{ "DIV",	rAX,__,__ },
{ "IDIV",	rAX,__,__ }};
opcode_t group3_F7[8] = {
{ "TEST",	Eb,Iz,__ },
{ "TEST",	Eb,Iz,__ },
{ "NOT",	Eb,__,__ },
{ "NEG",	Eb,__,__ },
{ "MUL",	rAX,__,__ },
{ "IMUL",	rAX,__,__ },
{ "DIV",	rAX,__,__ },
{ "IDIV",	rAX,__,__ }};
opcode_t group4[8] = { 	 
{ "INC",	Eb,__,__ },
{ "DEC",	Eb,__,__ },
{ "(bad)",	__,__,__ },
{ "(bad)",	__,__,__ },
{ "(bad)",	__,__,__ },
{ "(bad)",	__,__,__ },
{ "(bad)",	__,__,__ },
{ "(bad)",	__,__,__ }};
opcode_t group5[8] = {
{ "INC",	Ev,__,__ },
{ "DEC",	Ev,__,__ },
{ "CALL",	Ev,__,__ },
{ "CALL",	Mp,__,__ },
{ "JMP",	STOP | Ev,__,__ },
{ "JMP",	STOP | Mp,__,__ },
{ "PUSH",	Ev,__,__ },
{ "(bad)",	__,__,__ }};
opcode_t group6[8] = {
{ "SLDT", 	E,__,__},	//Mw/Rv
{ "STR", 	E,__,__},	//Mw/Rv
{ "LLDT", 	E,__,__},	//Mw/Rv
{ "LTR", 	E,__,__},	//Mw/Rv
{ "VERR", 	E,__,__},	//Mw/Rv
{ "VERW", 	E,__,__},	//Mw/Rv
{ "(bad)",	__,__,__},	// JMPE, Ev (IA-64)
{ "(bad)",	__,__,__}};
opcode_t group7[8] = { 
{ "SGDT", 	Ms,__,__},
{ "SIDT", 	Ms,__,__},
{ "LGDT", 	Ms,__,__},
{ "LIDT", 	Ms,__,__},
{ "SMSW", 	E,__,__},	// Mw/Rv
{ "(bad)",	__,__,__},
{ "LMSW",	E,__,__},	// Mw/Rv
{ "INVLPG",	M,__,__}};	// (80486+) SWAPGS (F8h) RDTSCP (F9h)
opcode_t group8[8] = {
{ "(bad)",	__,__,__ },
{ "(bad)",	__,__,__ },
{ "(bad)",	__,__,__ },
{ "(bad)",	__,__,__ },
{ "BT",		__,__,__ },
{ "BTS",	__,__,__ },
{ "BTR",	__,__,__ },
{ "BTC",	__,__,__ }};
opcode_t group9[8] = {
{ "(bad)",	__,__,__ },
{ "CMPXCHG",	Mq,__,__ },
{ "(bad)",	__,__,__ },
{ "(bad)",	__,__,__ },
{ "(bad)",	__,__,__ },
{ "(bad)",	__,__,__ },
{ "(bad)",	__,__,__ },
{ "(bad)",	__,__,__ }};

opcode_t group10[8] = {
{ "POP",	Ev,__,__ },
{ "(bad)",	__,__,__ },
{ "(bad)",	__,__,__ },
{ "(bad)",	__,__,__ },
{ "(bad)",	__,__,__ },
{ "(bad)",	__,__,__ },
{ "(bad)",	__,__,__ },
{ "(bad)",	__,__,__ }};
opcode_t group12[8] = {
{ "MOV",	__,__,__ },
{ "(bad)",	__,__,__ },
{ "(bad)",	__,__,__ },
{ "(bad)",	__,__,__ },
{ "(bad)",	__,__,__ },
{ "(bad)",	__,__,__ },
{ "(bad)",	__,__,__ },
{ "(bad)",	__,__,__ }};
/* there are additional code to handle SSE2 insns (with 66 prefix) */
opcode_t group13[8] = {
{ "(bad)",	__,__,__ },
{ "(bad)",	__,__,__ },
{ "PSRLW",	PRq,Ib,__},	// (MMX) (66h) PSRLW VRo,Ib (SSE2)
{ "(bad)",	__,__,__ },
{ "PSRAW",	PRq,Ib,__},	// (MMX) (66h) PSRAW VRo,Ib (SSE2)
{ "(bad)",	__,__,__ },
{ "PSLLW",	PRq,Ib,__},	// (MMX) (66h) PSLLW VRo,Ib (SSE2)
{ "(bad)",	__,__,__ }};
opcode_t group14[8] = {
{ "(bad)",	__,__,__ },
{ "(bad)",	__,__,__ },
{ "PSRLD",	PRq,Ib,__},	// (MMX) (66h) PSRLD VRo,Ib (SSE2)
{ "(bad)",	__,__,__ },
{ "PSRAD",	PRq,Ib,__},	// (MMX) (66h) PSRAD VRo,Ib (SSE2)
{ "(bad)",	__,__,__ },
{ "PSLLD",	PRq,Ib,__},	// (MMX) (66h) PSLLD VRo,Ib (SSE2)
{ "(bad)",	__,__,__ }};
/* two opcodes marked by NB! are special cases */
opcode_t group15[8] = {
{ "(bad)",	__,__,__ },
{ "(bad)",	__,__,__ },
{ "PSRLQ",	PRq,Ib,__},	// (MMX) (66h) PSRLQ VRo,Ib (SSE2)
{ "(bad)",	__,__,__ },	// NB!	 (66h) PSRLDQ VRo,Ib (SSE2)
{ "(bad)",	__,__,__ },
{ "(bad)",	__,__,__ },
{ "PSLLQ",	PRq,Ib,__},	// (MMX) (66h) PSLLQ VRo,Ib (SSE2)
{ "(bad)",	__,__,__ },	// NB!	 (66h) PSLLDQ VRo,Ib (SSE2)
};
opcode_t group16[8] = {
{ "FXSAVE",	M512,__,__ },
{ "FXRSTOR",	M512,__,__ },
{ "LDMXCSR",	Md,__,__ },	// (SSE)
{ "STMXCSR",	Md,__,__ },	// (SSE)
{ "XSAVE",	M,__,__ },
{ "LFENCE",	__,__,__ },	// (SSE2-MEM) XRSTOR M / 
{ "MFENCE",	__,__,__ },	// (SSE2-MEM)
{ "SFENCE",	__,__,__ }};	// (SSE-MEM) CLFLUSH M /
opcode_t group17[8] = {
{ "PREFETCHNTA",M,__,__ },	// (SSE-MEM)
{ "PREFETCHT0",	M,__,__ },	// (SSE-MEM)
{ "PREFETCHT1",	M,__,__ },	// (SSE-MEM)
{ "PREFETCHT2",	M,__,__ },	// (SSE-MEM)
{ "HINT_NOP",	Ev,__,__ },	// (P6+)
{ "HINT_NOP",	Ev,__,__ },	// (P6+)
{ "HINT_NOP",	Ev,__,__ },	// (P6+)
{ "HINT_NOP",	Ev,__,__ }};	// (P6+)

/* PREFIXES */
opcode_t pre_0f_10[4] =
{{ "MOVUPS",	Vo,Wo,__ },	// (SSE) UMOV Eb,Gb (80386/486)
{ "MOVSS",	Vd,Wd,__ },	// (SSE)
{ "MOVUPD",	Vo,Wo,__ },	// (SSE2)
{ "MOVSD",	Vq,Wq,__ }};	// (SSE2)
opcode_t pre_0f_11[4] =
{{ "MOVUPS",	Wo,Vo,__ },	// (SSE) UMOV Ev,Gv (80386/486)
{ "MOVSS",	Wd,Vd,__ },	// (SSE)
{ "MOVUPD",	Wo,Vo,__ },	// (SSE2)
{ "MOVSD",	Wq,Vq,__ }};	// (SSE2)
opcode_t pre_0f_12[4] =
{{ "MOVLPS",	Vq,Mq,__ },	// (SSE) UMOV Gb,Eb (80386/486)
{ "MOVSLDUP",	Vo,Wo,__ },	// (SSE3)
{ "MOVLPD",	Vq,Mq,__ },	// (SSE2)
{ "MOVDDUP",	Vo,Wq,__ }};	// (SSE3)
opcode_t pre_0f_13[4] =
{{ "MOVLPS",	Mq,Vq,__ },	// (SSE) UMOV Gv,Ev (80386/486)
{ "(bad)",	__,__,__ },
{ "MOVLPD",	Mq,Vq,__ },	// (SSE2)
{ "(bad)",	__,__,__ }};
opcode_t pre_0f_14[4] =
{{ "UNPCKLPS",	Vo,Wo,__ },	// (SSE)
{ "(bad)",	__,__,__ },
{ "UNPCKLPD",	Vo,Wo,__ },	// (SSE2)
{ "(bad)",	__,__,__ }};
opcode_t pre_0f_15[4] =
{{ "UNPCKHPS",	Vo,Wo,__ },	// (SSE)
{ "(bad)",      __,__,__ },
{ "UNPCKHPD",	Vo,Wo,__ },	// (SSE2)
{ "(bad)",      __,__,__ }};
opcode_t pre_0f_16[4] =
{{ "MOVHPS",	Vq,Mq,__ },	// (SSE)
{ "MOVSHDUP",	Vo,Wo,__ },
{ "MOVHPD",	Vq,Mq,__ }, 	// (SSE2)
{ "(bad)",      __,__,__ }};
opcode_t pre_0f_17[4] =
{{ "MOVHPS",	Mq,Vq,__ },	// (SSE)
{ "(bad)",      __,__,__ },
{ "MOVHPD",	Mq,Vq,__ },	// (SSE2)
{ "(bad)",      __,__,__ }};
opcode_t pre_0f_28[4] =
{{ "MOVAPS",	Vo,Wo,__ },	// (SSE)
{ "(bad)",      __,__,__ },
{ "MOVAPD",	Vo,Wo,__ },	// (SSE2)
{ "(bad)",      __,__,__ }};
opcode_t pre_0f_29[4] =
{{ "MOVAPS",	Wo,Vo,__ },	// (SSE)
{ "(bad)",      __,__,__ },
{ "MOVAPD",	Wo,Vo,__ },	// (SSE2)
{ "(bad)",      __,__,__ }};
opcode_t pre_0f_2a[4] =
{{ "CVTPI2PS",	Vq,Mq,__ },	// (SSE)
{ "CVTSI2SS",	Vd,Ed,__ },	// (SSE)
{ "CVTPI2PD",	Vo,Mq,__ },	// (SSE2)
{ "CVTSI2SD",	Vq,Ed,__ }};	// (SSE2)
opcode_t pre_0f_2b[4] =
{{ "MOVNTPS",	Mo,Vo,__ },	// (SSE)
{ "(bad)",	__,__,__ },	// MOVNTSS Md,Vd (SSE4A)
{ "MOVNTPD",	Mo,Vo,__ },	// (SSE2)
{ "(bad)",	__,__,__ }};	// MOVNTSD Mq,Vq (SSE4A)
opcode_t pre_0f_2c[4] =
{{ "CVTTPS2PI",	Pq,Wq,__ },	// (SSE-MMX)
{ "CVTTSS2SI",	Gd,Wd,__ },	// (SSE)
{ "CVTTPD2PI",	Pq,Wo,__ },	// (SSE2-MMX)
{ "CVTTSD2SI",	Gd,Wq,__ }};	// (SSE2)
opcode_t pre_0f_2d[4] =
{{ "CVTPS2PI",	Pq,Wq,__ },	// (SSE-MMX)
{ "CVTSS2SI",	Gd,Wd,__ },	// (SSE)
{ "CVTPD2PI",	Pq,Wo,__ },	// (SSE2-MMX)
{ "CVTSD2SI",	Gd,Wq,__ }};	// (SSE2)
opcode_t pre_0f_2e[4] =
{{ "UCOMISS",	Vd,Wd,__ },	// (SSE)
{ "(bad)",	__,__,__ },
{ "UCOMISD",	Vq,Wq,__ },	// (SSE2)
{ "(bad)",	__,__,__ }};
opcode_t pre_0f_2f[4] =
{{ "COMISS",	Vd,Wd,__ },	// (SSE)
{ "(bad)",	__,__,__ },
{ "COMISD",	Vq,Wq,__ },	// (SSE2)
{ "(bad)",	__,__,__ }};
opcode_t pre_0f_50[4] =
{{ "MOVMSKPS",	Gd,VRo,__},
{ "(bad)",      __,__,__ },
{ "MOVMSKPD",	Gd,VRo,__},
{ "(bad)",      __,__,__ }};
opcode_t pre_0f_51[4] =
{{ "SQRTPS",	Vo,Wo,__ },
{ "SQRTSS",	Vd,Wd,__ },
{ "SQRTPD",	Vo,Wo,__ },
{ "SQRTSD",	Vq,Wq,__ }};
opcode_t pre_0f_52[4] =
{{ "RSQRTPS",	Vo,Wo,__ },
{ "RSQRTSS",	Vd,Wd,__ },
{ "(bad)",      __,__,__ },
{ "(bad)",      __,__,__ }};
opcode_t pre_0f_53[4] =
{{ "RCPPS",	Vo,Wo,__ },
{ "RCPSS",	Vd,Wd,__ },
{ "(bad)",      __,__,__ },
{ "(bad)",      __,__,__ }};
opcode_t pre_0f_54[4] =
{{ "ANDPS",	Vo,Wo,__ },
{ "(bad)",      __,__,__ },
{ "ANDPD",	Vo,Wo,__ },
{ "(bad)",      __,__,__ }};
opcode_t pre_0f_55[4] =
{{ "ANDNPS",	Vo,Wo,__ },
{ "(bad)",      __,__,__ },
{ "ANDNPD",	Vo,Wo,__ },
{ "(bad)",      __,__,__ }};
opcode_t pre_0f_56[4] =
{{ "ORPS",	Vo,Wo,__ },
{ "(bad)",      __,__,__ },
{ "ORPD",	Vo,Wo,__ },
{ "(bad)",      __,__,__ }};
opcode_t pre_0f_57[4] =
{{ "XORPS",	Vo,Wo,__ },
{ "(bad)",      __,__,__ },
{ "XORPD",	Vo,Wo,__ },
{ "(bad)",      __,__,__ }};
opcode_t pre_0f_58[4] =
{{ "ADDPS",	Vo,Wo,__ },	// (SSE)
{ "ADDSS",	Vd,Wd,__ },	// (SSE)
{ "ADDPD",	Vo,Wo,__ },	// (SSE2)
{ "ADDSD",	Vq,Wq,__ }};	// (SSE2)
opcode_t pre_0f_59[4] =
{{ "MULPS",	Vo,Wo,__ },	// (SSE)
{ "MULSS",	Vd,Wd,__ },	// (SSE)
{ "MULPD",	Vo,Wo,__ },	// (SSE2)
{ "MULSD",	Vq,Wq,__ }};	// (SSE2)
opcode_t pre_0f_5a[4] =
{{ "CVTPS2PD",	Vo,Wq,__ },	// (SSE2)
{ "CVTSS2SD",	Vq,Wd,__ },	// (SSE2)
{ "CVTPD2PS",	Vo,Wo,__ },	// (SSE2)
{ "CVTSD2SS",	Vd,Wq,__ }};	// (SSE2)
opcode_t pre_0f_5b[4] =
{{ "CVTDQ2PS",	Vo,Wo,__ },	// (SSE2)
{ "CVTTPS2DQ",	Vo,Wo,__ },	// (SSE2)
{ "CVTPS2DQ",	Vo,Wo,__ },	// (SSE2)
{ "(bad)",      __,__,__ }};
opcode_t pre_0f_5c[4] =
{{ "SUBPS",	Vo,Wo,__ },	// (SSE)
{ "SUBSS",	Vd,Wd,__ },	// (SSE)
{ "SUBPD",	Vo,Wo,__ },	// (SSE2)
{ "SUBSD",	Vq,Wq,__ }};	// (SSE2)
opcode_t pre_0f_5d[4] =
{{ "MINPS",	Vo,Wo,__ },	// (SSE)
{ "MINSS",	Vd,Wd,__ },	// (SSE)
{ "MINPD",	Vo,Wo,__ },	// (SSE2)
{ "MINSD",	Vq,Wq,__ }};	// (SSE2)
opcode_t pre_0f_5e[4] =
{{ "DIVPS",	Vo,Wo,__ },	// (SSE)
{ "DIVSS",	Vd,Wd,__ },	// (SSE)
{ "DIVPD",	Vo,Wo,__ },	// (SSE2)
{ "DIVSD",	Vq,Wq,__ }};	// (SSE2)
opcode_t pre_0f_5f[4] =
{{ "MAXPS",	Vo,Wo,__ },	// (SSE)
{ "MAXSS",	Vd,Wd,__ },	// (SSE)
{ "MAXPD",	Vo,Wo,__ },	// (SSE2)
{ "MAXSD",	Vq,Wq,__ }};	// (SSE2)
opcode_t pre_0f_60[4] =
{{ "PUNPCKLBW",	Pq,Qd,__ },	// (MMX)
{ "(bad)",      __,__,__ },
{ "PUNPCKLBW",	Vo,Wo,__ },	// (SSE2) #3
{ "(bad)",      __,__,__ }};
opcode_t pre_0f_61[4] =
{{ "PUNPCKLWD",	Pq,Qd,__ },	// (MMX)
{ "(bad)",      __,__,__ },
{ "PUNPCKLWD",	Vo,Wo,__ },	// (SSE2) #3
{ "(bad)",      __,__,__ }};
opcode_t pre_0f_62[4] =
{{ "PUNPCKLDQ",	Pq,Qd,__ },	// (MMX)
{ "(bad)",      __,__,__ },
{ "PUNPCKLDQ",	Vo,Wo,__ },	// (SSE2) #3
{ "(bad)",      __,__,__ }};
opcode_t pre_0f_63[4] =
{{ "PACKSSWB",	Pq,Qq,__ },	// (MMX)
{ "(bad)",      __,__,__ },
{ "PACKSSWB",	Vo,Wo,__ },	// (SSE2)
{ "(bad)",      __,__,__ }};
opcode_t pre_0f_64[4] =
{{ "PCMPGTB",	Pq,Qq,__ },	// (MMX)
{ "(bad)",      __,__,__ },
{ "PCMPGTB",	Vo,Wo,__ },	// (SSE2)
{ "(bad)",      __,__,__ }};
opcode_t pre_0f_65[4] =
{{ "PCMPGTW",	Pq,Qq,__ },	// (MMX)
{ "(bad)",      __,__,__ },
{ "PCMPGTW",	Vo,Wo,__ },	// (SSE2)
{ "(bad)",      __,__,__ }};
opcode_t pre_0f_66[4] =
{{ "PCMPGTD",	Pq,Qq,__ },	// (MMX)
{ "(bad)",      __,__,__ },
{ "PCMPGTD",	Vo,Wo,__ },	// (SSE2)
{ "(bad)",      __,__,__ }};
opcode_t pre_0f_67[4] =
{{ "PACKUSWB",	Pq,Qq,__ },	// (MMX)
{ "(bad)",      __,__,__ },
{ "PACKUSWB",	Vo,Wo,__ },	// (SSE2)
{ "(bad)",      __,__,__ }};
opcode_t pre_0f_68[4] =
{{ "PUNPCKHBW",	Pq,Qq,__ },	// (MMX)
{ "(bad)",      __,__,__ },
{ "PUNPCKHBW",	Vo,Wo,__ },	// (SSE2)
{ "(bad)",      __,__,__ }};
opcode_t pre_0f_69[4] =
{{ "PUNPCKHWD",	Pq,Qq,__ },	// (MMX)
{ "(bad)",      __,__,__ },
{ "PUNPCKHWD",	Vo,Wo,__ },	// (SSE2)
{ "(bad)",      __,__,__ }};
opcode_t pre_0f_6a[4] =
{{ "PUNPCKHDQ",	Pq,Qq,__ },	// (MMX)
{ "(bad)",      __,__,__ },
{ "PUNPCKHDQ",	Vo,Wo,__ },	// (SSE2)
{ "(bad)",      __,__,__ }};
opcode_t pre_0f_6b[4] =
{{ "PACKSSDW",	Pq,Qq,__ },	// (MMX)
{ "(bad)",      __,__,__ },
{ "PACKSSDW",	Vo,Wo,__ },	// (SSE2)
{ "(bad)",      __,__,__ }};
opcode_t pre_0f_6c[4] =
{{ "(bad)",     __,__,__ },
{ "(bad)",      __,__,__ },
{ "PUNPCKLQDQ",	Vo,Wq,__ },	// (SSE2) #3
{ "(bad)",      __,__,__ }};
opcode_t pre_0f_6d[4] =
{{ "(bad)",     __,__,__ },
{ "(bad)",      __,__,__ },
{ "PUNPCKHQDQ",	Vo,Wo,__ },	// (SSE2)
{ "(bad)",      __,__,__ }};
opcode_t pre_0f_6e[4] =
{{ "MOVD",	Pq,Ed,__ },	// (MMX)
{ "(bad)",      __,__,__ },
{ "MOVD",	Vo,Ed,__ },	// (SSE2)
{ "(bad)",      __,__,__ }};
opcode_t pre_0f_6f[4] =
{{ "MOVQ",	Pq,Qq,__ },	// (MMX)
{ "MOVDQU",	Vo,Wo,__ },	// (SSE2)
{ "MOVDQA",	Vo,Wo,__ },	// (SSE2)
{ "(bad)",      __,__,__ }};
opcode_t pre_0f_70[4] =
{{ "PSHUFW",	Pq,Qq,Ib },	// (MMX-SSE)
{ "PSHUFHW",	Vo,Wo,Ib },	// (SSE2)
{ "PSHUFD",	Vo,Wo,Ib },	// (SSE2)
{ "PSHUFLW",	Vo,Wo,Ib }};	// (SSE2)
opcode_t pre_0f_74[4] =
{{ "PCMPEQB",	Pq,Qq,__ },	// (MMX)
{ "(bad)",      __,__,__ },
{ "PCMPEQB",	Vo,Wo,__ },	// (SSE2)
{ "(bad)",      __,__,__ }};
opcode_t pre_0f_75[4] =
{{ "PCMPEQW",	Pq,Qq,__ },	// (MMX)
{ "(bad)",      __,__,__ },
{ "PCMPEQW",	Vo,Wo,__ },	// (SSE2)
{ "(bad)",      __,__,__ }};
opcode_t pre_0f_76[4] =
{{ "PCMPEQD",	Pq,Qq,__ },	// (MMX)
{ "(bad)",      __,__,__ },
{ "PCMPEQD",	Vo,Wo,__ },	// (SSE2)
{ "(bad)",      __,__,__ }};
opcode_t pre_0f_78[4] =
{{ "VMREAD",	Ed,Gd,__ },	// (see CPUID) Eq,Gq
{ "(bad)",      __,__,__ },
{ "(bad)",	__,__,__ },	// EXTRQ Vo,Iw (/0) (SSE4A)
{ "(bad)",	__,__,__ }};	// NSERTQ Vo,Vo,Iw (SSE4A)
opcode_t pre_0f_79[4] =
{{ "VMWRITE",	Ed,Gd,__ },	// (see CPUID) Eq,Gq
{ "(bad)",      __,__,__ },
{ "(bad)",	__,__,__ },	// EXTRQ Vo,Vo (SSE4A)
{ "(bad)",	__,__,__ }};	// INSERTQ Vo, Vo (SSE4A)
opcode_t pre_0f_7c[4] =
{{ "(bad)",     __,__,__ },
{ "(bad)",      __,__,__ },
{ "HADDPD",	Vo,Wo,__ },	// (SSE3)
{ "HADDPS",	Vo,Wo,__ }};	// (SSE3)
opcode_t pre_0f_7d[4] =
{{ "(bad)",     __,__,__ },
{ "(bad)",      __,__,__ },
{ "HSUBPD",	Vo,Wo,__ },	// (SSE3)
{ "HSUBPS",	Vo,Wo,__ }};	// (SSE3)
opcode_t pre_0f_7e[4] =
{{ "MOVD",	Ed,Pd,__ },	// (MMX)
{ "MOVQ",	Vo,Mq,__ },	// Vq,Vq (SSE2)
{ "MOVD",	Ed,Vd,__ },	// (SSE2)
{ "(bad)",      __,__,__ }};
opcode_t pre_0f_7f[4] =
{{ "MOVQ",	Qq,Pq,__ },	// (MMX)
{ "MOVDQU",	Wo,Vo,__ },	// (SSE2)
{ "MOVDQA",	Wo,Vo,__ },	// (SSE2)
{ "(bad)",      __,__,__ }};
opcode_t pre_0f_c2[4] =
{{ "CMPccPS",	Vo,Wo,Ib }, 	// (SSE)
{ "CMPccSS",	Vd,Wd,Ib }, 	// (SSE)
{ "CMPccPD",	Vo,Wo,Ib }, 	// (SSE2)
{ "CMPccSD",	Vq,Wq,Ib }}; 	// (SSE2)
opcode_t pre_0f_c3[4] =
{{ "MOVNTI",	Md,Gd,__ },	// (SSE2-MEM)
{ "(bad)",      __,__,__ },
{ "(bad)",      __,__,__ },
{ "(bad)",      __,__,__ }};
opcode_t pre_0f_c4[4] =
{{ "PINSRW",	Pq,Mw,Ib },	// Pq,G[wd],Ib (MMX-SSE)
{ "(bad)",      __,__,__ },
{ "PINSRW",	Vo,Mw,Ib },	// Vo,G[wd],Ib (SSE2)
{ "(bad)",      __,__,__ }};
opcode_t pre_0f_c5[4] =
{{ "PEXTRW",	Gd,PRq,Ib},	// (MMX-SSE)
{ "(bad)",      __,__,__ },
{ "PEXTRW",	Gd,VRo,Ib},	// (SSE2)
{ "(bad)",      __,__,__ }};
opcode_t pre_0f_c6[4] =
{{ "SHUFPS",	Vo,Wo,Ib },	// (SSE)
{ "(bad)",      __,__,__ },
{ "SHUFPD",	Vo,Wo,Ib },	// (SSE2)
{ "(bad)",      __,__,__ }};
opcode_t pre_0f_d0[4] =
{{ "(bad)",     __,__,__ },
{ "(bad)",      __,__,__ },
{ "ADDSUBPD",	Vo,Wo,__ }, 	// (SSE3)
{ "ADDSUBPS",	Vo,Wo,__ }};	// (SSE3)
opcode_t pre_0f_d1[4] =
{{ "PSRLW",	Pq,Qq,__ },	// (MMX)
{ "(bad)",      __,__,__ },
{ "PSRLW",	Vo,Wo,__ },	// (SSE2) #4
{ "(bad)",      __,__,__ }};
opcode_t pre_0f_d2[4] =
{{ "PSRLD",	Pq,Qq,__ },	// (MMX)
{ "(bad)",      __,__,__ },
{ "PSRLD",	Vo,Wo,__ },	// (SSE2) #4
{ "(bad)",      __,__,__ }};
opcode_t pre_0f_d3[4] =
{{ "PSRLQ",	Pq,Qq,__ },	// (MMX)
{ "(bad)",      __,__,__ },
{ "PSRLQ",	Vo,Wo,__ },	// (SSE2) #4
{ "(bad)",      __,__,__ }};
opcode_t pre_0f_d4[4] =
{{ "PADDQ",	Pq,Qq,__ },	// (MMX-SSE2)
{ "(bad)",      __,__,__ },
{ "PADDQ",	Vo,Wo,__ },	// (SSE2)
{ "(bad)",      __,__,__ }};
opcode_t pre_0f_d5[4] =
{{ "PMULLW",	Pq,Qq,__ },	// (MMX)
{ "(bad)",      __,__,__ },
{ "PMULLW",	Vo,Wo,__ },	// (SSE2)
{ "(bad)",      __,__,__ }};
opcode_t pre_0f_d6[4] =
{{ "(bad)",     __,__,__ },
{ "MOVQ2DQ",	Vo,PRq,__},	// (SSE2-MMX)
{ "MOVQ",	Mq,Vq,__ },	// Vq,Vq (SSE2)
{ "MOVDQ2Q",	Pq,VRq,__}};	// (SSE2-MMX)
opcode_t pre_0f_d7[4] =
{{ "PMOVMSKB",	Gd,PRq,__},	// (MMX-SSE)
{ "(bad)",      __,__,__ },
{ "PMOVMSKB",	Gd,VRo,__},	// (SSE2)
{ "(bad)",      __,__,__ }};
opcode_t pre_0f_d8[4] =
{{ "PSUBUSB",	Pq,Qq,__ },	// (MMX)
{ "(bad)",      __,__,__ },
{ "PSUBUSB",	Vo,Wo,__ },	// (SSE2)
{ "(bad)",      __,__,__ }};
opcode_t pre_0f_d9[4] =
{{ "PSUBUSW",	Pq,Qq,__ },	// (MMX)
{ "(bad)",      __,__,__ },
{ "PSUBUSW",	Vo,Wo,__ },	// (SSE2)
{ "(bad)",      __,__,__ }};
opcode_t pre_0f_da[4] =
{{ "PMINUB",	Pq,Qq,__ },	// (MMX-SSE)
{ "(bad)",      __,__,__ },
{ "PMINUB",	Vo,Wo,__ },	// (SSE2)
{ "(bad)",      __,__,__ }};
opcode_t pre_0f_db[4] =
{{ "PAND",	Pq,Qq,__ },	// (MMX)
{ "(bad)",      __,__,__ },
{ "PAND",	Vo,Wo,__ },	// (SSE2)
{ "(bad)",      __,__,__ }};
opcode_t pre_0f_dc[4] =
{{ "PADDUSB",	Pq,Qq,__ },	// (MMX)
{ "(bad)",      __,__,__ },
{ "PADDUSB",	Vo,Wo,__ },	// (SSE2)
{ "(bad)",      __,__,__ }};
opcode_t pre_0f_dd[4] =
{{ "PADDUSW",	Pq,Qq,__ },	// (MMX)
{ "(bad)",      __,__,__ },
{ "PADDUSW",	Vo,Wo,__ },	// (SSE2)
{ "(bad)",      __,__,__ }};
opcode_t pre_0f_de[4] =
{{ "PMAXUB",	Pq,Qq,__ },	// (MMX-SSE)
{ "(bad)",      __,__,__ },
{ "PMAXUB",	Vo,Wo,__ },	// (SSE2)
{ "(bad)",      __,__,__ }};
opcode_t pre_0f_df[4] =
{{ "PANDN",	Pq,Qq,__ },	// (MMX)
{ "(bad)",      __,__,__ },
{ "PANDN",	Vo,Wo,__ },	// (SSE2)
{ "(bad)",      __,__,__ }};
opcode_t pre_0f_e0[4] =
{{ "PAVGB",	Pq,Qq,__ },	// (MMX-SSE)
{ "(bad)",      __,__,__ },
{ "PAVGB",	Vo,Wo,__ },	// (SSE2)
{ "(bad)",      __,__,__ }};
opcode_t pre_0f_e1[4] =
{{ "PSRAW",	Pq,Qq,__ },	// (MMX)
{ "(bad)",      __,__,__ },
{ "PSRAW",	Vo,Wo,__ },	// (SSE2) #4
{ "(bad)",      __,__,__ }};
opcode_t pre_0f_e2[4] =
{{ "PSRAD",	Pq,Qq,__ },	// (MMX)
{ "(bad)",      __,__,__ },
{ "PSRAD",	Vo,Wo,__ },	// (SSE2) #4
{ "(bad)",      __,__,__ }};
opcode_t pre_0f_e3[4] =
{{ "PAVGW",	Pq,Qq,__ },	// (MMX-SSE)
{ "(bad)",      __,__,__ },
{ "PAVGW",	Vo,Wo,__ },	// (SSE2)
{ "(bad)",      __,__,__ }};
opcode_t pre_0f_e4[4] =
{{ "PMULHUW",	Pq,Qq,__ },	// (MMX-SSE)
{ "(bad)",      __,__,__ },
{ "PMULHUW",	Vo,Wo,__ },	// (SSE2)
{ "(bad)",      __,__,__ }};
opcode_t pre_0f_e5[4] =
{{ "PMULHW",	Pq,Qq,__ },	// (MMX)
{ "(bad)",      __,__,__ },
{ "PMULHW",	Vo,Wo,__ },	// (SSE2)
{ "(bad)",      __,__,__ }};
opcode_t pre_0f_e6[4] =
{{ "(bad)",     __,__,__ },
{ "CVTDQ2PD",	Vo,Wq,__ },	// (SSE2)
{ "CVTTPD2DQ",	Vo,Wo,__ },	// (SSE2)
{ "CVTPD2DQ",	Vo,Wo,__ }};	// (SSE2)
opcode_t pre_0f_e7[4] =
{{ "MOVNTQ",	Mq,Pq,__ },	// (MMX-SSE)
{ "(bad)",      __,__,__ },
{ "MOVNTDQ",	Mo,Vo,__ },	// (SSE2)
{ "(bad)",      __,__,__ }};
opcode_t pre_0f_e8[4] =
{{ "PSUBSB",	Pq,Qq,__ },	// (MMX)
{ "(bad)",      __,__,__ },
{ "PSUBSB",	Vo,Wo,__ },	// (SSE2)
{ "(bad)",      __,__,__ }};
opcode_t pre_0f_e9[4] =
{{ "PSUBSW",	Pq,Qq,__ },	// (MMX)
{ "(bad)",      __,__,__ },
{ "PSUBSW",	Vo,Wo,__ },	// (SSE2)
{ "(bad)",      __,__,__ }};
opcode_t pre_0f_ea[4] =
{{ "PMINSW",	Pq,Qq,__ },	// (MMX-SSE)
{ "(bad)",      __,__,__ },
{ "PMINSW",	Vo,Wo,__ },	// (SSE2)
{ "(bad)",      __,__,__ }};
opcode_t pre_0f_eb[4] =
{{ "POR",	Pq,Qq,__ },	// (MMX)
{ "(bad)",      __,__,__ },
{ "POR",	Vo,Wo,__ },	// (SSE2)
{ "(bad)",      __,__,__ }};
opcode_t pre_0f_ec[4] =
{{ "PADDSB",	Pq,Qq,__ },	// (MMX)
{ "(bad)",      __,__,__ },
{ "PADDSB",	Vo,Wo,__ },	// (SSE2)
{ "(bad)",      __,__,__ }};
opcode_t pre_0f_ed[4] =
{{ "PADDSW",	Pq,Qq,__ },	// (MMX)
{ "(bad)",      __,__,__ },
{ "PADDSW",	Vo,Wo,__ },	// (SSE2)
{ "(bad)",      __,__,__ }};
opcode_t pre_0f_ee[4] =
{{ "PMAXSW",	Pq,Qq,__ },	// (MMX-SSE)
{ "(bad)",      __,__,__ },
{ "PMAXSW",	Vo,Wo,__ },	// (SSE2)
{ "(bad)",      __,__,__ }};
opcode_t pre_0f_ef[4] =
{{ "PXOR",	Pq,Qq,__ },	// (MMX)
{ "(bad)",      __,__,__ },
{ "PXOR",	Vo,Wo,__ },	// (SSE2)
{ "(bad)",      __,__,__ }};
opcode_t pre_0f_f0[4] =
{{ "(bad)",     __,__,__ },
{ "(bad)",      __,__,__ },
{ "(bad)",      __,__,__ },
{ "LDDQU",	Vo,Mo,__ }};	// (SSE3)
opcode_t pre_0f_f1[4] =
{{ "PSLLW",	Pq,Qq,__ },	// (MMX)
{ "(bad)",      __,__,__ },
{ "PSLLW",	Vo,Wo,__ },	// (SSE2) #4
{ "(bad)",      __,__,__ }};
opcode_t pre_0f_f2[4] =
{{ "PSLLD",	Pq,Qq,__ },	// (MMX)
{ "(bad)",      __,__,__ },
{ "PSLLD",	Vo,Wo,__ },	// (SSE2) #4
{ "(bad)",      __,__,__ }};
opcode_t pre_0f_f3[4] =
{{ "PSLLQ",	Pq,Qq,__ },	// (MMX)
{ "(bad)",      __,__,__ },
{ "PSLLQ",	Vo,Wo,__ },	// (SSE2) #4
{ "(bad)",      __,__,__ }};
opcode_t pre_0f_f4[4] =
{{ "PMULUDQ",	Pq,Qq,__ },	// (MMX-SSE2)
{ "(bad)",      __,__,__ },
{ "PMULUDQ",	Vo,Wo,__ },	// (SSE2)
{ "(bad)",      __,__,__ }};
opcode_t pre_0f_f5[4] =
{{ "PMADDWD",	Pq,Qq,__ },	// (MMX)
{ "(bad)",      __,__,__ },
{ "PMADDWD",	Vo,Wo,__ },	// (SSE2)
{ "(bad)",      __,__,__ }};
opcode_t pre_0f_f6[4] =
{{ "PSADBW",	Pq,Qq,__ },	// (MMX-SSE)
{ "(bad)",      __,__,__ },
{ "PSADBW",	Vo,Wo,__ },	// (SSE2)
{ "(bad)",      __,__,__ }};
opcode_t pre_0f_f7[4] =
{{ "MASKMOVQ",	Pq,PRq,__},	// (MMX-SSE)
{ "(bad)",      __,__,__ },
{ "MASKMOVDQU",	Vo,VRo,__},	// (SSE2)
{ "(bad)",      __,__,__ }};
opcode_t pre_0f_f8[4] =
{{ "PSUBB",	Pq,Qq,__ },	// (MMX)
{ "(bad)",      __,__,__ },
{ "PSUBB",	Vo,Wo,__ },	// (SSE2)
{ "(bad)",      __,__,__ }};
opcode_t pre_0f_f9[4] =
{{ "PSUBW",	Pq,Qq,__ },	// (MMX)
{ "(bad)",      __,__,__ },
{ "PSUBW",	Vo,Wo,__ },	// (SSE2)
{ "(bad)",      __,__,__ }};
opcode_t pre_0f_fa[4] =
{{ "PSUBD",	Pq,Qq,__ },	// (MMX)
{ "(bad)",      __,__,__ },
{ "PSUBD",	Vo,Wo,__ },	// (SSE2)
{ "(bad)",      __,__,__ }};
opcode_t pre_0f_fb[4] =
{{ "PSUBQ",	Pq,Qq,__ },	// (MMX-SSE2)
{ "(bad)",      __,__,__ },
{ "PSUBQ",	Vo,Wo,__ },	// (SSE2)
{ "(bad)",      __,__,__ }};
opcode_t pre_0f_fc[4] =
{{ "PADDB",	Pq,Qq,__ },	// (MMX)
{ "(bad)",      __,__,__ },
{ "PADDB",	Vo,Wo,__ },	// (SSE2)
{ "(bad)",      __,__,__ }};
opcode_t pre_0f_fd[4] =
{{ "PADDW",	Pq,Qq,__ },	// (MMX)
{ "(bad)",      __,__,__ },
{ "PADDW",	Vo,Wo,__ },	// (SSE2)
{ "(bad)",      __,__,__ }};
opcode_t pre_0f_fe[4] =
{{ "PADDD",	Pq,Qq,__ },	// (MMX)
{ "(bad)",      __,__,__ },
{ "PADDD",	Vo,Wo,__ },	// (SSE2)
{ "(bad)",      __,__,__ }};

/* MAIN TABLE */
opcode_t main_table[512] = {
/* 00 */
{ "ADD",	Eb,Gb,__ },
{ "ADD",	Ev,Gv,__ },
{ "ADD",	Gb,Eb,__ },
{ "ADD",	Gv,Ev,__ },
{ "ADD",	AL,Ib,__ },
{ "ADD",	rAX,Iz,__ },
{ "PUSH",	ES,__,__ },
{ "POP",	ES,__,__ },
/* 08 */
{ "OR",		Eb,Gb,__ },
{ "OR",		Ev,Gv,__ },
{ "OR",		Gb,Eb,__ },
{ "OR",		Gv,Ev,__ },
{ "OR",		AL,Ib,__ },
{ "OR",		rAX,Iz,__ },
{ "PUSH",	CS,__,__ },
{ "(bad)",	__,__,__ },	// two byte opcodes (80286+)
/* 10 */
{ "ADC",	Eb,Gb,__ },
{ "ADC",	Ev,Gv,__ },
{ "ADC",	Gb,Eb,__ },
{ "ADC",	Gv,Ev,__ },
{ "ADC",	AL,Ib,__ },
{ "ADC",	rAX,Iz,__ },
{ "PUSH",	SS,__,__ },
{ "POP",	SS,__,__ },
/* 18 */
{ "SBB",	Eb,Gb,__ },
{ "SBB",	Ev,Gv,__ },
{ "SBB",	Gb,Eb,__ },
{ "SBB",	Gv,Ev,__ },
{ "SBB",	AL,Ib,__ },
{ "SBB",	rAX,Iz,__ },
{ "PUSH",	DS,__,__ },
{ "POP",	DS,__,__ },
/* 20 */
{ "AND",	Eb,Gb,__ },
{ "AND",	Ev,Gv,__ },
{ "AND",	Gb,Eb,__ },
{ "AND",	Gv,Ev,__ },
{ "AND",	AL,Ib,__ },
{ "AND",	rAX,Iz,__ },
{ "(bad)",	__,__,__ },	// ES:
{ "DAA",	__,__,__ },
/* 28 */
{ "SUB",	Eb,Gb,__ },
{ "SUB",	Ev,Gv,__ },
{ "SUB",	Gb,Eb,__ },
{ "SUB",	Gv,Ev,__ },
{ "SUB",	AL,Ib,__ },
{ "SUB",	rAX,Iz,__ },
{ "(bad)",	__,__,__ },	// CS:, Hint Not Taken for Jcc (P4)
{ "DAS",	__,__,__ },
/* 30 */
{ "XOR",	Eb,Gb,__ },
{ "XOR",	Ev,Gv,__ },
{ "XOR",	Gb,Eb,__ },
{ "XOR",	Gv,Ev,__ },
{ "XOR",	AL,Ib,__ },
{ "XOR",	rAX,Iz,__ },
{ "(bad)",	__,__,__ },	// SS:
{ "AAA",	__,__,__ },
/* 38 */
{ "CMP",	Eb,Gb,__ },
{ "CMP",	Ev,Gv,__ },
{ "CMP",	Gb,Eb,__ },
{ "CMP",	Gv,Ev,__ },
{ "CMP",	AL,Ib,__ },
{ "CMP",	rAX,Iz,__ },
{ "(bad)",	__,__,__ },	// DS:, Hint Taken for Jcc (P4)
{ "AAS",	__,__,__ },
/* 40 */
{ "INC",	eAX,__,__ },
{ "INC",	eCX,__,__ },
{ "INC",	eDX,__,__ },
{ "INC",	eBX,__,__ },
{ "INC",	eSP,__,__ },
{ "INC",	eBP,__,__ },
{ "INC",	eSI,__,__ },
{ "INC",	eDI,__,__ },
/* 48 */
{ "DEC",	eAX,__,__ },
{ "DEC",	eCX,__,__ },
{ "DEC",	eDX,__,__ },
{ "DEC",	eBX,__,__ },
{ "DEC",	eSP,__,__ },
{ "DEC",	eBP,__,__ },
{ "DEC",	eSI,__,__ },
{ "DEC",	eDI,__,__ },
/* 50 */
{ "PUSH",	rAX,__,__ },
{ "PUSH",	rCX,__,__ },
{ "PUSH",	rDX,__,__ },
{ "PUSH",	rBX,__,__ },
{ "PUSH",	rSP,__,__ },
{ "PUSH",	rBP,__,__ },
{ "PUSH",	rSI,__,__ },
{ "PUSH",	rDI,__,__ },
/* 58 */
{ "POP",	rAX,__,__ },
{ "POP",	rCX,__,__ },
{ "POP",	rDX,__,__ },
{ "POP",	rBX,__,__ },
{ "POP",	rSP,__,__ },
{ "POP",	rBP,__,__ },
{ "POP",	rSI,__,__ },
{ "POP",	rDI,__,__ },
/* 60 */
{ "PUSHA",	__,__,__ },	// (80186+)
{ "POPA",	__,__,__ },	// (80186+)
{ "BOUND",	Gv,Ma,__ },	// (80186+)
{ "ARPL",	Ew,Gw,__ },	// (80286+)
{ "(bad)",	__,__,__ },	// FS: (80386+), Hint Alt Taken for Jcc (P4)
{ "(bad)",	__,__,__ },	// GS: (80386+)
{ "(bad)",	__,__,__ },	// OPSIZE: (80386+)
{ "(bad)",	__,__,__ },	// ADSIZE: (80386+)
/* 68 */
{ "PUSH",	Iz,__,__ },	// (80186+)
{ "IMUL",	Gv,Ev,Iz },	// (80186+)
{ "PUSH",	Ib,__,__ },	// (80186+)
{ "IMUL",	Gv,Ev,Ib },	// (80186+)
{ "INS",	Yb,DX,__ },	// (80186+)
{ "INS",	Yz,DX,__ },	// (80186+)
{ "OUTS",	DX,Xb,__ },	// (80186+)
{ "OUTS",	DX,Xz,__ },	// (80186+)
/* 70 */
{ "JO",		Jb,__,__ },
{ "JNO",	Jb,__,__ },
{ "JB",		Jb,__,__ },
{ "JNB",	Jb,__,__ },
{ "JZ",		Jb,__,__ },
{ "JNZ",	Jb,__,__ },
{ "JBE",	Jb,__,__ },
{ "JNBE",	Jb,__,__ },
/* 78 */
{ "JS",		Jb,__,__ },
{ "JNS",	Jb,__,__ },
{ "JP",		Jb,__,__ },
{ "JNP",	Jb,__,__ },
{ "JL",		Jb,__,__ },
{ "JNL",	Jb,__,__ },
{ "JLE",	Jb,__,__ },
{ "JNLE",	Jb,__,__ },
/* 80 */
{ "group1",	Eb,Ib,__ },	// NB!
{ "group1",	Ev,Iz,__ },
{ "group1",	Eb,Ib,__ },
{ "group1",	Ev,Ib,__ },
{ "TEST",	Eb,Gb,__ },
{ "TEST",	Ev,Gv,__ },
{ "XCHG",	Eb,Gb,__ },
{ "XCHG",	Ev,Gv,__ },
/* 88 */
{ "MOV",	Eb,Gb,__ },
{ "MOV",	Ev,Gv,__ },
{ "MOV",	Gb,Eb,__ }, 
{ "MOV",	Gv,Ev,__ },
{ "MOV",	E,Sw,__	},	// Mw,Sw/MOV Rv,Sw
{ "LEA",	Gv,M,__ },
{ "MOV", 	Sw,E,__ },	// Sw,Mw/MOV Sw,Rv
{ _V group10,	GRP,__,__ },
/* 90 */
{ "NOP",	__,__,__ },	// PAUSE (F3h) (see CPUID)
{ "XCHG",	rCX,rAX,__ },
{ "XCHG",	rDX,rAX,__ },
{ "XCHG",	rBX,rAX,__ },
{ "XCHG",	rSP,rAX,__ },
{ "XCHG",	rBP,rAX,__ },
{ "XCHG",	rSI,rAX,__ },
{ "XCHG",	rDI,rAX,__ },
/* 98 */
{ "CBW",	__,__,__ },	// (8088) CBW/CWDE (80386+)
{ "CWD",	__,__,__ },	// (8088) CWD/CDQ (80386+)
{ "CALL",	Ap,__,__ },
{ "WAIT",	__,__,__ },	// FWAIT
{ "PUSHF",	Fv,__,__ },
{ "POPF",	Fv,__,__ },
{ "SAHF",	__,__,__ },
{ "LAHF",	__,__,__ },
/* A0 */
{ "MOV",	AL,Ob,__ },
{ "MOV",	rAX,Ov,__ },
{ "MOV",	Ob,AL,__ },
{ "MOV",	Ov,rAX,__ },
{ "MOVS",	Yb,Xb,__ },
{ "MOVS",	Yv,Xv,__ },
{ "CMPS",	Yb,Xb,__ },
{ "CMPS",	Yv,Xv,__ },
/* A8 */
{ "TEST",	AL,Ib,__ },
{ "TEST",	rAX,Iz,__ },
{ "STOS",	Yb,AL,__ },
{ "STOS",	Yv,rAX,__ },
{ "LODS",	AL,Xb,__ },
{ "LODS",	rAX,Xv,__ },
{ "SCAS",	Yb,AL,__ },
{ "SCAS",	Yv,rAX,__ },
/* B0 */
{ "MOV",	AL,Ib,__ },
{ "MOV",	CL,Ib,__ },
{ "MOV",	DL,Ib,__ },
{ "MOV",	BL,Ib,__ },
{ "MOV",	AH,Ib,__ },
{ "MOV",	CH,Ib,__ },
{ "MOV",	DH,Ib,__ },
{ "MOV",	BH,Ib,__ },
/* B8 */
{ "MOV",	rAX,Iv,__ },
{ "MOV",	rCX,Iv,__ },
{ "MOV",	rDX,Iv,__ },
{ "MOV",	rBX,Iv,__ },
{ "MOV",	rSP,Iv,__ },
{ "MOV",	rBP,Iv,__ },
{ "MOV",	rSI,Iv,__ },
{ "MOV",	rDI,Iv,__ },
/* C0 */
{ "group2",	Eb,Ib,__ },	// (80186+)	NB!
{ "group2",	Ev,Ib,__ },	// (80186+)
{ "RET",	STOP | Iw,__,__ },
{ "RET",	STOP,__,__ },
{ "LES",	Gz,Mp,__ },
{ "LDS",	Gz,Mp,__ },
{ _V group12,	GRP | Eb,Ib,__ },
{ _V group12,	GRP | Ev,Iz,__ },
/* C8 */
{ "ENTER",	Iw,Ib,__ },	// (80186+)
{ "LEAVE",	__,__,__ },	// (80186+)
{ "RETF",	STOP | Iw,__,__ },
{ "RETF",	STOP,__,__ },
{ "INT3",	__,__,__ },
{ "INT",	Ib,__,__ },
{ "INTO",	__,__,__ },
{ "IRET",	STOP,__,__ },
/* D0 */
{ "group2",	Eb,__,__ },	//1	NB!
{ "group2",	Ev,__,__ },	//1
{ "group2",	Eb,CL,__ },
{ "group2",	Ev,CL,__ },
{ "AAM",	Ib,__,__ },
{ "AAD",	Ib,__,__ },
{ "SALC",	__,__,__ },	// SETALC
{ "XLAT",	__,__,__ },
/* D8 */
{ "FPU",	E,__,__ },
{ "FPU",	E,__,__ },
{ "FPU",	E,__,__ },
{ "FPU",	E,__,__ },
{ "FPU",	E,__,__ },
{ "FPU",	E,__,__ },
{ "FPU",	E,__,__ },
{ "FPU",	E,__,__ },
/* E0 */
{ "LOOPNE",	Jb,__,__ },
{ "LOOPE",	Jb,__,__ },
{ "LOOP",	Jb,__,__ },
{ "JCXZ",	Jb,__,__ },
{ "IN",		AL,Ib,__ },
{ "IN",		eAX,Ib,__ },
{ "OUT",	Ib,AL,__ },
{ "OUT",	Ib,eAX,__ },
/* E8 */
{ "CALL",	Jz,__,__ },
{ "JMP",	STOP | Jz,__,__ },
{ "JMP",	STOP | Ap,__,__ },
{ "JMP",	STOP | Jb,__,__ },
{ "IN",		AL,DX,__ },
{ "IN",		eAX,DX,__ },
{ "OUT",	DX,AL,__ },
{ "OUT",	DX,eAX,__ },
/* F0 */
{ "(bad)",	__,__,__ },	// LOCK:
{ "INT1",	__,__,__ },	// (ICEBP) (80386+)
{ "(bad)",	__,__,__ },	// REPNE:
{ "(bad)",	__,__,__ },	// REP: REPE:
{ "HLT",	__,__,__ },
{ "CMC",	__,__,__ },
{ _V group3_F6,	GRP,__,__ },	// Eb
{ _V group3_F7,	GRP,__,__ },	// Ev
/* F8 */
{ "CLC",	__,__,__ },
{ "STC",	__,__,__ },
{ "CLI",	__,__,__ },
{ "STI",	__,__,__ },
{ "CLD",	__,__,__ },
{ "STD",	__,__,__ },
{ _V group4,	GRP,__,__ },	// INC/DEC
{ _V group5,	GRP,__,__ },	// INC/DEC etc.
/* 0f 00 */
{ _V group6,	GRP,__,__ },
{ _V group7,	GRP,__,__ },
{ "LAR",	Gv,Ew,__ },
{ "LSL",	Gv,Ew,__ },
{ "(bad)",	__,__,__ },	// LOADALL (80286)
{ "SYSCALL",	__,__,__ },	// LOADALL (80286) SYSCALL (AMD)
{ "CLTS",	__,__,__ },
{ "SYSRET",	__,__,__ }, 	// LOADALL (80386) SYSRET (AMD)
/* 0f 08 */
{ "INVD",	__,__,__ },	// (80486+)
{ "WBINVD",	__,__,__ },	// (80486+)
{ "(bad)",	__,__,__ },
{ "(bad)",	__,__,__ },	// UD1 (80286+)
{ "(bad)",	__,__,__ },
{ "PREFETCH",	E,__,__ },	// Group NB!
{ "FEMMS",	__,__,__ },
{ "3DNow!",	E,Ib,__ },
/* 0f 10 */
{ _V pre_0f_10,	PRE,__,__ },
{ _V pre_0f_11,	PRE,__,__ },
{ _V pre_0f_12,	PRE,__,__ },
{ _V pre_0f_13,	PRE,__,__ },
{ _V pre_0f_14,	PRE,__,__ },
{ _V pre_0f_15,	PRE,__,__ },
{ _V pre_0f_16,	PRE,__,__ },
{ _V pre_0f_17,	PRE,__,__ },
/* 0f 18 */
{ "group17",	Ev,__,__ },	// NB!
{ "group17",	Ev,__,__ },
{ "group17",	Ev,__,__ },
{ "group17",	Ev,__,__ },
{ "group17",	Ev,__,__ },
{ "group17",	Ev,__,__ },
{ "group17",	Ev,__,__ },
{ "group17",	Ev,__,__ },
/* 0f 20 */
{ "MOV",	Rd,Cd,__ },	// (80386+)
{ "MOV",	Rd,Dd,__ },	// (80386+)
{ "MOV",	Cd,Rd,__ },	// (80386+)
{ "MOV",	Dd,Rd,__ },	// (80386+)
{ "(bad)",	__,__,__ },	// MOV Rd,Td (80386/486) SSE5A (AMD)
{ "(bad)",	__,__,__ },	// SSE5A (AMD)
{ "(bad)",	__,__,__ },	// MOV Td,Rd (80386/486) 
{ "(bad)",	__,__,__ },
/* 0f 28 */
{ _V pre_0f_28,	PRE,__,__ },
{ _V pre_0f_29,	PRE,__,__ },
{ _V pre_0f_2a,	PRE,__,__ },
{ _V pre_0f_2b,	PRE,__,__ },
{ _V pre_0f_2c,	PRE,__,__ },
{ _V pre_0f_2d,	PRE,__,__ },
{ _V pre_0f_2e,	PRE,__,__ },
{ _V pre_0f_2f,	PRE,__,__ },
/* 0f 30 */
{ "WRMSR",	__,__,__ },
{ "RDTSC",	__,__,__ },
{ "RDMSR",	__,__,__ },
{ "RDPMC",	__,__,__ },
{ "SYSENTER",	__,__,__ },
{ "SYSEXIT",	__,__,__ },
{ "(bad)",	__,__,__ },	// RDSHR Ed (Cyrix)
{ "GETSEC",	__,__,__ },	// WRSHR Ed (Cyrix)
/* 0f 38 */
{ "(bad)",	__,__,__ },	// 3-bytes opcodes
{ "(bad)",	__,__,__ },	// 3-bytes opcodes
{ "(bad)",	__,__,__ },	// 3-bytes opcodes
{ "(bad)",	__,__,__ },	// 3-bytes opcodes
{ "(bad)",	__,__,__ },	// 3-bytes opcodes
{ "(bad)",	__,__,__ },	// 3-bytes opcodes
{ "(bad)",	__,__,__ },	// 3-bytes opcodes
{ "(bad)",	__,__,__ },	// 3-bytes opcodes
/* 0f 40 */
{ "CMOVO",	Gv,Ev,__ },
{ "CMOVNO",	Gv,Ev,__ },
{ "CMOVB",	Gv,Ev,__ },
{ "CMOVNB",	Gv,Ev,__ },
{ "CMOVZ",	Gv,Ev,__ },
{ "CMOVNZ",	Gv,Ev,__ },
{ "CMOVBE",	Gv,Ev,__ },
{ "CMOVNBE",	Gv,Ev,__ },
/* 0f 48 */
{ "CMOVS",	Gv,Ev,__ },
{ "CMOVNS",	Gv,Ev,__ },
{ "CMOVP",	Gv,Ev,__ },
{ "CMOVNP",	Gv,Ev,__ },
{ "CMOVL",	Gv,Ev,__ },
{ "CMOVNL",	Gv,Ev,__ },
{ "CMOVLE",	Gv,Ev,__ },
{ "CMOVNLE",	Gv,Ev,__ },
/* 0f 50 */
{ _V pre_0f_50,	PRE,__,__},
{ _V pre_0f_51,	PRE,__,__},
{ _V pre_0f_52,	PRE,__,__},
{ _V pre_0f_53,	PRE,__,__},
{ _V pre_0f_54,	PRE,__,__},
{ _V pre_0f_55,	PRE,__,__},
{ _V pre_0f_56,	PRE,__,__},
{ _V pre_0f_57,	PRE,__,__},
/* 0f 58 */
{ _V pre_0f_58,	PRE,__,__},
{ _V pre_0f_59,	PRE,__,__},
{ _V pre_0f_5a,	PRE,__,__},
{ _V pre_0f_5b,	PRE,__,__},
{ _V pre_0f_5c,	PRE,__,__},
{ _V pre_0f_5d,	PRE,__,__},
{ _V pre_0f_5e,	PRE,__,__},
{ _V pre_0f_5f,	PRE,__,__},
/* 0f 60 */
{ _V pre_0f_60,	PRE,__,__},
{ _V pre_0f_61,	PRE,__,__},
{ _V pre_0f_62,	PRE,__,__},
{ _V pre_0f_63,	PRE,__,__},
{ _V pre_0f_64,	PRE,__,__},
{ _V pre_0f_65,	PRE,__,__},
{ _V pre_0f_66,	PRE,__,__},
{ _V pre_0f_67,	PRE,__,__},
/* 0f 68 */
{ _V pre_0f_68,	PRE,__,__},
{ _V pre_0f_69,	PRE,__,__},
{ _V pre_0f_6a,	PRE,__,__},
{ _V pre_0f_6b,	PRE,__,__},
{ _V pre_0f_6c,	PRE,__,__},
{ _V pre_0f_6d,	PRE,__,__},
{ _V pre_0f_6e,	PRE,__,__},
{ _V pre_0f_6f,	PRE,__,__},
/* 0f 70 */
{ _V pre_0f_70,	PRE,__,__},
{ _V group13,	GRP,__,__},
{ _V group14,	GRP,__,__},
{ _V group15,	GRP,__,__},
{ _V pre_0f_74,	PRE,__,__},
{ _V pre_0f_75,	PRE,__,__},
{ _V pre_0f_76,	PRE,__,__},
{ "EMMS",	__,__,__ },	// MMX
/* 0f 78 */
{ "(bad)",	__,__,__ },	// VMX { "VMREAD",	Ed,Gd,__ },	// { _V pre_0f_78,	PRE,__,__},
{ "(bad)",	__,__,__ },	// VMX { "VMWRITE",	Gd,Ed,__ },	// { _V pre_0f_79,	PRE,__,__},
{ "(bad)",	__,__,__ },	// (SSE5A)
{ "(bad)",	__,__,__ },	// (SSE5A)
{ _V pre_0f_7c,	PRE,__,__},
{ _V pre_0f_7d,	PRE,__,__},
{ _V pre_0f_7e,	PRE,__,__},
{ _V pre_0f_7f,	PRE,__,__},
/* 0f 80 */
{ "JO",		Jz,__,__},	// (80386+)
{ "JNO",	Jz,__,__},	// (80386+)
{ "JB",		Jz,__,__},	// (80386+)
{ "JNB",	Jz,__,__},	// (80386+)
{ "JZ",		Jz,__,__},	// (80386+)
{ "JNZ",	Jz,__,__},	// (80386+)
{ "JBE",	Jz,__,__},	// (80386+)
{ "JNBE",	Jz,__,__},	// (80386+)
/* 0f 88 */
{ "JS",		Jz,__,__},	// (80386+)
{ "JNS",	Jz,__,__},	// (80386+)
{ "JP",		Jz,__,__},	// (80386+)
{ "JNP",	Jz,__,__},	// (80386+)
{ "JL",		Jz,__,__},	// (80386+)
{ "JNL",	Jz,__,__},	// (80386+)
{ "JLE",	Jz,__,__},	// (80386+)
{ "JNLE",	Jz,__,__},	// (80386+)
/* 0f 90 */
{ "SETO",	Eb,__,__},	// (80386+)
{ "SETNO",	Eb,__,__},	// (80386+)
{ "SETB",	Eb,__,__},	// (80386+)
{ "SETNB",	Eb,__,__},	// (80386+)
{ "SETZ",	Eb,__,__},	// (80386+)
{ "SETNZ",	Eb,__,__},	// (80386+)
{ "SETBE",	Eb,__,__},	// (80386+)
{ "SETNBE",	Eb,__,__},	// (80386+)
/* 0f 98 */
{ "SETS",	Eb,__,__},	// (80386+)
{ "SETNS",	Eb,__,__},	// (80386+)
{ "SETP",	Eb,__,__},	// (80386+)
{ "SETNP",	Eb,__,__},	// (80386+)
{ "SETL",	Eb,__,__},	// (80386+)
{ "SETNL",	Eb,__,__},	// (80386+)
{ "SETLE",	Eb,__,__},	// (80386+)
{ "SETNLE",	Eb,__,__},	// (80386+)
/* 0f a0 */
{ "PUSH",	FS,__,__},	// (80386+)
{ "POP",	FS,__,__},	// (80386+)
{ "CPUID",	__,__,__},	// (EFLAGS.ID)
{ "BT",		Ev,Gv,__},	// (80386+)
{ "SHLD",	Ev,Gv,Ib},	// (80386+)
{ "SHLD",	Ev,Gv,CL},	// (80386+)
{ "(bad)",	__,__,__},	// XBTS and CMPXCHG (386/486-A) MONTMUL (Centaur MM) XSHA (Centaur HE)
{ "(bad)",	__,__,__},	// IBTS and CMPXCHG (386/486-A) XSTORE (Centaur RNG) XCRYPT (Centaur ACE)
/* 0f a8 */
{ "PUSH",	GS,__,__},	// (80386+)
{ "POP",	GS,__,__},	// (80386+)
{ "RSM",	__,__,__},	// (SMM)(80386SL+?)
{ "BTS",	Ev,Gv,__},	// (80386+)
{ "SHRD",	Ev,Gv,Ib},	// (80386+)
{ "SHRD",	Ev,Gv,CL},	// (80386+)
{ _V group16,	GRP,__,__},
{ "IMUL",	Gv,Ev,__},	// (80386+)
/* 0f b0 */
{ "CMPXCHG",	Eb,Gb,__},	// (80486-B+)
{ "CMPXCHG",	Ev,Gv,__},	// (80486-B+)
{ "LSS",	Gz,Mp,__},	// (80386+)
{ "BTR",	Ev,Gv,__},	// (80386+)
{ "LFS",	Gz,Mp,__},	// (80386+)
{ "LGS",	Gz,Mp,__},	// (80386+)
{ "MOVZX",	Gv,Eb,__},	// (80386+)
{ "MOVZX",	Gv,Ew,__},	// (80386+)
/* 0f b8 */
{ "(bad)",	__,__,__},	// JMPE Jz (IA-64) (F3) POPCNT Gv,Ev (SSE4A)
{ "(bad)",	__,__,__},	// group11 UD2 (80286+)
{ _V group8,	GRP | Ev,Ib,__},// (80386+)
{ "BTC",	Ev,Gv,__},	// (80386+)
{ "BSF",	Gv,Ev,__},	// (80386+)
{ "BSR",	Gv,Ev,__},	// (80386+) (F3) LZCNT Gv,Ev (SSE4A)
{ "MOVSX",	Gv,Eb,__},	// (80386+)
{ "MOVSX",	Gv,Ew,__},	// (80386+)
/* 0f c0 */
{ "XADD",	Eb,Gb,__},	// (80486+)
{ "XADD",	Ev,Gv,__},	// (80486+)
{ _V pre_0f_c2,	PRE,__,__},
{ _V pre_0f_c3,	PRE,__,__},
{ _V pre_0f_c4,	PRE,__,__},
{ _V pre_0f_c5,	PRE,__,__},
{ _V pre_0f_c6,	PRE,__,__},
{ _V group9,	GRP,__,__},
/* 0f c8 */
{ "BSWAP",	eAX,__,__},	// (80486+)
{ "BSWAP",	eCX,__,__},	// (80486+)
{ "BSWAP",	eDX,__,__},	// (80486+)
{ "BSWAP",	eBX,__,__},	// (80486+)
{ "BSWAP",	eSP,__,__},	// (80486+)
{ "BSWAP",	eBP,__,__},	// (80486+)
{ "BSWAP",	eSI,__,__},	// (80486+)
{ "BSWAP",	eDI,__,__},	// (80486+)
/* 0f d0 */
{ _V pre_0f_d0,	PRE,__,__},
{ _V pre_0f_d1,	PRE,__,__},
{ _V pre_0f_d2,	PRE,__,__},
{ _V pre_0f_d3,	PRE,__,__},
{ _V pre_0f_d4,	PRE,__,__},
{ _V pre_0f_d5,	PRE,__,__},
{ _V pre_0f_d6,	PRE,__,__},
{ _V pre_0f_d7,	PRE,__,__},
/* 0f d8 */
{ _V pre_0f_d8,	PRE,__,__},
{ _V pre_0f_d9,	PRE,__,__},
{ _V pre_0f_da,	PRE,__,__},
{ _V pre_0f_db,	PRE,__,__},
{ _V pre_0f_dc,	PRE,__,__},
{ _V pre_0f_dd,	PRE,__,__},
{ _V pre_0f_de,	PRE,__,__},
{ _V pre_0f_df,	PRE,__,__},
/* 0f e0 */
{ _V pre_0f_e0,	PRE,__,__},
{ _V pre_0f_e1,	PRE,__,__},
{ _V pre_0f_e2,	PRE,__,__},
{ _V pre_0f_e3,	PRE,__,__},
{ _V pre_0f_e4,	PRE,__,__},
{ _V pre_0f_e5,	PRE,__,__},
{ _V pre_0f_e6,	PRE,__,__},
{ _V pre_0f_e7,	PRE,__,__},
/* 0f e8 */
{ _V pre_0f_e8,	PRE,__,__},
{ _V pre_0f_e9,	PRE,__,__},
{ _V pre_0f_ea,	PRE,__,__},
{ _V pre_0f_eb,	PRE,__,__},
{ _V pre_0f_ec,	PRE,__,__},
{ _V pre_0f_ed,	PRE,__,__},
{ _V pre_0f_ee,	PRE,__,__},
{ _V pre_0f_ef,	PRE,__,__},
/* 0f f0 */
{ _V pre_0f_f0,	PRE,__,__},
{ _V pre_0f_f1,	PRE,__,__},
{ _V pre_0f_f2,	PRE,__,__},
{ _V pre_0f_f3,	PRE,__,__},
{ _V pre_0f_f4,	PRE,__,__},
{ _V pre_0f_f5,	PRE,__,__},
{ _V pre_0f_f6,	PRE,__,__},
{ _V pre_0f_f7,	PRE,__,__},
/* 0f f8 */
{ _V pre_0f_f8,	PRE,__,__},
{ _V pre_0f_f9,	PRE,__,__},
{ _V pre_0f_fa,	PRE,__,__},
{ _V pre_0f_fb,	PRE,__,__},
{ _V pre_0f_fc,	PRE,__,__},
{ _V pre_0f_fd,	PRE,__,__},
{ _V pre_0f_fe,	PRE,__,__},
{ "(bad)",	__,__,__ }};	// UD (AMD)

#include "opcodes_fpu.h"

/* 3DNow */
char *Cmd3DNow[256] = {
	[0x0c] = "PI2FW*",
	[0x0d] = "PI2FD",
	[0x1c] = "PF2IW*",
	[0x1d] = "PF2ID",
	[0x8a] = "PFNACC*",
	[0x8e] = "PFPNACC*",
	[0x90] = "PFCMPGE",
	[0x94] = "PFMIN",
	[0x96] = "PFRCP",
	[0x97] = "PFRSQRT",
	[0x9a] = "PFSUB",
	[0x9e] = "PFADD",
	[0xa0] = "PFCMPGT",
	[0xa4] = "PFMAX",
	[0xa6] = "PFRCPIT1",
	[0xa7] = "PFRSQIT1",
	[0xaa] = "PFSUBR",
	[0xae] = "PFACC",
	[0xb0] = "PFCMPEQ",
	[0xb4] = "PFMUL",
	[0xb6] = "PFRCPIT2",
	[0xb7] = "PMULHRW",
	[0xbb] = "PSWAPD*",
	[0xbf] = "PAVGUSB",
};
