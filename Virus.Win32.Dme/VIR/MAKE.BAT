tasm32 /iC:\make\lib /ml /w0 /m9 /z silencer
tlink32 /Tpe /aa /c /x silencer,,, import32.lib
del silencer.obj
