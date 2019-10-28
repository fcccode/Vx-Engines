; ---------------------------------------------------------------------------
; ADE32   v2.02   (AUTO-GENERATED FILE)   (x) 1999-2002 http://z0mbie.cjb.net
; ---------------------------------------------------------------------------
ade32_size              equ     517+382+116  ; == 1015

disasm_struct           struct                  ; disasm()  asm()
disasm_defaddr          db      ?               ;  in/out  unused
disasm_defdata          db      ?               ;  in/out  unused
disasm_len              dd      ?               ;2    out     out  ==ret.value
disasm_flag             dd      ?               ;6    out     in
disasm_addrsize         dd      ?               ;a    out     in
disasm_datasize         dd      ?               ;e    out     in
disasm_rep              db      ?               ;12    out     in
disasm_seg              db      ?               ;13    out     in
disasm_opcode           db      ?               ;14    out     in
disasm_opcode2          db      ?               ;15    out     in
disasm_modrm            db      ?               ;16    out     in
disasm_sib              db      ?               ;17    out     in
disasm_addr             db      8 dup (?)       ;1f    out     in
disasm_data             db      8 dup (?)       ;27    out     in
ends

;<----Start my staff---->
ComandInfo 			struct
		InfCmd			disasm_struct ?
		_Flag			db	?
								; 0 - normal comand
								; 1 - jmp
								; 2 - call
								; 3 - jcc
								; 4 - bad 
		_AddrComand		dd	?
		_AddrTrans		dd	? 	; reserved 
		_NextrStr		dd	? 	; next stucure
		_PreStr			dd	? 	; previos stucture
		_NStr			dd	? 	; "virtual" address
		_Label			dd	? 	; 0 - nothing
								; 1 - Label
								; > 1 - end address of transition
		_NoMove			db	?
ends
SizeStruct	=	size ComandInfo

_BaseStr			struct
		_FreeMem		dd	? ; address free memory
		_HeadListStr	dd	? ; start list disassemble structure
		_CmdNum			dd	? ; amount of commands
		ListEnd			dd	? ; end list disassemble structure
		_TblOpcode		dd	? ; table of opcode
;-----
;any information
;-----
ends
;<----End my staff---->

C_ERROR                 equ     -1              ; ==invalid opcode
C_ADDR1                 equ     00000001h       ; |
C_ADDR2                 equ     00000002h       ; |may be used simultaneously
C_ADDR4                 equ     00000004h       ; |
C_LOCK                  equ     00000008h       ; have LOCK prefix
C_67                    equ     00000010h       ; defaddr: 2 <--> 4
C_66                    equ     00000020h       ; defdata: 2 <--> 4
C_REP                   equ     00000040h       ; have REPx prefix (F2/F3)
C_SEG                   equ     00000080h       ; have SEG prefix
C_ANYPREFIX             equ     (C_66+C_67+C_LOCK+C_REP+C_SEG)
C_DATA1                 equ     00000100h       ; |
C_DATA2                 equ     00000200h       ; |may be used simultaneously
C_DATA4                 equ     00000400h       ; |
C_SIB                   equ     00000800h       ; SIB present
C_ADDR67                equ     00001000h       ; addrsize += defaddr
C_DATA66                equ     00002000h       ; datasize += defdata
C_MODRM                 equ     00004000h       ; MODxxxR/M
C_BAD                   equ     00008000h       ; unusual for PE EXE/DLL
C_OPCODE2               equ     00010000h       ; have 2nd opcode (0F o2)
C_REL                   equ     00020000h       ; have relative argument (jxx)
C_STOP                  equ     00040000h       ; control xfer (ret,jmp)
C_OPCODE2_LG2           equ     16              ; }
C_REL_LG2               equ     17              ; } for optimization
C_STOP_LG2              equ     18              ; }

