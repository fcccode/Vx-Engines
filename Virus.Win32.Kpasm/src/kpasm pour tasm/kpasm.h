#ifndef KPASM_H
#define KPASM_H

#include "linkedlist.h"

#define MAX_REGISTRES 10


enum SsOpType {ADDITION,SOUSTRACTION,MULTIPLICATION,DIVISION,OU,ET,OUEX,DECGAUCHE,DECDROIT,MOD,JA,JB,JE,JNE,JAE,JBE,
	       CONSTANTE,RNDI,RNDM,RNDR,URNDR,ARG,VAREXT,TAILLE_DEC,REG,UREG,LAB,NEGATION,INDIRECTION,};

enum OpType {INVALIDE_OPCODE,ASMOPCODE,CALLOPCODE,LABELOPCODE,LOCKOPCODE,FREEOPCODE,
	     INITMEMOPCODE,CHANGEMEMOPCODE,WRITE,NOP,CONDITIONIF,CONDITIONIFELSE};

enum {ATYPE_REGISTRE,ATYPE_ENTIER,ATYPE_ADRESSE};

enum{REG_EAX,REG_EBX,REG_ECX,REG_EDX,REG_ESI,REG_EDI,REG_EBP,REG_ESP};


#define estOpBinaire(so) (so->letype>=ADDITION && so->letype<=JBE)
#define estOpUnaire(so) (so->letype>=NEGATION && so->letype<=INDIRECTION)
#define estRessource(so) (so->letype==RNDR || so->letype==RNDM || so->letype==REG)
#define estCondition(so) (so->letype>=JA && so->letype<=JBE)

struct CoupleOpcodes_{
  struct SousOpcode_* gauche;
  struct SousOpcode_* droit;
};
typedef struct CoupleOpcodes_ CoupleOpcodes;

struct SousOpcode_{
    int letype;
    union {
	int valeur;
	CoupleOpcodes couple;
	struct SousOpcode_ * sousopcode;
	char* nom;
    }operandes;
    int argtype;
    int ligne;
};
typedef struct SousOpcode_ SousOpcode;


struct OpcodeCall_{
  char* nomtransfo;
  struct  Transformation_* transfo;
  linkedlist arguments;
};

typedef struct OpcodeCall_ OpcodeCall;

typedef struct {
    char* nom;
    int type;
}Argument;

typedef struct {
   SousOpcode* ss;
   char* id;
}OpcodeLock;

typedef struct {
    SousOpcode* condition;
    linkedlist codeif;
    linkedlist codeelse;
}OpcodeIf;

typedef struct {
   char* asmtxt;
   int taille;
}OpcodeAsm;

typedef struct {
  int num;
}OpcodeLabel;

typedef struct {
    SousOpcode* dest;
    SousOpcode* valeur;
}OpcodeEgal;

typedef struct {
    int nboctets;
    SousOpcode* valeur;
}OpcodeWrite;

typedef struct {
  int letype;
  union {
      OpcodeCall opcall;
      OpcodeAsm opasm;
      OpcodeLock oplock;
      OpcodeEgal opegal;
      OpcodeLabel oplabel;
      OpcodeWrite opwrite;
      OpcodeIf opif;
  }operandes;
  int ligne;
}Opcode;
  

typedef struct {
    int proba;
    int is_defaut;
    linkedlist opcodes;
    int ligne;
    int minimum_taille;
    int randint_used[MAX_REGISTRES];
    int nb_randint;
    int randmem_used[MAX_REGISTRES];
    int nb_randmem;
    int randreg_used[MAX_REGISTRES];
    int nb_randreg;
    int reg_used[MAX_REGISTRES];
    int nb_reg;
    int ureg_used[MAX_REGISTRES];
    int nb_ureg;
    int lab_used[MAX_REGISTRES];
    int nb_lab;
    int urandreg_used[MAX_REGISTRES];
    int nb_urandreg;
    int randreg_locked[MAX_REGISTRES];
    int randmem_locked[MAX_REGISTRES];
    int reg_locked[MAX_REGISTRES];
}Regle;

struct Transformation_{
  char* nom;
  linkedlist arguments;
  linkedlist regles;
  Regle* regledefaut;
  int ligne;
};
typedef struct Transformation_ Transformation;


typedef struct 
{
    SousOpcode* ss;
    char* id;
}Locked;

linkedlist transformations;
linkedlist lockeds;
#endif
