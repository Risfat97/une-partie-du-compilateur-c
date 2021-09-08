%code requires {
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include "arbre-abstrait.h"
    #include "tpK-tabSymbol.h"

    void yyerror(const char*);
    int yylex();
}

%union {double dval; int ival; char sval[32]; Arbre arbre;}
%token LEQ EQ AND OR INT FLOAT DOUBLE CHAR IF ELSE WHILE
%token <sval> IDENT
%token <ival> ENTIER 
%token <dval> REEL
%type <arbre> resultat EXPRESSION_AR EXPRESSION_BOOL TERME FACTEUR CONDITION AUTRE_CONDITION
%left '+' '-'
%left '*' '/'
%nonassoc MOINSU PLUSU
%start main /* axiom */

%%

main: DECLARATION
    | LISTE_INSTR
    | DECLARATION LISTE_INSTR
    | resultat                          {afficher_arbre($1); printf("\n");}
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
    | IDENT '(' ARGUMENTS ')'           {$$ = NULL;}
    ;

ARGUMENTS: resultat ',' ARGUMENTS
    | resultat
    | VIDE
    ;

VIDE: ;

EXPRESSION_BOOL: EXPRESSION_BOOL  AND CONDITION {$$ = arbre_ajout_texte("&&", $1, $3);}
    | EXPRESSION_BOOL OR CONDITION              {$$ = arbre_ajout_texte("||", $1, $3);}
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

AUTRE_CONDITION: '(' EXPRESSION_BOOL ')'        {$$ = $2;}
    | '!' AUTRE_CONDITION                       {$$ = arbre_ajout_lettre('!', $2, NULL);}
    | EXPRESSION_AR                             {$$ = $1;}
    ;

DECLARATION: INT IDENT ';'
    | FLOAT IDENT ';'
    | DOUBLE IDENT ';'
    | CHAR IDENT ';'
    ;

INSTRUCTION: ';'
    | IDENT '=' resultat ';'
    | INSTRUCTION '\n'
    ;

LISTE_INSTR: INSTRUCTION
    | INSTRUCTION INSTRUCTION
    | BLOC
    | IF_INST
    | IF_ELSE
    | BOUCLE
    | LISTE_INSTR LISTE_INSTR
    ;

BLOC: '{' '}'
    | '{' LISTE_INSTR '}'
    | '{' BLOC '}'
    ;

IF_INST: IF '(' EXPRESSION_BOOL ')' LISTE_INSTR
    ;

ELSE_INST: ELSE LISTE_INSTR
    ;

IF_ELSE: IF_INST ELSE_INST
    ;

BOUCLE: WHILE '(' EXPRESSION_BOOL ')' LISTE_INSTR
    ;
%%

void yyerror(const char* err){
    fprintf(stderr, "erreur de syntaxe\n");
}

int yywrap(){
    return 1;
}