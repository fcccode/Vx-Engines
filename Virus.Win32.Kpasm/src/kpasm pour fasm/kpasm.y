%{
#include <malloc.h>
#include <stdio.h>
#include <string.h>
#include "kpasm.h"
#include "kasm.h"
#include "linkedlist.h"
#include "verif.h"
  extern int yylineno;
  extern int yylex();
  void yyerror(char *s);	
  int yywrap(void)
    {
      return 1;
    }
%}


%union value {
  SousOpcode* sousopcode;
  Opcode* opcode;
  int entier;
  char* chaine;
  linkedlist liste;
  Regle* regle;
}

%token SHL
%token SHR
%token MODULO
%token OR
%token AND
%token WRITE8
%token WRITE16
%token WRITE32
%token LABELLOCK
%token LABELFREE
%token LABEL
%token TAILLE_CODE
%token TAILLE_DECRYPTEUR
%token IDEXT
%token REGLE_DEFAUT
%token SAUT_LIGNE
%token PARENTHESE_OUVRANTE
%token PARENTHESE_FERMANTE
%token ACCOLADE_OUVRANTE
%token ACCOLADE_FERMANTE
%token CROCHET_OUVRANT
%token CROCHET_FERMANT
%token NOMBRE
%token ID
%token VIRGULE
%token LOCK
%token FREE
%token INITMEM
%token CHANGEMEM
%token RAW
%token ASM
%token RNDMEM
%token RNDMEMI
%token RNDINT
%token RNDREG
%token FIN_OPCODE
%token DEUXPOINTS
%token SUP
%token EGAL
%token INF
%token PASEGAL
%token INFOUEGAL
%token SUPOUEGAL
%token IF
%token ELSE
%token BOR
%token BAND
%token REGISTRE
%token UREGISTRE
%token URNDREG
%token ATYPE
%token NOT
%token XOR


%left BOR
%left BAND
%right NOT
%left SUP EGAL INF PASEGAL INFOUEGAL SUPOUEGAL
%left OR
%left XOR
%left AND
%left PLUS MOINS
%left MULT DIV
%right SHR SHL

%type <entier> ATYPE
%type <entier> NOMBRE
%type <chaine> ID
%type <entier> REGISTRE
%type <entier> UREGISTRE
%type <chaine> IDEXT
%type <entier> RNDINT
%type <entier> RNDMEM
%type <entier> RNDMEMI
%type <entier> RNDREG
%type <entier> URNDREG
%type <entier> LABEL
%type <sousopcode> EXP
%type <opcode> OPCODE
%type <liste> SUITE_EXP
%type <liste> SUITE_OPCODE
%type <liste> BLOC_OPCODE
%type <liste> SUITE_REGLE
%type <liste> SUITE_PARAMETRE
%type <chaine> ASM
%type <regle> REGLE;


%start INPUT


%locations
%error-verbose

%%

INPUT           :  
| INPUT TRANSFORMATION



TRANSFORMATION : ID PARENTHESE_OUVRANTE SUITE_PARAMETRE  PARENTHESE_FERMANTE ACCOLADE_OUVRANTE SUITE_REGLE ACCOLADE_FERMANTE{ 
   Transformation* t=(Transformation*)malloc(sizeof(Transformation));
   t->nom=$1;
   t->arguments=$3;
   t->regles=$6;
   t->ligne=yylineno;
   ll_push_back(&transformations,t);
}
| ID PARENTHESE_OUVRANTE SUITE_PARAMETRE  PARENTHESE_FERMANTE ACCOLADE_OUVRANTE SUITE_OPCODE ACCOLADE_FERMANTE{ 
  linkedlist l; 
  Transformation* t=(Transformation*)malloc(sizeof(Transformation));
  Regle* r=(Regle*)malloc(sizeof(Regle));
  r->proba=1;
  r->opcodes=$6;
  r->minimum_taille=-1;
  r->is_defaut=1;
  r->ligne=yylineno;
  ll_init(&l,sizeof(Regle));
  ll_push_back(&l,r);
  t->regles=l;
  t->nom=$1;
  t->arguments=$3;
  t->ligne=yylineno;
  ll_push_back(&transformations,t);
 }


