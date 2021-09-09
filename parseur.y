%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include "arbre-abstrait.h"
    #include "tpK-tabSymbol.h"

    int nbParams = 0, nbVarGlob = 0, nbVarLoc = 0, nbFonc = 0;
    classe_t contexte = C_GLOBAL;
    type_t typeVar;

    void yyerror(const char*);
    int yylex();
%}

%define parse.lac full
%define parse.error verbose

%union {double dval; int ival; char sval[32]; Arbre arbre;}
%token LEQ EQ AND OR INT FLOAT DOUBLE CHAR IF ELSE WHILE MAIN VOID PARENTH_O_F
%token <sval> IDENT
%token <ival> ENTIER 
%token <dval> REEL
%type <arbre> EXPRESSION EXPRESSION_AR EXPRESSION_BOOL TERME FACTEUR CONDITION AUTRE_CONDITION APPEL_FUNC
%left '+' '-'
%left '*' '/'
%nonassoc MOINSU PLUSU
%start program /* axiom */

%%

program: LISTE_DEC_VAR LISTE_DEC_FUNC MAIN {contexte = C_LOCAL; ajouterEntree("main", C_FONCTION, T_ENTIER, nbFonc++, 0);} BLOC LISTE_DEF_FUNC
    | main
    ;

BLOC: '{' LISTE_INSTR '}'
    | '{' BLOC '}'
    | '{' '}'
    ;
    
LISTE_DEC_VAR: {contexte = C_GLOBAL;} DECLARATION_VAR {nbVarGlob++;} LISTE_DEC_VAR
    | VIDE
    ;

LISTE_DEC_FUNC: {contexte = C_FONCTION;} DECLARATION_FUNC ';' {nbFonc++;} LISTE_DEC_FUNC
    | VIDE
    ;

LISTE_DEF_FUNC: {contexte = C_FONCTION;} DECLARATION_FUNC BLOC LISTE_DEF_FUNC
    | VIDE
    ;

DECLARATION_FUNC: {typeVar = T_ENTIER;} INT SUITE_DEC_FUNC
    | {typeVar = T_DOUBLE;} DOUBLE SUITE_DEC_FUNC
    | {typeVar = T_CHAR;} CHAR SUITE_DEC_FUNC
    | {typeVar = T_FLOAT;} FLOAT SUITE_DEC_FUNC
    | {typeVar = T_VOID;} VOID SUITE_DEC_FUNC
    ;

SUITE_DEC_FUNC: IDENT {nbParams = 0;} '(' LISTE_PARAM ')'   {ajouterEntree($1, contexte, typeVar, nbFonc, nbParams);}
    | IDENT PARENTH_O_F                                     {ajouterEntree($1, contexte, typeVar, nbFonc, 0);}
    ;

LISTE_PARAM: PARAM  
    | PARAM ',' LISTE_PARAM
    ;

VIDE: ;

PARAM: INT IDENT {nbParams++;}
    | DOUBLE IDENT {nbParams++;}
    | CHAR IDENT {nbParams++;}
    | FLOAT IDENT {nbParams++;}
    ;

DECLARATION_VAR: {typeVar = T_ENTIER;} INT IDENT ';'  {ajouterEntree($3, contexte, typeVar, nbVarGlob, 0);}
    | {typeVar = T_FLOAT;} FLOAT IDENT ';'    {ajouterEntree($3, contexte, typeVar, nbVarGlob, 0);}
    | {typeVar = T_DOUBLE;} DOUBLE IDENT ';'   {ajouterEntree($3, contexte, typeVar, nbVarGlob, 0);}
    | {typeVar = T_CHAR;} CHAR IDENT ';'     {ajouterEntree($3, contexte, typeVar, nbVarGlob, 0);}
    ;

LISTE_INSTR: INSTRUCTION LISTE_INSTR
    | INSTRUCTION
    ;

