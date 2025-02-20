%{

/*+=============================================================
| UNIFAL = U n i v e r s i d a d e F e d e r a l de A l f e n a s .
| BACHARELADO EM CIENCIA DA COMPUTACAO.
| Trabalho . . : R e g i s t r o e v e r i f i c a c a o de t i p o s
| D i s c i p l i n a : T e o r i a de Linguagens e Compiladores
| P r o f e s s o r . : Luiz Eduardo da S i l v a
| Aluno . . . . . : Tiago Costa Soares
| Data . . . . . . : 13/12/2023
+=============================================================*/


#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "lexico.c"
#include "utils.c"
int contaVar = 0;
int rotulo = 0;
int ehRegistro = 0;
int tipo;
int tamReg;
int desReg;    //    criei a variável mas pelo jeito ela substituiu a função da variável des, tomar cuidado para não gerar erros
int j;
int buscaORegistrador;
int tam; // tamanho da estrutura qdo percorre expressão de acesso
int des = 0; // deslocamento para chegar no campo
int pos = 0; // posicao do tipo na tabela de simbolos
int desGlob;
ptno listaCampos;
ptno busca_campo;


%}

%token T_PROGRAMA
%token T_INICIO
%token T_FIM
%token T_IDENTIF
%token T_LEIA
%token T_ESCREVA
%token T_ENQTO
%token T_FACA
%token T_FIMENQTO
%token T_SE
%token T_ENTAO
%token T_SENAO
%token T_FIMSE
%token T_ATRIB
%token T_VEZES
%token T_DIV
%token T_MAIS
%token T_MENOS
%token T_MAIOR
%token T_MENOR
%token T_IGUAL
%token T_E
%token T_OU
%token T_V
%token T_F
%token T_NUMERO
%token T_NAO
%token T_ABRE
%token T_FECHA
%token T_LOGICO
%token T_INTEIRO
%token T_DEF
%token T_FIMDEF
%token T_REGISTRO
%token T_IDPONTO

%start programa

%left T_E T_OU
%left T_IGUAL
%left T_MAIOR T_MENOR
%left T_MAIS T_MENOS
%left T_VEZES T_DIV

%%

programa 
   : cabecalho definicoes variaveis 
        { 
            mostraTabela();
            empilha (contaVar);
            if (contaVar)
               fprintf(yyout, "\tAMEM\t%d\n", contaVar); 
        }
     T_INICIO lista_comandos T_FIM
        { 
            int conta = desempilha();
            if (conta)
               fprintf(yyout, "\tDMEM\t%d\n", conta); 
        }
        { fprintf(yyout, "\tFIMP\n"); }
   ;

cabecalho
   : T_PROGRAMA T_IDENTIF
       { fprintf(yyout, "\tINPP\n"); 
       
            strcpy(elemTab.id, "inteiro");
            elemTab.tip = 0;
            elemTab.pos = pos;
            elemTab.end = -1;
            elemTab.tam = 1;
            elemTab.listaCampos = NULL;
            pos++;
            insereSimbolo(elemTab);


            strcpy(elemTab.id, "logico");
            elemTab.tip = 1;
            elemTab.pos = pos;
            elemTab.end = -1;
            elemTab.tam = 1;
            elemTab.listaCampos = NULL;
            pos++;
            insereSimbolo(elemTab);
       }
   ;

tipo
   : T_LOGICO
         { 
            tipo = LOG; 
            int a = buscaSimbolo("logico");
            elemTab.tam = tabSimb[a].tam;
            elemTab.pos = tabSimb[a].pos;
            // TODO #1
            // Além do tipo, precisa guardar o TAM (tamanho) do
            // tipo e a POS (posição) do tipo na tab. símbolos
         }
   | T_INTEIRO
         { 
            tipo = INT;
            int a = buscaSimbolo("inteiro");
            elemTab.tam = tabSimb[a].tam;
            elemTab.pos = tabSimb[a].pos;
            // idem 
        }
   | T_REGISTRO T_IDENTIF
         { 
            int a = buscaSimbolo(atomo);
            tipo = REG; 
            tamReg += tabSimb[a].tam;
            //desReg = tamReg;
            elemTab.tam = tabSimb[a].tam;
            elemTab.pos = tabSimb[a].pos;
        
            // TODO #2
            // Aqui tem uma chamada de buscaSimbolo para encontrar
            // as informações de TAM e POS do registro
         }
   ;

definicoes
   : define definicoes
   | /* vazio */
   ;

