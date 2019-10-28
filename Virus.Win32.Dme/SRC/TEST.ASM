.386p
.model flat,stdcall
extrn	ExitProcess:proc
extrn	CreateFileA:proc
extrn	WriteFile  :proc
extrn	CloseHandle:proc

.data
Start:	
	mov	esi,offset ETbl				; Code
	xor	ebp,ebp	
	mov	edi,offset Buffer			; Dest
	mov	ecx,BSize				; Size

	mov	ebx,esi					; Data Positions
	xor	eax,eax
	mov	edx,offset ETest
	Call	DME

	push	ecx
	Call	CreateFileA,offset mfile,GENERIC_WRITE,SHARE_READ,0,CREATE_ALWAYS,0,0
	xchg	eax,ebx
	pop	eax
	Call	WriteFile,ebx,offset Buffer,eax,offset xx,0
	Call	CloseHandle,ebx

	Call	ExitProcess,0
include	win32.inc
include	dme.inc

ETbl	dd	offset ETest
	dd	0
;--------------------------------------------------------------------------
ETest:
include	test.inc
;--------------------------------------------------------------------------
BSize	equ	$ - ETest

xx	dd	?
mfile	db	'outta.dmp',0
Buffer	db	50000 dup (?)
include	data.inc

.code
	db	'TASM is buggy !',0
end	Start