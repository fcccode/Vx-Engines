/* A Bison parser, made by GNU Bison 2.1.  */

/* Skeleton parser for Yacc-like parsing with Bison,
   Copyright (C) 1984, 1989, 1990, 2000, 2001, 2002, 2003, 2004, 2005 Free Software Foundation, Inc.

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2, or (at your option)
   any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 51 Franklin Street, Fifth Floor,
   Boston, MA 02110-1301, USA.  */

/* As a special exception, when this file is copied by Bison into a
   Bison output file, you may use that output file without restriction.
   This special exception was added by the Free Software Foundation
   in version 1.24 of Bison.  */

/* Tokens.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
   /* Put the tokens into the symbol table, so that GDB and other debuggers
      know about them.  */
   enum yytokentype {
     SHL = 258,
     SHR = 259,
     MODULO = 260,
     OR = 261,
     AND = 262,
     WRITE8 = 263,
     WRITE16 = 264,
     WRITE32 = 265,
     LABELLOCK = 266,
     LABELFREE = 267,
     LABEL = 268,
     TAILLE_CODE = 269,
     TAILLE_DECRYPTEUR = 270,
     IDEXT = 271,
     REGLE_DEFAUT = 272,
     SAUT_LIGNE = 273,
     PARENTHESE_OUVRANTE = 274,
     PARENTHESE_FERMANTE = 275,
     ACCOLADE_OUVRANTE = 276,
     ACCOLADE_FERMANTE = 277,
     CROCHET_OUVRANT = 278,
     CROCHET_FERMANT = 279,
     NOMBRE = 280,
     ID = 281,
     VIRGULE = 282,
     LOCK = 283,
     FREE = 284,
     INITMEM = 285,
     CHANGEMEM = 286,
     RAW = 287,
     ASM = 288,
     RNDMEM = 289,
     RNDMEMI = 290,
     RNDINT = 291,
     RNDREG = 292,
     FIN_OPCODE = 293,
     DEUXPOINTS = 294,
     SUP = 295,
     EGAL = 296,
     INF = 297,
     PASEGAL = 298,
     INFOUEGAL = 299,
     SUPOUEGAL = 300,
     IF = 301,
     ELSE = 302,
     BOR = 303,
     BAND = 304,
     REGISTRE = 305,
     UREGISTRE = 306,
     URNDREG = 307,
     ATYPE = 308,
     NOT = 309,
     XOR = 310,
     MOINS = 311,
     PLUS = 312,
     DIV = 313,
     MULT = 314
   };
#endif
/* Tokens.  */
#define SHL 258
#define SHR 259
#define MODULO 260
#define OR 261
#define AND 262
#define WRITE8 263
#define WRITE16 264
#define WRITE32 265
#define LABELLOCK 266
#define LABELFREE 267
#define LABEL 268
#define TAILLE_CODE 269
#define TAILLE_DECRYPTEUR 270
#define IDEXT 271
#define REGLE_DEFAUT 272
#define SAUT_LIGNE 273
#define PARENTHESE_OUVRANTE 274
#define PARENTHESE_FERMANTE 275
#define ACCOLADE_OUVRANTE 276
#define ACCOLADE_FERMANTE 277
#define CROCHET_OUVRANT 278
#define CROCHET_FERMANT 279
#define NOMBRE 280
#define ID 281
#define VIRGULE 282
#define LOCK 283
#define FREE 284
#define INITMEM 285
#define CHANGEMEM 286
#define RAW 287
#define ASM 288
#define RNDMEM 289
#define RNDMEMI 290
#define RNDINT 291
#define RNDREG 292
#define FIN_OPCODE 293
#define DEUXPOINTS 294
#define SUP 295
#define EGAL 296
#define INF 297
#define PASEGAL 298
#define INFOUEGAL 299
#define SUPOUEGAL 300
#define IF 301
#define ELSE 302
#define BOR 303
#define BAND 304
#define REGISTRE 305
#define UREGISTRE 306
#define URNDREG 307
#define ATYPE 308
#define NOT 309
#define XOR 310
#define MOINS 311
#define PLUS 312
#define DIV 313
#define MULT 314




#if ! defined (YYSTYPE) && ! defined (YYSTYPE_IS_DECLARED)
#line 19 "kpasm.y"
typedef union value {
  SousOpcode* sousopcode;
  Opcode* opcode;
  int entier;
  char* chaine;
  linkedlist liste;
  Regle* regle;
} YYSTYPE;
/* Line 1447 of yacc.c.  */
#line 165 "kpasm.tab.h"
# define yystype YYSTYPE /* obsolescent; will be withdrawn */
# define YYSTYPE_IS_DECLARED 1
# define YYSTYPE_IS_TRIVIAL 1
#endif

extern YYSTYPE yylval;

#if ! defined (YYLTYPE) && ! defined (YYLTYPE_IS_DECLARED)
typedef struct YYLTYPE
{
  int first_line;
  int first_column;
  int last_line;
  int last_column;
} YYLTYPE;
# define yyltype YYLTYPE /* obsolescent; will be withdrawn */
# define YYLTYPE_IS_DECLARED 1
# define YYLTYPE_IS_TRIVIAL 1
#endif

extern YYLTYPE yylloc;


