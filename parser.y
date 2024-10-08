%{
#include <stdio.h> 
#include <stdbool.h>
#include <signal.h>
#include <string.h>
#include <stdlib.h>
void yyerror(char *);
int yylex();
extern int lineno;
extern FILE * tokenFile;
extern FILE * parsedFile;

void addToFile(char * s, int t);
void INThandler(int sig);
int addtoken(char *s, char *token_value);
%}
%union {
    long int intval; 
    float floatval; 
}

%token <intval> INTEGER
%token <floatval> DOUBLE
%token INT FLOAT BIG SMALL IF ELSE RETURN SIZE
%token ADD_OP SUB_OP DIV_OP MULT_OP POW_OP MOD_OP ASSIGN COMP_ASSIGN_ADD
%token LESS_THAN LESS_THAN_EQ GREAT_THAN GREAT_THAN_EQ NOT_EQ COMPLEMENT EQUAL_TO
%token OR AND NOT BIT_OR BIT_AND BIT_NOT BIT_XOR NOT_OP
%token VAR TERNARY COLON SEMI RIGHT_ACCESS LEFT_ACCESS  
%token LEFT_PAREN RIGHT_PAREN LEFT_CURLY_BRACE RIGHT_CURLY_BRACE LEFT_BRACE RIGHT_BRACE
%token SINGLE_LINE_COMMENT RIGHT_ANGLE LEFT_ANGLE SET LOOP FINALLY PRINT FUNC  COMMA
%left OR
%left AND
%left LESS_THAN LESS_THAN_EQ GREAT_THAN GREAT_THAN_EQ EQUAL_TO NOT_EQ
%left ADD_OP SUB_OP
%left MULT_OP DIV_OP MOD_OP
%right NOT 
%right TERNARY
%%
PROGRAM:SETUP_STATEMENT COMPOUND_STATEMENT  {$$ = malloc(strlen($1)+strlen($2)+1); sprintf($$, "%s%s",$1,$2); free($1);free($2);};
       ;
COMPOUND_STATEMENT: COMPOUND_STATEMENT STATEMENT  {$$ = malloc(strlen($1)+strlen($2)+1); sprintf($$, "%s%s",$1,$2); free($1);free($2);};
                  |
                  ;
/* there can be multiple fucntion declaration statements in the setup section but it must have one set statement */
MUL_FUNC_STATMENT: MUL_FUNC_STATMENT FUNC_STATEMENT {$$ = malloc(strlen($1)+strlen($2)+1); sprintf($$, "%s%s",$1,$2); free($1);free($2);};
                 | FUNC_STATEMENT {$$ = malloc(strlen($1)+1); sprintf($$, "%s",$1); free($1);};
                 ;
SET_STATEMENT_LIST : SET_STATEMENT_LIST SET_STATEMENT  {$$ = malloc(strlen($1)+strlen($2)+1); sprintf($$, "%s%s",$1,$2); free($1);free($2);};
                   | SET_STATEMENT {$$ = malloc(strlen($1)+1); sprintf($$, "%s",$1); free($1);};
                   ;
SETUP_STATEMENT: SET_STATEMENT_LIST {$$ = malloc(strlen($1)+1); sprintf($$, "%s",$1); free($1);};
                 | SET_STATEMENT_LIST MUL_FUNC_STATMENT {$$ = malloc(strlen($1)+strlen($2)+1); sprintf($$, "%s%s",$1,$2); free($1);free($2);};
               ;
/* all the statments that can be seen on the main section */
STATEMENT   : 
            LOOP_STATEMENT  SEMI  {$$ = malloc(strlen($1)+strlen($2)+1); sprintf($$, "%s%s",$1,$2); free($1);free($2);};
            | PUSH_POP_STATEMENT  SEMI {addToFile("PUSH_POP_STATEMENT", 2); $$ = malloc(strlen($1)+strlen($2)+1); sprintf($$, "%s%s",$1,$2); free($1);free($2);}
            | CONDITIONAL_STATEMENT {$$ = malloc(strlen($1)+1); sprintf($$, "%s",$1); free($1);};
            | PRINT_STATEMENT {addToFile("PRINT_STATEMENT", 2);$$ = malloc(strlen($1)+1); sprintf($$, "%s",$1); free($1);}
            | DEC_STATEMENT  {addToFile("DEC_STATEMENT", 2);$$ = malloc(strlen($1)+1); sprintf($$, "%s",$1); free($1);}
            | EXPRESSION_STMT  {addToFile("EXPRESSION_STMT", 2);$$ = malloc(strlen($1)+1); sprintf($$, "%s",$1); free($1);}
            | ASSIGN_STATEMENT  SEMI {addToFile("ASSIGN_STATEMENT", 2);$$ = malloc(strlen($1)+strlen($2)+1); sprintf($$, "%s%s",$1,$2); free($1);free($2);}
            ;
