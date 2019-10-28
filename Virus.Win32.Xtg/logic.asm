;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
;																										 ;
;																										 ;
;                                                            											 ;
;																										 ;
;                                       																 ;
;                                     xxxxxxxxxxxxxxxxxxxxxxxxxx      xxxxxxxxxxxxxxxxxxx				 ;
;                                     xxxxxxxxxxxxxxxxxxxxxxxxxx     xxxxxxxxxxxxxxxxxxxx     			 ;
;                                     xxxxxxxxxxxxxxxxxxxxxxxxxx    xxxxxxxxxxxxxxxxxxxxx      			 ;
;        x                         x  xxxxxxxxxxxxxxxxxxxxxxxxxx   xxxxxxxxxxxxxxxxxxxxxx				 ;
;        xxx                     xxx           xxxxxxxx           xxxxxxx		  xxxxxxx      			 ; 
;        xxxxx                 xxxxx           xxxxxxxx           xxxxxxx								 ;
;        xxxxxxx             xxxxxxx           xxxxxxxx           xxxxxxx								 ;
;        xxxxxxxxx         xxxxxxxxx           xxxxxxxx           xxxxxxx								 ;
;         xxxxxxxxxx     xxxxxxxxxx            xxxxxxxx           xxxxxxx								 ;
;           xxxxxxxxxx xxxxxxxxxx              xxxxxxxx           xxxxxxx								 ;
;             xxxxxxxxxxxxxxxxx                xxxxxxxx           xxxxxxx								 ;
;               xxxxxxxxxxxxx                  xxxxxxxx           xxxxxxx       xxxxxxxxx				 ;
;                xxxxxxxxxxx                   xxxxxxxx           xxxxxxx       xxxxxxxxx				 ;
;              xx  xxxxxxx  xx                 xxxxxxxx           xxxxxxx       xxxxxxxxx				 ;
;             xxxx  xxxxx  xxxx                xxxxxxxx           xxxxxxx         xxxxxxx				 ;
;            xxxxxx   x   xxxxxx               xxxxxxxx           xxxxxxx         xxxxxxx				 ;
;           xxxxxxxx     xxxxxxxx              xxxxxxxx            xxxxxxxxxxxxxxxxxxxxxx 				 ;
;          xxxxxxxx       xxxxxxxx             xxxxxxxx             xxxxxxxxxxxxxxxxxxxxx 				 ;
;         xxxxxxxx         xxxxxxxx            xxxxxxxx              xxxxxxxxxxxxxxxxxxxx 				 ;
;        xxxxxxxx           xxxxxxxx           xxxxxxxx               xxxxxxxxxxxxxxxxxxx				 ;
;																										 ;
;																										 ;
;																										 ;
;																										 ;
;																										 ; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
;							eXperimental/eXtended/eXecutable Trash Generator							 ;
;												  xTG													 ;
;												logic.asm												 ;
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
;																										 ;
;												  xD													 ;
;																										 ;
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
;модуль логики трэшгена logic.asm (для xtg.inc, xtg.asm); условно "движок";								 ; 
;проверка и построение логики конструкций/инструкций; 													 ;
;!!!!! здесь лучше не юзать swap-reg мутацию, а использовать другие виды мутаций, так как может быть 	 ;
;!!!!! несоответствие регов и виртуальных регов!														 ;
;!!!!! для понимания фичи изучай сорцы!																	 ;
;!!!!! если логика не нужна, тогда эти функи коментим, а те, что в самом конце сорца - соответственно, 	 ;
;!!!!! раскоментим и юзаем;																				 ;
;!!!!! наслаждайтесь =) 																				 ;
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
;v2.0.0


																		;m1x
																		;pr0mix@mail.ru
																		;EOF



 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;функа let_init ;vl -> verify logic; let - logic in executable trash; 
;инициализация различных данных для правильной работы функции проверки/построения логики трэш-кода
;выделение памяти, инициализация переменных, блоков памяти и т.д.; 
;ВХОД (stdcall: DWORD let_init(DWORD xparam)):
;	xparam		-	адрес заполненной структуры XTG_TRASH_GEN (можно заполнять только конкретные поля);
;ВЫХОД:
;	EAX			-	0, если не получилось всё проинициализировать, иначе вернётся адрес выделенного 
;					участка памяти (этот адрес можно (нужно) также рассматривать как адрес (заполненной) структуры 
;					XTG_LOGIC_STRUCT); 
;ЗАМЕТКИ:
;	пока нет необходимости следить за адресами типа 403008h etc, а также копировать участки памяти 
;	в свою виртуальную память для эмуляции. Достаточно (пока) просто выделить память; 
;	также, нет необходимости следить за правильным состоянием флагов (ZF etc); 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
vl_struct1_addr		equ		dword ptr [ebp + 24h]						;XTG_TRASH_GEN

let_init:
	pushad
	cld
	mov		ebp, esp
	xor		eax, eax 
	mov		ebx, vl_struct1_addr 
	assume	ebx: ptr XTG_TRASH_GEN
	cmp		[ebx].fmode, XTG_REALISTIC									;фича LET будет работать только в режиме "реалистик", 
	jne		_vl_ret_
	test	[ebx].xmask1, XTG_LOGIC										;включили логику?
	je		_vl_ret_
	cmp		[ebx].alloc_addr, 0											;а также при наличии фунок выделения/освобождения памяти; 
	je		_vl_ret_
	cmp		[ebx].free_addr, 0
	je		_vl_ret_ 
																		;далее, выделим память под:
	mov		esi, (sizeof (XTG_LOGIC_STRUCT) + 04 + sizeof (XTG_INSTR_DATA_STRUCT))						;+ структу XTG_LOGIC_STRUCT + flags + struct XTG_INSTR_DATA_STRUCT + 
	add		esi, (sizeof (XTG_INSTR_PARS_STRUCT) + vl_vstack_size + vl_vstack_small_size)				;+ структу XTG_INSTR_PARS_STRUCT + размер виртуального стека + размер дополнительного виртуального стека + 
	add		esi, (sizeof (XTG_REGS_CURV_STRUCT) + (vl_regs_states + 01) * (sizeof (XTG_REGS_STRUCT)))	;+ текущие значения регистров (и 2 маски) (в эмулируемом коде) + состояния регов (100 состояний + 1 такая же структура для хранения количеств состояний регов в массиве структур (состояний)) + 
	add		esi, ((vl_lv_num + 01 + 01 + 01) * 04 + (vl_lv_states + 01) * vl_lv_num * 04)				;+ адреса выбранных проверяемых локальных переменных (+ 2 маски (если кол-во локал-варов увеличивается, тогда и добавить дворды для масок - так как 1 бит под 1 локал-вар, если > 32, то нужен еще дворд etc) + 1 дворд для хранения кол-ва активных локал-варов) + состояния этих локал-варов (etc) + 
	add		esi, (vl_instr_buf_size + 1000h)															;+ буфер для копирования и дальнейшего запуска эмулируемой конструкции (+ 1000h байтов на запас - байты для выравниваний и просто =)) + 
	mov		edi, [ebx].xdata_struct_addr
	assume	edi: ptr XTG_DATA_STRUCT
	test	edi, edi
	je		_vl_nxt_1_
	add		esi, [edi].rdata_size										;+ если есть область памяти, то еще и под неё память; 
	add		esi, [edi].xdata_size        

_vl_nxt_1_:	
	push	esi
	call	[ebx].alloc_addr											;выделим одну такую, здоровую область памяти; 

	test	eax, eax													;успешно?
	je		_vl_ret_

	mov		edx, eax													;и теперь проинициализируем всё, что нужно; 
	assume	edx: ptr XTG_LOGIC_STRUCT
	mov		[edx].xalloc_buf_addr, eax									;сохраним адрес только что выделенной области памяти в данном поле; 
	mov		[edx].xalloc_buf_size, esi									;и размер этой области памяти; 
	add		eax, sizeof (XTG_LOGIC_STRUCT)								;скорректируем дальнейший адрес
	mov		[edx].flags_addr, eax										;адрес для хранения флагов (ZF etc); 
	add		eax, 04
	mov		[edx].xinstr_data_struct_addr, eax							;для структы XTG_INSTR_DATA_STRUCT; 
	add		eax, sizeof (XTG_INSTR_DATA_STRUCT)
	mov		[edx].xinstr_pars_struct_addr, eax							;память (адрес) для структы XTG_INSTR_PARS_STRUCT; 
	add		eax, (sizeof (XTG_INSTR_PARS_STRUCT) + vl_vstack_size)		;
	mov		[edx].vstack_addr, eax										;адрес нового виртуального стэка 
	add		eax, vl_vstack_small_size
	mov		[edx].vstack_small_addr, eax								;адрес для доп. вирт. стека;
	add		eax, 04
	mov		[edx].xregs_curv_struct_addr, eax							;адрес для хранения текущих значений регистров (в эмулируемом коде);
	add		eax, sizeof (XTG_REGS_CURV_STRUCT)
	mov		[edx].xregs_states_addr, eax								;адрес для хранения состояний регов (+ их позиций в массиве состояний -> то есть сначала по этому адресу будет структура XTG_REGS_STRUCT, 
																		;в которой будут храниться кол-во сохранённых состояний для каждого рега, ну а потом массив этих структур - собсно, состояния регов); 
	add		eax, (vl_regs_states + 01) * (sizeof (XTG_REGS_STRUCT))
	mov		[edx].xlv_addr, eax											;адрес для хранения адресов - локальных переменных;
	add		eax, ((vl_lv_num + 01 + 01 + 01) * 04)
	mov		[edx].xlv_states_addr, eax									;под их состояния (etc);
	add		eax, ((vl_lv_states + 01) * vl_lv_num * 04)
	and		[edx].xdata_addr, 0
	test	edi, edi
	je		_vl_nxt_2_													;если была передана ещё и область памяти, то и под неё свой адрес;
	mov		[edx].xdata_addr, eax
	add		eax, [edi].rdata_size
	add		eax, [edi].xdata_size
	add		eax, 10h													;
_vl_nxt_2_:
	mov		[edx].instr_buf_addr, eax									;и под буфер для эмуляции команд; 

	mov		edi, [edx].xalloc_buf_addr									;обнуляю почти все значения;
	mov		ecx, sizeof (XTG_LOGIC_STRUCT)
	add		edi, ecx
	sub		ecx, [edx].xalloc_buf_size
	neg		ecx
	xor		eax, eax
	rep		stosb
	mov		edi, [edx].xregs_curv_struct_addr
	assume	edi: ptr XTG_REGS_CURV_STRUCT
	mov		eax, [edx].vstack_addr
	mov		[edi].xregs_struct.x_esp, eax								;v_esp = адресу виртуального (нового) стека; 
	mov		[edi].xregs_struct.x_ebp, eax								;v_ebp = v_esp; 
	xchg	eax, edx 
		
_vl_ret_:
	mov		dword ptr [ebp + 1Ch], eax									;eax = адресу выделенного участка памяти;
	mov		esp, ebp 
	popad
	ret		4															;выходим; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;конец функи let_init 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx





;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;функа let_main
;построение логики трэш-кода; 
;ВХОД (stdcall: DWORD let_main(DWORD xparam1, xparam2)):
;	xparam1		-	адрес (входной) структуры XTG_TRASH_GEN
;	xparam2		_	адрес (входной) структуры XTG_LOGIC_STRUCT
;ВЫХОД:
;	EAX			-	0	-	если конструкция/инструкция не подходит;
;					-1	-	если попалась неизвестная конструкция;
;					1	-	если конструкция подходит, всё окэ; 
;	(+)			-	нужные поля заполнены соотв-щим образом;
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
vlm_struct1_addr		equ		dword ptr [ebp + 24h]					;XTG_TRASH_GEN
vlm_struct2_addr		equ		dword ptr [ebp + 28h]					;XTG_LOGIC_STRUCT

vlm_xids_addr			equ		dword ptr [ebp - 04]					;XTG_INSTR_DATA_STRUCT
vlm_xips_addr			equ		dword ptr [ebp - 08]					;XTG_INSTR_PARS_STRUCT
vlm_real_flags			equ		dword ptr [ebp - 12]					;для хранения флагов эмулятора
vlm_xrcs_addr			equ		dword ptr [ebp - 16]					;XTG_REGS_CURV_STRUCT
																		;различные вспомогательные переменные; 
vlm_tmp_var1			equ		dword ptr [ebp - 20]					;будем хранить тут regs_init
vlm_tmp_var2			equ		dword ptr [ebp - 24]					;а тут regs_used

vlm_xlv_addr			equ		dword ptr [ebp - 28]					;адрес буфера, в котором будут храниться адреса локальных переменных, а также 2 маски и число активных л.п.; 
vlm_xlv_states_addr		equ		dword ptr [ebp - 32]					;адрес массива "структур", где хранятся состояния локал-варов; 
vlm_xlv_init_addr		equ		dword ptr [ebp - 36]					;адрес дворда, где хранится маска init для локальных переменных - инициализированные локал-вары;
vlm_xlv_used_addr		equ		dword ptr [ebp - 40]					;etc, где хранится маска used - локал-вары, которые можно юзать; 
vlm_xlv_alv_addr		equ		dword ptr [ebp - 44]					;etc, где хранится число активных локал-варов; 

vlm_tmp_var3			equ		dword ptr [ebp - 48]					;тут будем хранить маску init локал-варов
vlm_tmp_var4			equ		dword ptr [ebp - 52]					;used локал-варов
vlm_tmp_var5			equ		dword ptr [ebp - 56]					;число активных локал-варов
vlm_tmp_var6			equ		dword ptr [ebp - 60]					;индекс конкретного адреса локал-вара в буфере (массиве) адресов локал-варов; 

let_main:
	pushad
	mov		ebp, esp													;поделаем различные темы =)! 
	sub		esp, 64
	mov		ebx, vlm_struct1_addr
	assume	ebx: ptr XTG_TRASH_GEN
	mov		edx, vlm_struct2_addr
	assume	edx: ptr XTG_LOGIC_STRUCT
	mov		eax, [edx].xinstr_data_struct_addr
	mov		vlm_xids_addr, eax											;XTG_INSTR_DATA_STRUCT etc; 
	mov		eax, [edx].xinstr_pars_struct_addr
	mov		vlm_xips_addr, eax											;XTG_INSTR_PARS_STRUCT etc; 
	mov		eax, [edx].xregs_curv_struct_addr
	mov		vlm_xrcs_addr, eax											;XTG_REGS_CURV_STRUCT

	mov		eax, [edx].xlv_states_addr
	mov		vlm_xlv_states_addr, eax									;адреса буфера состояний локал-варов

	mov		eax, [edx].xlv_addr
	mov		vlm_xlv_addr, eax											;адрес буфера адресов локал-варов
	lea		ecx, dword ptr [eax + (vl_lv_num * 4)]
	mov		vlm_xlv_init_addr, ecx										;адрес маски init для локал-варов
	lea		ecx, dword ptr [eax + (vl_lv_num + 01) * 4]
	mov		vlm_xlv_used_addr, ecx										;used
	lea		ecx, dword ptr [eax + (vl_lv_num + 01 + 01) * 4]
	mov		vlm_xlv_alv_addr, ecx										;etc активных локал-варов; 

	call	vl_check_instr												;вызовем функу проверки и построения логики трэш-кода (трэш-команды); 

	mov		dword ptr [ebp + 1Ch], eax									;-1, 0 или 1; 
	mov		esp, ebp
	popad
	ret		04 * 2
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;конец функи let_main; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx





;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;вспомогательная (внутренняя) функа vl_check_instr; 
;проверка и построение логики инструкций;
;ВХОД:
;	ebx		-	XTG_TRASH_GEN
;	эта функа вызывается из let_main и юзает локал-вары let_main; 
;	etc;
;ВЫХОД:
;	(+)		-	аналогичный функе let_main; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
vl_check_instr:
	push	ecx															;сначала сохраним данные реги; 
	push	edx
	push	esi
	push	edi
	mov		ecx, vlm_xids_addr
	assume	ecx: ptr XTG_INSTR_DATA_STRUCT
	mov		edx, vlm_xips_addr
	assume	edx: ptr XTG_INSTR_PARS_STRUCT
	mov		eax, [ecx].flags
	and		[edx].param_3, 0 											;обнулим данное поле - обязательно для правильной работы vl_code_analyzer'a; 
																		;при необходимости конкретные конструкции сами выставят нужные значения в это поле; 

;--------------------------------------------[FLAGS]-----------------------------------------------------
	test	eax, eax
	je		vl_inc_dec___r32											;00
	dec		eax
	je		vl_not_neg___r32											;01
	dec		eax
	je		vl_mov_xchg___r32__r32										;02
	dec		eax
	je		vl_mov_xchg___r8__r8_imm8									;03
	dec		eax
	je		vl_mov___r32_r16__imm32_imm16								;04
	dec		eax
	je		vl_lea___r32___mso											;05
	dec		eax
	je		vl_adc_add_and_or_sbb_sub_xor___r32_r16__r32_r16			;06
	dec		eax
	je		vl_adc_add_and_or_sbb_sub_xor___r8__r8						;07
	dec		eax
	je		vl_adc_add_and_or_sbb_sub_xor___r32__imm32					;08
	dec		eax
	je		vl_adc_add_and_or_sbb_sub_xor___r32__imm8					;09
	dec		eax
	je		vl_adc_add_and_or_sbb_sub_xor___r8__imm8					;10
	dec		eax
	je		vl_rcl_rcr_rol_ror_shl_shr___r32__imm8						;11
	dec		eax															;12
	dec		eax
	je		vl_push_pop___imm8___r32									;13
	dec		eax
	je		vl_cmp___r32__r32											;14
	dec		eax
	je		vl_cmp___r32__imm8											;15
	dec		eax
	je		vl_cmp___r32__imm32											;16
	dec		eax
	je		vl_test___r32_r8__r32_r8 									;17
	dec		eax
	je		vl_jxx_short_down___rel8									;18
	dec		eax
	je		vl_jxx_near_down___rel32									;19
	dec		eax
	je		vl_jxx_up___rel8___rel32									;20
	dec		eax
	je		vl_jmp_down___rel8___rel32									;21
	dec		eax															;22
	dec		eax															;23
	dec		eax															;24
	dec		eax
;--------------------------------------------------------------------------------------------------------
	je		vl_mov___r32_m32__m32_r32									;25
	dec		eax
	je		vl_mov___m32__imm8_imm32									;26
	dec		eax
	je		vl_mov___r8_m8__m8_r8										;27
	dec		eax
	je		vl_inc_dec___m32											;28
	dec		eax
	je		vl_adc_add_and_or_sbb_sub_xor___r32__m32					;29
	dec		eax
	je		vl_adc_add_and_or_sbb_sub_xor___m32__r32					;30
	dec		eax
	je		vl_adc_add_and_or_sbb_sub_xor___r8_m8__m8_r8				;31
	dec		eax
	je		vl_adc_add_and_or_sbb_sub_xor___m32_m8__imm32_imm8			;32
	dec		eax
	je		vl_cmp___r32_m32__m32_r32									;33
	dec		eax
	je		vl_cmp___m32_m8__imm32_imm8									;34
;--------------------------------------------------------------------------------------------------------
	dec		eax
	je		vl_mov_lea___r32__m32ebpo8									;35
	dec		eax
	je		vl_mov___m32ebpo8__r32										;36
	dec		eax
	je		vl_mov___m32ebpo8__imm32									;37
	dec		eax
	je		vl_adc_add_and_or_sbb_sub_xor___r32__m32ebpo8				;38
	dec		eax
	je		vl_adc_add_and_or_sbb_sub_xor___m32ebpo8__r32				;39
	dec		eax
	je		vl_adc_add_and_or_sbb_sub_xor___m32ebpo8__imm32_imm8		;40
	dec		eax
	je		vl_cmp___r32_m32ebpo8__m32ebpo8_r32							;41
	dec		eax
	je		vl_cmp___m32ebpo8__imm32_imm8								;42
;--------------------------------------------------------------------------------------------------------
	dec		eax
	je		vl_xwinapi_func												;43
;--------------------------------------------------------------------------------------------------------
	sub		eax, 958
	je		vl_xif_prolog												;1001
	dec		eax
	je		vl_xif_param												;1002
	dec		eax
	je		vl_xif_call													;1003
	dec		eax
	je		vl_xif_epilog												;1004
;--------------------------------------------[FLAGS]----------------------------------------------------- 
	xor		eax, eax													;если встретилась неподдерживаемая конструкта, тогда вернём (в eax) -01; 
	dec		eax
;--------------------------------------------------------------------------------------------------------
_vlci_ret_: 
	pop		edi
	pop		esi
	pop		edx
	pop		ecx
	ret																	;на выход! 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;end of func vl_check_instr;
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx


	
;=========================================[INC/DEC REG32]================================================
vl_inc_dec___r32:
	mov		[edx].flags, (XTG_VL_INSTR_CHG + XTG_VL_P1_GET + XTG_VL_P1_REG)	
																		;указываю, что эта команда изменения значения параметра (1); 
																		;также, что 1 параметр - регистр, который получает значение (и больше ничего не задействовано (типо еще один рег и т.п.)); 
	mov		eax, [ecx].instr_addr
	movzx	eax, byte ptr [eax]											;берём опкод
	and		eax, 07														;получаем рег
	mov		[edx].param_1, eax											;и записываем его в param_1; 
	;and	[edx].param_3, 0											;обнуляем 3-ий параметр на всякий, так как мы его не юзаем в этой конструкции; 

	call	vl_emul_run_instr											;вызываем эмулятор - запуск команды в специальной среде; можно еще проверять и выходное значение eax после вызова данной функи; 

	call	vl_code_analyzer											;вызываем анализатор/корректор трэш-кода;

	jmp		_vlci_ret_
;=========================================[INC/DEC REG32]================================================



;=========================================[NOT/NEG REG32]================================================
vl_not_neg___r32:
	mov		[edx].flags, (XTG_VL_INSTR_CHG + XTG_VL_P1_GET + XTG_VL_P1_REG)
	mov		eax, [ecx].instr_addr
	movzx	eax, byte ptr [eax + 01] 									;etc 
	and		eax, 07 
	mov		[edx].param_1, eax 											;получаем рег и записываем его в указанный param_1; 

	call	vl_emul_run_instr

	call	vl_code_analyzer

	jmp		_vlci_ret_	
;=========================================[NOT/NEG REG32]================================================



;=====================================[MOV/XCHG REG32, REG32]============================================
vl_mov_xchg___r32__r32:
																		;реги не должны быть одинаковыми (везде, где это надо)! За этим следит xTG! (xtg.asm); 
	mov		[edx].flags, (XTG_VL_INSTR_INIT + XTG_VL_P1_GET + XTG_VL_P1_REG + XTG_VL_P2_GIVE + XTG_VL_P2_REG)
	mov		eax, [ecx].instr_addr
	cmp		byte ptr [eax], 8Bh											;mov reg32, reg32
	je		_vl_mov_r32_r32_
	mov		[edx].flags, (XTG_VL_INSTR_CHG + XTG_VL_P1_GET + XTG_VL_P1_REG + XTG_VL_P2_GIVE + XTG_VL_P2_GET + XTG_VL_P2_REG)
	cmp		byte ptr [eax], 87h											;xchg reg32, reg32
	je		_vl_xchg_r32_r32_

_vl_xchg_eax_r32_:														;xchg eax, reg32
	and		[edx].param_1, 0											;instr_size = 1; param_1 = 0 (eax); etc; 
	movzx	eax, byte ptr [eax]
	sub		eax, 90h
	mov		[edx].param_2, eax
	jmp		_vl_mx_r32_r32_nxt_1_

_vl_mov_r32_r32_:														;mov reg32, reg32
_vl_xchg_r32_r32_:														;xchg reg32, reg32
_vl_mx_r32_r32_gp_:														;instr_size = 2;
	movzx	eax, byte ptr [eax + 01]
	mov		esi, eax
	shr		esi, 03
	and		esi, 07 
	mov		[edx].param_1, esi
	and		eax, 07
	mov		[edx].param_2, eax

_vl_mx_r32_r32_nxt_1_:
	call	vl_emul_run_instr

	call	vl_code_analyzer 

	jmp		_vlci_ret_
;=====================================[MOV/XCHG REG32, REG32]============================================



;====================================[MOV/XCHG REG8, REG8/IMM8]==========================================
vl_mov_xchg___r8__r8_imm8:
	mov		eax, [ecx].instr_addr
	cmp		byte ptr [eax], 0B0h 
	jb		_vl_mov_xchg_r8r8_
	movzx	eax, byte ptr [eax]
	sub		eax, 0B0h
	cmp		eax, 04
	jl		_vlmxr8r8_nxt_0_
	sub		eax, 04														;если это ah/ch/dh/bh -> то это суть одного из регов eax/ecx/edx/ebx; 
_vlmxr8r8_nxt_0_:
	mov		[edx].param_1, eax											;mov reg8, imm8
	mov		[edx].flags, (XTG_VL_INSTR_CHG + XTG_VL_P1_GET + XTG_VL_P1_REG + XTG_VL_P2_GIVE + XTG_VL_P2_NUM)
	jmp		_vlmxr8_n1_

_vl_mov_xchg_r8r8_:
	cmp		byte ptr [eax], 8Ah 
	je		_vlmxr8r8_nxt_1_
	mov		[edx].flags, (XTG_VL_INSTR_CHG + XTG_VL_P1_GET + XTG_VL_P1_REG + XTG_VL_P2_GIVE + XTG_VL_P2_GET + XTG_VL_P2_REG)
	jmp		_vlmxr8r8_nxt_2_											;xchg reg8, reg8
_vlmxr8r8_nxt_1_:														;mov reg8, reg8
	mov		[edx].flags, (XTG_VL_INSTR_CHG + XTG_VL_P1_GET + XTG_VL_P1_REG + XTG_VL_P2_GIVE + XTG_VL_P2_REG)
_vlmxr8r8_nxt_2_:
	movzx	eax, byte ptr [eax + 01]
	mov		esi, eax
	shr		esi, 03
	and		esi, 07
	and		eax, 07
	cmp		esi, 04
	jl		_vlmxr8r8_nxt_3_
	sub		esi, 04
_vlmxr8r8_nxt_3_:
	cmp		eax, 04														;al
	jl		_vlmxr8r8_nxt_4_
	sub		eax, 04
_vlmxr8r8_nxt_4_:
	cmp		eax, esi													;но если скажем попалась команда типа mov al,ah -> используются разные части одного рега EAX, поэтому для таких ситуаций свои флаги! 
	jne		_vlmxr8r8_nxt_5_
	mov		[edx].flags, (XTG_VL_INSTR_CHG + XTG_VL_P1_GET + XTG_VL_P1_REG)
_vlmxr8r8_nxt_5_:
	mov		[edx].param_1, esi
	mov		[edx].param_2, eax

_vlmxr8_n1_:
	call	vl_emul_run_instr 

	call	vl_code_analyzer 

	jmp		_vlci_ret_													;на выход! 
;====================================[MOV/XCHG REG8, REG8/IMM8]==========================================


 
;==================================[MOV REG32/REG16, IMM32/IMM16]========================================
vl_mov___r32_r16__imm32_imm16:
	mov		[edx].flags, (XTG_VL_INSTR_INIT + XTG_VL_P1_GET + XTG_VL_P1_REG + XTG_VL_P2_GIVE + XTG_VL_P2_NUM)
																		;etc - команда инициализации параметра (1)
																		;1 параметр - получает значение и этот 1 парам - рег;
																		;2 параметр - число, отдает значение; 
	mov		eax, [ecx].instr_addr
	cmp		byte ptr [eax], 66h
	jne		_vl_movr3216_imm3216_nxt_1_
	mov		[edx].flags, (XTG_VL_INSTR_CHG + XTG_VL_P1_GET + XTG_VL_P1_REG + XTG_VL_P2_GIVE + XTG_VL_P2_NUM)
	inc		eax															;если есть префикс 66h, тогда это будет команда изменения значения параметра; 
	movzx	esi, word ptr [eax + 01]
	jmp		_vl_movr3216_imm3216_nxt_2_
_vl_movr3216_imm3216_nxt_1_:
	mov		esi, dword ptr [eax + 01]
_vl_movr3216_imm3216_nxt_2_:
	mov		[edx].param_2, esi											;number
	movzx	esi, byte ptr [eax]
	sub		esi, 0B8h
	mov		[edx].param_1, esi											;reg (1); 

	call	vl_emul_run_instr

	call	vl_code_analyzer

	jmp		_vlci_ret_
;==================================[MOV REG32/REG16, IMM32/IMM16]========================================
	


;====================================[LEA MODRM SIB OFFSET]==============================================
vl_lea___r32___mso:
	mov		[edx].flags, (XTG_VL_INSTR_INIT + XTG_VL_P1_GET + XTG_VL_P1_REG + XTG_VL_P2_GIVE + XTG_VL_P2_NUM)
	mov		eax, [ecx].instr_addr 
	movzx	esi, byte ptr [eax + 01]
	push	esi
	shr		esi, 03
	and		esi, 07
	mov		[edx].param_1, esi
	pop		esi
	push	esi
	shr		esi, 06
	cmp		esi, 00
	pop		esi
	je		_vl_lr32mso_nxt_1_
	and		esi, 07
	cmp		[edx].param_1, esi
	jne		_vl_lr32mso_othr_1_
	mov		[edx].flags, (XTG_VL_INSTR_CHG + XTG_VL_P1_GET + XTG_VL_P1_REG + XTG_VL_P2_GIVE + XTG_VL_P2_NUM)
_vl_lr32mso_othr_1_:
	bts		[edx].param_3, esi
	jmp		_vl_lr32mso_nxt_2_

