%{
#include <stdio.h>
#include <stdbool.h>
#include <signal.h>
#include <string.h>
#include <stdlib.h>
void yyerror(char *);
int yylex();
void INThandler(int sig);
int addtoken(char *s, char *token_value);
%}
%union {
    long int intval; 
    float floatval; 
}

%token <intval> INTEGER
%token <floatval> DOUBLE
%token INT FLOAT BIG SMALL IF ELSE RETURN
%token ADD_OP SUB_OP DIV_OP MULT_OP POW_OP MOD_OP ASSIGN COMP_ASSIGN_ADD
%token LESS_THAN LESS_THAN_EQ GREAT_THAN GREAT_THAN_EQ NOT_EQ COMPLEMENT
%token OR AND NOT BIT_OR BIT_AND BIT_NOT
%token VAR TERNARY COLON RIGHT_ACCESS LEFT_ACCESS EOL
%token LEFT_PAREN RIGHT_PAREN LEFT_CURLY_BRACE RIGHT_CURLY_BRACE LEFT_BRACE RIGHT_BRACE
%token SINGLE_LINE_COMMENT RIGHT_ANGLE LEFT_ANGLE SET LOOP FINALLY PRINT FUNC 
%%
PROGRAM : STATEMENT |PROGRAM STATEMENT;
STATEMENT: SET_STATEMENT
            | DEC_STATEMENT 
            | ASSGN_STATEMENT 
            | PUSH_POP_STATEMENT 
            | CONDITIONAL_STATEMENT
            | LOOP_STATEMENT
            | FUNC
            | RETURN_STATEMENT
            | PRINT_STATEMENT
            ;
SET_TYPE: INT 
            |FLOAT
            ;
VEC_TYPE:LEFT_BRACE SET_TYPE RIGHT_BRACE ;
MIX_TYPE: SET_TYPE|VEC_TYPE;
TYPE : SET_TYPE 
        | VEC_TYPE 
        | LEFT_CURLY_BRACE SET_TYPE ':' MIX_TYPE RIGHT_CURLY_BRACE
        ;     
SET_SIZE: BIG
            |SMALL
            ;
SET_STATEMENT: SET SET_TYPE SET_SIZE;
VAR_TYPE: INTEGER | DOUBLE;
DEC_CONDITION: ASSIGN VAR_TYPE 
                   | ;
DEC_STATEMENT: TYPE DEC_CONDITION ;

/* input:
    | input statement
    ;

statement:
    VAR { printf("VAR\n"); }
    | INTEGER { printf("INTEGER\n"); }
    | DOUBLE { printf("DOUBLE\n"); }

    | INT { printf("INT\n"); }
    | FLOAT { printf("FLOAT\n"); }
    | BIG { printf("BIG\n"); }
    | SMALL { printf("SMALL\n"); }
    | IF { printf("IF\n"); }
    | ELSE { printf("ELSE\n"); }
    | RETURN { printf("RETURN\n"); }
    | SET { printf("SET\n"); }
    | LOOP { printf("LOOP\n"); }
    | FINALLY { printf("FINALLY\n"); }
    | PRINT { printf("PRINT\n"); }
    | FUNC { printf("FUNC\n"); }

    | ADD_OP { printf("ADD_OP\n"); }
    | SUB_OP { printf("SUB_OP\n"); }
    | DIV_OP { printf("DIV_OP\n"); }
    | MULT_OP { printf("MULT_OP\n"); }
    | MOD_OP { printf("MOD_OP\n"); }
    | POW_OP { printf("POW_OP\n"); }
    | ASSIGN { printf("ASSIGN\n"); }
    | COMP_ASSIGN_ADD { printf("COMP_ASSIGN_ADD\n"); }

    | BIT_OR { printf("BIT_OR\n"); }
    | BIT_AND { printf("BIT_AND\n"); }
    | BIT_NOT { printf("BIT_NOT\n"); }

    | OR { printf("OR\n"); }
    | AND { printf("AND\n"); }
    | NOT { printf("NOT\n"); }

    | LESS_THAN { printf("LESS_THAN\n"); }
    | LESS_THAN_EQ { printf("LESS_THAN_EQ\n"); }
    | GREAT_THAN { printf("GREAT_THAN\n"); }
    | GREAT_THAN_EQ { printf("GREAT_THAN_EQ\n"); }
    | NOT_EQ { printf("NOT_EQ\n"); }
    | COMPLEMENT { printf("COMPLEMENT\n"); }

    | RIGHT_ACCESS { printf("RIGHT_ACCESS\n"); }
    | LEFT_ACCESS { printf("LEFT_ACCESS\n"); }

    | LEFT_PAREN { printf("LEFT_PAREN\n"); }
    | RIGHT_PAREN { printf("RIGHT_PAREN\n"); }
    | LEFT_CURLY_BRACE { printf("LEFT_CURLY_BRACE\n"); }
    | RIGHT_CURLY_BRACE { printf("RIGHT_CURLY_BRACE\n"); }
    | LEFT_BRACE { printf("LEFT_BRACE\n"); }
    | RIGHT_BRACE { printf("RIGHT_BRACE\n"); }
    | TERNARY {printf("TERNARY\n");}
    | COLON { printf("COLON\n"); }
    | EOL { printf("EOL\n"); }


    | RIGHT_ANGLE{ printf("RIGHT_ANGLE\n");}
    | LEFT_ANGLE{ printf("LEFT_ANGLE\n");}
    | SINGLE_LINE_COMMENT { printf("SINGLE_LINE_COMMENT\n"); }
    ; */
