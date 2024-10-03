%{ #include <stdio.h>
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
%token LESS_THAN LESS_THAN_EQ GREAT_THAN GREAT_THAN_EQ NOT_EQ COMPLEMENT EQUAL_TO
%token OR AND NOT BIT_OR BIT_AND BIT_NOT
%token VAR TERNARY COLON SEMI RIGHT_ACCESS LEFT_ACCESS  
%token LEFT_PAREN RIGHT_PAREN LEFT_CURLY_BRACE RIGHT_CURLY_BRACE LEFT_BRACE RIGHT_BRACE
%token SINGLE_LINE_COMMENT RIGHT_ANGLE LEFT_ANGLE SET LOOP FINALLY PRINT FUNC 
%%
PROGRAM : STATEMENT |PROGRAM STATEMENT;
STATEMENT: SET_STATEMENT
            | DEC_STATEMENT  SEMI {printf("DEC_STATEMENT");}
            | EXPRESSION SEMI
            | ASSGN_STATEMENT  SEMI
            | LOOP_STATEMENT 
            /* | PUSH_POP_STATEMENT 
            | CONDITIONAL_STATEMENT
            | FUNC
            | RETURN_STATEMENT */
            | PRINT_STATEMENT SEMI
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

DEC_STATEMENT: TYPE VAR DEC_CONDITION ;
ASSGN_STATEMENT: VAR ASSIGN EXPRESSION;


LOOP_STATEMENT : LOOP LEFT_PAREN DEC_STATEMENT SEMI BOOLEAN_EXP SEMI ASSGN_STATEMENT RIGHT_PAREN

EXPRESSION : BOOLEAN_EXP  {printf("Relations here\n");}
           ;
ARITHMETIC_EXP : ARITHMETIC_EXP ADD_OP  MUL_EXP  {printf("ARITHMETIC_EXP");}
               | ARITHMETIC_EXP SUB_OP MUL_EXP 
               | MUL_EXP 
	            ;

MUL_EXP : MUL_EXP MULT_OP  POW_EXP 
        | MUL_EXP DIV_OP POW_EXP
        | POW_EXP  
        ;

POW_EXP : POW_EXP POW_OP PRIMARY_EXP 
        | PRIMARY_EXP 
        ;

PRIMARY_EXP  : LEFT_PAREN EXPRESSION RIGHT_PAREN 
             | FACTOR 
             ; 

BOOLEAN_EXP : BOOLEAN_EXP AND RELATIONAL_EXP {}
            | BOOLEAN_EXP OR RELATIONAL_EXP
            | RELATIONAL_EXP 
            ;
RELATIONAL_EXP : RELATIONAL_EXP COMP_OP ARITHMETIC_EXP 
               | ARITHMETIC_EXP  
              ;
ACCES_VAL: INTEGER | VAR;

REF_TYPE: LEFT_BRACE  ACCES_VAL RIGHT_BRACE {/*The conflict is here*/}
            | LEFT_PAREN RIGHT_PAREN
            | 
            ;

FACTOR: DOUBLE 
      | INTEGER
      | VAR
      ;

PRINTABLE: VAR_TYPE | VAR;

PRINT_STATEMENT: PRINT LEFT_PAREN PRINTABLE RIGHT_PAREN ;

COMP_OP : LEFT_ANGLE | RIGHT_ANGLE| GREAT_THAN_EQ | LESS_THAN_EQ | NOT_EQ | EQUAL_TO 
        ;


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
        perror("Token Memory allocation Failed.\n");
        return -1;
    }
    curr_token->token = (char *)malloc(strlen(token) + 1);
    if (curr_token->token == NULL) {
        perror("Token_name memory allocation failed\n");
        free(curr_token);
        return -1;
    }
    curr_token->token_value = (char *)malloc(strlen(token_value) + 1);
    if (curr_token->token_value == NULL) {
        perror("Token_value Memory allocation Failed");
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

void printall() { /*Printing out all token lists*/
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
    printf("%s\n", s);/*Procedure to print out the error message...*/
}

// Free dynamically allocated memory
void free_token_list() {
    struct token *current = token_list;
    struct token *next;
    
    printf("Freeing Tokens memory...\n");
    while (current != NULL) {

      printf(".");
        next = current->next;
        free(current->token);
        free(current->token_value);  // Added to free the token value
        free(current);
        current = next;
    }
    printf("\nToken Memory Freed<---->\n");
    token_list = NULL;
}

//extern FILE *yyin;

int main(int argc, char **argv) {

    signal(SIGINT,INThandler);
    while(1) {
    yyparse();
    }
    return 0;
}


void INThandler(int sig) 
{
char c;

  // Catching the signal
  signal(sig,SIG_IGN);
  printf("\nDid you hit (Crtl-c)?\n Are you sure you want to close this program ? (Y/N)\n");
c  = getchar();
if (c=='y'||c=='Y') {
  free_token_list();
  exit(0);
}else {
signal(SIGINT,INThandler);
getchar();
}
} 
