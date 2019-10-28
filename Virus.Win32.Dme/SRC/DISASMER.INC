; Немного ламерски, но работает...

LowData	db	?
LowType	db	?

GetSize32	proc
	mov	[LowData][ebp],0
	mov	[LowType][ebp],0
	xor	ebx,ebx
SAgain:	push	esi edi ecx
	lodsb
	lea	edi,[OpTbl][ebp]
FindIt:	movzx	ecx,1 ptr [edi]
	or	ecx,ecx
	jz	BadOpcode
	inc	edi
repne	scasb
	jnz	SkipBlock
	add	edi,ecx
	mov	eax,[edi]
	add	eax,ebp
	Call	eax
	xchg	eax,ebx
	pop	ecx edi esi
	ret
SkipBlock:
	add	edi,4
	jmp	FindIt
BadOpcode:
	pop	ecx edi esi
	xor	eax,eax
	ret
GetSize32	endp

GetSize16	proc
	mov	[LowData][ebp],1
	inc	ebx
	Call	SAgain
	xchg	eax,ebx
	mov	[LowData][ebp],0
	ret
GetSize16	endp
;-----------------------
XData:	mov	[LowType][ebp],1
	inc	ebx
	Call	SAgain
	xchg	eax,ebx
	mov	[LowType][ebp],0
	ret
;-----------------------
Complex	proc
	xor	edx,edx
	add	bl,2
	lodsb
	push	eax
	shr	al,6
	cmp	al,0
	jz	NoAdd
	cmp	al,3
	jz	NoAdd
	inc	edx

	inc	ebx
	cmp	al,2
	jnz	NoAdd
	inc	ebx
	cmp	[LowData][ebp],1
	jz	NoAdd
	cmp	[LowType][ebp],1
	jz	NoAdd
	inc	ebx
	inc	ebx
NoAdd:	pop	eax
	and	al,11000111b
	cmp	al,5
	jnz	NotFour
	add	ebx,4
NotFour:and	al,00000111b
	cmp	al,4
	jnz	NotAdd2
	cmp	[LowData][ebp],1
	jz	NotAdd2
	inc	ebx
	jmp	Cplx2
NotAdd2:ret
Complex	endp

Cplx2   proc
	or	edx,edx
	jnz	NotAdd4
	lodsb
	and	al,00000111b
	cmp	al,5
	jnz	NotAdd4
	add	ebx,4
NotAdd4:ret
Cplx2   endp

Return7:inc	ebx
Return6:inc	ebx
Return5:inc	ebx
Return4:inc	ebx
Return3:inc	ebx
Return2:inc	ebx
Return1:inc	ebx
	ret

Complex1:
	Call	Complex
	inc	ebx
	ret

Complex2:
	Call	Complex
	add	bl,2
	ret

Complex4:
	Call	Complex2
	cmp	[LowData][ebp],1
	jz	GoRet
	add	bl,2
GoRet:	ret

Return3or5:
	cmp	[LowData][ebp],1
	jnz	Return5
	jmp	Return3

Return3or5addr:
	cmp	[LowType][ebp],1
	jnz	Return5
	jmp	Return3

Repzz:	inc	ebx
	Call	SAgain
	xchg	eax,ebx
	ret
;----------------------------------------------
Grp1:	lodsb
	dec	esi
	and	al,00111000b
	or	al,al
	jz	Complex1
	jmp	Complex

Grp2:	lodsb
	dec	esi
	and	al,00111000b
	or	al,al
	jz	Complex4
	jmp	Complex

uExtended:
	lodsb
	cmp	al,0A3h
	jz	Complex1
	cmp	al,0A4h
	jz	Complex2
	cmp	al,0A5h
	jz	Complex1
	cmp	al,0ABh
	jz	Complex1
	cmp	al,0ACh
	jz	Complex2
	cmp	al,0ADh
	jz	Complex1
	cmp	al,0AFh
	jz	Complex1

	cmp	al,3
	ja	S1
	cmp	al,0
	jae	Complex1

S1:	cmp	al,0Fh
	ja	S2
	cmp	al,5
	jae	Return2

S2:	cmp	al,26h
	ja	S3
	cmp	al,20h
	jae	Complex1

S3:	cmp	al,4Fh
	ja	S4
	cmp	al,40h
	jae	Complex1

S4:	cmp	al,8Fh
	ja	S5
	cmp	al,80h
	jae	Return6

S5:	cmp	al,9Ah
	ja	S6
	cmp	al,90h
	jae	Complex1

S6:	cmp	al,0A1h
	ja	S7
	cmp	al,0A0h
	jae	Return2

S7:	cmp	al,0AAh
	ja	S8
	cmp	al,0A8h
	jae	Return2

S8:	cmp	al,0C1h
	ja	S9
	cmp	al,0B0h
	jae	Complex1

S9:	jmp	Complex1
	
