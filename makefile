lyc: parseur.tab.o lex.yy.o tpK-tabSymbol.o arbre-abstrait.o main.o
	gcc -o lyc parseur.tab.o lex.yy.o tpK-tabSymbol.o arbre-abstrait.o main.o

lex.yy.c: lexeur.l
	flex lexeur.l

parseur.tab.c: parseur.y
	bison -d parseur.y

ley.yy.o: lex.yy.c
	gcc -c -Wall lex.yy.c

parseur.tab.o: parseur.tab.c parseur.tab.h
	gcc -c -Wall parseur.tab.c

tpK-tabSymbol.o: tpK-tabSymbol.h tpK-tabSymbol.c
	gcc -c -Wall tpK-tabSymbol.c

arbre-abstrait.o: arbre-abstrait.h arbre-abstrait.c
	gcc -c -Wall arbre-abstrait.c

main.o: main.c
	gcc -c -Wall main.c

all: 
	lyc

targz: 
	tar -zcvf Ndiour_TafsirMbodj.tar.gz main.c parseur.y lexeur.l

clean:
	rm -f *.o lyc lex.yy.c parseur.tab.*