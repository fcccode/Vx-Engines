; (c) Pr0cedure pr0cedure@chat.ru

rnd proc near
                    push ds di dx cx bx ax
                    call @@r0
@@r0:
                    pop di
                    push cs
                    pop ds
                    add di,randomize
                    mov bx,word ptr ds:[di]
                    shr bx,1
                    mov ah,2ch
                    int 21h
                    pop ax
@@r1:
                    xor cx,bx
                    push cx
@@r2:
                    xor dx,bx
                    xor bx,ax
                    not bx
                    add bx,dx
                    neg bx
                    xor bx,dx
                    loop @@r2
                    pop cx
                    xor cx,bx
                    xor ch,cl
                    add ch,dh
                    sub ch,dl
                    mov cl,dl
                    rol cx,1
                    xor cx,dx
                    xchg ax,bx
                    pop bx
                    push bx
                    cmp bx,0ffh
                    jnc @@rr
@@rr3:
                    cmp cl,0ffh
                    jc @@rr2
                    inc ch
                    xchg ch,cl
                    xor cl,ch
                    sub cl,1
                    jmp short @@rr3
@@rr2:
                    cmp cl,bl
                    jmp short @@rr1
@@rr:
                    cmp cx,bx
@@rr1:
                    xchg ax,bx
                    jnc @@r3
                    jmp short @@r4
@@r3:
                    xor dh,dl
                    add dh,dl
                    xchg dh,dl
                    ror dx,cl
                    sub bx,2
                    jmp short @@r1
@@r4:
                    xchg cx,ax
                    mov word ptr ds:[di],ax
                    pop bx cx dx di ds
                    ret
randomize equ $-@@r0
          dw 2406h
rnd endp
