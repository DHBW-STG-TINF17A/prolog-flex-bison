%{
#include "parser.tab.h"
%}

%option noyywrap

lowercase_letter  [a-z]
uppercase_letter  [A-Z_]
digit             [0-9]
alphanum          {lowercase_letter}|{uppercase_letter}|{digit}

atom              {lowercase_letter}{alphanum}*
variable          {uppercase_letter}{alphanum}*
numeral           {digit}+(\.{digit}+)?

%%

{atom}            { return atom; }
{variable}        { return variable; }
{numeral}         { return numeral; }

\.                { return dot; }
:-                { return def; }
,                 { return com; }

\(                { return op; }
\)                { return cp; }
\[                { return ob; }
\]                { return cb; }
\|                { return vert; }

.                 { printf("Cannot interpret '%s'\n", yytext); }


%%