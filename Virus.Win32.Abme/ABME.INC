; (c) Pr0cedure pr0cedure@chat.ru

ABME:
    push ax bx dx bp
    mov  bp,si
    sub  bp,TableLength
ABME0:
    lodsw
    xchg ax,bx
    push si
    push cx
    mov si,bp
    mov cx,0ffh
ABME1:
    lodsw
    cmp ax,bx
    je Ok
    loop ABME1
Ok:
    mov ax,0ffh
    sub ax,cx
    pop cx
    pop si
    stosb
    loop ABME0
    pop bp dx bx ax
    ret
