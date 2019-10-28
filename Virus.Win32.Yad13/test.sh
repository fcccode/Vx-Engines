#!/bin/sh
	echo $1
	./tester $1| cut -c -40|grep '^ 8'|sed 's/ *$//g' > dump.yad
	objdump -z -d -j .text $1 |cut -c -31|grep '^ 8'|sed 's/ *$//g' > dump.objdump
	diff dump.yad dump.objdump
