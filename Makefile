prolog:	scanner.l parser.y
		bison -v -d -b y parser.y
		flex scanner.l
		gcc -lm -g -o $@ y.tab.c lex.yy.c