_vl_lr32mso_nxt_1_:
_vl_lr32mso_sib_:
	movzx	eax, byte ptr [eax + 02]
	mov		esi, eax
	shr		esi, 03
	and		esi, 07
	and		eax, 07
	bts		[edx].param_3, esi
	bts		[edx].param_3, eax
	cmp		[edx].param_1, esi
	jne		_vl_lr32mso_othr_2_
	mov		[edx].flags, (XTG_VL_INSTR_CHG + XTG_VL_P1_GET + XTG_VL_P1_REG + XTG_VL_P2_GIVE + XTG_VL_P2_NUM)
_vl_lr32mso_othr_2_:
	cmp		[edx].param_1, eax
	jne		_vl_lr32mso_nxt_2_
	mov		[edx].flags, (XTG_VL_INSTR_CHG + XTG_VL_P1_GET + XTG_VL_P1_REG + XTG_VL_P2_GIVE + XTG_VL_P2_NUM)

_vl_lr32mso_nxt_2_:
	call	vl_emul_run_instr

	call	vl_code_analyzer

	jmp		_vlci_ret_
;====================================[LEA MODRM SIB OFFSET]==============================================



;=======================[ADC/ADD/AND/OR/SBB/SUB/XOR REG32/REG16, REG32/REG16]============================
vl_adc_add_and_or_sbb_sub_xor___r32_r16__r32_r16:
	mov		[edx].flags, (XTG_VL_INSTR_CHG + XTG_VL_P1_GET + XTG_VL_P1_REG + XTG_VL_P2_GIVE + XTG_VL_P2_REG)
																		;add ecx, edx etc;
																		;XTG_VL_INSTR_CHG - это команда изменения параметра(ов);
																		;XTG_VL_P1_GET - первый параметр - получает значение;
																		;XTG_VL_P1_REG - первый парам - рег;
																		;XTG_VL_P2_GIVE - второй парам - передаёт своё значение;
																		;XTG_VL_P2_REG - второй парам - рег; 
																		;такая маска, например, для add/sub/xor/etc reg32_1, reg32_2 -> reg32_1 != reg32_2; 
																		;etc 
	mov		eax, [ecx].instr_addr
	cmp		byte ptr [eax], 66h
	jne		_vl_aaaossxr3216_r3216_nxt_1_
	inc		eax
_vl_aaaossxr3216_r3216_nxt_1_:
	push	eax
	movzx	eax, byte ptr [eax + 01]
	mov		esi, eax
	shr		esi, 03
	and		esi, 07
	and		eax, 07
	mov		[edx].param_1, esi
	mov		[edx].param_2, eax
	pop		eax
	cmp		esi, [edx].param_2											;if reg32_1 == reg32_2
	jne		_vl_aaaossxr3216_r3216_nxt_2_
	cmp		[ecx].instr_size, 03										;если есть префикс 66h, тогда это команда изменения значения параметра
	je		_vl_aaaossxr3216_r3216_nxt_3_
	cmp		byte ptr [eax], 33h											;иначе если это xor eax,eax и т.п., тогда это команда инициализации параметра
	je		_vl_aaaossxr3216_r3216_nxt_2_1_
	cmp		byte ptr [eax], 2Bh											;иначе если это sub ecx,ecx etc -> тоже инициализация; 
	jne		_vl_aaaossxr3216_r3216_nxt_3_
_vl_aaaossxr3216_r3216_nxt_2_1_:
	mov		[edx].flags, (XTG_VL_INSTR_INIT + XTG_VL_P1_GET + XTG_VL_P1_REG)
	jmp		_vl_aaaossxr3216_r3216_nxt_2_
_vl_aaaossxr3216_r3216_nxt_3_:
	mov		[edx].flags, (XTG_VL_INSTR_CHG + XTG_VL_P1_GET + XTG_VL_P1_REG)

_vl_aaaossxr3216_r3216_nxt_2_:
	call	vl_emul_run_instr

	call	vl_code_analyzer

	jmp		_vlci_ret_
;=======================[ADC/ADD/AND/OR/SBB/SUB/XOR REG32/REG16, REG32/REG16]============================



;============================[ADC/ADD/AND/OR/SBB/SUB/XOR REG8, REG8]=====================================
vl_adc_add_and_or_sbb_sub_xor___r8__r8:
	mov		[edx].flags, (XTG_VL_INSTR_CHG + XTG_VL_P1_GET + XTG_VL_P1_REG + XTG_VL_P2_GIVE + XTG_VL_P2_REG)
	mov		eax, [ecx].instr_addr
	movzx	eax, byte ptr [eax + 01]
	mov		esi, eax
	shr		esi, 03
	and		esi, 07
	and		eax, 07
	cmp		esi, 04
	jl		_vaaaossx_r8r8_nxt_1_
	sub		esi, 04
_vaaaossx_r8r8_nxt_1_:
	cmp		eax, 04
	jl		_vaaaossx_r8r8_nxt_2_
	sub		eax, 04
_vaaaossx_r8r8_nxt_2_:
	mov		[edx].param_1, esi
	mov		[edx].param_2, eax
	cmp		esi, eax
	jne		_vaaaossx_r8r8_nxt_3_
	mov		[edx].flags, (XTG_VL_INSTR_CHG + XTG_VL_P1_GET + XTG_VL_P1_REG)

_vaaaossx_r8r8_nxt_3_:
	call	vl_emul_run_instr

	call	vl_code_analyzer

	jmp		_vlci_ret_
;============================[ADC/ADD/AND/OR/SBB/SUB/XOR REG8, REG8]=====================================



;===========================[ADC/ADD/AND/OR/SBB/SUB/XOR REG32, IMM32]====================================
;===========================[ADC/ADD/AND/OR/SBB/SUB/XOR REG32, IMM8]=====================================
;============================[RCL/RCR/ROL/ROR/SHL/SHR REG32, IMM8]=======================================
vl_adc_add_and_or_sbb_sub_xor___r32__imm32:
vl_adc_add_and_or_sbb_sub_xor___r32__imm8:
vl_rcl_rcr_rol_ror_shl_shr___r32__imm8:
	and		[edx].param_1, 0
	mov		[edx].flags, (XTG_VL_INSTR_CHG + XTG_VL_P1_GET + XTG_VL_P1_REG + XTG_VL_P2_GIVE + XTG_VL_P2_NUM)
	mov		eax, [ecx].instr_addr
	cmp		byte ptr [eax], 81h
	je		_vaaaosx_ri32_nxt_1_ 
	cmp		byte ptr [eax], 83h
	je		_vaaaosx_ri32_nxt_1_
	cmp		byte ptr [eax], 0C1h
	je		_vaaaosx_ri32_nxt_1_
	cmp		byte ptr [eax], 0D1h
	jne		_vaaaosx_ri32_nxt_2_
_vaaaosx_ri32_nxt_1_:
	movzx	eax, byte ptr [eax + 01]
	and		eax, 07 ;al
	mov		[edx].param_1, eax

_vaaaosx_ri32_nxt_2_:
	call	vl_emul_run_instr

	call	vl_code_analyzer

	jmp		_vlci_ret_
;===========================[ADC/ADD/AND/OR/SBB/SUB/XOR REG32, IMM32]====================================
;===========================[ADC/ADD/AND/OR/SBB/SUB/XOR REG32, IMM8]=====================================
;============================[RCL/RCR/ROL/ROR/SHL/SHR REG32, IMM8]=======================================



;===========================[ADC/ADD/AND/OR/SBB/SUB/XOR REG8, IMM8]====================================== 
vl_adc_add_and_or_sbb_sub_xor___r8__imm8:
	and		[edx].param_1, 0
	mov		[edx].flags, (XTG_VL_INSTR_CHG + XTG_VL_P1_GET + XTG_VL_P1_REG + XTG_VL_P2_GIVE + XTG_VL_P2_NUM)
	mov		eax, [ecx].instr_addr
	cmp		byte ptr [eax], 80h
	jne		_vaaaossx_rimm8_nxt_1_
	movzx	eax, byte ptr [eax + 01]
	and		eax, 07
	cmp		eax, 04
	jl		_vaaaossx_rimm8_nxt_2_
	sub		eax, 04
_vaaaossx_rimm8_nxt_2_:
	mov		[edx].param_1, eax

_vaaaossx_rimm8_nxt_1_:
	call	vl_emul_run_instr

	call	vl_code_analyzer

	jmp		_vlci_ret_
;===========================[ADC/ADD/AND/OR/SBB/SUB/XOR REG8, IMM8]======================================



;=====================================[PUSH IMM8   POP REG32]============================================
vl_push_pop___imm8___r32:
	mov		eax, [ecx].instr_addr
	cmp		byte ptr [eax], 6Ah
	je		_vpush_6ah_
	xor		eax, eax
	inc		eax
	jmp		_vlci_ret_
;--------------------------------------------------------------------------------------------------------
_vpush_6ah_:
	xor		eax, eax 
	mov		[edx].flags, (XTG_VL_INSTR_INIT + XTG_VL_P1_GET + XTG_VL_P1_REG + XTG_VL_P2_GIVE + XTG_VL_P2_NUM)
	mov		esi, [ecx].param_1
	and		esi, 07
	mov		[edx].param_1, esi
	xchg	eax, esi
	mov		edx, vlm_struct2_addr
	assume	edx: ptr XTG_LOGIC_STRUCT
	mov		edi, [edx].instr_buf_addr
	mov		esi, [ecx].instr_addr
	mov		edx, [ecx].instr_size
	inc		[ecx].instr_size
	push	esi
	push	edx
	push	ecx
	push	edx
	add		edi, vl_instr_buf_size
	sub		edi, [ecx].instr_size
	mov		[ecx].instr_addr, edi
	pop		ecx
	rep		movsb
	add		al, 58h 
	stosb

	call	vl_emul_run_instr

	call	vl_code_analyzer

	pop		ecx
	assume	ecx: ptr XTG_INSTR_DATA_STRUCT
	assume	edx: ptr XTG_INSTR_PARS_STRUCT
	pop		[ecx].instr_size
	pop		[ecx].instr_addr

	jmp		_vlci_ret_
;=====================================[PUSH IMM8   POP REG32]============================================
	


;=====================================[CMP REG32, REG32]=================================================
;=====================================[CMP REG32, IMM8]==================================================
;=====================================[CMP REG32, IMM32]=================================================
vl_cmp___r32__r32:
vl_cmp___r32__imm8: 
vl_cmp___r32__imm32:
	mov		[edx].flags, (XTG_VL_INSTR_CHG + XTG_VL_P2_GIVE + XTG_VL_P2_NUM)
	mov		esi, [ecx].instr_addr
	movzx	eax, byte ptr [esi + 01]
	
	cmp		byte ptr [esi], 3Bh
	je		_vcmprr32_
	cmp		byte ptr [esi], 83h
	je		_vcmpr32imm8_
	cmp		byte ptr [esi], 81h
	je		_vcmpr32imm32_
	cmp		byte ptr [esi], 3Dh
	je		_vcmpeaximm32_
																		;
_vcmpeaximm32_:
	xor		eax, eax
_vcmpr32imm8_:
_vcmpr32imm32_: 
	and		eax, 07
	bts		[edx].param_3, eax
	jmp		_vcmpri_nxt_1_

_vcmprr32_:
	mov		esi, eax
	shr		esi, 03
	and		esi, 07
	and		eax, 07
	bts		[edx].param_3, esi
	bts		[edx].param_3, eax
	                        
_vcmpri_nxt_1_:
	call	vl_emul_run_instr

	call	vl_code_analyzer

	jmp		_vlci_ret_
;=====================================[CMP REG32, REG32]=================================================
;=====================================[CMP REG32, IMM8]==================================================
;=====================================[CMP REG32, IMM32]=================================================



;================================[TEST REG32/REG8, REG32/REG8]===========================================	
vl_test___r32_r8__r32_r8:
	mov		[edx].flags, (XTG_VL_INSTR_CHG + XTG_VL_P2_GIVE + XTG_VL_P2_NUM)
	mov		edi, [ecx].instr_addr
	mov		eax, dword ptr [edi + 01]
	mov		esi, eax
	shr		esi, 03
	and		esi, 07
	and		eax, 07
	cmp		byte ptr [edi], 85h
	je		_vtest_r328_nxt_1_
	cmp		esi, 04
	jl		_vtest_r328_nxt_2_
	sub		esi, 04
_vtest_r328_nxt_2_:
	cmp		eax, 04
	jl		_vtest_r328_nxt_1_
	sub		eax, 04
_vtest_r328_nxt_1_:
	bts		[edx].param_3, esi
	bts		[edx].param_3, eax

	call	vl_emul_run_instr

	call	vl_code_analyzer

	jmp		_vlci_ret_
;================================[TEST REG32/REG8, REG32/REG8]===========================================
	


;====================================[JXX_SHORT_DOWN REL8]===============================================
;====================================[JXX_NEAR_DOWN REL32]===============================================
;====================================[JMP_DOWN REL8/REL32]===============================================
vl_jxx_short_down___rel8:
vl_jxx_near_down___rel32:
vl_jmp_down___rel8___rel32:
	xor		eax, eax
	mov		ecx, vlm_xrcs_addr
	assume	ecx: ptr XTG_REGS_CURV_STRUCT
	test	[ecx].regs_used, 11001111b
	je		_vlci_ret_
	inc		eax
	jmp		_vlci_ret_
;====================================[JXX_SHORT_DOWN REL8]===============================================
;====================================[JXX_NEAR_DOWN REL32]===============================================
;====================================[JMP_DOWN REL8/REL32]===============================================



;=====================================[JXX_UP REL8/REL32]================================================
vl_jxx_up___rel8___rel32:
	xor		eax, eax
	assume	ecx: ptr XTG_INSTR_DATA_STRUCT
	mov		esi, [ecx].param_1
	and		esi, 07
	mov		ecx, vlm_xrcs_addr
	assume	ecx: ptr XTG_REGS_CURV_STRUCT
	bt		[ecx].regs_init, esi
	jc		_vlci_ret_
	bt		[ecx].regs_used, esi
	jnc		_vlci_ret_
	inc		eax
	jmp		_vlci_ret_ 
;=====================================[JXX_UP REL8/REL32]================================================



;================================[MOV REG32/MEM32, MEM32/REG32]==========================================
vl_mov___r32_m32__m32_r32:
	assume	ecx: ptr XTG_INSTR_DATA_STRUCT
	push	01 
	pop		esi
	and		[edx].param_1, 0
	and		[edx].param_2, 0
	mov		[edx].flags, (XTG_VL_INSTR_INIT + XTG_VL_P1_GET + XTG_VL_P1_REG) 
	mov		edi, [ecx].instr_addr
	
	cmp		byte ptr [edi], 0A1h
	je		_vmrmmr32_nxt_1_
	cmp		byte ptr [edi], 0A3h
	je		_vmrmmr32_nxt_2_
	inc		esi
	movzx	eax, byte ptr [edi + 01]
	shr		eax, 03
	and		eax, 07
	mov		[edx].param_1, eax
	mov		[edx].param_2, eax
	cmp		byte ptr [edi], 8Bh
	je		_vmrmmr32_nxt_1_
