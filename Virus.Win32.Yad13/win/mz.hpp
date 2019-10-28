
////////x///////x///////x///////x///////x///////x///////x///////x///////x////

#ifndef __MZ_HPP__
#define __MZ_HPP__

#ifdef __GNUC__
#pragma pack(push, 1)
#else
#pragma pack(push)
#pragma pack(1)
#endif /* __GNUC__ */

typedef struct MZ_STRUCT
{
uint16_t    mz_id;
uint16_t    mz_last512;
uint16_t    mz_num512;
uint16_t    mz_relnum;
uint16_t    mz_headersize;
uint16_t    mz_minmem;
uint16_t    mz_maxmem;
uint16_t    mz_ss;
uint16_t    mz_sp;
uint16_t    mz_checksum;
uint16_t    mz_ip;
uint16_t    mz_cs;
uint16_t    mz_relofs;
uint16_t    mz_ovrnum;
uint8_t     mz_reserved[32];
uint32_t    mz_neptr;
} MZ_HEADER;

#pragma pack(pop)

#define MZ_ID 0x5a4d

#endif // __MZ_HPP__

////////x///////x///////x///////x///////x///////x///////x///////x///////x////