SUITE_PARAMETRE : ID DEUXPOINTS ATYPE {
  linkedlist l;
  Argument* arg=(Argument*)malloc(sizeof(Argument));
  arg->nom=$1;
  arg->type=$3;
  ll_init(&l,sizeof(Argument));
  ll_push_back(&l,arg);
  $$=l;
}
| SUITE_PARAMETRE VIRGULE ID DEUXPOINTS ATYPE{
  Argument* arg=(Argument*)malloc(sizeof(Argument));
  arg->nom=$3;
  arg->type=$5;
  ll_push_back(&$1,arg);
  $$=$1;
}
| /* rien */
{
  linkedlist l;
  ll_init(&l,sizeof(Argument));
  $$=l;
 }

SUITE_REGLE : REGLE{
  linkedlist l;
  ll_init(&l,sizeof(Regle));
  ll_push_back(&l,$1);
  $$=l;
}
| SUITE_REGLE REGLE{
  ll_push_back(&$1,$2);
  $$=$1;
}

REGLE		: NOMBRE DEUXPOINTS ACCOLADE_OUVRANTE SUITE_OPCODE ACCOLADE_FERMANTE{
  Regle* r=(Regle*)malloc(sizeof(Regle));
  r->proba=$1;
  r->opcodes=$4;
  r->minimum_taille=-1;
  r->is_defaut=0;
  r->ligne=yylineno;
  $$=r;
}
| NOMBRE DEUXPOINTS REGLE_DEFAUT ACCOLADE_OUVRANTE SUITE_OPCODE ACCOLADE_FERMANTE{
   Regle* r=(Regle*)malloc(sizeof(Regle));
   r->proba=$1;
   r->opcodes=$5;
   r->is_defaut=1;
   r->ligne=yylineno;
   r->minimum_taille=-1;
   $$=r;
}



OPCODE          : ID PARENTHESE_OUVRANTE SUITE_EXP PARENTHESE_FERMANTE FIN_OPCODE{
  Opcode* op=(Opcode*)malloc(sizeof(Opcode));
  op->letype=CALLOPCODE;
  op->operandes.opcall.nomtransfo=(char*)strdup($1);
  op->operandes.opcall.arguments=$3;
  op->ligne=yylineno;
  $$=op;  
}
| RAW PARENTHESE_OUVRANTE NOMBRE PARENTHESE_FERMANTE ASM {
  Opcode* op=(Opcode*)malloc(sizeof(Opcode));
  op->letype=ASMOPCODE;
  op->ligne=yylineno;
  op->operandes.opasm.asmtxt=$5;
  op->operandes.opasm.taille=$3;
  $$=op;
}
|LABEL FIN_OPCODE{
  Opcode* op=(Opcode*)malloc(sizeof(Opcode));
  op->letype=LABELOPCODE;
  op->ligne=yylineno;
  op->operandes.oplabel.num=$1;
  $$=op;
}
|LOCK PARENTHESE_OUVRANTE EXP VIRGULE ID PARENTHESE_FERMANTE FIN_OPCODE{
  Opcode* op=(Opcode*)malloc(sizeof(Opcode));
  Locked* l=(Locked*)malloc(sizeof(Locked));
  op->ligne=yylineno;
  op->letype=LOCKOPCODE;
  op->operandes.oplock.ss=$3;
  op->operandes.oplock.id=$5;
  l->ss=$3;
  l->id=$5;
  if(ll_find(&lockeds,$5,cmp_char_locked)==NULL)
    ll_push_back(&lockeds,l);
  $$=op;
}
|LOCK PARENTHESE_OUVRANTE EXP PARENTHESE_FERMANTE FIN_OPCODE{
  Opcode* op=(Opcode*)malloc(sizeof(Opcode));
  op->letype=LOCKOPCODE;
  op->ligne=yylineno;
  op->operandes.oplock.ss=$3;
  op->operandes.oplock.id=NULL;
  $$=op;
}

|FREE PARENTHESE_OUVRANTE ID PARENTHESE_FERMANTE FIN_OPCODE{
  Opcode* op=(Opcode*)malloc(sizeof(Opcode));
  op->letype=FREEOPCODE;
  op->ligne=yylineno;
  op->operandes.oplock.id=$3;
  op->operandes.oplock.ss=NULL;
  $$=op;
}

|FREE PARENTHESE_OUVRANTE EXP PARENTHESE_FERMANTE FIN_OPCODE{
  Opcode* op=(Opcode*)malloc(sizeof(Opcode));
  op->letype=FREEOPCODE;
  op->ligne=yylineno;
  op->operandes.oplock.id=NULL;
  op->operandes.oplock.ss=$3;
  $$=op;
}