%%
struct token {
    char *token;
    struct token *next;
    char *token_value;
};

struct token *token_list;

int addtoken(char *token, char *token_value) {
    struct token *curr_token;
    curr_token = (struct token *)malloc(sizeof(struct token));
    if (curr_token == NULL) {
        perror("Failed to allocate memory for token.\n");
        return -1;
    }
    curr_token->token = (char *)malloc(strlen(token) + 1);
    if (curr_token->token == NULL) {
        perror("Failed to allocate memory for token name.\n");
        free(curr_token);
        return -1;
    }
    curr_token->token_value = (char *)malloc(strlen(token_value) + 1);
    if (curr_token->token_value == NULL) {
        perror("Failed to allocate memory for token_value");
        free(curr_token->token);
        free(curr_token);
        return -1;
    }
    strcpy(curr_token->token, token);
    strcpy(curr_token->token_value, token_value);
    curr_token->next = NULL;

    if (token_list == NULL) {
        token_list = curr_token;
    } else {
        struct token *temp = token_list;
        while (temp->next != NULL) {
            temp = temp->next;
        }
        temp->next = curr_token;
    }
    return 1;
}

void printall() {
    struct token *current = token_list;
    while (current != NULL) {
        if (strcmp(current->token, "EOL") == 0) {
            printf("\n");
        } else if ((strcmp(current->token, "INTEGER") == 0) || 
                   (strcmp(current->token, "DOUBLE") == 0) || 
                   (strcmp(current->token, "STRING_VALUE") == 0) || 
                   (strcmp(current->token, "BOOL_VALUE") == 0)) {
            printf(" <%s , %s > ", current->token, current->token_value);
        } else {
            printf(" <%s> ", current->token);
        }
        current = current->next;
    }
}

void yyerror(char *s) {
    printf("%s\n", s);
}

// Free dynamically allocated memory
void free_token_list() {
    struct token *current = token_list;
    struct token *next;
    
    printf("Freeing memory...\n");
    while (current != NULL) {

      printf(".");
        next = current->next;
        free(current->token);
        free(current->token_value);  // Added to free the token value
        free(current);
        current = next;
    }
    printf("\nMemory Freed<---->\n");
    token_list = NULL;
}

extern FILE *yyin;

int main(int argc, char **argv) {

    signal(SIGINT,INThandler);
    yyparse();
    
    return 0;
}


void INThandler(int sig) 
{
char c;

  // Catching the signal
  signal(sig,SIG_IGN);
  printf("\nDid you hit Crtl-c?\n (Y/N)\n");
c  = getchar();
if (c=='y'||c=='Y') {
  free_token_list();
  exit(0);
}else {
signal(SIGINT,INThandler);
getchar();
}
}
