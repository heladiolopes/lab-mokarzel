%{

/* Inclusao de arquivos da biblioteca de C */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* Definicao dos atributos dos atomos operadores */

#define		LT	1
#define		LE	2
#define		GT	3
#define		GE	4
#define		EQ	5
#define		NE	6

#define		PLUS	1
#define		MINUS	2

#define		TIMES	1
#define		DIVIDED	2
#define		REST	3

/*   Definicao dos tipos de identificadores   */

#define 	IDPROG		1
#define 	IDVAR		2
#define		IDFUNC		3

/*  Definicao dos tipos de variaveis   */

#define 	NAOVAR		0
#define 	INTEIRO		1
#define 	LOGICO		2
#define 	REAL		3
#define 	CARACTERE	4
#define 	VAZIO		5

/*   Definicao de outras constantes   */

#define	NCLASSHASH	23
#define	VERDADE		1
#define	FALSO		0
#define MAXDIMS		10
#define MAXPARS		10

/*	Auxiliar na identação	*/

int tab = 0;

/*  Strings para nomes dos tipos de identificadores  */

char *nometipid[4] = {" ", "IDPROG", "IDVAR", "IDFUNC"};

/*  Strings para nomes dos tipos de variaveis  */

char *nometipvar[6] = {"NAOVAR",
	"INTEIRO", "LOGICO", "REAL", "CARACTERE", "VAZIO"
};

/*    Declaracoes para a tabela de simbolos     */

typedef struct celsimb celsimb;
typedef celsimb *simbolo;
struct celsimb {
	char *cadeia;
	char *escopo;
	int tid, tvar, ndims, dims[MAXDIMS+1];
	char inic, ref, array, parameter;
	simbolo prox;
	int npars, pars[MAXPARS+1];
};

/*  Variaveis globais para a tabela de simbolos e analise semantica */

int tipocorrente, emfuncao;
char *escopocorrente;
simbolo tabsimb[NCLASSHASH];
simbolo simb;

/*
	Prototipos das funcoes para a tabela de simbolos
    	e analise semantica
 */

void tabular();
void InicTabSimb (void);
void ImprimeTabSimb (void);
simbolo InsereSimb (char *, int, int, char *);
int hash (char *);
simbolo ProcuraSimb (char *, char *);
void DeclaracaoRepetida (char *);
void TipoInadequado (char *);
void NaoDeclarado (char *);
void VerificaInicRef ();
void Incompatibilidade(char *);
void Esperado (char *);
void NaoEsperado (char *);

%}

/* Definicao do tipo de yylval e dos atributos dos nao terminais */

%union {
	char string[50];
	int atr, valint;
	float valreal;
	char carac;
	simbolo simb;
	int tipoexpr;
	int nsubscr;
	int nparam;
}

/* Declaracao dos atributos dos tokens e dos nao-terminais */


%token			CALL
%token			CHAR
%token			DO
%token			ELSE
%token			FALSE
%token			FLOAT
%token			FOR
%token			FUNCTIONS
%token			GLOBAL
%token			IF
%token			INT
%token			LOCAL
%token			LOGIC
%token			MAIN
%token			PROGRAM
%token			READ
%token			RETURN
%token			STATEMENTS
%token			TRUE
%token			VOID
%token			WHILE
%token			WRITE

%token	<string>	ID
%token	<valint>	INTCT
%token	<string>	CHARCT
%token	<valreal>	FLOATCT
%token	<string>	STRING

%token			OR
%token			AND
%token			NOT
%token	<atr>		RELOP
%token	<atr>		ADOP
%token	<atr>		MULTOP
%token			NEG

%token			ASSIGN
%token			OPPAR
%token			CLPAR
%token			OPBRAK
%token			CLBRAK
%token			OPBRACE
%token			CLBRACE
%token			SCOLON
%token			COMMA
%token			COLON

%token	<carac>		INVAL

%type 		<simb>			Variable
%type 	    <tipoexpr> 	    Expression  AuxExpr1  AuxExpr2
                            AuxExpr3   AuxExpr4   Term   Factor
							FuncCall
%type   	<nsubscr>      	Subscripts  SubscrList
%type		<nparam>		Arguments	ExprList

%%

/* Producoes da gramatica:

	Os terminais sao escritos e, depois de alguns,
	para alguma estetica, ha mudanca de linha       */


