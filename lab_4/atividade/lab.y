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
	int tid, tvar;
	char inic, ref;
	simbolo prox;
};

/*  Variaveis globais para a tabela de simbolos e analise semantica */

int tipocorrente, emfuncao;
simbolo tabsimb[NCLASSHASH];
simbolo simb;

/*
	Prototipos das funcoes para a tabela de simbolos
    	e analise semantica
 */

void tabular();
void InicTabSimb (void);
void ImprimeTabSimb (void);
simbolo InsereSimb (char *, int, int);
int hash (char *);
simbolo ProcuraSimb (char *);
void DeclaracaoRepetida (char *);
void TipoInadequado (char *);
void NaoDeclarado (char *);
void VerificaInicRef();
void Incompatibilidade(char *);

%}

/* Definicao do tipo de yylval e dos atributos dos nao terminais */

%union {
	char string[50];
	int atr, valint;
	float valreal;
	char carac;
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


%%

/* Producoes da gramatica:

	Os terminais sao escritos e, depois de alguns,
	para alguma estetica, ha mudanca de linha       */


Prog		:	{InicTabSimb();} PROGRAM ID OPBRACE {printf("program %s ", $3);tabular();printf("\n\{\n\n"); InsereSimb($3, IDPROG, NAOVAR);}
				GlobDecls Functions CLBRACE {tabular();printf("}\n"); VerificaInicRef(); ImprimeTabSimb();}
			;

GlobDecls 	:
			|	GLOBAL COLON {tabular();printf("global :\n");tab++;}
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
				if(ProcuraSimb($1) != NULL) DeclaracaoRepetida($1);
				else InsereSimb($1, IDVAR, tipocorrente);} Dims
			;

Dims 		:
			| 	OPBRAK {printf("[");} DimList CLBRAK {printf("]");}
			;

DimList 	: 	INTCT {printf("%d", $1);}
			| 	DimList COMMA INTCT {printf(", %d", $3);}
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

Header 		: 	MAIN {printf("main \n");}
			| 	Type ID OPPAR {printf("%s (", $2);
				if(ProcuraSimb($2) != NULL) DeclaracaoRepetida($2);
				else InsereSimb($2, IDFUNC, NAOVAR);}
				Params CLPAR {printf(")\n");}
			;

Params 		:
			| 	ParamList;

ParamList 	: 	Parameter
			| 	ParamList COMMA {printf(", ");} Parameter
			;

Parameter 	: 	Type ID {printf("%s", $2);}
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

IfStat 		: 	IF OPPAR {tabular();printf("if (");tab++;} Expression CLPAR {printf(")\n");} Statement {tab--;} ElseStat
			;

ElseStat 	:
			| 	ELSE {tabular();printf("else\n");tab++;} Statement {tab--;}
			;

WhileStat 	: 	WHILE OPPAR {tabular();printf("while (");tab++;} Expression CLPAR {printf(")\n");} Statement {tab--;}
			;

DoStat 		: 	DO {tabular();printf("do ");tab++;} Statement
				WHILE OPPAR {tab--;tabular();printf("while (");} Expression CLPAR SCOLON  {printf(");");}
			;

ForStat 	: 	FOR OPPAR {tabular();printf("for (");tab++;} Variable
				ASSIGN {printf(" <- ");} Expression
				SCOLON {printf("; ");} Expression
				SCOLON {printf("; ");} Variable
				ASSIGN {printf(" <- ");} Expression
				CLPAR {printf(")\n");} Statement {tab--;}
			;

ReadStat 	: 	READ OPPAR {tabular();printf("read (");} ReadList CLPAR SCOLON {printf(");\n");}
			;

ReadList 	: 	Variable
			| 	ReadList COMMA {printf(", ");} Variable
			;

WriteStat 	: 	WRITE OPPAR {tabular();printf("write (");} WriteList CLPAR SCOLON {printf(");\n");}
			;

WriteList 	: 	WriteElem
			| 	WriteList COMMA {printf(", ");} WriteElem
			;

WriteElem 	: 	STRING {printf("%s", $1);}
			|	Expression
			;