ade32_begin:
ade32_init:
                db 060h,08Bh,07Ch,024h,024h,0FCh,033h,0C0h
                db 050h,050h,050h,068h,0B6h,0A3h,00Dh,000h
                db 068h,0FFh,03Fh,000h,0D8h,068h,0F3h,0FFh
                db 03Fh,0C8h,068h,097h,007h,0DBh,0CBh,068h
                db 0FFh,0FFh,0FFh,0B6h,068h,0A5h,094h,052h
                db 0FFh,068h,094h,052h,04Ah,029h,068h,000h
                db 04Ah,029h,0A5h,050h,050h,050h,050h,050h
                db 050h,050h,068h,0FFh,007h,063h,0DBh,068h
                db 06Bh,0DFh,06Eh,0EDh,068h,05Bh,00Dh,0D5h
                db 0D3h,068h,034h,0E9h,06Bh,06Ch,068h,024h
                db 08Ah,0A2h,0A8h,068h,0FFh,07Fh,09Eh,0A7h
                db 068h,0FBh,02Fh,08Ah,0EDh,068h,06Bh,0D5h
                db 06Dh,0ABh,068h,092h,0E4h,0ACh,036h,068h
                db 059h,0D6h,0A1h,05Dh,068h,008h,002h,021h
                db 004h,068h,08Ch,0A2h,018h,042h,068h,0EBh
                db 0C6h,018h,063h,068h,0D8h,076h,00Ch,0B6h
                db 068h,06Dh,026h,093h,0C9h,068h,06Dh,06Bh
                db 07Dh,0B7h,068h,0A5h,0A5h,06Dh,0B7h,068h
                db 00Ah,096h,0FFh,0FFh,068h,053h,04Ah,049h
                db 0CEh,068h,052h,04Ah,029h,0CFh,068h,0F3h
                db 03Ch,0A5h,094h,068h,0C8h,046h,0B9h,06Dh
                db 068h,053h,0A8h,045h,073h,068h,06Dh,0B7h
                db 092h,0A4h,068h,0B6h,06Dh,0DBh,076h,068h
                db 0DBh,076h,06Dh,0DBh,068h,0C2h,0DAh,076h
                db 06Dh,068h,020h,0ECh,07Fh,00Ch,068h,00Ch
                db 0C2h,0FEh,0C7h,068h,0C7h,020h,0ECh,07Fh
                db 068h,0BFh,028h,0D0h,0FEh,068h,0B4h,028h
                db 0D0h,04Ah,068h,031h,054h,090h,0B4h,068h
                db 0FFh,031h,0B4h,0FFh,033h,0C9h,0B5h,002h
                db 033h,0DBh,0E8h,010h,000h,000h,000h,00Bh
                db 0DBh,075h,008h,05Bh,05Eh,05Ah,056h,053h
                db 06Ah,020h,05Bh,04Bh,0D1h,0EAh,0C3h,05Dh
                db 033h,0C0h,0E8h,005h,000h,000h,000h,0ABh
                db 0E2h,0F6h,061h,0C3h,0FFh,0D5h,073h,03Ah
                db 0FFh,0D5h,073h,003h,0B4h,040h,0C3h,0FFh
                db 0D5h,072h,02Ch,0FFh,0D5h,073h,01Eh,0FFh
                db 0D5h,073h,014h,0FFh,0D5h,072h,00Ah,0FFh
                db 0D5h,073h,003h,0B4h,060h,0C3h,0B4h,010h
                db 0C3h,0B8h,000h,081h,002h,000h,0C3h,0B8h
                db 000h,001h,002h,000h,0C3h,0FFh,0D5h,073h
                db 003h,0B4h,001h,0C3h,0B4h,020h,0C3h,0B4h
                db 080h,0C3h,0FFh,0D5h,00Fh,083h,0B1h,000h
                db 000h,000h,0FFh,0D5h,073h,001h,0C3h,0FFh
                db 0D5h,073h,074h,0FFh,0D5h,073h,06Ah,0FFh
                db 0D5h,073h,025h,0FFh,0D5h,072h,017h,0FFh
                db 0D5h,073h,006h,0B8h,000h,080h,004h,000h
                db 0C3h,0FFh,0D5h,073h,003h,0B0h,080h,0C3h
                db 0B8h,000h,002h,004h,000h,0C3h,0FFh,0D5h
                db 072h,003h,0B0h,040h,0C3h,0B4h,0A2h,0C3h
                db 0FFh,0D5h,073h,01Dh,0FFh,0D5h,072h,00Dh
                db 0FFh,0D5h,073h,006h,0B8h,000h,082h,004h
                db 000h,0C3h,0B0h,020h,0C3h,0FFh,0D5h,072h
                db 003h,0B4h,003h,0C3h,00Fh,0BAh,0F8h,012h
                db 0C3h,0FFh,0D5h,072h,00Fh,0FFh,0D5h,072h
                db 005h,066h,0B8h,008h,080h,0C3h,0B8h,000h
                db 001h,006h,000h,0C3h,0FFh,0D5h,073h,003h
                db 0B0h,010h,0C3h,0B8h,000h,020h,006h,000h
                db 0C3h,0B8h,000h,020h,002h,000h,0C3h,0FFh
                db 0D5h,073h,00Ah,0FFh,0D5h,073h,003h,0B4h
                db 041h,0C3h,0B4h,0C0h,0C3h,0FFh,0D5h,073h
                db 003h,0B4h,081h,0C3h,0FFh,0D5h,073h,005h
                db 066h,0B8h,080h,080h,0C3h,0FFh,0D5h,072h
                db 006h,0B8h,000h,0A0h,000h,000h,0C3h,0FFh
                db 0D5h,073h,003h,0B4h,0C1h,0C3h,00Fh,0BAh
                db 0F8h,010h,0C3h,048h,0C3h