define 
   : T_DEF
        {
            tamReg = 0;
            desReg = 0;
            // TODO #3
            // Iniciar a lista de campos
            listaCampos = NULL;
        } 
   definicao_campos T_FIMDEF T_IDENTIF
       {

            strcpy(elemTab.id, atomo);
            elemTab.tip = 2;
            elemTab.pos = pos;
            elemTab.end = -1;
            elemTab.listaCampos = listaCampos;
            elemTab.tam = tamReg;
            pos++;


            insereSimbolo (elemTab);
           // TODO #4
           // Inserir esse novo tipo na tabela de simbolos
           // com a lista que foi montada
       }
   ;

definicao_campos
   : tipo lista_campos definicao_campos
   | tipo lista_campos
   ;

lista_campos
   : lista_campos T_IDENTIF
      {
        
        char idL[100];
        strcpy(idL, atomo);
        int tipL = tipo;
        int posL = pos;

        int desL = desReg;
        int tamL = tam;
        if(tipo == 0 || tipo == 1){
            posL = elemTab.pos;
            tamL = elemTab.tam;
            desReg++;
            tamReg++;
            
        } else if (tipo == 2){
            posL = elemTab.pos;
            tamL = elemTab.tam;
            desReg += tamL;
        }

        listaCampos = inserir(listaCampos, idL, tipL, posL, desL, tamL);

         // TODO #5
         // acrescentar esse campo na lista de campos que
         // esta sendo construida
         // o deslocamento (endereço) do próximo campo
         // será o deslocamento anterior mais o tamanho desse campo
      }
   | T_IDENTIF
      {
        char idL[100];
        strcpy(idL, atomo);
        int tipL = tipo;
        int posL = pos;

        int desL = desReg;
        int tamL = tam;
        if(tipo == 0 || tipo == 1){
            posL = elemTab.pos;
            tamL = elemTab.tam;
            desReg++;
            tamReg++;
        } else if (tipo == 2){
            posL = elemTab.pos;
            tamL = elemTab.tam;
            desReg += tamL;
        }

        listaCampos = inserir(listaCampos, idL, tipL, posL, desL, tamL);
        // idem
      }
   ;

variaveis
   : /* vazio */
   | declaracao_variaveis
   ;

declaracao_variaveis
   : tipo lista_variaveis declaracao_variaveis
   | tipo lista_variaveis
   ;

lista_variaveis
   : lista_variaveis
     T_IDENTIF 
        { 
            strcpy(elemTab.id, atomo);
            if(tipo == 0 || tipo == 1) {
               elemTab.end = contaVar;
               contaVar++;
            } else {
               elemTab.end = contaVar;
               contaVar += elemTab.tam;
            }
            elemTab.tip = tipo;
            // TODO #6
            // Tem outros campos para acrescentar na tab. símbolos
            insereSimbolo (elemTab);

            // TODO #7
            // Se a variavel for registro
            // contaVar = contaVar + TAM (tamanho do registro)
        }
   | T_IDENTIF
       { 
            strcpy(elemTab.id, atomo);
            if(tipo == 0 || tipo == 1) {
               elemTab.end = contaVar;
               contaVar++;
            } else {
               elemTab.end = contaVar;
               contaVar += elemTab.tam;
            }
            elemTab.tip = tipo;
            // TODO #6
            // Tem outros campos para acrescentar na tab. símbolos
            insereSimbolo (elemTab);
            // bidem 
       }
   ;

lista_comandos
   : /* vazio */
   | comando lista_comandos
   ;

comando
   : entrada_saida
   | atribuicao
   | selecao
   | repeticao
   ;

entrada_saida
   : entrada
   | saida 
   ;

entrada
   : T_LEIA expressao_acesso
       { 
          // TODO #8
          // Se for registro, tem que fazer uma repetição do
          // TAM do registro de leituras
          if(tipo == 2) {    
            printf("tamanho: %d" ,tam);
            printf("j:%d", j);
            for(int i = tam-1; i >= j; i--) {
               fprintf(yyout, "\tLEIA\n"); 
               fprintf(yyout, "\tARZGzz\t%d\n", des);
               des++;
            }  } else { 
                  fprintf(yyout, "\tLEIA\n");
                  fprintf(yyout, "\tARZG\t%d\n", tabSimb[pos].end);
                  des++;
            } 
            desGlob += des;
       }
   ;

