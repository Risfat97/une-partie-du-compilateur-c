%{
    #include <stdio.h>
    #include <stdlib.h>
    int yyerror(const char* err);
    int yylex();
%}

%token NOMBRE OPERATEUR COMP LOGIC_OP
%start resultat /* axiom */

%%
resultat: EXPRESSION_AR
    | EXPRESSION_BOOL
    ;

EXPRESSION_AR: EXPRESSION_AR OPERATEUR EXPRESSION_AR
    | '-' NOMBRE
    | '+' NOMBRE
    | NOMBRE
    | '(' EXPRESSION_AR ')'
    ;

EXPRESSION_BOOL: EXPRESSION_BOOL  LOGIC_OP EXPRESSION_BOOL
    | '!' EXPRESSION_BOOL
    | '(' EXPRESSION_BOOL ')'
    | EXPRESSION_BOOL COMP EXPRESSION_BOOL
    | EXPRESSION_BOOL OPERATEUR EXPRESSION_BOOL
    | EXPRESSION_AR OPERATEUR EXPRESSION_BOOL
    | EXPRESSION_BOOL OPERATEUR EXPRESSION_AR
    | EXPRESSION_AR COMP EXPRESSION_BOOL
    | EXPRESSION_BOOL COMP EXPRESSION_AR
    | EXPRESSION_AR COMP EXPRESSION_AR
    | EXPRESSION_AR
    ;

%%

int yyerror(const char* err){
    fprintf(stderr, "erreur de syntaxe\n");
    return 1;
}


int yywrap(){
    return 1;
}