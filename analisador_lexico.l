%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

// Arquivo de saída
FILE *output_file;

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


// Função para adicionar uma variável simples na tabela de símbolos
void add_identifier(char *id, char *type) {
    int idx = find_identifier(id);
    if (idx == -1) {
        strcpy(identifiers[identifier_count].id, id);
        strcpy(identifiers[identifier_count].type, type);
        identifier_count++;
        fprintf(output_file, "<id, %d> ", identifier_count);
    } else {
        fprintf(output_file, "<id, %d> ", idx + 1);
    }
}

%}

DIGIT [0-9]+
ID [a-zA-Z_][a-zA-Z0-9]*
FLOAT [0-9]+\.[0-9]+
WHITESPACE [ \t\n]+
STRING \"(\\.|[^\"\\])*\"

%option noyywrap

%%
int       { fprintf(output_file, "<int> "); }
float     { fprintf(output_file, "<float> "); }
char      { fprintf(output_file, "<char> "); }
void      { fprintf(output_file, "<void> "); }
public    { fprintf(output_file, "<public> "); }
printf    { fprintf(output_file, "<printf> "); }
scanf    { fprintf(output_file, "<scanf> "); }
exit    { fprintf(output_file, "<exit> "); }
static    { fprintf(output_file, "<static> "); }
args      { fprintf(output_file, "<args> "); }
if        { fprintf(output_file, "<if> "); }
else      { fprintf(output_file, "<else> "); }
for       { fprintf(output_file, "<for> "); }
while     { fprintf(output_file, "<while> "); }
break     { fprintf(output_file, "<break> "); }
switch    { fprintf(output_file, "<switch> "); }
case      { fprintf(output_file, "<case> "); }
default   { fprintf(output_file, "<default> "); }
do        { fprintf(output_file, "<do> "); }
typedef   { fprintf(output_file, "<typedef> "); }
struct    { fprintf(output_file, "<struct> "); }
return    { fprintf(output_file, "<return> "); }
"="       { fprintf(output_file, "<= > "); }
"&&"      { fprintf(output_file, "<&&> "); }
"||"      { fprintf(output_file, "<||> "); }
"=="      { fprintf(output_file, "<==> "); }
"<"       { fprintf(output_file, "<< > "); }
"<="      { fprintf(output_file, "<<= > "); }
">"       { fprintf(output_file, "<> > "); }
">="      { fprintf(output_file, "<>= > "); }
"!="      { fprintf(output_file, "<!= > "); }
"+"       { fprintf(output_file, "<+> "); }
"-"       { fprintf(output_file, "<-> "); }
"*"       { fprintf(output_file, "<*> "); }
"/"       { fprintf(output_file, "</> "); }
"("       { fprintf(output_file, "<(> "); }
")"       { fprintf(output_file, "<)> "); }
"["       { fprintf(output_file, "<[> "); }
"]"       { fprintf(output_file, "<]> "); }
"{"       { fprintf(output_file, "<{> "); }
"}"       { fprintf(output_file, "<}> "); }
","       { fprintf(output_file, "<,> "); }
";"       { fprintf(output_file, "<;> "); }
"%"       { fprintf(output_file, "<%%> "); }
"++"      { fprintf(output_file, "<++> "); }
"--"      { fprintf(output_file, "<--> "); }
"&"       { fprintf(output_file, "<&> "); }
"|"       { fprintf(output_file, "<|> "); }
"~"       { fprintf(output_file, "<~> "); }
"^"       { fprintf(output_file, "<^> "); }
"!"       { fprintf(output_file, "<!> "); }
"+="      { fprintf(output_file, "<+=> "); }
"-="      { fprintf(output_file, "<-=> "); }
":"       { fprintf(output_file, "<:> "); }
"?"       { fprintf(output_file, "<?> "); }
"#"       { fprintf(output_file, "<#> "); }
"->"      { fprintf(output_file, "<-> > "); }

{DIGIT}          { fprintf(output_file, "<num, %s> ", yytext); }
{FLOAT}          { fprintf(output_file, "<num, %s> ", yytext); }
{ID}             { add_identifier(yytext, "unknown"); }
{STRING}         { fprintf(output_file, "<str, %s> ", yytext); }
"//".*           { /* Ignora comentários de linha única */ }
"/*"([^*]|\*+[^*/])*\*+"/" { /* Ignora comentários de múltiplas linhas */ }

{WHITESPACE}     { /* Ignora espaços em branco */ }

.                { fprintf(output_file, "<invalido, %s> ", yytext); }

%%

int main() {
    // Abre o arquivo de saída
    output_file = fopen("output.lex", "w");
    if (!output_file) {
        printf("Erro ao abrir o arquivo de saída.\n");
        return 1;
    }

    // Executa o analisador léxico
    yylex();

    // Fecha o arquivo de saída
    fclose(output_file);
    return 0;
}
