RANDOMIZE	Proc				;initialization of random engine
i1	pushad
_rnd_:	dw	310Fh				;RDTCS
	db	(MAXINSTRLENGTH-2) dup (90h)	;fill the rest with NOPz
i3	add	eax,edx
i3	mov	[ebp+rnd32_seed-gdelta],eax	;save the random seed
i1	popad
i1	ret
RANDOMIZE	EndP

RANDOM	Proc					;get random number in range <0,ESP+4>
i2	push	ecx
i2	push	edx
i3	mov	eax,[ebp+rnd32_seed-gdelta]
i3	mov	ecx,41C64E6Dh
i2	mul	ecx
i3	add	eax,00003039h
i3	mov	[ebp+rnd32_seed-gdelta],eax
i3	xor	edx,edx
i1o1	div	dword ptr [esp+0Ch]
i3	xchg	eax,edx
i2	pop	edx
i2	pop	ecx
i2	ret	4
RANDOM	EndP

RANDOM2	Proc
i2	push	2
i2	call	RANDOM
i1	ret
RANDOM2	EndP
