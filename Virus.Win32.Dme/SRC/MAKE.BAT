tasm32 /iC:\make\lib /ml /w0 /m9 /z test
tlink32 /Tpe /aa /c /x test,,, import32.lib
del test.obj
