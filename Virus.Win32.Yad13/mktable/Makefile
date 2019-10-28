all: mktable yad_data.h testrle test-c

test-c:
	./testrle

yad_data.h: mktable
	./mktable > yad_data.h 2> debug

%:	%.c
	$(CC) -DPACK6 -DNO_MODRM_ON_GRP -Wall $< -o $*

clean:
	-@rm -f yad_data.h mktable testrle debug

.PHONY: test-c clean all
