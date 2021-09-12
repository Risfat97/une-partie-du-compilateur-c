# une-partie-du-compilateur-c

On définit ici le langage K pour lequel on veut faire un compilateur: c’est un sous-ensemble simplifié du langage C, par exemple:
- pas de pointeurs/malloc/passage par adresse, ni de struct, 
- seul le type int est considéré
- pas de d'inclusion de librairie donc pas de printf, etc
- pas d'affectations multiples (var1 =  ... = varN = valeur;) seulement affectation simple (var = valeur)
- pas d'instruction return
- pas d'instruction conditionnelle simple (if(condition) { .. }) seulement un if suivi d'un else (if(condition) {...} else {...})
- 
La structure du code dans le langage K est la suivante:
### Déclaration de variables globales (optionnelle)
### Déclaration de fonctions: prototype (optionnelle) exemple: int somme(int a, int b);
### int main() {
      Liste d'instructions
### }
### Définition des fonctions déclarées

On souhaite reconnaitre un document source en langage K, et générer du pseudo-code assembleur correspondant.
Listes des instructions (sans leurs opérandes) :
- empiler : EMPG, EMPL, EMPC,
- dépiler : DEPG, DEPL
- opérations arith./bool. : ADD, SOUS, MUL, DIV, NON,
- opérateurs de comparaison : EGAL, INF, INFEG,
- opérateurs de sauts : SAUT, SIFAUX,
- opérations pour les fonctions : APPEL, ENTREE, SORTIE,
- (dé)allocation dans la pile : PILE

Mis en place d'une table des symboles pour rassemble toutes les informations utiles concernant les variables et les fonctions ou procédures du programme.
Elle grandit pendant la compilation des parties déclaratives :
- déclaration de variables,
- définition de fonctions.
Elle est consultée pendant la compilation des parties exécutables :
- appel de fonction,
- référence à une variable.

Pour lé génération de je simule une machine virtuelle à pile. Pour simplifier on ne génére pas opcode/opérande dans un fichier exécutable,
mais dans un tableau mem[TC] = Taille Code du fichier d'entrée: cela permet au besoin de réparer du code.
