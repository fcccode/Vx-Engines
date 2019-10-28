CreateFile		dd	0
ReadFile		dd	?
WriteFile		dd	?
CloseHandle		dd	?
FindFirstFile		dd	?
FindNextFile		dd	?
FindClose		dd	?
FSeek			dd	?
CreateThread		dd	?
ExitThread		dd	?
imnum	equ	($ - CreateFile) shr 2	; Количество импортируемых функций

VirFindData	        label
dwFileAttributes	dd ?
ftCreationTime		dq ?
ftLastAccessTime	dq ?
ftLastWriteTime		dq ?
nFileSizeHigh		dd ?
nFileSizeLow		dd ?
dwReserved0		dd ?
dwReserved1		dd ?
cFileName		db MAX_PATH dup (?)
cAlternateFileName	db 14 dup (0)

sects		db	2Ch dup (0);
free		dd	0
need		db	400h dup (0);
