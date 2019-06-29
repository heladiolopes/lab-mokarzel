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

/* Definicao de constantes para os operadores de quadruplas */

#define		OPOR			1
#define		OPAND	 		2
#define 	OPLT	 		3
#define 	OPLE	 		4
#define		OPGT		    5
#define		OPGE			6
#define		OPEQ			7
#define		OPNE			8
#define		OPMAIS		    9
#define		OPMENOS		    10
#define		OPMULTIP		11
#define		OPDIV			12
#define		OPRESTO		    13
#define		OPMENUN		    14
#define		OPNOT			15
#define		OPATRIB		    16
#define		OPENMOD		    17
#define		NOP			    18
#define		OPJUMP		    19
#define		OPJF			20
#define     PARAM           21
#define     OPREAD          22
#define     OPWRITE         23
#define		OPIND			24
#define		OPINDEX			25
#define		OPATRIBPONT		26
#define		OPCONTAPONT		27
#define		OPRETURN		28
#define		OPCALL			29
#define		OPEXIT			30
#define		OPENFUNC		31
#define		OPJT			32


/* Definicao de constantes para os tipos de operandos de quadruplas */

#define		IDLEOPND		0
#define		VAROPND		    1
#define		INTOPND		    2
#define		REALOPND		3
#define		CHAROPND		4
#define		LOGICOPND	    5
#define		CADOPND		    6
#define		ROTOPND		    7
#define		MODOPND		    8
#define		FUNCOPND		9

/*   Definicao de outras constantes   */

#define 	NCLASSHASH	23
#define		VERDADE		1
#define		FALSO		0
#define 	MAXDIMS		10
#define 	MAXPARS		10

/*	Auxiliar na identação	*/

int tab = 0;

/*  Strings para nomes dos tipos de identificadores  */

char *nometipid[4] = {" ", "IDPROG", "IDVAR", "IDFUNC"};

/*  Strings para nomes dos tipos de variaveis  */

char *nometipvar[6] = {"NAOVAR",
	"INTEIRO", "LOGICO", "REAL", "CARACTERE", "VAZIO"
};

/* Strings para operadores de quadruplas */

char *nomeoperquad[31] = {"",
	"OR", "AND", "LT", "LE", "GT", "GE", "EQ", "NE", "MAIS",
	"MENOS", "MULT", "DIV", "RESTO", "MENUN", "NOT", "ATRIB",
	"OPENMOD", "NOP", "JUMP", "JF", "PARAM", "READ", "WRITE",
	"IND", "INDEX", "ATRIBPONT", "CONTAPONT", "RETURN", "CALL",
	"EXIT", "OPENFUNC", "JT"
};

/*
	Strings para tipos de operandos de quadruplas
 */

char *nometipoopndquad[10] = {"IDLE",
	"VAR", "INT", "REAL", "CARAC", "LOGIC", "CADEIA", "ROTULO", "MODULO",
	"FUNCAO"
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
	int relacionado;
};

/*  Variaveis globais para a tabela de simbolos e analise semantica */

int tipocorrente, ehfuncao, ehatrib = FALSO, ehindex;
char *escopocorrente;
simbolo tabsimb[NCLASSHASH];
simbolo simb, fcall;

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

/* Declaracoes para a estrutura do codigo intermediario */

typedef union atribopnd atribopnd;
typedef struct operando operando;
typedef struct celquad celquad;
typedef celquad *quadrupla;
typedef struct celmodhead celmodhead;
typedef celmodhead *modhead;

union atribopnd {
	simbolo simb; int valint; float valfloat;
	char valchar; char vallogic; char *valcad;
	quadrupla rotulo; modhead modulo;
};

struct operando {
	int tipo; atribopnd atr;
};

struct celquad {
	int num, oper; operando opnd1, opnd2, result;
	quadrupla prox;
};

struct celmodhead {
	simbolo modname; modhead prox;
	quadrupla listquad;
};

/* Variaveis globais para o codigo intermediario */

quadrupla quadcorrente, quadaux, quadaux2, quadread;
modhead codintermed, modcorrente;
int oper, numquadcorrente;
operando opnd1, opnd2, result, opndaux;
int numtemp;
const operando opndidle = {IDLEOPND, 0};

/* Prototipos das funcoes para o codigo intermediario */

void InicCodIntermed (void);
void InicCodIntermMod (simbolo);
void ImprimeQuadruplas (void);
quadrupla GeraQuadrupla (int, operando, operando, operando);
simbolo NovaTemp (int, char*);
void RenumQuadruplas (quadrupla, quadrupla);

/* Declaracoes para atributos das expressoes e variaveis */

typedef struct infoexpressao infoexpressao;
struct infoexpressao {
	int tipo;
	operando opnd;
};

typedef struct infovariavel infovariavel;
struct infovariavel {
	simbolo simb;
	operando opnd;
};

typedef struct infofuncao infofuncao;
struct infofuncao {
	int tipo;
	simbolo simb;
	operando opnd;
};

%}

/* Definicao do tipo de yylval e dos atributos dos nao terminais */

%union {
	char string[50];
	int atr, valint;
	float valreal;
	char carac;
	simbolo simb;
	infoexpressao infoexpr;
	infovariavel infovar;
	infofuncao infofunc;
	int tipoexpr, nsubscr, nparam, nargs;
	quadrupla quad;
}

