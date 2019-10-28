#ifndef	YAD_H
#define	YAD_H

#include <stdint.h>

#define C_DATA1		0x0001
#define C_DATA2		0x0002
#define C_DATA66	0x0004
#define C_ADDR1		0x0008
#define C_ADDR67	0x0010
#define C_MODRM		0x0020
#define C_SIB		0x0040
#define C_BAD		0x0080
#define C_REL		0x0100
#define C_STOP		0x0200
#define	C_PREGRP	0x4000
#define	C_GROUP		0x8000
#define C_ERROR		0xffff

#define	YAD_GROUP_MASK	0x3fff

typedef struct {
	uint32_t	flags;
	uint8_t		len;
	uint8_t		p_seg;
	uint8_t		p_lock;
	uint8_t		p_rep;
	uint8_t		p_67;
	uint8_t		p_66;
	uint8_t		opcode;
	uint8_t		opcode2;
	uint8_t		modrm;
	uint8_t		sib;
	uint8_t		addrsize;
	uint8_t		datasize;
	union {
		uint8_t		data1;
		uint16_t	data2;
		uint32_t	data4;
	};
	union {
		uint8_t		addr1;
		uint16_t	addr2;
		uint32_t	addr4;
	};
} yad_t;

#endif	/* YAD_H */
