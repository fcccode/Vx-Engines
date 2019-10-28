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

/* Written by Richard Stallman by simplifying the original so called
   ``semantic'' parser.  */

/* All symbols defined below should begin with yy or YY, to avoid
   infringing on user name space.  This should be done even for local
   variables, as they might otherwise be expanded by user macros.
   There are some unavoidable exceptions within include files to
   define necessary library symbols; they are noted "INFRINGES ON
   USER NAME SPACE" below.  */

/* Identify Bison output.  */
#define YYBISON 1

/* Bison version.  */
#define YYBISON_VERSION "2.1"

/* Skeleton name.  */
#define YYSKELETON_NAME "yacc.c"

/* Pure parsers.  */
#define YYPURE 0

/* Using locations.  */
#define YYLSP_NEEDED 1



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




/* Copy the first part of user declarations.  */
#line 1 "kpasm.y"

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


/* Enabling traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif

/* Enabling verbose error messages.  */
#ifdef YYERROR_VERBOSE
# undef YYERROR_VERBOSE
# define YYERROR_VERBOSE 1
#else
# define YYERROR_VERBOSE 1
#endif

/* Enabling the token table.  */
#ifndef YYTOKEN_TABLE
# define YYTOKEN_TABLE 0
#endif

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
/* Line 196 of yacc.c.  */
#line 229 "kpasm.tab.c"
# define yystype YYSTYPE /* obsolescent; will be withdrawn */
# define YYSTYPE_IS_DECLARED 1
# define YYSTYPE_IS_TRIVIAL 1
#endif

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


/* Copy the second part of user declarations.  */


/* Line 219 of yacc.c.  */
#line 253 "kpasm.tab.c"

#if ! defined (YYSIZE_T) && defined (__SIZE_TYPE__)
# define YYSIZE_T __SIZE_TYPE__
#endif
#if ! defined (YYSIZE_T) && defined (size_t)
# define YYSIZE_T size_t
#endif
#if ! defined (YYSIZE_T) && (defined (__STDC__) || defined (__cplusplus))
# include <stddef.h> /* INFRINGES ON USER NAME SPACE */
# define YYSIZE_T size_t
#endif
#if ! defined (YYSIZE_T)
# define YYSIZE_T unsigned int
#endif

#ifndef YY_
# if YYENABLE_NLS
#  if ENABLE_NLS
#   include <libintl.h> /* INFRINGES ON USER NAME SPACE */
#   define YY_(msgid) dgettext ("bison-runtime", msgid)
#  endif
# endif
# ifndef YY_
#  define YY_(msgid) msgid
# endif
#endif

#if ! defined (yyoverflow) || YYERROR_VERBOSE

/* The parser invokes alloca or malloc; define the necessary symbols.  */

# ifdef YYSTACK_USE_ALLOCA
#  if YYSTACK_USE_ALLOCA
#   ifdef __GNUC__
#    define YYSTACK_ALLOC __builtin_alloca
#   else
#    define YYSTACK_ALLOC alloca
#    if defined (__STDC__) || defined (__cplusplus)
#     include <stdlib.h> /* INFRINGES ON USER NAME SPACE */
#     define YYINCLUDED_STDLIB_H
#    endif
#   endif
#  endif
# endif

# ifdef YYSTACK_ALLOC
   /* Pacify GCC's `empty if-body' warning. */
#  define YYSTACK_FREE(Ptr) do { /* empty */; } while (0)
#  ifndef YYSTACK_ALLOC_MAXIMUM
    /* The OS might guarantee only one guard page at the bottom of the stack,
       and a page size can be as small as 4096 bytes.  So we cannot safely
       invoke alloca (N) if N exceeds 4096.  Use a slightly smaller number
       to allow for a few compiler-allocated temporary stack slots.  */
#   define YYSTACK_ALLOC_MAXIMUM 4032 /* reasonable circa 2005 */
#  endif
# else
#  define YYSTACK_ALLOC YYMALLOC
#  define YYSTACK_FREE YYFREE
#  ifndef YYSTACK_ALLOC_MAXIMUM
#   define YYSTACK_ALLOC_MAXIMUM ((YYSIZE_T) -1)
#  endif
#  ifdef __cplusplus
extern "C" {
#  endif
#  ifndef YYMALLOC
#   define YYMALLOC malloc
#   if (! defined (malloc) && ! defined (YYINCLUDED_STDLIB_H) \
	&& (defined (__STDC__) || defined (__cplusplus)))
void *malloc (YYSIZE_T); /* INFRINGES ON USER NAME SPACE */
#   endif
#  endif
#  ifndef YYFREE
#   define YYFREE free
#   if (! defined (free) && ! defined (YYINCLUDED_STDLIB_H) \
	&& (defined (__STDC__) || defined (__cplusplus)))
void free (void *); /* INFRINGES ON USER NAME SPACE */
#   endif
#  endif
#  ifdef __cplusplus
}
#  endif
# endif
#endif /* ! defined (yyoverflow) || YYERROR_VERBOSE */


#if (! defined (yyoverflow) \
     && (! defined (__cplusplus) \
	 || (defined (YYLTYPE_IS_TRIVIAL) && YYLTYPE_IS_TRIVIAL \
             && defined (YYSTYPE_IS_TRIVIAL) && YYSTYPE_IS_TRIVIAL)))

/* A type that is properly aligned for any stack member.  */
union yyalloc
{
  short int yyss;
  YYSTYPE yyvs;
    YYLTYPE yyls;
};

/* The size of the maximum gap between one aligned stack and the next.  */
# define YYSTACK_GAP_MAXIMUM (sizeof (union yyalloc) - 1)

/* The size of an array large to enough to hold all stacks, each with
   N elements.  */
# define YYSTACK_BYTES(N) \
     ((N) * (sizeof (short int) + sizeof (YYSTYPE) + sizeof (YYLTYPE))	\
      + 2 * YYSTACK_GAP_MAXIMUM)

/* Copy COUNT objects from FROM to TO.  The source and destination do
   not overlap.  */
# ifndef YYCOPY
#  if defined (__GNUC__) && 1 < __GNUC__
#   define YYCOPY(To, From, Count) \
      __builtin_memcpy (To, From, (Count) * sizeof (*(From)))
#  else
#   define YYCOPY(To, From, Count)		\
      do					\
	{					\
	  YYSIZE_T yyi;				\
	  for (yyi = 0; yyi < (Count); yyi++)	\
	    (To)[yyi] = (From)[yyi];		\
	}					\
      while (0)
#  endif
# endif

/* Relocate STACK from its old location to the new one.  The
   local variables YYSIZE and YYSTACKSIZE give the old and new number of
   elements in the stack, and YYPTR gives the new location of the
   stack.  Advance YYPTR to a properly aligned location for the next
   stack.  */
# define YYSTACK_RELOCATE(Stack)					\
    do									\
      {									\
	YYSIZE_T yynewbytes;						\
	YYCOPY (&yyptr->Stack, Stack, yysize);				\
	Stack = &yyptr->Stack;						\
	yynewbytes = yystacksize * sizeof (*Stack) + YYSTACK_GAP_MAXIMUM; \
	yyptr += yynewbytes / sizeof (*yyptr);				\
      }									\
    while (0)

#endif

#if defined (__STDC__) || defined (__cplusplus)
   typedef signed char yysigned_char;
#else
   typedef short int yysigned_char;
#endif

/* YYFINAL -- State number of the termination state. */
#define YYFINAL  2
/* YYLAST -- Last index in YYTABLE.  */
#define YYLAST   742

/* YYNTOKENS -- Number of terminals. */
#define YYNTOKENS  60
/* YYNNTS -- Number of nonterminals. */
#define YYNNTS  11
/* YYNRULES -- Number of rules. */
#define YYNRULES  65
/* YYNRULES -- Number of states. */
#define YYNSTATES  159

/* YYTRANSLATE(YYLEX) -- Bison symbol number corresponding to YYLEX.  */
#define YYUNDEFTOK  2
#define YYMAXUTOK   314

#define YYTRANSLATE(YYX)						\
  ((unsigned int) (YYX) <= YYMAXUTOK ? yytranslate[YYX] : YYUNDEFTOK)

/* YYTRANSLATE[YYLEX] -- Bison symbol number corresponding to YYLEX.  */
static const unsigned char yytranslate[] =
{
       0,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     1,     2,     3,     4,
       5,     6,     7,     8,     9,    10,    11,    12,    13,    14,
      15,    16,    17,    18,    19,    20,    21,    22,    23,    24,
      25,    26,    27,    28,    29,    30,    31,    32,    33,    34,
      35,    36,    37,    38,    39,    40,    41,    42,    43,    44,
      45,    46,    47,    48,    49,    50,    51,    52,    53,    54,
      55,    56,    57,    58,    59
};

#if YYDEBUG
/* YYPRHS[YYN] -- Index of the first RHS symbol of rule number YYN in
   YYRHS.  */
static const unsigned short int yyprhs[] =
{
       0,     0,     3,     4,     7,    15,    23,    27,    33,    34,
      36,    39,    45,    52,    58,    64,    67,    75,    81,    87,
      93,   101,   109,   115,   121,   127,   133,   141,   143,   147,
     149,   152,   153,   155,   159,   160,   164,   168,   172,   176,
     180,   184,   188,   192,   196,   200,   204,   208,   212,   216,
     220,   224,   228,   232,   236,   240,   243,   245,   247,   249,
     251,   253,   255,   257,   259,   261
};

/* YYRHS -- A `-1'-separated list of the rules' RHS. */
static const yysigned_char yyrhs[] =
{
      61,     0,    -1,    -1,    61,    62,    -1,    26,    19,    63,
      20,    21,    64,    22,    -1,    26,    19,    63,    20,    21,
      68,    22,    -1,    26,    39,    53,    -1,    63,    27,    26,
      39,    53,    -1,    -1,    65,    -1,    64,    65,    -1,    25,
      39,    21,    68,    22,    -1,    25,    39,    17,    21,    68,
      22,    -1,    26,    19,    69,    20,    38,    -1,    32,    19,
      25,    20,    33,    -1,    13,    38,    -1,    28,    19,    70,
      27,    26,    20,    38,    -1,    28,    19,    70,    20,    38,
      -1,    29,    19,    26,    20,    38,    -1,    29,    19,    70,
      20,    38,    -1,    30,    19,    70,    27,    70,    20,    38,
      -1,    31,    19,    70,    27,    70,    20,    38,    -1,     8,
      19,    70,    20,    38,    -1,     9,    19,    70,    20,    38,
      -1,    10,    19,    70,    20,    38,    -1,    46,    19,    70,
      20,    67,    -1,    46,    19,    70,    20,    67,    47,    67,
      -1,    66,    -1,    21,    68,    22,    -1,    66,    -1,    68,
      66,    -1,    -1,    70,    -1,    69,    27,    70,    -1,    -1,
      19,    70,    20,    -1,    70,    48,    70,    -1,    70,     6,
      70,    -1,    70,    49,    70,    -1,    70,     7,    70,    -1,
      70,    55,    70,    -1,    70,    57,    70,    -1,    70,    56,
      70,    -1,    70,    59,    70,    -1,    70,    58,    70,    -1,
      70,     5,    70,    -1,    70,     3,    70,    -1,    70,     4,
      70,    -1,    70,    41,    70,    -1,    70,    43,    70,    -1,
      70,    42,    70,    -1,    70,    40,    70,    -1,    70,    45,
      70,    -1,    70,    44,    70,    -1,    23,    70,    24,    -1,
      54,    70,    -1,    25,    -1,    36,    -1,    34,    -1,    37,
      -1,    52,    -1,    13,    -1,    26,    -1,    16,    -1,    51,
      -1,    50,    -1
};

