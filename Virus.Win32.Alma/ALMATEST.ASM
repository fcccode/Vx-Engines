include alma.inc
.586p
.model flat

extrn ExitProcess:PROC
extrn AlmaDizasm:PROC
extrn GetProcAddress:proc
extrn CreateFileA:proc
extrn ReadFile:proc
extrn WriteFile:proc
extrn SetFilePointer:proc
extrn CloseHandle:proc

.data
filename db 'hello.exe',0

_Start:
           ; открываем HELLO.EXE
           sub    EAX, EAX
           push   EAX
           push   EAX
           push   3
           push   EAX
           push   3
           push   40000000h or 80000000h
           lea    EDI, filename
           push   EDI
           call   CreateFileA
           xchg   EAX, EBX


           sub    EAX, EAX
           push   EAX
           push   EAX
           push   600h ; Смещение кодовой секции в файле HELLO.EXE
           push   EBX
           call   SetFilePointer

           sub    EAX, EAX
           push   EAX
           push   offset Temp
           push   8Bh ; Длина кода в файле HELLO.EXE
           push   offset _TestBuff
           push   EBX
           call   ReadFile

           sub    EAX, EAX
           push   EAX
           push   EAX
           push   600h ; Смещение кодовой секции в файле HELLO.EXE
           push   EBX
           call   SetFilePointer
       lea     ESI, _TestBuff
ToLoopCycl:
       lea     EDI, CommInf
       pushad
       call    AlmaDizasm
       jc      ErrorDiz
;=========== ASM
       lea     EBX, TempBuff
       xchg    EDI, EBX

       cmp     [EBX.cFlg_F0], 0
       je      c_No_F0
       mov     AL, 0F0h
       stosb
c_No_F0:
       cmp     [EBX.cFlg_67], 0
       je      c_No_67
       mov     AL, 67h
       stosb
c_No_67:
       cmp     [EBX.cFlg_66], 0
       je      c_No_66
       mov     AL, 66h
       stosb
c_No_66:
       cmp     [EBX.cFlg_Seg], 0
       je      c_No_Seg
       mov     AL, [EBX.cFlg_Seg]
       stosb
c_No_Seg:
       cmp     [EBX.cFlg_Rep], 0
       je      c_No_Rep
       mov     AL, [EBX.cFlg_Rep]
       stosb
c_No_Rep:
       mov     EAX, [EBX.cOpCod]
       push    ECX
       xor     ECX,ECX
       mov     CL,[EBX.cLen]
     @@lp:
        stosb
        shr EAX,8
        loop @@lp
       pop     ECX
c_SIB:
       cmp     [EBX.cSIB], 1
       jne     c_Addr
       mov     AL, [EBX.cSibSS]
       or      AL, [EBX.cSibIndex]
       or      AL, [EBX.cSibBase]
       stosb
c_Addr:
       cmp     [EBX.cALen], 0
       je      c_Data

       push    ESI
       lea     ESI, [EBX.cAdr]
       sub     ECX, ECX
       mov     CL, [EBX.cALen]
       rep     movsb
       pop     ESI

c_Data:
       cmp     [EBX.cDLen], 0
       je      c_Success

       push    ESI
       lea     ESI, [EBX.cData]
       sub     ECX, ECX
       mov     CL, [EBX.cDLen]
       rep     movsb
       pop     ESI
c_Success:
       cmp     [EBX.cType],21h
       jnz NOONO
       cmp     [EBX.cDLen],4
       jnz NOONO
       cmp     4 ptr [EBX.cData], 1
       jnz NOONO
       cmp     [EBX.cReg],0
       jnz NOONO
       mov     1 ptr [EDI-5],33h
       mov     1 ptr [EDI-4],0C0h
       mov     1 ptr [EDI-3],90h
       mov     1 ptr [EDI-2],40h
       mov     1 ptr [EDI-1],90h
NOONO:
;=========== /ASM
       popad
       clc
       sub    EAX, EAX
       push   EAX
       push   offset Temp
       mov    AL, [EDI.cLen]
       add    AL, [EDI.cDLen]
       add    AL, [EDI.cALen]
       push   EAX
       add    EBP, EAX
;       add    ESI, EAX
;       push   8Bh ; Длина кода в файле HELLO.EXE
       push   offset TempBuff
       push   EBX
       call   WriteFile
cmp  EBP, 8Bh ; Длина кода в файле HELLO.EXE
       jb     ToLoopCycl
       retn
ErrorDiz:
       popad
       retn

Temp     db 100 dup (90h)
TempBuff db 16d dup (90h)
CommInf ComandInfo ?

_TestBuff db 8Bh DUP (90h)


.code

start:
                call        _Start
exit:
                push        00000000h
                call        ExitProcess
end start