|INITMEM PARENTHESE_OUVRANTE EXP VIRGULE EXP  PARENTHESE_FERMANTE FIN_OPCODE{
  Opcode* op=(Opcode*)malloc(sizeof(Opcode));
  op->letype=INITMEMOPCODE;
  op->ligne=yylineno;

  op->operandes.opegal.valeur=$5;
  if($3->letype!=ARG && $3->letype!=RNDM)
  {
    add_error("Utilisation invalide de INITMEM");
    op->letype=INVALIDE_OPCODE;
  }
  else
  {
    op->operandes.opegal.dest=$3;
  }
  $$=op;
}
|CHANGEMEM PARENTHESE_OUVRANTE EXP VIRGULE EXP  PARENTHESE_FERMANTE FIN_OPCODE{
  Opcode* op=(Opcode*)malloc(sizeof(Opcode));
  op->letype=CHANGEMEMOPCODE;
  op->ligne=yylineno;

  op->operandes.opegal.valeur=$5;
  if($3->letype!=ARG && $3->letype!=RNDM)
  {
    add_error("Utilisation invalide de CHANGEMEM");
    op->letype=INVALIDE_OPCODE;
  }
  else
  {
    op->operandes.opegal.dest=$3;
  }
  $$=op;
}
|WRITE8 PARENTHESE_OUVRANTE EXP PARENTHESE_FERMANTE FIN_OPCODE{
  Opcode* op=(Opcode*)malloc(sizeof(Opcode));
  op->letype=WRITE;
  op->ligne=yylineno;
  op->operandes.opwrite.nboctets=1;
  op->operandes.opwrite.valeur=$3;
  $$=op;
}
|WRITE16 PARENTHESE_OUVRANTE EXP PARENTHESE_FERMANTE FIN_OPCODE{
  Opcode* op=(Opcode*)malloc(sizeof(Opcode));
  op->letype=WRITE;
  op->ligne=yylineno;
  op->operandes.opwrite.nboctets=2;
  op->operandes.opwrite.valeur=$3;
  $$=op;
}
|WRITE32 PARENTHESE_OUVRANTE EXP PARENTHESE_FERMANTE FIN_OPCODE{
  Opcode* op=(Opcode*)malloc(sizeof(Opcode));
  op->letype=WRITE;
  op->ligne=yylineno;
  op->operandes.opwrite.nboctets=4;
  op->operandes.opwrite.valeur=$3;
  $$=op;
}
|IF PARENTHESE_OUVRANTE EXP PARENTHESE_FERMANTE BLOC_OPCODE {
  Opcode* op=(Opcode*)malloc(sizeof(Opcode));
  op->letype=CONDITIONIF;
  op->ligne=yylineno;
  op->operandes.opif.condition=$3;
  op->operandes.opif.codeif=$5;
  $$=op;
}

|IF PARENTHESE_OUVRANTE EXP PARENTHESE_FERMANTE BLOC_OPCODE  ELSE  BLOC_OPCODE {
  Opcode* op=(Opcode*)malloc(sizeof(Opcode));
  op->letype=CONDITIONIFELSE;
  op->ligne=yylineno;
  op->operandes.opif.condition=$3;
  op->operandes.opif.codeif=$5;
  op->operandes.opif.codeelse=$7;
  $$=op;
}





BLOC_OPCODE : OPCODE {
  linkedlist l;
  ll_init(&l,sizeof(Opcode));
  ll_push_back(&l,$1);
  $$=l;
}
| ACCOLADE_OUVRANTE SUITE_OPCODE ACCOLADE_FERMANTE
{
  $$=$2;
}


SUITE_OPCODE    : OPCODE {
  linkedlist l;
  ll_init(&l,sizeof(Opcode));
  ll_push_back(&l,$1);
  $$=l;
}
| SUITE_OPCODE OPCODE {
  $2->ligne=yylineno;
  ll_push_back(&$1,$2);
  $$=$1;
}
| /* rien */
{
  linkedlist l;
  ll_init(&l,sizeof(Opcode));
  $$=l;
}

SUITE_EXP       : EXP {
  linkedlist l;
  ll_init(&l,sizeof(SousOpcode));
  ll_push_back(&l,$1);
  $$=l;
}
| SUITE_EXP VIRGULE EXP {
  ll_push_back(&$1,$3);
  $$=$1;
}
| /* rien */
{
  linkedlist l;
  ll_init(&l,sizeof(SousOpcode));
  $$=l;
}




