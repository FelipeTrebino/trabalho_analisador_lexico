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
    int size;  // Armazena o tamanho do vetor (se aplicável)
} Identifier;

// Estrutura para armazenar funções na tabela de símbolos
typedef struct {
    char name[100];
    char return_type[10];
    int param_count;
    Identifier parameters[10]; // Parâmetros da função
} Function;


Identifier identifiers[100];
int identifier_count = 0;

Function functions[100];
int function_count = 0;

// Lista de funções reservadas
const char *reserved_functions[] = {"printf", "scanf", "exit", "puts", "gets"};
const int reserved_function_count = sizeof(reserved_functions) / sizeof(reserved_functions[0]);

// Função para verificar se uma função é reservada
int is_reserved_function(char *name) {
    for (int i = 0; i < reserved_function_count; i++) {
        if (strcmp(reserved_functions[i], name) == 0) {
            return 1; // Função reservada encontrada
        }
    }
    return 0; // Não é uma função reservada
}

// Função para encontrar um identificador na tabela de símbolos
int find_identifier(char *id) {
    for (int i = 0; i < identifier_count; i++) {
        if (strcmp(identifiers[i].id, id) == 0) {
            return i;
        }
    }
    return -1;
}

void process_reserved_function_call(char *func_name, char *param_list) {
    fprintf(output_file, "<%s> ", func_name);

    // Processar a lista de parâmetros
    char *token = strtok(param_list, ",");
    int param_count = 1;

    while (token != NULL) {
        // Verificar se o parâmetro é uma string (começa com aspas)
        if (token[0] == '"') {
            fprintf(output_file, "<param%d,str,%s> ", param_count, token);
        }
        // Verificar se o parâmetro é um número inteiro
        else if (strspn(token, "0123456789") == strlen(token)) {
            fprintf(output_file, "<param%d,num,%s> ", param_count, token);
        }
        // Verificar se o parâmetro é um número de ponto flutuante
        else if (strchr(token, '.') && strspn(token, "0123456789.") == strlen(token)) {
            fprintf(output_file, "<param%d,float,%s> ", param_count, token);
        }
        // Verificar se o parâmetro é um vetor
        else if (strchr(token, '[') && strchr(token, ']')) {
            char var_name[100];
            int index;
            sscanf(token, "%[^[][%d]", var_name, &index);

            int idx = find_identifier(var_name);
            if (idx != -1) {
                fprintf(output_file, "<param%d,vector_access,%d,%d> ", param_count, idx + 1, index);
            } else {
                fprintf(output_file, "<param%d,unknown_vector,%s> ", param_count, var_name);
            }
        }
        // Verificar se o parâmetro é um identificador já conhecido
        else {
            char var_name[100];
            sscanf(token, "%s", var_name);

            int idx = find_identifier(var_name);
            if (idx != -1) {
                fprintf(output_file, "<param%d,id,%d> ", param_count, idx + 1);
            } else {
                fprintf(output_file, "<param%d,unknown,%s> ", param_count, var_name);
            }
        }

        param_count++;
        token = strtok(NULL, ",");
    }
}