/* definition for the looping statement */
LOOP_STATEMENT : LOOP LEFT_PAREN LOOP_CONDITION RIGHT_PAREN COLON LEFT_ANGLE COMPOUND_STATEMENT RIGHT_ANGLE  
                    {$$= malloc(strlen($1)+strlen($2)+strlen($3)+ strlen($4)+strlen($5)+strlen($6)+strlen($7)+strlen($8)+1); 
            sprintf($$, "%s%s%s%s%s%s%s%s", $1,$2,$3,$4,$5,$6,$7,$8); 
            free($1); free($2); free($3); free($4);free($5);free($6);free($7);free($8);
            };
               | LOOP LEFT_PAREN LOOP_CONDITION RIGHT_PAREN COLON LEFT_ANGLE COMPOUND_STATEMENT RIGHT_ANGLE COLON FINALLY_STMT 
               {$$= malloc(strlen($1)+strlen($2)+strlen($3)+ strlen($4)+strlen($5)+strlen($6)+strlen($7)+strlen($8)+strlen($9)+1); 
            sprintf($$, "%s%s%s%s%s%s%s%s%s", $1,$2,$3,$4,$5,$6,$7,$8,$9); 
            free($1); free($2); free($3); free($4);free($5);free($6);free($7);free($8);free($9);
            };
               ;
LOOP_CONDITION : DEC_STATEMENT BOOLEAN_EXP SEMI ASSIGN_STATEMENT {addToFile("LOOP_STATEMENT", 2);$$= malloc(strlen($1)+strlen($2)+strlen($3)+ strlen($4)+1); 
            sprintf($$, "%s%s%s%s", $1,$2,$3,$4); free($1); free($2); free($3); free($4);};

FINALLY_STMT : FINALLY COLON LEFT_ANGLE COMPOUND_STATEMENT RIGHT_ANGLE {$$= malloc(strlen($1)+strlen($2)+strlen($3)+ strlen($4)+strlen($5)+1); 
            sprintf($$, "%s%s%s%s%s", $1,$2,$3,$4,$5); free($1); free($2); free($3); free($4);free($5);
            };;
 /* definition for the conditional statement with if else */
IF_STATEMENT: BOOLEAN_EXP TERNARY STATEMENT {addToFile("CONDITIONAL_STATEMENT", 2); 
                        $$= malloc(strlen($1)+strlen($2)+strlen($3)+1); 
                        sprintf($$, "%s%s%s", $1,$2,$3); 
                        free($1); free($2); free($3);
                        };
ELSE_STATEMENT: ELSE COLON STATEMENT{$$= malloc(strlen($1)+strlen($2)+strlen($3)+1); sprintf($$, "%s%s%s", $1,$2,$3); free($1); free($2); free($3);}
            ;
CONDITIONAL_STATEMENT : RIGHT_ANGLE IF_STATEMENT ELSE_STATEMENT LEFT_ANGLE{$$= malloc(strlen($1)+strlen($2)+strlen($3)+ strlen($4)+1); 
            sprintf($$, "%s%s%s%s", $1,$2,$3,$4); free($1); free($2); free($3); free($4);
            };
/* Print statement */
PRINT_STATEMENT: PRINT LEFT_PAREN PRINTABLE RIGHT_PAREN SEMI{$$= malloc(strlen($1)+strlen($2)+strlen($3)+ strlen($4)+strlen($5)+1); 
            sprintf($$, "%s%s%s%s%s", $1,$2,$3,$4,$5); free($1); free($2); free($3); free($4);free($5);
            };
