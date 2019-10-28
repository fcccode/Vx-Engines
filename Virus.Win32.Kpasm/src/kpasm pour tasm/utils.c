#include "utils.h"
#include <stdio.h>

char* strmyreplace(char* texte,const char* cherche,const char* remplace)
{
  char* orgtexte=texte;
  char* p=strstr(texte,cherche);
  if(p==NULL)
    return texte;
  char* r=(char*) malloc(1);
  *r=0;
  while(p!=NULL)
    {
      if(((p!=orgtexte) || ((*(p-1))==' ' || (*(p-1))=='\t' || (*(p-1))==',' || (*(p-1))=='['))
	 && ((*(p+strlen(cherche)))==' ' || (*(p+strlen(cherche)))=='\t' || (*(p+strlen(cherche)))=='\n' || (*(p+strlen(cherche)))==',' || (*(p+strlen(cherche)))==']'))
	{
	  char tmp=*p;
	  *p=0;
	  r=(char*)realloc(r,strlen(r)+strlen(texte)+strlen(remplace)+1);
	  strcat(r,texte);
	  strcat(r,remplace);
	  *p=tmp;
	}
      else
	{
	  *p=0;
	  r=(char*)realloc(r,strlen(r)+strlen(texte)+strlen(cherche)+1);
	  strcat(r,texte);
	  strcat(r,cherche);
	}
      texte=p+strlen(cherche);
      p=strstr(texte,cherche);
    }
  r=(char*)realloc(r,strlen(r)+strlen(texte)+1);
  strcat(r,texte);
  free(orgtexte);
  return r;
}

