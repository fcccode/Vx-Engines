
mz_struc                struc
mz_id                   dw      ?               ; MZ/ZM
mz_last512              dw      ?
mz_num512               dw      ?
mz_relnum               dw      ?
mz_hdrsize              dw      ?               ; in PAR
mz_minmem               dw      ?
mz_maxmem               dw      ?
mz_ss                   dw      ?
mz_sp                   dw      ?
mz_csum                 dw      ?               ; 0
mz_ip                   dw      ?
mz_cs                   dw      ?
mz_relptr               dw      ?
mz_ovrnum               dw      ?               ; 0
                        db      32 dup (?)
mz_neptr                dd      ?
                        ends
