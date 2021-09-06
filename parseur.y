%{
    #include <stdio.h>
    #include <stdlib.h>
    void yyerror(const char*);
    int yylex();
%}

%token NOMBRE IDENT LEQ EQ AND OR
%left '+' '-'
%left '*' '/'
%nonassoc MOINSU PLUSU
%start resultat /* axiom */

%%
resultat: EXPRESSION_AR
    | EXPRESSION_BOOL
    ;

EXPRESSION_AR: EXPRESSION_AR '+' TERME
    | EXPRESSION_AR '-' TERME
    | TERME
    ;

TERME: TERME '*' FACTEUR
    | TERME '/' FACTEUR
    | FACTEUR
    ;

FACTEUR: '(' EXPRESSION_AR ')'
    | '-' FACTEUR %prec MOINSU
    | '+' FACTEUR %prec PLUSU
    | NOMBRE
    | IDENT
    ;

EXPRESSION_BOOL: EXPRESSION_BOOL  AND CONDITION
    | EXPRESSION_BOOL OR CONDITION
    | CONDITION
    ;

CONDITION: CONDITION '<' AUTRE_CONDITION
    | CONDITION LEQ AUTRE_CONDITION
    | CONDITION EQ AUTRE_CONDITION
    | CONDITION '+' AUTRE_CONDITION
    | CONDITION '-' AUTRE_CONDITION
    | CONDITION '*' AUTRE_CONDITION
    | CONDITION '/' AUTRE_CONDITION
    | AUTRE_CONDITION
    ;

AUTRE_CONDITION: '(' EXPRESSION_BOOL ')'
    | '!' AUTRE_CONDITION
    | EXPRESSION_AR
    ;
%%

void yyerror(const char* err){
    fprintf(stderr, "erreur de syntaxe\n");
}

int yywrap(){
    return 1;
}