Prog		:	{InicTabSimb();} PROGRAM ID OPBRACE {printf("program %s ", $3);tabular();printf("\n\{\n\n"); InsereSimb($3, IDPROG, NAOVAR, "Programa");}
				GlobDecls Functions CLBRACE {tabular();printf("}\n"); VerificaInicRef(); ImprimeTabSimb();}
			;

GlobDecls 	:
			|	GLOBAL COLON {tabular();printf("global :\n");tab++;
				escopocorrente = (char*) malloc ((strlen("Global")+1) * sizeof(char));
				strcpy(escopocorrente, "Global");}
				DeclList {tab--;printf("\n");}
			;

DeclList 	: 	Declaration
			| 	DeclList Declaration
			;

Declaration :	{tabular();} Type ElemList SCOLON {printf(";\n");}
			;

Type 		: 	INT {printf("int "); tipocorrente = INTEIRO;}
			| 	FLOAT {printf("float "); tipocorrente = REAL;}
			| 	CHAR {printf("char "); tipocorrente = CARACTERE;}
			| 	LOGIC {printf("logic "); tipocorrente = LOGICO;}
			| 	VOID {printf("void "); tipocorrente = VAZIO;}
			;

ElemList	: 	Elem
			| 	ElemList COMMA{printf(", ");} Elem
			;

Elem 		: 	ID {printf("%s", $1);
					simbolo aux = ProcuraSimb($1, escopocorrente);
					if(aux != NULL && strcmp(aux->escopo, escopocorrente) == 0) DeclaracaoRepetida($1);
					else { simb = InsereSimb($1, IDVAR, tipocorrente, escopocorrente);
							simb->array = FALSO;
							simb->ndims = 0;
					}
				} Dims
			;

Dims 		:
			| 	OPBRAK {printf("[");} DimList CLBRAK {printf("]"); simb->array = VERDADE;}
			;

DimList 	: 	INTCT {printf("%d", $1); if($1 <= 0) Esperado("Valor inteiro positivo");
										simb->ndims++;
										simb->dims[simb->ndims] = $1; }
			| 	DimList COMMA INTCT {printf(", %d", $3); if($3 <= 0) Esperado("Valor inteiro positivo");
														simb->ndims++;
															simb->dims[simb->ndims] = $3;}
			;

Functions 	: 	FUNCTIONS COLON {tabular();printf("functions :\n\n");tab++;} FuncList {tab--;}
			;

FuncList 	: 	Function
			| 	FuncList Function
			;

Function 	: 	{tabular();} Header
				OPBRACE {tabular();printf("\{\n");}
				LocDecls Stats
				CLBRACE {tabular();printf("}\n\n");}
			;

Header 		: 	MAIN {printf("main \n");
				escopocorrente = (char*) malloc ((strlen("Main")+1) * sizeof(char));
				strcpy(escopocorrente, "Main");
				if(ProcuraSimb("main", "Global") != NULL) DeclaracaoRepetida("main");
				else {
						simb = InsereSimb("main", IDFUNC, NAOVAR, "Global");
						simb->parameter = FALSO;
						simb->npars = 0;
					}
				}

			| 	Type ID OPPAR {printf("%s (", $2);
			  	escopocorrente = (char*) malloc ((strlen($2)+1) * sizeof(char));
				strcpy(escopocorrente, $2);
				if(ProcuraSimb($2, "Global") != NULL) DeclaracaoRepetida($2);
				else {
						simb = InsereSimb($2, IDFUNC, tipocorrente, "Global");
						simb->parameter = FALSO;
						simb->npars = 0;
					}
				}
				Params CLPAR {printf(")\n");}
			;

Params 		:
			| 	ParamList {simb->parameter = VERDADE;}
			;

ParamList 	: 	Parameter
			| 	ParamList COMMA {printf(", ");} Parameter
			;

Parameter 	: 	Type ID {
					printf("%s", $2);
					simbolo aux = ProcuraSimb(escopocorrente, "Global");
					aux->npars++; aux->pars[aux->npars] = tipocorrente;

					aux = ProcuraSimb($2, escopocorrente);
					if(aux != NULL && strcmp(aux->escopo, escopocorrente) == 0) DeclaracaoRepetida($2);
					else InsereSimb($2, IDVAR, tipocorrente, escopocorrente);

					simbolo simb = ProcuraSimb($2, escopocorrente);
					simb->inic = VERDADE;
				}
			;

LocDecls 	:
			| 	LOCAL COLON {tabular();printf("local :\n");tab++;} DeclList {tab--;}
			;

