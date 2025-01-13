/*
 * MATA61 - Compiladores
 * Trabalho 1 - Análise Léxica
 * Discentes: Filipe dos Santos Freitas, Pedro Afonso, Felipe Trebino
 * Data: 08/01/2025
 * Descrição: Arquivo Flex que implementa um analisador léxico para reconhecer números, identificadores e operadores aritméticos. O arquivo apenas reconhece símbolos mais comuns, não fomos muito a fundo. Também, há um controle de erro para
 identificadores: se o identificador começar com números, um bloco de ERRO é impresso.
 */

# Analisador Léxico em Flex

Este projeto implementa um **Analisador Léxico** utilizando a ferramenta **Flex**. O analisador reconhece diversos tokens presentes em linguagens de programação, como variáveis, funções, operadores aritméticos, lógicos, e palavras reservadas. A saída do analisador é salva em um arquivo chamado **`output.lex`**.

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
  - **Lógicos**: `&&`, `||`, `!`
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
 - 'find_identifier': Procura pelo identificador no array;
 - 'add_identifier': Adiciona o identificador no array caso não esteja presente;
 
 Definição dos tokens:
 - DIGIT: Inteiros;
 - ID: Identificadores;
 - FLOAT: Numéricos do tipo float;
 - STRING: String delimitadas por aspas duplas;
 - WHITESPACE: Espaços em branco;
 
 O analisador utiliza a função yylex() para processar a entrada. Cada token identificado gera uma saída apropriada ou é marcado como inválido. Colocamos a diretiva "%option noyywrap" para não ter que utilizar a função "yywrap()" e ter que retornar 1 como o fim do processamento.