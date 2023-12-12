simples: utils.c lexico.l sintatico2.y;
	flex -o lexico.c lexico.l;\
	bison -v -d sintatico2.y -o sintatico.c;\
	gcc sintatico.c -o simples;

limpa: ;
	rm lexico.c sintatico.c sintatico.h sintatico.output simples