Stats 		: 	STATEMENTS COLON {tabular();printf("statements :\n");tab++;} StatList {tab--;}
			;

StatList 	:
			| 	StatList Statement
			;

Statement 	: 	CompStat
			| 	IfStat
			| 	WhileStat
			| 	DoStat
			| 	ForStat
			| 	ReadStat
			| 	WriteStat
			| 	AssignStat
			| 	CallStat
			| 	ReturnStat
			| 	SCOLON {tabular();printf(";\n");}
			;

CompStat 	: 	OPBRACE {tab--;tabular();printf("\{\n");tab++;} StatList CLBRACE {tab--;tabular();printf("\}\n");tab++;}
			;

IfStat 		: 	IF OPPAR {tabular();printf("if (");tab++;} Expression CLPAR
				{printf(")\n"); if ($4 != LOGICO) Incompatibilidade("Expressao deve ser logica ou relacional");}
				Statement {tab--;} ElseStat
			;

ElseStat 	:
			| 	ELSE {tabular();printf("else\n");tab++;} Statement {tab--;}
			;

WhileStat 	: 	WHILE OPPAR {tabular();printf("while (");tab++;} Expression CLPAR
 				{printf(")\n"); if ($4 != LOGICO) Incompatibilidade("Expressao deve ser logica ou relacional");}
				Statement {tab--;}
			;

DoStat 		: 	DO {tabular();printf("do ");tab++;} Statement
				WHILE OPPAR {tab--;tabular();printf("while (");} Expression CLPAR SCOLON
				{printf(");"); if ($7 != LOGICO) Incompatibilidade("Expressao deve ser logica ou relacional");}
			;

ForStat 	: 	FOR OPPAR {tabular();printf("for (");tab++;} Variable {
					if ($4 != NULL)
						$4->inic = $4->ref = VERDADE;
					if ($4->tvar != INTEIRO && $4->tvar != CARACTERE)
						Incompatibilidade("Variavel de inicializacao deve ser inteiro ou caractere");
				}
				ASSIGN {printf(" <- ");} Expression
				SCOLON {printf("; ");} Expression
				SCOLON {printf("; ");} Variable {
					if (strcmp($4->cadeia, $14->cadeia))
						Incompatibilidade("Variavel de atualizacao deve ser a mesma de inicializacao");
				}
				ASSIGN {printf(" <- ");} Expression {
					if (!((($8 == INTEIRO && $18 == INTEIRO) || ($8 == CARACTERE && $18 == CARACTERE)) && ($11 == LOGICO)))
						Incompatibilidade("Expressoes do for invalida");

				}
				CLPAR {printf(")\n");} Statement {tab--;}
			;

ReadStat 	: 	READ OPPAR {tabular();printf("read (");} ReadList CLPAR SCOLON {printf(");\n");}
			;

ReadList 	: 	Variable {if ($1 != NULL) $1->inic = $1->ref = VERDADE;}
			| 	ReadList COMMA {printf(", ");} Variable {if ($4 != NULL) $4->inic = $4->ref = VERDADE;}
			;

WriteStat 	: 	WRITE OPPAR {tabular();printf("write (");} WriteList CLPAR SCOLON {printf(");\n");}
			;

WriteList 	: 	WriteElem
			| 	WriteList COMMA {printf(", ");} WriteElem
			;

WriteElem 	: 	STRING {printf("%s", $1);}
			|	Expression
			;

CallStat 	: 	CALL {tabular();printf("call ");} FuncCall SCOLON {
					printf(";\n");
					if ($3 != VAZIO)
						Incompatibilidade("Funcao chamada por call deve ser void");
				}
			;

FuncCall 	: 	ID OPPAR {printf("%s (", $1);
					simb = ProcuraSimb($1, escopocorrente);
					if (simb == NULL) {NaoDeclarado($1);}
					else if (simb->tid != IDFUNC)
						Incompatibilidade("Call deve chamar funcao");
					else $<tipoexpr>$ = simb->tvar;
				} Arguments CLPAR {
					printf(")");
					$$ = $<tipoexpr>3;

					simbolo aux = ProcuraSimb($1, "Global");

					if (aux != NULL) {
		              	if (aux->parameter == FALSO && $4 > 0)
		                    NaoEsperado ("Parametro\(s)");
		                else if (aux->parameter == VERDADE && $4 == 0)
		                	Esperado ("Parametro\(s)");
		                else if (aux->npars != $4)
							Incompatibilidade ("Numero de parametros incompativel com declaracao");
		      	}


					if (strcmp($1, escopocorrente) == 0)
						Incompatibilidade("Linguagem nao admite recursividade");
				}
			;

