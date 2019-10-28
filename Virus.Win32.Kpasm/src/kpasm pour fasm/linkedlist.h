#ifndef LINKEDLIST_H
#define LINKEDLIST_H
#include <malloc.h>


struct cellule_ {
  struct cellule_ *suivant;
  void* valeur;
};
typedef struct cellule_ cellule;

struct linkedlist_{
  cellule* tete;
  cellule* queue;
  int taille_cellule;
  int taille;
};
typedef struct linkedlist_ linkedlist;


void ll_init(linkedlist* l,unsigned int taille);
void ll_destroy(linkedlist* l);
void ll_push_back(linkedlist* l,void* e);
void ll_pop_front(linkedlist* l);
void ll_remove(linkedlist* l,cellule* c);
cellule* ll_back(linkedlist* l);
int ll_size(linkedlist* l);
cellule* ll_front(linkedlist* l);
cellule* ll_next(linkedlist* l,cellule* c);
cellule* ll_find(linkedlist* l,void* e, int (*cmp_fonction)(void*,void*,int));
cellule* ll_find2(linkedlist* l,void* e, int (*cmp_fonction)(void*,void*,int));
int ll_indice(linkedlist* l,cellule* c);
#endif
