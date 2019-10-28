all		:	kpasm 
poly_fonctions.h : 	poly_fonctions.asm
			cat poly_fonctions.asm | ascii2c > poly_fonctions.h
lex.yy.c	:	kpasm.l kpasm.tab.h
			flex -i -l kpasm.l
kpasm.tab.c	:	kpasm.y kpasm.l kpasm.h linkedlist.h kasm.h 
			bison -v kpasm.y

kpasm.tab.h	:	kpasm.y
			bison -v -d kpasm.y

kpasm		:	kpasm.tab.c linkedlist.c utils.c lex.yy.c kasm.c poly_fonctions.h verif.c verif.h
			gcc -g -o kpasm kpasm.tab.c linkedlist.c kasm.c utils.c verif.c -ll
clean		:	
			rm -f lex.yy.c *.o kpasm.tab.c kpasm.tab.h kpasm kpasm.output poly_assembleur.asm poly_defines.inc *~ poly_fonctions.h

