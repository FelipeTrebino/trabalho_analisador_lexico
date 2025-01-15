# MATA61 - Compiladores
## Trabalho 1 - Análise Léxica

**Discentes:** Filipe dos Santos Freitas, Pedro Afonso, Felipe Trebino  
**Data:** 15/01/2025  

---

# Analisador Léxico em Flex

Este projeto implementa um **Analisador Léxico** utilizando a ferramenta **Flex**. O analisador reconhece diversos tokens presentes em linguagens de programação C, como variáveis, funções, operadores aritméticos, lógicos, e palavras reservadas. A saída do analisador é salva em um arquivo chamado **`output.lex`**.

---

## 📋 **Instruções de Uso**

### 🔧 **Passo 1: Criar o Arquivo `lex.yy.c`**

Execute o comando abaixo para gerar o arquivo **`lex.yy.c`** a partir do arquivo **`analisador_lexico.l`**:

```bash
flex analisador_lexico.l
```

### 🔧 **Passo 2: Compilar o Arquivo `lex.yy.c`**

Compile o arquivo gerado para criar o executável:

```bash
cc lex.yy.c -o analisador
```

### 🔧 **Passo 3: Executar o Analisador Léxico**

Para iniciar a análise léxica em um arquivo de entrada, execute o seguinte comando:

```bash
./analisador < entrada.txt
```

### 📄 **Passo 4: Verificar a Saída**

A saída da análise léxica será salva no arquivo **`output.lex`**. Você pode visualizar o conteúdo do arquivo com o comando:

```bash
cat output.lex
```

---

## ✨ **Funcionalidades Implementadas**

O analisador reconhece:

- **Palavras reservadas**: `int`, `float`, `char`, `void`, `if`, `else`, `for`, `while`, `return`, etc.
- **Identificadores**: Nomes de variáveis, funções e vetores.
- **Operadores**:
  - **Aritméticos**: `+`, `-`, `*`, `/`, `%`, `++`, `--`
  - **Lógicos**: `&&`, `||`, `!`, `^`, `~`
  - **Comparação**: `==`, `!=`, `<`, `>`, `<=`, `>=`
  - **Atribuição**: `=`, `+=`, `-=`
- **Delimitadores**: `(`, `)`, `{`, `}`, `[`, `]`, `,`, `;`, `:`
- **Strings**: Reconhecimento de literais de string entre aspas (`""`)
- **Comentários**: Comentários de linha única (`//`) e múltiplas linhas (`/* ... */`)

---

O analisador é responsável por identificar diferentes tokens em uma entrada, categorizá-los e realizar operações relacionadas, como registrar identificadores e verificar a validade dos elementos.
 
 Temos 3 estruturas de dados:
 - 'Identifier': Representando um identificador armazenado num array;
 - 'identifiers': O array para armazenar até 100 identificadores diferentes;
 - 'identifier_count': Conta o número de identificadores armazenados para controle.
 
 Para poder saber quais os identificadores diferentes e sua contagem na tabela de símbolos, utilizamos as funções:
 ## Funções para Manipulação da Tabela de Símbolos

### 1. `find_identifier`
**Função:**  
Busca um identificador na tabela de símbolos.

**Lógica:**  
- Itera pelo vetor de identificadores.
- Retorna o índice do identificador se encontrado, ou `-1` caso contrário.

      int find_identifier(char *id) {
          for (int i = 0; i < identifier_count; i++) {
              if (strcmp(identifiers[i].id, id) == 0) {
                  return i;
              }
          }
          return -1;
      }
---

### 2. `add_identifier`
**Função:**  
Adiciona um identificador à tabela de símbolos ou reutiliza seu índice caso já exista.

**Lógica:**  
- Verifica se o identificador já existe usando `find_identifier`.
- Se não existir, adiciona ao vetor e escreve `<id, N>` no arquivo de saída.
- Se já existir, apenas registra seu índice no arquivo de saída.

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
----

