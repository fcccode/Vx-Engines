
	comment "================="
	comment "                 "
	comment "  Useful macros  "
	comment "                 "
	comment "================="

;Push offset to procedure onto stack
;Usage: push_of label1
push_of	macro __lbl
	local	skp_lb
	call	skp_lb
	jmp	__lbl
skp_lb:	endm

;get string hash macro
;long get_hash(const char *fname)
;{ long hash=0;
;  while(*(fname++)) hash=hash*31+*fname;
;}

g_hash	macro	fname
	local	_hash1, _hash2
	_hash1 = 0		;;I must use two variables because
	_hash2 = 0		;;TASM is sensitive to arithmetic overflow
	irpc	c,<fname>
	_hash1 = _hash1*31  + "&c"
	_hash2 = (_hash2*31 + (_hash1 shr 16)) and 0ffffh
	_hash1 = _hash1 and 0ffffh
	endm
	_hash1 = _hash1*31
	__ret_hash = (_hash1 and 0ffffh) + ((_hash2*31+(_hash1 shr 16)) shl 16)
	endm
;mov string hash macro
mov_h	macro	dest, fname
	g_hash	<fname>
	mov	dest, __ret_hash
	endm
;push string hash macro
push_h	macro	fname
	g_hash	<fname>
	push	__ret_hash
	endm


;Syntax:
; push_sz <some string>
; push_uz <some string>
;
;Push ascii/unicode zero-terminated string in C-like style onto stack
;You can use the next escape sequences:
;\n - 0ah - lf
;\r - 0dh - cr
;\t - 09h - tab
;\\ - "\" symbol
;\xYY - \XYY - hexadecimal number, were Y is one of 0-9, a-f, A-F
;\ZZZ - decimal number, were Z is one of 0-9 (less than 256)
;
;push_sz <kernel32>
;is same as the sequence:
;push 0
;push '23le'
;push 'nrek'
;
;Examples:
; push_sz <Vx rules!!!!\r\n\tyeah>
; push_sz <Vx rules!!!!\r\X0a\x09yeah>
; push_sz <Vx rules!!!!\013\x0A\tyeah>
; will push the next zero-terminated string onto stack:
;
;"Vx rules!
;	yeah"	   ;;'!' is a special symbol and '!!!!' equal '!'
;
; push_sz <\053ab>      - will be <push 'ba5'> => "5ab" (053 - decimal code of '5')
; push_sz <\x331\05137> - will be <push '7'/push '3313'> => "31337" (33h=051=code of '3')
;
;Possible Errors:
; push_uz <some \sfdf>      - unknown speciefier '\s'
; push_sz <possible \x2ghh> - invalid hex number '2g'
; push_uz <mistakes\x0 ff>  - invalid hex number '0 ' (use 2 digits \x00)
; push_uz <in your\0>       - invalid decimal number '0  '(use 3 digits \000)
; push_uz <code\345>        - value out of range (greater then 255)
;
push_au	macro	au, fstr
	local	pvar, cnt, es, cn, idx1, idx2, len, ln
	local	hex, dcm, hid

	es = 0
	len = 0
	irpc	c1, <fstr>
	  len = len+1
	  if es eq 1
	    if (("&c1" ge "0") and ("&c1" le "9")) or ("&c1" eq "x") or  ("&c1" eq "X")
	      len = len-3
	    else
	      len = len-1
	    endif
	    es = 0
	  elseif "&c1" eq "\"
	    es = 1
	  endif
	endm

	idx2 = len
	ln = (len shr 2) + 1
	if au eq 1
	  ln = (len shr 1) + 1
	endif

	rept ln
	  pvar = 0
	  cnt  = 0
	  hex  = 0
	  dcm  = 0
	  hid  = 0
	  cn   = 0
	  es   = 0
	  idx  = 0
	  irpc	c, <fstr>
	  ;;process escape sequences
	  if     ("&c" eq "n") and (es eq 1)			;;lf
            cn = 10
	  elseif ("&c" eq "r") and (es eq 1)			;;cr
	    cn = 13
	  elseif ("&c" eq "t") and (es eq 1)			;;tab
	    cn = 9
	  elseif (("&c" eq "x") or  ("&c" eq "X")) and (es eq 1)	;;hex number
	    hex = 1
	    cn  = 0
	    es  = 0
	  elseif (("&c" ge "0") and ("&c" le "9")) and \
	         ((es eq 1) or (dcm eq 1))			;;decimal number
	    if dcm eq 0
	      cn = 0
	    endif
	    dcm = 1
	    cn = cn*10 + "&c" - "0"
	    if cn ge 100h
	      .err "push_ua: val out of range \YYY"
	    endif
	    hid = hid+1
	    es = 0
	  ;;process hex digits
	  elseif hex eq 1
	    if     ("&c" ge "A") and ("&c" le "F")
	      cn = (cn shl (4*hid)) + "&c" - "A" + 0ah
	    elseif ("&c" ge "a") and ("&c" le "f")
	      cn = (cn shl (4*hid)) + "&c" - "a" + 0ah
	    elseif ("&c" ge "0") and ("&c" le "9")
	      cn = (cn shl (4*hid)) + "&c" - "0"
	    else
	      .err "push_ua: use \XYY or \xYY (Y can be 0-9,a-f,A-F)"
	    endif
	    hid = hid+1
	  elseif (es eq 1) and ("&c" ne "\")
	    .err "push_ua: unknown speciefer \&c"
	  else
	    cn = "&c"
	  endif

	  if (("&c" ne "\") or (es ne 0)) and ((hex eq 0) or (hid ge 2)) and ((dcm eq 0) or (hid ge 3))
	    hex  = 0
	    dcm  = 0
	    hid  = 0
	    es   = 0
	    pvar = pvar + (cn shl (8*cnt)) 
	    cnt  = cnt+1+(au)
	    if cnt eq 4
	      if ((idx gt idx2) and (au eq 0)) or ((idx ge idx2) and (au eq 1))
	        exitm
	      endif
	      pvar = 0
	      cnt  = 0
	    endif
	    idx  = idx+1
	  elseif ((hex eq 0) or (hid ge 2)) and ((dcm eq 0) or (hid ge 3))
	    es = 1
	  endif

	  endm	;;internal IRPC

	  if idx ge idx2
	    push pvar
	  endif
	  idx2 = idx2-2
	  if au eq 0
	    idx2 = idx2-2
	  endif
	endm	;;external REPT
	
	endm

push_sz	macro	fstr
	push_au	0, <fstr>
	endm

push_uz	macro	fstr
	push_au	1, <fstr>
	endm

















