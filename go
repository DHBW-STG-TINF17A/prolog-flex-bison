bison -v -d -b y parser.y
flex scanner.l
gcc -lm -g -o prolog y.tab.c lex.yy.c
./prolog<test_input.txt