_vmrmmr32_nxt_2_:	
	mov		[edx].flags, (XTG_VL_INSTR_INIT + XTG_VL_P2_GIVE + XTG_VL_P2_REG)

_vmrmmr32_nxt_1_:
	lea		eax, dword ptr [edi + esi]
	call	vl_chk_crct_instr_m
	
	jmp		_vlci_ret_
;================================[MOV REG32/MEM32, MEM32/REG32]==========================================



;===================================[MOV MEM32, IMM8/IMM32]==============================================
;=======================================[INC/DEC MEM32]==================================================
;======================[ADC/ADD/AND/OR/SBB/SUB/XOR MEM32/MEM8, IMM32/IMM8]===============================
;=================================[CMP MEM32/MEM8, IMM32/IMM8]=========================================== 
vl_mov___m32__imm8_imm32:
vl_inc_dec___m32:;для неё не важно, инит или чендж - так как нам важно просто проэмулить ее - команда полюбасу пройдет проверку =) 
vl_adc_add_and_or_sbb_sub_xor___m32_m8__imm32_imm8:
vl_cmp___m32_m8__imm32_imm8:
	mov		eax, [ecx].instr_addr
	inc		eax 
	inc		eax 
	mov		[edx].flags, (XTG_VL_INSTR_INIT)

	call	vl_chk_crct_instr_m 

	jmp		_vlci_ret_
;===================================[MOV MEM32, IMM8/IMM32]==============================================
;=======================================[INC/DEC MEM32]==================================================
;======================[ADC/ADD/AND/OR/SBB/SUB/XOR MEM32/MEM8, IMM32/IMM8]===============================
;=================================[CMP MEM32/MEM8, IMM32/IMM8]=========================================== 



;==================================[MOV REG8/MEM8, MEM8/REG8]============================================	
vl_mov___r8_m8__m8_r8:
	assume	ecx: ptr XTG_INSTR_DATA_STRUCT
	push	01 
	pop		esi
	and		[edx].param_1, 0
	and		[edx].param_2, 0
	mov		[edx].flags, (XTG_VL_INSTR_CHG + XTG_VL_P1_GET + XTG_VL_P1_REG) 
	mov		edi, [ecx].instr_addr
	
	cmp		byte ptr [edi], 0A0h
	je		_vmrmmr8_nxt_1_
	cmp		byte ptr [edi], 0A2h
	je		_vmrmmr8_nxt_2_
	inc		esi 
	movzx	eax, byte ptr [edi + 01]
	shr		eax, 03
	and		eax, 07
	cmp		eax, 04
	jl		_vmrmmr8_nxt_3_
	sub		eax, 04
_vmrmmr8_nxt_3_:
	mov		[edx].param_1, eax
	mov		[edx].param_2, eax
	cmp		byte ptr [edi], 8Ah
	je		_vmrmmr8_nxt_1_
_vmrmmr8_nxt_2_:	
	mov		[edx].flags, (XTG_VL_INSTR_CHG + XTG_VL_P2_GIVE + XTG_VL_P2_REG)

_vmrmmr8_nxt_1_:
	lea		eax, dword ptr [edi + esi]
	call	vl_chk_crct_instr_m
	
	jmp		_vlci_ret_
;==================================[MOV REG8/MEM8, MEM8/REG8]============================================



;==========================[ADC/ADD/AND/OR/SBB/SUB/XOR REG32, MEM32]=====================================
vl_adc_add_and_or_sbb_sub_xor___r32__m32:
	mov		[edx].flags, (XTG_VL_INSTR_CHG + XTG_VL_P1_GET + XTG_VL_P1_REG)
	mov		eax, [ecx].instr_addr
	movzx	esi, byte ptr [eax + 01]
	shr		esi, 03
	and		esi, 07
	mov		[edx].param_1, esi
	inc		eax 
	inc		eax

	call	vl_chk_crct_instr_m

	jmp		_vlci_ret_
;==========================[ADC/ADD/AND/OR/SBB/SUB/XOR REG32, MEM32]=====================================



;==========================[ADC/ADD/AND/OR/SBB/SUB/XOR MEM32, REG32]=====================================
vl_adc_add_and_or_sbb_sub_xor___m32__r32:
	mov		[edx].flags, (XTG_VL_INSTR_CHG + XTG_VL_P2_GIVE + XTG_VL_P2_REG)
	mov		eax, [ecx].instr_addr
	movzx	esi, byte ptr [eax + 01]
	shr		esi, 03
	and		esi, 07
	mov		[edx].param_2, esi
	inc		eax 
	inc		eax

	call	vl_chk_crct_instr_m

	jmp		_vlci_ret_
;==========================[ADC/ADD/AND/OR/SBB/SUB/XOR MEM32, REG32]=====================================



;=======================[ADC/ADD/AND/OR/SBB/SUB/XOR REG8/MEM8, MEM8/REG8]================================
vl_adc_add_and_or_sbb_sub_xor___r8_m8__m8_r8:
	mov		[edx].flags, (XTG_VL_INSTR_CHG + XTG_VL_P1_GET + XTG_VL_P1_REG)
	mov		eax, [ecx].instr_addr
	movzx	esi, byte ptr [eax + 01]
	shr		esi, 03
	and		esi, 07
	cmp		esi, 04
	jl		_vaaaossxrmmr8_nxt_1_
	sub		esi, 04
_vaaaossxrmmr8_nxt_1_:
	mov		[edx].param_1, esi
	mov		[edx].param_2, esi
	movzx	edi, byte ptr [eax]
	inc		eax 
	inc		eax
	and		edi, 03
	test	edi, edi
	jne		_vaaaossxrmmr8_nxt_2_
	mov		[edx].flags, (XTG_VL_INSTR_CHG + XTG_VL_P2_GIVE + XTG_VL_P2_REG)

_vaaaossxrmmr8_nxt_2_:
	call	vl_chk_crct_instr_m

	jmp		_vlci_ret_
;=======================[ADC/ADD/AND/OR/SBB/SUB/XOR REG8/MEM8, MEM8/REG8]================================



;================================[CMP REG32/MEM32, MEM32/REG32]==========================================
vl_cmp___r32_m32__m32_r32:
	mov		eax, [ecx].instr_addr
	movzx	esi, byte ptr [eax + 01]
	shr		esi, 03
	and		esi, 07
	mov		[edx].param_2, esi
	mov		[edx].flags, (XTG_VL_INSTR_CHG + XTG_VL_P2_GIVE + XTG_VL_P2_REG)
	inc		eax 
	inc		eax

	call	vl_chk_crct_instr_m

	jmp		_vlci_ret_
;================================[CMP REG32/MEM32, MEM32/REG32]==========================================



;=============================[MOV/LEA REG32, DWORD PTR [ebp +- XXh]]==================================== 
;==============================[MOV DWORD PTR [ebp +- XXh], REG32]======================================= 
;====================[ADC/ADD/AND/OR/SBB/SUB/XOR REG32, DWORD PTR [ebp +- XXh]]========================== 
;====================[ADC/ADD/AND/OR/SBB/SUB/XOR DWORD PTR [ebp +- XXh], REG32]==========================
vl_mov_lea___r32__m32ebpo8:	
vl_mov___m32ebpo8__r32:
vl_adc_add_and_or_sbb_sub_xor___r32__m32ebpo8:
vl_adc_add_and_or_sbb_sub_xor___m32ebpo8__r32:
	mov		[edx].flags, (XTG_VL_INSTR_INIT + XTG_VL_P1_GET + XTG_VL_P1_REG + XTG_VL_P2_GIVE + XTG_VL_P2_ADDR) 
	mov		eax, [ecx].instr_addr

	push	eax
	call	processing_lv_addr
	xchg	eax, edi
	pop		eax

	mov		[edx].param_2, edi

	movzx	esi, byte ptr [eax + 01] 
	shr		esi, 03
	and		esi, 07
	mov		[edx].param_1, esi

	movzx	ecx, byte ptr [eax] 
	cmp		cl, 8Bh
	je		_viic_nxt_3_
	mov		[edx].flags, (XTG_VL_INSTR_INIT + XTG_VL_P1_GET + XTG_VL_P1_REG)
	cmp		cl, 8Dh
	je		_viic_nxt_3_
	mov		[edx].flags, (XTG_VL_INSTR_INIT + XTG_VL_P1_GET + XTG_VL_P1_ADDR + XTG_VL_P2_GIVE + XTG_VL_P2_REG)
	cmp		cl, 89h
	je		_viic_nxt_4_
	mov		[edx].flags, (XTG_VL_INSTR_CHG + XTG_VL_P1_GET + XTG_VL_P1_REG + XTG_VL_P2_GIVE + XTG_VL_P2_ADDR)
	and		cl, 03
	cmp		cl, 03
	je		_viic_nxt_3_
	mov		[edx].flags, (XTG_VL_INSTR_CHG + XTG_VL_P1_GET + XTG_VL_P1_ADDR + XTG_VL_P2_GIVE + XTG_VL_P2_REG)

_viic_nxt_4_:
	mov		[edx].param_1, edi
	mov		[edx].param_2, esi

_viic_nxt_3_:
	call	vl_emul_run_instr

	call	vl_code_analyzer

	jmp		_vlci_ret_
;=============================[MOV/LEA REG32, DWORD PTR [ebp +- XXh]]====================================
;==============================[MOV DWORD PTR [ebp +- XXh], REG32]======================================= 
;====================[ADC/ADD/AND/OR/SBB/SUB/XOR REG32, DWORD PTR [ebp +- XXh]]==========================
;====================[ADC/ADD/AND/OR/SBB/SUB/XOR DWORD PTR [ebp +- XXh], REG32]==========================



;==============================[MOV DWORD PTR [ebp +- XXh], IMM32]=======================================
;==================[ADC/ADD/AND/OR/SBB/SUB/XOR DWORD PTR [ebp +- XXh], IMM32/IMM8]=======================
vl_mov___m32ebpo8__imm32:
vl_adc_add_and_or_sbb_sub_xor___m32ebpo8__imm32_imm8:
	mov		[edx].flags, (XTG_VL_INSTR_INIT + XTG_VL_P1_GET + XTG_VL_P1_ADDR)
	mov		eax, [ecx].instr_addr
	cmp		byte ptr [eax], 0C7h
	je		_vmaaaossxm32ebpo8_i832_nxt_1_
	mov		[edx].flags, (XTG_VL_INSTR_CHG + XTG_VL_P1_GET + XTG_VL_P1_ADDR)

_vmaaaossxm32ebpo8_i832_nxt_1_:
	call	processing_lv_addr

	mov		[edx].param_1, eax 

	call	vl_emul_run_instr

	call	vl_code_analyzer

	jmp		_vlci_ret_
;==============================[MOV DWORD PTR [ebp +- XXh], IMM32]=======================================
;==================[ADC/ADD/AND/OR/SBB/SUB/XOR DWORD PTR [ebp +- XXh], IMM32/IMM8]=======================



;==================[CMP REG32/DWORD PTR [EBP +- XXh], DWORD PTR [EBP +- XXh]/REG32]======================
vl_cmp___r32_m32ebpo8__m32ebpo8_r32:
	mov		eax, [ecx].instr_addr
	movzx	esi, byte ptr [eax + 01]
	shr		esi, 03
	and		esi, 07
	
	call	processing_lv_addr

	mov		[edx].flags, (XTG_VL_INSTR_CHG + XTG_VL_P1_GIVE + XTG_VL_P1_REG + XTG_VL_P2_GIVE + XTG_VL_P2_ADDR)
	mov		[edx].param_1, esi 
	mov		[edx].param_2, eax

	call	vl_emul_run_instr

	call	vl_code_analyzer

	jmp		_vlci_ret_
;==================[CMP REG32/DWORD PTR [EBP +- XXh], DWORD PTR [EBP +- XXh]/REG32]======================



;===========================[CMP DWORD PTR [EBP +- XXh], IMM32/IMM8]=====================================
vl_cmp___m32ebpo8__imm32_imm8:
	mov		[edx].flags, (XTG_VL_INSTR_CHG + XTG_VL_P2_GIVE + XTG_VL_P2_ADDR)
	mov		eax, [ecx].instr_addr 

	call	processing_lv_addr

	mov		[edx].param_2, eax 

	call	vl_emul_run_instr

	call	vl_code_analyzer

	jmp		_vlci_ret_
;===========================[CMP DWORD PTR [EBP +- XXh], IMM32/IMM8]=====================================
	


;=====================================[FAKE WINAPI FUNC]=================================================
vl_xwinapi_func:														;проверка передаваемых параметров в винапишку; 
	mov		edi, [ecx].instr_addr

_vwf_cycle_:
	cmp		word ptr [edi], 15FFh										;мы дошли до вызова винапи? (call dword ptr [<addr?]) (это если мы проврили все парамы или их не было вообще); 
	je		_vwf_crct_fields_											;тогда прыгаем дальше
	cmp		byte ptr [edi], 6Ah											;иначе проверяем парамы: это push imm8?
	jne		_vwfc_nxt_1_
	inc		edi															;если так, то он однозначно проходит проверку (нет ни регов, ни адресов etc - что следует провреить) - передвигаемся на длину этой команды и прыгаем на проверку следующей команды; 
	inc		edi
	jmp		_vwf_cycle_
_vwfc_nxt_1_:
	cmp		byte ptr [edi], 68h											;это push imm32? если так, то аналогично, этот параметр проходит проверку и мы прыгаем дальше; 
	jne		_vwfc_nxt_2_
	add		edi, 05 
	jmp		_vwf_cycle_
_vwfc_nxt_2_:
	cmp		word ptr [edi], 75FFh										;или это push [ebp +- XXh]?
	jne		_vwfc_nxt_3_												;если это не так, то проверяем дальше
	mov		eax, edi													;иначе получим адрес локальной переменной/входного парама
	add		edi, 03														;edi корректируем на следующую команду (размер этой команды = 3 байта); 
	call	processing_lv_addr											;получаем адрес (и если нужно, обрабатываем этот адрес); 
	mov		[edx].flags, (XTG_VL_INSTR_CHG + XTG_VL_P2_GIVE + XTG_VL_P2_ADDR)
																		;выставляем соотв-щие флаги;
	mov		[edx].param_2, eax											;сохраняем в нужном поле полученный адрес локал-вара/входного парама; 
	jmp		_vwfc_ca_													;и прыгаем на проверку параметра (для винапи); 
_vwfc_nxt_3_:
	cmp		word ptr [edi], 35FFh										;или это push dword ptr [<addr>]?
	jne		_vwfc_nxt_4_												;
	add		edi, 06														;если это так, то такой параметр тоже нам подходит (значения по этим адресам всегда можно считать проинициализированными, и за ними не ведется проверка - она и не нужна); 
	jmp		_vwf_cycle_
