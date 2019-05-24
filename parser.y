%{
	#include <stdio.h>
  #include <stdlib.h>
  #include <string.h>
	#include "parser.tab.h"

	int main(void);
  void print_l(struct var_symbol *p);
  void yyerror(char*);
	int yylex();

  struct clause_group {
    char *name;
    int term_count;
    struct clause_group *next;
  };

  struct clause_symbol {
    struct literal_symbol *literal_list;
    struct clause_symbol *next;
  };

  struct literal_symbol {
    char *name;
    struct var_symbol *var_list;
    struct literal_symbol *next;
  };

  struct var_symbol {
    char *name;
    struct var_symbol *next;
  };

  struct var_symbol *create_new_list(char *str) {
    struct var_symbol *new = calloc(1, sizeof(struct var_symbol));
    new->next = NULL;
    new->name = strdup(str);
    return new;
  }

  struct var_symbol *merge_list(struct var_symbol *left, struct var_symbol *right) {
    if (left == NULL) { return right; }
    if (right == NULL) { return left; }

    struct var_symbol *left_end = left;
    while (left_end->next != NULL) {
      left_end = left_end->next;
    }

    struct var_symbol *right_element = right;
    while (right_element != NULL) {
      char duplicate = 0;

      struct var_symbol *left_element = left;
      while (left_element != NULL) {
        if (strcmp(left_element->name, right_element->name) == 0) {
          duplicate = 1;
          break;
        }

        left_element = left_element->next;
      }

      if (duplicate == 0) {
        left_end->next = right_element;
        left_end = right_element;
      }

      right_element = right_element->next;
    }

    return left;
  }

%}

%union {
  struct var_symbol *smbl;
  char *ch;
}

%token <ch> atom variable numeral dot def com op cp ob cb vert is
%type <smbl> FACT RULE TERM TERM_L OPERAND COMP ARITH LIST LITERAL LITERAL_L FUNCTION

%left lt lte st ste eq eqeq neq neqeq plus minus times divby

%start S_L

%debug
%initial-action {
  yydebug = 0;
}

%%

S_L: S_L S	{ ; }
	| S	{ ; }
	;

S: FACT { print_l($1); }
	|	RULE { print_l($1); }
	;

FACT:	LITERAL dot { $$ = $1; }
	;

RULE:	LITERAL def LITERAL_L dot { $$ = merge_list($1, $3); }
	;

LITERAL: atom op TERM_L cp { $$ = $3; }
  | ARITH { $$ = $1; }
  | COMP { $$ =$1; }
	| atom { $$ = NULL; }
  | variable is OPERAND { $$ = merge_list(create_new_list($1), $3); }
	;

LITERAL_L: LITERAL com LITERAL_L { $$ = merge_list($1, $3); }
	| LITERAL { $$ = $1; }
	;

TERM_L: TERM_L com TERM { $$ = merge_list($1, $3); }
	| TERM { $$ = $1; }
	;

TERM:   ARITH { $$ = $1; }
  | FUNCTION { $$ = $1; }
  | LIST { $$ = $1; }
  | COMP { $$ = $1; } 
  | atom { $$ = NULL; }
  | numeral { $$ = NULL; }
//  | variable { $$ = create_new_list($1); }
  ;

ARITH: OPERAND plus OPERAND { $$ = merge_list($1, $3); }
  | OPERAND minus OPERAND { $$ = merge_list($1, $3); }
  | OPERAND times OPERAND { $$ = merge_list($1, $3); }
  | OPERAND divby OPERAND { $$ = merge_list($1, $3); }
  | op ARITH cp { $$ = $2; }
  ;

COMP: OPERAND lt OPERAND { $$ = merge_list($1, $3); }
  | OPERAND lte OPERAND { $$ = merge_list($1, $3); }
  | OPERAND st OPERAND { $$ = merge_list($1, $3); }
  | OPERAND ste OPERAND { $$ = merge_list($1, $3); }
  | OPERAND eq OPERAND { $$ = merge_list($1, $3); }
  | OPERAND eqeq OPERAND { $$ = merge_list($1, $3); }
  | OPERAND neq OPERAND { $$ = merge_list($1, $3); }
  | OPERAND neqeq OPERAND { $$ = merge_list($1, $3); }
  ; 

OPERAND: ARITH { $$ = $1; } 
  | variable { $$ = create_new_list($1); }
  | numeral { $$ = NULL; }
  ;

LIST:	ob TERM_L vert LIST cb { $$ = merge_list($2, $4); }
	| ob TERM_L cb { $$ = $2; }
	|	ob cb { $$ = NULL; }
	|	variable { $$ = create_new_list($1); }
  ;

FUNCTION: atom op TERM_L cp { $$ = $3; }
  ;



%%

int main(void) {	
  yyparse();
  return 0;
}

void print_l(struct var_symbol *p) {
    printf("Recognized: ");
    while (p != NULL) {
      printf("%s", p->name);
      p = p->next;
      if (p != NULL) {
        printf(", ");
      }
    }
    printf("\n");
}

void yyerror(char *err) {
	printf("%s",err);
}