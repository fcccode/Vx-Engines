#include "kasm.h"
#include "kpasm.h"
#include "linkedlist.h"
#include "utils.h"
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <assert.h>
#include "poly_fonctions.h"
#include "verif.h"
#define DEBUG
#define NON_CALCULE -1

char* asm_types[]={"TYPE_REGISTRE","TYPE_ENTIER","TYPE_ADRESSE"};
char* asm_registres[]={"REG_EAX","REG_EBX","REG_ECX","REG_EDX","REG_ESI","REG_EDI","REG_EBP","REG_ESP"};
char derniere_erreur[1024];

/* ================================ GESTION DES ERREURS ================================ */
int position_rnd(int rnd,int* tab);

extern int yylineno;
int label=0;



int get_label()
{
  return label++;
}

int compare_chaines(void* v1,void* v2,int n)
{
  return strncmp((char*)v1,(char*)v2,n);
}

/* ================================= GESTION DES REGISTRES =============================== */

/*
 * Liste des registres utilisables par le moteur de poly.
 * edx est utilisé pour l'espace dispo restant (et comme compteur
 * de boucle pour al recursivité) et edi pointe vers l'endroit où
 * est produit le code poymorphisé
 */
#define NB_REGISTRES 5
enum {REDX,REDI,REBX,RECX,REAX};
char* registres_noms[]={"edx","edi","ebx","ecx","eax"};
int registres[NB_REGISTRES]={1,1,0,0,0};


/*
 * Libere un registre utilisé. Si celui-ci
 * avait été sauvegardé, le dpeile en meme temps.
 */
int libere_registre(FILE* f,int r)
{
  assert(registres[r]>0);
  if(--registres[r]!=0)
    {
      fprintf(f,"\tpop %s\n",registres_noms[r]);
      return 1;
    }
  else
    return 0;
}

/*
 * Renvoie le registre le moins utilisé
 */
int min_registres()
{
   int i,rmin=0,min=registres[0];
   for(i=1;i<NB_REGISTRES;i++)
     {
	if(registres[i]<min)
	  {
	     rmin=i;
	     min=registres[i];
	  }
     }
   return rmin;
}

/*
 * Renvoie un registre de libre, epu importe le quel.
 * Si il n'y en a pas de libre, en sauvegarde un et le renvoie.
 */
int registre_libre(FILE* f)
{
  int reg=min_registres();
  if(registres[reg]++!=0)
    {
      fprintf(f,"\tpush %s\n",registres_noms[reg]);
    }
  return reg;
}

/* 
 * Idem que precedemment sauf que le chois du registre est forcé.
 */
int registre_force(FILE* f,int reg)
{ 
  if(registres[reg]++!=0)
    {
      fprintf(f,"\tpush %s\n",registres_noms[reg]);
    }
  return reg;
}

/* 
 * Idem que registre_libre si ce n'est que l'on veut un registre
 * different de 'r'
 */
int registre_libre_different(FILE* f,int r)
{
  registres[r]+=150;
  int reg=min_registres();
  registres[r]-=150;
  if(registres[reg]++!=0)
    {
      fprintf(f,"\tpush %s\n",registres_noms[reg]);
    }
  return reg;
}

int registre_libre_different2(FILE* f,int r1,int r2)
{
  registres[r1]+=150;
  registres[r2]+=150;
  int reg=min_registres();
  registres[r1]-=150;
  registres[r2]-=150;
  if(registres[reg]++!=0)
    {
      fprintf(f,"\tpush %s\n",registres_noms[reg]);
    }
  return reg;
}


/* ================================ GENERATION DE FICHIERS ================================ */

/*
 * Gere la génération du fichier .inc. Celui-ci contiendra
 * les macros de description du pseudo_code ainsi que quelques defines.
 */
void produit_inc(FILE* f,linkedlist* transfos,linkedlist* lockeds)
{
  fprintf(f,";=================================== MACROS =====================================\n");
  fprintf(f,"; Ces macros sont les pseudos-opcodes qui composeront votre decrypteur.\n");
  fprintf(f,";================================================================================\n");
  produit_macros_tasm(f,transfos);
  fprintf(f,"\n\n\n");
  fprintf(f,";=============================== DEFINES DES OPCODES ============================\n");
  produit_opcodes_tasm(f,transfos);
  fprintf(f,"\n\n\n");
  fprintf(f,";=============================== DEFINES DES REGISTRES ==========================\n");
  produit_defines_tasm(f);
}

/*
 * Gere la génération du .asm. Celui-ci contiendra le moteur: la fonction
 * asm_opcode(edx=taille_max_code,edi->où assembler,esi->pseudo_opcode).
 * Il contient également le code assembleur des routines d'assemblage,
 * les transformations définies par l'utilisateur.
 * Enfin, il contient également quelques routines utiles, comme l'allocation
 * de registre, de mémoire, un gnpa, etc.
 */
void produit_asm(FILE* f,linkedlist* transfos,linkedlist* lockeds)
{
  cellule* ct=ll_front(transfos);
  fprintf(f,"%s\n",poly_fonctions);
  fprintf(f,";========================== VARIABLES LOCKEDS ====================================\n");
  produit_lockeds_tasm(f,lockeds);
  fprintf(f,";========================== TABLE DE SAUTS UTILISEE EN INTERNE ===================\n");
  produit_table_opcodes_tasm(f,transfos);
  fprintf(f,"\n\n\n");
  fprintf(f,";=========================== TRANSFORMATIONS UTILISATEUR =========================\n");
  fprintf(f,"; Ceci est le code assembleur des transformations que vous avez définies.\n");
  fprintf(f,";=================================================================================\n");
  while(ct!=NULL)
    {
      Transformation* t=(Transformation*)ct->valeur;
      asm_transformation(f,t,lockeds);
      fprintf(f,"\n\n");
      ct=ll_next(transfos,ct);
    }
  fprintf(f,"\n\n\n");
}



/* ========================================= ASSEMBLEUR ===================================== */

/*
 * Assemble une transformation définie par l'utilisateur.
 * Calcule notamment le ret <x>, ou x est le nombre d'arguments.
 */
void asm_transformation(FILE* f,Transformation* t,linkedlist* lockeds)
{
  int somme_probas=somme_proba_regles(&t->regles);
  fprintf(f,"; === Transformation %s\n",t->nom);
  fprintf(f,"; IN : ");
  cellule* a=ll_front(&t->arguments);
  while(a!=NULL)
    {
      char* arg=(char*)((Argument*)a->valeur)->nom;
      fprintf(f,"%s  ",arg);
      a=ll_next(&t->arguments,a);
    }
  fprintf(f,"\nasm_%s: \n",t->nom);
  fprintf(f,"\tpush esi\n\tmov esi,esp\n");
  cellule* cr=ll_front(&t->regles);
  int indice=0;
  while(cr!=NULL)
    {
      Regle* r=(Regle*)cr->valeur;
      asm_regle(f,t,r,indice,somme_probas,&t->arguments,lockeds);
      somme_probas-=r->proba;
      cr=ll_next(&t->regles,cr);
      if(!r->is_defaut)
	indice++;
    }
  fprintf(f,"%s_fin:\n",t->nom);
  fprintf(f,"\tpop esi\n");
  fprintf(f,"\tret %d\n",ll_size(&t->arguments)*4);
  //fprintf(f,"asm_%s endp\n",t->nom);
}

