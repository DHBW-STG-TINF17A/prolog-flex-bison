%{
#include "y.tab.h"
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

is                { yylval.ch="is"; return is; }

{atom}            { yylval.ch = strdup(yytext); return atom; }
{variable}        { yylval.ch = strdup(yytext); return variable; }
{numeral}         { yylval.ch = strdup(yytext); return numeral; }

%.*\n             /* ignore comments */
[\t \n]+          /* ignore whitespace */

\.                { return dot; }
:-                { return def; }
,                 { return com; }

\(                { yylval.ch="("; return op; }
\)                { yylval.ch=")";return cp; }
\[                { yylval.ch="[";return ob; }
\]                { yylval.ch="]";return cb; }
\|                { yylval.ch="|";return vert; }

\>                { yylval.ch=">";return lt; }
\>=               { yylval.ch=">=";return lte; }
\<                { yylval.ch="<";return st; }
\=<               { yylval.ch="=<";return ste; }

\=                { yylval.ch="=";return eq; }
\==               { yylval.ch="==";return eqeq; }
\\=               { yylval.ch="\\=";return neq; }
\\==              { yylval.ch="\\==";return neqeq; }

\+                { yylval.ch="+";return plus; }
\-                { yylval.ch="-";return minus; }
\*                { yylval.ch="*";return times; }
\/                { yylval.ch="/";return divby; }

.                 { printf("Cannot interpret '%s'\n", yytext); }