_vwfc_nxt_4_:
	xor		eax, eax													;eax = 0; 
	cmp		byte ptr [edi], 50h											;если же байт < 50h, тогда это неподдерживаемый парам и мы выходим и возвращаем 0;
	jb		_vlci_ret_
	cmp		byte ptr [edi], 57h											;аналогично и тут, только если байт > 57h; 
	ja		_vlci_ret_
	movzx	eax, byte ptr [edi]											;иначе это команда push reg32
	and		eax, 07														;получаем рег
	inc		edi 														;корректируем edi на следующую команду
	mov		[edx].flags, (XTG_VL_INSTR_CHG + XTG_VL_P2_GIVE + XTG_VL_P2_REG)
																		;ставим нужные атрибуты
	mov		[edx].param_2, eax											;сохраняем в соотв-щее поле номер рега; 
	
_vwfc_ca_:
	call	vl_code_analyzer											;и вызываем анализатор кода (в данном случае эмуляция не нужна, мы просто проверим команду (параметр) - подходит ли она трэш-коду по логике); 
	test	eax, eax
	jne		_vwf_cycle_													;если да, тогда всё ок, продолжаем анализировать остальные параметры; 
	jmp		_vlci_ret_													;иначе выходим;
_vwf_crct_fields_:														;а сюда мы попадаем, если все параметры пошли проверку (или их вообще не было); 
	mov		ecx, vlm_xrcs_addr											;тогда винапишка сгенеренная винапишка прошла проверку и мы её оставим
	assume	ecx: ptr XTG_REGS_CURV_STRUCT
	and		[ecx].regs_init, 11111000b									;сбросим в этой маске eax, ecx, edx - их можно заново инициализировать; 
	and		[ecx].regs_used, 11111001b									;в этой маске сбросим ecx, edx - их нельзя юзать;
	or		[ecx].regs_used, 00000001b									;и выставим в этой маске eax;
																		;в итоге, получаем следующее: 
																		;eax можно инициализировать и в то же время использовать в командах add reg32, reg32 и др.;
																		;ecx & edx можно только инициализиовать, и в других командах без инициализации нельзя будет юзать; 
	xor		eax, eax
	inc		eax 														;eax = 1;
	jmp		_vlci_ret_													;на выход; 
;=====================================[FAKE WINAPI FUNC]=================================================



;===============================[FUNC PROLOG/PARAM/CALL/EPILOG]==========================================
vl_xif_prolog:															;prolog
	call	vl_emul_run_instr											;эмулируем пролог нашей функи
	xor		eax, eax
	inc		eax															;eax = 1;
	jmp		_vlci_ret_													;на выход;
;--------------------------------------------------------------------------------------------------------
vl_xif_param:															;param; 
	assume	ecx: ptr XTG_INSTR_DATA_STRUCT								;проэмулим и проверим передаваемые параметры в функу; 
	mov		[edx].flags, (XTG_VL_INSTR_CHG + XTG_VL_P2_GIVE + XTG_VL_P2_NUM)
	xor		eax, eax
	mov		edi, [ecx].instr_addr
	cmp		byte ptr [edi], 6Ah											;push imm8
	je		_vxp_emul_
	cmp		byte ptr [edi], 68h											;push imm32;
	je		_vxp_emul_
	cmp		word ptr [edi], 35FFh										;push dword ptr [<addr>]
	je		_vxp_emul_
	cmp		word ptr [edi], 75FFh										;push dword ptr [ebp +- XXh]
	jne		_vxp_nxt_1_
	mov		eax, edi
	call	processing_lv_addr
	mov		[edx].flags, (XTG_VL_INSTR_CHG + XTG_VL_P2_GIVE + XTG_VL_P2_ADDR)
	mov		[edx].param_2, eax
	jmp		_vxp_emul_
_vxp_nxt_1_:
	cmp		byte ptr [edi], 50h											;push reg32; 
	jb		_vlci_ret_
	cmp		byte ptr [edi], 57h
	ja		_vlci_ret_
	movzx	eax, byte ptr [edi]
	and		eax, 07
	mov		[edx].flags, (XTG_VL_INSTR_CHG + XTG_VL_P2_GIVE + XTG_VL_P2_REG)
	mov		[edx].param_2, eax

_vxp_emul_:
	call	vl_emul_run_instr

	call	vl_code_analyzer
	test	eax, eax
	jne		_vlci_ret_													;если проверка успешно пройдена, выходим
	mov		ecx, vlm_xrcs_addr
	assume	ecx: ptr XTG_REGS_CURV_STRUCT
	add		[ecx].xregs_struct.x_esp, 04								;иначе скорректируем виртуальный esp - так как мы эмулили push, что уменьшаем esp на 4; 
	jmp		_vlci_ret_													;на выход; 
;--------------------------------------------------------------------------------------------------------
vl_xif_call:															;call
	mov		ecx, vlm_xrcs_addr
	assume	ecx: ptr XTG_REGS_CURV_STRUCT
	sub		[ecx].xregs_struct.x_esp, 04								;нам не нужно никуда прыгать, так как нужный адрес всегда будет передаваться;
	xor		eax, eax													;просто уменьшим виртуальный esp на 4, типо положили адрес возврата в виртуальный стэк =) 
	inc		eax
	jmp		_vlci_ret_
;--------------------------------------------------------------------------------------------------------
vl_xif_epilog:															;epilog
	assume	ecx: ptr XTG_INSTR_DATA_STRUCT
	xor		esi, esi
	mov		[ecx].instr_size, 01
	mov		edi, [ecx].instr_addr
	cmp		byte ptr [edi], 0C9h										;leave = size = 1 byte;
	je		_vxe_nxt_1_
	mov		[ecx].instr_size, 03										;иначе это mov esp, ebp  pop ebp; 
_vxe_nxt_1_:
	add		edi, [ecx].instr_size										;передвигаем edi на адрес команды ret; 
	cmp		byte ptr [edi], 0C3h										;ret 0xC3?
	je		_vxe_nxt_2_
	movzx	esi, word ptr [edi + 01]									;esi = числу, сколько нужно забрать со стэка

_vxe_nxt_2_:
	add		esi, 04														;в итоге [ecx].instr_size = размеру эпилога, а esi = числу, сколько надо байтов вытолкнуть из стэка; 
	
	call	vl_emul_run_instr											;эмулим

	mov		ecx, vlm_xrcs_addr
	assume	ecx: ptr XTG_REGS_CURV_STRUCT
	add		[ecx].xregs_struct.x_esp, esi								;и выталкиваем нужное число байтов из стэка; 
	xor		eax, eax
	inc		eax															;eax = 1;
	jmp		_vlci_ret_													;выходим; 
;===============================[FUNC PROLOG/PARAM/CALL/EPILOG]==========================================
	
	
	


;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;функа vl_chk_crct_instr_m
;корректировка команды и последующая её проверка;
;производится корректировка команд, содержащих абсолютный виртуальный адрес;
;например, есть команда mov ecx, dword ptr [403008h]
;значит, сначала адрес 403008h будет заменён на соответствующий ему адрес в памяти, предназначенной 
;для эмуляции, например, на 880008h. Получившаяся команда mov ecx, dword ptr [880008h] 
;будет проэмулирована и проверена анализатором; 
;ВХОД:
;	ebx			-		XTG_TRASH_GEN;
;	eax			-		адрес (в команде), по которому находится VA (который заменим на свой адрес); 
;	etc
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
vl_chk_crct_instr_m:
	assume	ecx: ptr XTG_INSTR_DATA_STRUCT
	push	edx
	push	esi
	push	edi
	push	[ecx].instr_addr
	push	ecx
	mov		esi, [ebx].xdata_struct_addr
	assume	esi: ptr XTG_DATA_STRUCT
	mov		edi, vlm_struct2_addr
	assume	edi: ptr XTG_LOGIC_STRUCT
	mov		edx, dword ptr [eax] 										;edx = VA; for example, 403008h 
	sub		edx, [esi].xdata_addr										;отнимаем от edx адрес начала области памяти, которой принадлежит адрес в edx; таким образом получаем смещение адреса в переданной области памяти [ebx].xdata_addr; 
	add		edx, [edi].xdata_addr										;добавляем к смещению адрес начала области памяти для эмуляции; т.о., получаем адрес в памяти для эмуляции, соотв-щий VA; выполнили преобразование; 
	mov		edi, [edi].instr_buf_addr									;edi - адрес буфера, в который скопируем преобразованную команду и запустим этот буфер (эмуляция); 
	add		edi, vl_instr_buf_size 										;edi = концу этого буфера
	sub		edi, [ecx].instr_size										;отнимаем размер переденной на проверку команды; 
	mov		esi, [ecx].instr_addr										;esi = адрес переданной команды;
	mov		[ecx].instr_addr, edi										;заменяем адрес на новый - тут будет лежать преобразованная команда; 
	mov		ecx, [ecx].instr_size										;ecx = размер команды
	sub		eax, esi													;eax = смещение VA в команде; 
	push	edi
	rep		movsb														;копируем команду в новый буфер
	pop		edi
	mov		dword ptr [edi + eax], edx									;заменяем VA на свой адрес (например, 403008h меняем на 880008h); 
	mov		ecx, dword ptr [edx]										;сохраняем значение, которое лежит по адресу 880008h etc; 

	call	vl_emul_run_instr											;эмулируем преобразованную команду

	call	vl_code_analyzer											;проверим преобразованную команду

	test	eax, eax													;если команда нам подходит по логике, тогда прыгаем на выход; 
	jne		_vccim_nxt_1_
	mov		dword ptr [edx], ecx										;иначе вернём ранее сохранённое значение в 880008h; (880008h просто взят для примера, естесно, тут будут другие адреса); 
_vccim_nxt_1_:
	pop		ecx
	pop		[ecx].instr_addr											;восстанавливаем всё
	pop		edi
	pop		esi
	pop		edx
	ret																	;и на выход; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;конец функи vl_chk_crct_instr_m 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
	


;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;функа processing_lv_addr
;обработка адресов локальных переменных (и входных параметров);
;получение адреса локальной переменной/входного параметра (л.п./в.п.) в команде; 
;если это адрес входного параметра (ebp + XXh), тогда мы его ещё проверим - есть ли такой адрес в 
;буфере адресов локал-варов и входных парамов. Если есть, тогда данная функа просто вернёт адрес 
;этого параметра. Если же адрес не найден, тогда запишем его, а также сбросим его состояния в 0 и 
;добавим первое состояние. Так можно делать, потому как входной параметр юзать можно (это же переданный 
;параметр ака значение, например push 5 - > 5 - корректное значение etc); 
;ВХОД:
;	ebx		-		etc;
;	eax		-		адрес команды с локальной переменной/входных параметром (например, такая команда:
;					mov ecx, dword ptr [ebp - 14h] - л.п., mov dword ptr [ebp + 18h] - в.п., edx   etc);
;ВЫХОД:
;	eax		-		адрес локальной переменной/входного параметра;
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
processing_lv_addr:
	push	ecx
	push	esi 
	mov		esi, vlm_xrcs_addr
	assume	esi: ptr XTG_REGS_CURV_STRUCT
	movzx	ecx, byte ptr [eax + 02]									;ecx - содержит 8-битное смещение
	mov		eax, [esi].xregs_struct.x_ebp								;eax = виртуальному значению ebp; 
	mov		esi, ecx
	neg		cl															;8-битное смещение делаем по модулю положительным; 
	js		_pla_nxt_1_
	sub		eax, ecx													;если это локал-вар, то просто отнимем от ebp полученное значение
	jmp		_pla_nxt_2_
_pla_nxt_1_:
	add		eax, esi 													;если это входной парам, то прибавим и вызовем функу обработки адреса входного парама; 
	call	vlca_new_lv_param
_pla_nxt_2_:
	pop		esi
	pop		ecx
	ret																	;выходим; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;конец функи processing_lv_addr 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

	



;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;функа vl_emul_run_instr
;эмуляция кода
;запуск конструкции/инструкции в специальной среде
;ВХОД:
;	функа вызывается из let_main и юзает её переменные etc;
;ВЫХОД:
;	eax		-	1, если эмуль отработал чёточка; 
;
;ЗАМЕТКИ:
;1)
;специальная среда представляет собой буфер, в который скопирована проверяемая команда и некоторые 
;другие спец. команды. Вот:
;		mov		edx, dword ptr [esp + 04]			;
;		mov		esp, dword ptr [esp + 08]
;		;x_instr									;наша скопированная для эмуля команда; 
;		mov		dword ptr [addr_1], ecx
;		mov		dword ptr [addr_1 + 04], esp
;		mov		esp, 
;		ret		08
;	addr_1:
;		;...
;
;2) если нужно мутировать данный код, то лучше не юзать swap-reg, так как могут быть несоответствия 
;	регов и виртуальных регов; иначе предусмотреть данную ситуацию;
;	это касается всех функций vl;
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
vl_emul_run_instr:
	pushad
	xor		eax, eax
	mov		edx, vlm_struct2_addr
	assume	edx: ptr XTG_LOGIC_STRUCT
	mov		edi, [edx].xregs_curv_struct_addr
	assume	edi: ptr XTG_REGS_CURV_STRUCT
	mov		ecx, [edx].vstack_addr
	sub		ecx, [edi].xregs_struct.x_esp
	add		ecx, 04
	cmp		ecx, vl_vstack_size											;есть у нас ещё место в виртуальном стэке?
	jb		_veri_nxt_1_
	mov		ecx, [edx].vstack_addr
	mov		[edi].xregs_struct.x_esp, ecx
	mov		[edi].xregs_struct.x_ebp, ecx
	;jmp		_veri_ret_
