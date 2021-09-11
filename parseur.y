%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include "arbre-abstrait.h"
    #include "tpK-tabSymbol.h"

    int nbParams = 0;
    int adrCourant[3] = {0};
    classe_t contexte = C_GLOBAL;
    type_t typeVar;
    curseur_adr_t curseur = ADR_GLOB;

    void yyerror(const char*);
    int yylex();
%}

%define parse.lac full
%define parse.error verbose

%union {int ival; char sval[32]; Arbre arbre;}
%token LEQ EQ AND OR INT IF ELSE WHILE MAIN
%token <sval> IDENT
%token <ival> ENTIER
%type <arbre> EXPRESSION EXPRESSION_AR EXPRESSION_BOOL TERME FACTEUR CONDITION AUTRE_CONDITION APPEL_FUNC
%left '+' '-'
%left '*' '/'
%nonassoc MOINSU PLUSU
%start program /* axiom */

%%

program: DECLARATIONS DEFINITIONS
    | DEFINITIONS
    | main
    ;

DECLARATIONS: DECLARATION DECLARATIONS
    | DECLARATION
    ;

DECLARATION: DECLARATION_VAR ';'
    | DECLARATION_FUNC ';'
    ;

DECLARATION_FUNC: DECLARATION_VAR SUITE_DEC_FUNC
    ;

SUITE_DEC_FUNC: '(' ')'
    | '(' LISTE_PARAM ')'
    ;

DECLARATION_VAR: INT IDENT
    ;

DEFINITIONS: MAIN BLOC
    | MAIN BLOC LISTE_DEF_FUNC
    ;

LISTE_PARAM: DECLARATION_VAR ',' LISTE_PARAM
    | DECLARATION_VAR
    ;

BLOC: '{' LISTE_INSTR '}'
    | '{' BLOC '}'
    | '{' '}'
    ;

LISTE_DEF_FUNC: DECLARATION_FUNC BLOC LISTE_DEF_FUNC
    | DECLARATION_FUNC BLOC
    ;

LISTE_INSTR: INSTRUCTION LISTE_INSTR
    | INSTRUCTION
    ;

INSTRUCTION: ';'
    | DECLARATION_VAR ';'
    | IDENT '=' EXPRESSION ';'
    | APPEL_FUNC ';'
    | IF_ELSE
    | BOUCLE
    | BLOC
    ;

IF_ELSE: IF '(' EXPRESSION_BOOL ')' LISTE_INSTR ELSE LISTE_INSTR
    ;

BOUCLE: WHILE '(' EXPRESSION_BOOL ')' LISTE_INSTR
    ;

main: EXPRESSION ';'          {printf("\nArbre syntaxique abstrait correspondant: \n"); afficher_arbre($1); printf("\n"); arbre_vider($1);}
    ;

EXPRESSION: EXPRESSION_AR               {$$ = $1;}
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
    | IDENT                             {$$ = arbre_init_texte($1);}
    | APPEL_FUNC                        {$$ = NULL;}
    ;

APPEL_FUNC: IDENT '(' ')'           {$$ = NULL;}
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