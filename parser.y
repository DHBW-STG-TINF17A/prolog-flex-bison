%{
	#include <stdio.h>
	#include "parser.tab.h"

	int main(int argc, char **argv);
  void yyerror(char*);
	int yylex();
	FILE *yyin;
%}

%token EOL
%token test

%start S

%%
S: test EOL { printf("Test passed.\n"); }
| S test EOL { printf("Test passed.\n"); }
;

%%
int main(int argc, char *argv[])
{	
  yyparse();
}
void yyerror(char *err) {
	printf("%s",err);
}