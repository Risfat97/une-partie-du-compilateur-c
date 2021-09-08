#include <stdio.h>      /* fprintf */
#include <stdlib.h>     /* EXIT_SUCCESS */
#include <string.h>	    /* strcmp */
#include "tpK-tabSymbol.h"

/* prototypes */
//void creerTSymb(void) ;
//void agrandirTSymb(void) ;
//int erreurFatale(char *message) ; 
//void ajouterEntree(char *identif, int classe, int type, int adresse, int complement) ;
//int existe(char * id);
//void afficheTSymb(void) ;
    

/* definitions */
int erreurFatale(char *message) { 
	fprintf(stderr, "%s\n", message); 
	exit(-1);
}

void creerTSymb(void) { 
	maxTSymb = TAILLE_INITIALE_TSYMB; 
	tsymb = malloc(maxTSymb * sizeof(ENTREE_TSYMB)); 
	if (tsymb == NULL)
		erreurFatale("Erreur fonction creerTSymb (pas assez de memoire)"); 
	sommet = 0;
	base = 0;
}

void agrandirTSymb(void) { 
	maxTSymb = maxTSymb + INCREMENT_TAILLE_TSYMB; 
	tsymb = realloc(tsymb, maxTSymb); 
	if (tsymb == NULL)
		erreurFatale("Erreur fonction agrandirTSymb (pas assez de memoire)");
}

void ajouterEntree(char *identif, int classe, int type, int adresse, int complement) { 
	if (sommet >= maxTSymb)
		agrandirTSymb();
	tsymb[sommet].identif = malloc(strlen(identif) + 1); 
	if (tsymb[sommet].identif == NULL)
		erreurFatale("Erreur fonction ajouterEntree (pas assez de memoire)"); 
	strcpy(tsymb[sommet].identif, identif); 
	tsymb[sommet].classe = classe; 
	tsymb[sommet].type = type; 
	tsymb[sommet].adresse = adresse;
	tsymb[sommet].complement = complement; 
	sommet++;
}

int existe(char * id){
	int i = sommet-1;
	while ( (i>=base) && (strcmp(id,tsymb[i].identif)!=0) ){
		i=i-1; 
	}
	return (i>=base);
}

void afficheTSymb(void) {
	int i;
	char* classe;
	char* type;
	
	printf("\n--- Contenu Table des Symboles : ---\n\n");
	for(i=base;i<sommet;i++) {
		switch(tsymb[i].classe) {
			case 0: classe = "C_FONCTION";break;
			case 1: classe = "C_GLOBAL";break;
			case 2: classe = "C_ARG";break;
			case 3: classe = "C_LOCAL";break;
		}
		switch(tsymb[i].type) {
			case 0: type = "T_ENTIER";break;
			case 1: type = "T_TABLEAU";break;
		}
		printf("Entrée : %s (%s, %s, %d, %d)\n", tsymb[i].identif, classe, type, \
			tsymb[i].adresse, tsymb[i].complement);
	}
	printf("\n----------------------\n\n");
}