EXP		: PARENTHESE_OUVRANTE EXP PARENTHESE_FERMANTE { $$=$2}

| EXP BOR EXP{
  if($1->letype==CONSTANTE && $3->letype==CONSTANTE)
    {
      $1->operandes.valeur|=$3->operandes.valeur;
      $$=$1;
      free($3);
    }
  else
    {
      SousOpcode *cur=(SousOpcode*)malloc(sizeof(SousOpcode));
      cur->letype=OU;
      cur->operandes.couple.gauche=$1;
      cur->operandes.couple.droit=$3;
      cur->ligne=yylineno;
      $$=cur;
    }
}

| EXP OR EXP {
  if($1->letype==CONSTANTE && $3->letype==CONSTANTE)
    {
      $1->operandes.valeur|=$3->operandes.valeur;
      $$=$1;
      free($3);
    }
  else
    {
      SousOpcode *cur=(SousOpcode*)malloc(sizeof(SousOpcode));
      cur->letype=OU;
      cur->operandes.couple.gauche=$1;
      cur->operandes.couple.droit=$3;
      cur->ligne=yylineno;
      $$=cur;
    }
}
| EXP BAND EXP {
  if($1->letype==CONSTANTE && $3->letype==CONSTANTE)
    {
      $1->operandes.valeur&=$3->operandes.valeur;
      $$=$1;
      free($3);
    }
  else
    {
      SousOpcode *cur=(SousOpcode*)malloc(sizeof(SousOpcode));
      cur->letype=ET;
      cur->operandes.couple.gauche=$1;
      cur->operandes.couple.droit=$3;
      cur->ligne=yylineno;
      $$=cur;
    }
}
| EXP AND EXP {
  if($1->letype==CONSTANTE && $3->letype==CONSTANTE)
    {
      $1->operandes.valeur&=$3->operandes.valeur;
      $$=$1;
      free($3);
    }
  else
    {
      SousOpcode *cur=(SousOpcode*)malloc(sizeof(SousOpcode));
      cur->letype=ET;
      cur->operandes.couple.gauche=$1;
      cur->operandes.couple.droit=$3;
      cur->ligne=yylineno;
      $$=cur;
    }
}
| EXP XOR EXP {
  if($1->letype==CONSTANTE && $3->letype==CONSTANTE)
    {
      $1->operandes.valeur^=$3->operandes.valeur;
      $$=$1;
      free($3);
    }
  else
    {
      SousOpcode *cur=(SousOpcode*)malloc(sizeof(SousOpcode));
      cur->letype=OUEX;
      cur->operandes.couple.gauche=$1;
      cur->operandes.couple.droit=$3;
      cur->ligne=yylineno;
      $$=cur;
    }
}
| EXP PLUS EXP {
  if($1->letype==CONSTANTE && $3->letype==CONSTANTE)
    {
      $1->operandes.valeur+=$3->operandes.valeur;
      $$=$1;
      free($3);
    }
  else
    {
      SousOpcode *cur=(SousOpcode*)malloc(sizeof(SousOpcode));
      cur->letype=ADDITION;
      cur->operandes.couple.gauche=$1;
      cur->operandes.couple.droit=$3;
      cur->ligne=yylineno;
      $$=cur;
    }
}

| EXP MOINS EXP {
  if($1->letype==CONSTANTE && $3->letype==CONSTANTE)
    {
      $1->operandes.valeur-=$3->operandes.valeur;
      $$=$1;
      free($3);
    }
  else
    {
      SousOpcode *cur=(SousOpcode*)malloc(sizeof(SousOpcode));
      cur->letype=SOUSTRACTION;
      cur->operandes.couple.gauche=$1;
      cur->operandes.couple.droit=$3;
      cur->ligne=yylineno;
      $$=cur;
    }
}

| EXP MULT EXP {
  if($1->letype==CONSTANTE && $3->letype==CONSTANTE)
    {
      $1->operandes.valeur*=$3->operandes.valeur;
      $$=$1;
      free($3);
    }
  else
    {
      SousOpcode *cur=(SousOpcode*)malloc(sizeof(SousOpcode));
      cur->letype=MULTIPLICATION;
      cur->operandes.couple.gauche=$1;
      cur->operandes.couple.droit=$3;
      cur->ligne=yylineno;
      $$=cur;
    }
}

