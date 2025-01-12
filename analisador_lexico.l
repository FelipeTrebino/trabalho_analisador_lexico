%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

// Estrutura para armazenar identificadores na tabela de símbolos
typedef struct {
    char id[100];
    char type[10];
    int size;  // Armazena o tamanho do vetor (se aplicável)
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

// Função para adicionar uma variável simples na tabela de símbolos
void add_variable(char *id, char *type) {
    int idx = find_identifier(id);
    if (idx == -1) {
        strcpy(identifiers[identifier_count].id, id);
        strcpy(identifiers[identifier_count].type, type);
        identifiers[identifier_count].size = 0;
        identifier_count++;
        printf("<id, %d> ", identifier_count);
    } else {
        printf("<id, %d> ", idx + 1);
    }
}

// Função para adicionar um vetor na tabela de símbolos
void add_vector(char *id, char *type, int size) {
    if (find_identifier(id) == -1) {
        strcpy(identifiers[identifier_count].id, id);
        strcpy(identifiers[identifier_count].type, type);
        identifiers[identifier_count].size = size;
        identifier_count++;
        printf("<vetor_decl, %s, %d> ", id, size);
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
printf    { printf("<printf> "); }
"="       { printf("<= > "); }
"&&"       { printf("<&&> "); }
"||"       { printf("<||> "); }
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


(int|float)[ ]+{ID}\[{DIGIT}\] { 
    char var_name[100];
    int size;
    printf("<int> "); 
    sscanf(yytext, "%*s %[^[[][%d]", var_name, &size);
    add_vector(var_name, "vetor", size);
}

{ID}\[{DIGIT}\] { 
    char var_name[100];
    int index;
    sscanf(yytext, "%[^[[][%d]", var_name, &index);
    printf("<vetor_acesso, %s, %d> ", var_name, index);
}

{DIGIT}          { printf("<num, %s> ", yytext); }
{FLOAT}          { printf("<num, %s> ", yytext); }
{ID}             { add_variable(yytext, "unknown"); }
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
