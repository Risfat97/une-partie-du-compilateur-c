#include "tpK-tabSymbol.h" 
#include <stdio.h>      /* fprintf */
#include <stdlib.h>     /* EXIT_SUCCESS */
#include <string.h>	    /* strcmp */   

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

void ajoute_variable(char *identif){
	if(!existe(identif)){
		ajouterEntree(identif, contexte, typeVar, adrCourant[curseur]++, 0);
	}
}

int ajoute_fonction(char *identif, int nb_params){
	if(!existe(identif)){
		ajouterEntree(identif, C_FONCTION, typeVar, adrCourant[ADR_GLOB]++, nb_params);
		return 1;
	}
	return 0;
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
			case C_FONCTION: classe = "C_FONCTION";break;
			case C_GLOBAL: classe = "C_GLOBAL";break;
			case C_ARG: classe = "C_ARG";break;
			case C_LOCAL: classe = "C_LOCAL";break;
		}
		switch(tsymb[i].type) {
			case T_ENTIER: type = "T_ENTIER";break;
			case T_TABLEAU: type = "T_TABLEAU";break;
		}
		printf("Entrée : %s (%s, %s, %d, %d)\n", tsymb[i].identif, classe, type, \
			tsymb[i].adresse, tsymb[i].complement);
	}
	printf("\n----------------------\n\n");
}

void entree_fonction(){
	base = sommet;
}
void sortie_fonction(){
	afficheTSymb();
	sommet = base;
	base = 0;
	adrCourant[ADR_LOC] = 0;
}

void viderTSymb(){
	free(tsymb);
}

int recherche_executable(char *identif, int line){
	int i = sommet-1;
	while ( (i>=0) && (strcmp(identif,tsymb[i].identif)!=0) ){
		i=i-1; 
	}
	if(i >= 0)
		return 1;
	char msg[64];
	sprintf(msg, "%s:%d: error: '%s' undeclared", filename, line, identif);
	erreurFatale(msg);
	return 0;
}