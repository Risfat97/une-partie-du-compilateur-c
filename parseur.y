%{
    #include "tpK-tabSymbol.h"
    #include "arbre-abstrait.h"
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>

    extern int yylineno;
    int nbParams = 0, nbArgs = 0, adrSave, returnToADrSave = 0;
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

DECLARATIONS: DECLARATION
    | DECLARATION DECLARATIONS
    ;

DECLARATION: PROTOTYPE 
    | INT IDENT ';'
        {
            contexte = C_GLOBAL;
            curseur = ADR_GLOB;
            ajoute_variable($2);
        }
    ;

PROTOTYPE: INT IDENT 
        {
            adrSave = sommet;
            returnToADrSave = ajoute_fonction($2, 0);
        }
     SUITE_DEC_FUNC  
        {
            if(returnToADrSave)
                tsymb[adrSave].complement = nbParams;
        } ';' 
    ;

SUITE_DEC_FUNC: '(' ')' {nbParams = 0;}
    |  '(' 
        { 
            contexte = C_LOCAL;
            curseur = ADR_LOC;
            nbParams = 0;
        } 
    LISTE_PARAM ')' {contexte = C_GLOBAL;}
    ;

DEFINITIONS: MAIN 
        {
            contexte = C_FONCTION; 
            curseur = ADR_GLOB;
            ajoute_variable("main"); 
            entree_fonction(); 
            contexte = C_LOCAL; 
            curseur = ADR_LOC;
        } 
    BLOC 
        {
            sortie_fonction();
        } 
    LISTE_DEF_FUNC
    | MAIN 
        {
            contexte = C_FONCTION; 
            curseur = ADR_GLOB;
            ajoute_variable("main"); 
            entree_fonction(); 
            contexte = C_LOCAL; 
            curseur = ADR_LOC;
        } 
    BLOC 
        {
            sortie_fonction();
        }
    ;

LISTE_PARAM: INT IDENT 
        {
            nbParams++;
            contexte = C_LOCAL;
            curseur = ADR_LOC;
            ajoute_variable($2);    
        } 
    ',' LISTE_PARAM
    | INT IDENT 
        {
            nbParams++;
            contexte = C_LOCAL;
            curseur = ADR_LOC;
            ajoute_variable($2);    
        }
    ;

BLOC: '{' LISTE_INSTR '}'
    | '{' BLOC '}'
    | '{' '}'
    ;

LISTE_DEF_FUNC:  DEFINITION_FUNC LISTE_DEF_FUNC
    | DEFINITION_FUNC
    |
    ;

DEFINITION_FUNC: INT IDENT 
        {
            entree_fonction();
        }
    SUITE_DEC_FUNC 
        {
            int tmp = recherche_executable($2, yylineno);
            verifier_fonction($2, tsymb[tmp].complement, nbParams, yylineno, PARAMS);
        } 
    BLOC 
        {
            sortie_fonction();
        }
    ;

LISTE_INSTR: INSTRUCTION LISTE_INSTR
    | INSTRUCTION
    ;

INSTRUCTION: ';'
    | INT IDENT  ';' 
        {
            contexte = C_LOCAL;
            curseur = ADR_LOC;
            ajoute_variable($2);
        }
    | IDENT 
        {
            recherche_executable($1, yylineno);
        } 
    '=' EXPRESSION ';'
    | APPEL_FUNC ';'
    | IF_ELSE
    | BOUCLE
    | BLOC
    ;

IF_ELSE: IF '(' EXPRESSION_BOOL ')' LISTE_INSTR ELSE LISTE_INSTR
    ;

BOUCLE: WHILE '(' EXPRESSION_BOOL ')' LISTE_INSTR
    ;

main: INSTRUCTION
    | EXPRESSION ';' {
        printf("\nArbre syntaxique abstrait correspondant: \n"); 
        afficher_arbre($1); printf("\n"); 
        arbre_vider($1);
    }
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
    | IDENT 
        {
            if(recherche_executable($1, yylineno) != -1)
                $$ = arbre_init_texte($1);
            else 
                $$ = NULL;
        }
    | APPEL_FUNC                        {$$ = NULL;}
    ;

APPEL_FUNC: IDENT  '(' ')' {nbArgs = 0;}
        {
            $$ = NULL;
            recherche_executable($1, yylineno);
        }
    | IDENT '(' 
        {
            nbArgs = 0;
        }    
    ARGUMENTS ')'
        {
            $$ = NULL;
            int tmp = recherche_executable($1, yylineno);
            if(tmp != -1){
                verifier_fonction($1, tsymb[tmp].complement, nbArgs, yylineno, ARGS);
            }
        }
    ;

ARGUMENTS: EXPRESSION {nbArgs++;} ',' ARGUMENTS
    | EXPRESSION {nbArgs++;}
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