ade32_disasm:
                db 060h,033h,0C0h,033h,0D2h,08Bh,06Ch,024h
                db 028h,08Dh,07Dh,002h,06Ah,026h,059h,0FCh
                db 0F3h,0AAh,08Bh,07Ch,024h,02Ch,08Bh,074h
                db 024h,024h,066h,03Bh,006h,00Fh,084h,07Eh
                db 000h,000h,000h,066h,083h,03Eh,0FFh,074h
                db 078h,08Ah,006h,046h,08Bh,01Ch,087h,0F6h
                db 0C3h,0F8h,075h,071h,00Bh,0D3h,088h,045h
                db 014h,03Ch,00Fh,00Fh,084h,09Eh,000h,000h
                db 000h,03Ch,0F7h,00Fh,084h,0B7h,000h,000h
                db 000h,03Ch,0F6h,00Fh,084h,0A5h,000h,000h
                db 000h,03Ch,0CDh,00Fh,084h,0B1h,000h,000h
                db 000h,0F6h,0C6h,040h,00Fh,085h,0B2h,000h
                db 000h,000h,089h,055h,006h,08Ah,0C6h,066h
                db 081h,0E2h,007h,007h,0A8h,010h,074h,003h
                db 002h,055h,000h,0A8h,020h,074h,003h,002h
                db 075h,001h,00Fh,0B6h,0CAh,089h,04Dh,00Ah
                db 0E3h,005h,08Dh,07Dh,018h,0F3h,0A4h,08Ah
                db 0CEh,089h,04Dh,00Eh,0E3h,005h,08Dh,07Dh
                db 020h,0F3h,0A4h,02Bh,074h,024h,024h,096h
                db 089h,045h,002h,089h,044h,024h,01Ch,061h
                db 0C3h,033h,0C0h,0EBh,0F3h,08Ah,0E3h,022h
                db 0E2h,080h,0E4h,0F8h,075h,0F3h,00Bh,0D3h
                db 0F6h,0C3h,010h,075h,024h,0F6h,0C3h,020h
                db 075h,019h,0F6h,0C3h,080h,075h,00Fh,0F6h
                db 0C3h,040h,075h,005h,0E9h,060h,0FFh,0FFh
                db 0FFh,088h,045h,012h,0EBh,0F6h,088h,045h
                db 013h,0EBh,0F1h,080h,075h,001h,006h,0EBh
                db 0EBh,080h,075h,000h,006h,0EBh,0E5h,08Ah
                db 006h,046h,088h,045h,015h,00Bh,094h,087h
                db 000h,004h,000h,000h,083h,0FAh,0FFh,074h
                db 0B0h,0E9h,063h,0FFh,0FFh,0FFh,0F6h,006h
                db 038h,075h,0F6h,080h,0CEh,001h,0EBh,0F1h
                db 0F6h,006h,038h,075h,0ECh,080h,0CEh,020h
                db 0EBh,0E7h,080h,03Eh,020h,075h,0E2h,080h
                db 0CEh,004h,0EBh,0DDh,08Ah,006h,046h,088h
                db 045h,016h,050h,024h,038h,03Ch,020h,058h
                db 075h,00Ah,080h,07Dh,014h,0FFh,075h,004h
                db 00Fh,0BAh,0FAh,012h,08Ah,0E0h,066h,025h
                db 007h,0C0h,080h,0FCh,0C0h,074h,028h,080h
                db 07Dh,000h,002h,074h,02Ch,03Ch,004h,075h
                db 00Bh,080h,0CEh,008h,08Ah,006h,046h,088h
                db 045h,017h,024h,007h,080h,0FCh,040h,074h
                db 013h,080h,0FCh,080h,074h,006h,066h,03Dh
                db 005h,000h,075h,003h,080h,0CAh,004h,0E9h
                db 0FEh,0FEh,0FFh,0FFh,080h,0CAh,001h,0EBh
                db 0F6h,066h,03Dh,006h,000h,074h,00Ah,080h
                db 0FCh,040h,074h,0F0h,080h,0FCh,080h,075h
                db 0E6h,080h,0CAh,002h,0EBh,0E1h
