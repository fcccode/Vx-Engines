#ifndef KASM_H
#define KASM_H
#include "kpasm.h"
#include <stdio.h>

void debug_sous_opcode(SousOpcode* s);
linkedlist get_erreurs();
void affiche_erreurs();
int verification_semantique(linkedlist* transfos,linkedlist* lockeds);
void produit_opcodes_tasm(FILE* f,linkedlist* transfos);
void produit_lockeds_tasm(FILE* f,linkedlist* lockeds);
void produit_inc(FILE* f,linkedlist* transfos,linkedlist* lockeds);
void produit_asm(FILE* f,linkedlist* transfos,linkedlist* lockeds);
void produit_macros_tasm(FILE* f,linkedlist* transfos);
void produit_defines_tasm(FILE* f);
void asm_transformation(FILE* f,Transformation* t,linkedlist* lockeds);
void asm_opcode(FILE* f,Opcode* o,Regle* r,linkedlist* arguments,linkedlist* lockeds);
void asm_regle(FILE*f,Transformation* t,Regle* r,int indice,int somme_probas,linkedlist* arguments,linkedlist* lockeds);
int cmp_nom_transfo(void* t1,void* t2,int n);
int cmp_char_transfo(void* t,void* s,int n);
int cmp_char_locked(void* a, void*b, int n);
int preprocess(linkedlist* transformations);
int somme_proba_regles(linkedlist* l);
int asm_sous_opcode(FILE* f,SousOpcode* s,Regle* r,linkedlist* arguments,linkedlist* lockeds);
void  produit_table_opcodes_tasm(FILE* f,linkedlist* transfos);
void produit_fonction_asm(FILE*f);
void produit_fonction_divers(FILE* f);
void add_error(char* err);
int compare_char_arg(void* a,void* c,int n);
#endif