saida
   : T_ESCREVA expressao
       {  
          desempilha(); 
          // TODO #9
          // Se for registro, tem que fazer uma repetição do
          // TAM do registro de escritas
          if(tipo == 2) {    
            for(int i = tam-1; i >= j; i--) {
               fprintf(yyout, "\tESCR\t\n");
            }  } else { 
                  fprintf(yyout, "\tESCR\n");
            }
           
      }
   ;

atribuicao
   : expressao_acesso
       { 
         // TODO #10 - FEITO
         // Tem que guardar o TAM, DES e o TIPO (POS do tipo, se for registro)
          empilha(tam);
          empilha(des);
          empilha(tipo);
       }
     T_ATRIB expressao
       { 
          int tipexp = desempilha();
          int tipvar = desempilha();
          int des = desempilha();
          int tam = desempilha();
          if (tipexp != tipvar)
             yyerror("Incompatibilidade de tipo!");
          // TODO #11 - FEITO
          // Se for registro, tem que fazer uma repetição do
          // TAM do registro de ARZG
   
         if(tipo == 2) {    
            tam += desGlob;
            for(desGlob; desGlob < tam; desGlob++) {
               fprintf(yyout, "\tARZGss\t%d\n", desGlob);
            }  } else { 
                  fprintf(yyout, "\tARZG\t%d\n", des);
                  desGlob++;
            }
       }
   ;

selecao
   : T_SE expressao T_ENTAO 
       {  
          int t = desempilha();
          if (t != LOG)
            yyerror("Incompatibilidade de tipo!");
          fprintf(yyout, "\tDSVF\tL%d\n", ++rotulo); 
          empilha(rotulo);
       }
     lista_comandos T_SENAO 
       {  
           fprintf(yyout, "\tDSVS\tL%d\n", ++rotulo);
           int rot = desempilha(); 
           fprintf(yyout, "L%d\tNADA\n", rot);
           empilha(rotulo); 
       }
     lista_comandos T_FIMSE
       {  
          int rot = desempilha();
          fprintf(yyout, "L%d\tNADA\n", rot);  
       }
   ;

repeticao
   : T_ENQTO 
       { 
         fprintf(yyout, "L%d\tNADA\n", ++rotulo);
         empilha(rotulo);  
       }
     expressao T_FACA 
       {  
         int t = desempilha();
         if (t != LOG)
            yyerror("Incompatibilidade de tipo!");
         fprintf(yyout, "\tDSVF\tL%d\n", ++rotulo); 
         empilha(rotulo);
       }
     lista_comandos T_FIMENQTO
       { 
          int rot1 = desempilha();
          int rot2 = desempilha();
          fprintf(yyout, "\tDSVS\tL%d\n", rot2);
          fprintf(yyout, "L%d\tNADA\n", rot1);  
       }
   ;

expressao
   : expressao T_VEZES expressao
       {  testaTipo(INT,INT,INT); fprintf(yyout, "\tMULT\n");  }
   | expressao T_DIV expressao
       {  testaTipo(INT,INT,INT); fprintf(yyout, "\tDIVI\n");  }
   | expressao T_MAIS expressao
      {  testaTipo(INT,INT,INT); fprintf(yyout, "\tSOMA\n");  }
   | expressao T_MENOS expressao
      {  testaTipo(INT,INT,INT); fprintf(yyout, "\tSUBT\n");  }
   | expressao T_MAIOR expressao
      {  testaTipo(INT,INT,LOG); fprintf(yyout, "\tCMMA\n");  }
   | expressao T_MENOR expressao
      {  testaTipo(INT,INT,LOG); fprintf(yyout, "\tCMME\n");  }
   | expressao T_IGUAL expressao
      {  testaTipo(INT,INT,LOG); fprintf(yyout, "\tCMIG\n");  }
   | expressao T_E expressao
      {  testaTipo(LOG,LOG,LOG); fprintf(yyout, "\tCONJ\n");  }
   | expressao T_OU expressao
      {  testaTipo(LOG,LOG,LOG); fprintf(yyout, "\tDISJ\n");  }
   | termo
   ;