/* Function declaration statement */
FUNC_STATEMENT: FUNC VAR  FUNCTION_DEC_LIST LEFT_ANGLE FUNCTION_BODY RIGHT_ANGLE  {$$= malloc(strlen($1)+strlen($2)+strlen($3)+ strlen($4)+strlen($5)+1); 
            sprintf($$, "%s%s%s%s%s", $1,$2,$3,$4,$5); free($1); free($2); free($3); free($4);free($5);
            };
FUNCTION_DEC_LIST :LEFT_PAREN PARAMETER_LIST SEMI  TYPE RIGHT_PAREN{addToFile("FUNC_STATEMENT",2);$$= malloc(strlen($1)+strlen($2)+strlen($3)+ strlen($4)+strlen($5)+1); 
            sprintf($$, "%s%s%s%s%s", $1,$2,$3,$4,$5); free($1); free($2); free($3); free($4);free($5);
            };
                    |LEFT_PAREN SEMI TYPE RIGHT_PAREN{addToFile("FUNC_STATEMENT",2);$$= malloc(strlen($1)+strlen($2)+strlen($3)+ strlen($4)+1); 
            sprintf($$, "%s%s%s%s", $1,$2,$3,$4); free($1); free($2); free($3); free($4);};
PARAMETER_LIST : PARAMETER {$$ = malloc(strlen($1)+1); sprintf($$, "%s",$1); free($1);};
              | PARAMETER_LIST COMMA PARAMETER  {$$= malloc(strlen($1)+strlen($2)+strlen($3)+1); sprintf($$, "%s%s%s", $1,$2,$3); free($1); free($2); free($3);}
            ;
                ;
PARAMETER : TYPE VAR {$$ = malloc(strlen($1)+strlen($2)+1); sprintf($$, "%s%s",$1,$2); free($1);free($2);};

FUNCTION_BODY : COMPOUND_STATEMENT RETURN_STATEMENT{$$ = malloc(strlen($1)+strlen($2)+1); sprintf($$, "%s%s",$1,$2); free($1);free($2);}
              ;

RETURN_STATEMENT : RETURN EXPRESSION SEMI {addToFile("RETURN_STATEMENT",2); $$= malloc(strlen($1)+strlen($2)+strlen($3)+1); sprintf($$, "%s%s%s", $1,$2,$3); free($1); free($2); free($3);}
            ; 

/* Vector push pop statements */
PUSH_POP_STATEMENT : PUSH_STMT {$$ = malloc(strlen($1)+1); sprintf($$, "%s",$1); free($1);};
                 | POP_STMT {$$ = malloc(strlen($1)+1); sprintf($$, "%s",$1); free($1);};

PUSH_STMT : VAR LEFT_ACCESS LEFT_BRACE EXPRESSION RIGHT_BRACE {$$= malloc(strlen($1)+strlen($2)+strlen($3)+ strlen($4)+strlen($5)+1); 
            sprintf($$, "%s%s%s%s%s", $1,$2,$3,$4,$5); free($1); free($2); free($3); free($4);free($5);
            };
          | LEFT_BRACE EXPRESSION RIGHT_BRACE RIGHT_ACCESS VAR{$$= malloc(strlen($1)+strlen($2)+strlen($3)+ strlen($4)+1); 
            sprintf($$, "%s%s%s%s", $1,$2,$3,$4); free($1); free($2); free($3); free($4);}
          ;
POP_STMT  :  VAR RIGHT_ACCESS LEFT_BRACE VAR RIGHT_BRACE {$$= malloc(strlen($1)+strlen($2)+strlen($3)+ strlen($4)+strlen($5)+1); 
            sprintf($$, "%s%s%s%s%s", $1,$2,$3,$4,$5); free($1); free($2); free($3); free($4);free($5);
            };
          | LEFT_BRACE  RIGHT_BRACE LEFT_ACCESS VAR {$$= malloc(strlen($1)+strlen($2)+strlen($3)+ strlen($4)+1); 
            sprintf($$, "%s%s%s%s", $1,$2,$3,$4); free($1); free($2); free($3); free($4);}
          | VAR RIGHT_ACCESS LEFT_BRACE RIGHT_BRACE {$$= malloc(strlen($1)+strlen($2)+strlen($3)+ strlen($4)+1); 
            sprintf($$, "%s%s%s%s", $1,$2,$3,$4); free($1); free($2); free($3); free($4);}
            ;
          ;