| EXP DIV EXP {
  if($1->letype==CONSTANTE && $3->letype==CONSTANTE)
    {
      $1->operandes.valeur/=$3->operandes.valeur;
      $$=$1;
      free($3);
    }
  else
    {
      SousOpcode *cur=(SousOpcode*)malloc(sizeof(SousOpcode));
      cur->letype=DIVISION;
      cur->operandes.couple.gauche=$1;
      cur->operandes.couple.droit=$3;
      cur->ligne=yylineno;
      $$=cur;
    }
}

| EXP MODULO EXP {
  if($1->letype==CONSTANTE && $3->letype==CONSTANTE)
    {
      $1->operandes.valeur%=$3->operandes.valeur;
      $$=$1;
      free($3);
    }
  else
    {
      SousOpcode *cur=(SousOpcode*)malloc(sizeof(SousOpcode));
      cur->letype=MOD;
      cur->operandes.couple.gauche=$1;
      cur->operandes.couple.droit=$3;
      cur->ligne=yylineno;
      $$=cur;
    }
}

| EXP SHL EXP {
  if($1->letype==CONSTANTE && $3->letype==CONSTANTE)
    {
      $1->operandes.valeur<<=$3->operandes.valeur;
      $$=$1;
      free($3);
    }
  else
    {
      SousOpcode *cur=(SousOpcode*)malloc(sizeof(SousOpcode));
      cur->letype=DECGAUCHE;
      cur->operandes.couple.gauche=$1;
      cur->operandes.couple.droit=$3;
      cur->ligne=yylineno;
      $$=cur;
    }
}
| EXP SHR EXP {
  if($1->letype==CONSTANTE && $3->letype==CONSTANTE)
    {
      $1->operandes.valeur>>=$3->operandes.valeur;
      $$=$1;
      free($3);
    }
  else
    {
      SousOpcode *cur=(SousOpcode*)malloc(sizeof(SousOpcode));
      cur->letype=DECDROIT;
      cur->operandes.couple.gauche=$1;
      cur->operandes.couple.droit=$3;
      cur->ligne=yylineno;
      $$=cur;
    }
}
| EXP EGAL EXP {
  SousOpcode *cur=(SousOpcode*)malloc(sizeof(SousOpcode));
  cur->letype=JE;
  cur->operandes.couple.gauche=$1;
  cur->operandes.couple.droit=$3;
  cur->ligne=yylineno;
  $$=cur;
}
| EXP PASEGAL EXP {
  SousOpcode *cur=(SousOpcode*)malloc(sizeof(SousOpcode));
  cur->letype=JNE;
  cur->operandes.couple.gauche=$1;
  cur->operandes.couple.droit=$3;
  cur->ligne=yylineno;
  $$=cur;
}
| EXP INF EXP {
  SousOpcode *cur=(SousOpcode*)malloc(sizeof(SousOpcode));
  cur->letype=JB;
  cur->operandes.couple.gauche=$1;
  cur->operandes.couple.droit=$3;
  cur->ligne=yylineno;
  $$=cur;
}
| EXP SUP EXP {
  SousOpcode *cur=(SousOpcode*)malloc(sizeof(SousOpcode));
  cur->letype=JA;
  cur->operandes.couple.gauche=$1;
  cur->operandes.couple.droit=$3;
  cur->ligne=yylineno;
  $$=cur;
}
| EXP SUPOUEGAL EXP {
  SousOpcode *cur=(SousOpcode*)malloc(sizeof(SousOpcode));
  cur->letype=JAE;
  cur->operandes.couple.gauche=$1;
  cur->operandes.couple.droit=$3;
  cur->ligne=yylineno;
  $$=cur;
}
| EXP INFOUEGAL EXP {
  SousOpcode *cur=(SousOpcode*)malloc(sizeof(SousOpcode));
  cur->letype=JBE;
  cur->operandes.couple.gauche=$1;
  cur->operandes.couple.droit=$3;
  cur->ligne=yylineno;
  $$=cur;
}

| CROCHET_OUVRANT EXP CROCHET_FERMANT {
  SousOpcode *cur=(SousOpcode*)malloc(sizeof(SousOpcode));
  cur->letype=INDIRECTION;
  cur->operandes.sousopcode=$2;
  cur->ligne=yylineno;
  $$=cur;
}

