DEBUG   EQU 1  ; Так отладка возможна.
NODEBUG EQU 0  ; А так затрудняется
DEBUGFLAG EQU DEBUG

         EXCEPTION_SINGLE_STEP EQU 080000004h
         EXCEPTION_BREAKPOINT EQU 080000003h
   EXCEPTION_ACCESS_VIOLATION EQU 0C0000005h
EXCEPTION_ILLEGAL_INSTRUCTION EQU 0C000001Dh

 IF DEBUGFLAG
    EXEPTION EQU dw 0ffffh,090c3h,9090h
    ELSE
    EXEPTION EQU db 0cch
 ENDIF
 IF DEBUGFLAG
  BreakPoint EQU db 0cch
    ELSE
  BreakPoint EQU ;
 ENDIF

callEx macro Arg
       ; call Arg
       push z&Arg
       exeption
       endm