/*
 * Permet juste le calcule de la somme des probabilités des regles
 * définie dans une transformation donnée. En effet, l'utilisateur
 * donne a la regle un numero d'importance, sa proba d'etre utilisée est donc
 * numero/somme_des_numéros
 */
int somme_proba_regles(linkedlist* l)
{
  cellule* c=ll_front(l);
  int s=0;
  while(c!=NULL)
    {
      Regle* r=(Regle*)c->valeur;
      s+=r->proba;
      c=ll_next(l,c);
    }
  return s;
}



int nb_calls_restants(Regle* r,Opcode* lo)
{
  cellule* co=ll_front(&r->opcodes);
  int s=0;
  int passe=0;
  while(co!=NULL)
  {
    Opcode* o=(Opcode*)co->valeur;
    if(o!=NULL)
    {
      if(o->letype==CALLOPCODE)
      {
	if(passe)
	  s++;
	else
	  passe=(lo==o);
      }    
      co=ll_next(&r->opcodes,co);
    }
  }  
  return s;  
}        
    
/*
 * Assemble une regle définie par l'utilisateur. Ici, le côté "difficile"
 * est de gérer les différents RNDINTx RNDMEMx RNDREGx utilisés dans la regle.
 * En effet, si disons RNDINT1 est utilisé plusieurs fois dans la regle, il
 * nous faut sauvegarder sa valeur sur la pile.
 * Enfin, il nous faut également gérer les gardes de la règle, i.e si une regle
 * utilise 3 RNDREG !=, il ne faut pas rentrer dedans si il n'y a pas 3 registres
 * dispos a cet instant là.
 * De même si la taille minimum du code généré par la regle est superieur a
 * la place dispo, on en choisra une autre.
 */
void asm_regle(FILE*f,Transformation* t,Regle* r,int indice,int somme_probas,linkedlist* arguments,linkedlist* lockeds)
{
  int i;
  if(!r->is_defaut) //gardes
    {
      fprintf(f,"%s_regle_%d:\n",t->nom,indice);
      fprintf(f,"\tmov eax,%d ; somme des probas des règles de cette transformation\n",somme_probas);
      fprintf(f,"\tcall poly_rand_int\n");
      fprintf(f,"\tcmp eax,%d ; probabilité d'occurence de la règle\n",r->proba);
      fprintf(f,"\tjae near %s_regle_%d\n",t->nom,indice+1);
      if(r->minimum_taille>0)
      {
	fprintf(f,"\tcmp edx,%d ; taille minimale du code généré par cette règle\n",r->minimum_taille);
	fprintf(f,"\tjb near %s_regle_%d\n",t->nom,indice+1);
      }
      if(r->nb_randreg+r->nb_reg>0)
      {
	fprintf(f,"\tcall nb_registres_libres\n");
	fprintf(f,"\tcmp eax,%d\n",r->nb_randreg+r->nb_reg);
	fprintf(f,"\tjb near %s_regle_%d\n",t->nom,indice+1);
      }
      if(r->nb_randmem>0)
      {
	fprintf(f,"\tcall nb_memoire_libre\n");
	fprintf(f,"\tcmp eax,%d\n",r->nb_randmem);
	fprintf(f,"\tjb near %s_regle_%d\n",t->nom,indice+1);
      }
      for(i=0;i<10;i++)
      {
	if(r->reg_used[i]>0)
	{
	  fprintf(f,"\tmov eax,%s\n",asm_registres[i]);
	  fprintf(f,"\tcall est_registre_libre\n");
	  fprintf(f,"\tjc near %s_regle_%d\n",t->nom,indice+1);
	}
      }
    }
  else
    {
      fprintf(f,"%s_defaut:\n",t->nom);
      fprintf(f,"%s_regle_%d:\n",t->nom,ll_size(&t->regles)-1);
    }
  if(r->nb_randint+r->nb_randmem+r->nb_randreg+r->nb_urandreg+r->nb_lab>0)
    {
      fprintf(f,"\tsub esp,%d\n",(r->nb_randint+r->nb_randmem+r->nb_randreg+r->nb_lab+r->nb_urandreg)*4);
    }
  if(r->nb_lab>0)
  {
      fprintf(f,"\tsub [ebp+poly_ebp],dword %d\n",4*r->nb_lab);
      fprintf(f,"\tmov eax,dword [ebp+poly_ebp]\n");
      int i;
      for(i=0;i<r->nb_lab;i++)
      {
         fprintf(f,"\tmov [esi-%d-4],eax ; LABEL%d\n",(r->nb_randint+r->nb_randreg+r->nb_randmem+i)*4,i);
         fprintf(f,"\tadd eax,4\n");
      }   
  }    

  if(r->nb_urandreg>0)
  {
    fprintf(f,"\tcall raz_choix_uregistres\n");
  }
  cellule* a=ll_front(arguments);
  while(a!=NULL && !r->is_defaut && r->nb_randreg+r->nb_urandreg>0)
  {
    Argument* arg=(Argument*)a->valeur;
    if(arg->type==ATYPE_REGISTRE)
    {
      int pos=ll_indice(arguments,a);
      fprintf(f,"\tmov eax,[esi+%d+8]\n",(ll_size(arguments)-1-pos)*4);
      fprintf(f,"\tinc byte [ebp+choix_uregistres+eax]\n");
    }
    a=ll_next(arguments,a);
  }
  for(i=0;i<10;i++)
  {
    if(r->reg_used[i]>0)
    {
      fprintf(f,"\tmov eax,%s\n",asm_registres[i]);
      fprintf(f,"\tcall reserve_registre\n");
    }
  }
  for(i=0;i<10;i++)
  {
    if(r->ureg_used[i]>0)
    {
      fprintf(f,"\tmov eax,%s\n",asm_registres[i]);
      fprintf(f,"\tcall reserve_uregistre\n");
    }
  }
  for(i=0;i<10;i++)
    {
      if(r->randint_used[i]>1)
	{
	  fprintf(f,"\txor eax,eax\n\tdec eax\n");
	  fprintf(f,"\tcall poly_rand_int\n");
	  fprintf(f,"\tmov [esi-%d-4],eax ; RNDINT%i\n",position_rnd(i,r->randint_used)*4,i);
	}
      if(r->randreg_used[i]>0)
	{
	  fprintf(f,"\tcall choix_registre\n");
	  fprintf(f,"\tmov [esi-%d-4],eax ; FREEREG%d\n",(r->nb_randint+position_rnd(i,r->randreg_used))*4,i);
	}
      if(r->randmem_used[i]>0)
	{
	  fprintf(f,"\tcall choix_memoire\n");
	  fprintf(f,"\tmov [esi-%d-4],eax ; FREEMEM%d\n",(r->nb_randint+r->nb_randreg+position_rnd(i,r->randmem_used))*4,i);
	}
    }
  for(i=0;i<10;i++)
    {
      if(r->urandreg_used[i]>0)
	{
	  fprintf(f,"\tcall choix_uregistre\n");
	  fprintf(f,"\tmov [esi-%d-4],eax ; RNDREG%d\n",(r->nb_randint+r->nb_randreg+r->nb_randmem+r->nb_lab+position_rnd(i,r->urandreg_used))*4,i);
	}
    }
  if(r->minimum_taille!=0)
    {
      fprintf(f,"\tsub edx,%d\n",r->minimum_taille);
    }
  cellule* co=ll_front(&r->opcodes);
  while(co!=NULL)
    {
      Opcode* o=(Opcode*)co->valeur;
      if(o!=NULL)
      {
	asm_opcode(f,o,r,arguments,lockeds);
	co=ll_next(&r->opcodes,co);
      }
    }
 
  for(i=0;i<10;i++)
  {
    if(r->reg_used[i]>0 )
    {
      fprintf(f,"\tmov eax,%s\n",asm_registres[i]);
      fprintf(f,"\tcall libere_registre\n");
    }
    if(r->ureg_used[i]>0 )
    {
      fprintf(f,"\tmov eax,%s\n",asm_registres[i]);
      fprintf(f,"\tcall libere_uregistre\n");
    }
    if(r->randreg_used[i]>0 )
    {
      fprintf(f,"\tmov eax,[esi-%d-4] ; FREEREG%d\n",(r->nb_randint+position_rnd(i,r->randreg_used))*4,i);
      fprintf(f,"\tcall libere_registre\n");
    }
    if(r->urandreg_used[i]>0 )
    {
      fprintf(f,"\tmov eax,[esi-%d-4] ; RNDREG%d\n",(r->nb_randint+position_rnd(i,r->urandreg_used))*4,i);
      fprintf(f,"\tcall libere_uregistre\n");
    }
    if(r->randmem_used[i]>0 )
    {
      fprintf(f,"\tmov eax,[esi-%d-4] ; FREEMEM%d\n",(r->nb_randint+r->nb_randreg+position_rnd(i,r->randmem_used))*4,i);
      fprintf(f,"\tcall libere_memoire\n");
    }
  }
  if(r->nb_randint+r->nb_randmem+r->nb_randreg+r->nb_urandreg+r->nb_lab>0)
    {
      fprintf(f,"\tadd esp,%d\n",(r->nb_randint+r->nb_randmem+r->nb_randreg+r->nb_urandreg+r->nb_lab)*4);
    }
  fprintf(f,"\tjmp %s_fin\n",t->nom);    
}

