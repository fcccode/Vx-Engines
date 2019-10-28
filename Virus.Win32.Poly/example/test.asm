.586p
.model        flat, stdcall

callW                macro         __xxx
                     extrn         __xxx:proc
                     call          __xxx
                     endm

sizecrypted          equ           endcode-code

.data
string               db            "poly in da WiLd",0
cryptkey             dd            ?

.code
__start:
                     rdtsc
                     add           eax, edx
                     mov           cryptkey, eax
                     mov           ecx, sizecrypted
                     shr           ecx, 2
                     mov           edi, offset code
__spin_crypt:        xor           dword ptr[edi], eax
                     ror           dword ptr[edi], 16
                     sub           dword ptr[edi], eax
                     add           edi, 4
                     loop          __spin_crypt
                     
                     push          cryptkey
                     push          offset decrypt
                     push          sizecrypted
                     push          offset code
                     call          poly
                                          
                     call          decrypt
code:
                     push          0
                     push          offset string
                     push          offset string
                     push          0
                     callW         MessageBoxA
                     push          0
                     callW         ExitProcess
endcode:                     
decrypt:             db            1300    dup(0)
include              ..\bin\poly32bin.inc
end                  __start