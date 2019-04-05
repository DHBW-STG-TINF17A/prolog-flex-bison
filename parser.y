%{
	#include <stdio.h>
  #include <stdlib.h>
  #include <string.h>
	#include "parser.tab.h"

	int main(int argc, char **argv);
  void print_l(struct symbol *p);
  void yyerror(char*);
	int yylex();
	FILE *yyin;

  struct symbol {
    char *name;
    struct symbol *next;
  };

  struct symbol *create_new_list(char *str) {
    struct symbol *new = malloc(sizeof(struct symbol));
    new->next = NULL;
    new->name = malloc((strlen(str) + 1) * sizeof(char));
    strcpy(new->name, str);
    return new;
  }

  struct symbol *merge_list(struct symbol *p1, struct symbol *p2) {
    if (p1 == NULL) { return p2; }
    if (p2 == NULL) { return p1; }

    struct symbol *helper;
    char found;

    while (p2 != NULL) {
      helper = p1;
      found = 0;

      while (helper != NULL) {
        if (strcmp(p2->name, helper->name) == 0) {
          found = 1;
        }
        helper = helper->next;
      }
      helper = p2->next;

      if (!found) {
        p2->next = p1;
        p1 = p2;
      }

      p2 = helper;
    }
    return p1;
  }

%}

%union {
  struct symbol *smbl;
  char *ch;
}

%token <ch> atom variable numeral dot def com op cp ob cb vert
%type <smbl> FACT RULE TERM TERM_L LIST LITERAL LITERAL_L

%start S_L

%%

S_L: 	S S_L	{ ; }
	| 	S			{ ; }
	;

S: 		FACT { print_l($1); }
	|		RULE { print_l($1); }
	;

FACT:	LITERAL dot { $$ = $1; }
	;

RULE:	LITERAL def LITERAL_L dot { $$ = merge_list($1, $3); }
	;

LITERAL: 	atom op TERM_L cp { $$ = $3; }
	|				variable { $$ = create_new_list($1); }
	;

LITERAL_L:	LITERAL com LITERAL_L { $$ = merge_list($1, $3); }
	|					LITERAL { $$ = $1; }
	;

TERM_L:	TERM_L com TERM { $$ = merge_list($1, $3); }
	|			TERM { $$ = $1; }
	;

TERM: LIST { $$ = $1; }
  |   atom { $$ = NULL; }
  |   numeral { $$ = NULL; }
  ;

LIST:	ob TERM_L vert LIST cb { $$ = merge_list($2, $4); }
	|		ob TERM_L cb { $$ = $2 }
	|		ob cb { $$ = NULL; }
	|		variable { $$ = create_new_list($1); }
  ;	

%%

int main(int argc, char *argv[]) {	
  yyparse(); return 0;
}

void print_l(struct symbol *p) {
    printf("Recognized: ");
    while (p != NULL) {
      printf("%s, ", p->name);
      p = p->next;
    }
    printf("\n");
  }

void yyerror(char *err) {
	printf("%s",err);
}