int compare_lockeds(void* s1,void* s2,int n)
{
  Locked* l=(Locked*) s1;
  return(strncmp(l->id,s2,n));
}


void asm_opcode(FILE* f,Opcode* o,Regle* r,linkedlist* arguments,linkedlist* lockeds)
{
  switch(o->letype)
    {
    case ASMOPCODE:
      {
          int l=get_label();
          fprintf(f,"\tcmp byte [ebp+poly_passe],NB_PASSES/2\n");
          fprintf(f,"\tjbe goto_%d  ; pas d'asm a la première passe car labels faux\n",l);
      
        	fprintf(f,"; ASM code from line %d\n",o->ligne);
        	/* A changer : on remplace le nom des arguments par leur position dans la pile */
        	char* txt=o->operandes.opasm.asmtxt;
        	int indice=0;
        	cellule* a=ll_front(arguments);
        	while(a!=NULL)
        	{
        	  char rplc[20];
        	  Argument* arg=(Argument*)a->valeur;
        	  snprintf(rplc,25,"[esi+%d+8]",(ll_size(arguments)-1-indice)*4);
        	  txt=strmyreplace(txt,(const char*)arg->nom,(const char*) rplc);
        	  a=ll_next(arguments,a);
        	  indice++;
        	}
        	indice=0;
        	a=ll_front(lockeds);
        	while(a!=NULL)
        	{
        	  char rplc[250];
        	  Locked* lo=(Locked*) a->valeur;
        	  snprintf(rplc,250,"[ebp+locked_%s]",lo->id);
        	  txt=strmyreplace(txt,(const char*)lo->id,(const char*) rplc);
        	  a=ll_next(lockeds,a);
        	  indice++;
        	}
        
        	o->operandes.opasm.asmtxt=txt;
        	fprintf(f,"%s",txt);
        	fprintf(f,"goto_%d:   ; END of asm code\n",l);
        	break;
      }
    case CALLOPCODE:
      {
          if(nb_calls_restants(r,o)>0)
          {
              fprintf(f,"\tmov eax,%d\n",nb_calls_restants(r,o));
	      fprintf(f,"\tcall optimise_taille_code_genere\n");
              fprintf(f,"\tpush eax\n");
          }    
    if(o->operandes.opcall.transfo->regledefaut->minimum_taille>0)      
	    fprintf(f,"\tadd edx,%d ; taille minimale de la transformation %s\n",o->operandes.opcall.transfo->regledefaut->minimum_taille,o->operandes.opcall.transfo->nom);
	cellule* cs=ll_front(&o->operandes.opcall.arguments);
	while(cs!=NULL)
	  {
	    SousOpcode* s=(SousOpcode*)cs->valeur;
	    int reg=asm_sous_opcode(f,s,r,arguments,lockeds);
	    if(libere_registre(f,reg))
	      {
		fprintf(f,"\txchg %s,dword [esp]\n",registres_noms[reg]);
	      }
	    else
	      {
		fprintf(f,"\tpush %s\n",registres_noms[reg]);
	      }
	    cs=ll_next(&o->operandes.opcall.arguments,cs);
	  }
	fprintf(f,"\tcall asm_%s\n",o->operandes.opcall.transfo->nom);
	if(nb_calls_restants(r,o)>0)
    {	
       fprintf(f,"\tpop eax\n");
	   fprintf(f,"\tadd edx,eax\n");
    }	   
	break;
      }
      case LABELOPCODE:
      {
        fprintf(f,"\tmov eax,edi\n");
        fprintf(f,"\tsub eax,[ebp+poly_va_buffer]\n");
        fprintf(f,"\tadd eax,[ebp+poly_va_code]\n");
        fprintf(f,"\tmov ebx,[esi-%d-4] ; LABEL%d\n",(r->nb_randint+r->nb_randreg+r->nb_randmem+position_rnd(o->operandes.oplabel.num,r->lab_used))*4,o->operandes.oplabel.num); 
        fprintf(f,"\tmov [ebx],eax\n");
        break;
      }
      
      
      
      case LOCKOPCODE:
      {
	int reg=asm_sous_opcode(f,o->operandes.oplock.ss,r,arguments,lockeds );
	if(o->operandes.oplock.ss->letype==REG || o->operandes.oplock.ss->letype==RNDR 
        || o->operandes.oplock.ss->letype==ARG && o->operandes.oplock.ss->argtype==ATYPE_REGISTRE)
	{
	  fprintf(f,"\tmov eax,%s\n",registres_noms[reg]);
	  fprintf(f,"\tcall lock_registre\n");
	}
	else if(o->operandes.oplock.ss->letype==RNDM
         || o->operandes.oplock.ss->letype==ARG && o->operandes.oplock.ss->argtype==ATYPE_ADRESSE)
	{
	  fprintf(f,"\tmov eax,%s\n",registres_noms[reg]);
	  fprintf(f,"\tcall lock_memoire\n");
	}
	else if(o->operandes.oplock.ss->letype==UREG || o->operandes.oplock.ss->letype==URNDR )
	{
	  fprintf(f,"\tmov eax,%s\n",registres_noms[reg]);
	  fprintf(f,"\tcall lock_uregistre\n");
	}
	if(o->operandes.oplock.id!=NULL)
	{
	  fprintf(f,"\tmov [ebp+locked_%s],%s    ; LOCKED\n",o->operandes.oplock.id,registres_noms[reg]);
	}
	libere_registre(f,reg);
	break;
      }
      
      
            
      case FREEOPCODE:
      {
	if(o->operandes.oplock.id!=NULL)
	{
	  cellule* p=ll_find(lockeds,o->operandes.oplock.id,compare_lockeds);
	  if(p!=NULL)
	  {
	    Locked* l=(Locked*)p->valeur;
	    if(l->ss->letype==RNDR  ||l->ss->letype==REG
             || l->ss->letype==ARG && l->ss->argtype==ATYPE_REGISTRE)
	    {
	      fprintf(f,"\tmov eax,[ebp+locked_%s] ; FREEDREG %s\n",l->id,l->id);
	      fprintf(f,"\tcall free_registre\n");
	    }
	    else if(l->ss->letype==RNDM
                  || l->ss->letype==ARG && l->ss->argtype==ATYPE_ADRESSE)
	    {
	      fprintf(f,"\tmov eax,[ebp+locked_%s] ; FREEDMEM %s\n",l->id,l->id);
	      fprintf(f,"\tcall free_memoire\n");
	    }
	    else if(l->ss->letype==URNDR||l->ss->letype==UREG)
	    {
	      fprintf(f,"\tmov eax,[ebp+locked_%s] ; FREEDUREG %s\n",l->id,l->id);
	      fprintf(f,"\tcall free_uregistre\n");
	    }
	  }
	}
	else
	{
	  int reg=asm_sous_opcode(f,o->operandes.oplock.ss,r,arguments,lockeds );
	  if(o->operandes.oplock.ss->letype==REG || o->operandes.oplock.ss->letype==RNDR )
	  {
	    fprintf(f,"\tmov eax,%s\n",registres_noms[reg]);
	    fprintf(f,"\tcall free_registre\n");
	  }
	  else if(o->operandes.oplock.ss->letype==RNDM)
	  {
	    fprintf(f,"\tmov eax,%s\n",registres_noms[reg]);
	    fprintf(f,"\tcall free_memoire\n");
	  }
	  else if(o->operandes.oplock.ss->letype==UREG || o->operandes.oplock.ss->letype==URNDR )
	  {
	    fprintf(f,"\tmov eax,%s\n",registres_noms[reg]);
	    fprintf(f,"\tcall free_uregistre\n");
	  }
	  libere_registre(f,reg);
	}
	break;
      }
   
      case INITMEMOPCODE:
      {
	registre_force(f,REBX);
	int reg=asm_sous_opcode(f,o->operandes.opegal.valeur,r,arguments,lockeds);
	fprintf(f,"\tmov ebx,%s\n",registres_noms[reg]);
	libere_registre(f,reg);
	
	registre_force(f,REAX);
	reg=asm_sous_opcode(f,o->operandes.opegal.dest,r,arguments,lockeds);
	fprintf(f,"\tmov eax,%s\n",registres_noms[reg]);
	libere_registre(f,reg);	
	fprintf(f,"\tcall set_memoire\n");
	libere_registre(f,REAX);	
	libere_registre(f,REBX);	
	break;
      }
      case CHANGEMEMOPCODE:
      {
	registre_force(f,REBX);
	int reg=asm_sous_opcode(f,o->operandes.opegal.valeur,r,arguments,lockeds);
	fprintf(f,"\tmov ebx,%s\n",registres_noms[reg]);
	libere_registre(f,reg);
	
	registre_force(f,REAX);
	reg=asm_sous_opcode(f,o->operandes.opegal.dest,r,arguments,lockeds);
	fprintf(f,"\tmov eax,%s\n",registres_noms[reg]);
	libere_registre(f,reg);	
	fprintf(f,"\tcall change_memoire\n");
	libere_registre(f,REAX);	
	libere_registre(f,REBX);	
	break;
      }
      case WRITE:
      {
	if(o->operandes.opwrite.valeur->letype==CONSTANTE)
	{
	  fprintf(f,"\tmov eax,%d\n",o->operandes.opwrite.valeur->operandes.valeur);
	}
	else
	{
	  int reg=asm_sous_opcode(f,o->operandes.opwrite.valeur,r,arguments,lockeds);
	  if(reg!=REG_EAX)
	    fprintf(f,"\tmov eax,%s\n",registres_noms[reg]);
	  libere_registre(f,reg);
	}
	switch(o->operandes.opwrite.nboctets)
	{
	  case 1:
	    fprintf(f,"\tstosb\n");
	    break;
	  case 2:
	    fprintf(f,"\tstosw\n");
	    break;
	  case 4:
	    fprintf(f,"\tstosd\n");
	    break;
	}
	break;
      }
      case CONDITIONIF:
      {
	int lfin=get_label();
	int taille_if=minimum_taille(&o->operandes.opif.codeif,50000,0);
	fprintf(f,"\tadd edx,%d\n",taille_if);
	int reg=asm_sous_opcode(f,o->operandes.opif.condition,r,arguments,lockeds);	
	fprintf(f,"\ttest %s,%s\n",registres_noms[reg],registres_noms[reg]);
	libere_registre(f,reg);
	fprintf(f,"\tjz near goto_%d\n",lfin);
	fprintf(f,"\tsub edx,%d\n",taille_if);
	cellule* co=ll_front(&o->operandes.opif.codeif);
	while(co!=NULL)
	{
	  Opcode* o2=(Opcode*)co->valeur;
	  asm_opcode(f,o2,r,arguments,lockeds);
	  co=ll_next(&o->operandes.opif.codeif,co);
	}
	fprintf(f,"goto_%d:\n",lfin);
	break;
      }
    case CONDITIONIFELSE:
      {
	int lelse=get_label(),lfin=get_label();
	int taille_if=minimum_taille(&o->operandes.opif.codeif,50000,0);
	int taille_else=minimum_taille(&o->operandes.opif.codeelse,50000,0);
	int taille_max=taille_if>taille_else?taille_if:taille_else;
	int reg=asm_sous_opcode(f,o->operandes.opif.condition,r,arguments,lockeds);
	fprintf(f,"\ttest %s,%s\n",registres_noms[reg],registres_noms[reg]);
	libere_registre(f,reg);
	fprintf(f,"\tjz near goto_%d\n",lelse);
	if(taille_if<taille_max)
	   fprintf(f,"\tadd edx,%d\n",taille_max-taille_if);
	cellule* co=ll_front(&o->operandes.opif.codeif);
	while(co!=NULL)
	{
	  Opcode* o2=(Opcode*)co->valeur;
	  asm_opcode(f,o2,r,arguments,lockeds);
	  co=ll_next(&o->operandes.opif.codeif,co);
	}
	fprintf(f,"\tjmp near goto_%d\n",lfin);
	fprintf(f,"goto_%d:\n",lelse);
	if(taille_else<taille_max)
	   fprintf(f,"\tadd edx,%d\n",taille_max-taille_else);	
	co=ll_front(&o->operandes.opif.codeelse);
	while(co!=NULL)
	{
	  Opcode* o2=(Opcode*)co->valeur;
	  asm_opcode(f,o2,r,arguments,lockeds);
	  co=ll_next(&o->operandes.opif.codeelse,co);
	}
	fprintf(f,"goto_%d:\n",lfin);
	break;
      }
    }
}


