
;===============================================================================
;Length-disassembler engine virxasm32 v1.5
;===============================================================================

include virxasm32b.inc

;===============================================================================
;Length-disassembler
;Prototype of procedure:
; char __stdcall user_disasm (
;     user_param, //user's parameter (is not used here)
;     opcodes     //pointer to opcode
;     );
;
;Format of return information in AL register:
;  ________________
; |0 0 x x s s s s |
; 8                0
;
;00   - this two bits must be equal zero (second bit will be used in mutate)
;xx   - user defined routines (disasm and mutate) can use this bits on its own
;ssss - four bits of size of opcode 
;
;Note: routine must not change any registers except EAX
;===============================================================================

perm_disasm proc
	push	esi
	mov	esi, [esp+12]
	call	virxasm32
	and	al, 3fh		;clear reserved bits
	or	al, 30h		;set our bits (just for fun :))
	pop	esi
	ret	8		;clear arguments from stack
perm_disasm endp

