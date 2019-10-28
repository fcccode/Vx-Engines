
////////x///////x///////x///////x///////x///////x///////x///////x///////x////

#ifndef __PE_HPP__
#define __PE_HPP__

#ifdef __GNUC__
#pragma pack(push, 1)
#else
#pragma pack(push)
#pragma pack(1)
#endif /* __GNUC__ */

typedef struct PE_STRUCT
{
uint32_t   pe_id;                  // 00 01 02 03
uint16_t   pe_cputype;             // 04 05
uint16_t   pe_numofobjects;        // 06 07
uint32_t   pe_datetime;            // 08 09 0A 0B
uint32_t   pe_coffptr;             // 0C 0D 0E 0F
uint32_t   pe_coffsize;            // 10 11 12 13
uint16_t   pe_ntheadersize;        // 14 15
uint16_t   pe_flags;               // 16 17
        // NT_Header {
uint16_t   pe_magic;               // 18 19
uint8_t    pe_linkmajor;           // 1A
uint8_t    pe_linkminor;           // 1B
uint32_t   pe_sizeofcode;          // 1C 1D 1E 1F
uint32_t   pe_sizeofidata;         // 20 21 22 23
uint32_t   pe_sizeofudata;         // 24 25 26 27
uint32_t   pe_entrypointrva;       // 28 29 2A 2B
uint32_t   pe_baseofcode;          // 2C 2D 2E 2F
uint32_t   pe_baseofdata;          // 30 31 32 33
uint32_t   pe_imagebase;           // 34 35 36 37
uint32_t   pe_objectalign;         // 38 39 3A 3B
uint32_t   pe_filealign;           // 3C 3D 3E 3F
uint16_t   pe_osmajor;             // 40 41
uint16_t   pe_osminor;             // 42 43
uint16_t   pe_usermajor;           // 44 45
uint16_t   pe_userminor;           // 46 47
uint16_t   pe_subsysmajor;         // 48 49
uint16_t   pe_subsysminor;         // 4A 4B
uint32_t   pe_reserved;            // 4C 4D 4E 4F
uint32_t   pe_imagesize;           // 50 51 52 53
uint32_t   pe_headersize;          // 54 55 56 56
uint32_t   pe_checksum;            // 58 59 5A 5B
uint16_t   pe_subsystem;           // 5C 5D
uint16_t   pe_dllflags;            // 5E 5F
uint32_t   pe_stackreserve;        // 60 61 62 63
uint32_t   pe_stackcommit;         // 64 65 66 67
uint32_t   pe_heapreserve;         // 68 69 6A 6B
uint32_t   pe_heapcommit;          // 6C 6D 6E 6F
uint32_t   pe_loaderflags;         // 70 71 72 73
uint32_t   pe_numofrvaandsizes;    // 74 75 76 77
        // rva and sizes
uint32_t   pe_exportrva;           // 78 79 7A 7B
uint32_t   pe_exportsize;          // 7C 7D 7E 7F
uint32_t   pe_importrva;           // 80 81 82 83
uint32_t   pe_importsize;          // 84 85 86 87
uint32_t   pe_resourcerva;         // 88 89 8A 8B
uint32_t   pe_resourcesize;        // 8C 8D 8E 8F
uint32_t   pe_exceptionrva;        // 90 91 92 93
uint32_t   pe_exceptionsize;       // 94 95 96 97
uint32_t   pe_securityrva;         // 98 99 9A 9B
uint32_t   pe_securitysize;        // 9C 9D 9E 9F
uint32_t   pe_fixuprva;            // A0 A1 A2 A3
uint32_t   pe_fixupsize;           // A4 A5 A6 A7
uint32_t   pe_debugrva;            // A8 A9 AA AB
uint32_t   pe_debugsize;           // AC AD AE AF
uint32_t   pe_descriptionrva;      // B0 B1 B2 B3
uint32_t   pe_descriptionsize;     // B4 B5 B6 B7
uint32_t   pe_machinerva;          // B8 B9 BA BB
uint32_t   pe_machinesize;         // BC BD BE BF
uint32_t   pe_tlsrva;              // C0 C1 C2 C3
uint32_t   pe_tlssize;             // C4 C5 C6 C7
uint32_t   pe_loadconfigrva;       // C8 C9 CA CB
uint32_t   pe_loadconfigsize;      // CC CD CE CF
uint8_t    pe_reserved_1[8];       // D0 D1 D2 D3  D4 D5 D6 D7
uint32_t   pe_iatrva;              // D8 D9 DA DB
uint32_t   pe_iatsize;             // DC DD DE DF
uint8_t    pe_reserved_2[8];       // E0 E1 E2 E3  E4 E5 E6 E7
uint8_t    pe_reserved_3[8];       // E8 E9 EA EB  EC ED EE EF
uint8_t    pe_reserved_4[8];       // F0 F1 F2 F3  F4 F5 F6 F7
// ---- total size == 0xF8 ---------
} PE_HEADER;

typedef struct PE_OBJENTRY_STRUCT
{
uint8_t    oe_name[8];             // 00 01 02 03  04 05 06 07
uint32_t   oe_virtsize;            // 08 09 0A 0B
uint32_t   oe_virtrva;             // 0C 0D 0E 0F
uint32_t   oe_physsize;            // 10 11 12 13
uint32_t   oe_physoffs;            // 14 15 16 17
uint8_t    oe_reserved[0x0C];      // 18 19 1A 1B   1C 1D 1E 1F  20 21 22 23
uint32_t   oe_objectflags;         // 24 25 26 27
// ---- total size == 0x28 ---------
} PE_OBJENTRY;

typedef struct PE_EXPORT_STRUCT
{
uint32_t   ex_flags;               // 00 01 02 03
uint32_t   ex_datetime;            // 04 05 06 07
uint16_t   ex_major_ver;           // 08 09
uint16_t   ex_minor_ver;           // 0A 0B
uint32_t   ex_namerva;             // 0C 0D 0E 0F
uint32_t   ex_ordinalbase;         // 10 11 12 13
uint32_t   ex_numoffunctions;      // 14 15 16 17
uint32_t   ex_numofnamepointers;   // 18 19 1A 1B
uint32_t   ex_addresstablerva;     // 1C 1D 1E 1F
uint32_t   ex_namepointersrva;     // 20 21 22 23
uint32_t   ex_ordinaltablerva;     // 24 25 26 27
// ---- total size == 0x28 ---------
} PE_EXPORT;

typedef struct PE_IMPORT_STRUCT
{
uint32_t   im_lookup;              // 00
uint32_t   im_datetime;            // 04  ?
uint32_t   im_forward;             // 08  -1
uint32_t   im_name;                // 0C
uint32_t   im_addresstable;        // 10
// ---- total size == 0x14 ---------
} PE_IMPORT;

typedef struct PE_FIXUP_STRUCT
{
uint32_t   fx_pagerva;             // 00 01 02 03
uint32_t   fx_blocksize;           // 04 05 06 07
uint16_t   fx_typeoffs[];          // 08 09 .. ..
} PE_FIXUP;

#pragma pack(pop)

#define PE_ID 0x4550

#endif // __PE_HPP__

////////x///////x///////x///////x///////x///////x///////x///////x///////x////
