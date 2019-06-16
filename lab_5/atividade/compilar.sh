#!/bin/bash

# Ação de erro
if [ $# -lt 1 ]; then
   echo "Utilização incorreta"
   exit 1
fi

clear

# Analisador léxico
if [ -e "$1.l" ]; then
	echo "Compilando $1.l"
	flex $1.l
fi

# Analisador sintático
if [ -e "$1.y" ]; then
	echo "Compilando $1.y"
	yacc $1.y
fi

echo "Compilando $1"
echo ""

gcc y.tab.c main.c yyerror.c -o $1 -w -lfl

# Executar
if [ -e "testes/$1.dat" ]; then
	./$1 < testes/$1.dat
else
	./$1
fi

# Remover arquivos temporários
if [ -e "lex.yy.c" ]; then
	rm lex.yy.c
fi
rm y.tab.c $1