SIZE_EXP: SIZE LEFT_BRACE VAR RIGHT_BRACE{$$= malloc(strlen($1)+strlen($2)+strlen($3)+ strlen($4)+1); 
            sprintf($$, "%s%s%s%s", $1,$2,$3,$4); free($1); free($2); free($3); free($4);}
         ;


/* Set statement */
SET_TYPE: INT   {$$ = malloc(strlen($1)+1); sprintf($$, "%s",$1); free($1);};
            |FLOAT {$$ = malloc(strlen($1)+1); sprintf($$, "%s",$1); free($1);};
            ;
SET_SIZE: BIG {$$ = malloc(strlen($1)+1); sprintf($$, "%s",$1); free($1);};
            |SMALL {$$ = malloc(strlen($1)+1); sprintf($$, "%s",$1); free($1);};
            ;

SET_STATEMENT: SET SET_TYPE SET_SIZE SEMI { addToFile("SET_STATEMENT",2);
                    $$= malloc(strlen($1)+strlen($2)+strlen($3)+ strlen($4)+1); 
                    sprintf($$, "%s%s%s%s", $1,$2,$3,$4); free($1); free($2); free($3); free($4);};

/* Declaration Statements */
VEC_TYPE:LEFT_BRACE SET_TYPE RIGHT_BRACE {$$= malloc(strlen($1)+strlen($2)+strlen($3)+1); sprintf($$, "%s%s%s", $1,$2,$3); free($1); free($2); free($3);}
            ; 
MIX_TYPE: SET_TYPE{$$ = malloc(strlen($1)+1); sprintf($$, "%s",$1); free($1);};
                 | VEC_TYPE{$$ = malloc(strlen($1)+1); sprintf($$, "%s",$1); free($1);}; ;
TYPE : SET_TYPE {$$ = malloc(strlen($1)+1); sprintf($$, "%s",$1); free($1);};
        | VEC_TYPE {$$ = malloc(strlen($1)+1); sprintf($$, "%s",$1); free($1);};
        | LEFT_CURLY_BRACE SET_TYPE COLON MIX_TYPE RIGHT_CURLY_BRACE{$$= malloc(strlen($1)+strlen($2)+strlen($3)+ strlen($4)+strlen($5)+1); 
            sprintf($$, "%s%s%s%s%s", $1,$2,$3,$4,$5); free($1); free($2); free($3); free($4);free($5);
            }
        ;     

VAR_TYPE: INTEGER{$$ = malloc(strlen($1)+1); sprintf($$, "%s",$1); free($1);}; 
            | DOUBLE {$$ = malloc(strlen($1)+1); sprintf($$, "%s",$1); free($1);};
DEC_CONDITION: ASSIGN VAR_TYPE  {$$ = malloc(strlen($1)+strlen($2)+1); sprintf($$, "%s%s",$1,$2); free($1);free($2);};
             | ;
VAR_LIST: VAR_LIST COMMA VAR DEC_CONDITION {$$= malloc(strlen($1)+strlen($2)+strlen($3)+ strlen($4)+1); 
            sprintf($$, "%s%s%s%s", $1,$2,$3,$4); free($1); free($2); free($3); free($4);
            }
            |  VAR DEC_CONDITION {$$ = malloc(strlen($1)+strlen($2)+1); sprintf($$, "%s%s",$1,$2); free($1);free($2);};
DEC_STATEMENT: TYPE VAR_LIST SEMI {$$= malloc(strlen($1)+strlen($2)+strlen($3)+1); sprintf($$, "%s%s%s", $1,$2,$3); free($1); free($2); free($3);}
            ; ;
/* Assignment Statement */
ASSIGN_STATEMENT: VAR ASSIGN EXPRESSION {$$= malloc(strlen($1)+strlen($2)+strlen($3)+1); sprintf($$, "%s%s%s", $1,$2,$3); free($1); free($2); free($3);}
            ;;