/* Declaracao dos atributos dos tokens e dos nao-terminais */


%token					CALL
%token					CHAR
%token					DO
%token					ELSE
%token					FALSE
%token					FLOAT
%token					FOR
%token					FUNCTIONS
%token					GLOBAL
%token					IF
%token					INT
%token					LOCAL
%token					LOGIC
%token					MAIN
%token					PROGRAM
%token					READ
%token					RETURN
%token					STATEMENTS
%token					TRUE
%token					VOID
%token					WHILE
%token					WRITE
%token		<string>	ID
%token		<valint>	INTCT
%token		<carac>		CHARCT
%token		<valreal>	FLOATCT
%token		<string>	STRING
%token					OR
%token					AND
%token					NOT
%token		<atr>		RELOP
%token		<atr>		ADOP
%token		<atr>		MULTOP
%token					NEG
%token					ASSIGN
%token					OPPAR
%token					CLPAR
%token					OPBRAK
%token					CLBRAK
%token					OPBRACE
%token					CLBRACE
%token					SCOLON
%token					COMMA
%token					COLON
%token		<carac>		INVAL

%type 		<infovar>	Variable
%type 	    <infoexpr> 	Expression  AuxExpr1	AuxExpr2
                        AuxExpr3	AuxExpr4	Term	Factor
						WriteElem
%type 		<infofunc>	FuncCall
%type   	<nsubscr>   Subscripts  SubscrList
%type		<nparam>	Arguments	ExprList
%type		<nargs>		ReadList	WriteList

%%

/* Producoes da gramatica:

	Os terminais sao escritos e, depois de alguns,
	para alguma estetica, ha mudanca de linha       */


Prog		:	{
					InicTabSimb();
					InicCodIntermed (); numtemp = 0;
				} PROGRAM ID OPBRACE {
					printf("program %s ", $3);
					tabular(); printf("\n\{\n\n");
					simb = InsereSimb($3, IDPROG, NAOVAR, "Programa");
					InicCodIntermMod(simb);
					opnd1.tipo = MODOPND;
					opnd1.atr.modulo = modcorrente;
					GeraQuadrupla(OPENMOD, opnd1, opndidle, opndidle);
				} GlobDecls Functions CLBRACE {
					tabular();
					printf("}\n");

					// Call na main
					quadrupla p = codintermed->prox->listquad->prox;
					while (p->prox != NULL)
						p = p->prox;
					quadcorrente = p;
					opnd1.tipo = FUNCOPND;	opnd1.atr.simb = ProcuraSimb("Main", "Global");
					opnd2.tipo = INTOPND; 	opnd2.atr.valint = 0;
					numquadcorrente=1;
					GeraQuadrupla (OPCALL, opnd1, opnd2, opndidle);
					GeraQuadrupla (OPEXIT, opndidle, opndidle, opndidle);

					VerificaInicRef();
					ImprimeTabSimb();
					ImprimeQuadruplas();
				}
			;

GlobDecls 	:
			|	GLOBAL COLON {
					tabular(); printf("global :\n"); tab++;
					free(escopocorrente);
					escopocorrente = (char*) malloc ((strlen("Global")+1) * sizeof(char));
					strcpy(escopocorrente, "Global");
				} DeclList {tab--;printf("\n");}
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
			| 	ElemList COMMA {printf(", ");} Elem
			;

Elem 		: 	ID {
					printf("%s", $1);
					simbolo aux = ProcuraSimb($1, escopocorrente);
					if (aux != NULL && strcmp(aux->escopo, escopocorrente) == 0)
						DeclaracaoRepetida($1);
					else { simb = InsereSimb($1, IDVAR, tipocorrente, escopocorrente);
							simb->array = FALSO;
							simb->ndims = 0;
					}
				} Dims
			;

Dims 		:
			| 	OPBRAK {printf("[");} DimList CLBRAK {printf("]"); simb->array = VERDADE;}
			;

