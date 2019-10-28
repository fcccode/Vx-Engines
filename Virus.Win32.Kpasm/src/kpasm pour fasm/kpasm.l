%{
#include <malloc.h>
#include <string.h>
#include "kpasm.h"
#include "kpasm.tab.h"


#define YY_INPUT(buf,result,max_size) \
{   \
   int c = getchar(); \
   /*if(c>='a' && c<='z') c+='A'-'a';*/ \
   result = (c == EOF) ? YY_NULL : (buf[0] = c, 1); \
}

%}

%%

[ \t\n]             ;
"#".*"\n"           ;
"//".*"\n"          ;
"$("[^")"]+")"      {
char* debext=strstr(yytext,"(")+1;
char* finext=strstr(yytext,")");
char* lext=(char*)malloc((finext-debext+2)*sizeof(char));
strncpy(lext,debext,finext-debext);
lext[finext-debext]='\0';
yylval.chaine=lext;
return(IDEXT);
};
"/*"[^"*/"]*"*/"    ;
"("		    return(PARENTHESE_OUVRANTE); 
")"		    return(PARENTHESE_FERMANTE); 
"["                 return(CROCHET_OUVRANT);
"]"                 return(CROCHET_FERMANT);
"{"		    return(ACCOLADE_OUVRANTE); 
"}"		    return(ACCOLADE_FERMANTE); 
"+"		    return(PLUS);
":"                 return(DEUXPOINTS);
"*"		    return(MULT);
"-"                 return(MOINS);
"/"                 return(DIV);
"<<"                return(SHL);
">>"                return(SHR);
"||"                return(BOR);
"&&"                return(BAND);
"&"                 return(AND);
"|"                 return(OR);
">"                 return(SUP);
"<"                 return(INF);
"=="                return(EGAL);
"="                 return(EGAL);
"!="                return(PASEGAL);
"<="                return(INFOUEGAL);
">="                return(SUPOUEGAL);
"!"                 return(NOT);
"^"                 return(XOR);
"if"                return(IF);
"else"              return(ELSE);
"%"                 return(MODULO);
","                 return(VIRGULE);
";"                 return(FIN_OPCODE);
"LOCK"              return(LOCK);
"FREE"              return(FREE);
"MEM_INIT"          return(INITMEM);
"MEM_CHANGED"       return(CHANGEMEM);
"TAILLE_DECRYPTEUR" return(TAILLE_DECRYPTEUR);
"WRITE8"            return(WRITE8);
"WRITE16"           return(WRITE16);
"WRITE32"           return(WRITE32);
"registre"          { yylval.entier=ATYPE_REGISTRE; return(ATYPE);};
"adresse"           { yylval.entier=ATYPE_ADRESSE; return(ATYPE);};
"entier"            { yylval.entier=ATYPE_ENTIER; return(ATYPE);};
"FREEEAX"               { yylval.entier=REG_EAX; return(REGISTRE);};
"FREEEBX"               { yylval.entier=REG_EBX; return(REGISTRE);};
"FREEECX"               { yylval.entier=REG_ECX; return(REGISTRE);};
"FREEEDX"               { yylval.entier=REG_EDX; return(REGISTRE);};
"FREEESI"               { yylval.entier=REG_ESI; return(REGISTRE);};
"FREEEDI"               { yylval.entier=REG_EDI; return(REGISTRE);};
"FREEEBP"               { yylval.entier=REG_EBP; return(REGISTRE);};
"FREEESP"               { yylval.entier=REG_ESP; return(REGISTRE);};
"EAX"               { yylval.entier=REG_EAX; return(UREGISTRE);};
"EBX"               { yylval.entier=REG_EBX; return(UREGISTRE);};
"ECX"               { yylval.entier=REG_ECX; return(UREGISTRE);};
"EDX"               { yylval.entier=REG_EDX; return(UREGISTRE);};
"ESI"               { yylval.entier=REG_ESI; return(UREGISTRE);};
"EDI"               { yylval.entier=REG_EDI; return(UREGISTRE);};
"EBP"               { yylval.entier=REG_EBP; return(UREGISTRE);};
"ESP"               { yylval.entier=REG_ESP; return(UREGISTRE);};
"DEFAUT" 	    return(REGLE_DEFAUT);
"RAW"		    return(RAW);
"ASM"[" \n\t"]*"{"[^"}"]*"}"     {
char* debasm=strstr(yytext,"{")+1;
char* finasm=strstr(yytext,"}");
char* lasm=(char*)malloc((finasm-debasm+2)*sizeof(char));
strncpy(lasm,debasm,finasm-debasm);
lasm[finasm-debasm]='\0';
yylval.chaine=lasm;
return(ASM);
};
"rndint"[0-9]       { yylval.entier = (int)yytext[6]-'0'; return(RNDINT) ; };
"freemem"[0-9]       { yylval.entier = (int)yytext[7]-'0'; return(RNDMEM) ; };
"label"[0-9]        { yylval.entier = (int)yytext[5]-'0'; return(LABEL) ; };
"freereg"[0-9]       { yylval.entier = (int)yytext[7]-'0'; return(RNDREG) ; };
"rndreg"[0-9]       { yylval.entier = (int)yytext[6]-'0'; return(URNDREG) ; };
[0-9]+              { yylval.entier = atoi(yytext);  return(NOMBRE) ; };
"0x"[0-9a-fA-F]+    { sscanf(yytext,"%x",&yylval.entier);  return(NOMBRE) ; };
[a-zA-Z_][0-9a-zA-Z_]* {yylval.chaine = strdup(yytext); return ID;};
