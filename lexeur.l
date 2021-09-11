%{
    #include "arbre-abstrait.h"
    #include "parseur.tab.h"
    #include <stdio.h>
    #include <stdlib.h>
%}

int_t           "int"
main_f          {int_t}{ws}+"main()"{ws}*
if_i            "if"
else_i          "else"
while_i         "while"
entier          0|[1-9][0-9]*
ws              [ \t]
nl              [\n]
ident           [a-zA-Z_]*[a-zA-Z]+[a-zA-Z0-9_]*
leq             "<="
eq              "=="
and             "&&"
or              "||"
%%

{or}                {printf("lex::OR %s\n", yytext); return OR;}
{and}               {printf("lex::AND %s\n", yytext); return AND;}
{leq}               {printf("lex::LEQ %s\n", yytext); return LEQ;}
{eq}                {printf("lex::EQ %s\n", yytext); return EQ;}
{if_i}              {printf("lex::IF %s\n", yytext); return IF;}
{int_t}             {printf("lex::INT %s\n", yytext); return INT;}
{else_i}            {printf("lex::ELSE %s\n", yytext); return ELSE;}
{while_i}           {printf("lex::WHILE %s\n", yytext); return WHILE;}
{main_f}            {printf("lex::MAIN %s\n", yytext); return MAIN;}
{entier}            {printf("lex::ENTIER %s\n", yytext); yylval.ival = atoi(yytext); return ENTIER;}
{ident}             {printf("lex::IDENT %s\n", yytext); strcpy(yylval.sval, yytext); return IDENT;}
{ws}                ;
{nl}                {yylineno++;}
.                   {printf("lex::char %c\n", yytext[0]); return yytext[0];}

%%
 