DimList 	: 	INTCT {
					printf("%d", $1);
					if($1 <= 0) Esperado("Valor inteiro positivo");
					simb->ndims++;
					simb->dims[simb->ndims] = $1;
				}
			| 	DimList COMMA INTCT {
					printf(", %d", $3);
					if($3 <= 0) Esperado("Valor inteiro positivo");
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

Header 		: 	MAIN {
					printf("main \n");
					free(escopocorrente);
					escopocorrente = (char*) malloc ((strlen("Main")+1) * sizeof(char));
					strcpy(escopocorrente, "Main");
					if(ProcuraSimb("Main", "Global") != NULL)
						DeclaracaoRepetida("Main");
					else {
							simb = InsereSimb("Main", IDFUNC, NAOVAR, "Global");
							InicCodIntermMod(simb);
							opnd1.tipo = MODOPND;
							opnd1.atr.modulo = modcorrente;
							GeraQuadrupla(OPENMOD, opnd1, opndidle, opndidle);
							simb->parameter = FALSO;
							simb->npars = 0;
						}
				}

			| 	Type ID OPPAR {
					printf("%s (", $2);
					free(escopocorrente);
					escopocorrente = (char*) malloc ((strlen($2)+1) * sizeof(char));
					strcpy(escopocorrente, $2);
					if(ProcuraSimb($2, "Global") != NULL)
						DeclaracaoRepetida($2);
					else {
							simb = InsereSimb($2, IDFUNC, tipocorrente, "Global");
							InicCodIntermMod(simb);
							opnd1.tipo = MODOPND;
							opnd1.atr.modulo = modcorrente;
							GeraQuadrupla(OPENMOD, opnd1, opndidle, opndidle);
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

Stats 		: 	STATEMENTS COLON {tabular();printf("statements :\n");tab++;} StatList {
					tab--;
					if (quadcorrente->oper != OPRETURN)
						GeraQuadrupla(OPRETURN, opndidle, opndidle, opndidle);
				}
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

IfStat 		: 	IF OPPAR {tabular();printf("if (");tab++;} Expression {
					if ($4.tipo != LOGICO)
						Incompatibilidade ("Expressao nao logica em comando if");
					opndaux.tipo = ROTOPND;
					$<quad>$ = GeraQuadrupla (OPJF, $4.opnd, opndidle, opndaux);
				} CLPAR {printf(")\n");} Statement {tab--;
					$<quad>$ = quadcorrente;
					$<quad>5->result.atr.rotulo = GeraQuadrupla (NOP, opndidle, opndidle, opndidle);
				} ElseStat {
					if ($<quad>9->prox != quadcorrente) {
						quadaux = $<quad>9->prox;
						$<quad>9->prox = quadaux->prox;
						quadaux->prox = $<quad>9->prox->prox;
						$<quad>9->prox->prox = quadaux;
						RenumQuadruplas ($<quad>9, quadcorrente);
					}
				}
			;

ElseStat 	:
			| 	ELSE {
					tabular();printf("else\n");tab++;
					opndaux.tipo = ROTOPND;
					$<quad>$ = GeraQuadrupla (OPJUMP, opndidle, opndidle, opndaux);
				} Statement {
					tab--;
					$<quad>2->result.atr.rotulo = GeraQuadrupla (NOP, opndidle, opndidle, opndidle);
				}
			;

WhileStat 	: 	WHILE OPPAR {
					tabular();printf("while (");tab++;
					$<quad>$ = GeraQuadrupla (NOP, opndidle, opndidle, opndidle);
				} Expression CLPAR {
					printf(")\n");
					if ($4.tipo != LOGICO)
						Incompatibilidade("Expressao deve ser logica ou relacional");
					opndaux.tipo = ROTOPND;
					$<quad>$ = GeraQuadrupla (OPJF, $4.opnd, opndidle, opndaux);
				} Statement {tab--;
					opndaux.tipo = ROTOPND;
					$<quad>$ = GeraQuadrupla(OPJUMP, opndidle, opndidle, opndaux);
					$<quad>$->result.atr.rotulo = $<quad>3;
					$<quad>6->result.atr.rotulo = GeraQuadrupla (NOP, opndidle, opndidle, opndidle);
				}
			;

DoStat 		: 	DO {
					tabular();printf("do ");tab++;
					$<quad>$ = GeraQuadrupla(NOP, opndidle, opndidle, opndidle);
				} Statement
				WHILE OPPAR {tab--;tabular();printf("while (");} Expression CLPAR SCOLON {
					printf(");");
					if ($7.tipo != LOGICO)
						Incompatibilidade("Expressao deve ser logica ou relacional");
					opndaux.tipo = ROTOPND;
					opndaux.atr.rotulo = $<quad>2;
					GeraQuadrupla (OPJT, $7.opnd, opndidle, opndaux);
				}
			;

ForStat 	: 	FOR OPPAR {tabular();printf("for (");tab++;} Variable {
					if ($4.simb != NULL){
						$4.simb->inic = $4.simb->ref = VERDADE;
						if ($4.simb->tvar != INTEIRO && $4.simb->tvar != CARACTERE)
							Incompatibilidade("Variavel de inicializacao deve ser inteiro ou caractere");
					}
				}
				ASSIGN {printf(" <- ");} Expression
				SCOLON {
					printf("; ");
					GeraQuadrupla (OPATRIB, $8.opnd, opndidle, $4.opnd);
					$<quad>$ = GeraQuadrupla(NOP, opndidle, opndidle, opndidle);
				} Expression {
					opndaux.tipo = ROTOPND;
					$<quad>$ = GeraQuadrupla (OPJF, $11.opnd, opndidle, opndaux);
				}
				SCOLON {
					printf("; ");
					$<quad>$ = GeraQuadrupla(NOP, opndidle, opndidle, opndidle);
				} Variable {
					if ($4.simb != NULL && strcmp($4.simb->cadeia, $15.simb->cadeia))
						Incompatibilidade("Variavel de atualizacao deve ser a mesma de inicializacao");
				}
				ASSIGN {printf(" <- ");} Expression {
					if ($4.simb != NULL && $8.tipo != NULL &&
						!((($8.tipo == INTEIRO && $19.tipo == INTEIRO) ||
						($8.tipo == CARACTERE && $19.tipo == CARACTERE)) &&
						($11.tipo == LOGICO)))
						Incompatibilidade("Expressoes do for invalida");
					GeraQuadrupla (OPATRIB, $19.opnd, opndidle, $15.opnd);
				}
				CLPAR {
					printf(")\n");
					$<quad>$ = quadcorrente;
				} {
					$<quad>$ = GeraQuadrupla (NOP, opndidle, opndidle, opndidle);
				} Statement {tab--;
					quadaux = quadcorrente;
					opndaux.tipo = ROTOPND;  opndaux.atr.rotulo = $<quad>10;
					quadaux2 = GeraQuadrupla (OPJUMP, opndidle, opndidle, opndaux);
					$<quad>12->result.atr.rotulo = GeraQuadrupla (NOP, opndidle, opndidle, opndidle);

					$<quad>12->prox = $<quad>23;
					quadaux->prox = $<quad>14;
					$<quad>22->prox = quadaux2;
					RenumQuadruplas ($<quad>12,	quadcorrente);
				}
			;

ReadStat 	: 	READ OPPAR {tabular();printf("read (");ehatrib=VERDADE;} ReadList {
					if ($4 > 0){
						opnd1.tipo = INTOPND;
						opnd1.atr.valint = $4;
						GeraQuadrupla (OPREAD, opnd1, opndidle, opndidle);
					}
				} CLPAR SCOLON {printf(");\n");ehatrib=FALSO;}
			;

ReadList 	: 	Variable {
					if ($1.simb->relacionado){

						simb = $1.opnd.atr.simb;
						$1.opnd.atr.simb = NovaTemp($1.opnd.atr.simb->tvar, escopocorrente);

						if ($1.simb != NULL)
							$1.simb->inic = $1.simb->ref = VERDADE;
						$$ = 0;
						GeraQuadrupla (PARAM, $1.opnd, opndidle, opndidle);

						opnd1.tipo = INTOPND;
						opnd1.atr.valint = 1;
						GeraQuadrupla(OPREAD, opnd1, opndidle, opndidle);
						opndaux.tipo = VAROPND;
						opndaux.atr.simb = simb;
						quadread = GeraQuadrupla(OPATRIBPONT, $1.opnd, opndidle, opndaux);
					}
					else {
						if ($1.simb != NULL)
						$1.simb->inic = $1.simb->ref = VERDADE;
						$$ = 1;
						quadread = GeraQuadrupla (PARAM, $1.opnd, opndidle, opndidle);
					}

				}
			| 	ReadList COMMA {printf(", ");} Variable {
					quadrupla aux, q;
					if ($4.simb->relacionado && $1 > 0) {
						opnd1.tipo = INTOPND;
						opnd1.atr.valint = $$;
						aux = GeraQuadrupla (OPREAD, opnd1, opndidle, opndidle);
						$1 = 0;

						if (quadread != NULL){
							aux->prox = quadread->prox;
							quadread->prox = aux;

							q = aux->prox;
							while (q->prox != aux)
								q = q->prox;
							q->prox = NULL;
							RenumQuadruplas(quadread, q->prox);
							quadcorrente = q;
						}
						simb = $4.opnd.atr.simb;
						$4.opnd.atr.simb = NovaTemp($4.opnd.atr.simb->tvar, escopocorrente);
						if ($4.simb != NULL)
							$4.simb->inic = $4.simb->ref = VERDADE;
						$$ = 0;
						quadread = GeraQuadrupla (PARAM, $4.opnd, opndidle, opndidle);
						opnd1.tipo = INTOPND;
						opnd1.atr.valint = 1;
						GeraQuadrupla(OPREAD, opnd1, opndidle, opndidle);
						opndaux.tipo = VAROPND;
						opndaux.atr.simb = simb;
						quadread = GeraQuadrupla(OPATRIBPONT, $4.opnd, opndidle, opndaux);
					} else {
						if ($4.simb != NULL)
						$4.simb->inic = $4.simb->ref = VERDADE;
						$$ = $1 + 1;
						quadread = GeraQuadrupla (PARAM, $4.opnd, opndidle, opndidle);
					}
				}
			;

WriteStat 	: 	WRITE OPPAR {tabular();printf("write (");} WriteList {
					opnd1.tipo = INTOPND;
					opnd1.atr.valint = $4;
					GeraQuadrupla (OPWRITE, opnd1, opndidle, opndidle);
				} CLPAR SCOLON {printf(");\n");}
			;

WriteList 	: 	WriteElem {
					$$ = 1;
					GeraQuadrupla (PARAM, $1.opnd, opndidle, opndidle);
				}
			| 	WriteList COMMA {printf(", ");} WriteElem {
					$$ = $1 + 1;
					GeraQuadrupla (PARAM, $4.opnd, opndidle, opndidle);
				}
			;

WriteElem 	: 	STRING {
					printf("\"%s\"", $1);
					$$.opnd.tipo = CADOPND;
					$$.opnd.atr.valcad = malloc (strlen($1) + 1);
					strcpy ($$.opnd.atr.valcad, $1);
				}
			|	Expression
			;

CallStat 	: 	CALL {tabular();printf("call ");} FuncCall SCOLON {
					printf(";\n");
					if ($3.tipo != VAZIO)
						Incompatibilidade("Funcao chamada por call deve ser void");
				}
			;

FuncCall 	: 	ID OPPAR {
					printf("%s (", $1);
					simb = ProcuraSimb($1, escopocorrente);
					if (simb == NULL)
						NaoDeclarado($1);
					else if (simb->tid != IDFUNC)
						Incompatibilidade("Call deve chamar funcao");
					else
						$<tipoexpr>$ = simb->tvar;

					fcall = ProcuraSimb($1, "Global");

				} Arguments CLPAR {
					printf(")");
					$$.tipo = $<tipoexpr>3;
					$$.simb = fcall;

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

					opnd1.tipo = FUNCOPND;	opnd1.atr.simb = $$.simb;
					opnd2.tipo = INTOPND; opnd2.atr.valint = $4;

					if ($$.simb->tvar == NAOVAR || $$.simb->tvar == VAZIO)
						result = opndidle;
					else {
						result.tipo = VAROPND;
						result.atr.simb = NovaTemp ($$.simb->tvar, escopocorrente);
					}
					GeraQuadrupla (OPCALL, opnd1, opnd2, result);
					$$.opnd = result;
				}
			;

Arguments 	:	{$$ = 0;}
			| 	ExprList {$$ = $1;}
			;

ReturnStat 	: 	RETURN SCOLON {
					tabular(); printf("return;\n");
					simbolo aux = ProcuraSimb(escopocorrente, "Global");
					if (aux->tvar != VAZIO)
						Incompatibilidade("Funcao deve retornar expressao");
					GeraQuadrupla (OPRETURN, opndidle, opndidle, opndidle);
				}
			| 	RETURN {tabular();printf("return ");} Expression SCOLON {
					printf(";\n");
					simbolo aux = ProcuraSimb(escopocorrente, "Global");

					if (aux != NULL){
						if (aux->tvar == VAZIO)
							Incompatibilidade("Funcao void nao tem retorno");
						if (((aux->tvar == INTEIRO ||
							aux->tvar == CARACTERE) &&
							($3.tipo == REAL || $3.tipo == LOGICO)) ||
							(aux->tvar == REAL && $3.tipo == LOGICO) ||
							(aux->tvar == LOGICO && $3.tipo != LOGICO))
							Incompatibilidade ("Retorno improprio");
					}
					GeraQuadrupla (OPRETURN, $3.opnd, opndidle, opndidle);
				}
			;

AssignStat 	: 	{tabular();ehatrib=VERDADE;} Variable {
					if  ($2.simb != NULL)
						$2.simb->inic = $2.simb->ref = VERDADE;
				}
 				ASSIGN {printf(" <- "); ehatrib = FALSO;} Expression SCOLON {
					printf(";\n");
					if ($2.simb != NULL)
						if ((($2.simb->tvar == INTEIRO ||
							$2.simb->tvar == CARACTERE) &&
							($6.tipo == REAL || $6.tipo == LOGICO)) ||
	        				($2.simb->tvar == REAL && $6.tipo == LOGICO) ||
							($2.simb->tvar == LOGICO && $6.tipo != LOGICO))
	    					Incompatibilidade ("Lado direito de comando de atribuicao improprio");
					if (!$2.simb->relacionado)
						GeraQuadrupla (OPATRIB, $6.opnd, opndidle, $2.opnd);
					else
						GeraQuadrupla (OPATRIBPONT, $6.opnd, opndidle, $2.opnd);

				}
			;

ExprList 	: 	{ehfuncao = FALSO;} Expression {
					if ($2.tipo == VAZIO)
						Incompatibilidade("Tipo incompativel de parametro");
					if (ehfuncao)
						Incompatibilidade("Funcao nao pode ser parametro");
					$$ = 1;
					if (((fcall->pars[$$] == INTEIRO ||
						fcall->pars[$$] == CARACTERE) &&
						($2.tipo == REAL || $2.tipo == LOGICO)) ||
						(fcall->pars[$$] == REAL && $2.tipo == LOGICO) ||
						(fcall->pars[$$] == LOGICO && $2.tipo != LOGICO))
						Incompatibilidade("Tipo nao aceito de parâmetro");
					GeraQuadrupla(PARAM, $2.opnd, opndidle, opndidle);

				}
			| 	ExprList COMMA {printf(" , "); ehfuncao = FALSO;} Expression {
					if ($4.tipo == VAZIO)
						Incompatibilidade("Tipo incompativel de parametro");
					if (ehfuncao)
						Incompatibilidade("Funcao nao pode ser parametro");

					$$ = $1 + 1;

					if (((fcall->pars[$$] == INTEIRO ||
						fcall->pars[$$] == CARACTERE) &&
						($4.tipo == REAL || $4.tipo == LOGICO)) ||
						(fcall->pars[$$] == REAL && $4.tipo == LOGICO) ||
						(fcall->pars[$$] == LOGICO && $4.tipo != LOGICO))
						Incompatibilidade("Tipo nao aceito de parâmetro");
					GeraQuadrupla(PARAM, $4.opnd, opndidle, opndidle);
				}
			;

Expression 	:	AuxExpr1
			| 	Expression OR {printf(" || ");} AuxExpr1 {
					if ($1.tipo != LOGICO || $4.tipo != LOGICO)
						Incompatibilidade ("Operando improprio para operador or");
					$$.tipo = LOGICO;
					$$.opnd.tipo = VAROPND;
					$$.opnd.atr.simb = NovaTemp ($$.tipo, escopocorrente);
					GeraQuadrupla (OPOR, $1.opnd, $4.opnd, $$.opnd);
				}
			;

AuxExpr1 	:	AuxExpr2
			| 	AuxExpr1 AND{printf(" && ");} AuxExpr2 {
					if ($1.tipo != LOGICO || $4.tipo != LOGICO)
						Incompatibilidade ("Operando improprio para operador and");
					$$.tipo = LOGICO;
					$$.opnd.tipo = VAROPND;
					$$.opnd.atr.simb = NovaTemp ($$.tipo, escopocorrente);
					GeraQuadrupla (OPAND, $1.opnd, $4.opnd, $$.opnd);
				}
			;

AuxExpr2 	: 	AuxExpr3
			| 	NOT {printf("!");} AuxExpr3 {
					if ($3.tipo != LOGICO)
						Incompatibilidade ("Operando improprio para operador not");
					$$.tipo = LOGICO;
					$$.opnd.tipo = VAROPND;
					$$.opnd.atr.simb = NovaTemp ($$.tipo, escopocorrente);
					GeraQuadrupla (OPNOT, $3.opnd, opndidle, $$.opnd);
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
							if ($1.tipo != INTEIRO && $1.tipo != REAL && $1.tipo != CARACTERE ||
								$4.tipo != INTEIRO && $4.tipo != REAL && $4.tipo != CARACTERE)
								Incompatibilidade	("Operando improprio para operador relacional");
							break;
						case EQ: case NE:
							if (($1.tipo == LOGICO || $4.tipo == LOGICO) && $1.tipo != $4.tipo)
								Incompatibilidade ("Operando improprio para operador relacional");
							break;
					}
					$$.tipo = LOGICO;
					$$.opnd.tipo = VAROPND;
					$$.opnd.atr.simb = NovaTemp ($$.tipo, escopocorrente);
					int op;
					switch($2){
						case LT: op = OPLT; break;
						case LE: op = OPLE; break;
						case EQ: op = OPEQ; break;
						case NE: op = OPNE; break;
						case GT: op = OPGT; break;
						case GE: op = OPGE; break;

					}
					GeraQuadrupla (op, $1.opnd, $4.opnd, $$.opnd);
				}
			;

AuxExpr4 	: 	Term
			| 	AuxExpr4 ADOP {
					switch ($2) {
						case PLUS: printf (" + "); break;
						case MINUS: printf (" - "); break;
					}
				} Term {
					if ($1.tipo != INTEIRO && $1.tipo != REAL && $1.tipo != CARACTERE ||
						$4.tipo != INTEIRO && $4.tipo != REAL && $4.tipo != CARACTERE)
						Incompatibilidade ("Operando improprio para operador aritmetico");
					if ($1.tipo == REAL || $4.tipo == REAL)
						$$.tipo = REAL;
					else
						$$.tipo = INTEIRO;
					$$.opnd.tipo = VAROPND;
					$$.opnd.atr.simb = NovaTemp ($$.tipo, escopocorrente);
					if ($2 == PLUS)
						GeraQuadrupla (OPMAIS, $1.opnd, $4.opnd, $$.opnd);
					else  GeraQuadrupla (OPMENOS, $1.opnd, $4.opnd, $$.opnd);
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
							if ($1.tipo != INTEIRO && $1.tipo != REAL && $1.tipo != CARACTERE ||
								$4.tipo != INTEIRO && $4.tipo != REAL && $4.tipo != CARACTERE)
								Incompatibilidade ("Operando improprio para operador aritmetico");
							if ($1.tipo == REAL || $4.tipo == REAL)
								$$.tipo = REAL;
							else
								$$.tipo = INTEIRO;
								$$.opnd.tipo = VAROPND;
								$$.opnd.atr.simb = NovaTemp ($$.tipo, escopocorrente);
								if ($2 == TIMES)
									GeraQuadrupla (OPMULTIP, $1.opnd, $4.opnd, $$.opnd);
								else  GeraQuadrupla (OPDIV, $1.opnd, $4.opnd, $$.opnd);
							break;
						case REST:
							if ($1.tipo != INTEIRO && $1.tipo != CARACTERE ||
								$4.tipo != INTEIRO && $4.tipo != CARACTERE)
								Incompatibilidade ("Operando improprio para operador resto");
							$$.tipo = INTEIRO;
							$$.opnd.tipo = VAROPND;
							$$.opnd.atr.simb = NovaTemp ($$.tipo, escopocorrente);
							GeraQuadrupla (OPRESTO, $1.opnd, $4.opnd, $$.opnd);
							break;
					}
				}
		;

Factor 		: 	Variable {
					if ($1.simb != NULL) {
						$1.simb->ref  =  VERDADE;
						$$.tipo = $1.simb->tvar;
						$$.opnd = $1.opnd;
					}
				}
			| 	INTCT {
					printf ("%d", $1); $$.tipo = INTEIRO;
					$$.opnd.tipo = INTOPND;
					$$.opnd.atr.valint = $1;
				}
			| 	FLOATCT {
					printf ("%f", $1); $$.tipo = REAL;
					$$.opnd.tipo = REALOPND;
					$$.opnd.atr.valfloat = $1;
				}
			| 	CHARCT {
					printf ("\'%c\'", $1); $$.tipo = CARACTERE;
					$$.opnd.tipo = CHAROPND;
					$$.opnd.atr.valchar = $1;
				}
			| 	TRUE {
					printf ("true"); $$.tipo = LOGICO;
					$$.opnd.tipo = LOGICOPND;
					$$.opnd.atr.vallogic = 1;
				}
			| 	FALSE {
					printf ("false"); $$.tipo = LOGICO;
					$$.opnd.tipo = LOGICOPND;
					$$.opnd.atr.vallogic = 0;
				}
			| 	NEG {printf("~");} Factor {
					if ($3.tipo != INTEIRO && $3.tipo != REAL && $3.tipo != CARACTERE)
						Incompatibilidade  ("Operando improprio para menos unario");
					if ($3.tipo == REAL)
						$$.tipo = REAL;
					else
						$$.tipo = INTEIRO;
					$$.opnd.tipo = VAROPND;
					$$.opnd.atr.simb = NovaTemp ($$.tipo, escopocorrente);
					GeraQuadrupla  (OPMENUN, $3.opnd, opndidle, $$.opnd);
				}
			| 	OPPAR {printf("(");} Expression CLPAR {
					printf(")"); $$.tipo = $3.tipo; $$.opnd = $3.opnd;}
			| 	FuncCall {
					$$.tipo = $1.tipo;
					if ($1.tipo == VAZIO)
						Incompatibilidade("Funcao nao pode ser void");
					ehfuncao = VERDADE;
					if ($1.simb != NULL){
						$$.tipo = $1.simb->tvar;
						$$.opnd = $1.opnd;
					}
				}
			;

Variable 	: 	ID {
					printf("%s", $1);
					simb = ProcuraSimb($1, escopocorrente);
					if (simb == NULL)
						NaoDeclarado($1);
					else if (simb->tid != IDVAR)
						TipoInadequado($1);
					$<simb>$ = simb;
				}
				Subscripts {
					$$.simb = $<simb>2;
					if ($$.simb != NULL) {
		              	if ($$.simb->array == FALSO && $3 > 0)
		                    NaoEsperado ("Subscrito\(s)");
		                else if ($$.simb->array == VERDADE && $3 == 0)
		                    Esperado ("Subscrito\(s)");
		                else if ($$.simb->ndims != $3)
							Incompatibilidade ("Numero de subscritos incompativel com declaracao");
						$$.opnd.tipo = VAROPND;
						if ($3 == 0)
							$$.opnd.atr.simb = $$.simb;
						else {
							$$.opnd.tipo = VAROPND;
							$$.opnd.atr.simb = NovaTemp ($$.simb->tvar, escopocorrente);

							opndaux.tipo = INTOPND;
							opndaux.atr.valint = $3;

							operando op;
							op.tipo = VAROPND;
							op.atr.simb = ProcuraSimb($1, escopocorrente);

							GeraQuadrupla(OPINDEX, op, opndaux, $$.opnd);
							$$.simb = $$.opnd.atr.simb;

							if(ehatrib == FALSO){
								operando opnd = $$.opnd;
								$$.opnd.atr.simb = NovaTemp($$.simb->tvar, escopocorrente);
								GeraQuadrupla(OPCONTAPONT, opnd, opndidle, $$.opnd);
								$$.simb = $$.opnd.atr.simb;
							}
							$$.simb->relacionado = VERDADE;

						}
      				}
				}
			;

Subscripts 	:	{$$ = 0;}
			| 	OPBRAK {printf("[");} SubscrList CLBRAK {printf("]"); $$ = $3;}
			;

SubscrList 	: 	AuxExpr4 {
					if ($1.tipo != INTEIRO && $1.tipo != CARACTERE)
						Incompatibilidade ("Tipo inadequado para subscrito");
					$$ = 1;
					GeraQuadrupla(OPIND, $1.opnd, opndidle, opndidle);
				}
			| 	SubscrList COMMA {printf(", ");} AuxExpr4 {
					if ($4.tipo != INTEIRO && $4.tipo != CARACTERE)
						Incompatibilidade ("Tipo inadequado para subscrito");
					$$ = $1 + 1;
					GeraQuadrupla(OPIND, $4.opnd, opndidle, opndidle);
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
	s->relacionado = FALSO;
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

/*  Mensagens de erros semanticos  */

void DeclaracaoRepetida (char *s) {
	printf ("\n\n***** Declaracao Repetida: %s *****\n\n", s);
	exit(1);
}

void NaoDeclarado (char *s) {
    printf ("\n\n***** Identificador Nao Declarado: %s *****\n\n", s);
	exit(2);
}

void TipoInadequado (char *s) {
    printf ("\n\n***** Identificador de Tipo Inadequado: %s *****\n\n", s);
	exit(3);
}

void Incompatibilidade (char *s) {
	printf ("\n\n***** Incompatibilidade: %s *****\n\n", s);
	exit(4);
}

void Esperado (char *s) {
	printf ("\n\n***** Esperado: %s *****\n\n", s);
	exit(5);
}

void NaoEsperado (char *s) {
	printf ("\n\n***** Nao Esperado: %s *****\n\n", s);
	exit(6);
}

/* Funcoes para o codigo intermediario */

void InicCodIntermed () {
	modcorrente = codintermed = malloc (sizeof (celmodhead));
    modcorrente->listquad = NULL;
	modcorrente->prox = NULL;
}

void InicCodIntermMod (simbolo simb) {
	modcorrente->prox = malloc (sizeof (celmodhead));
	modcorrente = modcorrente->prox;
	modcorrente->prox = NULL;
	modcorrente->modname = simb;
	modcorrente->listquad = malloc (sizeof (celquad));
	quadcorrente = modcorrente->listquad;
	quadcorrente->prox = NULL;
	numquadcorrente = 0;
	quadcorrente->num = numquadcorrente;
}

quadrupla GeraQuadrupla (int oper, operando opnd1, operando opnd2,
	operando result) {
	quadcorrente->prox = malloc (sizeof (celquad));
	quadcorrente = quadcorrente->prox;
	quadcorrente->oper = oper;
	quadcorrente->opnd1 = opnd1;
	quadcorrente->opnd2 = opnd2;
	quadcorrente->result = result;
	quadcorrente->prox = NULL;
	numquadcorrente ++;
    quadcorrente->num = numquadcorrente;
    return quadcorrente;
}

simbolo NovaTemp (int tip, char *escopo) {
	simbolo simb; int temp, i, j;
	char nometemp[10] = "##", s[10] = {0};

	numtemp ++; temp = numtemp;
	for (i = 0; temp > 0; temp /= 10, i++)
		s[i] = temp % 10 + '0';
	i --;
	for (j = 0; j <= i; j++)
		nometemp[2+i-j] = s[j];
	simb = InsereSimb (nometemp, IDVAR, tip, escopo);
	simb->inic = simb->ref = VERDADE;
    simb->array = FALSO;
	return simb;
}

void ImprimeQuadruplas () {
	modhead p;
	quadrupla q;
	for (p = codintermed->prox; p != NULL; p = p->prox) {
		printf ("\n\nQuadruplas do modulo %s:\n", p->modname->cadeia);
		for (q = p->listquad->prox; q != NULL; q = q->prox) {
			printf ("\n\t%4d) %s", q->num, nomeoperquad[q->oper]);
			printf (", (%s", nometipoopndquad[q->opnd1.tipo]);
			switch (q->opnd1.tipo) {
				case IDLEOPND: break;
				case VAROPND: printf (", %s", q->opnd1.atr.simb->cadeia); break;
				case INTOPND: printf (", %d", q->opnd1.atr.valint); break;
				case REALOPND: printf (", %g", q->opnd1.atr.valfloat); break;
				case CHAROPND: printf (", %c", q->opnd1.atr.valchar); break;
				case LOGICOPND: printf (", %d", q->opnd1.atr.vallogic); break;
				case CADOPND: printf (", %s", q->opnd1.atr.valcad); break;
				case ROTOPND: printf (", %d", q->opnd1.atr.rotulo->num); break;
				case MODOPND: printf(", %s", q->opnd1.atr.modulo->modname->cadeia); break;
				case FUNCOPND: printf(", %s", q->opnd1.atr.simb->cadeia);
				break;
			}
			printf (")");
			printf (", (%s", nometipoopndquad[q->opnd2.tipo]);
			switch (q->opnd2.tipo) {
				case IDLEOPND: break;
				case VAROPND: printf (", %s", q->opnd2.atr.simb->cadeia); break;
				case INTOPND: printf (", %d", q->opnd2.atr.valint); break;
				case REALOPND: printf (", %g", q->opnd2.atr.valfloat); break;
				case CHAROPND: printf (", %c", q->opnd2.atr.valchar); break;
				case LOGICOPND: printf (", %d", q->opnd2.atr.vallogic); break;
				case CADOPND: printf (", %s", q->opnd2.atr.valcad); break;
				case ROTOPND: printf (", %d", q->opnd2.atr.rotulo->num); break;
				case MODOPND: printf(", %s", q->opnd2.atr.modulo->modname->cadeia); break;
				case FUNCOPND: printf(", %s", q->opnd2.atr.simb->cadeia);
					break;
			}
			printf (")");
			printf (", (%s", nometipoopndquad[q->result.tipo]);
			switch (q->result.tipo) {
				case IDLEOPND: break;
				case VAROPND: printf (", %s", q->result.atr.simb->cadeia); break;
				case INTOPND: printf (", %d", q->result.atr.valint); break;
				case REALOPND: printf (", %g", q->result.atr.valfloat); break;
				case CHAROPND: printf (", %c", q->result.atr.valchar); break;
				case LOGICOPND: printf (", %d", q->result.atr.vallogic); break;
				case CADOPND: printf (", %s", q->result.atr.valcad); break;
				case ROTOPND: printf (", %d", q->result.atr.rotulo->num); break;
				case MODOPND: printf(", %s", q->result.atr.modulo->modname->cadeia); break;
				case FUNCOPND: printf(", %s", q->result.atr.simb->cadeia);
					break;
			}
			printf (")");
		}
	}
   printf ("\n");
}

void RenumQuadruplas (quadrupla quad1, quadrupla quad2) {
	quadrupla q; int nquad;
	for (q = quad1->prox, nquad = quad1->num; q != quad2; q = q->prox) {
      nquad++;
		q->num = nquad;
	}
}
