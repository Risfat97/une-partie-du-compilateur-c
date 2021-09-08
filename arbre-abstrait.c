#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "arbre-abstrait.h"


Arbre arbre_init(){
    Arbre t = (Arbre)malloc(sizeof(struct node));
    return t;
}
Arbre arbre_init_entier(int val){
    Arbre t = arbre_init();
    if(t){
        t->val.entier = val;
        t->id_type = INTTYPE;
        t->left = t->right = NULL;
    }
    return t;
}
Arbre arbre_init_reel(double val){
    Arbre t = arbre_init();
    if(t){
        t->val.flottant = val;
        t->id_type = DOUBLETYPE;
        t->left = t->right = NULL;
    }
    return t;
}
Arbre arbre_init_lettre(char val){
    Arbre t = arbre_init();
    if(t){
        t->val.lettre = val;
        t->id_type = CHARTYPE;
        t->left = t->right = NULL;
    }
    return t;
}
Arbre arbre_init_texte(char val[32]){
    Arbre t = arbre_init();
    if(t){
        strcpy(t->val.texte, val);
        t->id_type = STRINGTYPE;
        t->left = t->right = NULL;
    }
    return t;
}
Arbre arbre_ajout_entier(int val, Arbre fg, Arbre fd){
    Arbre t = arbre_init_entier(val);
    if(t){
        t->left = fg;
        t->right = fd;
    }
    return t;
}
Arbre arbre_ajout_reel(double val, Arbre fg, Arbre fd){
    Arbre t = arbre_init_reel(val);
    if(t){
        t->left = fg;
        t->right = fd;
    }
    return t;
}
Arbre arbre_ajout_lettre(char val, Arbre fg, Arbre fd){
    Arbre t = arbre_init_lettre(val);
    if(t){
        t->left = fg;
        t->right = fd;
    }
    return t;
}
Arbre arbre_ajout_texte(char val[32], Arbre fg, Arbre fd){
    Arbre t = arbre_init_texte(val);
    if(t){
        t->left = fg;
        t->right = fd;
    }
    return t;
}

void afficher_arbre(Arbre arbre){
    if(arbre){
        printf("[ ");
        afficher_arbre(arbre->left);
        if(arbre->id_type == INTTYPE){
            printf("%d ", arbre->val.entier);
        } else if(arbre->id_type == DOUBLETYPE){
            printf("%lf ", arbre->val.flottant);
        } else if(arbre->id_type == CHARTYPE){
            printf("%c ", arbre->val.lettre);
        } else {
            printf("%s ", arbre->val.texte);
        }
        afficher_arbre(arbre->right);
        printf("] ");
    }
}