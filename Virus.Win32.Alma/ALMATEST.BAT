tasm32 /s /m /z /ml /la almatest.asm
tlink32 /Tpe /aa /c /x alma.obj almatest.obj,almatest.exe,, /L import32.lib