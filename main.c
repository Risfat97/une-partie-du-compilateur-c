#include "tpK-tabSymbol.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int yyparse();

int main(int argc, char* argv[]){
    extern FILE *yyin;
    if(argc > 1){
        yyin = fopen(argv[1], "r");
        if(yyin)
            strcpy(filename, argv[1]);
    }
    adrCourant[ADR_GLOB] = adrCourant[ADR_LOC] = 0;
    typeVar = T_ENTIER;
    contexte = C_GLOBAL;
    creerTSymb();
    if(yyparse() == 0)
        printf("Analyse réussie\n");
    afficheTSymb();
    viderTSymb();
    exit(EXIT_SUCCESS);
}