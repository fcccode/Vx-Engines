#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>

#include "opcodes.h"
#include "../yad.h"

#define	MAX_ENTRIES	1024
uint16_t table[MAX_ENTRIES];
int last = 512;
uint8_t yad_float[56] = {
0x00,0x00,0xfe,0x00,0xcc,0x80,0x00,0x00,
0x00,0x00,0x00,0x00,0xff,0xfd,0xff,0xff,
0x00,0x00,0x00,0x00,0xe0,0x00,0x00,0xff,
0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
0x00,0x00,0x00,0x00,0x00,0x00,0xff,0xff,
0x00,0x00,0x00,0xfd,0x00,0x00,0x00,0x00,
0x00,0x00,0x00,0x00,0xfe,0x00,0x00,0xff,
};
uint8_t yad_3dnow[32];

int arg(uint32_t type)
{
	int a, b, flags, aa = 0;
	
	a = type & 0x0000ff00;	/* op. type */
	b = type & 0x000000ff;	/* op. mode */
	flags = 0;
	if (type & REL)
		flags |= C_REL;
	if (type & STOP)
		flags |= C_STOP;
	switch (a) {
		case OP_M:

		case OP_R: case OP_PR: case OP_VR:
	
                case OP_C: case OP_D: case OP_G:
		case OP_P: case OP_S: case OP_V: 
		case OP_E: case OP_Q: case OP_W:
			flags |= C_MODRM; aa++;
			break;
		case OP_J:
			flags |= C_REL;
			if (b == b_b)
				flags |= C_DATA1;
			else
				flags |= C_DATA66;
			aa++;
			break;
		case OP_O:
			flags |= C_ADDR67;
			aa++;
			break;
		case OP_A:
			if (b == b_p) {
				flags |= C_DATA66 | C_DATA2;
				aa++;
			}
			break;
		case OP_I:
			switch (b) {
				case b_b:
					flags |= C_DATA1;
					break;
				case b_w:
					flags |= C_DATA2;
					break;
	
				case b_q:
				case b_v:
				case b_z:
					flags |= C_DATA66;
					break;
				default:
					printf("DATA MODE: %02x\n", b);
					exit(2);
			}
			aa++;
			break;
		case OP_F:
		case OP_X:
		case OP_Y:
			aa++;
			break;
		case OP_REG:
			aa++;
			break;
		default:
			if (a != 0)
				fprintf(stderr, "Type %08x left unhandled\n", a);
			break;
	}
	return flags;
}

void compile(uint16_t *dst, opcode_t *src, int size, uint16_t tpl_flags)
{
	int i;
	for (i = 0; i < size; i++) {
		if (! strcmp(src[i].name, "(bad)"))
			dst[i] = C_ERROR;
		else
			dst[i] = arg(src[i].op1) | arg(src[i].op2) | arg(src[i].op3) | tpl_flags;
	}
}

int add_to_table(uint16_t *what, opcode_t *src, int size)
{
	int i, s, index;
	int find_best_match(void) {
		for (i = 0; i <= last - size; i++)
			if (! memcmp(&table[i], what, size * 2))
				return i;
		return -1;
	}
	int find_any_match(void) {
		for (i = last - size; i < last; i++)
			if (! memcmp(&table[i], what, (last - i) * 2))
				return i;
		return -1;
	}
	if ((index = find_best_match()) != -1) {
//		fprintf(stderr,"perfect match\n");
		return index;
	}
	if ((index = find_any_match()) != -1) {
		s = last - index;
//		fprintf(stderr,"worse match %d out of %d, index %d\n", s, size, index);
	} else {
//		fprintf(stderr,"no match\n");
		s = 0;
		index = last;
	}
	for (i = s; i < size; i++) {
		table[index + i] = what[i];
	}
	last += (size - s);
	
/*	for (index = -1, i = 0; i <= last - size; i++)
		if (! memcmp(&table[i], what, size * 2)) {
			index = i;
			break;
		}
	if (index == -1) {
		index = last;
		for (i = 0; i < size; i++) {
			table[index + i] = what[i];
		}
		last += size;
	} */
	return index;
}

void compile_groups(uint32_t type)
{
	int i;
	uint16_t tmp[8], tpl_flags, sz, gf;

	for (i = 0; i < 512; i++) {
		if ((main_table[i].op1 & type) == 0)
			continue;
		compile(&tpl_flags, &main_table[i], 1, 0);
		if (main_table[i].op1 & GRP) {
			sz = 8;
			gf = C_GROUP;
		} else {
			sz = 4;
			gf = C_PREGRP;
		}
		bzero(tmp, 8 * 2);
		compile(tmp, (opcode_t*)main_table[i].name, sz, tpl_flags);
#ifdef	NO_MODRM_ON_GRP
		int j;
		for (j = 0; j < sz; j++)
			if (tmp[j] != C_ERROR)
				tmp[j] &= ~C_MODRM;
#endif
		table[i] = gf | add_to_table(tmp, (opcode_t*)main_table[i].name, sz);
	}
}

void compile_table(void)
{
	int i;
	/* compile regular opcodes */
	for (i = 0; i < 512; i++) {
		if (main_table[i].op1 & (GRP|PRE)) {
			table[i] = 0x55aa;
			continue;
		}
		compile(&table[i], &main_table[i], 1, 0);
	}
	compile_groups(GRP);	
	compile_groups(PRE);	
}

