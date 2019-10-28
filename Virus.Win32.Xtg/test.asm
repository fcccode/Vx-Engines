;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
;										  																 ;
;										  ТЕСТ ДВИЖКОВ 													 ;
;										RANG32, xTG, FAKA												 ;
;						(rang32.asm, faka.asm, xtg.inc, xtg.asm, logic.asm)								 ; 
;																										 ; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;

																		;m1x
																		;pr0mix@mail.ru
																		;EOF 

.386
.model flat, stdcall
option casemap:none

include windows.inc
include kernel32.inc
include user32.inc
include gdi32.inc

includelib kernel32.lib
includelib user32.lib
includelib gdi32.lib





.data
rdata_buf					db		1000h	dup	(00)
rd_size						equ		$ - rdata_buf - 1
xdata_buf					db		1000h	dup	(00)
xd_size						equ		$ - xdata_buf - 1
xtg_trash_gen_buf			db		1000h	dup	(00)					;буферы под различные нужды; 
faka_fakeapi_gen_buf		db		1000h	dup	(00) 
xtg_func_struct_buf			db		1000h	dup	(00)
trash_code_buf				db		5000h	dup	(00)
tcb_size					equ		$ - trash_code_buf - 0C4Eh
xtg_data_struct_buf			db		1000h	dup	(00)

path_buf					db		1000h	dup	(00)
pb_size						equ		$ - path_buf - 1

szMsg						db	'test engines OK!', 0





.code

engines:
include		rang32.asm													;подключение движков
include		xtg.inc	
include		xtg.asm
include		faka.asm
include		logic.asm



;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;функа xVirtualAlloc
;функа выделения памяти;
;ВХОД (stdcall: (DWORD xVirtualAlloc(DWORD xsize))):
;	xsize	-	сколько байт нужно выделить;
;ВЫХОД:
;	(+)		-	выделенная память;
;	EAX		-	адрес выделенной памяти; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
xVirtualAlloc:
	pushad
	mov		eax, dword ptr [esp + 24h]
	
	push	PAGE_EXECUTE_READWRITE
	push	MEM_RESERVE + MEM_COMMIT
	push	eax
	push	0
	call	VirtualAlloc
	
	mov		dword ptr [esp + 1Ch], eax
	popad
	ret		04
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;конец функи xVirtualAlloc; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx



;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;функа xVirtualFree
;освобождение (ранее выделенной) памяти
;ВХОД (stdcall: (DWORD/VOID xVirtualFree(DWORD xaddr))):
;	xaddr	-	адрес памяти, которую нужно освободить
;ВЫХОД:
;	(+)		-	память освобождена, все спасены =)
;	
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx	
xVirtualFree:
	pushad
	mov		eax, dword ptr [esp + 24h]
	
	push	MEM_RELEASE
	push	0
	push	eax
	call	VirtualFree
	
	popad
	ret		04
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;конец функи xVirtualFree 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx





;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;ПОЕХАЛИ!
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
xstart:
	push	0
	call	GetModuleHandleA											;получаем базовый адрес загрузки (также можно через fs etc); 

	push	pb_size
	push	offset path_buf
	push	eax
	call	GetModuleFileNameA											;получаем имя этого файла
	
	push	0 
	push	FILE_ATTRIBUTE_NORMAL
	push	OPEN_EXISTING
	push	0
	push	FILE_SHARE_READ + FILE_SHARE_WRITE
	push	GENERIC_READ
	push	offset path_buf
	call	CreateFileA													;открываем на чтение наш файлек

	;inc	eax															;не будем делать здесь разных проверок; 
	;je		__
	;dec	eax

	push	eax
	xor		ebx, ebx 
	
	push	ebx
	push	ebx
	push	ebx
	push	PAGE_READONLY
	push	ebx
	push	eax
	call	CreateFileMapping											;создаём проекцию файла

	push	eax

	push	ebx
	push	ebx
	push	ebx
	push	FILE_MAP_READ
	push	eax
	call	MapViewOfFile												;проецируем

	push	eax
	xchg	eax, edi													;в edi теперь база мэппинга файла; 
