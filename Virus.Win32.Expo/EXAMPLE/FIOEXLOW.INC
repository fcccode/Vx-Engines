
; advanced FileIO library  4.xx  (c) 1998-2000 Z0MBiE

;  ***ALL FUNCTIONS***: if (CF==1) EAX=error code
;
; fopen    (EDX=fname) : EAX=handle
; fclose   (EBX=handle)
; fseek    (EBX=handle, EDX=newpos) : EAX=new pos
; fread    (EBX=handle, EDX=buffer, ECX=size) : EAX=bytesread
; fwrite   (EBX,EDX,ECX) : EAX=byteswritten

OPEN_EXISTING           equ     3
CREATE_ALWAYS           equ     2
GENERIC_READ            equ     80000000h
GENERIC_WRITE           equ     40000000h
FILE_SHARE_READ         equ     00000001h
FILE_SHARE_WRITE        equ     00000002h
FILE_ATTRIBUTE_NORMAL   equ     00000080h
FILE_BEGIN              equ     0

fzeroerror:             pusha
                        push    0
                        callW   SetLastError
                        popa
                        ret

fcheckerror:            callW   GetLastError
                        or      eax, eax
                        jz      maplib1  ; CF=0
                        mov     [esp+7*4]+4, eax
                        stc
maplib1:                ret

fopen:                  pusha
                        call    fzeroerror
                        push    0
                        push    FILE_ATTRIBUTE_NORMAL
                        push    OPEN_EXISTING
                        push    0
                        push    FILE_SHARE_READ
                        push    GENERIC_READ + GENERIC_WRITE
                        push    edx
                        callW   CreateFileA
                        cmp     eax, -1
                        je      maplib3
                        clc
                        mov     [esp+7*4], eax
                        popa
                        ret

fclose:                 pusha
                        call    fzeroerror
                        push    ebx
                        callW   CloseHandle
maplib3:                call    fcheckerror
                        popa
                        ret

fseek:                  pusha
                        call    fzeroerror
                        push    FILE_BEGIN
                        push    0
                        push    edx
                        push    ebx
                        callW   SetFilePointer
maplib2:                mov     [esp+7*4], eax
                        jmp     maplib3

fread:                  pusha
                        call    fzeroerror
                        push    0
                        lea     eax, [esp+7*4] + 4
                        push    eax               ; bytesread
                        push    ecx
                        push    edx
                        push    ebx
                        callW   ReadFile
                        jmp     maplib3

fwrite:                 pusha
                        call    fzeroerror
                        push    0
                        lea     eax, [esp+7*4] + 4
                        push    eax               ; byteswritten
                        push    ecx
                        push    edx
                        push    ebx
                        callW   WriteFile
                        jmp     maplib3

