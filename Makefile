compile:
	lex lexer.l 
	yacc -d parser.y 
	gcc -o out lex.yy.c y.tab.c -ll  
clean:
	rm out y.tab.c y.tab.h
	rm -rf out

run : 
	rm -rf output/token.txt output/parsed.txt
	./out
