#include <stdio.h>
#include <stdlib.h>

/*
#include "poly_fonctions.h"

int main()
{
   FILE* f=fopen("poly_fonctions.asm","w");
   fprintf(f,poly_fonctions);
   fclose(f);   
} 
*/   
int main()
{
  char ligne[1024];
  printf("char* poly_fonctions=\n");
  while(  fgets(ligne,1024,stdin))
  {
    printf("\"");
    char* p;
    for(p=ligne;*p!='\0';p++)
    {
      switch(*p)
      {
	case '\t':
	  printf("\\t");
	  break;
	case '\n':
	  printf("\\n");
	  break;
	case '\\':
	  printf("\\\\");
	  break;
	case '\r':
	  printf("\\r");
	  break;
	case '"':
	  printf("\\\"");
	  break;
	default:
	  printf("%c",*p);
      }
    }
    printf("\"\n");
  }
  printf(";\n");
  return(EXIT_SUCCESS);
}
