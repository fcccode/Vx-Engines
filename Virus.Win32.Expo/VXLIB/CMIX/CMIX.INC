
; ---------------------------------------------------------------------------
; CODE MIXER      version 1.50         (x) 2000 Z0MBiE, http://z0mbie.cjb.net
; ---------------------------------------------------------------------------

CM_ERR_SUCCESS          equ     0       ; success
CM_ERR_DISASM           equ     1       ; error disassembling instruction
CM_ERR_NOMEMORY         equ     2    ; not ebough memory in the output buffer
CM_ERR_TOOMANYCMDS      equ     3       ; too many commands (maxcmd reached)

 ; input:  pushed on the stack, see params
 ; output: exitcode in EAX, CM_ERR_xxx

codemixer               proc    pascal

                        arg     _maxcmd          ; max # of commands
                        arg     _buf3sizeptr     ; ptr to output _buffer size
                        arg     _buf3size        ; output _buffer max size
                        arg     _buf3            ; output _buffer ptr
                        arg     _buf2size        ; _buf#2 size
                        arg     _buf2            ; _buf#2 offset
                        arg     _buf1size        ; _buf#1 size
                        arg     _buf1            ; _buf#1 offset
                        arg     _rnd             ; routine: _rnd()
                        arg     _disasm          ; routine: _disasm()

                        local   _max             ; # of links
                        local   _oldptr          ; array of old offsets
                        local   _newptr          ; array of new offsets

                        pusha
                        cld

                        mov     ecx, _maxcmd
                        push    ecx             ; allocate memory
                        loop    $-1
                        mov     _oldptr, esp

                        mov     ecx, _maxcmd
                        push    ecx             ; allocate memory
                        loop    $-1
                        mov     _newptr, esp

                        mov     _max, ecx       ; empty links array

 ; process

__cycle1:               xor     eax, eax        ; no space in output _buffer?
                        cmp     _buf3size, eax
                        jz      __err_nomem

                        mov     eax, _buf1size   ; EAX+EBX=summary input size
                        mov     ebx, _buf2size

                        lea     ecx, [eax+ebx]  ; both==0 -- break
                        jecxz   __cycle1exit

                        or      eax, eax        ; _buf#1 empty? -- use #2
                        jz      __use2
                        or      ebx, ebx        ; _buf#2 empty? -- use #1
                        jz      __use1

__usernd:               push    ecx             ; EAX=_rnd(size1+size2)
                        call    _rnd
                        pop     ecx

                        cmp     eax, _buf1size   ; 1st _buffer or 2nd one ?
                        jae     __use2

__use1:                 lea     esi, _buf1       ; use 1st input _buffer
                        lea     edi, _buf1size
                        jmp     __use

__use2:                 lea     esi, _buf2       ; use 2nd input _bufer
                        lea     edi, _buf2size

__use:                  push    dword ptr [esi] ; disassemble opcode (EAX=len)
                        call    _disasm
                        pop     ecx

                        mov     ecx, eax        ; ECX=len

                        inc     eax            ; check if error disassembling
                        jz      __err_dis
                        dec     eax

                        pusha                   ; copy opcode to out_buffer

                        mov     esi, [esi]      ; source addr
                        mov     edi, _buf3      ; dest addr

                        call    __addlink       ; add one entry


                        mov     eax, [esi]      ; get opcode

                        cmp     al, 0EBh        ; short jmp?
                        jne     __njj

                        mov     al, 0E9h        ; store near jmp
                        stosb
                        movsx   eax, ah
                        push    3
                        jmp     __xx

__njj:                  and     al, 0F0H        ; jxx short?
                        cmp     al, 70h
                        jnz     __nj

                        mov     al, 0Fh         ; store near jxx
                        stosb
                        mov     eax, [esi]
                        xor     al, 70h xor 80h ; 7x --> 8x
                        stosb
                        movsx   eax, ah

                        push    4               ; fix arg (-4), fix size(+4)