int position_rnd(int rnd,int* tab)
{
  int c=0,i;
  for(i=0;i<10 && i<rnd;i++)
    {
      if(tab[i]>=1)
	c++;
    }
  return c;
}

int compare_char_arg(void* a,void* c,int n)
{
  Argument* arg=(Argument*)a;
  return strncmp(arg->nom,(char*)c,n);
}

int asm_sous_opcode(FILE* f,SousOpcode* s,Regle* r,linkedlist* arguments,linkedlist* lockeds)
{
  switch(s->letype)
    {
      case ARG:
      {
	    int reg=registre_libre(f);
	    cellule* p=ll_find(arguments,s->operandes.nom,compare_char_arg);
	    if(p!=NULL)
	    {
	      int pos=ll_indice(arguments,p);
	      fprintf(f,"\tmov %s,[esi+%d+8] ; %s\n",registres_noms[reg],(ll_size(arguments)-1-pos)*4,s->operandes.nom);
	      s->argtype=((Argument*)p->valeur)->type;
	      return reg;
	    }
	    p=ll_find(lockeds,s->operandes.nom,compare_lockeds);
	    if(p!=NULL)
	    {
	      fprintf(f,"\tmov %s,[ebp+locked_%s]\n",registres_noms[reg],s->operandes.nom);
	      return reg;
	    }
	    fprintf(stderr,"[FATAL] Identificateur inconnu : %s\n",s->operandes.nom);
      }
      case UREG:
      case REG:
      {
	int reg=registre_libre(f);
	fprintf(f,"\tmov %s,%s\n",registres_noms[reg],asm_registres[s->operandes.valeur]);
	return reg;
      }
      case VAREXT:
      {
	int reg=registre_libre(f);
	fprintf(f,"\tmov %s,%s\n",registres_noms[reg],s->operandes.nom);
	return reg;
      }
     
      case RNDI:
      {
	int reg;
	if(r->randint_used[s->operandes.valeur]>1)
	{
	    reg=registre_libre(f);
	    fprintf(f,"\tmov %s,[esi-%d-4] ; RNDINT%d\n",registres_noms[reg],position_rnd(s->operandes.valeur,r->randint_used)*4,s->operandes.valeur);
	}
	else
	{
	  reg=registre_libre_different(f,REAX);
	  registre_force(f,REAX);
	  fprintf(f,"\txor eax,eax\n\tdec eax\n");
	  fprintf(f,"\tcall poly_rand_int\n");
	  fprintf(f,"\tmov %s,%s ; RNDINT%d\n",registres_noms[reg],registres_noms[REAX],s->operandes.valeur);
	  libere_registre(f,REAX);
	}
	return reg;
      }
      case RNDR:
      {
	int reg;
	if(r->randreg_used[s->operandes.valeur]>0)
	{
	  reg=registre_libre(f);
	  fprintf(f,"\tmov %s,[esi-%d-4] ; FREEREG%d\n",registres_noms[reg],(r->nb_randint+position_rnd(s->operandes.valeur,r->randreg_used))*4,s->operandes.valeur);
	}
	else
	{
	  reg=registre_libre_different(f,REAX);
	  registre_force(f,REAX);
	  fprintf(f,"\tcall choix_registre\n");
	  fprintf(f,"\tmov %s,%s ; FREEREG%d\n",registres_noms[reg],registres_noms[REAX],s->operandes.valeur);
	  libere_registre(f,REAX);
	}
	return reg;
      }
      case URNDR:
      {
	int reg;
	if(r->urandreg_used[s->operandes.valeur]>0)
	{
	  reg=registre_libre(f);
	  fprintf(f,"\tmov %s,[esi-%d-4] ; RNDREG%d\n",registres_noms[reg],(r->nb_randint+r->nb_randreg+r->nb_randmem+r->nb_lab+position_rnd(s->operandes.valeur,r->urandreg_used))*4,s->operandes.valeur);
	}
	else
	{
	  reg=registre_libre_different(f,REAX);
	  registre_force(f,REAX);
	  fprintf(f,"\tcall choix_uregistre\n");
	  fprintf(f,"\tmov %s,%s ; RNDREG%d\n",registres_noms[reg],registres_noms[REAX],s->operandes.valeur);
	  libere_registre(f,REAX);
	}
	return reg;
      }
      case RNDM:
      {
	int reg;
	if(r->randmem_used[s->operandes.valeur]>0)
	{
	  reg=registre_libre(f);
	  fprintf(f,"\tmov %s,[esi-%d-4] ; FREEMEM%d\n",registres_noms[reg],(r->nb_randint+r->nb_randreg+position_rnd(s->operandes.valeur,r->randmem_used))*4,s->operandes.valeur);
	}
	else
	{
	  reg=registre_libre_different(f,REBX);
	  registre_force(f,REBX);
	  fprintf(f,"\tcall choix_memoire\n");
	  fprintf(f,"\tmov %s,%s ; FREEMEM%d\n",registres_noms[reg],registres_noms[REAX],s->operandes.valeur);
	  libere_registre(f,REBX);
	}
	return reg;
      }
      case LAB:
      {
	      int reg=registre_libre(f);
	      fprintf(f,"\tmov %s,[esi-%d-4] ; LABEL%d\n",registres_noms[reg],(r->nb_randint+r->nb_randreg+r->nb_randmem+position_rnd(s->operandes.valeur,r->lab_used))*4,s->operandes.valeur);
	      fprintf(f,"\tmov %s,[%s]\n",registres_noms[reg],registres_noms[reg]);
	      return reg;
      }
      case CONSTANTE:
      {
	int reg=registre_libre(f);
	fprintf(f,"\tmov %s,%d\n",registres_noms[reg],s->operandes.valeur);
	return reg;
      }
      case ET:
      case OU:
      case OUEX:
      case SOUSTRACTION:
      case ADDITION:
      {
	char op[4];
	switch(s->letype)
	{
	  case ET:
	    strcpy(op,"and");
	    break;
	  case OU:
	    strcpy(op,"or");
	    break;
	  case OUEX:
	    strcpy(op,"xor");
	    break;
	  case ADDITION:
	    strcpy(op,"add");
	    break;
	  case SOUSTRACTION:
	    strcpy(op,"sub");
	    break;
	}
	SousOpcode* s1=s->operandes.couple.gauche;
	SousOpcode* s2=s->operandes.couple.droit;
	int r1,r2;
	if(s1->letype==CONSTANTE && s->letype!=SOUSTRACTION)
	{
	  r2=asm_sous_opcode(f,s2,r,arguments,lockeds);
	  fprintf(f,"\t%s %s,%d\n",op,registres_noms[r2],s1->operandes.valeur);
	  return r2;
	}
	else if(s2->letype==CONSTANTE)
	{
	  r1=asm_sous_opcode(f,s1,r,arguments,lockeds);
	  fprintf(f,"\t%s %s,%d\n",op,registres_noms[r1],s2->operandes.valeur);
	  return r1;
	}
	else
	{
	  r1=asm_sous_opcode(f,s1,r,arguments,lockeds);
	  r2=asm_sous_opcode(f,s2,r,arguments,lockeds);
	  fprintf(f,"\t%s %s,%s\n",op,registres_noms[r1],registres_noms[r2]);
	  libere_registre(f,r2);
	  return r1;
	}
      }
      case MULTIPLICATION:
      {
	SousOpcode* s1=s->operandes.couple.gauche;
	SousOpcode* s2=s->operandes.couple.droit;
	int r1=asm_sous_opcode(f,s1,r,arguments,lockeds);
	int r2=asm_sous_opcode(f,s2,r,arguments,lockeds);
	fprintf(f,"\timul %s,%s\n",registres_noms[r1],registres_noms[r2]);
	libere_registre(f,r2);
	return r1;
      }
      case DIVISION:
      {
	SousOpcode* s1=s->operandes.couple.gauche;
	SousOpcode* s2=s->operandes.couple.droit;
	int r1=asm_sous_opcode(f,s1,r,arguments,lockeds);
	int r2=asm_sous_opcode(f,s2,r,arguments,lockeds);
	fprintf(f,"\tidiv %s,%s\n",registres_noms[r1],registres_noms[r2]);
	libere_registre(f,r2);
	return r1;
      }
      case DECDROIT:
      case DECGAUCHE:
      {
	char op[4];
	int r1,r2;
	if(s->letype==DECDROIT)
	  strcpy(op,"shr");
	else
	  strcpy(op,"shl");
	SousOpcode* s1=s->operandes.couple.gauche;
	SousOpcode* s2=s->operandes.couple.droit;
	if(s2->letype==CONSTANTE)
	{
	  r1=asm_sous_opcode(f,s1,r,arguments,lockeds);
	  fprintf(f,"\t%s %s,%d\n",op,registres_noms[r1],s2->operandes.valeur);
	  return r1;
	}
	else
	{
	  int reg=registre_libre_different(f,RECX);
	  registre_force(f,RECX);
	  r1=asm_sous_opcode(f,s1,r,arguments,lockeds);
	  fprintf(f,"\tmov %s,%s\n",registres_noms[reg],registres_noms[r1]);
	  r2=asm_sous_opcode(f,s2,r,arguments,lockeds);
	  fprintf(f,"\tmov ecx,%s\n",registres_noms[r2]);
	  
	  fprintf(f,"\tshl %s,cl\n",registres_noms[reg],registres_noms[r1]);
	  libere_registre(f,r2);
	  libere_registre(f,r1);
	  libere_registre(f,RECX);
	  return reg;
	}
      }
      case INDIRECTION:
      {
	SousOpcode* s1=s->operandes.sousopcode;
	int r1=asm_sous_opcode(f,s1,r,arguments,lockeds);
	if(r1!=REBX)
	{
	  registre_force(f,REBX);
	  fprintf(f,"\tmov ebx,%s\n",registres_noms[r1]);
	}
	fprintf(f,"\tcall contenu_memoire\n");
	if(r1!=REBX)
	{
	  fprintf(f,"\tmov %s,ebx\n");
	  libere_registre(f,REBX);
	}
	return r1;
      }
      case MOD:
      {
	SousOpcode* s1=s->operandes.couple.gauche;
	SousOpcode* s2=s->operandes.couple.droit;
	int r2=registre_libre_different2(f,REAX,REDX);
	registre_force(f,REAX);
	registre_force(f,REDX);
	int r1=asm_sous_opcode(f,s1,r,arguments,lockeds);
	if(r1!=REAX)
	  fprintf(f,"\tmov eax,%s\n",registres_noms[r1]);
	fprintf(f,"\txor edx,edx\n");
	libere_registre(f,r1);
	r1=asm_sous_opcode(f,s2,r,arguments,lockeds);
	fprintf(f,"\tdiv %s\n",registres_noms[r1]);
	if(r2!=REDX)
	  fprintf(f,"\tmov %s,edx\n",registres_noms[r2]);
	libere_registre(f,r1);
	libere_registre(f,REDX);
	libere_registre(f,REAX);
	return r2;
	}
      case NEGATION:
      {
	SousOpcode* s1=s->operandes.sousopcode;
	int r1=asm_sous_opcode(f,s1,r,arguments,lockeds);
	fprintf(f,"\tnot %s\n",registres_noms[r1]);
	return r1;
      }
      case JA:
      case JB:
      case JAE:
      case JBE:
      case JE:
      case JNE:
      {
	SousOpcode* s1=s->operandes.couple.gauche;
	SousOpcode* s2=s->operandes.couple.droit;
	int r1,r2;
	int l1=get_label(),l2=get_label();
	if(s1->letype==CONSTANTE || s1->letype==UREG)
	{
	  r2=asm_sous_opcode(f,s2,r,arguments,lockeds);
	  if(s1->letype==CONSTANTE)
	    fprintf(f,"\tcmp %s,%d\n",registres_noms[r2],s1->operandes.valeur);
	  else
	    fprintf(f,"\tcmp %s,%s\n",registres_noms[r2],asm_registres[s1->operandes.valeur]);
	  r1=r2;
	}
	else if(s2->letype==CONSTANTE || s2->letype==UREG)
	{
	   r1=asm_sous_opcode(f,s1,r,arguments,lockeds);
	  if(s2->letype==CONSTANTE)
	    fprintf(f,"\tcmp %s,%d\n",registres_noms[r1],s2->operandes.valeur);
	  else
	    fprintf(f,"\tcmp %s,%s\n",registres_noms[r1],asm_registres[s2->operandes.valeur]);

	}
	else
	{
	  r1=asm_sous_opcode(f,s1,r,arguments,lockeds);
	  r2=asm_sous_opcode(f,s2,r,arguments,lockeds);
	  fprintf(f,"\tcmp %s,%s\n",registres_noms[r1],registres_noms[r2]);
	  libere_registre(f,r2);
	}
	switch(s->letype)
	{
	  case JA:
	    fprintf(f,"\tjg near goto_%d\n",l1);
	    break;
	  case JAE:
	    fprintf(f,"\tjge near goto_%d\n",l1);
	    break;
	  case JB:
	    fprintf(f,"\tjl near goto_%d\n",l1);
	    break;
	  case JBE:
	    fprintf(f,"\tjle near goto_%d\n",l1);
	    break;
   	  case JE:
	    fprintf(f,"\tje near goto_%d\n",l1);
	    break;
 	  case JNE:
	    fprintf(f,"\tjne near goto_%d\n",l1);
	    break;
	}
	fprintf(f,"\txor %s,%s\n",registres_noms[r1],registres_noms[r1]);
	fprintf(f,"\tjmp near goto_%d\n",l2);
	fprintf(f,"goto_%d:\n",l1);
	fprintf(f,"\txor %s,%s\n",registres_noms[r1],registres_noms[r1]);
	fprintf(f,"\tinc %s\n",registres_noms[r1]);
	fprintf(f,"goto_%d:\n",l2);
	return r1;
      }
    }
  return registre_libre(f);
}

