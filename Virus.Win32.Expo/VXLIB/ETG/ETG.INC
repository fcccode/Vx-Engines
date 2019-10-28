
; ---------------------------------------------------------------------------
; Executable Trash Generator (ETG) Engine
; version 1.00
; (x) 2000 Z0MBiE, z0mbie.cjb.net
; ---------------------------------------------------------------------------

                        locals  __

ETG_MOVRR               equ     00000000000000000000000000000001b
ETG_MOVRC               equ     00000000000000000000000000000010b
ETG_MOVSXZX             equ     00000000000000000000000000000100b
ETG_XCHG                equ     00000000000000000000000000001000b
ETG_LEA                 equ     00000000000000000000000000010000b
ETG_TTTRR               equ     00000000000000000000000000100000b
ETG_TTTRC               equ     00000000000000000000000001000000b
ETG_INCDEC              equ     00000000000000000000000010000000b
ETG_NOTNEG              equ     00000000000000000000000100000000b
ETG_TESTRR              equ     00000000000000000000001000000000b
ETG_TESTRC              equ     00000000000000000000010000000000b
ETG_IMUL                equ     00000000000000000000100000000000b
ETG_SHIFT               equ     00000000000000000001000000000000b
ETG_SHxD                equ     00000000000000000010000000000000b
ETG_BSWAP               equ     00000000000000000100000000000000b
ETG_XADD                equ     00000000000000001000000000000000b
ETG_BSx                 equ     00000000000000010000000000000000b
ETG_BTx                 equ     00000000000000100000000000000000b
ETG_JMPS                equ     00000000000001000000000000000000b
ETG_SEG                 equ     00000000000010000000000000000000b
ETG_REP                 equ     00000000000100000000000000000000b
ETG_ALL                 equ     00000000000111111111111111111111b
ETG_DEFAULT             equ     ETG_TTTRC ; used if no cmds specified

REG_EAX                 equ     00000001h
REG_ECX                 equ     00000002h
REG_EDX                 equ     00000004h
REG_EBX                 equ     00000008h
REG_ESP                 equ     00000010h
REG_EBP                 equ     00000020h
REG_ESI                 equ     00000040h
REG_EDI                 equ     00000080h
REG_ALL                 equ     (not REG_ESP) and 255
REG_DEFAULT             equ     REG_EAX   ; used if no regs specified

etg_engine              proc    pascal

                        arg     cmdavail        ; ETG_xxx
                        arg     regsrcavail     ; REG_xxx
                        arg     regdstavail     ; REG_xxx
                        arg     osizeptr        ; ptr to generated bufsize
                        arg     ncmds           ; max number of commands
                        arg     bufsize         ; max size of buffer
                        arg     bufptr          ; ptr to output buffer
                        arg     rnd             ; external subroutine: rnd

                        local   w
                        local   wx3
                        local   src
                        local   dst
                        local   src2
                        local   dst2
                        local   srcx3
                        local   dstx3
                        local   r1x0
                        local   r1x1
                        local   r1x3
                        local   r2x3
                        local   r3x3
                        local   dst32
                        local   dst32x3
                        local   src32
                        local   src32x3
                        local   any
                        local   anyx3
                        local   any2

                        pusha

                        mov     edi, bufptr
                        cld

                        and     regsrcavail, REG_ALL
                        jnz     __1a
                        mov     regsrcavail, REG_DEFAULT
__1a:
                        and     regdstavail, REG_ALL
                        jnz     __1b
                        mov     regdstavail, REG_DEFAULT
__1b:
                        and     cmdavail, ETG_ALL
                        jnz     __2
                        mov     cmdavail, ETG_DEFAULT
__2:

__cycle:
                        mov     eax, edi        ; calc curr bufsize
                        sub     eax, bufptr

                        mov     ecx, osizeptr   ; store
                        mov     [ecx], eax

                        add     eax, 16         ; to avoid overflow
                        cmp     eax, bufsize    ; check max size
                        jae     __cycle_exit
                        dec     ncmds           ; check # of cmds
                        jl      __cycle_exit

                        call    __gen1          ; generate one command

                        jmp     __cycle
__cycle_exit:

                        popa
                        ret

__gen1:                 mov     w, 1
                        mov     wx3, 1 shl 3

                        call    __getregdst_avail
                        mov     dst32, eax
                        shl     eax, 3
                        mov     dst32x3, eax

                        call    __getregsrc_avail
                        mov     src32, eax
                        shl     eax, 3
                        mov     src32x3, eax

                        mov     eax, regdstavail
                        and     eax, regsrcavail
                        test    eax, REG_EAX+REG_EBX+REG_ECX+REG_EDX
                        jz      __32only

                        push    2
                        call    rnd
                        pop     ecx
                        mov     w, eax
                        shl     eax, 3
                        mov     wx3, eax

