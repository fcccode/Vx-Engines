DEFINES=-DCHECK_LOCK -DCHECK_ARGS -DYAD_ASM
CFLAGS = -Os -Wall -fomit-frame-pointer $(DEFINES)
.PHONY: test size all clean

all: size tester

yad.o:
	$(CC) $(CFLAGS) -c yad.c

size: yad.o
	size yad.o

tester: tester.c
	$(CC) $(CFLAGS) tester.c -o tester

test: tester
	./test.sh /usr/bin/mplayer

distr:
	zip -r yad`head -n 1 yad.c|sed 's/.*0\.\([0-9]*\).*/\1/'`.zip win/ mktable/ Makefile README tester.c test.sh BUGS yad.c yad_data.h yad.h

clean:
	-@rm -f tester dump.objdump dump.yad yad.o yad*.zip