/* =================================== PREPROCESS ====================================== */


int minimum_taille(linkedlist* opcodes,int recursivite_max,int recursivite)
{
  if(recursivite>recursivite_max)
    return NON_CALCULE;
  cellule* co=ll_front(opcodes);
  int taille=0;
  while(co!=NULL)
  {
    Opcode* o=(Opcode*)co->valeur;
    if(o->letype==ASMOPCODE)
    {
      taille+=o->operandes.opasm.taille;
    }
    else if(o->letype==CALLOPCODE)
    {
      if(o->operandes.opcall.transfo->regledefaut->minimum_taille!=NON_CALCULE)
      {
	taille+=o->operandes.opcall.transfo->regledefaut->minimum_taille;
      }
      else
      {
	int m=minimum_taille(&(o->operandes.opcall.transfo->regledefaut->opcodes),recursivite_max,recursivite+1);
	if(m==NON_CALCULE)
	  return NON_CALCULE;
	taille+=m;
      }
    }
    else if(o->letype==WRITE)
    {
      taille+=o->operandes.opwrite.nboctets;
    }
    else if(o->letype==CONDITIONIF)
    {
      int m=minimum_taille(&o->operandes.opif.codeif,recursivite_max,recursivite);
      if(m==NON_CALCULE)
	return NON_CALCULE;
      taille+=m;
    }
    else if(o->letype==CONDITIONIFELSE)
    {
      int m1=minimum_taille(&o->operandes.opif.codeif,recursivite_max,recursivite);
      int m2=minimum_taille(&o->operandes.opif.codeelse,recursivite_max,recursivite);
      if(m1==NON_CALCULE || m2==NON_CALCULE)
	return NON_CALCULE;
      taille+=m1>m2?m1:m2;
    }
    co=ll_next(opcodes,co);
  }
  return taille;
}