void compile_float(void)
{
//	int i;
//	bzero(yad_float, sizeof(yad_float));
//	for (i = 0; i < 64 - 8; i++)
//		if (! strcmp(FPU_mem[i + 8].name, "(bad)"))
//			yad_float[i / 8] |= (1 << (i % 8));
//	for (i = 0; i < 512 - 64; i++)
//		if (! strcmp(FPU_reg[i + 64].name, "(bad)"))
//			yad_float[i / 8] |= (1 << (i % 8));
}

void compile_3dnow(void)
{
	int i;
	bzero(yad_3dnow, 32);
	for (i = 0; i < 256; i++)
		if (Cmd3DNow[i] == NULL)
			yad_3dnow[i / 8] |= (1 << (i % 8));
}

void verbose_flags(uint16_t flag)
{
	if (flag & (C_GROUP|C_PREGRP))
		return;
#define	F(x)	if (flag & x) { fprintf(stderr,#x); fprintf(stderr, " "); }
	F(C_DATA1);
	F(C_DATA2);		
	F(C_DATA66);
	F(C_ADDR1);
	F(C_ADDR67);
	F(C_MODRM);		
	F(C_REL);		
	F(C_STOP);
}

void merge_and_dump_tables(void)
{
	int i, j;
	uint8_t	out[2048];

#ifdef	PACK6
	uint16_t *values = (uint16_t*)(out + last*3/4);
	int mi = 0, ms = last*3/4;
#else
	uint16_t *values = (uint16_t*)(out + last);
	int mi = 0, ms = last;
#endif
	bzero(out, 2048);
	for (i = 0; i < last; i++) {
		int index = -1;
		for (j = 0; j < mi; j++)
			if (values[j] == table[i]) {
				index = j;
				break;
			}
		if (index == -1) {
			values[mi] = table[i];
			index = mi++;
		}
#ifdef	PACK6
		int n = i*3/4;
		if (index > 63)
			fprintf(stderr, "index too large!\n");
		switch (i & 3) {
			case 0: out[n]	|= index << 2;
				break;
			case 1: out[n]	|= index >> 4;
				out[n+1]|= index << 4;
				break;
			case 2:	out[n]	|= index >> 2;
				out[n+1]|= index << 6;
				break;
			case 3:	out[n]	|= index;
				break;
		}
#else
		out[i] = index;
#endif
	}
	fprintf(stderr, "Number of different values %d\n", mi);
	for (i = 0; i < mi; i++) {
		fprintf(stderr, "%-3d %04x ", i, values[i]);
		verbose_flags(values[i]);
		fprintf(stderr, "\n");
	}
	fprintf(stderr, "FPU reg table:\n");
	for (i = 0; i < sizeof(yad_float); i++)
		fprintf(stderr, "%02x%c", yad_float[i], i % 8 == 7 ? '\n' : ' ');
		
	fprintf(stderr, "3D Now table:\n");
	for (i = 0; i < sizeof(yad_3dnow); i++)
		fprintf(stderr, "%02x%c", yad_3dnow[i], i % 8 == 7 ? '\n' : ' ');
		
	memcpy(&values[mi], yad_float, sizeof(yad_float));
	printf("#ifndef\tYAD_DATA_H\n#define\tYAD_DATA_H\n");
#ifdef	PACK6
	printf("#define\tYAD_PACK6\n");
#endif
	printf("#define\tYAD_VALUES_OFFSET\t%d\n", ms);
	printf("#define\tYAD_FLOAT_OFFSET\t%d\n", ms + mi * 2);
	ms = ms + mi * 2 + sizeof(yad_float);
	printf("#define\tYAD_3DNOW_OFFSET\t%d\n", ms);
	memcpy(out + ms, yad_3dnow, sizeof(yad_3dnow));
	ms += sizeof(yad_3dnow);
	printf("uint8_t yad_data[%d] = {\n", ms);
	for (i = 0; i < ms; i++) {
		printf("0x%02x%c ", out[i], i == ms - 1 ? ' ' : ',');
		if (i % 16 == 15)
			putchar('\n');
	}
	printf("\n};\n");
	printf("#endif\t/*YAD_DATA_H*/\n");
}

void dump_debug(void)
{
	int i, j;
	fprintf(stderr, "Number of table entries %d\n", last);
	fprintf(stderr, "Idx Flag  Code Description\n");
	for (i = 0; i < last; i++) {
		fprintf(stderr, "%-3d %04x", i, table[i]);
		if (i < 512) {
			if (i < 256)
				fprintf(stderr, "    %02x ", i);
			else
				fprintf(stderr, " 0f %02x ", i - 256);
			if ((main_table[i].op1 & (PRE|GRP)) == 0 && table[i] != C_ERROR)
				fprintf(stderr, "%s ", main_table[i].name);
			if ((main_table[i].op1 & (PRE|GRP)) != 0 && table[i] != C_ERROR)
				for (j = 0; j < (main_table[i].op1 & PRE ? 4 : 8); j++)
					fprintf(stderr, "%s ", ((opcode_t*)main_table[i].name)[j].name);
		} else
			fprintf(stderr, "       ");
		if (table[i] == C_ERROR) {
			fprintf(stderr, "C_ERROR\n");
			continue;
		}
		if (table[i] & C_GROUP) {
			fprintf(stderr, "grp %-3d\n", table[i] & YAD_GROUP_MASK);
			continue;
		}
		if (table[i] & C_PREGRP) {
			fprintf(stderr, "pre %-3d\n", table[i] & YAD_GROUP_MASK);
			continue;
		}
		verbose_flags(table[i]);
		fprintf(stderr, "\n");
	}
}

int main(int argc, char **argv)
{
	compile_table();
	compile_float();
	compile_3dnow();
	dump_debug();
	merge_and_dump_tables();
	return 0;
}
