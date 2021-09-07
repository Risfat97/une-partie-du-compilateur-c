%{
    #include <stdio.h>
    #include <stdlib.h>
    void yyerror(const char*);
    int yylex();
%}

%token ENTIER REEL IDENT LEQ EQ AND OR INT FLOAT DOUBLE CHAR IF ELSE WHILE
%left '+' '-'
%left '*' '/'
%nonassoc MOINSU PLUSU
%start main /* axiom */

%%

main: DECLARATION
    | LISTE_INSTR
    | DECLARATION LISTE_INSTR
    ;

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
    | ENTIER
    | REEL
    | IDENT
    | IDENT '(' ARGUMENTS ')'
    ;

ARGUMENTS: resultat ',' ARGUMENTS
    | resultat
    | VIDE
    ;

VIDE: ;

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