__32only:

                        push    2
                        call    rnd
                        pop     ecx
                        mov     r1x0, eax
                        shl     eax, 1
                        mov     r1x1, eax
                        shl     eax, 3-1
                        mov     r1x3, eax

                        push    4
                        call    rnd
                        pop     ecx
                        shl     eax, 3
                        mov     r2x3, eax

                        call    __getrnd8
                        shl     eax, 3
                        mov     r3x3, eax

                        call    __getregsrc_avail
                        mov     src, eax
                        shl     eax, 3
                        mov     srcx3, eax
                        call    __getregsrc_avail
                        mov     src2, eax

                        call    __getregdst_avail
                        mov     dst, eax
                        shl     eax, 3
                        mov     dstx3, eax
                        call    __getregdst_avail
                        mov     dst2, eax

                        call    __getregany_avail
                        mov     any, eax
                        shl     eax, 3
                        mov     anyx3, eax
                        call    __getregany_avail
                        mov     any2, eax

__gen1_recycle:         push    31
                        call    rnd
                        pop     ecx
                        xchg    esi, eax
                        inc     esi

                        mov     edx, cmdavail
                        mov     eax, w

dxx                     macro   x
                        ifnb    <x>
                        dec     esi
                        jz      x
                        endif
                        endm

cxx                     macro   a1,a2,a3,a4,a5,a6,a7,a8,a9
                        local   t
                        shr     edx, 1
                        jnc     t
                        dxx     a1
                        dxx     a2
                        dxx     a3
                        dxx     a4
                        dxx     a5
                        dxx     a6
                        dxx     a7
                        dxx     a8
                        dxx     a9
t:                      endm

                        cxx     __a00,__a01 ;ETG_MOVRR
                        cxx     __a02,__a03 ;ETG_MOVRC
                        cxx     __a04       ;ETG_MOVSXZX
                        cxx     __a06       ;ETG_XCHG
                        cxx     __a07       ;ETG_LEA
                        cxx     __a08,__a09 ;ETG_TTTRR
                        cxx     __a10,__a11 ;ETG_TTTRC
                        cxx     __a12,__a13 ;ETG_INCDEC
                        cxx     __a14       ;ETG_NOTNEG
                        cxx     __a17       ;ETG_TESTRR
                        cxx     __a18       ;ETG_TESTRC
                        cxx     __a19,__a20 ;ETG_IMUL
                        cxx     __a21,__a22 ;ETG_SHIFT
                        cxx     __a23,__a24 ;ETG_SHxD
                        cxx     __a25       ;ETG_BSWAP
                        cxx     __a26       ;ETG_XADD
                        cxx     __a27       ;ETG_BSx
                        cxx     __a28,__a29 ;ETG_BTx
                        cxx     __a30       ;ETG_JMPS
                        cxx     __a31,__a32 ;ETG_SEG
                        cxx     __a33       ;ETG_REP

                        jmp     __gen1_recycle

__a00:                  or      al, 88h
                        stosb
__11sd_retn:            mov     al, 0C0h
                        or      eax, srcx3
__c3:                   or      eax, dst
                        stosb
                        retn

__a01:                  or      al, 8Ah
                        stosb
__11ds_retn:            mov     al, 0C0h
                        or      eax, dstx3
__c2:                   or      eax, src
                        stosb
                        retn

__a02:                  mov     al, 0B0h
                        or      eax, wx3
__c1:                   or      eax, dst
                        stosb
                        jmp     __dataw_retn


__a03:                  or      al, 0C6h
                        stosb
                        mov     al, 11000000b
                        jmp     __c1

__a04:                  mov     al, 0Fh
                        stosb
                        mov     al, 10110110b
                        or      eax, w
                        or      eax, r1x3
                        stosb
__11d32s_retn:          mov     al, 11000000b
                        or      eax, dst32x3
                        jmp     __c2

__a05:                  or      al, 10000110b
                        stosb
__11dd_retn:            mov     al, 11000000b
                        or      eax, dstx3
                        or      eax, dst2
                        stosb
                        retn

__a06:                  or      al, 10000110b
                        stosb
                        jmp     __11dd_retn

__a07:                  mov     al, 8Dh
                        stosb
                        mov     al, 05h
                        or      eax, dst32x3
                        stosb
                        jmp     __dword_retn

__a08:                  or      al, 00000000b
                        or      eax, r3x3
                        stosb
                        jmp     __11sd_retn

__a09:                  or      al, 00000010b
                        or      eax, r3x3
                        stosb
                        jmp     __11ds_retn

__a10:                  or      al, 10000000b
                        stosb
                        mov     al, 11000000b
                        or      eax, r3x3
                        or      eax, dst
                        stosb
                        jmp     __dataw_retn

__a11:                  test    regdstavail, REG_EAX
                        jz      __gen1_recycle
                        or      al, 00000100b
                        or      eax, r3x3
                        stosb
                        jmp     __dataw_retn

