%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>

    void yyerror(const char*);
    int yylex();
%}

%code requires {
    struct node {
        union {
            int entier;
            double flottant;
            char lettre;
            char texte[32];
        } val;
        enum {INTTYPE, DOUBLETYPE, CHARTYPE, STRINGTYPE} id_type;
        struct node* left;
        struct node* right;
    };

    typedef struct node* Arbre;

    Arbre arbre_init();
    Arbre arbre_init_entier(int val);
    Arbre arbre_init_reel(double val);
    Arbre arbre_init_lettre(char val);
    Arbre arbre_init_texte(char val[32]);
    Arbre arbre_ajout_entier(int val, Arbre fg, Arbre fd);
    Arbre arbre_ajout_reel(double val, Arbre fg, Arbre fd);
    Arbre arbre_ajout_lettre(char val, Arbre fg, Arbre fd);
    Arbre arbre_ajout_texte(char val[32], Arbre fg, Arbre fd);
    void afficher_arbre(Arbre arbre);
}

%union {double dval; int ival; char sval[32]; Arbre arbre;}
%token LEQ EQ AND OR INT FLOAT DOUBLE CHAR IF ELSE WHILE
%token <sval> IDENT
%token <ival> ENTIER 
%token <dval> REEL
%type <arbre> resultat EXPRESSION_AR EXPRESSION_BOOL TERME FACTEUR CONDITION AUTRE_CONDITION
%left '+' '-'
%left '*' '/'
%nonassoc MOINSU PLUSU
%start main /* axiom */

%%

main: DECLARATION
    | LISTE_INSTR
    | DECLARATION LISTE_INSTR
    | resultat                          {afficher_arbre($1); printf("\n");}
    ;

resultat: EXPRESSION_AR                 {$$ = $1;}
    | EXPRESSION_BOOL                   {$$ = $1;}
    ;

EXPRESSION_AR: EXPRESSION_AR '+' TERME  {$$ = arbre_ajout_lettre('+', $1, $3);}
    | EXPRESSION_AR '-' TERME           {$$ = arbre_ajout_lettre('-', $1, $3);}
    | TERME                             {$$ = $1;}
    ;

TERME: TERME '*' FACTEUR                {$$ = arbre_ajout_lettre('*', $1, $3);}
    | TERME '/' FACTEUR                 {$$ = arbre_ajout_lettre('/', $1, $3);}
    | FACTEUR                           {$$ = $1;}
    ;

FACTEUR: '(' EXPRESSION_AR ')'          {$$ = $2;}
    | '-' FACTEUR %prec MOINSU          {$$ = arbre_ajout_lettre('-', $2, NULL);}
    | '+' FACTEUR %prec PLUSU           {$$ = arbre_ajout_lettre('+', $2, NULL);}
    | ENTIER                            {$$ = arbre_init_entier($1);}
    | REEL                              {$$ = arbre_init_reel($1);}
    | IDENT                             {$$ = arbre_init_texte($1);}
    | IDENT '(' ARGUMENTS ')'           {$$ = NULL;}
    ;

ARGUMENTS: resultat ',' ARGUMENTS
    | resultat
    | VIDE
    ;

VIDE: ;

EXPRESSION_BOOL: EXPRESSION_BOOL  AND CONDITION {$$ = arbre_ajout_texte("&&", $1, $3);}
    | EXPRESSION_BOOL OR CONDITION              {$$ = arbre_ajout_texte("||", $1, $3);}
    | CONDITION                                 {$$ = $1;}
    ;

CONDITION: CONDITION '<' AUTRE_CONDITION        {$$ = arbre_ajout_lettre('<', $1, $3);}
    | CONDITION LEQ AUTRE_CONDITION             {$$ = arbre_ajout_texte("<=", $1, $3);}
    | CONDITION EQ AUTRE_CONDITION              {$$ = arbre_ajout_texte("==", $1, $3);}
    | CONDITION '+' AUTRE_CONDITION             {$$ = arbre_ajout_lettre('+', $1, $3);}
    | CONDITION '-' AUTRE_CONDITION             {$$ = arbre_ajout_lettre('-', $1, $3);}
    | CONDITION '*' AUTRE_CONDITION             {$$ = arbre_ajout_lettre('*', $1, $3);}
    | CONDITION '/' AUTRE_CONDITION             {$$ = arbre_ajout_lettre('/', $1, $3);}
    | AUTRE_CONDITION                           {$$ = $1;}
    ;

AUTRE_CONDITION: '(' EXPRESSION_BOOL ')'        {$$ = $2;}
    | '!' AUTRE_CONDITION                       {$$ = arbre_ajout_lettre('!', $2, NULL);}
    | EXPRESSION_AR                             {$$ = $1;}
    ;

DECLARATION: INT IDENT ';'
    | FLOAT IDENT ';'
    | DOUBLE IDENT ';'
    | CHAR IDENT ';'
    ;

INSTRUCTION: ';'
    | IDENT '=' resultat ';'
    | INSTRUCTION '\n'
    ;

LISTE_INSTR: INSTRUCTION
    | INSTRUCTION INSTRUCTION
    | BLOC
    | IF_INST
    | IF_ELSE
    | BOUCLE
    | LISTE_INSTR LISTE_INSTR
    ;

BLOC: '{' '}'
    | '{' LISTE_INSTR '}'
    | '{' BLOC '}'
    ;

IF_INST: IF '(' EXPRESSION_BOOL ')' LISTE_INSTR
    ;

ELSE_INST: ELSE LISTE_INSTR
    ;

IF_ELSE: IF_INST ELSE_INST
    ;

BOUCLE: WHILE '(' EXPRESSION_BOOL ')' LISTE_INSTR
    ;
%%

void yyerror(const char* err){
    fprintf(stderr, "erreur de syntaxe\n");
}

int yywrap(){
    return 1;
}

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