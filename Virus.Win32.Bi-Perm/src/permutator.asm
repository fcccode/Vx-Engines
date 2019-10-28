

;===============================================================================
; <<<< BI-PERM V0.1 >>>>
; Low metamorphic (permutation) engine
; (X) Malum 2007
;-------------------------------------------------------------------------------
;
;Description:
;Engine disassembles code in big list of p-codes then it randomly breaks p-code
;on blocks and writes mutated code into output buffer.
;For example:
;
; ...                ...               ...
; mov eax,ecx        mov eax,ecx       mov eax,ecx
; add eax,24         jmp @@1           add eax,24
; sub [edi],eax ==>  ...           ==> jmp @@1
; ...                @@1:              ...
;                    add eax,24        @@1:
;                    sub [edi],eax     sub [edi],eax
;                    ...               ...
;
;!!!IMPORTANT!!! Conditions of mutating code:
;1. Mutating code must not have absolute offsets and relative jumps out of
;   available memory
;2. All branchs of code must be connected with the next commands:
;   jmp lbl/call lbl/jcc/loop-e-ne/jecxz.
;3. Terminating commands of branch execution are retn[i]/retf[i]/iretd/jmp reg/
;   jmp mem
;4. All control commands (ret,jmp etc.) must not have prefixes (my bug)
;   for example, <jmp es:[mem]> is not terminating command because first byte of
;   this opcode is ES prefix
;5. jmp xxxx:xxxx is not terminating command too do RET after it (just a bug :))
;6. Of cause, input code must be ONLY code without data
;
;
;Notes about output mutated code:
;1. All jmps and jccs in mutated code have long size (I'm lazy :P )
;   je  xx ==> 0f 84 xx xx xx xx ;only long opcode (never 7x opcode)
;   jmp xx ==> e9 xx xx xx xx    ;only long opcode (never eb opcode)
;
;2. To avoid problems with loop/e/ne,jecxz all blocks of code have size less
;   then 60 bytes
;
;3. Mutator generates after all blocks (excluding blocks with terminating
;   command in the end) JMP_NEAR to next block. So sometimes (not often) you can
;   see code like this:
;   ...
;   mov ecx,eax
;   jmp $+5
;   sub ecx,[edx]
;   ...
;
;4. Mutator generates JMP_NEAR commands on destinations of loop/e/ne,jecxz after
;   blocks that have loop/e/ne,jecxz opcodes (but loop/e/ne,jecxz not use this
;   jmps sometimes)
;A generation
;   ....
;   jecxz @0:
;   ....
;   jmp near next_blk
;@0:jmp near _dest
;B generation
;   ....
;   jecxz _dest
;   ....
;   jmp near next_blk
;   jmp near junk	;never used JMP
;
;
;Engine needs three external user defined routines. Its prototypes:
; long __stdcall user_random (void *user_param);
; void __stdcall user_mutate (void *user_param, void *user_random,
;                             void *pcode, long *pnum);
; char __stdcall user_disasm (void *user_param, void *opcodes);
;
;user_param is a user defined argument for all this routines.
;Important note:
;All user defined routines must not change general registers and DF flag!
;It must return result in EAX register.
;For example:
;
;user_random:
;	push	ecx
;	mov	ecx, [esp+8]		;user_param points to random seed buffer
;	imul	eax, [ecx], 41C64E6Dh	;operations to get random value
;	add	eax, 3039h
;	xchg	eax, [ecx]
;	pop	ecx
;	ret	4			;clear argument from stack
;
;How to write your own disasm or mutate routine see disasm.asm and mutate.asm
;
;-------------------------------------------------------------------------------
;Prototype of main procedure:
;
;//df=0 (cld - DON'T FORGET!) 
;long long __stdcall permutate(
;        void *tmpbuf,      //temp buffer (codesize*50)
;        void *pentry,      //mutating code entry point
;        void *outbuf,      //output buffer for mutated code
;        long  codesize,    //size of first generation of code
;        void *user_param,  //user parameter for user_xxx routines
;        void *user_random, //offset to user_random
;        void *user_mutate, //offset to user_mutate
;        void *user_disasm  //offset to uset_disasm
;        );        
;
;return:
;        eax (low part of result)  - mutated code entry point in ouput buffer
;        edx (high part of result) - size of mutated code
;===============================================================================

;p-code's structure
pcd_opcode	= 0			;opcode bytes (+relj field optionally)
pcd_relj	= dword ptr 11		;next p-code in branching opcodes only
pcd_isz		= byte  ptr 15		;size of opcode and flags
pcd_next	= dword ptr 16		;\ address of next opcode in chain or 0
pcd_addr	= dword ptr 16		;/ address of output address of opcode
pcd_size	= 20

;block's structure
blk_inum	= byte ptr 0		;number of instructions
blk_sjmpn	= byte ptr 2		;number of loop/e/ne,jecxz opcodes
blk_next	= dword ptr 4		;ptr to next p-code after block or zero
blk_jmpsaddr	= dword ptr 8		;address of jmp-table after block
blk_size	= 12

;arguments for permutate routine
arg_tmpbuf	= dword ptr 00h		;temp buffer
arg_pcode	= dword ptr 04h		;mutating code entry point
arg_outbuf	= dword ptr 08h		;output buffer for mutated code
arg_codesize	= dword ptr 0ch		;size of first generation of code
user_var	= dword ptr 10h		;user value
user_random	= dword ptr 14h		;address of user_random
user_mutate	= dword ptr 18h		;address of user_mutate
user_disasm	= dword ptr 1ch		;address of uset_disasm

permutate proc
	pushad

	lea	ebp, [esp+36]
	mov	esi, [arg_pcode][ebp]	;esi - code entry point
	mov	edi, [arg_tmpbuf][ebp]	;edi - out buffer for p-code
	mov	ecx, [arg_codesize][ebp]
	imul	ecx, ecx, 28
	lea	ebx, [edi+ecx]		;ebx - temp buffer
	push	eax			;buffer for local variable
	push	ebx			;pointer to the number of p-codes
	call	analyze_code		;disassembly opcodes in p-codes

	pop	eax
	pop	ecx
	push	eax			;pointer to the number of p-codes
	push	[arg_tmpbuf][ebp]	;buffer with p-codes
	push	[user_random][ebp]	;user's random procedure
	push	[user_var][ebp]		;user parameter
	call	[user_mutate][ebp]	;mutate it!
	
	mov	esi, [arg_tmpbuf][ebp]	;esi - buffer with p-code
	mov	ecx, [arg_codesize][ebp]
	imul	ecx, ecx, 28
	lea	edi, [esi+ecx]		;edi - out buffer for block's info
	push	edi
	call	create_blocks		;break p-code in blocks

	pop	esi			;esi - buffer with block's info
	push	edi			;edi - out array of ptr to blocks
	call	mixx_blocks		;mix created blocks

	pop	esi			;esi - array of ptr to blocks
	mov	edi, [arg_outbuf][ebp]	;edi - buffer for mutated code
	call	make_permutant		;assembly and link blocks of p-code
	
	sub	eax, [arg_outbuf][ebp]	;eax - out buffer + size of new code
	mov	[esp+14h], eax		;pushad.edx = size of mutated code

	popad
	mov	eax, [arg_tmpbuf][esp+4]
	mov	eax, [pcd_addr][eax]	;address of first opcode in out buffer
	ret	20h			;clear arguments from stack
permutate endp


;Write mutated code into buffer
;input:  esi - array of blocks,
;        edi - output buffer
;output: edi - mutated code

make_permutant proc
	push_of	perm_code1
	push_of	perm_code1_j
	call	parse_blocks_pcodes
	push_of	perm_code2
	push_of	perm_code2_j
	call	parse_blocks_pcodes
	add	esp, 16
	ret

;Procedures integrated in parse_blocks_pcodes procedure
;--------->

;input: eax - p-code, 
;       edi - out buffer
perm_code1 proc
	push	esi
	xchg	eax, esi
	mov	[pcd_addr][esi], edi
	movzx	ecx, [pcd_isz][esi]
	and	cl, 0fh			;clear flag bits
	jz	mp_null_opcode		;skip nop opcodes (jmps)
	rep	movsb			;copy opcode in out buffer
 mp_null_opcode:
	pop	esi
	ret
perm_code1 endp

;input: ebp - next block,
;       [esi-4] - current block,
;       edi - out buffer
perm_code1_j proc
	mov	al, 0e9h		;jmp_near opcode
	test	ebp, ebp
	mov	ebp, [esi-4]		;get current block
	jz	mp_no_jmp
	stosb
	stosd
 mp_no_jmp:
	mov	[blk_jmpsaddr][ebp], edi
	movzx	ecx, [blk_sjmpn][ebp]
	jecxz	mp_no_jmp_table
 mp_next_jmp:
	stosb
	stosd
	loop	mp_next_jmp
 mp_no_jmp_table:
	ret
perm_code1_j endp

;input: eax - p-code, 
;       edi - out buffer, 
;       ebx - current ptr in block's array
perm_code2 proc
	movzx	ecx, [pcd_isz][eax]
	and	cl, 0fh			;clear flags field in size field
	add	edi, ecx
	mov	ecx, [pcd_relj][eax]	;p-code of next command
	mov	eax, [pcd_opcode][eax]	;get opcode bytes
	cmp	al, 0e8h		;call imm32
	je	mp_rel_jmp32
	and	ah, 0f0h
	cmp	ax, 0800fh		;jcc imm32
	jne	mp_no_jmp32
 mp_rel_jmp32:
	mov	ecx, [pcd_addr][ecx]	;address of next command
	sub	ecx, edi
	mov	[edi-4], ecx		;relative offset for call/jcc
 mp_no_jmp32:
	and	al, 0fch
	cmp	al, 0e0h
	jne	mp_no_jecxz_loop
	mov	eax, [pcd_addr][ecx]
	sub	eax, edi
	cmp	eax, 7fh
	jg	mp_jmp2near_jmp
	cmp	eax, -7fh
	jge	mp_write_offset8
 mp_jmp2near_jmp:
	mov	ecx, [ebx-4]		;get current block
	add	[blk_jmpsaddr][ecx], 5
	mov	ecx, [blk_jmpsaddr][ecx]
	add	eax, edi
	sub	eax, ecx
	mov	[ecx-4], eax
	sub	ecx, edi
	lea	eax, [ecx-5]
 mp_write_offset8:
	dec	edi			;relative offset for loop/e/ne,jecxz
	stosb
 mp_no_jecxz_loop:
	ret
perm_code2 endp

;input: ebp - next block, 
;       [esi-4] - current block, 
;       edi - out buffer
perm_code2_j proc
	test	ebp, ebp
	jz	mp_no_calc_jmp
	add	edi, 5
	mov	eax, [pcd_addr][ebp]
	sub	eax, edi
	mov	[edi-4], eax
 mp_no_calc_jmp:
	mov	ecx, [esi-4]
	movzx	ecx, [blk_sjmpn][ecx]
	lea	ecx, [ecx+ecx*4]
	add	edi, ecx		;skip jmp-table for loop/e/ne,jecxz
	ret
perm_code2_j endp


;Parse p-codes in blocks via mixed array of blocks
;input:  esi - array of blocks, edi - out buffer,
;        arg1 - _code, arg2 - _code_j

parse_blocks_pcodes proc
	pushad
	lodsd				;number of blocks
	xchg	ecx, eax
 mp_next_block:
	lodsd				;get element in array of ptrs to blocks
	push	ecx
	mov	ebx, esi
	xchg	esi, eax
	lodsd				;blk_inum/blk_sjmpn
	movzx	edx, al
	lodsd				;blk_next
	xchg	ebp, eax
	lodsd				;blk_jmpsaddr
	jmp	mp_begin_pcodes
 mp_next_pcode:
	lodsd
	call	dword ptr [esp+4+8*4+8]	;call arg2
 mp_begin_pcodes:
	dec	edx
	jns	mp_next_pcode
	mov	esi, ebx
	call	dword ptr [esp+4+8*4+4]	;call arg1
	pop	ecx
	loop	mp_next_block
	mov	[esp+7*4], edi
	popad
	ret
parse_blocks_pcodes endp

make_permutant endp


;Create array of pointers to blocks and mix it
;input:  esi - buffer with block's info
;        edi - out buffer
;        ebp - argument's stack, df=0 (cld)
;output: edi - array of mixed pointers to blocks

mixx_blocks proc
	xchg	eax, esi
	push	edi
	stosd				;value in eax is not important
	xor	ecx, ecx
 mb_next_block:
	inc	ecx
	stosd				;ptr to block
	movzx	edx, [blk_inum][eax]
	lea	eax, [eax+edx*4+blk_size]
	test	dl, dl			;test mark of last pseudo-block
	jns	mb_next_block

	dec	ecx
	pop	edi
	mov	eax, ecx
	stosd
 mb_mix_blox:
	push	[user_var][ebp]
	call	[user_random][ebp]	

	xor	edx, edx		;clear high part of qword [edx:eax]
	div	ecx			;edx = random value in range 0..ecx-1
	mov	eax, [edi]
	xchg	eax, [edi+edx*4]
	stosd
	loop	mb_mix_blox
	ret
mixx_blocks endp


;Creates random blocks of p-code
;input:  esi - buffer with p-code,
;        edi - out buffer for blocks' info,
;        ebp - argument's stack, df=0 (cld)
;output: edi - buffer with block's descriptors
;format of block structure:
;  __________________________________
; |inum|pblk| ... | ...pcode_ptrs... |
; 0    4    8     20                ...
;inum - number of pcode pointers
;pblk - pointer to next block in chain (equal 0 in last block in chain)
;pcode_ptrs - array of pointers to p-code structures from esi buffer
;other fields are used in make_permutant procedure

create_blocks proc
	call	__create_blocks
	or	al, 80h
	stosd				;mark end block
	ret

__create_blocks:
	push	edi
 px_init_block:
	test	[pcd_isz][esi], 80h	;test mark of p-code
	jnz	px_end_chain
	mov	ebx, edi
	xor	eax, eax
	stosd			;blk_inum - number of p-codes
	stosd			;blk_next - ptr to next p-code after block
	stosd			;blk_jmpsaddr - used in make_permutant only
	xchg	edx, eax		;edx - counter of p-codes in block

 px_next_pcode:
	movzx	eax, [pcd_isz][esi]
	test	al, 80h			;test mark of p-code
	jnz	px_end_chain
	and	al, 0fh			;clear optional disasm flags
	or	[pcd_isz][esi], 80h	;mark p-code (bit 8 of size field)

	add	edx, eax		;edx - size of block (must be <64)
	xchg	eax, esi
	mov	esi, [pcd_next][eax]
	mov	[blk_next][ebx], esi
	stosd
	inc	[blk_inum][ebx]
	test	esi, esi
	jz	px_end_chain

	push	[user_var][ebp]
	call	[user_random][ebp]

	and	al, 7
	cmp	al, 7			;in 1 of 8 cases end blocks with jmp
	je	px_init_block
	cmp	edx, 60			;size of block must be <64 bytes
	jb	px_next_pcode
	jmp	px_init_block

 px_end_chain:
	mov	edx, edi
	pop	esi
	jmp	px_empty_blk

 px_parse_block:
	add	esi, blk_size
	movzx	ecx, [blk_inum][ebx]
	jecxz	px_empty_blk

	push	edx
 px_parse_for_branch:
	lodsd				;get ptr to p-code
	xchg	edx, eax
	mov	eax, [pcd_opcode][edx]
	cmp	al, 0e8h		;call imm32
	je	px_is_branching
	and	ah, 0f0h
	cmp	ax, 0800fh		;jcc imm32 (jcc8 was converted to 32)
	je	px_is_branching
	and	al, 0fch
	cmp	al, 0e0h		;loop/e/ne imm8, jecxz imm8
	jne	px_no_branching
	inc	[blk_sjmpn][ebx]	;the number of loop/e/ne/jecxz
 px_is_branching:
	pushad
	mov	esi, [pcd_relj][edx]
	call	__create_blocks
	pop	eax
	push	edi			;change pushed edi
	popad
 px_no_branching:
	loop	px_parse_for_branch
	pop	edx

 px_empty_blk:
	mov	ebx, esi
	cmp	ebx, edx
	jb	px_parse_block		;if it is not empty block
	ret
create_blocks endp


;Disassemble code in p-code and write it into buffer
;input:  edi - out buffer,
;        ebx - temp buffer,
;        esi - code offset,
;        ebp - argument's stack, df=0 (cld)
;output: edi - buffer with pseudo code
;format of p-code block:
;  _____________________
; | opcode |relj|sz|next|
; 0        11   15 16   20
;opcode - bytes of opcode (relj field can be a part of opcode field)
;relj   - address of p-code block for all branching opcodes (jcc/call/...)
;sz     - size of opcode (low 4 bits) and optional flags (hi 3 bits ex 8th bit)
;next   - address of next p-code block


analyze_code proc
	loc_inum = dword ptr -40	;local variable in caller's stack

	mov	[loc_inum][ebp], ebx
	and	dword ptr [ebx], 00h	;initialze the number of p-codes
	add	ebx, 4

__analyze_code:
	push	esi
	push	[user_var][ebp]
	call	[user_disasm][ebp]	;call length-disassembler engine
	mov	[pcd_isz][edi], al
	and	al, 0fh			;clear optional disasm flags

	mov	[ebx], esi
	mov	[ebx+4], edi
	add	ebx, 8
	mov	edx, [loc_inum][ebp]
	inc	dword ptr [edx]

	push	edi
	xchg	eax, ecx
	mov	edx, [esi]
	rep	movsb
	pop	edi

	add	edi, pcd_size
	call	__get_marked_addr
	mov	[pcd_next][edi-pcd_size], eax
	xchg	eax, edx

	push	 eax
	and	ah, 38h
	cmp	ax, 020ffh
	pop	eax
	je	ac_retx
	and	ah, 0f0h
	cmp	ax, 0800fh		;jcc imm32
	je	ac_jcc32_call
	cmp	al, 0e8h		;call imm32
	je	ac_jcc32_call
	cmp	al, 0e9h		;jmp imm32
	je	ac_jmp32
	cmp	al, 0ebh		;jmp imm8
	je	ac_jmp8
	cmp	al, 0cfh		;iret
	je	ac_retx
	push	eax
	and	al, 0f6h
	cmp	al, 0c2h		;retn retf retn_i retf_i
	pop	eax
	je	ac_retx
	and	al, 0fch
	cmp	al, 0e0h		;loop/e/ne jecxz
	je	ac_loop_jecxz
	and	al, 0f0h
	cmp	al, 070h		;jcc imm8
	je	ac_jcc8

 ac_term_code:
	call	__get_marked_addr
	cmp	eax, edi
	je	__analyze_code
	ret
 ac_retx:
	and	[pcd_next][edi-pcd_size], 0
	ret

 ac_jmp8:
	movsx	edx, byte ptr [esi-1]
	add	esi, edx
	jmp	ac_xjmp8

 ac_jmp32:
	add	esi, [esi-4]
 ac_xjmp8:
	;clear size (jmps will be regenerated)
	and	[pcd_isz][edi-pcd_size], 0f0h
	call	__get_marked_addr
	mov	[pcd_next][edi-pcd_size], eax
	jmp	ac_term_code

 ac_jcc8:
	and	[pcd_isz][edi-pcd_size], 0f0h
	or	[pcd_isz][edi-pcd_size], 6	;size of jcc_near
	mov	dh, [pcd_opcode][edi-pcd_size]	;dh = 7xh
	xor	dh, 0f0h			;dh = 8xh
	mov	dl, 0fh
	mov	[pcd_opcode][edi-pcd_size], dx	;now it's 0fh 8xh opcode
 ac_loop_jecxz:
	movsx	edx, byte ptr [esi-1]
	jmp	ac_xjcc8
 ac_jcc32_call:
	mov	edx, [esi-4]
 ac_xjcc8:
	push	esi
	add	esi, edx
	call	__get_marked_addr
	mov	[pcd_relj][edi-pcd_size], eax
	or	[pcd_isz][eax], 40h		;mark opcode as label
	cmp	eax, edi
	jne	ac_already_anlzd

	push	edi
	call	__analyze_code
	pop	edx
	or	[pcd_isz][edx], 40h		;mark opcode as label
	pop	esi
	call	__get_marked_addr
	mov	[pcd_next][edx-pcd_size], eax
	push	esi
 ac_already_anlzd:
	pop	esi
	jmp	ac_term_code


;Search address of opcode's p-code in array of already processed
;opcodes and return this address or current edi (if nothing found)
;input:  esi - address of instruction
;output: eax - address of p-code or current edi

__get_marked_addr proc
	pushad
	mov	edx, edi		;defalut return value is edi
	mov	edi, [loc_inum][ebp]
	mov	ecx, [edi]
	shl	ecx, 1
	add	edi, 4
	xchg	eax, esi
	repne	scasd
	jne	pcode_not_found
	neg	ecx
	mov	edx, [ebx+ecx*4]	;address of p-code block
 pcode_not_found:
	mov	[esp+7*4], edx		;pusha.eax
	popad
	ret
__get_marked_addr endp

analyze_code endp

