; Различные процедуры для работы с блоками

MaxBlocks	equ	1000

AddBlock	proc		; ESi - Position, EAX - Size to extend
	Call	CheckBlockAdd	; Можно добавить уже к существующему блоку ?
	jc	CreateBlock	; Неа... Создадим новый
	add	[edx][4],eax	; Увеличим размер блока
	ret
AddBlock	endp
;--------------------------------------------------
CheckBlockAdd	proc		; Проверка на вхождение адреса в блок
	push	esi ecx eax	; с возможностью добавления в конец блока
	mov	ebx,esi
	mov	ecx,[BlockNum][ebp]
	or	ecx,ecx
	jz	BBlock
	lea	esi,[Blocks][ebp]
CheckIt:lodsd
	mov	edx,eax
	lodsd
	add	eax,edx
	cmp	ebx,eax
	ja	NotHere
	cmp	ebx,edx
	jae	Here
NotHere:loop	CheckIt
BBlock:	pop	eax ecx esi
	stc
	ret
Here:	lea	edx,[esi-8]
	pop	eax ecx esi
	clc
	ret
CheckBlockAdd	endp

CheckBlock	proc		; Проверка на вхождение адреса в блок
	push	esi ecx eax
	mov	ebx,esi
	mov	ecx,[BlockNum][ebp]
	or	ecx,ecx
	jz	xBBlock
	lea	esi,[Blocks][ebp]
xCheckIt:
	lodsd
	mov	edx,eax
	lodsd
	add	eax,edx
	cmp	ebx,eax
	jae	xNotHere
	cmp	ebx,edx
	jae	xHere
xNotHere:
	loop	xCheckIt
xBBlock:
	pop	eax ecx esi
	stc
	ret
xHere:	lea	edx,[esi-8]
	pop	eax ecx esi
	clc
	ret
CheckBlock	endp
;--------------------------------------------------
CreateBlock	proc			; Создает новый блок
	push	edi
	mov	edi,[BlockNum][ebp]
	lea	edi,[Blocks][edi*8][ebp]
	xchg	esi,eax
	stosd
	xchg	esi,eax
	stosd
	pop	edi
	inc	[BlockNum][ebp]
	ret
CreateBlock	endp
;--------------------------------------------------
CheckBlocks	proc
	mov	[incheck][ebp],1
	push	esi edi
	mov	ecx,[BlockNum][ebp]
	or	ecx,ecx
	jz	NoBlocks
	xor	ecx,ecx
	lea	edx,[Blocks][ebp]
DoCheck:push	ecx
	lea	esi,[edx][8]
DoC2:	mov	edi,[edx]
	add	edi,[edx][4]
	mov	ebx,[esi]
	add	ebx,[esi][4]

	mov	eax,[edx]
	cmp	eax,[esi]
	jb	RightCheck
	cmp	eax,ebx
	ja	xJoin
	Call	JoinBlocks
	jmp	xJoin
RightCheck:
	cmp	edi,ebx
	ja	xJoin
	cmp	edi,[esi]
	jb	xJoin
	Call	JoinBlocks
xJoin:	add	esi,8
	inc	ecx
	cmp	ecx,[BlockNum][ebp]
	jb	DoC2
	add	edx,8
	pop	ecx
	inc	ecx
	cmp	ecx,[BlockNum][ebp]
	jb	DoCheck

NoBlocks:
	mov	[incheck][ebp],0
	pop	edi esi
	ret
CheckBlocks	endp
;--------------------------------------------------
RemoveBlock	proc			; ESi = Block to delete...
	push	ecx esi edi
	mov	edi,esi
	lea	ecx,[Blocks][ebp]
	sub	ecx,esi
	neg	ecx
	shr	ecx,3
	sub	ecx,[BlockNum][ebp]
	neg	ecx
	or	ecx,ecx
	jz	NoShr
;	cmp	ecx,1
;	jz	NoShr
;	dec	ecx
	shl	ecx,1
	add	esi,8
rep	movsd
NoShr:	pop	edi esi ecx
	dec	[BlockNum][ebp]
	cmp	[incheck][ebp],0
	jz	JRet
	sub	esi,8
JRet:	ret
RemoveBlock	endp
;--------------------------------------------------
JoinBlocks	proc			; EDX + ESi = EDX
	push	ecx
	mov	ecx,[edx]
	add	ecx,[edx][4]
	
	mov	eax,[esi]
	add	eax,[esi][4]

	cmp	eax,ecx
	jb	LeaveEcx
	mov	ecx,eax
LeaveEcx:
	mov	eax,[edx]
	cmp	eax,[esi]
	jb	LeaveEax
	mov	eax,[esi]
LeaveEax:
	sub	ecx,eax

	mov	[edx],eax
	mov	[edx][4],ecx
	Call	RemoveBlock
	pop	ecx
	ret
JoinBlocks	endp