__xx:                   pop     ecx
                        sub     eax, ecx
                        stosd

                        add     dword ptr [esp+6*4], ecx  ; popa.ECX+=4

                        jmp     __ex

__nj:                   rep     movsb           ; copy opcode

__ex:                   popa

                        add     [esi], eax      ; _buf#i.offset += opcode_size
                        sub     [edi], eax      ; _buf#i.size   -= opcode_size

                        add     _buf3, ecx       ; _buf3.offset  += opcode_size
                        sub     _buf3size, ecx   ; _buf3.size    -= opcode_size

                        mov     eax, _buf3sizeptr; _buf3.real size += opc_size
                        jecxz   __skip
                        add     [eax], ecx
__skip:

                        mov     eax, [esi]      ; esi=ptr to curr bufptr
                        mov     eax, [eax]      ; get opcode

                        and     ah, 0F0h        ; jxx near?
                        cmp     ax, 800Fh
                        je      __use
                        and     al, 0F0h        ; jxx short?
                        cmp     al, 70h
                        je      __use

                        jmp     __cycle1        ; process next opcode
__cycle1exit:

 ; add 2 zero-length instructions to allow fixing jmps to the end of
 ; the source buffers.
 ; in other words, link [buf1.end--buf3.end] and [buf2.end--buf3.end]

                        mov     esi, _buf1
                        mov     edi, _buf3
                        call    __addlink
                        mov     esi, _buf2
                        call    __addlink

 ; link

                        xor     ebx, ebx
__cycle2:

                        mov     eax, _oldptr
                        mov     esi, [eax+ebx*4]
                        mov     eax, _newptr
                        mov     edi, [eax+ebx*4]

                        push    5    ; 5
                        pop     ecx

                        mov     eax, [edi]
                        and     al, 0FEh
                        cmp     al, 0E8h
                        je      __x4

                        inc     ecx  ; 6

                        mov     eax, [edi]
                        and     ah, 0F0h
                        cmp     ax, 800Fh
                        jne     __cycle2cont

__x4:
                        add     edi, ecx        ; newofs+len
                        add     esi, ecx        ; oldofs+len

                        mov     ecx, esi        ; ecx=oldofs+len
                        add     ecx, [edi-4]    ; ecx=label.oldofs

                        mov     eax, _oldptr
                        mov     edx, _max
__cycle3:               dec     edx
                        jle     __ext
                        cmp     [eax+edx*4], ecx
                        je      __int           ; edx=label.index
                        jmp     __cycle3

__ext:                  sub     esi, edi
                        add     [edi-4], esi    ; arg+=newofs-oldofs

                        jmp     __cycle2cont

__int:                  mov     eax, _newptr
                        mov     eax, [eax+edx*4]
                        sub     eax, edi
                        mov     [edi-4], eax  ; arg=label.newofs-(newofs+len)

__cycle2cont:           inc     ebx
                        cmp     ebx, _max
                        jb      __cycle2

 ; exit
                        mov     al, CM_ERR_SUCCESS

__exit:                 mov     ecx, _maxcmd    ; free memory
                        lea     esp, [esp+ecx*8]

                        movzx   eax, al         ; store exitcode
                        mov     [esp+7*4], eax

                        popa
                        ret

__err_dis:              mov     al, CM_ERR_DISASM
                        jmp     __exit

__err_nomem:            mov     al, CM_ERR_NOMEMORY
                        jmp     __exit

__err_toomanycmds:      pop     eax
                        popa
                        mov     al, CM_ERR_TOOMANYCMDS
                        jmp     __exit

__addlink:              mov     eax, _max
                        cmp     eax, _maxcmd
                        jae     __err_toomanycmds
                        inc     _max
                        mov     ebx, _oldptr
                        mov     [ebx+eax*4], esi
                        mov     ebx, _newptr
                        mov     [ebx+eax*4], edi
                        retn

codemixer               endp
