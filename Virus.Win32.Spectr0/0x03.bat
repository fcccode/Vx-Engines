@echo	off
C:\masm32\bin\ml /c /coff /nologo /I C:\masm32\include 0x03.asm
C:\masm32\bin\link /subsystem:windows /section:.text,RWE /nologo 0x03.obj /libpath:C:\masm32\lib
if	exist "0x03.obj" del 0x03.obj
pause
cls
