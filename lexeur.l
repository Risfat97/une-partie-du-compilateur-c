%{
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

{or}                {return OR;}
{and}               {return AND;}
{leq}               {return LEQ;}
{eq}                {return EQ;}
{if_i}              {return IF;}
{int_t}             {return INT;}
{else_i}            {return ELSE;}
{while_i}           {return WHILE;}
{main_f}            {return MAIN;}
{entier}            {yylval.ival = atoi(yytext); return ENTIER;}
{ident}             {strcpy(yylval.sval, yytext); return IDENT;}
{ws}                ;
{nl}                {yylineno++;}
.                   {return yytext[0];}

%%
 