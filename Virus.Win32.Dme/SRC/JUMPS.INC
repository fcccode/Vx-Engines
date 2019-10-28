; Процедуры для настройки Jump'ов и того подобного
; Different jmp/call/etc procedures

MaxJumps	equ	1000

AddJump	proc
	push	esi edi
	mov	ebx,esi

	lodsb
	cmp	al,0E9h
	jz	NearJ
	cmp	al,0E8h
	jz	NearJ
	cmp	al,0EBh
	jz	sJump

	cmp	al,0Fh
	jz	TryXJ

	cmp	al,0E0h
	jb	d1
	cmp	al,0E2h
	jbe	sJump

d1:	cmp	al,70h
	jb	NotJump
	cmp	al,7Fh
	ja	NotJump

sJump:	xor	eax,eax
	lodsb
	cbw
	or	ax,ax
	jge	NoInv
	or	eax,0FFFF0000h
NoInv:	Call	AddJmp
	jmp	NotJump
NearJ:	lodsd
	Call	AddJmp
NotJump:pop	edi esi
	ret

TryXJ:	lodsb
	cmp	al,80h
	jb	NotJump
	cmp	al,8Fh
	ja	NotJump
	jmp	NearJ
AddJump	endp

AddJmp	proc
	mov	edi,[Jmpn][ebp]
	lea	edi,[Jumps][ebp][edi*8]
	xchg	eax,ebx
	stosd
	xchg	eax,ebx
	add	eax,esi
	stosd
	inc	[Jmpn][ebp]
	ret
AddJmp	endp

;--------------------------------------------------------------------
GetJmpAddr	proc
	push	esi
	lea	esi,[Jumps][ebp]
	mov	ecx,[Jmpn][ebp]
	or	ecx,ecx
	jz	NoJmpx
FindJJ:	cmp	[esi],eax
	jz	ItHere
	add	esi,8
	loop	FindJJ
NoJmpx:	xor	eax,eax
	pop	esi
	ret
ItHere:	mov	eax,esi
	pop	esi
	ret
GetJmpAddr	endp
;--------------------------------------------------------------------
CheckAddr	proc		; ESi - Addr
	mov	ecx,[Jmpn][ebp]
	or	ecx,ecx
	jz	NoJmp
	lea	ebx,[Jumps][ebp]
CheckAr:
	cmp	[ebx],esi
	jnz	NotPos
	mov	[ebx],edi
NotPos:	cmp	[ebx][4],esi
	jnz	NoPoint
	mov	[ebx][4],edi
NoPoint:
	add	ebx,8
	loop	CheckAr
NoJmp:	ret
CheckAddr	endp

;--------------------------------------------------------------------
PatchJumps	proc
	mov	ecx,[Jmpn][ebp]
	or	ecx,ecx
	jz	NoJmp
	lea	esi,[Jumps][ebp]
DoPatch:
	lodsd
	or	eax,eax
	jz	Skip1
	mov	ebx,eax
	mov	al,[ebx]
	cmp	al,0E8h
	jz	NearJmp
	cmp	al,0E9h
	jz	NearJmp
	cmp	al,0Fh
	jz	xNearJmp
;; Short Jmp
	lodsd
	sub	eax,ebx
	sub	eax,2
	mov	[ebx][1],al
	jmp	NextLoop
xNearJmp:
	lodsd
	sub	eax,ebx
	sub	eax,6
	mov	[ebx][2],eax
	jmp	NextLoop
NearJmp:
	lodsd
	sub	eax,ebx
	sub	eax,5
	mov	[ebx][1],eax
	jmp	NextLoop
Skip1:	lodsd
NextLoop:
	loop	DoPatch
	ret
PatchJumps	endp