ade32_asm:
                        pusha

                        mov     edi, [esp+32+4]  ; outptr
                        mov		ebx, [esp+32+8]
                        cld
        mov     edx, [ebx].disasm_flag
        test    dl, C_SEG
        jz      @@not_seg
        mov     al, [ebx].disasm_seg
        stosb
@@not_seg:
        test    dl, C_LOCK
        jz      @@not_lock
        mov     al, 0F0h
        stosb
@@not_lock:
        test    dl, C_REP
        jz      @@not_rep
        mov     al, [ebx].disasm_rep
        stosb
@@not_rep:
        test    dl, C_67
        jmp      @@not_67
        mov     al, 67h
        stosb
@@not_67:
        test    dl, C_66
        jz      @@not_66
        mov     al, 66h
        stosb
@@not_66:
        mov     al, [ebx].disasm_opcode
        stosb
;        bt      edx, C_OPCODE2_LG2
;        jnc     @@not_opcode2

        mov     al, [ebx].disasm_opcode2
        or		al, al
        jz		@@not_opcode2
        stosb
@@not_opcode2:
        test    dh, C_MODRM shr 8
        jz      @@not_modrm
        mov     al, [ebx].disasm_modrm
        stosb
@@not_modrm:
        test    dh, C_SIB shr 8
        jz      @@not_sib
        mov     al, [ebx].disasm_sib
        stosb
@@not_sib:
        lea     esi, [ebx].disasm_addr
        mov     ecx, [ebx].disasm_addrsize
        rep     movsb
        lea     esi, [ebx].disasm_data
        mov     ecx, [ebx].disasm_datasize
        rep     movsb
        sub		edi, [esp+32+4]
        mov		[esp].popa_eax, edi
        popa
        retn
ade32_end:
