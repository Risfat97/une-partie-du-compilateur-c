#include "generateur-code.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void creer_tab_code(){
    mem.taille_max = 64;
    mem.taille_code = 0;
    mem.tcode = (data_t*)malloc(64 * sizeof(data_t));
    if(mem.tcode == NULL){
        fprintf(stderr, "Erreur fonction creer_tab_code (pas assez de memoire)");
        exit(EXIT_FAILURE);
    }
}

void agrandir_tab_code(){
    mem.taille_max += INCREMENT_TAILLE_TCODE; 
    mem.tcode = realloc(mem.tcode, mem.taille_max);
    if(mem.tcode){
        fprintf(stderr, "Erreur fonction agrandirTSymb (pas assez de memoire)");
        exit(EXIT_FAILURE);
    } 
}

void ajouter_code(char *opcode, int valeur, flag_value_t flag){
    if(mem.taille_code >= mem.taille_max)
        agrandir_tab_code();

    mem.tcode[mem.taille_code].opcode = malloc(strlen(opcode) + 1);
    strcpy(mem.tcode[mem.taille_code].opcode, opcode);
    mem.tcode[mem.taille_code].flag = flag;
    if(flag == OPCODE_WITH_VALUE)
        mem.tcode[mem.taille_code].valeur = valeur;
    mem.taille_code++;
}

void afficher_tab_code(){
    int i = 0;
    printf("\n--- Code généré : (taille code: %d) ---\n\n", mem.taille_code);
    while(i < mem.taille_code){
        if(mem.tcode[i].flag == OPCODE_WITH_VALUE)
            printf("\tCode:%d\t\t%s\t%d\n", i, mem.tcode[i].opcode, mem.tcode[i].valeur);
        else
            printf("\tCode:%d\t\t%s\n", i, mem.tcode[i].opcode);
        i++;
    }
    printf("\n----------------------\n\n");
}

void vider_tab_code(){
    int i = 0;
    while(i < mem.taille_code){
        free(mem.tcode[i].opcode);
        i++;
    } 
    free(mem.tcode);
}

void reparer_code(int place, int valeur){
    mem.tcode[place].valeur = valeur;
}