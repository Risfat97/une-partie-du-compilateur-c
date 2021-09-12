%{
    #include "tpK-tabSymbol.h"
    #include "generateur-code.h"
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

%union {int ival; char sval[32];}
%token LEQ EQ AND OR INT IF ELSE WHILE MAIN
%token <sval> IDENT
%token <ival> ENTIER
%left '+' '-'
%left '*' '/'
%nonassoc MOINSU PLUSU
%start program /* axiom */

%%

program: DECLARATIONS DEFINITIONS
    | DEFINITIONS
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
    | IDENT '=' EXPRESSION ';'
        {
            int tmp = recherche_executable($1, yylineno);
            if(tmp != -1){
                if(tsymb[tmp].classe == C_GLOBAL)
                    ajouter_code("DEPL", tsymb[tmp].adresse, OPCODE_WITH_VALUE);
                else
                    ajouter_code("DEPG", tsymb[tmp].adresse, OPCODE_WITH_VALUE);
            }
        }
    | APPEL_FUNC ';'
    | IF_ELSE
    | BOUCLE
    | BLOC
    ;

IF_ELSE: IF '(' EXPRESSION_BOOL ')' 
        {
            ajouter_code("SIFAUX", 0, OPCODE_WITH_VALUE);
            aReparer1 = mem.taille_code - 1;
        } 
    INSTRUCTION 
        {
            ajouter_code("SAUT", 0, OPCODE_WITH_VALUE);
            aReparer2 = mem.taille_code - 1;
            reparer_code(aReparer1, mem.taille_code);
        }
    ELSE INSTRUCTION
        {
            reparer_code(aReparer2, mem.taille_code);
        }
    ;

BOUCLE: WHILE '(' 
        {
            alpha = mem.taille_code;
        } 
    EXPRESSION_BOOL 
        {
            ajouter_code("SIFAUX", 0, OPCODE_WITH_VALUE);
            aReparer = mem.taille_code - 1;
        }
    ')' INSTRUCTION
        {
            ajouter_code("SAUT", alpha, OPCODE_WITH_VALUE);
            reparer_code(alpha, mem.taille_code);
        }
    ;

EXPRESSION: EXPRESSION_AR
    | EXPRESSION_BOOL
    ;

EXPRESSION_AR: TERME '+' EXPRESSION_AR
        {
            ajouter_code("ADD", -1, OPCODE_WITHOUT_VALUE);
        }
    | TERME  '-' EXPRESSION_AR
        {
            ajouter_code("SOUS", -1, OPCODE_WITHOUT_VALUE);
        }
    | TERME
    ;

TERME: FACTEUR '*' TERME
        {
            ajouter_code("MUL", -1, OPCODE_WITHOUT_VALUE);
        }
    | FACTEUR '/' TERME
        {
            ajouter_code("DIV", -1, OPCODE_WITHOUT_VALUE);
        }
    | FACTEUR
    ;

FACTEUR: '(' EXPRESSION_AR ')'
    | '-' FACTEUR %prec MOINSU
        {
            ajouter_code("SOUS_U", -1, OPCODE_WITHOUT_VALUE);
        }
    | '+' FACTEUR %prec PLUSU
        {
            ajouter_code("ADD_U", -1, OPCODE_WITHOUT_VALUE);
        }
    | ENTIER
        {
            ajouter_code("EMPC", $1, OPCODE_WITH_VALUE);
        }
    | IDENT 
        {
            int tmp = recherche_executable($1, yylineno); 
            if(tmp != -1){
                if(tsymb[tmp].classe == C_GLOBAL)
                    ajouter_code("EMPG", tsymb[tmp].adresse, OPCODE_WITH_VALUE);
                else
                    ajouter_code("EMPL", tsymb[tmp].adresse, OPCODE_WITH_VALUE);
            }
        }
    | APPEL_FUNC
    ;

APPEL_FUNC: IDENT  '(' ')' {nbArgs = 0;}
        {
            int tmp = recherche_executable($1, yylineno);
            if(tmp != -1){
                ajouter_code("PILE", 1, OPCODE_WITH_VALUE);
                ajouter_code("APPEL", tsymb[tmp].adresse, OPCODE_WITH_VALUE);
                ajouter_code("PILE", -1, OPCODE_WITH_VALUE);
            }
        }
    | IDENT '(' 
        {
            nbArgs = 0;
            if(recherche_executable($1, yylineno) != -1)
                ajouter_code("PILE", 1, OPCODE_WITH_VALUE);
        }    
    ARGUMENTS ')'
        {
            int tmp = recherche_executable($1, yylineno);
            if(tmp != -1){
                verifier_fonction($1, tsymb[tmp].complement, nbArgs, yylineno, ARGS);
                ajouter_code("APPEL", tsymb[tmp].adresse, OPCODE_WITH_VALUE);
                ajouter_code("Pile", -1 * nbArgs, OPCODE_WITH_VALUE);
            }
        }
    ;

ARGUMENTS: EXPRESSION {nbArgs++;} ',' ARGUMENTS
    | EXPRESSION {nbArgs++;}
    ;

EXPRESSION_BOOL: CONDITION AND EXPRESSION_BOOL
        {
            ajouter_code("ET", -1, OPCODE_WITHOUT_VALUE);
            
        }
    | CONDITION OR EXPRESSION_BOOL
        {
            ajouter_code("OU", -1, OPCODE_WITHOUT_VALUE);
        }
    | '(' EXPRESSION_BOOL ')'
    | CONDITION
    ;

CONDITION: AUTRE_CONDITION '<' CONDITION
        {
            ajouter_code("INF", -1, OPCODE_WITHOUT_VALUE);
        }
    | AUTRE_CONDITION LEQ CONDITION
        {
            ajouter_code("INFEG", -1, OPCODE_WITHOUT_VALUE);
        }
    | AUTRE_CONDITION EQ CONDITION
        {
            ajouter_code("EGAL", -1, OPCODE_WITHOUT_VALUE);
        }
    | AUTRE_CONDITION '+' CONDITION
        {
            ajouter_code("ADD", -1, OPCODE_WITHOUT_VALUE);
        }
    | AUTRE_CONDITION '-' CONDITION
        {
            ajouter_code("SOUS", -1, OPCODE_WITHOUT_VALUE);
        }
    | AUTRE_CONDITION '*' CONDITION
        {
            ajouter_code("MUL", -1, OPCODE_WITHOUT_VALUE);
        }
    | AUTRE_CONDITION '/' CONDITION
        {
            ajouter_code("DIV", -1, OPCODE_WITHOUT_VALUE);
        }
    | AUTRE_CONDITION
    ;

AUTRE_CONDITION: '!' AUTRE_CONDITION 
        {
            ajouter_code("NOT", -1, OPCODE_WITHOUT_VALUE);
        }
    | EXPRESSION_AR
    ;

%%

void yyerror(const char* err){
    fprintf(stderr, "%s\n", err);
}

int yywrap(){
    return 1;
}