// Função para encontrar uma função na tabela de símbolos
int find_function(char *name) {
    for (int i = 0; i < function_count; i++) {
        if (strcmp(functions[i].name, name) == 0) {
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
        fprintf(output_file, "<id, %d> ", identifier_count);
    } else {
        fprintf(output_file, "<id, %d> ", idx + 1);
    }
}

void add_function(char *name, char *return_type, int param_count, Identifier parameters[]) {
    // Verificar se a função já existe
    int idx = find_function(name);
    if (idx != -1) {
        fprintf(output_file, "<error, function_already_declared, %s> ", name);
        return;
    }

    // Armazenar nome e tipo de retorno
    strcpy(functions[function_count].name, name);
    strcpy(functions[function_count].return_type, return_type);

    // Validar e armazenar parâmetros
    functions[function_count].param_count = 0; // Inicializa o contador de parâmetros
    for (int i = 0; i < param_count; i++) {
        // Armazenar o parâmetro
        strcpy(functions[function_count].parameters[functions[function_count].param_count].id, parameters[i].id);
        strcpy(functions[function_count].parameters[functions[function_count].param_count].type, parameters[i].type);
        functions[function_count].parameters[functions[function_count].param_count].size = 0;
        functions[function_count].param_count++;
    }

    // Incrementar o contador de funções
    function_count++;

    // Informar a declaração da função
    fprintf(output_file, "<function_decl, %s, %s, %d params> ", name, return_type, param_count);
}

// Função para verificar os parâmetros de uma chamada de função
void validate_function_call(Function *func, int passed_param_count, char passed_params[][10]) {
    if (func->param_count != passed_param_count) {
        fprintf(output_file, "<error, wrong_param_count, expected %d, got %d> ", func->param_count, passed_param_count);
        return;
    }

    for (int i = 0; i < passed_param_count; i++) {
        // Verifica se o identificador do parâmetro esperado é válido
        if (strlen(func->parameters[i].id) == 0) {
            fprintf(output_file, "<error, undefined_param, position %d> ", i + 1);
            continue;
        }

        fprintf(output_file, "<param_match, %s -> %s> ", passed_params[i], func->parameters[i].id);
    }
}

// Função para adicionar um vetor na tabela de símbolos
int add_vector(char *id, char *type, int size) {
    int idx = find_identifier(id);
    if (idx == -1) {
        strcpy(identifiers[identifier_count].id, id);
        strcpy(identifiers[identifier_count].type, type);
        identifiers[identifier_count].size = size;
        identifier_count++;

        fprintf(output_file, "<vetor_decl, %d, %s, %d> ", identifier_count, id, size);
        return identifier_count;
    } else {
        fprintf(output_file, "<error, vector_already_declared, %s> ", id);
        return -1;
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

(int|float|void)[ ]+{ID}\(.*\) { 
    char return_type[10], name[100], param_list[100];
    sscanf(yytext, "%s %[^()]%[^)]", return_type, name, param_list);

    Identifier parameters[10];
    int param_count = 0;

    char *token = strtok(param_list, ",");
    while (token != NULL) {
        char param_id[100], param_type[10];
        if (sscanf(token, "%9s %99s", param_type, param_id) == 2) {
            strcpy(parameters[param_count].id, param_id);
            strcpy(parameters[param_count].type, param_type);
            param_count++;
        } else {
            fprintf(output_file, "<error, invalid_parameter_format> ");
        }
        token = strtok(NULL, ",");
    }

    add_function(name, return_type, param_count, parameters);
}


{ID}\((.*)\) {  
    char func_name[100], param_list[100];
    sscanf(yytext, "%[^()](%[^)])", func_name, param_list);

    if (is_reserved_function(func_name)) {
        process_reserved_function_call(func_name, param_list);
    } else {
        int func_idx = find_function(func_name);
        if (func_idx != -1) {
            fprintf(output_file, "<function_call, %s> ", func_name);

            char passed_params[10][10];
            int passed_param_count = 0;

            char *token = strtok(param_list, ",");
            while (token != NULL) {
                sscanf(token, "%99s", passed_params[passed_param_count]);
                passed_param_count++;
                token = strtok(NULL, ",");
            }

            validate_function_call(&functions[func_idx], passed_param_count, passed_params);
        } else {
            fprintf(output_file, "<error, undefined_function, %s> ", func_name);
        }
    }
}

(int|float)[ ]+{ID}\[{DIGIT}\] { 
    char var_name[100];
    int size;
    sscanf(yytext, "%*s %[^[[][%d]", var_name, &size);
    int vector_id = add_vector(var_name, "vetor", size);
    if (vector_id == -1) {
        fprintf(output_file, "<vetor_decl,error>");
    }
}

{ID}\[{DIGIT}\] { 
    char var_name[100];
    int index;
    sscanf(yytext, "%[^[[][%d]", var_name, &index);

    int vector_id = find_identifier(var_name);
    if (vector_id != -1) {
        fprintf(output_file, "<vetor_acesso, %d, %d> ", vector_id + 1, index);
    } else {
        fprintf(output_file, "<error, undefined_vector, %s> ", var_name);
    }
}


{DIGIT}          { fprintf(output_file, "<num, %s> ", yytext); }
{FLOAT}          { fprintf(output_file, "<num, %s> ", yytext); }
{ID}             { add_variable(yytext, "unknown"); }
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
