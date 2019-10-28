
pe_struc                struc
pe_id                   dd      ?       ; 00 01 02 03  pe00
pe_cputype              dw      ?       ; 04 05        14c..14e: i386..i586
pe_numofobjects         dw      ?       ; 06 07
pe_datetime             dd      ?       ; 08 09 0a 0b  date/time
pe_cofftableptr         dd      ?       ; 0c 0d 0e 0f
pe_cofftablesize        dd      ?       ; 10 11 12 13
pe_ntheadersize         dw      ?       ; 14 15
pe_exeflags             dw      ?       ; 16 17
                        ; ntheader
pe_ntheader_id          dw      ?       ; 18 19
pe_linkmajor            db      ?       ; 19
pe_linkminor            db      ?       ; 1a
pe_sizeofcode           dd      ?       ; 1c 1d 1e 1f
pe_sizeofinitdata       dd      ?       ; 20 21 22 23
pe_sizeofuninitdata     dd      ?       ; 24 25 26 27
pe_entrypointrva        dd      ?       ; 28 29 2a 2b
pe_baseofcoderva        dd      ?       ; 2c 2d 2e 2f
pe_baseofdatarva        dd      ?       ; 30 31 32 33
pe_imagebase            dd      ?       ; 34 35 36 37    align: 64k
pe_objectalign          dd      ?       ; 39 30 3a 3b  256n > power2 > 512
pe_filealign            dd      ?       ; 3c 3d 3e 3f   64k > power2 > 512
pe_osmajor              dw      ?       ; 40 41
pe_osminor              dw      ?       ; 42 43
pe_usermajor            dw      ?       ; 44 45
pe_userminor            dw      ?       ; 46 47
pe_subsysmajor          dw      ?       ; 48 49
pe_subsysminor          dw      ?       ; 4a 4b
                        dd      ?       ; 4c 4d 4e 4f
pe_imagesize            dd      ?       ; 50 51 52 53  align: objectalign
pe_headersize           dd      ?       ; 54 55 56 57  dosh+peh+objecttable
pe_checksum             dd      ?       ; 58 59 5a 5b  0
pe_subsystem            dw      ?       ; 5c 5d
pe_dllflags             dw      ?       ; 5e 5f
pe_stackreservesize     dd      ?       ; 60 61 62 63
pe_stackcommitsize      dd      ?       ; 64 65 66 67
pe_heapreservesize      dd      ?       ; 68 69 6a 6b
pe_heapcommitsize       dd      ?       ; 6c 6d 6e 6f
pe_loaderflags          dd      ?       ; 70 71 72 73
pe_numofrvaandsizes     dd      ?       ; 74 75 76 77   =10h
                        ; rva/sizes
pe_rvasizes             label   dword
pe_exporttablerva       dd      ?       ; 78 79 7a 7b
pe_exporttablesize      dd      ?       ; 7c 7d 7e 7f
pe_importtablerva       dd      ?       ; 80 81 82 83
pe_importtablesize      dd      ?       ; 84 85 86 87
pe_resourcetablerva     dd      ?       ; 88 89 8a 8b
pe_resourcetablesize    dd      ?       ; 8c 8d 8e 8f
pe_exceptiontablerva    dd      ?       ; 90 91 92 93
pe_exceptiontablesize   dd      ?       ; 94 95 96 97
pe_securitytablerva     dd      ?       ; 98 99 9a 9b
pe_securitytablesize    dd      ?       ; 9c 9d 9e 9f
pe_fixuptablerva        dd      ?       ; a0 a1 a2 a3
pe_fixuptablesize       dd      ?       ; a4 a5 a6 a7
pe_debugtablerva        dd      ?       ; a8 a9 aa ab
pe_debugtablesize       dd      ?       ; ac ad ae af
pe_imgdescrrva          dd      ?       ; b0 b1 b2 b3
pe_imgdescrsize         dd      ?       ; b4 b5 b6 b7
pe_machinerva           dd      ?       ; b8 b9 ba bb
pe_machinesize          dd      ?       ; bc bd be bf
pe_tlsrva               dd      ?       ; c0 c1 c2 c3
pe_tlssize              dd      ?       ; c4 c5 c6 c7
pe_loadcfgrva           dd      ?       ; c8 c9 ca cb
pe_loadcfgsize          dd      ?       ; cc cd ce cf
                        dq      ?       ; d0 d1 d2 d3 d4 d5 d6 d7
pe_iattablerva          dd      ?       ; d8 d9 da db
pe_iattablesize         dd      ?       ; dc dd de df
                        dq      ?       ; e0 e1 e2 e3 d4 e5 e6 e7
                        dq      ?       ; e8 e9 ea eb ec ed ee ef
                        dq      ?       ; f0 f1 f2 f3 f4 f5 f6 f7
                        ends

oe_struc                struc
oe_section_name         db      8 dup (?);00 01 02 03 04 05 06 07
oe_virt_size            dd      ?       ; 08 09 0a 0b
oe_virt_rva             dd      ?       ; 0c 0d 0e 0f  align: objectalign
oe_phys_size            dd      ?       ; 10 11 12 13
oe_phys_offs            dd      ?       ; 14 15 16 17  align: filealign
                        db      12 dup (?);for obj file
oe_flags                dd      ?        ; 24 25 26 27
                        ends
