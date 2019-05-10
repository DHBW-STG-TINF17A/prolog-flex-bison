%{
#define YYSTYPE char *

#include "parser.tab.h"
#include <stdio.h>
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

is                { return is; }

{atom}            { return atom; }
{variable}        { yylval = strdup(yytext); return variable; }
{numeral}         { return numeral; }

%.*\n             /* ignore comments */
[\t \n]+          /* ignore whitespace */

\.                { return dot; }
:-                { return def; }
,                 { return com; }

\(                { return op; }
\)                { return cp; }
\[                { return ob; }
\]                { return cb; }
\|                { return vert; }

\>                { return lt; }
\>=               { return lte; }
\<                { return st; }
\=<               { return ste; }

\=                { return eq; }
\==               { return eqeq; }
\\=               { return neq; }
\\==              { return neqeq; }

\+                { return plus; }
\-                { return minus; }
\*                { return times; }
\/                { return divby; }

.                 { printf("Cannot interpret '%s'\n", yytext); }
