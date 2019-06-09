%{
void comentario (void);
%}
delim		[ \t\n\r]
ws		{delim}+
digito		[0-9]
letra		[A-Za-z]
id		{letra}({letra}|{digito})*
intct		{digito}+
char		\\.|[^\\']
charct		'{char}'
floatct		{digito}+\.{digito}*([eE][+-]?{digito}+)?
str 		\\.|[^\\\"]
string		\"{str}*\"

%%
{ws}		{ ;}
call		{return CALL;}
char		{return CHAR;}
do		{return DO;}
else		{return ELSE;}
false		{return FALSE;}
float		{return FLOAT;}
for		{return FOR;}
functions	{return FUNCTIONS;}
global		{return GLOBAL;}
if		{return IF;}
int		{return INT;}
local		{return LOCAL;}
logic		{return LOGIC;}
main		{return MAIN;}
program		{return PROGRAM;}
read		{return READ;}
return		{return RETURN;}
statements	{return STATEMENTS;}
true		{return TRUE;}
void		{return VOID;}
while		{return WHILE;}
write		{return WRITE;}

{id}		{strcpy (yylval.string, yytext); return ID;}
{intct}		{yylval.valint = atoi(yytext); return INTCT;}
{charct}	{strcpy (yylval.string, yytext); return CHARCT;}
{floatct}	{yylval.valreal = atof(yytext); return FLOATCT;}
{string}	{strcpy (yylval.string, yytext); return STRING;}

"||"		{return OR;}
"&&"		{return AND;}
"!"		{return NOT;}
"<"		{yylval.atr = LT; return RELOP;}
"<="		{yylval.atr = LE; return RELOP;}
">"		{yylval.atr = GT; return RELOP;}
">="		{yylval.atr = GE; return RELOP;}
"="		{yylval.atr = EQ; return RELOP;}
"!="		{yylval.atr = NE; return RELOP;}
"+"		{yylval.atr = PLUS;  return ADOP;}
"-"		{yylval.atr = MINUS; return ADOP;}
"*"		{yylval.atr = TIMES; 	return MULTOP;}
"/"		{yylval.atr = DIVIDED; 	return MULTOP;}
"%"		{yylval.atr = REST; 	return MULTOP;}
"~"		{return NEG;}

"<-"		{return ASSIGN;}
"("		{return OPPAR;}
")"		{return CLPAR;}
"["		{return OPBRAK;}
"]"		{return CLBRAK;}
"{"		{return OPBRACE;}
"}"		{return CLBRACE;}
";"		{return SCOLON;}
","		{return COMMA;}
":"		{return COLON;}

.		{yylval.carac = yytext[0]; return INVAL;}
"/*"		{comentario ();}
%%

void comentario() {
	char c;
	int estado = 1;
	while (estado != 3) {
		switch (estado) {
			case 1:
				c = input();
				if (c == EOF) estado = 3;
				else if (c == '*') estado = 2;
				break;
			case 2:
				c = input();
				if (c == EOF || c == '/') estado = 3;
				else if (c == '*') estado = 2;
				else estado = 1;
				break;
			case 3:
				break;
		}
	}
}