;----------------------------------------------
OpTbl	db	32
	db	00h,02h,10h,12h,20h,22h,30h,32h	; ADD,ADC,AND,XOR
	db	01h,03h,11h,13h,21h,23h,31h,33h	; OR ,SBB,SUB,CMP
	db	08h,0Ah,18h,1Ah,28h,2Ah,38h,3Ah
	db	09h,0Bh,19h,1Bh,29h,2Bh,39h,3Bh
	dd	offset Complex

	db	17				; J??,Jmp Short
	db	70h,71h,72h,73h,74h,75h,76h,77h,78h,79h,7Ah,7Bh,7Ch,7Dh,7Eh,7Fh
	db	0EBh
	dd	offset Return2

	db	8				; Mov Reg8,im8
	db	0B0h,0B1h,0B2h,0B3h,0B4h,0B5h,0B6h,0B7h
	dd	offset Return2

	db	8				; Mov Reg16,im16
	db	0B8h,0B9h,0BAh,0BBh,0BCh,0BDh,0BEh,0BFh
	dd	offset Return3or5

	db	8				; AND,ADC.... AL,im8
	db	04h,14h,24h,34h,0Ch,1Ch,2Ch,3Ch
	dd	offset Return2

	db	8
	db	05h,15h,25h,35h,0Dh,1Dh,2Dh,3Dh	; AND,ADC.... (E)AX,im16(32)
	dd	offset Return3or5

	db	16				; INC/DEC Reg16(32)
	db	40h,41h,42h,43h,44h,45h,46h,47h,48h,49h,4Ah,4Bh,4Ch,4Dh,4Eh,4Fh
	dd	offset Return1

	db	8
	db	90h,91h,92h,93h,94h,95h,96h,97h	; NOP,XCHG (E)AX,Reg16(32)
	dd	offset Return1

	db	16				; Push/Pop Reg16(32)
	db	50h,51h,52h,53h,54h,55h,56h,57h,58h,59h,5Ah,5Bh,5Ch,5Dh,5Eh,5Fh
	dd	offset Return1

	db	2
	db	60h,61h				; Pusha/Popa
	dd	offset Return1
	
	db	1
	db	62h				; Bound
	dd	offset Complex

	db	1
	db	66h				; Extended Size
	dd	offset GetSize16

	db	1
	db	67h				; Xtended data
	dd	offset XData

	db	2
	db	64h,65h				; SegFS/GS
	dd	offset Repzz

	db	11
	db	06h,07h,16h,17h,27h,28h,0Eh,1Eh,1Fh,2Fh,3Fh
	dd	offset Return1

	db	4
	db	26h,36h,2Eh,3Eh
	dd	offset Repzz
	
	db	6
	db	0A0h,0A1h,0A2h,0A3h,0A8h,0A9h	; MOV (E)AX,mem16(32)
	dd	offset Return3or5addr

	db	11				; ???SB
	db	0A4h,0A5h,0A6h,0A7h,0AAh,0ABh,0ADh,0ACh,0ADh,0AEh,0AFh
	dd	offset Return1

	db	2
	db	0C3h,0CBh			; RETN/RETF
	dd	offset Return1
	
	db	4
	db	0D4h,0D5h,0D7h,0CCh		; AAM/AAD,etc
	dd	offset Return1

	db	2
	db	0C2h,0CAh			; RETF/RETN im16
	dd	offset Return3

	db	2
	db	0C4h,0C5h			; LES/LDS
	dd	offset Complex

	db	1
	db	0C6h				; MOV mem,im8
	dd	offset Complex1

	db	1
	db	0C7h				; MOV mem,imm16(32)
	dd	offset Complex4

	db	2
	db	0C0h,0C1h			; SHL/ROL/ROR ...,im8
	dd	offset Complex1

	db	4
	db	0D0h,0D1h,0D2h,0D3h		; SHL/.... ,1
	dd	offset Complex			; SHL/.... ,CL

	db	4
	db	88h,89h,8Ah,8Bh			; MOV r/m,im16,etc
	dd	offset Complex

	db	2
	db	8Ch,8Eh				; MOV r/m,seg
	dd	offset Complex			; MOV seg,r/m

	db	2
	db	8Fh,8Dh				; POP r/m,LEA reg,r/m
	dd	offset Complex

	db	1
	db	68h				; PUSH im16(32)
	dd	offset Return3or5

	db	1
	db	6Ah				; PUSH im8
	dd	offset Return2

	db	1
	db	69h				; imul r/m,im16(32)
	dd	offset Complex4

	db	1
	db	6Bh				; imul r/m,im8
	dd	offset Complex1

	db	4
	db	6Ch,6Dh,6Eh,6Fh			; insb/insw/outsb/outsw
	dd	offset Return1

	db	7
	db	98h,99h,9Bh,9Ch,9Dh,9Eh,9Fh	; cbw/.../lahf/...
	dd	offset Return1

	db	1
	db	0CDh				; int im8
	dd	offset Return2
	
	db	3
	db	0C9h,0CEh,0CFh			; leave/into/iret
	dd	offset Return1

	db	1
	db	0C8h
	dd	offset Return4			; Enter im16,im8

	db	3
	db	80h,82h,83h			; ArOp
	dd	offset Complex1

	db	4
	db	84h,85h,86h,87h			; TEST/XCHG r8(16)(32),r/m
	dd	offset Complex
	
	db	1
	db	81h				; ArOp r/m,r16(32)
	dd	offset Complex4

	db	4
	db	0E0h,0E1h,0E2h,0E3h		; Loop??,jcxz
	dd	offset Return2

	db	4
	db	0E4h,0E5h,0E6h,0E7h		; IN/OUT AL(AX)(EAX),port8
	dd	offset Return2

	db	2
	db	0E8h,0E9h			; Jmp/Call Near
	dd	offset Return3or5

	db	1
	db	0EAh				; Jmp Far
	dd	offset Return7

	db	4
	db	0ECh,0EDh,0EEh,0EFh		; IN/OUT AL(AX)(EAX),DX
	dd	offset Return1

	db	3
	db	0F0h,0F4h,0F5h			; Lock,Halt,CMC
	dd	offset Return1

	db	2
	db	0F2h,0F3h
	dd	offset Repzz

	db	6
	db	0F8h,0F9h,0FAh,0FBh,0FCh,0FDh	; STC/...
	dd	offset Return1

	db	1
	db	0F6h
	dd	offset Grp1

	db	1
	db	0F7h
	dd	offset Grp2

	db	2
	db	0FEh,0FFh
	dd	offset Complex

	db	1
	db	0Fh
	dd	offset uExtended
	
	db	0
