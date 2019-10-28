@echo off
tasm32 /m /ml pdemo.asm
ulink /Tpe /aa /x /c pdemo.obj, pdemo.exe
del pdemo.obj
pause