CallStat 	: 	CALL {tabular();printf("call ");} FuncCall SCOLON {printf(";\n");}
			;

FuncCall 	: 	ID OPPAR {printf("%s (", $1);} Arguments CLPAR {printf(")");}
			;

Arguments 	:
			| 	ExprList
			;

ReturnStat 	: 	RETURN SCOLON {tabular();printf("return;\n");}
			| 	RETURN {tabular();printf("return ");} Expression SCOLON {printf(";\n");}
			;

AssignStat 	: 	{tabular();} Variable
 				ASSIGN {printf(" <- ");} Expression SCOLON {printf(";\n");}
				;

ExprList 	: 	Expression
			| 	ExprList COMMA {printf(" , ");} Expression
			;

Expression 	:	AuxExpr1
			| 	Expression OR {printf(" || ");} AuxExpr1
			;

AuxExpr1 	:	AuxExpr2
			| 	AuxExpr1 AND{printf(" && ");} AuxExpr2
			;

AuxExpr2 	: 	AuxExpr3
			| 	NOT {printf("!");} AuxExpr3
			;

AuxExpr3 	: 	AuxExpr4
			| 	AuxExpr4 RELOP {
				if ($2 == LT) printf(" < ");
				else if ($2 == LE) printf(" <= ");
				else if ($2 == GT) printf(" > ");
				else if ($2 == GE) printf(" >= ");
				else if ($2 == EQ) printf(" = ");
				else printf(" != ");
				} AuxExpr4
				;

AuxExpr4 	: 	Term
			| 	AuxExpr4 ADOP {
				if ($2 == PLUS) printf (" + ");
				else printf (" - ");
				} Term
			;

Term 		: 	Factor
			|	Term MULTOP {
				if ($2 == TIMES) printf (" * ");
				else if ($2 == DIVIDED) printf (" / ");
				else printf (" % ");
				} Factor
		;

Factor 		: 	Variable
			| 	INTCT {printf("%d", $1);}
			| 	FLOATCT {printf("%f", $1);}
			| 	CHARCT {printf("%s", $1);}
			| 	TRUE {printf("true");}
			| 	FALSE {printf("false");}
			| 	NEG {printf("~");} Factor
			| 	OPPAR {printf("(");} Expression CLPAR {printf(")");}
			| 	FuncCall
			;

Variable 	: 	ID {printf("%s", $1);
				simb = ProcuraSimb($1);
				if (simb == NULL) NaoDeclarado($1);
				else if (simb->tid != IDVAR) TipoInadequado($1);} Subscripts
			;

Subscripts 	:
			| 	OPBRAK {printf("[");} SubscrList CLBRAK {printf("]");}
			;

SubscrList 	: 	AuxExpr4
			| 	SubscrList COMMA {printf(", ");} AuxExpr4
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

simbolo ProcuraSimb (char *cadeia) {
	simbolo s; int i;
	i = hash (cadeia);
	for (s = tabsimb[i]; (s!=NULL) && strcmp(cadeia, s->cadeia);
		s = s->prox);
	return s;
}

/*
	InsereSimb (cadeia, tid, tvar): Insere cadeia na tabela de
	simbolos, com tid como tipo de identificador e com tvar como
	tipo de variavel; Retorna um ponteiro para a celula inserida
 */

simbolo InsereSimb (char *cadeia, int tid, int tvar) {
	int i; simbolo aux, s;
	i = hash (cadeia); aux = tabsimb[i];
	s = tabsimb[i] = (simbolo) malloc (sizeof (celsimb));
	s->cadeia = (char*) malloc ((strlen(cadeia)+1) * sizeof(char));
	strcpy (s->cadeia, cadeia);
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
				if (s->tid == IDVAR)
					printf (", %9s, %d, %d",
						nometipvar[s->tvar], s->inic, s->ref);
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
					printf("Variável %10s ", s->cadeia);
					if (!s->inic && !s->ref) printf("não inicializada nem referênciada.\n");
					else if (!s->inic) printf("não inicializada.\n");
					else if (!s->ref) printf("não referênciada.\n");
				}
			}
		}
}