expressao_acesso
   : T_IDPONTO
       {   //--- Primeiro nome do registro

            if (!ehRegistro) {   //aqui é a primeira vez que entra em um ehRegistro
               ehRegistro = 1;
               des = 0;
               tam = 0;
               buscaORegistrador = buscaSimbolo(atomo);  //aqui encontra o endereço dele na tabela, mas na verdade queremos tabSimb.pos(indicando o tipo do registro)
               if(tabSimb[buscaORegistrador].tip != 2) {
                   yyerror("Registrador não encontrado");
               } else {
                  tipo == 2;
                  tam = tabSimb[buscaORegistrador].tam;
                  //des = tabSimb[buscaORegistrador].end;  //deslocamento a partir do ínicio para chegar no elemento    
                  pos = tabSimb[buscaORegistrador].pos;
                  busca_campo = tabSimb[pos].listaCampos;
               }
               // TODO #12
               // 1. busca o simbolo na tabela de símbolos
               // 2. se não for do tipo registo tem erro
               // 3. guardar o TAM, POS e DES desse t_IDENTIF
            } else {
               busca_campo = busca(listaCampos, atomo);
               if (busca_campo == NULL) {
                  yyerror("Campo não encontrado");
               } else if (tabSimb[pos].tip != 2) {
                  yyerror("Não é registro");
               } else {
                  tipo == 2;
                  tam += busca_campo->tam;
                  des += busca_campo->desl;
                  pos = busca_campo->pos;
               }
              //--- Campo que eh registro
              // 1. busca esse campo na lista de campos
              // 2. se não encontrar, erro
              // 3. se encontrar e não for registro, erro
              // 4. guardar o TAM, POS e DES desse CAMPO
            }
       }
     expressao_acesso
   | T_IDENTIF
       {   
           if (ehRegistro) {
               busca_campo = tabSimb[pos].listaCampos;
               busca_campo = busca(busca_campo, atomo);
               if(busca_campo == NULL) {
                  yyerror("Campos não encontrado!");
               } else {
                  des += busca_campo->desl;
                  tam += busca_campo->tam;
                  tipo = busca_campo->tip;
                  pos = buscaORegistrador;
               }
               // TODO #13
               // 1. buscar esse campo na lista de campos
               // 2. Se não encontrar, erro
               // 3. guardar o TAM, DES e TIPO desse campo.
               //    o tipo (TIP) nesse caso é a posição do tipo
               //    na tabela de simbolos
           }
           else {
              // TODO #14
               des = 0;
               tam = 0;
               pos = buscaSimbolo (atomo);
               tam = tabSimb[pos].tam;
               tipo = tabSimb[pos].tip;
               // guardar TAM, DES e TIPO dessa variável
           }
            
         ehRegistro = 0;
       };

termo
   : expressao_acesso
       {
         // TODO #15
         // Se for registro, tem que fazer uma repetição do
         // TAM do registro de CRVG (em ondem inversa)
         if(tipo == 2) {
            if(!buscaORegistrador) {
               tam += tabSimb[pos].end;
               j = tabSimb[pos].end;
               for(int i = tam-1; i >= j; i--) {
                  fprintf(yyout, "\tCRVG\t%d\n", i);
            }   
            }  else {
               tam -= des;
               tam--;
               j = tabSimb[buscaORegistrador].end;
               for(int i = tam-1; i >= j; i--) {
                  fprintf(yyout, "\tCRVG\t%d\n", i);
            }   

            }

         } else {
           fprintf(yyout, "\tCRVG\t%d\n", tabSimb[pos].end + des);
         }  
         buscaORegistrador = 0;
         empilha(tipo);
       }
   | T_NUMERO
       {  
          fprintf(yyout, "\tCRCT\t%s\n", atomo);  
          empilha(INT);
       }
   | T_V
       {  
          fprintf(yyout, "\tCRCT\t1\n");
          empilha(LOG);
       }
   | T_F
       {  
          fprintf(yyout, "\tCRCT\t0\n"); 
          empilha(LOG);
       }
   | T_NAO termo
       {  
          int t = desempilha();
          if (t != LOG)
              yyerror ("Incompatibilidade de tipo!");
          fprintf(yyout, "\tNEGA\n");
          empilha(LOG);
       }
   | T_ABRE expressao T_FECHA
   ;
%%

int main(int argc, char *argv[]) {
    char *p, nameIn[100], nameOut[100];
    argv++;
    if (argc < 2) {
        puts("\nCompilador da linguagem SIMPLES");
        puts("\n\tUSO: ./simples <NOME>[.simples]\n\n");
        exit(1);
    }
    p = strstr(argv[0], ".simples");
    if (p) *p = 0;
    strcpy(nameIn, argv[0]);
    strcat(nameIn, ".simples");
    strcpy(nameOut, argv[0]);
    strcat(nameOut, ".mvs");
    yyin = fopen(nameIn, "rt");
    if (!yyin) {
        puts ("Programa fonte não encontrado!");
        exit(2);
    }
    yyout = fopen(nameOut, "wt");
    yyparse();
    printf("programa ok!\n\n");
    return 0;
}