Arguments 	:	{$$ = 0;}
			| 	ExprList {$$ = $1;}
			;

ReturnStat 	: 	RETURN SCOLON {
					tabular();printf("return;\n");
					simbolo aux = ProcuraSimb(escopocorrente, "Global");
					if (aux->tvar != VAZIO)
						Incompatibilidade("Funcao deve retornar expressao");
				}
			| 	RETURN {tabular();printf("return ");} Expression SCOLON {
					printf(";\n");
					simbolo aux = ProcuraSimb(escopocorrente, "Global");

					if (aux != NULL){
						if (aux->tvar == VAZIO)
							Incompatibilidade("Funcao void nao tem retorno");
						if (((aux->tvar == INTEIRO ||
							aux->tvar == CARACTERE) &&
							($3 == REAL || $3 == LOGICO)) ||
							(aux->tvar == REAL && $3 == LOGICO) ||
							(aux->tvar == LOGICO && $3 != LOGICO))
							Incompatibilidade ("Retorno improprio");
					}
				}
			;

AssignStat 	: 	{tabular();} Variable {if  ($2 != NULL) $2->inic = $2->ref = VERDADE;}
 				ASSIGN {printf(" <- ");} Expression SCOLON {printf(";\n");
				if ($2 != NULL)
					if ((($2->tvar == INTEIRO ||
						$2->tvar == CARACTERE) &&
						($6 == REAL || $6 == LOGICO)) ||
        				($2->tvar == REAL && $6 == LOGICO) ||
						($2->tvar == LOGICO && $6 != LOGICO))
    					Incompatibilidade ("Lado direito de comando de atribuicao improprio");
			}
				;

ExprList 	: 	Expression {
					if ($1 == VAZIO)
						Incompatibilidade("Tipo incompativel de parametro");
					$$ = 1;
				}
			| 	ExprList COMMA {printf(" , ");} Expression {
					if ($4 == VAZIO)
						Incompatibilidade("Tipo incompativel de parametro");
					$$ = $1 + 1;
				}
			;

Expression 	:	AuxExpr1
			| 	Expression OR {printf(" || ");} AuxExpr1 {
					if ($1 != LOGICO || $4 != LOGICO)
						Incompatibilidade ("Operando improprio para operador or");
					$$ = LOGICO;
				}
			;

AuxExpr1 	:	AuxExpr2
			| 	AuxExpr1 AND{printf(" && ");} AuxExpr2 {
					if ($1 != LOGICO || $4 != LOGICO)
						Incompatibilidade ("Operando improprio para operador and");
					$$ = LOGICO;
				}
			;

AuxExpr2 	: 	AuxExpr3
			| 	NOT {printf("!");} AuxExpr3 {
					if ($3 != LOGICO)
						Incompatibilidade ("Operando improprio para operador not");
					$$ = LOGICO;
				}
			;

AuxExpr3 	: 	AuxExpr4
			| 	AuxExpr4 RELOP {
					switch ($2) {
						case LT: printf (" < "); break;
						case LE: printf (" <= "); break;
						case EQ: printf (" = "); break;
						case NE: printf (" != "); break;
						case GT: printf (" > "); break;
						case GE: printf (" >= "); break;
					}
				} AuxExpr4 {
					switch ($2) {
						case LT: case LE: case GT: case GE:
							if ($1 != INTEIRO && $1 != REAL && $1 != CARACTERE || $4 != INTEIRO && $4 != REAL && $4 != CARACTERE)
								Incompatibilidade	("Operando improprio para operador relacional");
							break;
						case EQ: case NE:
							if (($1 == LOGICO || $4 == LOGICO) && $1 != $4)
								Incompatibilidade ("Operando improprio para operador relacional");
							break;
					}
					$$ = LOGICO;
				}
			;

AuxExpr4 	: 	Term
			| 	AuxExpr4 ADOP {
					switch ($2) {
						case PLUS: printf (" + "); break;
						case MINUS: printf (" - "); break;
					}
				} Term {
					if ($1 != INTEIRO && $1 != REAL && $1 != CARACTERE || $4 != INTEIRO && $4!=REAL && $4!=CARACTERE)
						Incompatibilidade ("Operando improprio para operador aritmetico");
					if ($1 == REAL || $4 == REAL) $$ = REAL;
					else $$ = INTEIRO;
				}
			;

