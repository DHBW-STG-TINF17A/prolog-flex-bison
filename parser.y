%{
  #define _GNU_SOURCE
	#include <stdio.h>
  #include <stdlib.h>
  #include <string.h>
	#include "y.tab.h"
  #include <stdbool.h>

  typedef struct clause {
    char *name;
    int term_count;
    struct literal *next_literal;
    struct clause *next;
  } clause_t;

  typedef struct literal {
    char *text;
    struct literal *next_literal;
  } literal_t;

  struct literal_symbol {
    char * text;
    struct var_symbol *var_list;
    struct literal_symbol *next;
  };

  struct var_symbol {
    char *name;
    struct var_symbol *next;
  };


	int main(void);
  void print_l(struct var_symbol *p);
  char* concat(const char *s1, const char *s2);
  void yyerror(char*);
	int yylex();
  void add_clause();
  void add_literal();
  void print_symboltable();


clause_t * symbol_table;

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
  char *ch;
}

%token <ch> atom variable numeral dot def com op cp ob cb vert is
%type <ch> FACT RULE TERM TERM_L OPERAND COMP ARITH LIST LITERAL LITERAL_L FUNCTION

%left <ch> lt lte st ste eq eqeq neq neqeq plus minus times divby

%start S_L

%%

S_L: S_L S	{ ; }
	| S	{ ; }
	;

S: FACT { add_clause($1); }
	|	RULE {  add_clause($1); }
	;

FACT:	LITERAL dot { asprintf(&$$,"%s %s",$1,$2);  }
	;

RULE:	LITERAL def LITERAL_L dot { asprintf(&$$,"%s %s %s %s",$1,$2,$3,$4); }
	;

LITERAL: atom op TERM_L cp {asprintf(&$$,"%s %s %s %s",$1,$2,$3,$4); add_literal($$); }
  | ARITH { $$ = $1; add_literal($1);}
  | COMP { $$ =$1; add_literal($1);}
	| atom { $$=$1; add_literal($1); }
  | variable is OPERAND { asprintf(&$$,"%s %s %s",$1,$2,$3); add_literal($$); }
	;

LITERAL_L: LITERAL com LITERAL_L { asprintf(&$$,"%s %s %s",$1,$2,$3);  }
	| LITERAL { $$ = $1; }
	;

TERM_L: TERM_L com TERM { asprintf(&$$,"%s %s %s",$1,$2,$3);}
	| TERM { $$ = $1; }
	;

TERM:   ARITH { $$ = $1; }
  | FUNCTION { $$ = $1; }
  | LIST { $$ = $1; }
  | COMP { $$ = $1; } 
  | atom { $$ = $1;}
  | numeral { $$ = $1;}
//  | variable { $$ = create_new_list($1); }
  ;

ARITH: OPERAND plus OPERAND {asprintf(&$$,"%s %s %s",$1,$2,$3);}
  | OPERAND minus OPERAND { asprintf(&$$,"%s %s %s",$1,$2,$3);}
  | OPERAND times OPERAND { asprintf(&$$,"%s %s %s",$1,$2,$3);}
  | OPERAND divby OPERAND {asprintf(&$$,"%s %s %s",$1,$2,$3);}
  | op ARITH cp { asprintf(&$$,"%s %s %s",$1,$2,$3); }
  ;

COMP: OPERAND lt OPERAND {  asprintf(&$$,"%s %s %s",$1,$2,$3); }
  | OPERAND lte OPERAND {  asprintf(&$$,"%s %s %s",$1,$2,$3); }
  | OPERAND st OPERAND {  asprintf(&$$,"%s %s %s",$1,$2,$3); }
  | OPERAND ste OPERAND {  asprintf(&$$,"%s %s %s",$1,$2,$3); }
  | OPERAND eq OPERAND {  asprintf(&$$,"%s %s %s",$1,$2,$3);}
  | OPERAND eqeq OPERAND {  asprintf(&$$,"%s %s %s",$1,$2,$3);}
  | OPERAND neq OPERAND {  asprintf(&$$,"%s %s %s",$1,$2,$3);}
  | OPERAND neqeq OPERAND {  asprintf(&$$,"%s %s %s",$1,$2,$3); }
  ; 

OPERAND: ARITH {$$=$1;} 
  | variable { $$ = $1;}
  | numeral { $$ = $1;}
  ;

LIST:	ob TERM_L vert LIST cb {  asprintf(&$$,"%s %s %s %s %s",$1,$2,$3,$4,$5);}
	| ob TERM_L cb { asprintf(&$$,"%s %s %s",$1,$2,$3);  }
	|	ob cb {  asprintf(&$$,"%s %s",$1,$2);  }
	|	variable { $$ = $1;  }
  ;

FUNCTION: atom op TERM_L cp {  asprintf(&$$,"%s %s %s %s",$1,$2,$3,$4);  } ;



%%

int main(void) {	
  yyparse();
  print_symboltable();
  return 0;
}

void add_clause(){
  if(symbol_table==NULL){
    symbol_table = (clause_t *) malloc(sizeof(clause_t));
  }else{ 
    clause_t *old_clause = symbol_table;
    symbol_table = (clause_t *) malloc(sizeof(clause_t));
    symbol_table->next=old_clause;
   }
}

void add_literal(char* text){
  //if(text==NULL){text="##";}  
  if(symbol_table==NULL){ symbol_table = (clause_t *) malloc(sizeof(clause_t)); }
  literal_t *old_literal = (literal_t *) symbol_table->next_literal; // save current literal list pointer
  literal_t *new_literal = (literal_t *) malloc(sizeof(literal_t)); // allocate new list element
  
  new_literal->text = malloc(255 * sizeof(char));

  if(text!=NULL){
    strcpy(new_literal->text,text);
  }
  new_literal->next_literal =  old_literal;
  symbol_table->next_literal = new_literal;
 /* symbol_table->next_literal= (literal *)new_literal;
  new_literal->next_literal = (literal *) old_literal;*/
}


char* concat(const char *s1, const char *s2)
{
    char *result = malloc(strlen(s1) + strlen(s2) + 1); // +1 for the null-terminator
    // in real code you would check for errors in malloc here
    //strcpy(result, s1);
    //strcat(result, s2);
    strcpy(result, s2);
    strcat(result, s1);
    return result;
}

void print_symboltable(){
  printf("symbol table\n");
  int counter=1;
  char *str="";
  char *temp = malloc(500*sizeof(char));

  clause_t* current = symbol_table;

  while(current != NULL){
    //printf("%d clause: \n",counter);
    
    

    literal_t * current_literal = current->next_literal;
    while(current_literal != NULL){

      if(current_literal->text!=NULL){
        asprintf(&temp,"\tliteral %s\n",current_literal->text);
        str=concat(str,temp);
        //printf("\tliteral %s\n",current_literal->text);
      }else{
        //printf("\txx\n");
        //(&temp,"\txx\n");
        str=concat(temp,"\txx\n");
      }

      

      current_literal=current_literal->next_literal;
    }

    str=concat(str,"clause: \n");

    current=current->next;
    counter++;
  }
  printf("%s",str);
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