int utilisation_rand(SousOpcode* s,int* rnds,int type)
{
   if(s->letype==type)
     {
	if(rnds[s->operandes.valeur]==0)
	  {
	     rnds[s->operandes.valeur]++;
	     return 1;
	  }
	else 
	  {
	     rnds[s->operandes.valeur]++;
	     return 0;
	  }
     }
   else if(estOpBinaire(s))  
   {
	int r1=utilisation_rand(s->operandes.couple.gauche,rnds,type);
	return r1+utilisation_rand(s->operandes.couple.droit,rnds,type);
   }
   else if(estOpUnaire(s))
   {
     return utilisation_rand(s->operandes.sousopcode,rnds,type);
   }
   else 
     return 0;
}

void utilisation_rand_opcodes(linkedlist* opcodes,Regle* r)
{
  cellule* co=ll_front(opcodes);
  
  while(co!=NULL)
  {
    Opcode* o=co->valeur;
    if(o->letype==CALLOPCODE)
    {
      cellule* cs=ll_front(&o->operandes.opcall.arguments);
      while(cs!=NULL)
      {
	SousOpcode* s=(SousOpcode*)cs->valeur;
	r->nb_randint+=utilisation_rand(s,r->randint_used,RNDI);
	r->nb_randmem+=utilisation_rand(s,r->randmem_used,RNDM);
	r->nb_randreg+=utilisation_rand(s,r->randreg_used,RNDR);
	r->nb_urandreg+=utilisation_rand(s,r->urandreg_used,URNDR);
	r->nb_reg+=utilisation_rand(s,r->reg_used,REG);
	 r->nb_ureg+=utilisation_rand(s,r->ureg_used,UREG);
	cs=ll_next(&o->operandes.opcall.arguments,cs);
      }
    }
    else if(o->letype==LOCKOPCODE)
    {
      if(o->operandes.oplock.ss->letype==RNDR)
	r->randreg_locked[o->operandes.oplock.ss->operandes.valeur]=1;
      else if(o->operandes.oplock.ss->letype==RNDM)
	r->randmem_locked[o->operandes.oplock.ss->operandes.valeur]=1;
      else if(o->operandes.oplock.ss->letype==REG)
	r->reg_locked[o->operandes.oplock.ss->operandes.valeur]=1;
      SousOpcode* s=o->operandes.oplock.ss;
      r->nb_randint+=utilisation_rand(s,r->randint_used,RNDI);
      r->nb_randmem+=utilisation_rand(s,r->randmem_used,RNDM);
      r->nb_randreg+=utilisation_rand(s,r->randreg_used,RNDR);      
      r->nb_urandreg+=utilisation_rand(s,r->urandreg_used,URNDR);
      r->nb_reg+=utilisation_rand(s,r->reg_used,REG);
       r->nb_ureg+=utilisation_rand(s,r->ureg_used,UREG);
    }
    else if(o->letype==WRITE)
    {
      SousOpcode* s=o->operandes.opwrite.valeur;
      r->nb_randint+=utilisation_rand(s,r->randint_used,RNDI);
      r->nb_randmem+=utilisation_rand(s,r->randmem_used,RNDM);
      r->nb_randreg+=utilisation_rand(s,r->randreg_used,RNDR);
      r->nb_urandreg+=utilisation_rand(s,r->urandreg_used,URNDR);
      r->nb_reg+=utilisation_rand(s,r->reg_used,REG);
       r->nb_ureg+=utilisation_rand(s,r->ureg_used,UREG);
    }
    else if(o->letype==LABELOPCODE)
    {
      r->lab_used[o->operandes.oplabel.num]=1;
      r->nb_lab++;
    }	       
    else if(o->letype==CONDITIONIF)
    {
      SousOpcode* s=o->operandes.opif.condition;
      r->nb_randint+=utilisation_rand(s,r->randint_used,RNDI);
      r->nb_randmem+=utilisation_rand(s,r->randmem_used,RNDM);
      r->nb_randreg+=utilisation_rand(s,r->randreg_used,RNDR);
      r->nb_urandreg+=utilisation_rand(s,r->urandreg_used,URNDR);
      utilisation_rand_opcodes(&o->operandes.opif.codeif,r);
    }	  	       
    else if(o->letype==CONDITIONIFELSE)
    {
      SousOpcode* s=o->operandes.opif.condition;
      r->nb_randint+=utilisation_rand(s,r->randint_used,RNDI);
      r->nb_randmem+=utilisation_rand(s,r->randmem_used,RNDM);
      r->nb_randreg+=utilisation_rand(s,r->randreg_used,RNDR);
      r->nb_urandreg+=utilisation_rand(s,r->urandreg_used,URNDR);
      utilisation_rand_opcodes(&o->operandes.opif.codeif,r);
      utilisation_rand_opcodes(&o->operandes.opif.codeelse,r);
    }
    else if(o->letype==INITMEMOPCODE || o->letype==CHANGEMEMOPCODE)
       {
	  SousOpcode* s=o->operandes.opegal.valeur;
	  r->nb_randint+=utilisation_rand(s,r->randint_used,RNDI);
	  r->nb_randmem+=utilisation_rand(s,r->randmem_used,RNDM);
	  r->nb_randreg+=utilisation_rand(s,r->randreg_used,RNDR);
	  r->nb_urandreg+=utilisation_rand(s,r->urandreg_used,URNDR);
          r->nb_reg+=utilisation_rand(s,r->reg_used,REG);
	  s=o->operandes.opegal.dest;
	  r->nb_randint+=utilisation_rand(s,r->randint_used,RNDI);
	  r->nb_randmem+=utilisation_rand(s,r->randmem_used,RNDM);
	  r->nb_randreg+=utilisation_rand(s,r->randreg_used,RNDR);
	  r->nb_urandreg+=utilisation_rand(s,r->urandreg_used,URNDR);
	  r->nb_reg+=utilisation_rand(s,r->reg_used,REG);
	  r->nb_ureg+=utilisation_rand(s,r->ureg_used,UREG);
       }
     
    co=ll_next(opcodes,co);
  }
}

