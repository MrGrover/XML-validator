flex Lexer.l
bison -ydtv  Parser.y
g++ main.c lex.yy.c y.tab.c -o Valid