_veri_nxt_1_:
	mov		esi, vlm_xids_addr 
	assume	esi: ptr XTG_INSTR_DATA_STRUCT
	mov		edi, [edx].instr_buf_addr
	mov		ecx, [esi].instr_size
	mov		esi, [esi].instr_addr
	mov		eax, 0424548Bh												;mov edx, dword ptr [esp + 04]
	stosd																;будем изменять значение edx'a именно в спец. буфере (среде);
																		;так сделано потому, что в нашем эмуляторе есть вызов call dword ptr [edx + xxh];
																		;это мы как раз выполняем команды в спец. среде; если же изменить edx в эмуляторе, тогда выполнить эмулируемые команды не сможем - 
																		;edx примет уже другое значение;
	mov		eax, 0824648Bh												;mov esp, dword ptr [esp + 08]
	stosd																;esp - тоже изменяем в спец. среде, чтобы не повердить виртуальный стэк;
	rep		movsb														;x_instr;

	mov		ecx, [edx].xregs_curv_struct_addr
	assume	ecx: ptr XTG_REGS_CURV_STRUCT

	mov		ax, 0D89h													;mov dword ptr [addr_1], ecx
	stosw																;на выходе из спец. среды мы должны сохранить новые значения виртуальных регов;
																		;для этого заведена спец. структа, доступная через ecx; поэтому перед выходом мы сохраним 
																		;значение виртуального ecx в спец. среде; и после в эмуляторе восстановим ecx. А далее возьмем значение вирт. ecx, которое сохранили в спец. среде 
																		;и сохраним его в нашей структе;
	lea		eax, dword ptr [edi + 18]
	stosd
	mov		ax, 2589h													;mov dword ptr [addr_1 + 04], esp
	stosw																;etc
	lea		eax, dword ptr [edi + 12 + 04]
	stosd
	mov		al, 0BCh													;mov esp, value
	stosb																;esp должен указывать на тот адрес, чтобы корректно выйти из спец. среды (буфера); 
	lea		eax, dword ptr [esp - (8 * 4 + 4 + 4 * 2 + 4)]				;pushad + push ecx + push + push + call; 
	stosd
	mov		al, 0C2h													;ret 08;
	stosb
	mov		ax, 0008h
	stosw

	pushfd
	mov		eax, dword ptr [esp] 
	mov		vlm_real_flags, eax 										;сохраним в данной переменной текущие значения флагов эмулятора;
	mov		eax, [edx].flags_addr
	mov		eax, dword ptr [eax]										;затем возьмем сохраненные значения флагов эмулируемого кода 
	mov		dword ptr [esp], eax										;и сделаем их текущими
	popfd

	pushad																;сохраним реги
	push	ecx															;и отдельно ecx;
	mov		eax, [ecx].xregs_struct.x_eax								;установим значения регов текущими значениями виртуальных регов (для эмулируемого кода);
	mov		ebx, [ecx].xregs_struct.x_ebx
	mov		ebp, [ecx].xregs_struct.x_ebp
	mov		esi, [ecx].xregs_struct.x_esi
	mov		edi, [ecx].xregs_struct.x_edi
	push	[ecx].xregs_struct.x_esp									;edx & esp - будут устанавливаться уже в спец. среде;
	push	[ecx].xregs_struct.x_edx
	mov		ecx, [ecx].xregs_struct.x_ecx
	call	[edx].instr_buf_addr										;запускаем команду в специальной среде (эмуляция); 

	pop		ecx															;восстановим ecx;
	mov		[ecx].xregs_struct.x_eax, eax								;сохраним новые значения виртуальных регов;
	mov		[ecx].xregs_struct.x_edx, edx
	mov		[ecx].xregs_struct.x_ebx, ebx
	mov		[ecx].xregs_struct.x_ebp, ebp
	mov		[ecx].xregs_struct.x_esi, esi
	mov		[ecx].xregs_struct.x_edi, edi
	popad																;восстановим остальные реги
	mov		eax, dword ptr [edi]										;заберем из спец. среды значение виртуального рега ecx;
	mov		[ecx].xregs_struct.x_ecx, eax								;и сохраним его в нашей структе;
	mov		eax, dword ptr [edi + 04]									;аналогично с esp;
	mov		[ecx].xregs_struct.x_esp, eax

	pushfd																;сохраним флаги эмулируемого кода, 
	mov		eax, dword ptr [esp]										;и восстановим флаги эмулятора;
	mov		edi, [edx].flags_addr
	mov		dword ptr [edi], eax
	mov		eax, vlm_real_flags
	mov		dword ptr [esp], eax
	popfd

	xor		eax, eax
	inc		eax

_veri_ret_:
	mov		dword ptr [esp + 1Ch], eax
	popad
	ret																	;выходим;
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;конец функи vl_emul_run_instr; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx





;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;функа vl_code_analyzer
;анализатор кода: анализ (и построение) логики конструкции/инструкции; 
;ВХОД: 
;	ebx		-	etc;
;	заполненная структа XTG_INSTR_PARS_STRUCT; 
;	также перед вызовом данной функи, нужно всё необходимое настроить и проэмулить;
;	смотри в сорцы; 
;	etc;
;ВЫХОД:
;	EAX		-	0, если конструкция не подходит по логике, иначе 1;
;	(+)		-	скорректированные маски, состояния регов, локал-варов и т.п.;
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
vl_code_analyzer:
	pushad

	mov		ecx, vlm_xrcs_addr
	assume	ecx: ptr XTG_REGS_CURV_STRUCT
	mov		edx, vlm_xips_addr
	assume	edx: ptr XTG_INSTR_PARS_STRUCT

	mov		eax, [ecx].regs_init
	mov		vlm_tmp_var1, eax											;в этой переменной сохраним маску regs_init;
	mov		eax, [ecx].regs_used
	mov		vlm_tmp_var2, eax											;this var = regs_used; 

	mov		eax, vlm_xlv_init_addr
	mov		eax, dword ptr [eax]										;эти переменные будут хранить:
	mov		vlm_tmp_var3, eax											;значение маски init для локал-варов
	mov		eax, vlm_xlv_used_addr
	mov		eax, dword ptr [eax]
	mov		vlm_tmp_var4, eax											;used
	mov		eax, vlm_xlv_alv_addr
	mov		eax, dword ptr [eax]
	mov		vlm_tmp_var5, eax											;кол-во активных локал-варов/входных парамов etc; 

;========================================================================================================
																		;далее идут проверки на различные переданные флаги; 

;-------------------------------------------------------------------------------------------------------- 
	test	[edx].flags, XTG_VL_INSTR_CHG								;вначале определим: это команда изменения значения параметра(ов)? 
	jne		_vlca_instr_chg_
	test	[edx].flags, XTG_VL_INSTR_INIT								;или инициализации параметров? 
	jne		_vlca_instr_init_
	;jmp	_x_
;-------------------------------------------------------------------------------------------------------- 

;------------------------------------------------[CHG]---------------------------------------------------
;--------------------------------------------------------------------------------------------------------
_vlca_instr_chg_:														;если это команда изменения значений параметров, тогда 
	test	[edx].flags, XTG_VL_P1_GET									;проверим, 1-ый параметр получает значение?
	jne		_vlca_ic_p1_get_											;если да, то прыгаем дальше;
_vlca_ic_1_:
	test	[edx].flags, XTG_VL_P1_GIVE									;первый парам отдаёт своё значение?
	jne		_vlca_ic_p1_give_
_vlca_ic_2_:
_vlca_ic_3_:
	test	[edx].flags, XTG_VL_P2_GIVE									;второй парам отдаёт своё значение?
	jne		_vlca_ic_p2_give_
_vlca_ic_4_:
	test	[edx].flags, XTG_VL_P2_GET									;второй парам принимает своё значение?
	jne		_vlca_ic_p2_get_
_vlca_ic_5_:
	jmp		_vlca_instr_ok_												;если мы обработали все эти флаги и все проверки пройдены успешно, тогда прыгаем на блок кода, отвечающий за дальнейшую корректировку логики команды; 
;--------------------------------------------------------------------------------------------------------

;--------------------------------------------------------------------------------------------------------
_vlca_ic_p1_get_:														;если есть первый парам, и он принимает значение, то узнаем, что это за парам; 
	test	[edx].flags, XTG_VL_P1_REG									;это рег?
	jne		_vlca_ic_p1_get_reg_
	test	[edx].flags, XTG_VL_P1_ADDR 								;или адрес?
	jne		_vlca_ic_p1_get_addr_

_vlca_ic_p1_give_:														;если первый парам отдаёт своё значение, тогда также узнаем, какой это параметр; 
	test	[edx].flags, XTG_VL_P1_REG									;это регистр?
	jne		_vlca_ic_p1_give_reg_

_vlca_ic_p2_give_:														;если есть второй парам, который отдаёт своё значение -  то узнаем, какой это парам; 
	test	[edx].flags, XTG_VL_P2_REG									;рег
	jne		_vlca_ic_p2_give_reg_
	test	[edx].flags, XTG_VL_P2_NUM									;число
	jne		_vlca_ic_p2_give_num_
	test	[edx].flags, XTG_VL_P2_ADDR 								;адрес (локал-вар/входной парам); 
	jne		_vlca_ic_p2_give_addr_

_vlca_ic_p2_get_:														;второй парам получает значение
	test	[edx].flags, XTG_VL_P2_REG									;второй парам является регом; 
	jne		_vlca_ic_p2_get_reg_
;--------------------------------------------------------------------------------------------------------

;--------------------------------------------------------------------------------------------------------
;::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
_vlca_ic_p1_get_reg_:													;команда изменения значения парамов, где первый парам является регом, который получает значение; 
	mov		eax, [edx].param_1											;eax = номер рега, который нужно проверить; 
	bt		[ecx].regs_used, eax										;проверяем, можно ли его юзать (изменять его значение) в командах; 
	jnc		_vlca_instr_no_												;если нет, тогда прыгаем на блок кода, который откатит значения нужных параметров на предыдущее; 
	bts		vlm_tmp_var1, eax											;иначе, во вспомогательной переменной (которая соот-ет маске regs_init) выставим флаг, соотв-щий данному регу - это означает, что рег нельзя повторно инициализировать (так как он уже проинициализирован) (но можно изменять его значение); 
	call	vlca_check_reg_state										;проверим состояние рега
	test	eax, eax													;если его текущее состояние есть в таблице состояний для данного рега, тогда команда не подходит - идём на откат значений; 
	je		_vlca_instr_no_
	jmp		_vlca_ic_1_													;если же текущее состояние не было найдено, тогда всё ок - переходим на проверку остальных флагов; 
;::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

;::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
_vlca_ic_p1_get_addr_: 													;etc, только это не рег, а локал-вар/входной парам ([ebp +- XXh]); 
	mov		eax, [edx].param_1											;eax - содержит адрес локальной переменной; 
	call	vlca_search_index_lv_addr									;проверяем, есть ли такой адрес в таблице адресов локал-варов; 
	mov		vlm_tmp_var6, eax											;полученное значение (индекс или -1) сохраним в данной переменной; 
	inc		eax															;
	je		_vlca_instr_no_												;если адреса такого нет, значит переменная не инициализирована, и соотв-но, у неё нет никакого значения, чтобы его можно было изменять; 
	dec		eax
	mov		esi, vlm_xlv_used_addr										;иначе
	bt		dword ptr [esi], eax										;проверим, можно ли изменять значение данной локальной переменной
	jnc		_vlca_instr_no_												;если нет, тогда идём на откат значений; 
	bts		vlm_tmp_var3, eax											;если да, то вначале выставим флаг (в переменной) для данной локал-вара, что его нельзя повторно инициализировать
	call	vlca_check_lv_state											;и затем проверим текущее новое состояние
	test	eax, eax													;если такое уже было, значит команда не проходит проверку 
	je		_vlca_instr_no_
	jmp		_vlca_ic_1_													;иначе идём на проверку других флагов; 
;::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
	
;::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
_vlca_ic_p1_give_reg_:													;etc, только это рег, который отдаёт значение
	mov		eax, [edx].param_1											;eax = номер проверяемого рега; 
	bt		[ecx].regs_used, eax										;значение рега можно изменять?
	jnc		_vlca_instr_no_												;если нет, то откатываемся
	btr		vlm_tmp_var1, eax											;иначе, в соотв-щей переменной выставим флаг, указывающий, рег отдал своё значение - и его снова можно проинициализировать; 
	jmp		_vlca_ic_2_													;переходим к проверке следующих флагов; 
;::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
	
;::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
_vlca_ic_p2_give_reg_:													;etc, только это парам 2 - рег, отдающий своё значение; 
	mov		eax, [edx].param_2											;eax = номер проверяемого рега;
	bt		[ecx].regs_used, eax										;значение рега можно изменять?
	jnc		_vlca_instr_no_												;если нет, то на откат
	btr		vlm_tmp_var1, eax											;если да, укажем, что рег снова можно инициализировать; 
	jmp		_vlca_ic_4_													;переход на проверку других флагов кострукции; 
;::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

;::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
_vlca_ic_p2_give_num_:													;читаем название метки, ёба =) (итак, на сей раз это рег и прочее, а число); 
	call	vlca_chkreset_param_3										;а если это число, значит возможно юзается поле param_3; вызовем функу проверки; 
	inc		eax															;если в param_3 действительно были выставлены биты регов, отдающих свои значение и какой-то (или все) из них не прошел проверку, тогда идём на откат состояний etc; 
	je		_vlca_instr_no_
	jmp		_vlca_ic_4_													;иначе прыгаем на проверку остальных флагов; 
;::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

;::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
_vlca_ic_p2_give_addr_: 												;etc, только это адрес локал-вара/входного парама; 
	mov		eax, [edx].param_2 											;eax - содержит этот адрес; 
	call	vlca_search_index_lv_addr									;проверим, есть ли этот адрес в буфере адресов локал-варов/входных парамов; 
	inc		eax
	je		_vlca_instr_no_												;если нет, тогда этот локал-вар/etc еще юзать нельзя - он не проинициализирован etc; прыгаем на откат состояний etc; etc; 
	dec		eax															;иначе 
	mov		esi, vlm_xlv_used_addr
	bt		dword ptr [esi], eax										;проверим, можно ли изменять значение локал-вара
	jnc		_vlca_instr_no_												;если нет, тогда прыгаем на откат
	btr		vlm_tmp_var3, eax											;иначе укажем, что локал-вар снова можно инициализировать; 
	;mov		vlm_tmp_var6, eax
	jmp		_vlca_ic_4_													;прыгаем на проверку остальных флагов; 
;::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

;::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
_vlca_ic_p2_get_reg_:													;рег
	mov		eax, [edx].param_2
	bt		[ecx].regs_used, eax										;можно ли изменять его значение?
	jnc		_vlca_instr_no_
	bts		vlm_tmp_var1, eax											;запрет повторной инициализации
	call	vlca_check_reg_state										;проверка текущего состояния с другими, ранее полученными состояниями
	test	eax, eax
	je		_vlca_instr_no_												;такое уже было?
	jmp		_vlca_ic_5_													;если нет, то прыгаем дальше на проверку других флагов; 
;::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;--------------------------------------------------------------------------------------------------------
;------------------------------------------------[CHG]---------------------------------------------------

;------------------------------------------------[INIT]--------------------------------------------------
;--------------------------------------------------------------------------------------------------------	
_vlca_instr_init_:														;команда инициализации парамов; 
	test	[edx].flags, XTG_VL_P1_GET									;первый парам получает значение
	jne		_vlca_ii_p1_get_
_vlca_ii_1_:
_vlca_ii_2_:
_vlca_ii_3_:
	test	[edx].flags, XTG_VL_P2_GIVE									;второй парам отдаёт своё значение; 
	jne		_vlca_ii_p2_give_
_vlca_ii_4_:
	jmp		_vlca_instr_ok_
;--------------------------------------------------------------------------------------------------------

;--------------------------------------------------------------------------------------------------------
_vlca_ii_p1_get_:														;etc
	test	[edx].flags, XTG_VL_P1_REG									;рег
	jne		_vlca_ii_p1_get_reg_
	test	[edx].flags, XTG_VL_P1_ADDR									;адрес (локал-вар)
	jne		_vlca_ii_p1_get_addr_

