MaxGarb	equ	2

Last	dd	0

DoGarble	proc
	cmp	[GarbLvl][ebp],MaxGarb
	jae	NoGarb
	inc	[GarbLvl][ebp]
WLast:	mov	eax,GarbLen
	Call	Random
	cmp	[Last][ebp],eax
	jz	WLast
	mov	[Last][ebp],eax
	lea	eax,[GarbTbl][ebp][eax*4]
	mov	eax,[eax]
	add	eax,ebp
	Call	eax
NoGarb:	ret
DoGarble	endp
;--------------------
Random	proc
	push	edx ecx eax
	mov	eax,[randseed][ebp]
	rol	eax,1
	add	eax,7824F38Ch
	rol	eax,1
	not	eax
	neg	eax
	mov	[randseed][ebp],eax
	pop	ecx
	or	ecx,ecx
	jz	NoDiv
	xor	edx,edx
	div	ecx
	xchg	eax,edx
NoDiv:	pop	ecx edx
	ret
Random	endp

randseed	dd	22312345h
;--------------------
GetAnyReg	proc
	mov	eax,8
	Call	Random
	cmp	eax,4
	jz	GetAnyReg
	ret
GetAnyReg	endp

CheckReg	proc
	xchg	eax,ebx
	xor	eax,eax
	mov	al,bl
	bt	[RegMask][ebp],eax
	ret
CheckReg	endp

GetNotFreeReg	proc
	Call	GetRegNum
	or	eax,eax
	jz	GetAnyReg
	sub	eax,8
	neg	eax
	Call	Random
	inc	eax
	xchg	eax,ecx
	xor	ebx,ebx
	mov	eax,[RegMask][ebp]
GetF:	inc	ebx
	shr	al,1
	jnc	GetF
	loop	GetF
	dec	ebx
	xchg	eax,ebx
	ret
GetNotFreeReg	endp

GetReg	proc
	Call	GetRegNum
	or	eax,eax
	jz	NoReg
	Call	Random
	xchg	eax,ecx
	xor	ebx,ebx
	mov	eax,[RegMask][ebp]
ChooseReg:
	inc	ebx
	shr	al,1
	jc	ChooseReg
	or	ecx,ecx
	jz	RetReg
	dec	ecx
	jmp	GetReg

RetReg:	dec	ebx
	xchg	eax,ebx
	ret

NoReg:	mov	al,9
	ret
GetReg	endp

GetRegNum	proc
	mov	eax,[RegMask][ebp]
	xor	ebx,ebx
	not	eax
CheckN:	cmp	al,0
	jz	JJRet
	shr	al,1
	jnc	NoBit
	inc	ebx
NoBit:	jmp	CheckN
JJRet:	xchg	eax,ebx
	ret
GetRegNum	endp

FreeMask	proc
	btr	[RegMask][ebp],eax
	ret
FreeMask	endp

SetMask	proc
	bts	[RegMask][ebp],eax
	ret
SetMask	endp
;--------------------
GarbLvl	db	0

GarbTbl	dd	offset G_XchgEax
	dd	offset G_PushPop
	dd	offset G_Nop
	dd	offset G_GenJxx

	dd	offset G_MovRegImm
	dd	offset G_MovRegReg
GarbLen	equ	($-GarbTbl) shr 2

G_XchgEax:
	cmp	[RegMask][ebp],0FFh
	jnz	EaxUsed

;	xor	eax,eax
;	Call	CheckReg
;	jnc	EaxUsed
;	Call	GetNotFreeReg

	Call	GetAnyReg
	add	al,90h
	push	eax
	stosb
	Call	DoGarble
	pop	eax
	stosb
EaxUsed:
	ret


G_PushPop:
	Call	GetAnyReg
	push	eax
	Call	FreeMask
	
	add	al,50h
	stosb
	
	Call	DoGarble

	pop	eax
	Call	SetMask
	add	al,58h
	stosb
	ret
	
G_Nop:	mov	al,90h
	stosb
	ret

G_MovRegImm:
	Call	GetReg
	cmp	al,9
	jz	bReg
	add	al,0B8h
	stosb
	xor	eax,eax
	Call	Random
	stosd
bReg:	ret

G_MovRegReg:
	Call	GetReg
	cmp	al,9
	jz	bReg
	push	eax
	mov	al,8Bh
	stosb
	pop	eax
	shl	al,3
	xchg	eax,ebx
	Call	GetAnyReg
	add	al,bl
	add	al,0C0h
	stosb
	ret

G_Jxx	dd	0

G_GenJxx:
	mov	eax,[G_Jxx][ebp]
	cmp	eax,MaxJumps
	jae	NoJmpz

	mov	al,0Fh
	stosb
	mov	eax,16
	Call	Random
	add	al,80h
	stosb
	push	edi
	stosd
	Call	DoGarble
	pop	ebx
	mov	eax,edi
	sub	eax,ebx
	sub	eax,4
	mov	[ebx],eax
	inc	[G_Jxx][ebp]
NoJmpz:
	ret
