#ifndef VERIF_H
#define VERIF_H

#include "verif.h"
#include <stdio.h>
#include <string.h>
#include "kasm.h"


char derniere_erreur[1024];
linkedlist erreurs;
extern int yylineno;


/* ========================================= VERIFICATION SEMANTIQUE ====================================== */


int cmp_nom_transfo(void* t1,void* t2,int n)
{
  return strcmp(((Transformation *)t1)->nom,((Transformation *)t2)->nom);
}

int cmp_char_transfo(void* t,void* s,int n)
{
  return strcmp(((Transformation *)t)->nom,(char*) s);
}

int cmp_char_locked(void* a, void*b, int n)
{
  Locked* l=(Locked*) a;
  return strncmp(l->id,(char*)b,n);
}



void add_error(char* err)
{
  ll_push_back(&erreurs,strdup(err));
}

linkedlist get_erreurs()
{
  return erreurs;
}


void affiche_erreurs()
{
  fprintf(stderr,"%d erreur(s) rencontree(s) :\n",ll_size(&erreurs));
  cellule* c=ll_front(&erreurs);
  while(c!=NULL)
  {
    fprintf(stderr,"ERREUR %s\n",(char*)c->valeur);
    c=ll_next(&erreurs,c);
  }
}


int verification_sousopcode(SousOpcode* s,Opcode* o,Regle* r,Transformation* t,linkedlist* transfos,linkedlist* lockeds)
{
  int valide=1;
  if(estRessource(s) && r->is_defaut)
  {
    fprintf(stderr,"warning [ ligne %d ] Transformation '%s' : Utilisation de freereg ou freemem dans la regle par defaut\n",s->ligne,t->nom);
  }

  switch(s->letype)
  {
    case ARG:
    {
      cellule* arg=ll_find(&t->arguments,s->operandes.nom,compare_char_arg);
      cellule* locked=ll_find(lockeds,s->operandes.nom,cmp_char_locked);
      if(arg==NULL && locked==NULL)
      {
	snprintf(derniere_erreur,1024,"[ ligne %d ] Transformation '%s' : Identificateur inconnu \"%s\"",s->ligne,t->nom,s->operandes.nom);
	add_error(derniere_erreur);
	valide=0;
      }
      break;
    }
    case INDIRECTION:
    {
      valide=0;
      if(s->operandes.sousopcode->letype==ARG)
      {
	cellule* arg=ll_find(&t->arguments,s->operandes.sousopcode->operandes.nom,compare_char_arg);
	cellule* locked=ll_find(lockeds,s->operandes.sousopcode->operandes.nom,cmp_char_locked);
	if(arg!=NULL && s->operandes.sousopcode->argtype==ATYPE_ADRESSE)
	{
	  valide=1;
	}
	else if(locked!=NULL)
	{
	  Locked* l=(Locked*)locked->valeur;
	  if(l->ss->letype==RNDM)
	    valide=1;
	}
      }
      else if(s->operandes.sousopcode->letype==RNDM)
      {
	valide=1;
      }
      if(valide==0)
      {
	snprintf(derniere_erreur,1024,"[ ligne %d ] Transformation '%s' : Argument invalide pour l'indirection [] : doit être de type 'adresse'",s->ligne,t->nom);
	add_error(derniere_erreur);
      }
      break;
    }
    default:
      valide=valide && 1;
  }
  if(estOpBinaire(s))
  {
    return valide && verification_sousopcode(s->operandes.couple.gauche,o,r,t,transfos,lockeds) 
      && verification_sousopcode(s->operandes.couple.droit,o,r,t,transfos,lockeds);
  }
  else if(estOpUnaire(s))
  {
    return  valide && verification_sousopcode(s->operandes.sousopcode,o,r,t,transfos,lockeds);
  }
  else
    return valide;
}