INSTRUCTION: ';'
    | DECLARATION_VAR
    | IDENT '=' EXPRESSION ';'
    | APPEL_FUNC ';'
    | IF_INST
    | IF_ELSE
    | BOUCLE
    | BLOC
    ;

IF_INST: IF '(' EXPRESSION_BOOL ')' LISTE_INSTR
    ;

ELSE_INST: ELSE LISTE_INSTR
    ;

IF_ELSE: IF_INST ELSE_INST
    ;

BOUCLE: WHILE '(' EXPRESSION_BOOL ')' LISTE_INSTR
    ;

main: EXPRESSION ';'                      {afficher_arbre($1); printf("\n"); arbre_vider($1);}
    ;

EXPRESSION: EXPRESSION_AR                 {$$ = $1;}
    | EXPRESSION_BOOL                   {$$ = $1;}
    ;

EXPRESSION_AR: TERME '+' EXPRESSION_AR  {$$ = arbre_ajout_lettre('+', $1, $3);}
    | TERME  '-' EXPRESSION_AR          {$$ = arbre_ajout_lettre('-', $1, $3);}
    | TERME                             {$$ = $1;}
    ;

TERME: FACTEUR '*' TERME                {$$ = arbre_ajout_lettre('*', $1, $3);}
    | FACTEUR '/' TERME                {$$ = arbre_ajout_lettre('/', $1, $3);}
    | FACTEUR                           {$$ = $1;}
    ;

FACTEUR: '(' EXPRESSION_AR ')'          {$$ = $2;}
    | '-' FACTEUR %prec MOINSU          {$$ = arbre_ajout_lettre('-', $2, NULL);}
    | '+' FACTEUR %prec PLUSU           {$$ = arbre_ajout_lettre('+', $2, NULL);}
    | ENTIER                            {$$ = arbre_init_entier($1);}
    | REEL                              {$$ = arbre_init_reel($1);}
    | IDENT                             {$$ = arbre_init_texte($1);}
    | APPEL_FUNC                        {$$ = NULL;}
    ;

APPEL_FUNC: IDENT PARENTH_O_F           {$$ = NULL;}
    | IDENT '(' ARGUMENTS ')'           {$$ = NULL;}
    ;

ARGUMENTS: EXPRESSION ',' ARGUMENTS
    | EXPRESSION
    ;

EXPRESSION_BOOL: CONDITION AND EXPRESSION_BOOL {$$ = arbre_ajout_texte("&&", $1, $3);}
    | CONDITION OR EXPRESSION_BOOL             {$$ = arbre_ajout_texte("||", $1, $3);}
    | '(' EXPRESSION_BOOL ')'                   {$$ = $2;}
    | CONDITION                                 {$$ = $1;}
    ;

CONDITION: AUTRE_CONDITION '<' CONDITION        {$$ = arbre_ajout_lettre('<', $1, $3);}
    | AUTRE_CONDITION LEQ CONDITION             {$$ = arbre_ajout_texte("<=", $1, $3);}
    | AUTRE_CONDITION EQ CONDITION              {$$ = arbre_ajout_texte("==", $1, $3);}
    | AUTRE_CONDITION '+' CONDITION             {$$ = arbre_ajout_lettre('+', $1, $3);}
    | AUTRE_CONDITION '-' CONDITION             {$$ = arbre_ajout_lettre('-', $1, $3);}
    | AUTRE_CONDITION '*' CONDITION             {$$ = arbre_ajout_lettre('*', $1, $3);}
    | AUTRE_CONDITION '/' CONDITION             {$$ = arbre_ajout_lettre('/', $1, $3);}
    | AUTRE_CONDITION                           {$$ = $1;}
    ;

AUTRE_CONDITION: '!' AUTRE_CONDITION            {$$ = arbre_ajout_lettre('!', $2, NULL);}
    | EXPRESSION_AR                             {$$ = $1;}
    ;

%%

void yyerror(const char* err){
    fprintf(stderr, "%s\n", err);
}

int yywrap(){
    return 1;
}