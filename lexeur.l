%{
    #include <stdio.h>
    #include "parseur.tab.h"
%}

int_t           "int"
double_t        "double"
float_t         "float"
char_t          "char"
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
%%

{int_t}             {printf("lex::INT %s\n", yytext); return INT;}
{double_t}          {printf("lex::DOUBLE %s\n", yytext); return DOUBLE;}
{float_t}           {printf("lex::FLOAT %s\n", yytext); return FLOAT;}
{char_t}            {printf("lex::CHAR %s\n", yytext); return CHAR;}
{if_i}              {printf("lex::IF %s\n", yytext); return IF;}
{else_i}            {printf("lex::ELSE %s\n", yytext); return ELSE;}
{while_i}           {printf("lex::WHILE %s\n", yytext); return WHILE;}
{reel}              {printf("lex::REEL %s\n", yytext); return REEL;}
{entier}            {printf("lex::ENTIER %s\n", yytext); return ENTIER;}
{ident}             {printf("lex::IDENT %s\n", yytext); return IDENT;}
{and}               {printf("lex::AND %s\n", yytext); return AND;}
{or}                {printf("lex::OR %s\n", yytext); return OR;}
{leq}               {printf("lex::LEQ %s\n", yytext); return LEQ;};
{eq}                {printf("lex::EQ %s\n", yytext); return EQ;};
{ws}                ;
{nl}                ;
.                   {printf("lex::char %c\n", yytext[0]); return yytext[0];}

%%
 