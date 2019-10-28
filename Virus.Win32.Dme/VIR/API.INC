; Несколько процедур поиска/импорта kernel32 процедур
; Deviator//HAZARD

k32	dd	0
k32i	dd	0
k32e	dd	0
k32n	dd	0
k32nn	dd	0
obase	dd	0
opos	dd	0
xpos	dd	0

ApiInit	proc

	mov	eax,fs:[0]			; SEH
findl:	cmp	4 ptr [eax],-1			; Последний ?
	jz	last				; Угу
	mov	eax,[eax]
	jmp	findl
last:	mov	edi,[eax][4]

fn:	dec	edi
	mov	ax,'ZM'				; Ищем MZ
fndk:	cmp	[edi],ax
	jz	mz
	dec	edi
	jmp	fndk
mz:	mov	ebx,edi
	mov	eax,[edi][3Ch]			; Берем смещние на PE header
	cmp	eax,3000h			; > 3000h ? (просто в Win95
	jae	fn				; MZ встречается в самом
	add	ebx,eax				; kernel32,а мне облом SEH 
	cmp	4 ptr [ebx],'EP'		; юзать для предотвращения
	jnz	fn				; ошибок )
	mov	eax,edi
	mov	[k32][ebp],edi			; Store Kernel32 ImageBase
	add	edi,[ebx][54h]
	mov	[k32i][ebp],edi			; Store Kernel32 VA

	mov	edx,[ebx][78h]
	add	edx,eax
	mov	[k32e][ebp],edx			; Store Kernel32 Export table

	mov	ecx,[edx][10h]			; Ordinal Base
	mov	[obase][ebp],ecx

	mov	ecx,[edx][24h]			; Ordinal RVA
	add	ecx,eax
	mov	[opos][ebp],ecx

	mov	ecx,[edx][1Ch]
	add	ecx,eax
	mov	[xpos][ebp],ecx			; Export table

	mov	ecx,[edx][20h]
	add	ecx,eax
	mov	[k32n][ebp],ecx			; Export names

	mov	ecx,[edx][18h]
	mov	[k32nn][ebp],ecx		; Number of export names

	ret
ApiInit	endp

ImportApi	proc			; EDi - import name,EDX - Len of name
	mov	esi,[k32n][ebp]		; Процедурка импорта нужной функции
	mov	ecx,[k32nn][ebp]
	xor	ebx,ebx			; возвращает в EAX либо 0,если
aFindIt:
	lodsd				; нет такой функции в экспорте
	push	esi edi ecx		; или ее адрес.
	add	eax,[k32][ebp]
	xchg	eax,esi
	mov	ecx,edx
rep	cmpsb
	pop	ecx edi esi
	jz	ItsIt
	inc	ebx
	loop	aFindIt
	xor	eax,eax
	ret
ItsIt:	inc	ebx
	lea	esi,[ebx*2]
	add	esi,[opos][ebp]
	movzx	eax,2 ptr [esi]
	sub	eax,[obase][ebp]
	shl	eax,2
	add	eax,[xpos][ebp]
	mov	eax,[eax]
	add	eax,[k32][ebp]
	ret
ImportApi	endp
