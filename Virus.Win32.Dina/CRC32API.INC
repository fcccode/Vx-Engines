include crc32.inc
include crc32use.inc
;-------------------- Code ---------------------------------------------

;CRCSum: xor eax,eax
;Sum:    add eax,dword ptr [ebx]
;        cmp byte ptr [ebx+4],0
;        je ExitfromCRCSum
;        inc ebx
;        jmp Sum
;ExitfromCRCSum:
;           ret
CRCSum: xor eax,eax
Sum:    add eax,dword ptr [esi]
        cmp byte ptr [esi+4],0
        je_ ExitfromCRCSum
        inc esi
        jmp_ Sum
ExitfromCRCSum:
           ret
;----------------------------------------------------------------------