;-----------------------------------------------------------------------;сначала проверим совместную работу движков RANG32 + xTG + FAKA																		
	lea		eax, xtg_trash_gen_buf
	xchg	eax, ecx
	assume	ecx: ptr XTG_TRASH_GEN										;и начнём заполнять структуру XTG_TRASH_GEN
	mov		[ecx].fmode, XTG_REALISTIC									;режим реалистичность
	mov		[ecx].rang_addr, RANG32										;адрес ГСЧ
	mov		[ecx].faka_addr, FAKA										;адрес движка генерации фэйковых винапишек
	lea		ebx, faka_fakeapi_gen_buf
	mov		[ecx].faka_struct_addr, ebx									;передадим адрес будущей структуры для движка FAKA; 
	;lea	eax, xtg_func_struct_buf
	mov		[ecx].xfunc_struct_addr, 0 ;eax								;здесь суём 0 - так как движок будет сам генерировать функи (с прологами, эпилогами и т.п.); 
	mov		[ecx].alloc_addr, xVirtualAlloc								;адрес функи выделения памяти
	mov		[ecx].free_addr, xVirtualFree								;адрес функи освобождения памяти
	lea		eax, trash_code_buf 
	mov		[ecx].tw_trash_addr, eax									;сюда будем генерировать мусорные команды
	mov		[ecx].trash_size, tcb_size									;размер этого мусора
	mov		[ecx].xmask1, (XTG_FUNC + XTG_REALISTIC_WINAPI + XTG_LOGIC)	;указываем, что будем генерировать функи и винапишки, а также что мусор будет логичным (в режиме "реалистик"); 
	mov		[ecx].xmask2, 0												; 
	mov		[ecx].fregs, 0 												;все реги могут быть использованы при генерации команд (ну кроме изменения без восстановления esp и ebp); 
	lea		edx, xtg_data_struct_buf
	mov		[ecx].xdata_struct_addr, edx								;адрес будущей структуры XTG_DATA_STRUCT; 
																		;так, структуру XTG_TRASH_GEN заполнили, поехали дальше
	assume	edx: ptr XTG_DATA_STRUCT									;заполним теперь XTG_DATA_STRUCT; 
	mov		[edx].xmask, XTG_DG_ON_XMASK								;указываем, что будем генерить ещё и трэш-даные: строки и числа; 
	lea		eax, rdata_buf
	mov		[edx].rdata_addr, eax										;буфер, куда будут записаны трэш-данные
	mov		[edx].rdata_size, rd_size									;размер этого буфера
	mov		[edx].rdata_pva, XTG_VIRTUAL_ADDR							;указываю, что в rdata_addr адрес передан виртуальный (а не физический); 
	lea		eax, xdata_buf	
	mov		[edx].xdata_addr, eax										;а адреса в этой области памяти будут применяться некоторыми сгенерированными командами, например, вот такая: inc dword ptr [403008h] -> 403008h - может быть адресом в данной области памяти; 
	mov		[edx].xdata_size, xd_size									;размер данной области памяти;

	assume	ebx: ptr FAKA_FAKEAPI_GEN									;так, теперь заполним структуру FAKA_FAKEAPI_GEN
	mov		[ebx].mapped_addr, edi										;адрес файла в памяти (aka база мэппинга)
	mov		[ebx].rang_addr, RANG32										;адрес ГСЧ
	mov		[ebx].alloc_addr, xVirtualAlloc								;адрес функи выделения памяти
	mov		[ebx].free_addr, xVirtualFree								;адрес функи освобождения памяти
	mov		[ebx].xfunc_struct_addr, 0									;тут ставим 0, так как FAKA сейчас будет использоваться в движке xTG - а xTG будет сам генерить функи (с прологами etc) (флаг XTG_FUNC); 
	mov		[ebx].tw_api_addr, 0 										;тут тоже ставим 0, так как FAKA сейчас будет юзаться в движке xTG, который сам заполнет данное поле нужным значением (мы ведь точно не знаем, где именно будет сгенерирована апишка=)); 
	mov		[ebx].api_size, 0 											;etc
	mov		[ebx].xdata_struct_addr, edx								;указываем адрес на ту же структуру, что и в аналогичном поле структуры XTG_TRASH_GEN - по той же причине - FAKA & xTG работают сейчас вместе; 
	mov		[ebx].api_hash, 0											;будем генерить винапишки из заранее подготовленного набора в FAKA (таблица хэшей); 
 
	push	ecx 
	call	xTG															;вызываем двигл xTG
 
	pushad																;сохраним текущие значения всех регов в стеке; 
	mov		eax, [ecx].nobw												;кол-во реально записанных байт; 
	mov		eax, [ecx].fnw_addr											;eax = адрес для дальнейшей записи кода (при выходе из xTG он равен этому же значению - просто проверяем данное поле); 
	;mov	byte ptr [eax], 0C3h
	call	[ecx].ep_trash_addr											;точка входа в мусор: сейчас будет выполняться только что сгенерированный трэш-код; 
	popad																;восстановим; 
;-----------------------------------------------------------------------;теперь проверим работу RANG32 + xTG
	mov		[ecx].fmode, XTG_MASK										;теперь зададим режим "маска"
	mov		[ecx].faka_addr, 0											;отключаем FAKA; 
	mov		[ecx].faka_struct_addr, 0									;
	mov		[ecx].xmask1, XTG_MOV_XCHG___R32__R32						;указываем, какие команды будем генерить в этом режиме;
	add		[ecx].xmask1, (XTG_MOV_R32_R16__IMM32_IMM16 + XTG_ADC_ADD_AND_OR_SBB_SUB_XOR___R32_R16__R32_R16)
	mov		[ecx].xmask2, XTG_ADC_ADD_AND_OR_SBB_SUB_XOR___M32_M8__IMM32_IMM8
	mov		[ecx].fregs, (XTG_ECX + XTG_EDI) 							;ecx и edi после выполнения сгенерированного трэш-кода не изменят своих значений (так как мы еще и отрубили генерацию винапишек); 
																		
	mov		[edx].xmask, XTG_DG_STRA									;указываем, что будем генерить ещё и трэш-даные - на этот раз только строки; 
	
	push	ecx
	call	xTG															;снова вызываем двигл xTG; 

	pushad
	mov		eax, [ecx].nobw												;кол-во реально записанных байт; 
	mov		eax, [ecx].fnw_addr											;eax = адрес для дальнейшей записи кода (при выходе из xTG он равен этому же значению - просто проверяем данное поле); 
	mov		byte ptr [eax], 0C3h										;так как мы генерили конкретные команды, то в конце трэш-кода поставим ret - чтобы снова перейти на тест движков; 
	call	[ecx].ep_trash_addr											;точка входа в мусор: сейчас будет выполняться только что сгенерированный трэш-код; 
	popad
