%code requires {
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include "arbre-abstrait.h"
    #include "tpK-tabSymbol.h"

    void yyerror(const char*);
    int yylex();
}

%define parse.lac full
%define parse.error verbose

%union {double dval; int ival; char sval[32]; Arbre arbre;}
%token LEQ EQ AND OR INT FLOAT DOUBLE CHAR IF ELSE WHILE MAIN VOID PARENTH_O_F
%token <sval> IDENT
%token <ival> ENTIER 
%token <dval> REEL
%type <arbre> resultat EXPRESSION_AR EXPRESSION_BOOL TERME FACTEUR CONDITION AUTRE_CONDITION APPEL_FUNC
%left '+' '-'
%left '*' '/'
%nonassoc MOINSU PLUSU
%start program /* axiom */

%%

program: LISTE_DEC_VAR LISTE_DEC_FUNC MAIN BLOC LISTE_DEF_FUNC
    | main
    ;

BLOC: '{' LISTE_INSTR '}'
    | '{' VIDE '}'
    | '{' BLOC '}'
    ;
    
LISTE_DEC_VAR: DECLARATION_VAR LISTE_DEC_VAR
    | VIDE
    ;

LISTE_DEC_FUNC: DECLARATION_FUNC ';' LISTE_DEC_FUNC
    | VIDE
    ;

LISTE_DEF_FUNC: DECLARATION_FUNC BLOC LISTE_DEF_FUNC
    | VIDE
    ;

DECLARATION_FUNC: INT SUITE_DEC_FUNC
    | DOUBLE SUITE_DEC_FUNC
    | CHAR SUITE_DEC_FUNC
    | FLOAT SUITE_DEC_FUNC
    | VOID SUITE_DEC_FUNC
    ;

SUITE_DEC_FUNC: IDENT '(' LISTE_PARAM ')'
    | IDENT PARENTH_O_F
    ;

LISTE_PARAM: PARAM
    | PARAM ',' LISTE_PARAM
    ;

VIDE: ;

PARAM: INT IDENT
    | DOUBLE IDENT
    | CHAR IDENT
    | FLOAT IDENT
    | LISTE_PARAM
    ;

DECLARATION_VAR: INT IDENT ';'
    | FLOAT IDENT ';'
    | DOUBLE IDENT ';'
    | CHAR IDENT ';'
    ;

LISTE_INSTR: DECLARATION_VAR
    | INSTRUCTION
    | INSTRUCTION INSTRUCTION
    | IF_INST
    | IF_ELSE
    | BOUCLE
    | LISTE_INSTR LISTE_INSTR
    | BLOC
    ;

INSTRUCTION: ';'
    | IDENT '=' resultat ';'
    | APPEL_FUNC
    ;

IF_INST: IF '(' EXPRESSION_BOOL ')' LISTE_INSTR
    ;

ELSE_INST: ELSE LISTE_INSTR
    ;

IF_ELSE: IF_INST ELSE_INST
    ;

BOUCLE: WHILE '(' EXPRESSION_BOOL ')' LISTE_INSTR
    ;

main: resultat ';'                      {afficher_arbre($1); printf("\n");}
    ;

resultat: EXPRESSION_AR                 {$$ = $1;}
    | EXPRESSION_BOOL                   {$$ = $1;}
    ;

EXPRESSION_AR: EXPRESSION_AR '+' TERME  {$$ = arbre_ajout_lettre('+', $1, $3);}
    | EXPRESSION_AR '-' TERME           {$$ = arbre_ajout_lettre('-', $1, $3);}
    | TERME                             {$$ = $1;}
    ;

TERME: TERME '*' FACTEUR                {$$ = arbre_ajout_lettre('*', $1, $3);}
    | TERME '/' FACTEUR                 {$$ = arbre_ajout_lettre('/', $1, $3);}
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

ARGUMENTS: resultat ',' ARGUMENTS
    | resultat
    ;

EXPRESSION_BOOL: EXPRESSION_BOOL  AND CONDITION {$$ = arbre_ajout_texte("&&", $1, $3);}
    | EXPRESSION_BOOL OR CONDITION              {$$ = arbre_ajout_texte("||", $1, $3);}
    | '(' EXPRESSION_BOOL ')'                   {$$ = $2;}
    | CONDITION                                 {$$ = $1;}
    ;

CONDITION: CONDITION '<' AUTRE_CONDITION        {$$ = arbre_ajout_lettre('<', $1, $3);}
    | CONDITION LEQ AUTRE_CONDITION             {$$ = arbre_ajout_texte("<=", $1, $3);}
    | CONDITION EQ AUTRE_CONDITION              {$$ = arbre_ajout_texte("==", $1, $3);}
    | CONDITION '+' AUTRE_CONDITION             {$$ = arbre_ajout_lettre('+', $1, $3);}
    | CONDITION '-' AUTRE_CONDITION             {$$ = arbre_ajout_lettre('-', $1, $3);}
    | CONDITION '*' AUTRE_CONDITION             {$$ = arbre_ajout_lettre('*', $1, $3);}
    | CONDITION '/' AUTRE_CONDITION             {$$ = arbre_ajout_lettre('/', $1, $3);}
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