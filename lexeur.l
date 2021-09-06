%{
    #include <stdio.h>
    #include "parseur.tab.h"
%}

entier          0|[1-9][0-9]*
ws              [ \t]
nl              [\n]
ident           [_]{0,2}([a-zA-Z]|[a-zA-Z][a-zA-Z0-9_]+('_'{0,1}[a-zA-Z0-9_]+)*)[_]{0,2}
leq             "<="
eq              "=="
and             "&&"
or              "||"
%%

{entier}            {printf("lex::NOMBRE %s\n", yytext); return NOMBRE;}
{ident}             {printf("lex::IDENT %s\n", yytext); return IDENT;}
{and}               {printf("lex::AND %s\n", yytext); return AND;}
{or}               {printf("lex::OR %s\n", yytext); return OR;}
{leq}               {printf("lex::LEQ %s\n", yytext); return LEQ;};
{eq}                {printf("lex::EQ %s\n", yytext); return EQ;};
{ws}                ;
{nl}                {return 0;}
.                   {printf("lex::char %c\n", yytext[0]); return yytext[0];}

%%
 