%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

// Estrutura para armazenar identificadores na tabela de símbolos
typedef struct {
    char id[100];
    char type[10];
} Identifier;

Identifier identifiers[100];
int identifier_count = 0;

// Função para encontrar um identificador na tabela de símbolos
int find_identifier(char *id) {
    for (int i = 0; i < identifier_count; i++) {
        if (strcmp(identifiers[i].id, id) == 0) {
            return i;
        }
    }
    return -1;
}

// Função para adicionar um identificador na tabela de símbolos
int add_identifier(char *id, char *type) {
    int idx = find_identifier(id);
    if (idx == -1) {
        strcpy(identifiers[identifier_count].id, id);
        strcpy(identifiers[identifier_count].type, type);
        identifier_count++;
        printf("<id, %d> ", identifier_count);
        return identifier_count - 1;
    } else {
        printf("<id, %d> ", idx + 1);
        return idx;
    }
}
%}

DIGIT [0-9]+
ID [a-zA-Z_][a-zA-Z0-9]*
FLOAT [0-9]+\.[0-9]+
WHITESPACE [ \t\n]+
STRING \"(\\.|[^"\\])*\"

%option noyywrap

%%
int       { printf("<int> "); }
float     { printf("<float> "); }
void      { printf("<void> "); }
public    { printf("<public> "); }
static    { printf("<static> "); }
args      { printf("<args> "); }
if        { printf("<if> "); }
else      { printf("<else> "); }
for       { printf("<for> "); }
while     { printf("<while> "); }
return    { printf("<return> "); }
printf     { printf("<printf> "); }
"="       { printf("<= > "); }
"=="      { printf("<==> "); }
"<"       { printf("<< > "); }
"<="      { printf("<<= > "); }
">"       { printf("<> > "); }
">="      { printf("<>= > "); }
"!="      { printf("<!= > "); }
"+"       { printf("<+> "); }
"-"       { printf("<-> "); }
"*"       { printf("<*> "); }
"/"       { printf("</> "); }
"("       { printf("<(> "); }
")"       { printf("<)> "); }
"["       { printf("<[> "); }
"]"       { printf("<]> "); }
"{"       { printf("<{> "); }
"}"       { printf("<}> "); }
","       { printf("<,> "); }
";"       { printf("<;> "); }

{DIGIT}          { printf("<num, %s> ", yytext); }
{FLOAT}          { printf("<num, %s> ", yytext); }
{ID}             { add_identifier(yytext, "unknown"); }
{STRING}         { printf("<str, %s> ", yytext); }

"//".*           { /* Ignora comentários de linha única */ }
"/*"([^*]|\*+[^*/])*\*+"/" { /* Ignora comentários de múltiplas linhas */ }

{WHITESPACE}     { /* Ignora espaços em branco */ }

.                { printf("<invalido, %s> ", yytext); }
%%

int main() {
    yylex();
    return 0;
}
