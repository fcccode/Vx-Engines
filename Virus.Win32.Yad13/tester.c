#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/mman.h>
#include <elf.h>
#include "yad.c"

int main(int argc, char **argv)
{
	int h = open(argv[1], 0);
	if (h < 0)
		perror("");
	int l = lseek(h, 0, 2);
	uint8_t *m = mmap(NULL, l, PROT_READ, MAP_SHARED, h, 0);
	Elf32_Ehdr *ehdr = (Elf32_Ehdr*)m;
	Elf32_Shdr *shdr = (Elf32_Shdr*)(m + ehdr->e_shoff);
	int i;
	char *strtab = m + shdr[ehdr->e_shstrndx].sh_offset;
	for (i = 1; i < ehdr->e_shnum; i++)
		if (! strcmp(strtab + shdr[i].sh_name, ".text")) {
			uint32_t start = shdr[i].sh_offset;
			for (;;) {
				yad_t y;
				int il;
				if ((il = yad(m + start, &y)) == 0) {
					printf("Invalid instruction at %08x (%08x)\n", start + shdr[i].sh_addr - shdr[i].sh_offset, start);
					exit(0);
				}
				int j, al = il;
				printf(" %07x:\t", start + shdr[i].sh_addr - shdr[i].sh_offset);
				for (j = 0; j < il; j++) {
					if (j == 7) {
						printf("\n %07x:\t", start + shdr[i].sh_addr - shdr[i].sh_offset + j);
						al = il - 7;
					}
					printf("%02x ", *(m + start + j));
				}
				for (j = 12; j > al; j--)
					printf("   ");
				
				printf("l=%d, op=%02x, ", il, y.opcode);
				if (y.flags & C_MODRM)
					printf("modrm: %02x, ", y.modrm);
				if (y.flags & C_SIB)
					printf("sib: %02x, ", y.sib);
				if (y.addrsize) {
					printf("addr%d: ", y.addrsize);
					for (j = 0; j < y.addrsize; j++)
						printf("%02x ", *(&y.addr1 + j));
				}
				if (y.datasize) {
					printf("data%d: ", y.datasize);
					for (j = 0; j < y.datasize; j++)
						printf("%02x ", *(&y.data1 + j));
				}
				putchar('\n');
				if (y.flags & C_BAD) {
					if (*(uint16_t*)(m + start) == 0x0000 || *(uint16_t*)(m + start) == 0xffff)
						il = 2;
					else {
						fprintf(stderr, "Bad instruction!\n");
						return 2;
					}
				}
				start += il;
				if ((start - shdr[i].sh_offset) >= shdr[i].sh_size)
					break;
			}
			break;
		}
	return 0;
}
