invoke	macro	api					;macro for API callz
	extrn	api:PROC
	call	api
endm


i2o1	macro	code1,code2,over1,over2,code3
	local	s,e,ee
s:	code1	code2, over1 over2 code3		;e.g. MOVZX EAX,byte ptr [EDI]
e:	db	MAXINSTRLENGTH-(e-s) dup (90h)
endm

i1o2	macro	code1,over1,over2,code2,code3
	local	s,e,ee
s:	code1	over1 over2 code2,code3			;e.g. MOV byte ptr [EDI],3
e:	db	MAXINSTRLENGTH-(e-s) dup (90h)
endm

i1o1	macro	code1,over1,over2,code2
	local	s,e,ee
s:	code1	over1 over2 code2			;e.g. INC dword ptr [ESP]
e:	db	MAXINSTRLENGTH-(e-s) dup (90h)
endm

i3	macro	code1,code2,code3
	local	s,e,ee
s:	code1	code2,code3				;e.g. MOV EAX,EBX
e:	db	MAXINSTRLENGTH-(e-s) dup (90h)
endm

i2	macro	code1,code2
	local	s,e,ee
s:	code1	code2					;e.g. INC EAX
e:	db	MAXINSTRLENGTH-(e-s) dup (90h)
endm

i1	macro	code1
	local	s,e,ee
s:	code1						;e.g. STOSD
e:	db	MAXINSTRLENGTH-(e-s) dup (90h)
endm


SEH_SetupFrame	macro	ExceptionHandler
		local	set_new_eh
i2		call	set_new_eh
i3		mov	esp,[esp.EH_EstablisherFrame]
		ExceptionHandler
set_new_eh:
i3		xor	edx,edx
i1o1		push	dword ptr fs:[edx]
i3		mov	fs:[edx],esp
endm

SEH_RemoveFrame	macro
i3		xor    edx,edx
i1o1		pop    dword ptr fs:[edx]
i2		pop    edx
endm
