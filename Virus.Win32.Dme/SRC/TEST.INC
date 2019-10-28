; Код для теста пермутации

	db	8Dh,34h,5Dh,0,0,0,0
	jz	ee
	jmp	ee
	inc	eax
	mov	eax,3
ee:	ret
