#ifndef __ARBRE_ABSTRAIT_H__
#define __ARBRE_ABSTRAIT_H__

struct node {
    union {
        int entier;
        char lettre;
        char texte[32];
    } val;
    enum {INTTYPE, CHARTYPE, STRINGTYPE} id_type;
    struct node* left;
    struct node* right;
};

typedef struct node* Arbre;

Arbre arbre_init();
Arbre arbre_init_entier(int val);
Arbre arbre_init_lettre(char val);
Arbre arbre_init_texte(char val[32]);
Arbre arbre_ajout_entier(int val, Arbre fg, Arbre fd);
Arbre arbre_ajout_lettre(char val, Arbre fg, Arbre fd);
Arbre arbre_ajout_texte(char val[32], Arbre fg, Arbre fd);
void arbre_vider(Arbre arbre);
void afficher_arbre(Arbre arbre);


#endif