/* YYRLINE[YYN] -- source line where rule number YYN was defined.  */
static const unsigned short int yyrline[] =
{
       0,   125,   125,   126,   130,   138,   157,   166,   174,   180,
     186,   191,   200,   212,   220,   228,   235,   248,   257,   266,
     276,   293,   310,   318,   326,   334,   343,   357,   363,   369,
     375,   381,   387,   393,   398,   407,   409,   427,   444,   461,
     478,   495,   513,   531,   549,   567,   585,   602,   619,   627,
     635,   643,   651,   659,   668,   676,   684,   692,   700,   708,
     715,   722,   730,   737,   744,   751
};
#endif

#if YYDEBUG || YYERROR_VERBOSE || YYTOKEN_TABLE
/* YYTNAME[SYMBOL-NUM] -- String name of the symbol SYMBOL-NUM.
   First, the terminals, then, starting at YYNTOKENS, nonterminals. */
static const char *const yytname[] =
{
  "$end", "error", "$undefined", "SHL", "SHR", "MODULO", "OR", "AND",
  "WRITE8", "WRITE16", "WRITE32", "LABELLOCK", "LABELFREE", "LABEL",
  "TAILLE_CODE", "TAILLE_DECRYPTEUR", "IDEXT", "REGLE_DEFAUT",
  "SAUT_LIGNE", "PARENTHESE_OUVRANTE", "PARENTHESE_FERMANTE",
  "ACCOLADE_OUVRANTE", "ACCOLADE_FERMANTE", "CROCHET_OUVRANT",
  "CROCHET_FERMANT", "NOMBRE", "ID", "VIRGULE", "LOCK", "FREE", "INITMEM",
  "CHANGEMEM", "RAW", "ASM", "RNDMEM", "RNDMEMI", "RNDINT", "RNDREG",
  "FIN_OPCODE", "DEUXPOINTS", "SUP", "EGAL", "INF", "PASEGAL", "INFOUEGAL",
  "SUPOUEGAL", "IF", "ELSE", "BOR", "BAND", "REGISTRE", "UREGISTRE",
  "URNDREG", "ATYPE", "NOT", "XOR", "MOINS", "PLUS", "DIV", "MULT",
  "$accept", "INPUT", "TRANSFORMATION", "SUITE_PARAMETRE", "SUITE_REGLE",
  "REGLE", "OPCODE", "BLOC_OPCODE", "SUITE_OPCODE", "SUITE_EXP", "EXP", 0
};
#endif

# ifdef YYPRINT
/* YYTOKNUM[YYLEX-NUM] -- Internal token number corresponding to
   token YYLEX-NUM.  */
static const unsigned short int yytoknum[] =
{
       0,   256,   257,   258,   259,   260,   261,   262,   263,   264,
     265,   266,   267,   268,   269,   270,   271,   272,   273,   274,
     275,   276,   277,   278,   279,   280,   281,   282,   283,   284,
     285,   286,   287,   288,   289,   290,   291,   292,   293,   294,
     295,   296,   297,   298,   299,   300,   301,   302,   303,   304,
     305,   306,   307,   308,   309,   310,   311,   312,   313,   314
};
# endif

/* YYR1[YYN] -- Symbol number of symbol that rule YYN derives.  */
static const unsigned char yyr1[] =
{
       0,    60,    61,    61,    62,    62,    63,    63,    63,    64,
      64,    65,    65,    66,    66,    66,    66,    66,    66,    66,
      66,    66,    66,    66,    66,    66,    66,    67,    67,    68,
      68,    68,    69,    69,    69,    70,    70,    70,    70,    70,
      70,    70,    70,    70,    70,    70,    70,    70,    70,    70,
      70,    70,    70,    70,    70,    70,    70,    70,    70,    70,
      70,    70,    70,    70,    70,    70
};

/* YYR2[YYN] -- Number of symbols composing right hand side of rule YYN.  */
static const unsigned char yyr2[] =
{
       0,     2,     0,     2,     7,     7,     3,     5,     0,     1,
       2,     5,     6,     5,     5,     2,     7,     5,     5,     5,
       7,     7,     5,     5,     5,     5,     7,     1,     3,     1,
       2,     0,     1,     3,     0,     3,     3,     3,     3,     3,
       3,     3,     3,     3,     3,     3,     3,     3,     3,     3,
       3,     3,     3,     3,     3,     2,     1,     1,     1,     1,
       1,     1,     1,     1,     1,     1
};

/* YYDEFACT[STATE-NAME] -- Default rule to reduce with in state
   STATE-NUM when YYTABLE doesn't specify something else to do.  Zero
   means the default is an error.  */
static const unsigned char yydefact[] =
{
       2,     0,     1,     0,     3,     8,     0,     0,     0,     0,
       0,     6,    31,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     9,    29,     0,
       0,     0,     0,     0,    15,     0,    34,     0,     0,     0,
       0,     0,     0,     4,    10,     5,    30,     7,    61,    63,
       0,     0,    56,    62,    58,    57,    59,    65,    64,    60,
       0,     0,     0,     0,     0,    31,     0,    32,     0,    62,
       0,     0,     0,     0,     0,     0,     0,    55,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,    31,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,    35,    54,    46,    47,    45,    37,    39,    22,    51,
      48,    50,    49,    53,    52,    36,    38,    40,    42,    41,
      44,    43,    23,    24,     0,    11,    13,    33,    17,     0,
      18,    19,     0,     0,    14,    31,    27,    25,    12,     0,
       0,     0,     0,     0,    16,    20,    21,    28,    26
};

/* YYDEFGOTO[NTERM-NUM]. */
static const short int yydefgoto[] =
{
      -1,     1,     4,     7,    26,    27,    28,   147,    29,    66,
      61
};

/* YYPACT[STATE-NUM] -- Index in YYTABLE of the portion describing
   STATE-NUM.  */
#define YYPACT_NINF -64
static const short int yypact[] =
{
     -64,     1,   -64,   -16,   -64,   -19,   -24,   -14,   -32,     5,
      11,   -64,   563,   -10,    19,    20,    21,    -8,     2,    36,
      50,    51,    56,    57,    58,    59,     3,   -64,   -64,   588,
      34,   528,   528,   528,   -64,    -1,   528,   528,   533,   528,
     528,    74,   528,   -64,   -64,   -64,   -64,   -64,   -64,   -64,
     528,   528,   -64,   -64,   -64,   -64,   -64,   -64,   -64,   -64,
     528,   112,   143,   169,    62,   696,     4,   434,    86,    84,
     200,   226,   273,    87,   299,   330,   356,   481,   528,   528,
     528,   528,   528,    70,   528,   528,   528,   528,   528,   528,
     528,   528,   528,   528,   528,   528,   528,    71,    72,   696,
     613,    73,   528,    76,    94,    83,    95,   528,   528,    79,
     639,   -64,   -64,    30,    30,   434,    81,    44,   -64,    39,
      39,    39,    39,    39,    39,   460,   481,   231,    14,    14,
      30,    30,   -64,   -64,   664,   -64,   -64,   434,   -64,   102,
     -64,   -64,   387,   413,   -64,   696,   -64,    78,   -64,   113,
     120,   121,   689,   639,   -64,   -64,   -64,   -64,   -64
};

/* YYPGOTO[NTERM-NUM].  */
static const short int yypgoto[] =
{
     -64,   -64,   -64,   -64,   -64,   136,   -29,    12,   -63,   -64,
     -28
};

/* YYTABLE[YYPACT[STATE-NUM]].  What to do in state STATE-NUM.  If
   positive, shift that token.  If negative, reduce the rule which
   number is the opposite.  If zero, do what YYDEFACT says.
   If YYTABLE_NINF, syntax error.  */
#define YYTABLE_NINF -1
static const unsigned char yytable[] =
{
      46,     2,   100,     5,    62,    63,     9,     6,    67,    68,
      70,    71,    72,    10,    74,     8,    64,    78,    79,    80,
      65,    11,    75,    76,   101,    43,    12,     3,    18,    30,
      34,   102,    77,    78,    79,    80,   134,    13,    31,    32,
      33,    35,    78,    79,    80,    81,    82,    78,    79,    80,
     113,   114,   115,   116,   117,    36,   119,   120,   121,   122,
     123,   124,   125,   126,   127,   128,   129,   130,   131,    37,
      38,    46,    95,    96,   137,    39,    40,    41,    42,   142,
     143,   146,   152,    99,    78,    79,    80,    47,    82,    78,
      79,    80,    81,    82,    92,    93,    94,    95,    96,    73,
      93,    94,    95,    96,   105,    46,   103,   109,   118,   132,
     133,   136,   144,   104,   138,    78,    79,    80,    81,    82,
     139,   140,   149,    46,   146,   153,    84,    85,    86,    87,
      88,    89,    83,   141,    90,    91,    92,    93,    94,    95,
      96,    92,    93,    94,    95,    96,    78,    79,    80,    81,
      82,   154,    84,    85,    86,    87,    88,    89,   155,   156,
      90,    91,    44,    97,     0,   158,     0,    92,    93,    94,
      95,    96,    78,    79,    80,    81,    82,     0,     0,     0,
       0,     0,     0,    84,    85,    86,    87,    88,    89,    98,
       0,    90,    91,     0,     0,     0,     0,     0,    92,    93,
      94,    95,    96,    78,    79,    80,    81,    82,     0,    84,
      85,    86,    87,    88,    89,     0,     0,    90,    91,     0,
     106,     0,     0,     0,    92,    93,    94,    95,    96,    78,
      79,    80,    81,    82,    78,    79,    80,     0,    82,     0,
      84,    85,    86,    87,    88,    89,     0,     0,    90,    91,
       0,     0,     0,   107,     0,    92,    93,    94,    95,    96,
       0,     0,     0,     0,     0,     0,    84,    85,    86,    87,
      88,    89,     0,     0,    90,    91,    78,    79,    80,    81,
      82,    92,    93,    94,    95,    96,     0,    93,    94,    95,
      96,     0,     0,     0,     0,     0,     0,     0,     0,     0,
     108,     0,    78,    79,    80,    81,    82,     0,     0,     0,
       0,     0,     0,    84,    85,    86,    87,    88,    89,   110,
       0,    90,    91,     0,     0,     0,     0,     0,    92,    93,
      94,    95,    96,    78,    79,    80,    81,    82,     0,    84,
      85,    86,    87,    88,    89,     0,     0,    90,    91,     0,
     111,     0,     0,     0,    92,    93,    94,    95,    96,    78,
      79,    80,    81,    82,     0,     0,     0,     0,     0,     0,
      84,    85,    86,    87,    88,    89,     0,     0,    90,    91,
     112,     0,     0,     0,     0,    92,    93,    94,    95,    96,
      78,    79,    80,    81,    82,     0,    84,    85,    86,    87,
      88,    89,     0,     0,    90,    91,     0,   150,     0,     0,
       0,    92,    93,    94,    95,    96,    78,    79,    80,    81,
      82,     0,     0,     0,     0,     0,     0,    84,    85,    86,
      87,    88,    89,   151,     0,    90,    91,    78,    79,    80,
      81,    82,    92,    93,    94,    95,    96,     0,     0,     0,
       0,     0,     0,    84,    85,    86,    87,    88,    89,     0,
       0,    90,    91,    78,    79,    80,    81,    82,    92,    93,
      94,    95,    96,     0,    84,    85,    86,    87,    88,    89,
       0,     0,    90,    91,    78,    79,    80,    81,    82,    92,
      93,    94,    95,    96,     0,     0,     0,     0,     0,     0,
      84,    85,    86,    87,    88,    89,     0,     0,     0,    91,
       0,     0,     0,     0,     0,    92,    93,    94,    95,    96,
       0,    84,    85,    86,    87,    88,    89,     0,     0,     0,
       0,     0,     0,     0,     0,     0,    92,    93,    94,    95,
      96,    48,     0,     0,    49,     0,    48,    50,     0,    49,
       0,    51,    50,    52,    53,     0,    51,     0,    52,    69,
       0,     0,    54,     0,    55,    56,     0,    54,     0,    55,
      56,    14,    15,    16,     0,     0,    17,     0,    57,    58,
      59,     0,    60,    57,    58,    59,     0,    60,    18,    19,
       0,    20,    21,    22,    23,    24,    14,    15,    16,     0,
       0,    17,     0,     0,     0,     0,     0,     0,     0,    25,
      45,     0,     0,     0,    19,     0,    20,    21,    22,    23,
      24,    14,    15,    16,     0,     0,    17,     0,     0,     0,
       0,     0,     0,     0,    25,   135,     0,     0,     0,    19,
       0,    20,    21,    22,    23,    24,     0,    14,    15,    16,
       0,     0,    17,     0,     0,     0,     0,     0,     0,    25,
     145,     0,     0,     0,     0,    19,     0,    20,    21,    22,
      23,    24,    14,    15,    16,     0,     0,    17,     0,     0,
       0,     0,     0,     0,     0,    25,   148,     0,     0,     0,
      19,     0,    20,    21,    22,    23,    24,    14,    15,    16,
       0,     0,    17,     0,    14,    15,    16,     0,     0,    17,
      25,   157,     0,     0,     0,    19,     0,    20,    21,    22,
      23,    24,    19,     0,    20,    21,    22,    23,    24,     0,
       0,     0,     0,     0,     0,    25,     0,     0,     0,     0,
       0,     0,    25
};

