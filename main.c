#include <stdio.h>
#include <stdlib.h>

int yyparse();

int main(int argc, char* argv[]){
    if(yyparse() == 0)
        printf("Analyse réussie\n");
    exit(EXIT_SUCCESS);
}