int verification_opcode(Opcode* o,Regle* r,Transformation* t,linkedlist* transfos,linkedlist* lockeds)
{
  int valide=1;
  switch(o->letype)
  {
    case CALLOPCODE:
    {
      if(!ll_find(transfos,o->operandes.opcall.nomtransfo,cmp_char_transfo))
      {
	snprintf(derniere_erreur,1024,"[ ligne %d ] Transformation '%s' : Appel a une transformation inconnue \"%s\"",o->ligne,t->nom,o->operandes.opcall.nomtransfo);
	add_error(derniere_erreur);
	valide=0;
      }
      cellule* co=ll_front(&o->operandes.opcall.arguments);
      while(co!=NULL)
      {
	SousOpcode* s=(SousOpcode*)co->valeur;
	valide=valide && verification_sousopcode(s,o,r,t,transfos,lockeds);
	co=ll_next(&o->operandes.opcall.arguments,co);
      }
      break;
    }
    case WRITE:
    {
      valide=valide && verification_sousopcode(o->operandes.opwrite.valeur,o,r,t,transfos,lockeds);
      break;
    }
    case FREEOPCODE:
    {
      if(o->operandes.oplock.id!=NULL)
      {
	cellule* p=ll_find(lockeds,o->operandes.oplock.id,cmp_char_locked);
	if(p==NULL)
	{
	  snprintf(derniere_erreur,1024,"[ ligne %d ] Transformation '%s' : '%s' n'est pas un nom de variable lockee",o->ligne,t->nom,o->operandes.oplock.id);
	  add_error(derniere_erreur);
	  return 0;
	}
	return 1;
      }
      else
      {
	if(!(o->operandes.oplock.ss->letype==REG || o->operandes.oplock.ss->letype==RNDR || o->operandes.oplock.ss->letype==URNDR
	     || o->operandes.oplock.ss->letype==UREG || o->operandes.oplock.ss->letype==RNDM))
	{
	  snprintf(derniere_erreur,1024,"[ ligne %d ] Transformation '%s' : expression invalide pour l'instruction free, doit être de type 'adresse' ou 'registre' si un seul argument",o->ligne,t->nom);
	  add_error(derniere_erreur);
	  return 0;
	}
	return 1;
      }
      break;
    }
    case LOCKOPCODE:
    {
      valide=valide && verification_sousopcode(o->operandes.oplock.ss,o,r,t,transfos,lockeds);
      break;
    }
    case CONDITIONIF:
    {
      valide=valide && verification_sousopcode(o->operandes.opif.condition,o,r,t,transfos,lockeds);
      cellule* p=ll_front(&o->operandes.opif.codeif);
      while(p!=NULL)
      {
	Opcode* oi=(Opcode*)p->valeur;
	valide=valide && verification_opcode(oi,r,t,transfos,lockeds);
	p=ll_next(&o->operandes.opif.codeif,p);
      }
      break;
    }
    case CONDITIONIFELSE:
    {
      valide=valide && verification_sousopcode(o->operandes.opif.condition,o,r,t,transfos,lockeds);
      cellule* p=ll_front(&o->operandes.opif.codeif);
      while(p!=NULL)
      {
	Opcode* oi=(Opcode*)p->valeur;
	valide=valide && verification_opcode(oi,r,t,transfos,lockeds);
	p=ll_next(&o->operandes.opif.codeif,p);
      }
      p=ll_front(&o->operandes.opif.codeelse);
      while(p!=NULL)
      {
	Opcode* oi=(Opcode*)p->valeur;
	valide=valide && verification_opcode(oi,r,t,transfos,lockeds);
	p=ll_next(&o->operandes.opif.codeelse,p);
      }
      break;
    }
    case INVALIDE_OPCODE:
    {
      valide=0;
      break;
    }
    default:
      valide=1;
  }
  return valide;
}

int verification_regle(Regle* r,Transformation* t,linkedlist* transfos,linkedlist* lockeds)
{
  int valide=1;
  cellule* co=ll_front(&r->opcodes);
  if(r->proba<0)
  {
    snprintf(derniere_erreur,1024,"[ ligne %d ] Transformation '%s' : Probabilite de la regle negative",r->ligne,t->nom);
    add_error(derniere_erreur);
    valide=0;
  }
  if(!r->is_defaut && r->proba==0)
  {
    snprintf(derniere_erreur,1024,"[ ligne %d ] Transformation '%s' : Probabilite de la regle nulle (seule la regle par defaut peut avoir une proba nulle)",r->ligne,t->nom);
    add_error(derniere_erreur);
    valide=0;
  }
  while(co!=NULL)
  {
    Opcode* o=co->valeur;
    valide=valide && verification_opcode(o,r,t,transfos,lockeds);
    co=ll_next(&r->opcodes,co);
  }
  return valide;
}

int verification_transformation(Transformation* t,linkedlist* transfos,linkedlist* lockeds)
{
  int valide=1;
  int a_regle_defaut=0;
  if(ll_find2(transfos,t,cmp_nom_transfo))
  {
    cellule* tmp=ll_find2(transfos,t,cmp_nom_transfo);
    Transformation* doublon=(Transformation*)tmp->valeur;
    snprintf(derniere_erreur,1024,"[ lignes %d et %d ] Transformation '%s' : Doublon sur le nom de la transformation",t->ligne,doublon->ligne,t->nom);
    add_error(derniere_erreur);
    valide=0;
  }
  cellule* cr=ll_front(&t->regles);
  if(cr==NULL)
  {
    snprintf(derniere_erreur,1024,"[ ligne %d ] Transformation '%s' : Aucune regle de definie",t->ligne,t->nom);
    add_error(derniere_erreur);
    valide=0;
  }
  while(cr!=NULL)
  {
    Regle* r=cr->valeur;
    a_regle_defaut=a_regle_defaut || r->is_defaut;
    valide=valide && verification_regle(r,t,transfos,lockeds);
    cr=ll_next(&t->regles,cr);
  }
  if(!a_regle_defaut)
  {
    snprintf(derniere_erreur,1024,"[ ligne %d ] Transformation '%s' : Aucune regle par defaut",t->ligne,t->nom);
    add_error(derniere_erreur);
    valide=0;
  }
  return valide;
}


int verification_semantique(linkedlist* transfos, linkedlist* lockeds)
{
  int valide=1;
  ll_init(&erreurs,1024);
  cellule *ct=ll_front(transfos);
  if(ct==NULL)
    {
      snprintf(derniere_erreur,1024,"Aucune transformation de définie");
      add_error(derniere_erreur);
      valide=0;   
    }
  while(ct!=NULL)
  {
    Transformation* t=ct->valeur;
    valide=valide && verification_transformation(t,transfos,lockeds);
    ct=ll_next(transfos,ct);
  }
  return valide;
}

#endif