static const short int yycheck[] =
{
      29,     0,    65,    19,    32,    33,    20,    26,    36,    37,
      38,    39,    40,    27,    42,    39,    17,     3,     4,     5,
      21,    53,    50,    51,    20,    22,    21,    26,    25,    39,
      38,    27,    60,     3,     4,     5,    99,    26,    19,    19,
      19,    39,     3,     4,     5,     6,     7,     3,     4,     5,
      78,    79,    80,    81,    82,    19,    84,    85,    86,    87,
      88,    89,    90,    91,    92,    93,    94,    95,    96,    19,
      19,   100,    58,    59,   102,    19,    19,    19,    19,   107,
     108,   110,   145,    21,     3,     4,     5,    53,     7,     3,
       4,     5,     6,     7,    55,    56,    57,    58,    59,    25,
      56,    57,    58,    59,    20,   134,    20,    20,    38,    38,
      38,    38,    33,    27,    38,     3,     4,     5,     6,     7,
      26,    38,    20,   152,   153,    47,    40,    41,    42,    43,
      44,    45,    20,    38,    48,    49,    55,    56,    57,    58,
      59,    55,    56,    57,    58,    59,     3,     4,     5,     6,
       7,    38,    40,    41,    42,    43,    44,    45,    38,    38,
      48,    49,    26,    20,    -1,   153,    -1,    55,    56,    57,
      58,    59,     3,     4,     5,     6,     7,    -1,    -1,    -1,
      -1,    -1,    -1,    40,    41,    42,    43,    44,    45,    20,
      -1,    48,    49,    -1,    -1,    -1,    -1,    -1,    55,    56,
      57,    58,    59,     3,     4,     5,     6,     7,    -1,    40,
      41,    42,    43,    44,    45,    -1,    -1,    48,    49,    -1,
      20,    -1,    -1,    -1,    55,    56,    57,    58,    59,     3,
       4,     5,     6,     7,     3,     4,     5,    -1,     7,    -1,
      40,    41,    42,    43,    44,    45,    -1,    -1,    48,    49,
      -1,    -1,    -1,    27,    -1,    55,    56,    57,    58,    59,
      -1,    -1,    -1,    -1,    -1,    -1,    40,    41,    42,    43,
      44,    45,    -1,    -1,    48,    49,     3,     4,     5,     6,
       7,    55,    56,    57,    58,    59,    -1,    56,    57,    58,
      59,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      27,    -1,     3,     4,     5,     6,     7,    -1,    -1,    -1,
      -1,    -1,    -1,    40,    41,    42,    43,    44,    45,    20,
      -1,    48,    49,    -1,    -1,    -1,    -1,    -1,    55,    56,
      57,    58,    59,     3,     4,     5,     6,     7,    -1,    40,
      41,    42,    43,    44,    45,    -1,    -1,    48,    49,    -1,
      20,    -1,    -1,    -1,    55,    56,    57,    58,    59,     3,
       4,     5,     6,     7,    -1,    -1,    -1,    -1,    -1,    -1,
      40,    41,    42,    43,    44,    45,    -1,    -1,    48,    49,
      24,    -1,    -1,    -1,    -1,    55,    56,    57,    58,    59,
       3,     4,     5,     6,     7,    -1,    40,    41,    42,    43,
      44,    45,    -1,    -1,    48,    49,    -1,    20,    -1,    -1,
      -1,    55,    56,    57,    58,    59,     3,     4,     5,     6,
       7,    -1,    -1,    -1,    -1,    -1,    -1,    40,    41,    42,
      43,    44,    45,    20,    -1,    48,    49,     3,     4,     5,
       6,     7,    55,    56,    57,    58,    59,    -1,    -1,    -1,
      -1,    -1,    -1,    40,    41,    42,    43,    44,    45,    -1,
      -1,    48,    49,     3,     4,     5,     6,     7,    55,    56,
      57,    58,    59,    -1,    40,    41,    42,    43,    44,    45,
      -1,    -1,    48,    49,     3,     4,     5,     6,     7,    55,
      56,    57,    58,    59,    -1,    -1,    -1,    -1,    -1,    -1,
      40,    41,    42,    43,    44,    45,    -1,    -1,    -1,    49,
      -1,    -1,    -1,    -1,    -1,    55,    56,    57,    58,    59,
      -1,    40,    41,    42,    43,    44,    45,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    55,    56,    57,    58,
      59,    13,    -1,    -1,    16,    -1,    13,    19,    -1,    16,
      -1,    23,    19,    25,    26,    -1,    23,    -1,    25,    26,
      -1,    -1,    34,    -1,    36,    37,    -1,    34,    -1,    36,
      37,     8,     9,    10,    -1,    -1,    13,    -1,    50,    51,
      52,    -1,    54,    50,    51,    52,    -1,    54,    25,    26,
      -1,    28,    29,    30,    31,    32,     8,     9,    10,    -1,
      -1,    13,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    46,
      22,    -1,    -1,    -1,    26,    -1,    28,    29,    30,    31,
      32,     8,     9,    10,    -1,    -1,    13,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    46,    22,    -1,    -1,    -1,    26,
      -1,    28,    29,    30,    31,    32,    -1,     8,     9,    10,
      -1,    -1,    13,    -1,    -1,    -1,    -1,    -1,    -1,    46,
      21,    -1,    -1,    -1,    -1,    26,    -1,    28,    29,    30,
      31,    32,     8,     9,    10,    -1,    -1,    13,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    46,    22,    -1,    -1,    -1,
      26,    -1,    28,    29,    30,    31,    32,     8,     9,    10,
      -1,    -1,    13,    -1,     8,     9,    10,    -1,    -1,    13,
      46,    22,    -1,    -1,    -1,    26,    -1,    28,    29,    30,
      31,    32,    26,    -1,    28,    29,    30,    31,    32,    -1,
      -1,    -1,    -1,    -1,    -1,    46,    -1,    -1,    -1,    -1,
      -1,    -1,    46
};

/* YYSTOS[STATE-NUM] -- The (internal number of the) accessing
   symbol of state STATE-NUM.  */
static const unsigned char yystos[] =
{
       0,    61,     0,    26,    62,    19,    26,    63,    39,    20,
      27,    53,    21,    26,     8,     9,    10,    13,    25,    26,
      28,    29,    30,    31,    32,    46,    64,    65,    66,    68,
      39,    19,    19,    19,    38,    39,    19,    19,    19,    19,
      19,    19,    19,    22,    65,    22,    66,    53,    13,    16,
      19,    23,    25,    26,    34,    36,    37,    50,    51,    52,
      54,    70,    70,    70,    17,    21,    69,    70,    70,    26,
      70,    70,    70,    25,    70,    70,    70,    70,     3,     4,
       5,     6,     7,    20,    40,    41,    42,    43,    44,    45,
      48,    49,    55,    56,    57,    58,    59,    20,    20,    21,
      68,    20,    27,    20,    27,    20,    20,    27,    27,    20,
      20,    20,    24,    70,    70,    70,    70,    70,    38,    70,
      70,    70,    70,    70,    70,    70,    70,    70,    70,    70,
      70,    70,    38,    38,    68,    22,    38,    70,    38,    26,
      38,    38,    70,    70,    33,    21,    66,    67,    22,    20,
      20,    20,    68,    47,    38,    38,    38,    22,    67
};

#define yyerrok		(yyerrstatus = 0)
#define yyclearin	(yychar = YYEMPTY)
#define YYEMPTY		(-2)
#define YYEOF		0

#define YYACCEPT	goto yyacceptlab
#define YYABORT		goto yyabortlab
#define YYERROR		goto yyerrorlab


/* Like YYERROR except do call yyerror.  This remains here temporarily
   to ease the transition to the new meaning of YYERROR, for GCC.
   Once GCC version 2 has supplanted version 1, this can go.  */

#define YYFAIL		goto yyerrlab

#define YYRECOVERING()  (!!yyerrstatus)

#define YYBACKUP(Token, Value)					\
do								\
  if (yychar == YYEMPTY && yylen == 1)				\
    {								\
      yychar = (Token);						\
      yylval = (Value);						\
      yytoken = YYTRANSLATE (yychar);				\
      YYPOPSTACK;						\
      goto yybackup;						\
    }								\
  else								\
    {								\
      yyerror (YY_("syntax error: cannot back up")); \
      YYERROR;							\
    }								\
while (0)


#define YYTERROR	1
#define YYERRCODE	256


/* YYLLOC_DEFAULT -- Set CURRENT to span from RHS[1] to RHS[N].
   If N is 0, then set CURRENT to the empty location which ends
   the previous symbol: RHS[0] (always defined).  */