/* Expressions that make up boolean, arithmetic , bitwise operations */
EXPRESSION_STMT : EXPRESSION SEMI {$$ = malloc(strlen($1)+strlen($2)+1); sprintf($$, "%s%s",$1,$2); free($1);free($2);};;
EXPRESSION : BOOLEAN_EXP  {$$ = malloc(strlen($1)+1); sprintf($$, "%s",$1); free($1);};
           ;
ARITHMETIC_EXP : ARITHMETIC_EXP ADD_OP  MUL_EXP  {$$= malloc(strlen($1)+strlen($2)+strlen($3)+1); sprintf($$, "%s%s%s", $1,$2,$3); free($1); free($2); free($3);}
            ;
               | ARITHMETIC_EXP SUB_OP MUL_EXP {$$= malloc(strlen($1)+strlen($2)+strlen($3)+1); sprintf($$, "%s%s%s", $1,$2,$3); free($1); free($2); free($3);}
            ;
               | MUL_EXP {$$ = malloc(strlen($1)+1); sprintf($$, "%s",$1); free($1);};
	            ;

MUL_EXP : MUL_EXP MULT_OP  UNARY_EXPRESSION {$$= malloc(strlen($1)+strlen($2)+strlen($3)+1); sprintf($$, "%s%s%s", $1,$2,$3); free($1); free($2); free($3);}
            ;
        | MUL_EXP DIV_OP UNARY_EXPRESSION {$$= malloc(strlen($1)+strlen($2)+strlen($3)+1); sprintf($$, "%s%s%s", $1,$2,$3); free($1); free($2); free($3);}
            ;
        | UNARY_EXPRESSION  {$$ = malloc(strlen($1)+1); sprintf($$, "%s",$1); free($1);};
        ;

UNARY_EXPRESSION : NOT_OP UNARY_EXPRESSION  {$$ = malloc(strlen($1)+strlen($2)+1); sprintf($$, "%s%s",$1,$2); free($1);free($2);};
                 | BIT_NOT UNARY_EXPRESSION  {$$ = malloc(strlen($1)+strlen($2)+1); sprintf($$, "%s%s",$1,$2); free($1);free($2);};
                 | PRIMARY_EXP  {$$ = malloc(strlen($1)+1); sprintf($$, "%s",$1); free($1);};
 
PRIMARY_EXP  : LEFT_PAREN EXPRESSION RIGHT_PAREN {$$= malloc(strlen($1)+strlen($2)+strlen($3)+1); sprintf($$, "%s%s%s", $1,$2,$3); free($1); free($2); free($3);}
            ;
             | FACTOR {$$ = malloc(strlen($1)+1); sprintf($$, "%s",$1); free($1);};
             | REF_TYPE {$$ = malloc(strlen($1)+1); sprintf($$, "%s",$1); free($1);};
             ; 

BOOLEAN_EXP : BOOLEAN_EXP AND BIT_WISE_EXP{$$= malloc(strlen($1)+strlen($2)+strlen($3)+1); sprintf($$, "%s%s%s", $1,$2,$3); free($1); free($2); free($3);}
            ;
            | BOOLEAN_EXP OR BIT_WISE_EXP  {$$= malloc(strlen($1)+strlen($2)+strlen($3)+1); sprintf($$, "%s%s%s", $1,$2,$3); free($1); free($2); free($3);}
            ;
            |BIT_WISE_EXP {$$ = malloc(strlen($1)+1); sprintf($$, "%s",$1); free($1);};
            ;
BIT_WISE_EXP :BIT_WISE_EXP BIT_AND RELATIONAL_EXP  {$$= malloc(strlen($1)+strlen($2)+strlen($3)+1); sprintf($$, "%s%s%s", $1,$2,$3); free($1); free($2); free($3);}
            ;
             | BIT_WISE_EXP BIT_XOR RELATIONAL_EXP {$$= malloc(strlen($1)+strlen($2)+strlen($3)+1); sprintf($$, "%s%s%s", $1,$2,$3); free($1); free($2); free($3);}
            ;
             | BIT_WISE_EXP BIT_OR RELATIONAL_EXP {$$= malloc(strlen($1)+strlen($2)+strlen($3)+1); sprintf($$, "%s%s%s", $1,$2,$3); free($1); free($2); free($3);}
            ;
             | RELATIONAL_EXP {$$ = malloc(strlen($1)+1); sprintf($$, "%s",$1); free($1);};
             ;
