%{
    #include <stdio.h>
    #include <stdlib.h>
    #include "parseur.tab.h"
%}

int_t           "int"
double_t        "double"
float_t         "float"
char_t          "char"
void_t          "void"
main_f          "int"{ws}+"main()"{ws}*
if_i            "if"
else_i          "else"
while_i         "while"
entier          0|[1-9][0-9]*
reel            {entier}\.{entier}+
ws              [ \t]
nl              [\n]
ident           [_]{0,2}([a-zA-Z]|[a-zA-Z][a-zA-Z0-9_]+('_'{0,1}[a-zA-Z0-9_]+)*)[_]{0,2}
leq             "<="
eq              "=="
and             "&&"
or              "||"
parenth_o_f     "()"
%%

{or}                {printf("lex::OR %s\n", yytext); return OR;}
{and}               {printf("lex::AND %s\n", yytext); return AND;}
{leq}               {printf("lex::LEQ %s\n", yytext); return LEQ;}
{eq}                {printf("lex::EQ %s\n", yytext); return EQ;}
{parenth_o_f}       {printf("lex::PARENTH_O_F %s\n", yytext); return PARENTH_O_F;}
{if_i}              {printf("lex::IF %s\n", yytext); return IF;}
{int_t}             {printf("lex::INT %s\n", yytext); return INT;}
{char_t}            {printf("lex::CHAR %s\n", yytext); return CHAR;}
{void_t}            {printf("lex::VOID %s\n", yytext); return VOID;}
{else_i}            {printf("lex::ELSE %s\n", yytext); return ELSE;}
{float_t}           {printf("lex::FLOAT %s\n", yytext); return FLOAT;}
{while_i}           {printf("lex::WHILE %s\n", yytext); return WHILE;}
{double_t}          {printf("lex::DOUBLE %s\n", yytext); return DOUBLE;}
{main_f}            {printf("lex::MAIN %s\n", yytext); return MAIN;}
{entier}            {printf("lex::ENTIER %s\n", yytext); yylval.ival = atoi(yytext); return ENTIER;}
{reel}              {printf("lex::REEL %s\n", yytext); yylval.dval = atof(yytext); return REEL;}
{ident}             {printf("lex::IDENT %s\n", yytext); strcpy(yylval.sval, yytext); return IDENT;}
({ws}|{nl})         ;
.                   {printf("lex::char %c\n", yytext[0]); return yytext[0];}

%%
 