Term 		: 	Factor
			|	Term MULTOP {
				switch ($2) {
					case TIMES: printf ( "* "); break;
					case DIVIDED: printf (" / "); break;
					case REST: printf (" %% "); break;
					}
				} Factor {
					switch ($2) {
						case TIMES: case DIVIDED:
							if ($1 != INTEIRO && $1 != REAL && $1 != CARACTERE
								|| $4 != INTEIRO && $4!=REAL && $4!=CARACTERE)
								Incompatibilidade ("Operando improprio para operador aritmetico");
							if ($1 == REAL || $4 == REAL) $$ = REAL;
							else $$ = INTEIRO;
							break;
						case REST:
							if ($1 != INTEIRO && $1 != CARACTERE
								||  $4 != INTEIRO && $4 != CARACTERE)
								Incompatibilidade ("Operando improprio para operador resto");
							$$ = INTEIRO;
							break;
					}
				}
		;

Factor 		: 	Variable {if  ($1 != NULL) {$1->ref  =  VERDADE; $$ = $1->tvar;}}
			| 	INTCT {printf("%d", $1); $$ = INTEIRO;}
			| 	FLOATCT {printf("%f", $1); $$ = REAL;}
			| 	CHARCT {printf("%s", $1); $$ = CARACTERE;}
			| 	TRUE {printf("true"); $$ = LOGICO;}
			| 	FALSE {printf("false"); $$ = LOGICO;}
			| 	NEG {printf("~");} Factor {
					if ($3 != INTEIRO && $3 != REAL && $3 != CARACTERE)
						Incompatibilidade  ("Operando improprio para menos unario");
					if ($3 == REAL) $$ = REAL;
					else $$ = INTEIRO;
				}
			| 	OPPAR {printf("(");} Expression CLPAR {printf(")"); $$ = $3;}
			| 	FuncCall {
					$$ = $1;
					if ($1 == VAZIO)
						Incompatibilidade("Funcao nao pode ser void");
				}
			;

Variable 	: 	ID
				{printf("%s", $1);
				simb = ProcuraSimb($1, escopocorrente);
				if (simb == NULL) NaoDeclarado($1);
				else if (simb->tid != IDVAR) TipoInadequado($1);
				$<simb>$ = simb;}
				Subscripts
				{
					$$ = $<simb>2;
					if ($$ != NULL) {
		              	if ($$->array == FALSO && $3 > 0)
		                      	NaoEsperado ("Subscrito\(s)");
		                else if ($$->array == VERDADE && $3 == 0)
		                       	Esperado ("Subscrito\(s)");
		                else if ($$->ndims != $3)
							Incompatibilidade ("Numero de subscritos incompativel com declaracao");
      				}
				}
			;

Subscripts 	:	{$$ = 0;}
			| 	OPBRAK {printf("[");} SubscrList CLBRAK {printf("]"); $$ = $3;}
			;

SubscrList 	: 	AuxExpr4
				{
					if ($1 != INTEIRO && $1 != CARACTERE)
						Incompatibilidade ("Tipo inadequado para subscrito");
					$$ = 1;
				}
			| 	SubscrList COMMA {printf(", ");} AuxExpr4
				{
					if ($4 != INTEIRO && $4 != CARACTERE)
							Incompatibilidade ("Tipo inadequado para subscrito");
					$$ = $1 + 1;
				}
			;

%%

/*	Inclusao do analisador lexico	*/

#include "lex.yy.c"

/*	Função que auxilia no pretty printer	*/

void tabular () {
	int i;
	for (i = 1; i <= tab; i++)
   	printf ("\t");
}

/*  InicTabSimb: Inicializa a tabela de simbolos   */

void InicTabSimb () {
	int i;
	for (i = 0; i < NCLASSHASH; i++)
		tabsimb[i] = NULL;
}

/*
	ProcuraSimb (cadeia): Procura cadeia na tabela de simbolos;
	Caso ela ali esteja, retorna um ponteiro para sua celula;
	Caso contrario, retorna NULL.
 */

simbolo ProcuraSimb (char *cadeia, char * escopo) {
	simbolo s; int i;
	i = hash (cadeia);

	s = tabsimb[i];
	while (s!=NULL) {
		if (strcmp(cadeia, s->cadeia) == 0 && strcmp(escopo, s->escopo) == 0)
			return s;
		s = s->prox;
	}

	s = tabsimb[i];
	while (s!=NULL) {
		if (strcmp(cadeia, s->cadeia) == 0 && strcmp("Global", s->escopo) == 0)
			return s;
		s = s->prox;
	}

	return s;

}

