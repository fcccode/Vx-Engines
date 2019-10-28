; (c) Pr0cedure pr0cedure@chat.ru

BME:
      push ax bx dx si di bp
      call BME0
RAS equ $-BME
BME0:
      xor dx,dx
;Key generate
      pop bp
      push si
      push cx
      mov cx,0ffh
LOOP_RND:
      mov bx,0fffeh
      call RND
      inc ax
      xchg ax,bx
;Compare with current keys
      push cx
      push dx
      xor dx,dx
      mov cx,0ffh
      mov si,bp
      add si,Table_Of_Keys
LR1:
      add si,dx
      lodsw
      cmp ax,bx
      jne LOOP_RND1
      pop dx
      pop cx
      jmp LOOP_RND
LOOP_RND1:
      add dx,2
      loop LR1
      pop dx
      pop cx
;Save New Key
      mov si,bp
      add si,Table_Of_Keys
      add si,dx
      xchg si,di
      xchg ax,bx
      stosw
      xchg si,di
      add dx,2
      loop LOOP_RND
;Create New Buff
      mov si,bp
      add si,Table_Of_Keys
      mov cx,0ffh
      rep movsw
      pop cx
      pop si
New_Buff:
      xor ax,ax
      lodsb
      push si
      mov si,bp
      add si,Table_Of_Keys
      shl ax,1
      add si,ax
      lodsw
      stosw
      pop si
      loop New_Buff
;Restore and Exit
      xchg cx,di
      pop bp di si dx bx ax
      sub cx,di
      ret
;---
Table_Of_Keys equ $-BME0
TOK:
dw 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h
dw 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h
dw 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h
dw 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h
dw 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h
dw 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h
dw 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h
dw 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h
dw 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h
dw 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h
dw 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h
dw 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h
dw 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h
dw 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h
dw 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h
dw 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 0000h
TableLength equ $-TOK