;-----------------------------------------------------------------------;теперь проверим RANG32 + FAKA; 
	mov		[ebx].mapped_addr, edi										;адрес файла в памяти (aka база мэппинга)
	mov		[ebx].rang_addr, RANG32										;адрес ГСЧ
	mov		[ebx].alloc_addr, xVirtualAlloc								;адрес функи выделения памяти
	mov		[ebx].free_addr, xVirtualFree								;адрес функи освобождения памяти
	mov		[ebx].xfunc_struct_addr, 0									;тут ставим 0, так как не генерим сейчас функи (с прологами etc); 
	lea		eax, trash_code_buf
	mov		[ebx].tw_api_addr, eax 										;адрес буфера, куда сгенерим фэйк-апи; 
	mov		[ebx].api_size, tcb_size  									;размер этого буфера (или можно поставить, например, WINAPI_MAX_SIZE); 
	mov		[ebx].xdata_struct_addr, edx								;указываем адрес на заполненную структуру XTG_DATA_STRUCT; 
	mov		[ebx].api_hash, 0B1866570h									;будем генерить конкретно GetModuleHandleA; 

	push	ebx
	call	FAKA														;вызываем FAKA'у; 

	pushad
	mov		eax, [ebx].fnw_addr
	mov		byte ptr [eax], 0C3h
	call	[ebx].tw_api_addr											;выполним только что сгенеренный вызов винапишки; 
	popad

;-----------------------------------------------------------------------;теперь проверим только RANG32

	push	05
	call	RANG32														;вот и всё;

;-----------------------------------------------------------------------; 	
	call	UnmapViewOfFile 
	call	CloseHandle
	call	CloseHandle
 
	xor		eax, eax
	lea		ecx, szMsg
	
	push	eax
	push	ecx 
	push	ecx
	push	eax
	call	MessageBoxA 

	jmp		_xtest_ret_



;comment !
	call	QueryPerformanceCounter
	call	QueryPerformanceFrequency
	call	lstrcmpiA
	call	lstrcmpA
	call	lstrcpyA
	call	lstrlenA
	call	GetSystemTime
	call	GetLocalTime
	call	GetVersion; 
	call	GetOEMCP; 
	call	GetCurrentThreadId
	call	GetCurrentProcess
	call	GetTickCount
	call	GetCurrentProcessId
	call	GetProcessHeap
	call	GetACP
	call	GetCommandLineA
	call	GetCurrentThread
	call	IsDebuggerPresent
	call	GetThreadLocale
	call	GetCommandLineW
	call	GetSystemDefaultLangID
	call	GetSystemDefaultLCID
	call	GetUserDefaultUILanguage
	call	Sleep
	call	MulDiv
	call	IsValidCodePage
	call	GetDriveTypeA
	call	IsValidLocale
	call	GetModuleHandleA
	call	LoadLibraryA
	call	GetProcAddress

	call	GetFocus
	call	GetDesktopWindow
	call	GetCursor
	call	GetActiveWindow
	call	GetForegroundWindow
	call	GetCapture
	call	GetMessagePos
	call	GetMessageTime
	call	GetDlgItem
	call	GetParent
	call	GetSystemMetrics
	call	GetWindow
	call	IsDlgButtonChecked
	call	IsWindowVisible
	call	IsIconic
	call	IsWindowEnabled
	call	CheckDlgButton
	call	GetSysColor
	call	GetKeyState
	call	GetDlgCtrlID
	call	GetSysColorBrush
	call	SetActiveWindow
	call	IsChild
	call	GetTopWindow
	call	GetKeyboardType
	call	GetKeyboardLayout
	call	IsZoomed
	call	GetWindowTextLengthA
	call	DrawIcon
	call	GetClientRect
	call	GetWindowRect
	call	CharNextA
	call	GetCursorPos
	call	LoadIconA
	call	LoadCursorA
	call	FindWindowA

	call	SelectObject
	call	SetTextColor
	call	SetBkColor
	call	SetBkMode
	call	Rectangle
	call	GetTextColor
	call	GetBkColor
	call	SetROP2
	call	GetCurrentObject
	call	Ellipse
	call	GetNearestColor
	call	GetObjectType
	call	PtVisible
	call	GetMapMode
	call	GetBkMode
		;!

_xtest_ret_:
	ret
end xstart
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;VX! 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx



 


 