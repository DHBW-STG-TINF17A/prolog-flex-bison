%{
#include "parser.tab.h"
%}

%option noyywrap

%%

\n     return EOL;
test   return test;

%%