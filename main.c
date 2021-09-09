#include <stdio.h>
#include <stdlib.h>
#include "tpK-tabSymbol.h"

int yyparse();

int main(int argc, char* argv[]){
    creerTSymb();
    if(yyparse() == 0)
        printf("Analyse réussie\n");
    afficheTSymb();
    viderTSymb();
    exit(EXIT_SUCCESS);
}