#define YYRHSLOC(Rhs, K) ((Rhs)[K])
#ifndef YYLLOC_DEFAULT
# define YYLLOC_DEFAULT(Current, Rhs, N)				\
    do									\
      if (N)								\
	{								\
	  (Current).first_line   = YYRHSLOC (Rhs, 1).first_line;	\
	  (Current).first_column = YYRHSLOC (Rhs, 1).first_column;	\
	  (Current).last_line    = YYRHSLOC (Rhs, N).last_line;		\
	  (Current).last_column  = YYRHSLOC (Rhs, N).last_column;	\
	}								\
      else								\
	{								\
	  (Current).first_line   = (Current).last_line   =		\
	    YYRHSLOC (Rhs, 0).last_line;				\
	  (Current).first_column = (Current).last_column =		\
	    YYRHSLOC (Rhs, 0).last_column;				\
	}								\
    while (0)
#endif


/* YY_LOCATION_PRINT -- Print the location on the stream.
   This macro was not mandated originally: define only if we know
   we won't break user code: when these are the locations we know.  */

#ifndef YY_LOCATION_PRINT
# if YYLTYPE_IS_TRIVIAL
#  define YY_LOCATION_PRINT(File, Loc)			\
     fprintf (File, "%d.%d-%d.%d",			\
              (Loc).first_line, (Loc).first_column,	\
              (Loc).last_line,  (Loc).last_column)
# else
#  define YY_LOCATION_PRINT(File, Loc) ((void) 0)
# endif
#endif


/* YYLEX -- calling `yylex' with the right arguments.  */

#ifdef YYLEX_PARAM
# define YYLEX yylex (YYLEX_PARAM)
#else
# define YYLEX yylex ()
#endif

/* Enable debugging if requested.  */
#if YYDEBUG

# ifndef YYFPRINTF
#  include <stdio.h> /* INFRINGES ON USER NAME SPACE */
#  define YYFPRINTF fprintf
# endif

# define YYDPRINTF(Args)			\
do {						\
  if (yydebug)					\
    YYFPRINTF Args;				\
} while (0)

# define YY_SYMBOL_PRINT(Title, Type, Value, Location)		\
do {								\
  if (yydebug)							\
    {								\
      YYFPRINTF (stderr, "%s ", Title);				\
      yysymprint (stderr,					\
                  Type, Value, Location);	\
      YYFPRINTF (stderr, "\n");					\
    }								\
} while (0)

/*------------------------------------------------------------------.
| yy_stack_print -- Print the state stack from its BOTTOM up to its |
| TOP (included).                                                   |
`------------------------------------------------------------------*/

#if defined (__STDC__) || defined (__cplusplus)
static void
yy_stack_print (short int *bottom, short int *top)
#else
static void
yy_stack_print (bottom, top)
    short int *bottom;
    short int *top;
#endif
{
  YYFPRINTF (stderr, "Stack now");
  for (/* Nothing. */; bottom <= top; ++bottom)
    YYFPRINTF (stderr, " %d", *bottom);
  YYFPRINTF (stderr, "\n");
}

# define YY_STACK_PRINT(Bottom, Top)				\
do {								\
  if (yydebug)							\
    yy_stack_print ((Bottom), (Top));				\
} while (0)


/*------------------------------------------------.
| Report that the YYRULE is going to be reduced.  |
`------------------------------------------------*/

#if defined (__STDC__) || defined (__cplusplus)
static void
yy_reduce_print (int yyrule)
#else
static void
yy_reduce_print (yyrule)
    int yyrule;
#endif
{
  int yyi;
  unsigned long int yylno = yyrline[yyrule];
  YYFPRINTF (stderr, "Reducing stack by rule %d (line %lu), ",
             yyrule - 1, yylno);
  /* Print the symbols being reduced, and their result.  */
  for (yyi = yyprhs[yyrule]; 0 <= yyrhs[yyi]; yyi++)
    YYFPRINTF (stderr, "%s ", yytname[yyrhs[yyi]]);
  YYFPRINTF (stderr, "-> %s\n", yytname[yyr1[yyrule]]);
}

# define YY_REDUCE_PRINT(Rule)		\
do {					\
  if (yydebug)				\
    yy_reduce_print (Rule);		\
} while (0)

/* Nonzero means print parse trace.  It is left uninitialized so that
   multiple parsers can coexist.  */
int yydebug;
#else /* !YYDEBUG */
# define YYDPRINTF(Args)
# define YY_SYMBOL_PRINT(Title, Type, Value, Location)
# define YY_STACK_PRINT(Bottom, Top)
# define YY_REDUCE_PRINT(Rule)
#endif /* !YYDEBUG */


/* YYINITDEPTH -- initial size of the parser's stacks.  */
#ifndef	YYINITDEPTH
# define YYINITDEPTH 200
#endif

/* YYMAXDEPTH -- maximum size the stacks can grow to (effective only
   if the built-in stack extension method is used).

   Do not make this value too large; the results are undefined if
   YYSTACK_ALLOC_MAXIMUM < YYSTACK_BYTES (YYMAXDEPTH)
   evaluated with infinite-precision integer arithmetic.  */

#ifndef YYMAXDEPTH
# define YYMAXDEPTH 10000
#endif



#if YYERROR_VERBOSE

# ifndef yystrlen
#  if defined (__GLIBC__) && defined (_STRING_H)
#   define yystrlen strlen
#  else
/* Return the length of YYSTR.  */
static YYSIZE_T
#   if defined (__STDC__) || defined (__cplusplus)
yystrlen (const char *yystr)
#   else
yystrlen (yystr)
     const char *yystr;
#   endif
{
  const char *yys = yystr;

  while (*yys++ != '\0')
    continue;

  return yys - yystr - 1;
}
#  endif
# endif

# ifndef yystpcpy
#  if defined (__GLIBC__) && defined (_STRING_H) && defined (_GNU_SOURCE)
#   define yystpcpy stpcpy
#  else
/* Copy YYSRC to YYDEST, returning the address of the terminating '\0' in
   YYDEST.  */
static char *
#   if defined (__STDC__) || defined (__cplusplus)
yystpcpy (char *yydest, const char *yysrc)
#   else
yystpcpy (yydest, yysrc)
     char *yydest;
     const char *yysrc;
#   endif
{
  char *yyd = yydest;
  const char *yys = yysrc;

  while ((*yyd++ = *yys++) != '\0')
    continue;

  return yyd - 1;
}
#  endif
# endif

# ifndef yytnamerr
/* Copy to YYRES the contents of YYSTR after stripping away unnecessary
   quotes and backslashes, so that it's suitable for yyerror.  The
   heuristic is that double-quoting is unnecessary unless the string
   contains an apostrophe, a comma, or backslash (other than
   backslash-backslash).  YYSTR is taken from yytname.  If YYRES is
   null, do not copy; instead, return the length of what the result
   would have been.  */
static YYSIZE_T
yytnamerr (char *yyres, const char *yystr)
{
  if (*yystr == '"')
    {
      size_t yyn = 0;
      char const *yyp = yystr;

      for (;;)
	switch (*++yyp)
	  {
	  case '\'':
	  case ',':
	    goto do_not_strip_quotes;

	  case '\\':
	    if (*++yyp != '\\')
	      goto do_not_strip_quotes;
	    /* Fall through.  */
	  default:
	    if (yyres)
	      yyres[yyn] = *yyp;
	    yyn++;
	    break;

	  case '"':
	    if (yyres)
	      yyres[yyn] = '\0';
	    return yyn;
	  }
    do_not_strip_quotes: ;
    }

  if (! yyres)
    return yystrlen (yystr);

  return yystpcpy (yyres, yystr) - yyres;
}
# endif

#endif /* YYERROR_VERBOSE */



#if YYDEBUG
/*--------------------------------.
| Print this symbol on YYOUTPUT.  |
`--------------------------------*/

#if defined (__STDC__) || defined (__cplusplus)
static void
yysymprint (FILE *yyoutput, int yytype, YYSTYPE *yyvaluep, YYLTYPE *yylocationp)
#else
static void
yysymprint (yyoutput, yytype, yyvaluep, yylocationp)
    FILE *yyoutput;
    int yytype;
    YYSTYPE *yyvaluep;
    YYLTYPE *yylocationp;
#endif
{
  /* Pacify ``unused variable'' warnings.  */
  (void) yyvaluep;
  (void) yylocationp;

  if (yytype < YYNTOKENS)
    YYFPRINTF (yyoutput, "token %s (", yytname[yytype]);
  else
    YYFPRINTF (yyoutput, "nterm %s (", yytname[yytype]);

  YY_LOCATION_PRINT (yyoutput, *yylocationp);
  YYFPRINTF (yyoutput, ": ");

# ifdef YYPRINT
  if (yytype < YYNTOKENS)
    YYPRINT (yyoutput, yytoknum[yytype], *yyvaluep);
# endif
  switch (yytype)
    {
      default:
        break;
    }
  YYFPRINTF (yyoutput, ")");
}

#endif /* ! YYDEBUG */
/*-----------------------------------------------.
| Release the memory associated to this symbol.  |
`-----------------------------------------------*/

#if defined (__STDC__) || defined (__cplusplus)
static void
yydestruct (const char *yymsg, int yytype, YYSTYPE *yyvaluep, YYLTYPE *yylocationp)
#else
static void
yydestruct (yymsg, yytype, yyvaluep, yylocationp)
    const char *yymsg;
    int yytype;
    YYSTYPE *yyvaluep;
    YYLTYPE *yylocationp;
#endif
{
  /* Pacify ``unused variable'' warnings.  */
  (void) yyvaluep;
  (void) yylocationp;

  if (!yymsg)
    yymsg = "Deleting";
  YY_SYMBOL_PRINT (yymsg, yytype, yyvaluep, yylocationp);

  switch (yytype)
    {

      default:
        break;
    }
}


/* Prevent warnings from -Wmissing-prototypes.  */

#ifdef YYPARSE_PARAM
# if defined (__STDC__) || defined (__cplusplus)
int yyparse (void *YYPARSE_PARAM);
# else
int yyparse ();
# endif
#else /* ! YYPARSE_PARAM */
#if defined (__STDC__) || defined (__cplusplus)
int yyparse (void);
#else
int yyparse ();
#endif
#endif /* ! YYPARSE_PARAM */



/* The look-ahead symbol.  */
int yychar;

/* The semantic value of the look-ahead symbol.  */
YYSTYPE yylval;

/* Number of syntax errors so far.  */
int yynerrs;
/* Location data for the look-ahead symbol.  */
YYLTYPE yylloc;



/*----------.
| yyparse.  |
`----------*/

#ifdef YYPARSE_PARAM
# if defined (__STDC__) || defined (__cplusplus)
int yyparse (void *YYPARSE_PARAM)
# else
int yyparse (YYPARSE_PARAM)
  void *YYPARSE_PARAM;
# endif
#else /* ! YYPARSE_PARAM */
#if defined (__STDC__) || defined (__cplusplus)
int
yyparse (void)
#else
int
yyparse ()
    ;