void lie_transfo_opcodes(linkedlist* opcodes,linkedlist* transformations)
{
  cellule* co=ll_front(opcodes);
  while(co!=NULL)
  {
    Opcode* o=(Opcode*)co->valeur;
    if(o->letype==CALLOPCODE)
    {
      cellule* lct=ll_find(transformations,o->operandes.opcall.nomtransfo,cmp_char_transfo);
      Transformation* lt=(Transformation*)lct->valeur;
      o->operandes.opcall.transfo=lt;
    }
    else if(o->letype==CONDITIONIF)
    {
      lie_transfo_opcodes(&o->operandes.opif.codeif,transformations);
    }
    else if(o->letype==CONDITIONIFELSE)
    {
      lie_transfo_opcodes(&o->operandes.opif.codeif,transformations);
      lie_transfo_opcodes(&o->operandes.opif.codeelse,transformations);
    }
    co=ll_next(opcodes,co);
  }
}

void lie_transfo_regle(linkedlist* transformations)
{
   cellule* ct=ll_front(transformations);
   while(ct!=NULL)
     {
	Transformation* t=(Transformation*)ct->valeur;
	cellule* cr=ll_front(&t->regles);
	while(cr!=NULL)
	  {
	     Regle* r=(Regle*)cr->valeur;
	     if(r->is_defaut)
	       {
		 t->regledefaut=r;
	       }
	     lie_transfo_opcodes(&r->opcodes,transformations);
	     cr=ll_next(&t->regles,cr);
	  }
	ct=ll_next(transformations,ct);
     }
}