_vlca_ii_p2_give_:
	test	[edx].flags, XTG_VL_P2_REG									;рег
	jne		_vlca_ii_p2_give_reg_
	test	[edx].flags, XTG_VL_P2_NUM									;число
	jne		_vlca_ii_p2_give_num_ 	
	test	[edx].flags, XTG_VL_P2_ADDR									;локал-вар
	jne		_vlca_ii_p2_give_addr_
;--------------------------------------------------------------------------------------------------------

;--------------------------------------------------------------------------------------------------------	 
;::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
_vlca_ii_p1_get_reg_:													;рег
	mov		eax, [edx].param_1											;eax = номер рега (0 - eax etc); 
	bt		[ecx].regs_init, eax										;рег уже был проинициализирован?
	jc		_vlca_instr_no_												;если да, тогда это будет повторная инициализация - а это не есть гуд, запрещаем - переход на откат значений; 
	bts		vlm_tmp_var1, eax											;иначе, выставим флаг, что рег проинициализирован
	bts		vlm_tmp_var2, eax											;и его можно юзать в различных инструкциях; 
	call	vlca_check_reg_state										;также, проверим текущее состояние рега 
	test	eax, eax													;если оно уже было, значит команда по логике не подходит - она явно мусор - идём на откат значений; 
	je		_vlca_instr_no_
	jmp		_vlca_ii_1_													;если такого значения ещё не было, тогда пока всё оке, проверяем другие оставшиеся флаги команды; 
;::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

;::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
_vlca_ii_p1_get_addr_: 													;адрес локал-вара; 
	mov		eax, [edx].param_1											;eax - содержит этот адрес
	call	vlca_search_index_lv_addr									;узнаём, есть ли этот адрес в таблице адресов локал-варов
	mov		vlm_tmp_var6, eax											;если нам вернётся -1 - тогда этого адреса ещё не было, а значит этот локал-вар не был проинициализирован - и это сделать можно=) 
	inc		eax															;если же вернётся отличное от -1 число (ака индекс адреса в таблице адресов), тогда адрес есть, и нужно его дополнительно проверять; 
	jne		_viip1geta_idxok_
	dec		eax
	cmp		vlm_tmp_var5, vl_lv_num										;также, проверим, сколько у нас уже активных локал-варов: если >= max поддерживаемому числу локал-варов, тогда капец, прыгаем на откат значений; 
	jae		_vlca_instr_no_
	mov		eax, vlm_xlv_alv_addr										;иначе - на этот участок кода мы попадаем, если адрес не был найден в таблице адресов локал-варов; 
	mov		eax, dword ptr [eax]										;eax - получает число активных локал-варов - это число как раз будет индексом в таблице адресов, по которому можно получить наш адрес; 
	mov		vlm_tmp_var6, eax 											;сохраним индекс в переменной
	mov		esi, vlm_xlv_addr											;esi - адрес таблицы адресов локал-варов; 
	push	[edx].param_1												;и сохраняем новый адрес
	pop		dword ptr [esi + eax * 4]									;в этом буфере; 
	bts		vlm_tmp_var3, eax											;и выставим атрибуты, указывающие, что этот локал-вар уже проинициализирован (запрет от повторной инициализации); 
	bts		vlm_tmp_var4, eax											;и его значение можно использовать в различных командах; 
	inc		vlm_tmp_var5												;увеличиваем число активных локал-варов на +1; 
	jmp		_vlca_ii_1_													;прыгаем на проверку других флагов конструкции; 

_viip1geta_idxok_:														;а сюда мы попадаем, если адрес локал-вара был в таблице адресов; 
	dec		eax
	mov		esi, vlm_xlv_init_addr										;проверим, локал-вар уже проинициализирован?
	bt		dword ptr [esi], eax
	jc		_vlca_instr_no_												;если да, то на откат
	bts		vlm_tmp_var3, eax											;иначе выставим, что теперь он проинициализирован
	bts		vlm_tmp_var4, eax											;и его значение можно юзать в разных командах; 
	call	vlca_check_lv_state											;и проверим текущее состояние локал-вара
	test	eax, eax													;если оно уже было (найдено в таблице состояний), тогда на откат; 
	je		_vlca_instr_no_
	jmp		_vlca_ii_1_													;если же нет, то есть это новое состояние - тогда всё ок, проверим следующие флаги; 
;::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

;::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
_vlca_ii_p2_give_reg_:													;рег
	mov		eax, [edx].param_2											;eax - номер рега
	bt		[ecx].regs_used, eax										;рег можно юзать в командах?
	jnc		_vlca_instr_no_												;если нет, тогда на откат (такое бывает, когда рег даже не проинициализирован); 
	btr		vlm_tmp_var1, eax											;иначе, сбросим флаг - это означает, что рег снова можно инициализировать; 
	jmp		_vlca_ii_4_
;::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

;::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
_vlca_ii_p2_give_num_:													;число - а раз так, тогда поле param_3 может содержать выставленные биты, соотв-щие конкретным регам, проверим это; 
	call	vlca_chkreset_param_3
	inc		eax 														;возвращаемое число >=0, тогда всё ок, идем на проверку других флагов
	je		_vlca_instr_no_												;если же число = -1, тогда param_3 точно юзался, и какой-то рег не прошёл проверку - быстро на откат бля =) 
	jmp		_vlca_ii_4_
;::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

;::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
_vlca_ii_p2_give_addr_:													;адрес локал-вара; 
	mov		eax, [edx].param_2 											;eax - адрес локал-вара
	call	vlca_search_index_lv_addr									;проверим, есть ли адрес в таблице адресов
	inc		eax
	je		_vlca_instr_no_												;если нет, то на откат (eax = -01); 
	dec		eax
	mov		esi, vlm_xlv_used_addr										;иначе, проверим, можно ли локал-вар юзать в других командах?
	bt		dword ptr [esi], eax
	jnc		_vlca_instr_no_												;если нет, тогда откатываемся
	btr		vlm_tmp_var3, eax											;если да, тогда сбросим флаг в маске init - то есть локал-вар снова можно будет инициализировать; 
	jmp		_vlca_ii_4_													;прыгаем на проверку остальных флагов инструкции; 
;::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;--------------------------------------------------------------------------------------------------------
;------------------------------------------------[INIT]--------------------------------------------------

;----------------------------------------------[INSTR OK]------------------------------------------------
_vlca_instr_ok_:														;если команда провшла все проверки, тогда всё отлично, команда остаётся (не будет откатов); теперь скорректируем логику; 
;_vlca_instr_reg_ok_:
;--------------------------------------------------------------------------------------------------------
	test	[edx].flags, XTG_VL_P1_GET									;есть первый парам, который получает значение?
	je		_virok_p2_
	test	[edx].flags, XTG_VL_P1_REG									;и это рег?
	je		_virok_p1_addr_
	mov		eax, [edx].param_1											;eax - номер рега
	test	[edx].flags, XTG_VL_INSTR_INIT								;если проверяемая команда оказалось командной инициализации, 
	je		_virok_p1_nxt_1_
	call	vlca_reset_reg_state										;тогда сбросим все состояния рега в 0 
_virok_p1_nxt_1_:	
	call	vlca_new_reg_state											;сохраним новое состояние рега; 
;--------------------------------------------------------------------------------------------------------

;--------------------------------------------------------------------------------------------------------
_virok_p1_addr_: 														;если же первый парам получает значение, и этот первый парам - локал-вар, тогда приступим к корректировке; 
	test	[edx].flags, XTG_VL_P1_ADDR
	je		_virok_p2_
	mov		eax, vlm_tmp_var6											;eax - содержит индекс адреса этого локал-вара в таблице адресов локал-варов; 
	inc		eax
	je		_virok_p2_													;если в eax = -1 (это не индекс), тогда прыгаем дальше - корректировать нечего; 
	dec		eax
	test	[edx].flags, XTG_VL_INSTR_INIT								;иначе, проверим, проверяемая команда - это команда инициализации?
	je		_virok_p1_nxt_2_
	call	vlca_reset_lv_state											;если так, то сбросим все состояния локал-вара в 0; 
_virok_p1_nxt_2_:
	call	vlca_new_lv_state											;сохраним в таблице состояний текущее новое состояния данного локал-вара; 
;--------------------------------------------------------------------------------------------------------

;--------------------------------------------------------------------------------------------------------
_virok_p2_:
	test	[edx].flags, XTG_VL_P2_GET									;тут всё аналогично; 
	je		_virok_p3_
	test	[edx].flags, XTG_VL_P2_REG
	je		_virok_p2_addr_
	mov		eax, [edx].param_2
	test	[edx].flags, XTG_VL_INSTR_INIT
	je		_virok_p2_nxt_1_
	call	vlca_reset_reg_state
_virok_p2_nxt_1_:
	call	vlca_new_reg_state
;--------------------------------------------------------------------------------------------------------

;--------------------------------------------------------------------------------------------------------
_virok_p2_addr_:
_virok_p3_:
_virok_riu_:
	mov		ecx, vlm_xrcs_addr											;а теперь все новые значения масок, сохранённые во временных переменных, перенесём в постоянные переменные; 
	assume	ecx: ptr XTG_REGS_CURV_STRUCT
	mov		eax, vlm_tmp_var1
	mov		[ecx].regs_init, eax
	mov		eax, vlm_tmp_var2
	mov		[ecx].regs_used, eax

	mov		ecx, vlm_xlv_init_addr	
	mov		eax, vlm_tmp_var3
	mov		dword ptr [ecx], eax
	mov		ecx, vlm_xlv_used_addr
	mov		eax, vlm_tmp_var4
	mov		dword ptr [ecx], eax
	mov		ecx, vlm_xlv_alv_addr
	mov		eax, vlm_tmp_var5 
	mov		dword ptr [ecx], eax

	xor		eax, eax													;eax = 1; команда успешно прошла проверку, она не будет потёрта - останется в трэш-коде, и логика скорректирована, всё отлично - выходим xD; 
	inc		eax
	jmp		_vlca_ret_
;--------------------------------------------------------------------------------------------------------
;----------------------------------------------[INSTR OK]------------------------------------------------

;----------------------------------------------[INSTR NO]------------------------------------------------	
_vlca_instr_no_:
;_vlca_instr_reg_no_:
;--------------------------------------------------------------------------------------------------------
	test	[edx].flags, XTG_VL_P1_GET ;+ XTG_VL_P1_GIVE				;если первый парам - рег, который получает значение, тогда откатим значение; 
	je		_virno_p2_
	test	[edx].flags, XTG_VL_P1_REG
	je		_virno_p1_addr_
	mov		eax, [edx].param_1											;eax - номер рега
	call	vlca_invalid_reg_state										;откатим его текущее значение на предыдущее; 
;--------------------------------------------------------------------------------------------------------

;--------------------------------------------------------------------------------------------------------
_virno_p1_addr_: 														;если парам - локал-вар, тогда откатимся
	test	[edx].flags, XTG_VL_P1_ADDR
	je		_virno_p2_
	mov		eax, vlm_tmp_var6											;eax - индекс адреса локал-вара в таблице адресов; 
	inc		eax															;или -1 - если -1, тогда откатывать нечего, на выход; 
	je		_virno_p2_
	dec		eax
	call	vlca_invalid_lv_state										;иначе, если индекс (eax >= 0), тогда откатим текущее значение локал-вара на предыдущее; 
;--------------------------------------------------------------------------------------------------------

;--------------------------------------------------------------------------------------------------------
_virno_p2_:
	test	[edx].flags, XTG_VL_P2_GET ;+ XTG_VL_P2_GIVE				;аналогично
	je		_virno_p3_ 
	test	[edx].flags, XTG_VL_P2_REG
	je		_virno_p2_addr_
	mov		eax, [edx].param_2
	call	vlca_invalid_reg_state										;etc; 
;--------------------------------------------------------------------------------------------------------

;--------------------------------------------------------------------------------------------------------
_virno_p2_addr_:
_virno_p3_:
_vlca_inr_:
	xor		eax, eax													;eax = 0;
;--------------------------------------------------------------------------------------------------------
;----------------------------------------------[INSTR NO]------------------------------------------------

_vlca_ret_:
	mov		dword ptr [esp + 1Ch], eax									;eax
	popad
	ret																	;выходим 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;конец функи vl_code_analyzer; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx





;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;функа vlca_chkreset_param_3
;проверка поля param_3 на присутствие выставленных битов. Эти биты соотв-ют конкретным регам. 
;И проверка этих регов;
;ВХОД:
;		etc;
;		param_3		-	значение;
;ВЫХОД:
;		eax			-	-1, если проверка не пройдена, иначе число >= 0 (8);
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
vlca_chkreset_param_3:
	xor		eax, eax													;eax = 0; 
_vcp3_cycle_:
	bt		[edx].param_3, eax ;btr										;если бит установлен, тогда в eax - номер рега, отдающего своё значение; 
	jnc		_vcp3_nr_
	bt		[ecx].regs_used, eax										;проверим, можно ли этот рег юзать в командах?
	jnc		_vcp3_inv_													;если нет, тогда сразу на выход;
	btr		vlm_tmp_var1, eax											;иначе, сбрасываем бит в маске init - это означает, что рег снова можно инициализировать; 
_vcp3_nr_:
	inc		eax 														;увеличиваем счётчик; 
	cmp		eax, 08
	jne		_vcp3_cycle_
	jmp		_vcp3_ret_
_vcp3_inv_:
	xor		eax, eax
	dec		eax
_vcp3_ret_:
	ret																	;выходим; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;конец функи vlca_chkreset_param_3 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx




	
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;функа vlca_check_reg_state 
;проверка текущего состояния виртуального рега - есть ли он в таблице состояний для данного рега;
;ВХОД:
;	ebx		-	etc;
;	eax		-	номер рега, текущее состояние которого надо проверить; 
;ВЫХОД:
;	eax		-	0, если текущее состояние есть в таблице состояний, иначе 1 (состояние не найдено); 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
vlca_check_reg_state:
	push	ecx
	push	edx
	push	ebx
	push	edi
	mov		ecx, vlm_xrcs_addr
	assume	ecx: ptr XTG_REGS_CURV_STRUCT
	mov		edi, vlm_struct2_addr
	assume	edi: ptr XTG_LOGIC_STRUCT
	mov		edi, [edi].xregs_states_addr								;edi - адрес таблицы состояний;
	mov		ebx, dword ptr [edi + eax * 4]								;первая структура - кол-во состояний для каждого рега; ebx = кол-ву накопленных состояний проверяемого рега; 
	mov		ecx, dword ptr [ecx + eax * 4]								;ecx = текущему состоянию, которое надо проверить; 
