#ifndef __TPK_TAB_SYMBOL_H__
#define __TPK_TAB_SYMBOL_H__

typedef struct { 	/* selon cm-table-symboles.pdf */
	char *identif; 	/* en général un léxème */
	int classe; 	/* C_FONCTION, ou contexte de variable : C_GLOBAL, C_ARG
, C_LOCAL */
	int type; 	/* source L : T_ENTIER, T_TABLEAU */
	int adresse; 
	int complement; /* ex.: nombre d'argument d'une fonction */
} ENTREE_TSYMB;

#define TAILLE_INITIALE_TSYMB	50 
#define INCREMENT_TAILLE_TSYMB	25

/* Variables globales */
ENTREE_TSYMB *tsymb; 
int maxTSymb, sommet, base;

/* prototypes */
void creerTSymb(void) ;
void agrandirTSymb(void) ;
int erreurFatale(char *message) ; 
void ajouterEntree(char *identif, int classe, int type, int adresse, int complement) ;
int existe(char * id);
void afficheTSymb(void) ;

#endif