int preprocess(linkedlist* transformations)
{
  lie_transfo_regle(transformations);
  cellule* ct=ll_front(transformations);
  while(ct!=NULL)
    {
      Transformation* t=(Transformation*)ct->valeur;
      cellule* cr=ll_front(&t->regles);
      while(cr!=NULL)
	{
	  Regle* r=(Regle*)cr->valeur;
	  r->minimum_taille=minimum_taille(&r->opcodes,ll_size(transformations),0);
	  if(r->minimum_taille==NON_CALCULE)
	    {
	      snprintf(derniere_erreur,1024,"[ FATAL ] Recursion trop longue pour la transformation %s",t->nom);
	      add_error(derniere_erreur);
	      return 0;
	    }
	   
	   r->nb_randint=0;
	   r->nb_randmem=0;
	   r->nb_randreg=0;
	   r->nb_urandreg=0;
	   r->nb_lab=0;
	   r->nb_reg=0;
	   r->nb_ureg=0;
	   int i;
	   for(i=0;i<10;i++)
	     {
		r->randint_used[i]=0;
		r->randmem_used[i]=0;
		r->randreg_used[i]=0;
		r->urandreg_used[i]=0;
		r->reg_used[i]=0;
		r->ureg_used[i]=0;
		r->lab_used[i]=0;
		r->reg_locked[i]=0;
		r->randreg_locked[i]=0;
		r->randmem_locked[i]=0;
	     }
	   utilisation_rand_opcodes(&r->opcodes,r);
	   cr=ll_next(&t->regles,cr);
	}
      ct=ll_next(transformations,ct);
    }
  return 1;
}

/* ================================== PRODUCTION DE CODE ==================================== */


void produit_lockeds_tasm(FILE* f,linkedlist* lockeds)
{
  cellule* c=ll_front(lockeds);
  while(c!=NULL)
    {
       Locked* o=(Locked *)c->valeur;
       fprintf(f,"locked_%s dd 0           ;LOCKED\n",o->id);
       c=ll_next(lockeds,c);
    }   
}


void produit_table_opcodes_tasm(FILE* f,linkedlist* transfos)
{
  fprintf(f,"jmp_table_opcodes:\n");
  fprintf(f,"\tdd 0; OP_FIN_DECRYPTEUR\n");
  cellule* c=ll_front(transfos);
  while(c!=NULL)
    {
      Transformation* t=(Transformation *)c->valeur;
      fprintf(f,"\tdd asm_%s; OP_%s\n",t->nom,t->nom);
      c=ll_next(transfos,c);
    }
}


void produit_opcodes_tasm(FILE* f,linkedlist* transfos)
{
  int op_cur=1;
  fprintf(f,"OP_FIN_DECRYPTEUR EQU 0\n\n");;
  cellule* c=ll_front(transfos);
  while(c!=NULL)
    {
      Transformation* t=(Transformation *)c->valeur;
      fprintf(f,"OP_%s EQU %d\n",t->nom,op_cur++);
      fprintf(f,"OP_%s_NB_ARGS EQU %d\n\n",t->nom,ll_size(&(t->arguments)));
      c=ll_next(transfos,c);
    }
}


void produit_defines_tasm(FILE* f)
{
  fprintf(f,"REG_EAX EQU 00\n");
  fprintf(f,"REG_ECX EQU 01\n");
  fprintf(f,"REG_EDX EQU 02\n");
  fprintf(f,"REG_EBX EQU 03\n");
  fprintf(f,"REG_ESP EQU 04\n");
  fprintf(f,"REG_EBP EQU 05\n");
  fprintf(f,"REG_ESI EQU 06\n");
  fprintf(f,"REG_EDI EQU 07\n\n");
  fprintf(f,"TYPE_REGISTRE EQU 0\n");
  fprintf(f,"TYPE_ADRESSE EQU 1\n");
  fprintf(f,"TYPE_ENTIER EQU 2\n");
}

void produit_macros_tasm(FILE* f,linkedlist* transfos)
{
  
  fprintf(f,"macro FIN_DECRYPTEUR { \n");
  fprintf(f,"\t db OP_FIN_DECRYPTEUR\n");
  fprintf(f,"}\n\n");

  cellule* c=ll_front(transfos);
  while(c!=NULL)
    {
      Transformation* t=(Transformation *)c->valeur;
      fprintf(f,"macro %s ",t->nom);
      cellule* a=ll_front(&t->arguments);
      while(a!=NULL)
      {
	  Argument* arg=(Argument*)a->valeur;
	  fprintf(f,"%s",arg->nom);
	  a=ll_next(&t->arguments,a);
	  if(a!=NULL)
	    fprintf(f,",");
      }
      fprintf(f,"\n{\n");
      fprintf(f,"\tdb OP_%s\n",t->nom);
      fprintf(f,"\tdb OP_%s_NB_ARGS\n",t->nom);
       a=ll_front(&t->arguments);
      int i=1;
      while(a!=NULL)
	{
	  Argument* arg=(Argument*)a->valeur;
	  fprintf(f,"\tdb %s\n",asm_types[arg->type]);
	  fprintf(f,"\tdd %s\n",arg->nom);
	  a=ll_next(&t->arguments,a);
	  i++;
	}      
      fprintf(f,"}\n\n");
      c=ll_next(transfos,c);
    }
}










