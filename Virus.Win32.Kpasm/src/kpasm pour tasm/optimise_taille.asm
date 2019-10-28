optimise_taille_code_genere :		; in:	eax=nb transfos restantes
   push edx
   mov ebx,eax
   inc ebx
   imul eax,edx
   xor edx,edx
   div ebx
   pop edx
   sub edx,eax
   ret