_vlca_crs_cycle_:	
	test	ebx, ebx													;если кол-во состояний = 0 (то есть их вообще нет), тогда проверять не с чем, и естесно,  текущее состояние не найдено =) 
	je		_vlca_not_found_state_
	dec		ebx															;иначе, в ebx - индекс очередной структуры XTG_REGS_CURV_STRUCT; (начинаем с конца); 
	imul	edx, ebx, sizeof (XTG_REGS_STRUCT)							;edx = размер 
	lea		edx, dword ptr [edx + edi + sizeof (XTG_REGS_STRUCT)]		;пропускаем первую структуру, и edx = адрес на очередную структуру, которая хранит очередное состояние рега; 
	cmp		ecx, dword ptr [edx + eax * 4]								;сравниваем текущее состояние с каждым накопленным состоянием
	je		_vlca_yes_found_state_										;если равны, тогда eax = 0 и выходим
	jmp		_vlca_crs_cycle_											;иначе, проверяем дальше

_vlca_not_found_state_:													;если текущего состояния не найдено в накопленных состояний для данного рега или вообще нет накопленных состояний, тогда eax = 1 и выходим; 
	xor		eax, eax
	inc		eax
	jmp		_vlca_crs_ret_
_vlca_yes_found_state_:
	xor		eax, eax
	
_vlca_crs_ret_:
	pop		edi
	pop		ebx
	pop		edx
	pop		ecx
	ret																	;на выход 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;конец функи vlca_check_reg_state 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx





;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;функа vlca_new_reg_state
;добавление нового состояния в таблицу состояний (в накопленные состояния) для конкретного рега
;ВХОД:
;	eax		-	номер проверяемого рега (0 - eax, 1 - ecx etc); 
;ВЫХОД:
;	(+)		-	добавленное состояние и увеличенное на +1 кол-во состояний для данного рега; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
vlca_new_reg_state:
	push	ecx
	push	edx
	push	esi
	push	edi
	mov		ecx, vlm_xrcs_addr
	assume	ecx: ptr XTG_REGS_CURV_STRUCT
	mov		edi, vlm_struct2_addr
	assume	edi: ptr XTG_LOGIC_STRUCT
	mov		edi, [edi].xregs_states_addr
	mov		esi, dword ptr [edi + eax * 4]								;esi - кол-во накопленных состояний
	mov		ecx, dword ptr [ecx + eax * 4]								;ecx - текущее новое состояние
	cmp		esi, vl_regs_states											;если кол-во накопленных состояний >= max поддерживаемому кол-ву состояний, тогда 
	jb		_vlca_add_rs_crct_
	xor		esi, esi
	and		dword ptr [edi + eax * 4], 0								;обнулим (сбросим в 0) кол-во состояний данного рега; 
_vlca_add_rs_crct_:
	imul	edx, esi, sizeof (XTG_REGS_STRUCT)
	lea		edx, dword ptr [edx + edi + sizeof (XTG_REGS_STRUCT)]		;edx - содержит адрес за последней на данный момент структурой, хранящей состояния регов
	mov		dword ptr [edx + eax * 4], ecx								;добавляем в конец новое текущее состояние рега
	inc		dword ptr [edi + eax * 4]									;увеличиваем на +1 кол-во накопленных состояний данного рега; 
	pop		edi
	pop		esi
	pop		edx
	pop		ecx
	ret																	;выход 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;конец функи vlca_new_reg_state 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx





;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;функа vlca_invalid_reg_state
;откат текущего состояния рега на предыдущее
;берем последнее состояние в накопленных состояниях данного рега, и делаем его текущим состоянием 
;этого рега
;ВХОД:
;	eax		-	номер рега; 
;ВЫХОД:
;	(+)		-	откат состояния; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
vlca_invalid_reg_state:
	push	ecx
	push	edx
	push	esi
	push	edi
	mov		ecx, vlm_xrcs_addr
	assume	ecx: ptr XTG_REGS_CURV_STRUCT
	mov		edi, vlm_struct2_addr
	assume	edi: ptr XTG_LOGIC_STRUCT
	mov		edi, [edi].xregs_states_addr
	mov		esi, dword ptr [edi + eax * 4]								;esi - содержит кол-во всех накопленных состояний данного рега; 
	test	esi, esi													;если оно = 0 (то есть состояний ещё не было), тогда перепрыгнем дальше (такое может быть, если рег ни разу не проверялся - все нужные поля проинициализированы в 0); 
	je		_vlca_na_rs_0_s_
	dec		esi															;уменьшаем на -1;
_vlca_na_rs_0_s_:
	imul	edx, esi, sizeof (XTG_REGS_STRUCT) 
	lea		edx, dword ptr [edx + edi + sizeof (XTG_REGS_STRUCT)]		;edx - содержит адрес на последнюю на данный момент структуру, хранящую состояния регов
	mov		edx, dword ptr [edx + eax * 4]								;берём последнее состояние данного рега; 
	mov		dword ptr [ecx + eax * 4], edx								;и делаем его текущим; 
	;xor		eax, eax
	pop		edi
	pop		esi
	pop		edx
	pop		ecx	
	ret																	;выходим; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;конец функи vlca_invalid_reg_state
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx





;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;функа vlca_reset_reg_state
;сброс накопленных состояний рега в 0; 
;ВХОД:
;	eax		-	номер рега;
;ВЫХОД:
;	(+)		-	кол-во накопленных состояний этого рега теперь = 0; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
vlca_reset_reg_state:
	push	edi
	mov		edi, vlm_struct2_addr
	assume	edi: ptr XTG_LOGIC_STRUCT
	mov		edi, [edi].xregs_states_addr
	and		dword ptr [edi + eax * 4], 0								;сбрасываем кол-во накопленных состояний этого рега; 
	pop		edi
	ret
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;конец функи vlca_reset_reg_state; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx





;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;функа vlca_new_lv_param
;проверка - есть ли адрес входного парама ([ebp + XXh]) в таблице адресов локал-варов/входных парамов 
;и если нет, тогда добавление этого адреса, а также обнуление кол-ва состояний и добавление первого 
;текущего состояния в таблицу состояний;
;ВХОД:
;	eax		-	адрес входного парама;
;ВЫХОД:
;	(+)		-	уже написал =)
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
vlca_new_lv_param:
	push	ecx
	push	esi
	push	edi
	push	eax
	
	call	vlca_search_index_lv_addr									;вначале проверим, есть ли такой адрес в таблице адресов локал-варов; 
	
	inc		eax 
	pop		eax
	jne		_vnlp_ret_													;если есть (eax = -1), тогда выходим
	mov		ecx, vlm_xlv_alv_addr										;если нет, тогда поехали дальше; 
	mov		edi, dword ptr [ecx]										;edi - содержит кол-во активных локал-варов и входных парамов; 
	cmp		edi, vl_lv_num 												;если это кол-во >= max поддерживаемого числа активных локал-варов, тогда выходим; 
	jae		_vnlp_ret_
	inc		dword ptr [ecx]												;иначе, увеличим на +1 это кол-во; 
	mov		esi, vlm_xlv_addr
	mov		dword ptr [esi + edi * 4], eax 								;добавим в конец новый адрес
	mov		esi, vlm_xlv_used_addr 
	bts		dword ptr [esi], edi										;укажем, что данный входной парам можно юзать в других командах; 
	push	eax
	xchg	eax, edi 
	
	call	vlca_reset_lv_state											;а также сделаем кол-во его накомпленных состояний = 0;
	
	call	vlca_new_lv_state ; 										;и добавим текущее состояние в таблицу состояний - это будет первое накопленное состояние; 
	
	pop		eax
_vnlp_ret_:
	pop		edi
	pop		esi
	pop		ecx
	ret																	;выходим; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;конец функи vlca_new_lv_param
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx





;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;функа vlca_check_lv_state
;проверка текущего состояния локал-вара - есть ли он в таблице состояний для данного локал-вара;
;ВХОД:
;	ebx		-	etc;
;	eax		-	индекс адреса локал-вара в таблице адресов локал-варов, текущее состояние которого надо проверить; 
;ВЫХОД:
;	eax		-	0, если текущее состояние есть в таблице состояний, иначе 1 (состояние не найдено); 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
vlca_check_lv_state:
	push	ecx
	push	edx
	push	ebx
	push	edi
	mov		ecx, vlm_xlv_addr
	mov		ecx, dword ptr [ecx + eax * 4] 								;ecx - содержит адрес данного локал-вара; 
	mov		edi, vlm_xlv_states_addr
	mov		ebx, dword ptr [edi + eax * 4]								;ebx - кол-во накопленных состояний этого локал-вара; 
	mov		ecx, dword ptr [ecx] 										;ecx - текущее состояние локал-вара
_vcls_cycle_:	
	test	ebx, ebx													;если ebx = 0, прыгаем дальше
	je		_vcls_nfs_
	dec		ebx
	imul	edx, ebx, (vl_lv_num * 4)
	lea		edx, dword ptr [edx + edi + (vl_lv_num * 4)]
	cmp		ecx, dword ptr [edx + eax * 4]								;иначе, начинаем проверять каждое сохранённое состояние с текущим состоянием
	je		_vcls_yfs_													;если совпадение найдено, тогда eax = 0 и выходим отсюда
	jmp		_vcls_cycle_

_vcls_nfs_:
	xor		eax, eax													;если совпадений не найдено или сохранённых состояний ещё нет, тогда eax = 1 и выходим; 
	inc		eax
	jmp		_vcls_ret_
_vcls_yfs_:
	xor		eax, eax
	
_vcls_ret_:
	pop		edi
	pop		ebx
	pop		edx
	pop		ecx
	ret																	;на выход; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;конец функи vlca_check_lv_state; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx





;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;функа vlca_new_lv_state
;добавление нового состояния в таблицу состояний (в накопленные состояния) для конкретного local-var; 
;ВХОД:
;	eax		-	индекс локал-вара в таблице адресов локал-варов;
;ВЫХОД:
;	(+)		-	добавленное состояние и увеличенное на +1 кол-во состояний для данного local var; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
vlca_new_lv_state:
	push	ecx
	push	edx
	push	esi
	push	edi
	mov		ecx, vlm_xlv_addr
	mov		ecx, dword ptr [ecx + eax * 4]								;ecx - адрес локал-вара
	mov		edi, vlm_xlv_states_addr
	mov		esi, dword ptr [edi + eax * 4]								;esi - кол-во накопленных состояний локал-вара
	mov		ecx, dword ptr [ecx] 										;ecx - текущее состояние локал-вара
	cmp		esi, vl_lv_states											;если кол-во накопленных состояний локал-вара >= max поддерживаемого кол-ва, тогда 
	jb		_vnls_nxt_1_
	xor		esi, esi
	and		dword ptr [edi + eax * 4], 0								;сбросим кол-во состояний в 0; 
_vnls_nxt_1_:
	imul	edx, esi, (vl_lv_num * 4)
	lea		edx, dword ptr [edx + edi + (vl_lv_num * 4)]				;edx - адрес ЗА последней структурой, содержащуей состояния (последние состояния) локал-варов; 
	mov		dword ptr [edx + eax * 4], ecx								;добавляем текущее состояние в накопленные состояния;
	inc		dword ptr [edi + eax * 4]									;увеличиваем на +1 кол-во накопленных состояний локал-вара; 
	pop		edi
	pop		esi
	pop		edx
	pop		ecx
	ret																	;выходим; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;конец функи vlca_new_lv_state; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx





;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;функа vlca_invalid_lv_state
;откат текущего состояния local var на предыдущее
;берем последнее состояние в накопленных состояниях данного local var, и делаем его текущим состоянием 
;этого local var'a;
;ВХОД:
;	eax		-	индекс адреса локал-вара в таблице адресов локал-варов; 
;ВЫХОД:
;	(+)		-	откат состояния; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
vlca_invalid_lv_state:
	push	ecx
	push	edx
	push	esi
	push	edi
	mov		ecx, vlm_xlv_addr
	mov		ecx, dword ptr [ecx + eax * 4]								;ecx - адрес локал-вара
	mov		edi, vlm_xlv_states_addr
	mov		esi, dword ptr [edi + eax * 4]								;esi - кол-во накопленных состояний локал-вара
	test	esi, esi
	je		_vils_nxt_1_
	dec		esi
_vils_nxt_1_:
	imul	edx, esi, (vl_lv_num * 4)
	lea		edx, dword ptr [edx + edi + (vl_lv_num * 4)]				;edx - адрес на последнюю структуру, содержащую сохранённые состояния (последние состояния) локал-варов
	mov		edx, dword ptr [edx + eax * 4]								;берём оттуда состояние данного локал-вара
	mov		dword ptr [ecx], edx 										;и делаем его текущим состоянием для данного локал-вара; 
	pop		edi
	pop		esi
	pop		edx
	pop		ecx	
	ret																	;выходим; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;конец функи vlca_invalid_lv_state; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx 





;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;функа vlca_search_index_lv_addr
;поиск адреса локал-вара в таблице адресов локал-варов. 
;Если адрес найден, тогда вернётся индекс в таблице, по которому будет лежать даннный адрес;
;ВХОД:
;	eax		-	адрес локал-вара;
;ВЫХОД:
;	eax		-	-1, если адрес не найден, иначе вернётся индекс в таблице адресов; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
vlca_search_index_lv_addr:
	push	ecx
	push	esi
	mov		esi, vlm_xlv_addr
	mov		ecx, vlm_xlv_alv_addr
	mov		ecx, dword ptr [ecx]										;ecx - кол-во активных локал-варов - будет проверка только среди активных локал-варов - это важно!
_vsila_cycle_:
	test	ecx, ecx													;если ecx = 0, прыгаем дальше; 
	je		_vsila_nf_
	dec		ecx
	cmp		dword ptr [esi + ecx * 4], eax								;проверяем адрес с каждым сохранённым адресом в таблице адресов локал-варов; 
	je		_vsila_ok_													;если есть совпадение, тогда на выход;
	jmp		_vsila_cycle_												;иначе проверяем дальше;
_vsila_nf_:
	xor		ecx, ecx													;если адрес не найден или кол-во активных локал-варов = 0, тогда вернём в eax = -1;
	dec		ecx
_vsila_ok_:
	xchg	eax, ecx													;
	pop		esi
	pop		ecx
	ret																	;выходим; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;конец функи vlca_search_index_lv_addr; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx





;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;функа vlca_reset_lv_state
;сброс накопленных состояний local-var в 0; 
;ВХОД:
;	eax		-	индекс в таблице адресов локал-варов, по которому можно взять адрес данного локал-вара; 
;ВЫХОД:
;	(+)		-	кол-во накопленных состояний этого local var теперь = 0; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
vlca_reset_lv_state:
	push	edi
	mov		edi, vlm_xlv_states_addr
	and		dword ptr [edi + eax * 4], 0								;сбрасываем состояния в 0; 
	pop		edi
	ret
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;конец функи vlca_reset_lv_state; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx


	
	
 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;!!!!! если логика не нужна, то эти функи раскоментить, а другие закоментить; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
comment !
let_init:
	xor		eax, eax
	ret		04

let_main:
	ret		04 * 2
		
let_exit:
	ret
		;!
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx




