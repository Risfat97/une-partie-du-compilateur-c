%{
    #include <stdio.h>
    #include "parseur.tab.h"
%}

NOMBRE          0|[1-9][0-9]*
OPERATEUR       [-+*/]
COMP            [!=<>](={0,1})
LOGIC_OP        (&&)|(\|\|)
%%

{OPERATEUR}     {printf("lex::OPERATEUR %s\n", yytext); return OPERATEUR;}
{LOGIC_OP}      {printf("lex::LOGIC_OP %s\n", yytext); return LOGIC_OP;}
{NOMBRE}        {printf("lex::NOMBRE %s\n", yytext); return NOMBRE;}
{COMP}          {printf("lex::COMP %s\n", yytext); return COMP;}

[ \t]           ;
\n              {return 0;}
.               {printf("lex::char %c\n", yytext[0]); return yytext[0];}

%%
 