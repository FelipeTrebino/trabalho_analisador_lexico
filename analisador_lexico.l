%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

typedef struct {
    char id[100];
} Identifier;

Identifier identifiers[100];
int identifier_count = 0;

int find_identifier(char *id) {
    for (int i = 0; i < identifier_count; i++) {
        if (strcmp(identifiers[i].id, id) == 0) {
            return i;
        }
    }
    return -1;
}

int add_identifier(char *id) {
    int idx = find_identifier(id);
    if (idx == -1) {
        strcpy(identifiers[identifier_count].id, id);
        identifier_count++;
        printf("<id, %d> ", identifier_count);
        return identifier_count - 1;
    } else {
    	printf("<id, %d> ", idx + 1);
        return idx;
    }
}
%}

DIGIT[0-9]+
ID[a-zA-Z_][a-zA-Z0-9]*
FLOAT[0-9]+\.[0-9]+
WHITESPACE[ \t\n]+
STRING \"(\\.|[^"\\])*\"
%option noyywrap

%%
int 		     { printf("<int> ");}
float		     { printf("<float> ");}
if                   { printf("<if> "); }
else                 { printf("<else> "); }
for                  { printf("<for> "); }
while                { printf("<while> "); }
printf               { printf("<printf> "); }
return               { printf("<return> "); }
void                 { printf("<void> "); }
"="                    { printf("<= > "); }
"=="                   { printf("<==> "); }
"<"                    { printf("<< > "); }
"<="                   { printf("< <=  > "); }
">"                    { printf(" > > "); }
">="                   { printf("< >= > "); }
"!="                   { printf("<!= > "); }
"+"                    { printf("<+> "); }
"-"                    { printf("<-> "); }
"*"                    { printf("<*> "); }
"/"                    { printf("</> "); }
"("                    { printf("<(> "); }
")"                    { printf("<)> "); }
"["                    { printf("<[> "); }
"]"                    { printf("<]> "); }
"{"                    { printf("<{> "); }
"}"                    { printf("<}> "); }
","                    { printf("<,> "); }
";"                    { printf("<;> "); }
{DIGIT}                { printf("<num, %s> ", yytext); }
{ID}                   { add_identifier(yytext); }
{FLOAT}                { printf("<num, %s> ", yytext); }
{WHITESPACE}           { }
{STRING} 	       { printf("<str, %s> ", yytext); }
.                      { printf("<invalido, %s> ", yytext); }
%%

int main() {
    yylex();
    return 0;
}

