#ifndef __TPK_TAB_SYMBOL_H__
#define __TPK_TAB_SYMBOL_H__

typedef enum {C_FONCTION, C_GLOBAL, C_ARG, C_LOCAL} classe_t;
typedef	enum {T_ENTIER, T_TABLEAU} type_t;
typedef enum {ADR_GLOB, ADR_LOC} curseur_adr_t;
typedef enum {PARAMS, ARGS} flag_fonction_t;

typedef struct { 	/* selon cm-table-symboles.pdf */
	char *identif; 	/* en général un léxème */
	classe_t classe;
	type_t type;
	int adresse; 
	int complement; /* ex.: nombre d'argument d'une fonction */
} ENTREE_TSYMB;

#define TAILLE_INITIALE_TSYMB	50 
#define INCREMENT_TAILLE_TSYMB	25

/* Variables globales */
ENTREE_TSYMB *tsymb; 
int maxTSymb, sommet, base;
int adrCourant[2];
classe_t contexte;
type_t typeVar;
curseur_adr_t curseur;
char filename[32];

/* prototypes */
void creerTSymb(void) ;
void agrandirTSymb(void) ;
int erreurFatale(char *message) ; 
void ajouterEntree(char *identif, int classe, int type, int adresse, int complement) ;
int existe(char * id);
void afficheTSymb(void);
void viderTSymb();
void entree_fonction();
void sortie_fonction();
void ajoute_variable(char *identif);
int ajoute_fonction(char *identif, int nb_params);
int recherche_executable(char *identif, int line);
void verifier_fonction(char *identif, int nb_args_ou_params, int nb_args_ou_params_calcule, int line, flag_fonction_t flag);

#endif