| NOT EXP {
  SousOpcode *cur=(SousOpcode*)malloc(sizeof(SousOpcode));
  cur->letype=NEGATION;
  cur->operandes.sousopcode=$2;
  cur->ligne=yylineno;
  $$=cur;
}

| NOMBRE {
  SousOpcode* cur=(SousOpcode*)malloc(sizeof(SousOpcode));
  cur->letype=CONSTANTE;
  cur->operandes.valeur=$1;
  cur->ligne=yylineno;
  $$=cur;
}

| RNDINT {
  SousOpcode *cur=(SousOpcode*)malloc(sizeof(SousOpcode));
  cur->letype=RNDI;
  cur->operandes.valeur=$1;
  cur->ligne=yylineno;
  $$=cur;
}

| RNDMEM {
  SousOpcode *cur=(SousOpcode*)malloc(sizeof(SousOpcode));
  cur->letype=RNDM;
  cur->operandes.valeur=$1;
  cur->ligne=yylineno;
  $$=cur;
}

| RNDREG {
  SousOpcode *cur=(SousOpcode*)malloc(sizeof(SousOpcode));
  cur->letype=RNDR;
  cur->operandes.valeur=$1;
  cur->ligne=yylineno;
  $$=cur;
}
| URNDREG {
  SousOpcode *cur=(SousOpcode*)malloc(sizeof(SousOpcode));
  cur->letype=URNDR;
  cur->operandes.valeur=$1;
  cur->ligne=yylineno;
  $$=cur;
}
| LABEL {
  SousOpcode *cur=(SousOpcode*)malloc(sizeof(SousOpcode));
  cur->letype=LAB;
  cur->operandes.valeur=$1;
  cur->ligne=yylineno;
  $$=cur;
  }
  
| ID {
  SousOpcode *cur=(SousOpcode*)malloc(sizeof(SousOpcode));
  cur->letype=ARG;
  cur->operandes.nom=$1;
  cur->ligne=yylineno;
  $$=cur;
}
| IDEXT {
  SousOpcode *cur=(SousOpcode*)malloc(sizeof(SousOpcode));
  cur->letype=VAREXT;
  cur->operandes.nom=$1;
  cur->ligne=yylineno;
  $$=cur;  
}
| UREGISTRE {
  SousOpcode *cur=(SousOpcode*)malloc(sizeof(SousOpcode));
  cur->letype=UREG;
  cur->operandes.valeur=$1;
  cur->ligne=yylineno;
  $$=cur;  
  }
| REGISTRE {
  SousOpcode *cur=(SousOpcode*)malloc(sizeof(SousOpcode));
  cur->letype=REG;
  cur->operandes.valeur=$1;
  cur->ligne=yylineno;
  $$=cur;  
  }
  


%%
#include <stdio.h>
#include <ctype.h>


void yyerror(char *s)
{
  fprintf(stderr,"%s\n",s);
  //  fprintf(stderr,"Last token read: %s\n",yytext);
  fprintf(stderr,"Error line %d\n",yylineno);
}

#include "lex.yy.c"
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>


void usage(char* exe)
{
  printf("Usage : %s <fichier>\n",exe);
  printf("%s written by kaze <kaze@lyua.org>\n",exe);
  exit(EXIT_FAILURE);
}


int main(int argc, char** argv) {

  if(argc!=2)
    usage(argv[0]);
  close(0);
  if(open(argv[1],O_RDONLY))
    usage(argv[0]);
 

  ll_init(&lockeds,sizeof(Locked));
  ll_init(&transformations,sizeof(Transformation));

  yyparse();

  if(!verification_semantique(&transformations,&lockeds))
    {
      affiche_erreurs();
      exit(EXIT_FAILURE);
    }

  if(!preprocess(&transformations))
    {
      affiche_erreurs();
      exit(EXIT_FAILURE);
    }


  FILE* inc=fopen("poly_defines.inc","w");
  FILE* asmeur=fopen("poly_assembleur.asm","w");
  produit_inc(inc,&transformations,&lockeds);
  produit_asm(asmeur,&transformations,&lockeds);
  fclose(inc);
  fclose(asmeur);
  printf("poly_assembleur.asm & poly_defines.inc generated\n");
  printf("kpasm v1.0\nCoded by kaze <kaze@lyua.org>\n");
  ll_destroy(&lockeds);
  ll_destroy(&transformations);
  return EXIT_SUCCESS;
}