## Descrição das Expressões Regulares

### Definições de Expressões Regulares
As expressões regulares definem padrões para identificar diferentes tipos de tokens no código-fonte. Aqui estão as principais:

| **Expressão Regular** | **Descrição**                                                                 |
|------------------------|-----------------------------------------------------------------------------|
| `DIGIT [0-9]+`         | Reconhece números inteiros (uma ou mais ocorrências de dígitos de 0 a 9).   |
| `ID [a-zA-Z_][a-zA-Z0-9]*` | Reconhece identificadores: começam com uma letra ou sublinhado, seguidos de letras, números ou sublinhados. |
| `FLOAT [0-9]+\.[0-9]+` | Reconhece números de ponto flutuante, como `123.45`.                        |
| `WHITESPACE [ \t\n]+`  | Reconhece espaços em branco (espaços, tabulações ou quebras de linha).      |
| `STRING \"(\\.[^\"\\])*\"` | Reconhece strings delimitadas por aspas duplas, permitindo escapes (`\"`). |

---

### Regras de Tokens e Símbolos
Além das expressões regulares, o código reconhece palavras-chave, operadores e outros símbolos comuns. 

Alguns exemplos:

| **Padrão**      | **Descrição**                      |
|------------------|------------------------------------|
| `int`           | Palavra-chave para tipo inteiro.   |
| `float`         | Palavra-chave para tipo float.     |
| `char`          | Palavra-chave para tipo char.      |
| `=`             | Operador de atribuição.            |
| `==`            | Operador de igualdade.             |
| `<` / `>`       | Operadores de comparação.          |
| `+` / `-` / `*` / `/` | Operadores aritméticos básicos. |
| `&&`     | Operadores lógicos AND e OR.       |
| `(`, `)`, `{`, `}` | Delimitadores para blocos e expressões. |

---

### Ignorados
Alguns padrões são ignorados durante a análise:
- Comentários de linha única: `"//".*`
- Comentários de múltiplas linhas: `"/*"([^*]|\*+[^*/])*\*+"/`
- Espaços em branco: `{WHITESPACE}`

---

### Tokens Inválidos
Qualquer caractere ou sequência não reconhecida pelas regras acima será tratada como inválida:
```c
. { fprintf(output_file, "<invalido, %s> ", yytext); }
```


# Documentação do Funcionamento

Esta linguagem permite a criação de variáveis, funções e estruturas de controle de fluxo de forma simples e eficiente. A seguir, descrevemos as principais regras e como utilizá-las, baseando-se nos exemplos fornecidos.

## 1. Inicialização de Variáveis

### Tipos Numéricos:
Você pode inicializar variáveis do tipo numérico (inteiro e ponto flutuante) com tipagem estática. A sintaxe para inicialização é a seguinte:

```c
int a = 10;         // Declaração de uma variável inteira e inicialização com valor 10
float b = 3.14;     // Declaração de uma variável flutuante e inicialização com valor 3.14
```
```
<int> <id, 1> <= > <num, 10> <;> <float> <id, 2> <= > <num, 3.14> <;> 
```
### Vetores Numéricos:
Você também pode declarar e inicializar vetores de números inteiros ou flutuantes.

```c
int vetorn[5] = {1, 2, 3, 4, 5};  // Declaração e inicialização de um vetor de inteiros com 5 elementos
```
```
<int> <id, 1> <[> <num, 5> <]> <= > <{> <num, 1> <,> <num, 2> <,> <num, 3> <,> <num, 4> <,> <num, 5> <}> <;> 
```
---

## 2. Atribuições e Expressões Aritméticas

As variáveis podem ser modificadas por atribuições e expressões aritméticas que envolvem números literais, outras variáveis ou resultados de operações.

```c
a = a + 5;      // Atribuição de valor à variável 'a' (5 é somado ao valor atual de 'a')
b = b * 2.0;    // Atribuição de valor à variável 'b' (multiplica 'b' por 2.0)
```
```
<id, 1> <= > <id, 1> <+> <num, 5> <;> <id, 2> <= > <id, 2> <*> <num, 2.0> <;> 
```

