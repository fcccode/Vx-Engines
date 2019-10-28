; Different procedures to work with data

MaxData	equ	700

AddData	proc
	push	esi edi
	Call	CheckDataOpcode
	jc	NotData
	Call	AddDta
NotData:pop	edi esi
	ret
AddData	endp

AddDta	proc
	mov	edi,[Datan][ebp]
	lea	edi,[Datas][ebp][edi*8]
	mov	eax,esi
	stosd
	Call	GetDataAddr
	cmp	eax,[xSrc][ebp]
	jb	NotOur
	cmp	eax,[MaxMorph][ebp]
	ja	NotOur
	stosd
	inc	[Datan][ebp]
NotOur:	ret
AddDta	endp
;--------------------------------------------------------------------
CheckDataAddr	proc		; ESi - Addr
	mov	ecx,[Datan][ebp]
	or	ecx,ecx
	jz	NData
	lea	ebx,[Datas][ebp]
CheckData:
	cmp	[ebx],esi
	jnz	NxData
	mov	[ebx],edi
NxData:	cmp	[ebx][4],esi
	jnz	NPoint
	mov	[ebx][4],edi
NPoint:
	add	ebx,8
	loop	CheckData
NData:	ret
CheckDataAddr	endp
;--------------------------------------------------------------------
PatchData	proc
	mov	ecx,[Datan][ebp]
	or	ecx,ecx
	jz	NoJmp
	lea	esi,[Datas][ebp]
DataPatch:
	lodsd
	push	esi
	push	eax
	xchg	eax,esi
	Call	PointData
	pop	ebx
	add	ebx,eax
	pop	esi
	lodsd

;	sub	eax,[xDst][ebp]

	mov	[ebx],eax
	loop	DataPatch
	ret
PatchData	endp
;--------------------------------------------------------------------
CheckDataOpcode	proc
	Call	PointData
	or	eax,eax
	jz	BadR
	clc
	ret
BadR:	stc
	ret
CheckDataOpcode	endp

GetDataAddr	proc
	Call	PointData
	add	eax,esi
	mov	eax,[eax]
	sub	eax,[xBase][ebp]
	add	eax,[xSrc][ebp]
	ret
GetDataAddr	endp
;--------------------------------------------------------------------
PointData	proc
	push	esi edi ecx
	mov	ebx,esi
	lodsb
	lea	edi,[DataTbl][ebp]
FindData:
	movzx	ecx,1 ptr [edi]
	or	ecx,ecx
	jz	NotDataOpcode
	inc	edi
repne	scasb
	jnz	SkipThatBlock
	add	edi,ecx
	mov	eax,[edi]
	add	eax,ebp
	Call	eax
	pop	ecx edi esi
	mov	eax,ebx
	sub	eax,esi
	ret
SkipThatBlock:
	add	edi,4
	jmp	FindData
NotDataOpcode:
	pop	ecx edi esi
	xor	eax,eax
	ret
PointData	endp

DataComplex	proc
	xor	edx,edx
	lodsb
	push	eax
	and	al,00000111b
	cmp	al,4
	pop	eax
	jnz	xHaveData
	inc	edx
xHaveData:
	push	eax
	shr	al,6
	cmp	al,2
	pop	eax
	jz	HaveData
	
	and	al,11000111b
	cmp	al,5
	jz	HaveData

	or	edx,edx
	jz	NoData
	lodsb
	and	al,111b
	cmp	al,5
	jz	RetData

NoData:	ret
HaveData:
	or	edx,edx
	jz	RetData
	inc	esi
RetData:
	mov	ebx,esi
	ret
ExtendedData:
DataComplex	endp

DataReturn1:
	inc	ebx
	ret

xOpcode:
	lodsb
	cmp	al,0A3h
	jz	DataComplex
	cmp	al,0A4h
	jz	DataComplex
	cmp	al,0A5h
	jz	DataComplex
	cmp	al,0ABh
	jz	DataComplex
	cmp	al,0ACh
	jz	DataComplex
	cmp	al,0ADh
	jz	DataComplex
	cmp	al,0AFh
	jz	DataComplex

	cmp	al,3
	ja	dS1
	cmp	al,0
	jae	DataComplex

dS1:	cmp	al,26h
	ja	dS2
	cmp	al,20h
	jae	DataComplex

dS2:	cmp	al,4Fh
	ja	dS3
	cmp	al,40h
	jae	DataComplex

dS3:    cmp	al,9Ah
	ja	DataComplex
	cmp	al,90h
	jae	DataComplex

        jmp     DataComplex

;----------------------------------------------------------------------
CheckVariable	proc
	mov	eax,[xAddOffset][ebp]
	cmp	eax,esi
	jnz	NotIt
	mov	[xAddOffset][ebp],edi
NotIt:	ret
CheckVariable	endp
;----------------------------------------------------------------------
DataTbl	db	32
	db	00h,02h,10h,12h,20h,22h,30h,32h	; ADD,ADC,AND,XOR
	db	01h,03h,11h,13h,21h,23h,31h,33h	; OR ,SBB,SUB,CMP
	db	08h,0Ah,18h,1Ah,28h,2Ah,38h,3Ah
	db	09h,0Bh,19h,1Bh,29h,2Bh,39h,3Bh
	dd	offset DataComplex

        db	6
	db	0A0h,0A1h,0A2h,0A3h,0A8h,0A9h	; MOV (E)AX,mem16(32)
	dd	offset DataReturn1

        db	2
	db	0C4h,0C5h			; LES/LDS
	dd	offset DataComplex

        db	1
	db	0C6h				; MOV mem,im8
	dd	offset DataComplex

        db	1
	db	0C7h				; MOV mem,imm16(32)
	dd	offset DataComplex

        db	2
	db	0C0h,0C1h			; SHL/ROL/ROR ...,im8
	dd	offset DataComplex

	db	4
	db	0D0h,0D1h,0D2h,0D3h		; SHL/.... ,1
	dd	offset DataComplex		; SHL/.... ,CL

	db	4
	db	88h,89h,8Ah,8Bh			; MOV r/m,im16,etc
	dd	offset DataComplex

        db	2
	db	8Ch,8Eh				; MOV r/m,seg
	dd	offset DataComplex		; MOV seg,r/m

        db	2
	db	8Fh,8Dh				; POP r/m,LEA reg,r/m
	dd	offset DataComplex

	db	1
	db	69h				; imul r/m,im16(32)
	dd	offset DataComplex

	db	1
	db	6Bh				; imul r/m,im8
	dd	offset DataComplex

	db	4
	db	84h,85h,86h,87h			; TEST/XCHG r8(16)(32),r/m
	dd	offset DataComplex

	db	2
	db	80h,81h				; ArOp r/m,r16(32)
	dd	offset DataComplex

	db	2
	db	0FEh,0FFh
	dd	offset DataComplex

	db	8
	db	0B8h,0B9h,0BAh,0BBh,0BCh,0BDh,0BEh,0BFh
	dd	offset DataReturn1

	db	1
	db	0Fh
	dd	offset xOpcode

        db      0