RELATIONAL_EXP : RELATIONAL_EXP LEFT_ANGLE ARITHMETIC_EXP {$$= malloc(strlen($1)+strlen($2)+strlen($3)+1); sprintf($$, "%s%s%s", $1,$2,$3); free($1); free($2); free($3);}
            ;
               | RELATIONAL_EXP RIGHT_ANGLE ARITHMETIC_EXP {$$= malloc(strlen($1)+strlen($2)+strlen($3)+1); sprintf($$, "%s%s%s", $1,$2,$3); free($1); free($2); free($3);}
            ;
               | RELATIONAL_EXP GREAT_THAN_EQ ARITHMETIC_EXP {$$= malloc(strlen($1)+strlen($2)+strlen($3)+1); sprintf($$, "%s%s%s", $1,$2,$3); free($1); free($2); free($3);}
            ;
               | RELATIONAL_EXP LESS_THAN_EQ ARITHMETIC_EXP {$$= malloc(strlen($1)+strlen($2)+strlen($3)+1); sprintf($$, "%s%s%s", $1,$2,$3); free($1); free($2); free($3);}
            ;
               | RELATIONAL_EXP EQUAL_TO ARITHMETIC_EXP {$$= malloc(strlen($1)+strlen($2)+strlen($3)+1); sprintf($$, "%s%s%s", $1,$2,$3); free($1); free($2); free($3);}
            ;
               | RELATIONAL_EXP NOT_EQ ARITHMETIC_EXP {$$= malloc(strlen($1)+strlen($2)+strlen($3)+1); sprintf($$, "%s%s%s", $1,$2,$3); free($1); free($2); free($3);}
            ;
               |ARITHMETIC_EXP  {$$ = malloc(strlen($1)+1); sprintf($$, "%s",$1); free($1);};
              ;

/* For accessing arrays/functions */
ACCES_VAL: ARITHMETIC_EXP;{$$ = malloc(strlen($1)+1); sprintf($$, "%s",$1); free($1);};
FUNC_ACC_PARAM_LIST: FUNC_ACC_PARAM_LIST COMMA FACTOR {$$= malloc(strlen($1)+strlen($2)+strlen($3)+1); sprintf($$, "%s%s%s", $1,$2,$3); free($1); free($2); free($3);}
                  | FACTOR {$$ = malloc(strlen($1)+1); sprintf($$, "%s",$1); free($1);};
REF_TYPE: VAR LEFT_BRACE  ACCES_VAL RIGHT_BRACE  {$$= malloc(strlen($1)+strlen($2)+strlen($3)+ strlen($4)+1);
                     sprintf($$, "%s%s%s%s", $1,$2,$3,$4);
                     free($1); free($2); free($3); free($4);} /*Access vectors*/
            | VAR LEFT_PAREN FUNC_ACC_PARAM_LIST RIGHT_PAREN {$$= malloc(strlen($1)+strlen($2)+strlen($3)+ strlen($4)+1); 
            sprintf($$, "%s%s%s%s", $1,$2,$3,$4); free($1); free($2); free($3); free($4);
            }/*Call Functions*/
            |VAR LEFT_PAREN RIGHT_PAREN {$$= malloc(strlen($1)+strlen($2)+strlen($3)+1); sprintf($$, "%s%s%s", $1,$2,$3); free($1); free($2); free($3);}
            ;

FACTOR : VAR 
       | INTEGER
       | DOUBLE 
       | SIZE_EXP
       ;
PRINTABLE: EXPRESSION;
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
/*c  = getchar();
if (c=='y'||c=='Y') {
  fclose(tokenFile);
  fclose(parsedFile);
  free_token_list();
  exit(0);
}else {
signal(SIGINT,INThandler);
getchar();
} */
  fclose(tokenFile);
  fclose(parsedFile);
exit(0);
} 