#endif
#endif
{
  
  int yystate;
  int yyn;
  int yyresult;
  /* Number of tokens to shift before error messages enabled.  */
  int yyerrstatus;
  /* Look-ahead token as an internal (translated) token number.  */
  int yytoken = 0;

  /* Three stacks and their tools:
     `yyss': related to states,
     `yyvs': related to semantic values,
     `yyls': related to locations.

     Refer to the stacks thru separate pointers, to allow yyoverflow
     to reallocate them elsewhere.  */

  /* The state stack.  */
  short int yyssa[YYINITDEPTH];
  short int *yyss = yyssa;
  short int *yyssp;

  /* The semantic value stack.  */
  YYSTYPE yyvsa[YYINITDEPTH];
  YYSTYPE *yyvs = yyvsa;
  YYSTYPE *yyvsp;

  /* The location stack.  */
  YYLTYPE yylsa[YYINITDEPTH];
  YYLTYPE *yyls = yylsa;
  YYLTYPE *yylsp;
  /* The locations where the error started and ended. */
  YYLTYPE yyerror_range[2];

#define YYPOPSTACK   (yyvsp--, yyssp--, yylsp--)

  YYSIZE_T yystacksize = YYINITDEPTH;

  /* The variables used to return semantic value and location from the
     action routines.  */
  YYSTYPE yyval;
  YYLTYPE yyloc;

  /* When reducing, the number of symbols on the RHS of the reduced
     rule.  */
  int yylen;

  YYDPRINTF ((stderr, "Starting parse\n"));

  yystate = 0;
  yyerrstatus = 0;
  yynerrs = 0;
  yychar = YYEMPTY;		/* Cause a token to be read.  */

  /* Initialize stack pointers.
     Waste one element of value and location stack
     so that they stay on the same level as the state stack.
     The wasted elements are never initialized.  */

  yyssp = yyss;
  yyvsp = yyvs;
  yylsp = yyls;
#if YYLTYPE_IS_TRIVIAL
  /* Initialize the default location before parsing starts.  */
  yylloc.first_line   = yylloc.last_line   = 1;
  yylloc.first_column = yylloc.last_column = 0;
#endif

  goto yysetstate;

/*------------------------------------------------------------.
| yynewstate -- Push a new state, which is found in yystate.  |
`------------------------------------------------------------*/
 yynewstate:
  /* In all cases, when you get here, the value and location stacks
     have just been pushed. so pushing a state here evens the stacks.
     */
  yyssp++;

 yysetstate:
  *yyssp = yystate;

  if (yyss + yystacksize - 1 <= yyssp)
    {
      /* Get the current used size of the three stacks, in elements.  */
      YYSIZE_T yysize = yyssp - yyss + 1;

#ifdef yyoverflow
      {
	/* Give user a chance to reallocate the stack. Use copies of
	   these so that the &'s don't force the real ones into
	   memory.  */
	YYSTYPE *yyvs1 = yyvs;
	short int *yyss1 = yyss;
	YYLTYPE *yyls1 = yyls;

	/* Each stack pointer address is followed by the size of the
	   data in use in that stack, in bytes.  This used to be a
	   conditional around just the two extra args, but that might
	   be undefined if yyoverflow is a macro.  */
	yyoverflow (YY_("memory exhausted"),
		    &yyss1, yysize * sizeof (*yyssp),
		    &yyvs1, yysize * sizeof (*yyvsp),
		    &yyls1, yysize * sizeof (*yylsp),
		    &yystacksize);
	yyls = yyls1;
	yyss = yyss1;
	yyvs = yyvs1;
      }
#else /* no yyoverflow */
# ifndef YYSTACK_RELOCATE
      goto yyexhaustedlab;
# else
      /* Extend the stack our own way.  */
      if (YYMAXDEPTH <= yystacksize)
	goto yyexhaustedlab;
      yystacksize *= 2;
      if (YYMAXDEPTH < yystacksize)
	yystacksize = YYMAXDEPTH;

      {
	short int *yyss1 = yyss;
	union yyalloc *yyptr =
	  (union yyalloc *) YYSTACK_ALLOC (YYSTACK_BYTES (yystacksize));
	if (! yyptr)
	  goto yyexhaustedlab;
	YYSTACK_RELOCATE (yyss);
	YYSTACK_RELOCATE (yyvs);
	YYSTACK_RELOCATE (yyls);
#  undef YYSTACK_RELOCATE
	if (yyss1 != yyssa)
	  YYSTACK_FREE (yyss1);
      }
# endif
#endif /* no yyoverflow */

      yyssp = yyss + yysize - 1;
      yyvsp = yyvs + yysize - 1;
      yylsp = yyls + yysize - 1;

      YYDPRINTF ((stderr, "Stack size increased to %lu\n",
		  (unsigned long int) yystacksize));

      if (yyss + yystacksize - 1 <= yyssp)
	YYABORT;
    }

  YYDPRINTF ((stderr, "Entering state %d\n", yystate));

  goto yybackup;

/*-----------.
| yybackup.  |
`-----------*/
yybackup:

/* Do appropriate processing given the current state.  */
/* Read a look-ahead token if we need one and don't already have one.  */
/* yyresume: */

  /* First try to decide what to do without reference to look-ahead token.  */

  yyn = yypact[yystate];
  if (yyn == YYPACT_NINF)
    goto yydefault;

  /* Not known => get a look-ahead token if don't already have one.  */

  /* YYCHAR is either YYEMPTY or YYEOF or a valid look-ahead symbol.  */
  if (yychar == YYEMPTY)
    {
      YYDPRINTF ((stderr, "Reading a token: "));
      yychar = YYLEX;
    }

  if (yychar <= YYEOF)
    {
      yychar = yytoken = YYEOF;
      YYDPRINTF ((stderr, "Now at end of input.\n"));
    }
  else
    {
      yytoken = YYTRANSLATE (yychar);
      YY_SYMBOL_PRINT ("Next token is", yytoken, &yylval, &yylloc);
    }

  /* If the proper action on seeing token YYTOKEN is to reduce or to
     detect an error, take that action.  */
  yyn += yytoken;
  if (yyn < 0 || YYLAST < yyn || yycheck[yyn] != yytoken)
    goto yydefault;
  yyn = yytable[yyn];
  if (yyn <= 0)
    {
      if (yyn == 0 || yyn == YYTABLE_NINF)
	goto yyerrlab;
      yyn = -yyn;
      goto yyreduce;
    }

  if (yyn == YYFINAL)
    YYACCEPT;

  /* Shift the look-ahead token.  */
  YY_SYMBOL_PRINT ("Shifting", yytoken, &yylval, &yylloc);

  /* Discard the token being shifted unless it is eof.  */
  if (yychar != YYEOF)
    yychar = YYEMPTY;

  *++yyvsp = yylval;
  *++yylsp = yylloc;

  /* Count tokens shifted since error; after three, turn off error
     status.  */
  if (yyerrstatus)
    yyerrstatus--;

  yystate = yyn;
  goto yynewstate;


/*-----------------------------------------------------------.
| yydefault -- do the default action for the current state.  |
`-----------------------------------------------------------*/
yydefault:
  yyn = yydefact[yystate];
  if (yyn == 0)
    goto yyerrlab;
  goto yyreduce;


/*-----------------------------.
| yyreduce -- Do a reduction.  |
`-----------------------------*/
yyreduce:
  /* yyn is the number of a rule to reduce with.  */
  yylen = yyr2[yyn];

  /* If YYLEN is nonzero, implement the default value of the action:
     `$$ = $1'.

     Otherwise, the following line sets YYVAL to garbage.
     This behavior is undocumented and Bison
     users should not rely upon it.  Assigning to YYVAL
     unconditionally makes the parser a bit smaller, and it avoids a
     GCC warning that YYVAL may be used uninitialized.  */
  yyval = yyvsp[1-yylen];

  /* Default location. */
  YYLLOC_DEFAULT (yyloc, yylsp - yylen, yylen);
  YY_REDUCE_PRINT (yyn);
  switch (yyn)
    {
        case 4:
#line 130 "kpasm.y"
    { 
   Transformation* t=(Transformation*)malloc(sizeof(Transformation));
   t->nom=(yyvsp[-6].chaine);
   t->arguments=(yyvsp[-4].liste);
   t->regles=(yyvsp[-1].liste);
   t->ligne=yylineno;
   ll_push_back(&transformations,t);
;}
    break;

  case 5:
#line 138 "kpasm.y"
    { 
  linkedlist l; 
  Transformation* t=(Transformation*)malloc(sizeof(Transformation));
  Regle* r=(Regle*)malloc(sizeof(Regle));
  r->proba=1;
  r->opcodes=(yyvsp[-1].liste);
  r->minimum_taille=-1;
  r->is_defaut=1;
  r->ligne=yylineno;
  ll_init(&l,sizeof(Regle));
  ll_push_back(&l,r);
  t->regles=l;
  t->nom=(yyvsp[-6].chaine);
  t->arguments=(yyvsp[-4].liste);
  t->ligne=yylineno;
  ll_push_back(&transformations,t);
 ;}
    break;

  case 6:
#line 157 "kpasm.y"
    {
  linkedlist l;
  Argument* arg=(Argument*)malloc(sizeof(Argument));
  arg->nom=(yyvsp[-2].chaine);
  arg->type=(yyvsp[0].entier);
  ll_init(&l,sizeof(Argument));
  ll_push_back(&l,arg);
  (yyval.liste)=l;
;}
    break;

  case 7:
#line 166 "kpasm.y"
    {
  Argument* arg=(Argument*)malloc(sizeof(Argument));
  arg->nom=(yyvsp[-2].chaine);
  arg->type=(yyvsp[0].entier);
  ll_push_back(&(yyvsp[-4].liste),arg);
  (yyval.liste)=(yyvsp[-4].liste);
;}
    break;

  case 8:
#line 174 "kpasm.y"
    {
  linkedlist l;
  ll_init(&l,sizeof(Argument));
  (yyval.liste)=l;
 ;}
    break;

  case 9:
#line 180 "kpasm.y"
    {
  linkedlist l;
  ll_init(&l,sizeof(Regle));
  ll_push_back(&l,(yyvsp[0].regle));
  (yyval.liste)=l;
;}
    break;

  case 10:
#line 186 "kpasm.y"
    {
  ll_push_back(&(yyvsp[-1].liste),(yyvsp[0].regle));
  (yyval.liste)=(yyvsp[-1].liste);
;}
    break;

  case 11:
#line 191 "kpasm.y"
    {
  Regle* r=(Regle*)malloc(sizeof(Regle));
  r->proba=(yyvsp[-4].entier);
  r->opcodes=(yyvsp[-1].liste);
  r->minimum_taille=-1;
  r->is_defaut=0;
  r->ligne=yylineno;
  (yyval.regle)=r;
;}
    break;

  case 12:
#line 200 "kpasm.y"
    {
   Regle* r=(Regle*)malloc(sizeof(Regle));
   r->proba=(yyvsp[-5].entier);
   r->opcodes=(yyvsp[-1].liste);
   r->is_defaut=1;
   r->ligne=yylineno;
   r->minimum_taille=-1;
   (yyval.regle)=r;
;}
    break;

  case 13:
#line 212 "kpasm.y"
    {
  Opcode* op=(Opcode*)malloc(sizeof(Opcode));
  op->letype=CALLOPCODE;
  op->operandes.opcall.nomtransfo=(char*)strdup((yyvsp[-4].chaine));
  op->operandes.opcall.arguments=(yyvsp[-2].liste);
  op->ligne=yylineno;
  (yyval.opcode)=op;  
;}
    break;

  case 14:
#line 220 "kpasm.y"
    {
  Opcode* op=(Opcode*)malloc(sizeof(Opcode));
  op->letype=ASMOPCODE;
  op->ligne=yylineno;
  op->operandes.opasm.asmtxt=(yyvsp[0].chaine);
  op->operandes.opasm.taille=(yyvsp[-2].entier);
  (yyval.opcode)=op;
;}
    break;

  case 15:
#line 228 "kpasm.y"
    {
  Opcode* op=(Opcode*)malloc(sizeof(Opcode));
  op->letype=LABELOPCODE;
  op->ligne=yylineno;
  op->operandes.oplabel.num=(yyvsp[-1].entier);
  (yyval.opcode)=op;
;}
    break;

  case 16:
#line 235 "kpasm.y"
    {
  Opcode* op=(Opcode*)malloc(sizeof(Opcode));
  Locked* l=(Locked*)malloc(sizeof(Locked));
  op->ligne=yylineno;
  op->letype=LOCKOPCODE;
  op->operandes.oplock.ss=(yyvsp[-4].sousopcode);
  op->operandes.oplock.id=(yyvsp[-2].chaine);
  l->ss=(yyvsp[-4].sousopcode);
  l->id=(yyvsp[-2].chaine);
  if(ll_find(&lockeds,(yyvsp[-2].chaine),cmp_char_locked)==NULL)
    ll_push_back(&lockeds,l);
  (yyval.opcode)=op;
;}
    break;

  case 17:
#line 248 "kpasm.y"
    {
  Opcode* op=(Opcode*)malloc(sizeof(Opcode));
  op->letype=LOCKOPCODE;
  op->ligne=yylineno;
  op->operandes.oplock.ss=(yyvsp[-2].sousopcode);
  op->operandes.oplock.id=NULL;
  (yyval.opcode)=op;
;}
    break;

  case 18:
#line 257 "kpasm.y"
    {
  Opcode* op=(Opcode*)malloc(sizeof(Opcode));
  op->letype=FREEOPCODE;
  op->ligne=yylineno;
  op->operandes.oplock.id=(yyvsp[-2].chaine);
  op->operandes.oplock.ss=NULL;
  (yyval.opcode)=op;
;}
    break;

  case 19:
#line 266 "kpasm.y"
    {
  Opcode* op=(Opcode*)malloc(sizeof(Opcode));
  op->letype=FREEOPCODE;
  op->ligne=yylineno;
  op->operandes.oplock.id=NULL;
  op->operandes.oplock.ss=(yyvsp[-2].sousopcode);
  (yyval.opcode)=op;
;}
    break;

  case 20:
#line 276 "kpasm.y"
    {
  Opcode* op=(Opcode*)malloc(sizeof(Opcode));
  op->letype=INITMEMOPCODE;
  op->ligne=yylineno;

  op->operandes.opegal.valeur=(yyvsp[-2].sousopcode);
  if((yyvsp[-4].sousopcode)->letype!=ARG && (yyvsp[-4].sousopcode)->letype!=RNDM)
  {
    add_error("Utilisation invalide de INITMEM");
    op->letype=INVALIDE_OPCODE;
  }
  else
  {
    op->operandes.opegal.dest=(yyvsp[-4].sousopcode);
  }
  (yyval.opcode)=op;
;}
    break;

  case 21:
#line 293 "kpasm.y"
    {
  Opcode* op=(Opcode*)malloc(sizeof(Opcode));
  op->letype=CHANGEMEMOPCODE;
  op->ligne=yylineno;

  op->operandes.opegal.valeur=(yyvsp[-2].sousopcode);
  if((yyvsp[-4].sousopcode)->letype!=ARG && (yyvsp[-4].sousopcode)->letype!=RNDM)
  {
    add_error("Utilisation invalide de CHANGEMEM");
    op->letype=INVALIDE_OPCODE;
  }
  else
  {
    op->operandes.opegal.dest=(yyvsp[-4].sousopcode);
  }
  (yyval.opcode)=op;
;}
    break;

  case 22:
#line 310 "kpasm.y"
    {
  Opcode* op=(Opcode*)malloc(sizeof(Opcode));
  op->letype=WRITE;
  op->ligne=yylineno;
  op->operandes.opwrite.nboctets=1;
  op->operandes.opwrite.valeur=(yyvsp[-2].sousopcode);
  (yyval.opcode)=op;
;}
    break;

  case 23:
#line 318 "kpasm.y"
    {
  Opcode* op=(Opcode*)malloc(sizeof(Opcode));
  op->letype=WRITE;
  op->ligne=yylineno;
  op->operandes.opwrite.nboctets=2;
  op->operandes.opwrite.valeur=(yyvsp[-2].sousopcode);
  (yyval.opcode)=op;
;}
    break;

  case 24:
#line 326 "kpasm.y"
    {
  Opcode* op=(Opcode*)malloc(sizeof(Opcode));
  op->letype=WRITE;
  op->ligne=yylineno;
  op->operandes.opwrite.nboctets=4;
  op->operandes.opwrite.valeur=(yyvsp[-2].sousopcode);
  (yyval.opcode)=op;
;}
    break;

  case 25:
#line 334 "kpasm.y"
    {
  Opcode* op=(Opcode*)malloc(sizeof(Opcode));
  op->letype=CONDITIONIF;
  op->ligne=yylineno;
  op->operandes.opif.condition=(yyvsp[-2].sousopcode);
  op->operandes.opif.codeif=(yyvsp[0].liste);
  (yyval.opcode)=op;
;}
    break;

  case 26:
#line 343 "kpasm.y"
    {
  Opcode* op=(Opcode*)malloc(sizeof(Opcode));
  op->letype=CONDITIONIFELSE;
  op->ligne=yylineno;
  op->operandes.opif.condition=(yyvsp[-4].sousopcode);
  op->operandes.opif.codeif=(yyvsp[-2].liste);
  op->operandes.opif.codeelse=(yyvsp[0].liste);
  (yyval.opcode)=op;
;}
    break;

  case 27:
#line 357 "kpasm.y"
    {
  linkedlist l;
  ll_init(&l,sizeof(Opcode));
  ll_push_back(&l,(yyvsp[0].opcode));
  (yyval.liste)=l;
;}
    break;

  case 28:
#line 364 "kpasm.y"
    {
  (yyval.liste)=(yyvsp[-1].liste);
;}
    break;

  case 29:
#line 369 "kpasm.y"
    {
  linkedlist l;
  ll_init(&l,sizeof(Opcode));
  ll_push_back(&l,(yyvsp[0].opcode));
  (yyval.liste)=l;
;}
    break;

  case 30:
#line 375 "kpasm.y"
    {
  (yyvsp[0].opcode)->ligne=yylineno;
  ll_push_back(&(yyvsp[-1].liste),(yyvsp[0].opcode));
  (yyval.liste)=(yyvsp[-1].liste);
;}
    break;

  case 31:
#line 381 "kpasm.y"
    {
  linkedlist l;
  ll_init(&l,sizeof(Opcode));
  (yyval.liste)=l;
;}
    break;

  case 32:
#line 387 "kpasm.y"
    {
  linkedlist l;
  ll_init(&l,sizeof(SousOpcode));
  ll_push_back(&l,(yyvsp[0].sousopcode));
  (yyval.liste)=l;
;}
    break;

  case 33:
#line 393 "kpasm.y"
    {
  ll_push_back(&(yyvsp[-2].liste),(yyvsp[0].sousopcode));
  (yyval.liste)=(yyvsp[-2].liste);
;}
    break;

  case 34:
#line 398 "kpasm.y"
    {
  linkedlist l;
  ll_init(&l,sizeof(SousOpcode));
  (yyval.liste)=l;
;}
    break;

  case 35:
#line 407 "kpasm.y"
    { (yyval.sousopcode)=(yyvsp[-1].sousopcode);}
    break;

  case 36:
#line 409 "kpasm.y"
    {
  if((yyvsp[-2].sousopcode)->letype==CONSTANTE && (yyvsp[0].sousopcode)->letype==CONSTANTE)
    {
      (yyvsp[-2].sousopcode)->operandes.valeur|=(yyvsp[0].sousopcode)->operandes.valeur;
      (yyval.sousopcode)=(yyvsp[-2].sousopcode);
      free((yyvsp[0].sousopcode));
    }
  else
    {
      SousOpcode *cur=(SousOpcode*)malloc(sizeof(SousOpcode));
      cur->letype=OU;
      cur->operandes.couple.gauche=(yyvsp[-2].sousopcode);
      cur->operandes.couple.droit=(yyvsp[0].sousopcode);
      cur->ligne=yylineno;
      (yyval.sousopcode)=cur;
    }
;}
    break;

  case 37:
#line 427 "kpasm.y"
    {
  if((yyvsp[-2].sousopcode)->letype==CONSTANTE && (yyvsp[0].sousopcode)->letype==CONSTANTE)
    {
      (yyvsp[-2].sousopcode)->operandes.valeur|=(yyvsp[0].sousopcode)->operandes.valeur;
      (yyval.sousopcode)=(yyvsp[-2].sousopcode);
      free((yyvsp[0].sousopcode));
    }
  else
    {
      SousOpcode *cur=(SousOpcode*)malloc(sizeof(SousOpcode));
      cur->letype=OU;
      cur->operandes.couple.gauche=(yyvsp[-2].sousopcode);
      cur->operandes.couple.droit=(yyvsp[0].sousopcode);
      cur->ligne=yylineno;
      (yyval.sousopcode)=cur;
    }
;}
    break;

  case 38:
#line 444 "kpasm.y"
    {
  if((yyvsp[-2].sousopcode)->letype==CONSTANTE && (yyvsp[0].sousopcode)->letype==CONSTANTE)
    {
      (yyvsp[-2].sousopcode)->operandes.valeur&=(yyvsp[0].sousopcode)->operandes.valeur;
      (yyval.sousopcode)=(yyvsp[-2].sousopcode);
      free((yyvsp[0].sousopcode));
    }
  else
    {
      SousOpcode *cur=(SousOpcode*)malloc(sizeof(SousOpcode));
      cur->letype=ET;
      cur->operandes.couple.gauche=(yyvsp[-2].sousopcode);
      cur->operandes.couple.droit=(yyvsp[0].sousopcode);
      cur->ligne=yylineno;
      (yyval.sousopcode)=cur;
    }
;}
    break;

  case 39:
#line 461 "kpasm.y"
    {
  if((yyvsp[-2].sousopcode)->letype==CONSTANTE && (yyvsp[0].sousopcode)->letype==CONSTANTE)
    {
      (yyvsp[-2].sousopcode)->operandes.valeur&=(yyvsp[0].sousopcode)->operandes.valeur;
      (yyval.sousopcode)=(yyvsp[-2].sousopcode);
      free((yyvsp[0].sousopcode));
    }
  else
    {
      SousOpcode *cur=(SousOpcode*)malloc(sizeof(SousOpcode));
      cur->letype=ET;
      cur->operandes.couple.gauche=(yyvsp[-2].sousopcode);
      cur->operandes.couple.droit=(yyvsp[0].sousopcode);
      cur->ligne=yylineno;
      (yyval.sousopcode)=cur;
    }
;}
    break;

  case 40:
#line 478 "kpasm.y"
    {
  if((yyvsp[-2].sousopcode)->letype==CONSTANTE && (yyvsp[0].sousopcode)->letype==CONSTANTE)
    {
      (yyvsp[-2].sousopcode)->operandes.valeur^=(yyvsp[0].sousopcode)->operandes.valeur;
      (yyval.sousopcode)=(yyvsp[-2].sousopcode);
      free((yyvsp[0].sousopcode));
    }
  else
    {
      SousOpcode *cur=(SousOpcode*)malloc(sizeof(SousOpcode));
      cur->letype=OUEX;
      cur->operandes.couple.gauche=(yyvsp[-2].sousopcode);
      cur->operandes.couple.droit=(yyvsp[0].sousopcode);
      cur->ligne=yylineno;
      (yyval.sousopcode)=cur;
    }
;}
    break;

  case 41:
#line 495 "kpasm.y"
    {
  if((yyvsp[-2].sousopcode)->letype==CONSTANTE && (yyvsp[0].sousopcode)->letype==CONSTANTE)
    {
      (yyvsp[-2].sousopcode)->operandes.valeur+=(yyvsp[0].sousopcode)->operandes.valeur;
      (yyval.sousopcode)=(yyvsp[-2].sousopcode);
      free((yyvsp[0].sousopcode));
    }
  else
    {
      SousOpcode *cur=(SousOpcode*)malloc(sizeof(SousOpcode));
      cur->letype=ADDITION;
      cur->operandes.couple.gauche=(yyvsp[-2].sousopcode);
      cur->operandes.couple.droit=(yyvsp[0].sousopcode);
      cur->ligne=yylineno;
      (yyval.sousopcode)=cur;
    }
;}
    break;

  case 42:
#line 513 "kpasm.y"
    {
  if((yyvsp[-2].sousopcode)->letype==CONSTANTE && (yyvsp[0].sousopcode)->letype==CONSTANTE)
    {
      (yyvsp[-2].sousopcode)->operandes.valeur-=(yyvsp[0].sousopcode)->operandes.valeur;
      (yyval.sousopcode)=(yyvsp[-2].sousopcode);
      free((yyvsp[0].sousopcode));
    }
  else
    {
      SousOpcode *cur=(SousOpcode*)malloc(sizeof(SousOpcode));
      cur->letype=SOUSTRACTION;
      cur->operandes.couple.gauche=(yyvsp[-2].sousopcode);
      cur->operandes.couple.droit=(yyvsp[0].sousopcode);
      cur->ligne=yylineno;
      (yyval.sousopcode)=cur;
    }
;}
    break;

  case 43:
#line 531 "kpasm.y"
    {
  if((yyvsp[-2].sousopcode)->letype==CONSTANTE && (yyvsp[0].sousopcode)->letype==CONSTANTE)
    {
      (yyvsp[-2].sousopcode)->operandes.valeur*=(yyvsp[0].sousopcode)->operandes.valeur;
      (yyval.sousopcode)=(yyvsp[-2].sousopcode);
      free((yyvsp[0].sousopcode));
    }
  else
    {
      SousOpcode *cur=(SousOpcode*)malloc(sizeof(SousOpcode));
      cur->letype=MULTIPLICATION;
      cur->operandes.couple.gauche=(yyvsp[-2].sousopcode);
      cur->operandes.couple.droit=(yyvsp[0].sousopcode);
      cur->ligne=yylineno;
      (yyval.sousopcode)=cur;
    }
;}
    break;

  case 44:
#line 549 "kpasm.y"
    {
  if((yyvsp[-2].sousopcode)->letype==CONSTANTE && (yyvsp[0].sousopcode)->letype==CONSTANTE)
    {
      (yyvsp[-2].sousopcode)->operandes.valeur/=(yyvsp[0].sousopcode)->operandes.valeur;
      (yyval.sousopcode)=(yyvsp[-2].sousopcode);
      free((yyvsp[0].sousopcode));
    }
  else
    {
      SousOpcode *cur=(SousOpcode*)malloc(sizeof(SousOpcode));
      cur->letype=DIVISION;
      cur->operandes.couple.gauche=(yyvsp[-2].sousopcode);
      cur->operandes.couple.droit=(yyvsp[0].sousopcode);
      cur->ligne=yylineno;
      (yyval.sousopcode)=cur;
    }
;}
    break;

  case 45:
#line 567 "kpasm.y"
    {
  if((yyvsp[-2].sousopcode)->letype==CONSTANTE && (yyvsp[0].sousopcode)->letype==CONSTANTE)
    {
      (yyvsp[-2].sousopcode)->operandes.valeur%=(yyvsp[0].sousopcode)->operandes.valeur;
      (yyval.sousopcode)=(yyvsp[-2].sousopcode);
      free((yyvsp[0].sousopcode));
    }
  else
    {
      SousOpcode *cur=(SousOpcode*)malloc(sizeof(SousOpcode));
      cur->letype=MOD;
      cur->operandes.couple.gauche=(yyvsp[-2].sousopcode);
      cur->operandes.couple.droit=(yyvsp[0].sousopcode);
      cur->ligne=yylineno;
      (yyval.sousopcode)=cur;
    }
;}
    break;

  case 46:
#line 585 "kpasm.y"
    {
  if((yyvsp[-2].sousopcode)->letype==CONSTANTE && (yyvsp[0].sousopcode)->letype==CONSTANTE)
    {
      (yyvsp[-2].sousopcode)->operandes.valeur<<=(yyvsp[0].sousopcode)->operandes.valeur;
      (yyval.sousopcode)=(yyvsp[-2].sousopcode);
      free((yyvsp[0].sousopcode));
    }
  else
    {
      SousOpcode *cur=(SousOpcode*)malloc(sizeof(SousOpcode));
      cur->letype=DECGAUCHE;
      cur->operandes.couple.gauche=(yyvsp[-2].sousopcode);
      cur->operandes.couple.droit=(yyvsp[0].sousopcode);
      cur->ligne=yylineno;
      (yyval.sousopcode)=cur;
    }
;}
    break;

  case 47:
#line 602 "kpasm.y"
    {
  if((yyvsp[-2].sousopcode)->letype==CONSTANTE && (yyvsp[0].sousopcode)->letype==CONSTANTE)
    {
      (yyvsp[-2].sousopcode)->operandes.valeur>>=(yyvsp[0].sousopcode)->operandes.valeur;
      (yyval.sousopcode)=(yyvsp[-2].sousopcode);
      free((yyvsp[0].sousopcode));
    }
  else
    {
      SousOpcode *cur=(SousOpcode*)malloc(sizeof(SousOpcode));
      cur->letype=DECDROIT;
      cur->operandes.couple.gauche=(yyvsp[-2].sousopcode);
      cur->operandes.couple.droit=(yyvsp[0].sousopcode);
      cur->ligne=yylineno;
      (yyval.sousopcode)=cur;
    }
;}
    break;

  case 48:
#line 619 "kpasm.y"
    {
  SousOpcode *cur=(SousOpcode*)malloc(sizeof(SousOpcode));
  cur->letype=JE;
  cur->operandes.couple.gauche=(yyvsp[-2].sousopcode);
  cur->operandes.couple.droit=(yyvsp[0].sousopcode);
  cur->ligne=yylineno;
  (yyval.sousopcode)=cur;
;}
    break;

  case 49:
#line 627 "kpasm.y"
    {
  SousOpcode *cur=(SousOpcode*)malloc(sizeof(SousOpcode));
  cur->letype=JNE;
  cur->operandes.couple.gauche=(yyvsp[-2].sousopcode);
  cur->operandes.couple.droit=(yyvsp[0].sousopcode);
  cur->ligne=yylineno;
  (yyval.sousopcode)=cur;
;}
    break;

  case 50:
#line 635 "kpasm.y"
    {
  SousOpcode *cur=(SousOpcode*)malloc(sizeof(SousOpcode));
  cur->letype=JB;
  cur->operandes.couple.gauche=(yyvsp[-2].sousopcode);
  cur->operandes.couple.droit=(yyvsp[0].sousopcode);
  cur->ligne=yylineno;
  (yyval.sousopcode)=cur;
;}
    break;

  case 51:
#line 643 "kpasm.y"
    {
  SousOpcode *cur=(SousOpcode*)malloc(sizeof(SousOpcode));
  cur->letype=JA;
  cur->operandes.couple.gauche=(yyvsp[-2].sousopcode);
  cur->operandes.couple.droit=(yyvsp[0].sousopcode);
  cur->ligne=yylineno;
  (yyval.sousopcode)=cur;
;}
    break;

  case 52:
#line 651 "kpasm.y"
    {
  SousOpcode *cur=(SousOpcode*)malloc(sizeof(SousOpcode));
  cur->letype=JAE;
  cur->operandes.couple.gauche=(yyvsp[-2].sousopcode);
  cur->operandes.couple.droit=(yyvsp[0].sousopcode);
  cur->ligne=yylineno;
  (yyval.sousopcode)=cur;
;}
    break;

  case 53:
#line 659 "kpasm.y"
    {
  SousOpcode *cur=(SousOpcode*)malloc(sizeof(SousOpcode));
  cur->letype=JBE;
  cur->operandes.couple.gauche=(yyvsp[-2].sousopcode);
  cur->operandes.couple.droit=(yyvsp[0].sousopcode);
  cur->ligne=yylineno;
  (yyval.sousopcode)=cur;
;}
    break;

  case 54:
#line 668 "kpasm.y"
    {
  SousOpcode *cur=(SousOpcode*)malloc(sizeof(SousOpcode));
  cur->letype=INDIRECTION;
  cur->operandes.sousopcode=(yyvsp[-1].sousopcode);
  cur->ligne=yylineno;
  (yyval.sousopcode)=cur;
;}
    break;

  case 55:
#line 676 "kpasm.y"
    {
  SousOpcode *cur=(SousOpcode*)malloc(sizeof(SousOpcode));
  cur->letype=NEGATION;
  cur->operandes.sousopcode=(yyvsp[0].sousopcode);
  cur->ligne=yylineno;
  (yyval.sousopcode)=cur;
;}
    break;

  case 56:
#line 684 "kpasm.y"
    {
  SousOpcode* cur=(SousOpcode*)malloc(sizeof(SousOpcode));
  cur->letype=CONSTANTE;
  cur->operandes.valeur=(yyvsp[0].entier);
  cur->ligne=yylineno;
  (yyval.sousopcode)=cur;
;}
    break;

  case 57:
#line 692 "kpasm.y"
    {
  SousOpcode *cur=(SousOpcode*)malloc(sizeof(SousOpcode));
  cur->letype=RNDI;
  cur->operandes.valeur=(yyvsp[0].entier);
  cur->ligne=yylineno;
  (yyval.sousopcode)=cur;
;}
    break;

  case 58:
#line 700 "kpasm.y"
    {
  SousOpcode *cur=(SousOpcode*)malloc(sizeof(SousOpcode));
  cur->letype=RNDM;
  cur->operandes.valeur=(yyvsp[0].entier);
  cur->ligne=yylineno;
  (yyval.sousopcode)=cur;
;}
    break;

  case 59:
#line 708 "kpasm.y"
    {
  SousOpcode *cur=(SousOpcode*)malloc(sizeof(SousOpcode));
  cur->letype=RNDR;
  cur->operandes.valeur=(yyvsp[0].entier);
  cur->ligne=yylineno;
  (yyval.sousopcode)=cur;
;}
    break;

  case 60:
#line 715 "kpasm.y"
    {
  SousOpcode *cur=(SousOpcode*)malloc(sizeof(SousOpcode));
  cur->letype=URNDR;
  cur->operandes.valeur=(yyvsp[0].entier);
  cur->ligne=yylineno;
  (yyval.sousopcode)=cur;
;}
    break;

  case 61:
#line 722 "kpasm.y"
    {
  SousOpcode *cur=(SousOpcode*)malloc(sizeof(SousOpcode));
  cur->letype=LAB;
  cur->operandes.valeur=(yyvsp[0].entier);
  cur->ligne=yylineno;
  (yyval.sousopcode)=cur;
  ;}
    break;

  case 62:
#line 730 "kpasm.y"
    {
  SousOpcode *cur=(SousOpcode*)malloc(sizeof(SousOpcode));
  cur->letype=ARG;
  cur->operandes.nom=(yyvsp[0].chaine);
  cur->ligne=yylineno;
  (yyval.sousopcode)=cur;
;}
    break;

  case 63:
#line 737 "kpasm.y"
    {
  SousOpcode *cur=(SousOpcode*)malloc(sizeof(SousOpcode));
  cur->letype=VAREXT;
  cur->operandes.nom=(yyvsp[0].chaine);
  cur->ligne=yylineno;
  (yyval.sousopcode)=cur;  
;}
    break;

  case 64:
#line 744 "kpasm.y"
    {
  SousOpcode *cur=(SousOpcode*)malloc(sizeof(SousOpcode));
  cur->letype=UREG;
  cur->operandes.valeur=(yyvsp[0].entier);
  cur->ligne=yylineno;
  (yyval.sousopcode)=cur;  
  ;}
    break;

  case 65:
#line 751 "kpasm.y"
    {
  SousOpcode *cur=(SousOpcode*)malloc(sizeof(SousOpcode));
  cur->letype=REG;
  cur->operandes.valeur=(yyvsp[0].entier);
  cur->ligne=yylineno;
  (yyval.sousopcode)=cur;  
  ;}
    break;


      default: break;
    }

/* Line 1126 of yacc.c.  */
#line 2348 "kpasm.tab.c"

  yyvsp -= yylen;
  yyssp -= yylen;
  yylsp -= yylen;

  YY_STACK_PRINT (yyss, yyssp);

  *++yyvsp = yyval;
  *++yylsp = yyloc;

  /* Now `shift' the result of the reduction.  Determine what state
     that goes to, based on the state we popped back to and the rule
     number reduced by.  */

  yyn = yyr1[yyn];

  yystate = yypgoto[yyn - YYNTOKENS] + *yyssp;
  if (0 <= yystate && yystate <= YYLAST && yycheck[yystate] == *yyssp)
    yystate = yytable[yystate];
  else
    yystate = yydefgoto[yyn - YYNTOKENS];

  goto yynewstate;


/*------------------------------------.
| yyerrlab -- here on detecting error |
`------------------------------------*/
yyerrlab:
  /* If not already recovering from an error, report this error.  */
  if (!yyerrstatus)
    {
      ++yynerrs;
#if YYERROR_VERBOSE
      yyn = yypact[yystate];

      if (YYPACT_NINF < yyn && yyn < YYLAST)
	{
	  int yytype = YYTRANSLATE (yychar);
	  YYSIZE_T yysize0 = yytnamerr (0, yytname[yytype]);
	  YYSIZE_T yysize = yysize0;
	  YYSIZE_T yysize1;
	  int yysize_overflow = 0;
	  char *yymsg = 0;
#	  define YYERROR_VERBOSE_ARGS_MAXIMUM 5
	  char const *yyarg[YYERROR_VERBOSE_ARGS_MAXIMUM];
	  int yyx;

#if 0
	  /* This is so xgettext sees the translatable formats that are
	     constructed on the fly.  */
	  YY_("syntax error, unexpected %s");
	  YY_("syntax error, unexpected %s, expecting %s");
	  YY_("syntax error, unexpected %s, expecting %s or %s");
	  YY_("syntax error, unexpected %s, expecting %s or %s or %s");
	  YY_("syntax error, unexpected %s, expecting %s or %s or %s or %s");
#endif
	  char *yyfmt;
	  char const *yyf;
	  static char const yyunexpected[] = "syntax error, unexpected %s";
	  static char const yyexpecting[] = ", expecting %s";
	  static char const yyor[] = " or %s";
	  char yyformat[sizeof yyunexpected
			+ sizeof yyexpecting - 1
			+ ((YYERROR_VERBOSE_ARGS_MAXIMUM - 2)
			   * (sizeof yyor - 1))];
	  char const *yyprefix = yyexpecting;

	  /* Start YYX at -YYN if negative to avoid negative indexes in
	     YYCHECK.  */
	  int yyxbegin = yyn < 0 ? -yyn : 0;

	  /* Stay within bounds of both yycheck and yytname.  */
	  int yychecklim = YYLAST - yyn;
	  int yyxend = yychecklim < YYNTOKENS ? yychecklim : YYNTOKENS;
	  int yycount = 1;

	  yyarg[0] = yytname[yytype];
	  yyfmt = yystpcpy (yyformat, yyunexpected);

	  for (yyx = yyxbegin; yyx < yyxend; ++yyx)
	    if (yycheck[yyx + yyn] == yyx && yyx != YYTERROR)
	      {
		if (yycount == YYERROR_VERBOSE_ARGS_MAXIMUM)
		  {
		    yycount = 1;
		    yysize = yysize0;
		    yyformat[sizeof yyunexpected - 1] = '\0';
		    break;
		  }
		yyarg[yycount++] = yytname[yyx];
		yysize1 = yysize + yytnamerr (0, yytname[yyx]);
		yysize_overflow |= yysize1 < yysize;
		yysize = yysize1;
		yyfmt = yystpcpy (yyfmt, yyprefix);
		yyprefix = yyor;
	      }

	  yyf = YY_(yyformat);
	  yysize1 = yysize + yystrlen (yyf);
	  yysize_overflow |= yysize1 < yysize;
	  yysize = yysize1;

	  if (!yysize_overflow && yysize <= YYSTACK_ALLOC_MAXIMUM)
	    yymsg = (char *) YYSTACK_ALLOC (yysize);
	  if (yymsg)
	    {
	      /* Avoid sprintf, as that infringes on the user's name space.
		 Don't have undefined behavior even if the translation
		 produced a string with the wrong number of "%s"s.  */
	      char *yyp = yymsg;
	      int yyi = 0;
	      while ((*yyp = *yyf))
		{
		  if (*yyp == '%' && yyf[1] == 's' && yyi < yycount)
		    {
		      yyp += yytnamerr (yyp, yyarg[yyi++]);
		      yyf += 2;
		    }
		  else
		    {
		      yyp++;
		      yyf++;
		    }
		}
	      yyerror (yymsg);
	      YYSTACK_FREE (yymsg);
	    }
	  else
	    {
	      yyerror (YY_("syntax error"));
	      goto yyexhaustedlab;
	    }
	}
      else
#endif /* YYERROR_VERBOSE */
	yyerror (YY_("syntax error"));
    }

  yyerror_range[0] = yylloc;

  if (yyerrstatus == 3)
    {
      /* If just tried and failed to reuse look-ahead token after an
	 error, discard it.  */

      if (yychar <= YYEOF)
        {
	  /* Return failure if at end of input.  */
	  if (yychar == YYEOF)
	    YYABORT;
        }
      else
	{
	  yydestruct ("Error: discarding", yytoken, &yylval, &yylloc);
	  yychar = YYEMPTY;
	}
    }

  /* Else will try to reuse look-ahead token after shifting the error
     token.  */
  goto yyerrlab1;


/*---------------------------------------------------.
| yyerrorlab -- error raised explicitly by YYERROR.  |
`---------------------------------------------------*/
yyerrorlab:

  /* Pacify compilers like GCC when the user code never invokes
     YYERROR and the label yyerrorlab therefore never appears in user
     code.  */
  if (0)
     goto yyerrorlab;

  yyerror_range[0] = yylsp[1-yylen];
  yylsp -= yylen;
  yyvsp -= yylen;
  yyssp -= yylen;
  yystate = *yyssp;
  goto yyerrlab1;


/*-------------------------------------------------------------.
| yyerrlab1 -- common code for both syntax error and YYERROR.  |
`-------------------------------------------------------------*/
yyerrlab1:
  yyerrstatus = 3;	/* Each real token shifted decrements this.  */

  for (;;)
    {
      yyn = yypact[yystate];
      if (yyn != YYPACT_NINF)
	{
	  yyn += YYTERROR;
	  if (0 <= yyn && yyn <= YYLAST && yycheck[yyn] == YYTERROR)
	    {
	      yyn = yytable[yyn];
	      if (0 < yyn)
		break;
	    }
	}

      /* Pop the current state because it cannot handle the error token.  */
      if (yyssp == yyss)
	YYABORT;

      yyerror_range[0] = *yylsp;
      yydestruct ("Error: popping", yystos[yystate], yyvsp, yylsp);
      YYPOPSTACK;
      yystate = *yyssp;
      YY_STACK_PRINT (yyss, yyssp);
    }

  if (yyn == YYFINAL)
    YYACCEPT;

  *++yyvsp = yylval;

  yyerror_range[1] = yylloc;
  /* Using YYLLOC is tempting, but would change the location of
     the look-ahead.  YYLOC is available though. */
  YYLLOC_DEFAULT (yyloc, yyerror_range - 1, 2);
  *++yylsp = yyloc;

  /* Shift the error token. */
  YY_SYMBOL_PRINT ("Shifting", yystos[yyn], yyvsp, yylsp);

  yystate = yyn;
  goto yynewstate;


/*-------------------------------------.
| yyacceptlab -- YYACCEPT comes here.  |
`-------------------------------------*/
yyacceptlab:
  yyresult = 0;
  goto yyreturn;

/*-----------------------------------.
| yyabortlab -- YYABORT comes here.  |
`-----------------------------------*/
yyabortlab:
  yyresult = 1;
  goto yyreturn;

#ifndef yyoverflow
/*-------------------------------------------------.
| yyexhaustedlab -- memory exhaustion comes here.  |
`-------------------------------------------------*/
yyexhaustedlab:
  yyerror (YY_("memory exhausted"));
  yyresult = 2;
  /* Fall through.  */
#endif

yyreturn:
  if (yychar != YYEOF && yychar != YYEMPTY)
     yydestruct ("Cleanup: discarding lookahead",
		 yytoken, &yylval, &yylloc);
  while (yyssp != yyss)
    {
      yydestruct ("Cleanup: popping",
		  yystos[*yyssp], yyvsp, yylsp);
      YYPOPSTACK;
    }
#ifndef yyoverflow
  if (yyss != yyssa)
    YYSTACK_FREE (yyss);
#endif
  return yyresult;
}


#line 761 "kpasm.y"

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



