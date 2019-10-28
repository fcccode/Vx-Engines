#include "linkedlist.h"
#include <assert.h>


void ll_init(linkedlist* l,unsigned int taille)
{
  l->tete=NULL;
  l->queue=NULL;
  l->taille_cellule=taille;
  l->taille=0;
}

void ll_destroy(linkedlist* l)
{
  assert(l!=NULL);
  cellule* c=l->tete;
  while(c!=NULL)
    {
      cellule* n=c->suivant;
      free(c->valeur);
      free(c);
      c=n;
    }
  l->taille=0;
  l->queue=NULL;
  l->tete=NULL;
}

void ll_push_back(linkedlist* l,void* e)
{
  assert(l!=NULL);
  assert(e!=NULL);
  cellule* c=(cellule*)malloc(sizeof(cellule));
  c->suivant=NULL;
  c->valeur=e;
  
  if(l->tete==NULL)
    {
      l->tete=c;
      l->queue=c;
    }
  else
    {
      assert(l->queue!=NULL);
      l->queue->suivant=c;
      l->queue=c;
    }
  l->taille++;
}

void ll_pop_front(linkedlist* l)
{
  assert(l!=NULL);
  cellule* d=l->tete;
  if(d!=NULL)
    {
      l->tete=d->suivant;
      free(d);
      l->taille--;
    }
}

void ll_remove(linkedlist* l,cellule* c)
{
  assert(l!=NULL);
  assert(c!=NULL);
  if(c==l->tete)
    {
      ll_pop_front(l);
    }
  else
    {
      cellule* pred=l->tete;
      while(pred!=NULL && pred->suivant!=c)
	{
	  pred=pred->suivant;
	}
      if(pred!=NULL)
	{
	  cellule* s=c->suivant;
	  free(c);
	  pred->suivant=s;
	  l->taille--;
	}
    }
}

cellule* ll_front(linkedlist* l)
{
  assert(l!=NULL);
  return l->tete;
}

cellule* ll_back(linkedlist* l)
{
  assert(l!=NULL);
  return l->queue;
}

cellule* ll_next(linkedlist* l,cellule* c)
{
  assert(l!=NULL);
  assert(c!=NULL);
  return c->suivant;
}

int ll_size(linkedlist* l)
{
  return l->taille;
}

cellule* ll_find(linkedlist* l,void* e, int (*cmp_fonction)(void*,void*,int))
{
  assert(l!=NULL);
  cellule* c=l->tete;
  while(c!=NULL && cmp_fonction(c->valeur,e,l->taille_cellule)!=0)
    {
      c=c->suivant;
    }
  return c;
}

cellule* ll_find2(linkedlist* l,void* e, int (*cmp_fonction)(void*,void*,int))
{
  assert(l!=NULL);
  cellule* c=l->tete;
  while(c!=NULL && (cmp_fonction(c->valeur,e,l->taille_cellule)!=0 || c->valeur==e))
    {
      c=c->suivant;
    }
  return c;
}

int ll_indice(linkedlist* l,cellule* c)
{
  assert(l!=NULL);
  assert(c!=NULL);
  cellule* t=l->tete;
  int i=0;
  while(t!=NULL && t!=c)
    {
      t=t->suivant;
      i++;
    }
  return i;
}
