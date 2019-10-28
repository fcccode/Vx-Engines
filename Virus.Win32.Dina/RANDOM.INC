; Процедура генерации случайного слова в заданном интервале
RandEAX:  pusha
          push eax
          call random
          mov [esp+01ch],eax
          popa
          ret
random:
call @randomL1
@randomL2:
offset2RandSeed EQU offset RandSeed - offset @randomL2
offset2ww       EQU offset ww - offset @randomL2
RandSeed  dd 2394900h
ww        dw 8405h
@randomL1: pop edi
xor eax,eax
;mov ax,WORD PTR [edi+offset2RandSeed]
db 66h,8bh,07h
;mov bx,WORD PTR [edi+offset2RandSeed+2]
db 66h,8bh,5fh,02h
mov cx,ax
;mul word ptr [edi+offset2ww]
db 66h,0f7h,67h,04h
SHL cx,1
shl cx,1
shl cx,1
add dx,cx
add dx,bx
shl bx,1
shl bx,1
add dx,bx
add dh,bl
mov cl,05
shl bx,cl
add ax,0001
adc dx,0
;mov WORD PTR [edi+offset2RandSeed],ax
db 66h,89h,07h
;mov WORD PTR [edi+offset2RandSeed+2],dx
db 66h,89h,57h,02h
mov Ebx,Esp
mov cx,dx
mul ss:word ptr [Ebx+4]
mov ax,cx
mov cx,dx
mul ss:word ptr [Ebx+4]
add ax,cx
adc dx,00
mov ax,dx
ret  4