prolog:	scanner.l parser.y
		bison -d parser.y
		flex scanner.l
		gcc -g -o $@ parser.tab.c lex.yy.c -ll