Também é possível acessar elementos de vetores e realizar operações neles.

```c
int x = vetorn[2];   // Acessa o terceiro elemento do vetor 'vetorn'
vetorn[3] = a + 1;    // Atribui a soma de 'a' e 1 ao quarto elemento do vetor 'vetorn'
```
```
<int> <id, 1> <= > <id, 2> <[> <num, 2> <]> <;> <id, 2> <[> <num, 3> <]> <= > <id, 3> <+> <num, 1> <;> 
```

---

## 3. Desvios Condicionais

Você pode criar desvios condicionais simples ou compostos, utilizando operadores de comparação (como `>`, `<`, `==`, `!=`, `>=`, `<=`) para estabelecer a condição.

### Desvio Condicional Simples

```c
if (a > b) {
    printf("a é maior que b
");  // Se a condição for verdadeira, executa o código dentro do bloco
} else {
    printf("b é maior ou igual a a
");  // Caso contrário, executa o código dentro do 'else'
}
```
```
<if> <(> <id, 1> <> > <id, 2> <)> <{> <printf> <(> <str, "a é maior que b
"> <)> <;> <}> <else> <{> <printf> <(> <str, "b é maior ou igual a a"> <)> <;> <}> 
```


### Desvio Condicional Composto

```c
if (x != a && b >= 3.0) {
    printf("Condição atendida
");  // A condição é composta por operadores lógicos (&& para AND)
}
```
```
<if> <(> <id, 1> <!= > <id, 2> <&&> <id, 3> <>= > <num, 3.0> <)> <{> <printf> <(> <str, "Condição atendida"> <)> <;> <}> 
``` 

---

## 4. Comandos de Repetição

A linguagem permite a criação de laços de repetição, com a condição para a repetição sendo uma operação de comparação.

```c
while (z < 20) {           // Enquanto a condição for verdadeira, o código dentro do laço será executado
    z = z + 2;             // Incrementa 'z' em 2 a cada iteração
    printf("Valor de z: %d
", z);  // Imprime o valor de 'z'
}
```
```
<if> <(> <id, 1> <!= > <id, 2> <&&> <id, 3> <>= > <num, 3.0> <)> <{> <printf> <(> <str, "Condição atendida"> <)> <;> <}> 
```
---

## 5. Funções
 
É possível criar funções que aceitam parâmetros e retornam valores. O tipo de retorno deve ser explicitado na definição da função. As funções podem retornar tipos como inteiros, números flutuantes ou não retornar nada (tipos `void`).

### Definição de Função

```c
float soma(float c, float d) {
    return c + d;  // Retorna a soma dos parâmetros 'c' e 'd'
}
```
```
<float> <id, 1> <(> <float> <id, 2> <,> <float> <id, 3> <)> <{> <return> <id, 2> <+> <id, 3> <;> <}> 
``` 
### Chamada de Função

Após definir a função, você pode chamá-la passando os argumentos esperados:

```c
float resultado = soma(1.5, 2.5);  // Chama a função 'soma' com os valores 1.5 e 2.5 como parâmetros
printf("Resultado da soma: %.2f
", resultado);  // Imprime o resultado da função
```
```
<float> <id, 1> <= > <id, 2> <(> <num, 1.5> <,> <num, 2.5> <)> <;> <printf> <(> <str, "Resultado da soma: %.2f"> <,> <id, 1> <)> <;> 
```

---
 Obs:O analisador utiliza a função yylex() para processar a entrada. Cada token identificado gera uma saída apropriada ou é marcado como inválido. Colocamos a diretiva "%option noyywrap" para não ter que utilizar a função "yywrap()" e ter que retornar 1 como o fim do processamento.

---
# Diagrama de transições
![Diagrama de transição](diag_transicao.png)