__a12:                  or      al, 11111110b
                        stosb
                        mov     al, 11000000b
                        or      eax, r1x3
                        jmp     __c3

__a13:                  mov     al, 01000000b
                        or      eax, r1x3
                        or      eax, dst32
                        stosb
                        retn

__a14:                  or      al, 11110110b
                        stosb
                        mov     al, 11010000b
                        or      eax, r1x3
                        jmp     __c3

;__a15:                 or      al, 00111000b
;                       stosb
;                       jmp     __11xx_retn
;
;__a16:                 or      al, 10000000b
;                       stosb
;                       mov     al, 11111000b
;                       or      eax, any
;                       stosb
;                       jmp     __dataw_retn

__a17:                  or      al, 10000100b
                        stosb
__11xx_retn:            mov     al, 11000000b
                        or      eax, anyx3
                        or      eax, any2
                        stosb
                        retn

__a18:                  or      al, 11110110b
                        stosb
                        mov     al, 11000000b
                        or      eax, any
                        stosb
                        jmp     __dataw_retn

__a19:                  mov     al, 00001111b
                        stosb
                        mov     al, 10101111b
                        stosb
__11d32s32_retn:        mov     al, 11000000b
                        or      eax, dst32x3
                        or      eax, src32
                        stosb
                        retn

__a20:                  mov     al, 69h
                        stosb
                        call    __11d32s32_retn
                        jmp     __dword_retn

__a21:                  or      al, 11010000b
                        or      eax, r1x1
                        stosb
                        mov     al, 11000000b
                        or      eax, r3x3
                        or      eax, dst
                        stosb
                        retn

__a22:                  or      al, 11000000b
                        stosb
                        mov     al, 11000000b
                        or      eax, r3x3
                        or      eax, dst
                        stosb
                        jmp     __byte_retn

__a23:                  mov     al, 00001111b
                        stosb
                        mov     al, 10100100b
                        or      eax, r1x3
                        stosb
                        mov     al, 11000000b
                        call    __11s32d32_retn
                        jmp     __byte_retn

__11s32d32_retn:        mov     al, 11000000b
                        or      eax, src32x3
__c4:                   or      eax, dst32
                        stosb
                        retn

__a24:                  test    regsrcavail, REG_ECX
                        jz      __gen1_recycle
                        mov     al, 00001111b
                        stosb
                        mov     al, 10100101b
                        or      eax, r1x3
                        stosb
                        jmp     __11s32d32_retn

__a25:                  mov     al, 00001111b
                        stosb
                        mov     al, 11001000b
                        jmp     __c4

__a26:                  mov     al, 00001111b
                        stosb
                        mov     al, 11000000b
                        or      eax, w
                        stosb
                        jmp     __11dd_retn

__a27:                  mov     al, 00001111b
                        stosb
                        mov     al, 10111100b
                        or      eax, r1x0      ; r1x0
                        stosb
                        jmp     __11d32s32_retn

__a28:                  mov     al, 00001111b
                        stosb
                        mov     al, 10111010b
                        stosb
                        mov     al, 11100000b
                        or      eax, r2x3
                        or      eax, dst32
                        stosb
                        jmp     __byte_retn

__a29:                  mov     al, 00001111b
                        stosb
                        mov     al, 10100011b
                        or      eax, r2x3
                        stosb
                        jmp     __11s32d32_retn

__a30:                  mov     ax, 01EBh
                        stosw
                        push    256
                        call    rnd
                        pop     ecx
                        stosb
                        retn

__a31:                  mov     al, 00100110b
                        or      eax, r2x3
                        stosb
                        retn

__a32:                  mov     al, 64h
                        or      eax, r1x0
                        stosb
                        retn

__a33:                  mov     al, 0F2h
                        or      eax, r1x0
                        stosb
                        retn

__dataw_retn:           cmp     w, 0
                        je      __byte_retn
__dword_retn:           call    __word_retn
__word_retn:            call    __byte_retn
__byte_retn:            push    256
                        call    rnd
                        pop     ecx
                        stosb
                        retn

__getrnd8:              push    8
                        call    rnd
                        pop     ecx
                        retn

__getregsrc_avail:      mov     edx, regsrcavail
                        jmp     __getreg_avail
__getregdst_avail:      mov     edx, regdstavail
                        jmp     __getreg_avail
__getregany_avail:      mov     edx, regsrcavail
                        or      edx, regdstavail
                        jmp     __getreg_avail

__getreg_avail:         call    __getrnd8       ; get random available reg.
                        mov     ecx, eax
                        cmp     w, 0            ; w==0, 16bit?
                        jnz     __32
                        and     ecx, 3          ; 16bit# --> 32bit#
__32:                   bt      edx, ecx
                        jnc     __getreg_avail
                        retn

etg_engine              endp
