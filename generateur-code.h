#ifndef __GENERATEUR_CODE_H__
#define __GENERATEUR_CODE_H__

typedef enum {OPCODE_WITH_VALUE, OPCODE_WITHOUT_VALUE} flag_value_t;

typedef struct {
    char *opcode;
    int valeur;
    flag_value_t flag;
} data_t;

typedef struct {
	data_t *tcode;
    int taille_code;
    int taille_max;
} TAB_CODE;

#define INCREMENT_TAILLE_TCODE	32

/* Variables globales */
TAB_CODE mem;
int alpha, aReparer, aReparer1, aReparer2, aReparer3;

/* prototypes */
void creer_tab_code(void) ;
void agrandir_tab_code(void);
void ajouter_code(char *opcode, int valeur, flag_value_t flag);
void afficher_tab_code(void);
void vider_tab_code();
void reparer_code(int place, int valeur);


#endif