/*
	InsereSimb (cadeia, tid, tvar): Insere cadeia na tabela de
	simbolos, com tid como tipo de identificador e com tvar como
	tipo de variavel; Retorna um ponteiro para a celula inserida
 */

simbolo InsereSimb (char *cadeia, int tid, int tvar, char *escopo) {
	int i; simbolo aux, s;
	i = hash (cadeia); aux = tabsimb[i];
	s = tabsimb[i] = (simbolo) malloc (sizeof (celsimb));
	s->cadeia = (char*) malloc ((strlen(cadeia)+1) * sizeof(char));
	s->escopo = (char*) malloc ((strlen(escopo)+1) * sizeof(char));
	strcpy (s->cadeia, cadeia);
	strcpy (s->escopo, escopo);
	s->tid = tid;		s->tvar = tvar;
	s->inic = FALSO;	s->ref = FALSO;
	s->prox = aux;	return s;
}

/*
	hash (cadeia): funcao que determina e retorna a classe
	de cadeia na tabela de simbolos implementada por hashing
 */

int hash (char *cadeia) {
	int i, h;
	for (h = i = 0; cadeia[i]; i++) {h += cadeia[i];}
	h = h % NCLASSHASH;
	return h;
}

/* ImprimeTabSimb: Imprime todo o conteudo da tabela de simbolos  */

void ImprimeTabSimb () {
	int i; simbolo s;
	printf ("\n\n   TABELA  DE  SIMBOLOS:\n\n");
	for (i = 0; i < NCLASSHASH; i++)
		if (tabsimb[i]) {
			printf ("Classe %d:\n", i);
			for (s = tabsimb[i]; s!=NULL; s = s->prox){
				printf ("  (%10s, %s", s->cadeia,  nometipid[s->tid]);
				if (s->tid == IDVAR) {
					printf (", %9s, %d, %d, %s",
						nometipvar[s->tvar], s->inic, s->ref, s->escopo);
					if (s->array == VERDADE) {
						int j;
						printf (", EH ARRAY, ndims = %d, dimensoes:", s->ndims);
						for (j = 1; j <= s->ndims; j++)
	                  		printf ("  %d", s->dims[j]);
					}
				} else if (s->tid == IDFUNC){
					printf (",%9s", nometipvar[s->tvar]);
					if (s->parameter == VERDADE){
						int j;
						printf(", TEM PAR, npars = %d, parametros:", s->npars);
						for (j = 1; j <= s->npars; j++)
	                  		printf ("  %s", nometipvar[s->pars[j]]);
					}
				}
				printf(")\n");
			}
		}
}

/*  Mensagens de erros semanticos  */

void DeclaracaoRepetida (char *s) {
	printf ("\n\n***** Declaracao Repetida: %s *****\n\n", s);
}

void NaoDeclarado (char *s) {
    printf ("\n\n***** Identificador Nao Declarado: %s *****\n\n", s);
}

void TipoInadequado (char *s) {
    printf ("\n\n***** Identificador de Tipo Inadequado: %s *****\n\n", s);
}

void Incompatibilidade (char *s) {
	printf ("\n\n***** Incompatibilidade: %s *****\n\n", s);
}

void Esperado (char *s) {
	printf ("\n\n***** Esperado: %s *****\n\n", s);
}

void NaoEsperado (char *s) {
	printf ("\n\n***** Nao Esperado: %s *****\n\n", s);
}


/*
	Verifica tabela de simbolos e avisa de casos
	nãoinicializados/não-referênciados
*/

void VerificaInicRef() {
	int i; simbolo s;
	printf ("\n\n   VERIFICA INICIALIZA E REFERENCIA:\n\n");
	for (i = 0; i < NCLASSHASH; i++)
		if (tabsimb[i]) {
			for (s = tabsimb[i]; s!=NULL; s = s->prox){
				if((!s->inic || !s->ref) && s->tid == IDVAR) {
					printf("Variável %10s de %15s ", s->cadeia, s->escopo);
					if (!s->inic && !s->ref) printf("não inicializada nem referênciada.\n");
					else if (!s->inic) printf("não inicializada.\n");
					else if (!s->ref) printf("não referênciada.\n");
				}
			}
		}
}
