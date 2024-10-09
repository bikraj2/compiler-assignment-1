%{
#include <stdio.h> 
#include <stdbool.h>
#include <signal.h>
#include <string.h> 
#include <stdlib.h>
// Supress Errors from the lex and yacc due to ISO-C99
void yyerror(char *);
int yylex();
// To get the Current line no
extern int lineno;
// Two files; Token File and ParsedFile
extern FILE * tokenFile;
extern FILE * parsedFile;
// Function to add the type of token or statement to the file
void addToFile(char * s, int t);
// Handle Abrupt Process Kill
void INThandler(int sig);
int intSize = 0;
int floatSize = 0;
char *fileName;
%}
%union {
    char *sVal; 
}
%token <sVal> INTEGER
%token <sVal> VAR
%token <sVal> DOUBLE
%token <sVal> INT FLOAT VOID BIG SMALL IF ELSE RETURN SIZE
%token <sVal> ADD_OP SUB_OP DIV_OP MULT_OP POW_OP MOD_OP ASSIGN COMP_ASSIGN_ADD
%token <sVal> LESS_THAN LESS_THAN_EQ GREAT_THAN GREAT_THAN_EQ NOT_EQ COMPLEMENT EQUAL_TO
%token <sVal> OR AND NOT BIT_OR BIT_AND BIT_NOT BIT_XOR NOT_OP
%token <sVal> TERNARY COLON SEMI RIGHT_ACCESS LEFT_ACCESS  
%token <sVal> LEFT_PAREN RIGHT_PAREN LEFT_CURLY_BRACE RIGHT_CURLY_BRACE LEFT_BRACE RIGHT_BRACE
%token <sVal> SINGLE_LINE_COMMENT RIGHT_ANGLE LEFT_ANGLE SET LOOP FINALLY PRINT FUNC  COMMA
%type <sVal> PROGRAM SETUP_STATEMENT COMPOUND_STATEMENT RETURN_TYPE
%type <sVal> STATEMENT MUL_FUNC_STATMENT FUNC_STATEMENT LOOP_STATEMENT FINALLY_STMT IF_STATEMENT ELSE_IF_STATEMENT ELSE_STATEMENT CONDITIONAL_STATEMENT PRINT_STATEMENT
%type <sVal> PARAMETER_LIST PARAMETER  RETURN_STATEMENT PUSH_POP_STATEMENT PUSH_STMT POP_STMT SIZE_EXP SET_TYPE SET_STATEMENT_LIST SET_STATEMENT
%type <sVal> VEC_TYPE MIX_TYPE TYPE VAR_TYPE DEC_CONDITION VAR_LIST DEC_STATEMENT ASSIGN_STATEMENT EXPRESSION EXPRESSION_STMT ARITHMETIC_EXP MUL_EXP UNARY_EXPRESSION PRIMARY_EXP BOOLEAN_EXP BIT_WISE_EXP RELATIONAL_EXP ACCES_VAL
%type <sVal> FUNC_ACC_PARAM_LIST REF_TYPE FACTOR PRINTABLE FUNCTION_BODY SET_SIZE
%left OR
%left AND
%left LESS_THAN LESS_THAN_EQ GREAT_THAN GREAT_THAN_EQ EQUAL_TO NOT_EQ
%left ADD_OP SUB_OP
%left MULT_OP DIV_OP MOD_OP
%right NOT 
%right TERNARY
%%
PROGRAM:SETUP_STATEMENT COMPOUND_STATEMENT  {
       $$ = (char *)malloc(strlen($1)+strlen($2)+1); sprintf($$, "%s%s",$1,$2);  
   char *outName;
   outName = (char * ) malloc(strlen(".cpp")+strlen(fileName));
   strcpy(outName,fileName);
   strcat(outName,".cpp");
   FILE *outputFile = fopen(outName,"w");
  if (outputFile ==NULL) {
    fprintf(stderr,"Couldnot create the file");
    return EXIT_FAILURE;
  }
  fprintf(outputFile,"#include <iostream>\n#include <map>\n#include <vector>\nusing namespace std;\n%s\nint main() {\n%sreturn 1;\n}\n",$1,$2);
  fclose(outputFile);    
       printf("#include <iostream>\n#include <map>\n#include <vector>\nusing namespace std;\n%s\nint main() {\n%sreturn 1;\n}\n",$1,$2); free($1);free($2);
       free(outName);
       }
      ;
COMPOUND_STATEMENT: COMPOUND_STATEMENT STATEMENT  {$$ = (char *)malloc(strlen($1)+strlen($2)+1); sprintf($$, "%s%s",$1,$2); free($1);free($2);}
                  |  { $$= (char *)malloc(2); sprintf($$,""); } 

                  ;
/* there can be multiple fucntion declaration statements in the setup section but it must have one set statement */
MUL_FUNC_STATMENT: MUL_FUNC_STATMENT FUNC_STATEMENT {$$ = (char *)malloc(strlen($1)+strlen($2)+1); sprintf($$, "%s%s",$1,$2); free($1);free($2);}
                 | FUNC_STATEMENT {$$ = (char *)malloc(strlen($1)+1); sprintf($$, "%s",$1); free($1);}
                 ;
SET_STATEMENT_LIST : SET_STATEMENT_LIST SET_STATEMENT  {$$ = (char *)malloc(strlen($1)+strlen($2)+1); sprintf($$, "%s%s",$1,$2); free($1);free($2);}
                   | SET_STATEMENT {$$ = (char *)malloc(strlen($1)+1); sprintf($$, "%s",$1); free($1);}
                   ;
SETUP_STATEMENT: SET_STATEMENT_LIST {$$ = (char *)malloc(strlen($1)+1); sprintf($$, "%s",$1); free($1);}
                 | SET_STATEMENT_LIST MUL_FUNC_STATMENT {$$ = (char *)malloc(strlen($1)+strlen($2)+1); sprintf($$, "%s%s",$1,$2); free($1);free($2);}
               ;
/* all the statments that can be seen on the main section */
STATEMENT   : 
            LOOP_STATEMENT  SEMI  {$$ = (char *)malloc(strlen($1)+strlen(";")+1); sprintf($$, "%s\n;",$1); free($1);}
            | PUSH_POP_STATEMENT  SEMI {addToFile("PUSH_POP_STATEMENT", 2); $$ = (char *)malloc(strlen($1)+strlen(";\n")+1); sprintf($$, "%s\n;",$1); free($1);}
            | CONDITIONAL_STATEMENT {$$ = (char *)malloc(strlen($1)+1); sprintf($$, "%s\n",$1); free($1);}
            | PRINT_STATEMENT SEMI{addToFile("PRINT_STATEMENT", 2);$$ = (char *)malloc(strlen($1)+1); sprintf($$, "%s\n",$1); free($1);}
            | DEC_STATEMENT SEMI  {addToFile("DEC_STATEMENT", 2);$$ = (char *)malloc(strlen($1)+2); sprintf($$, "%s;\n",$1); free($1);}
            | EXPRESSION_STMT  {addToFile("EXPRESSION_STMT", 2);$$ = (char *)malloc(strlen($1)+1); sprintf($$, "%s\n",$1); free($1);}
            | ASSIGN_STATEMENT  SEMI {addToFile("ASSIGN_STATEMENT", 2);$$ = (char *)malloc(strlen($1) + strlen("\n") +2); sprintf($$, "%s;\n",$1); free($1);}
            ;
/* definition for the looping statement */
LOOP_STATEMENT :LOOP LEFT_PAREN  DEC_STATEMENT SEMI EXPRESSION SEMI ASSIGN_STATEMENT RIGHT_PAREN COLON LEFT_ANGLE COMPOUND_STATEMENT RIGHT_ANGLE FINALLY_STMT {
               $$= (char *)malloc(strlen("for ")+strlen("(")+strlen($3) + strlen(";") + strlen($5)+strlen(";")+strlen($7)+strlen(")")+strlen("{\n")+strlen($11)+strlen("}\n")+strlen($13)+strlen("if()")+strlen($5)+strlen("{}()!;;;")+ 1); 
            sprintf($$,"for (%s;%s;){\n %s \n %s;\n if (!(%s)) {\n%s}}",$3,$5,$11,$7,$5,$13);
            free($3); free($7); free($5); free($11); free($13);
            }
            ;
             
FINALLY_STMT : FINALLY COLON LEFT_ANGLE COMPOUND_STATEMENT RIGHT_ANGLE {$$= (char *)malloc(  strlen($4)+1); 
            sprintf($$, "%s",$4); free($4);}
            |  { $$= (char *)malloc(2); sprintf($$,"");} 
            ;
 /* definition for the conditional statement with if else */
IF_STATEMENT: BOOLEAN_EXP TERNARY COMPOUND_STATEMENT {addToFile("CONDITIONAL_STATEMENT", 2); 
                        $$= (char *)malloc(strlen($1)+strlen("if(){}")+strlen($3)+1); 
                        sprintf($$, "if(%s){%s}", $1,$3); 
                        free($1);free($3);
                        }
ELSE_IF_STATEMENT: ELSE_IF_STATEMENT IF_STATEMENT {$$= (char *)malloc(strlen($1)+strlen("else")+strlen($2)+1); 
                        sprintf($$, "%selse %s", $1,$2); 
                        free($1);free($2);
                        }
                      | IF_STATEMENT {$$= (char *)malloc(strlen($1)+1); 
                        sprintf($$, "%s", $1); 
                        free($1);
                        }
ELSE_STATEMENT: ELSE COLON COMPOUND_STATEMENT
{$$= (char *)malloc(strlen("else")+strlen("{}")+strlen($3)+1); sprintf($$, "else{%s}",$3); free($3);}
            ;
CONDITIONAL_STATEMENT : LEFT_ANGLE  IF_STATEMENT ELSE_STATEMENT RIGHT_ANGLE {$$= (char *)malloc(strlen($2)+strlen($3)+1); 
            sprintf($$, "%s%s", $2,$3);  free($2); free($3);
            }
            | LEFT_ANGLE  IF_STATEMENT  RIGHT_ANGLE {$$= (char *)malloc(strlen($2)+1); 
            sprintf($$, "%s", $2);  free($2); 
            }
            |LEFT_ANGLE  ELSE_IF_STATEMENT ELSE_STATEMENT  RIGHT_ANGLE LEFT_ANGLE  IF_STATEMENT ELSE_STATEMENT RIGHT_ANGLE {$$= (char *)malloc(strlen($2)+strlen($3)+1); 
            sprintf($$, "%s%s", $2,$3);  free($2); free($3); };
/* Print statement */
PRINT_STATEMENT: PRINT LEFT_PAREN PRINTABLE RIGHT_PAREN {$$= (char *)malloc(strlen("cout<<endl")+strlen("<<")+strlen($3)+1); 
sprintf($$, "cout<<%s<<endl;", $3); free($3); 
            }
/* Function declaration statement */
FUNC_STATEMENT: FUNC VAR LEFT_PAREN PARAMETER_LIST SEMI  RETURN_TYPE RIGHT_PAREN LEFT_ANGLE FUNCTION_BODY RIGHT_ANGLE  
            {
            $$= (char *)malloc(strlen($6)+strlen("(){}\n         ")+strlen($2) + strlen($4)+strlen($9)+1); 
            sprintf($$, "%s %s(%s) {\n %s }",$6,$2,$4,$9 );  free($2); free($4); free($6); free($9); 
            }
            | FUNC VAR  LEFT_PAREN SEMI RETURN_TYPE RIGHT_PAREN LEFT_ANGLE FUNCTION_BODY RIGHT_ANGLE  { 
            $$= (char *)malloc(strlen("func")+strlen($2)+strlen($3)+ strlen("<\n")+strlen($5)+strlen(">\n")+1); 
            sprintf($$,"%s %s( ) {\n %s }",$5,$2,$8);  free($8); free($2); free($5); 
            }
            ;


PARAMETER_LIST : PARAMETER {$$ = (char *)malloc(strlen($1)+1); sprintf($$, "%s",$1); free($1);}
              | PARAMETER_LIST COMMA PARAMETER  {$$= (char *)malloc(strlen($1)+strlen(" , ")+strlen($3)+1); sprintf($$, "%s, %s", $1,$3); free($1); free($3);}
            
                ;
PARAMETER : TYPE VAR {$$ = (char *)malloc(strlen($1)+strlen($2)+3); sprintf($$, "%s %s",$1,$2); free($1);free($2);}

RETURN_TYPE : TYPE {$$ = (char *)malloc(strlen($1)); sprintf($$, "%s",$1 ); free($1);}
            | VOID  {$$ = (char *)malloc(strlen("void")); sprintf($$, "void"); }
            ;
FUNCTION_BODY : COMPOUND_STATEMENT RETURN_STATEMENT{$$ = (char *)malloc(strlen($1)+strlen($2)+1); sprintf($$, "%s%s",$1,$2); free($1);free($2);}
              ;

RETURN_STATEMENT : RETURN EXPRESSION SEMI {addToFile("RETURN_STATEMENT",2); $$= (char *)malloc(strlen("return")+strlen($2)+strlen(";")+1);
             sprintf($$, "return %s;\n", $2); free($2);}
            | RETURN SEMI {addToFile("RETURN_STATEMENT",2); $$= (char *)malloc(2);
             sprintf($$, ""); }

            ; 

/* Vector push pop statements */
PUSH_POP_STATEMENT : PUSH_STMT {$$ = (char *)malloc(strlen($1)+1); sprintf($$, "%s",$1); free($1);}
                 | POP_STMT {$$ = (char *)malloc(strlen($1)+1); sprintf($$, "%s",$1); free($1);}

PUSH_STMT : VAR LEFT_ACCESS LEFT_BRACE EXPRESSION RIGHT_BRACE 
            {$$= (char *)malloc(strlen($1)+strlen("push_back()")+strlen(".")+ strlen($4)+1); 
            sprintf($$, "%s.push_back(%s)", $1,$4); free($1); free($4);
            }
          | LEFT_BRACE EXPRESSION RIGHT_BRACE RIGHT_ACCESS VAR
      {
        size_t total_len = strlen(".insert(.begin(),)") + strlen($2) + 2 * strlen($5) + 1;
        $$ = (char *)malloc(total_len);
        sprintf($$, "%s.insert(%s.begin(),%s)", $5, $5, $2);
        free($2);
        free($5);
      }
    ;          ;
POP_STMT  :  VAR RIGHT_ACCESS LEFT_BRACE VAR RIGHT_BRACE 
            {$$= (char *)malloc(strlen($1)+strlen("=.back();\n.pop_back()")+strlen($4)+strlen("]")+1); 
            sprintf($$, "%s=%s.back();\n%s.pop_back()", $4,$1,$1); free($1); free($4);
            }
          | LEFT_BRACE  RIGHT_BRACE LEFT_ACCESS VAR 
            {$$= (char *)malloc(strlen(".erase(.begin())")+2*strlen($4)+1); 
            sprintf($$, "%s.erase(%s.begin())", $4,$4); free($4);}
          | VAR RIGHT_ACCESS LEFT_BRACE RIGHT_BRACE {$$= (char *)malloc(strlen($1)+strlen(".pop_back()")+ 1); 
            sprintf($$, "%s.pop_back()", $1); 
            free($1);
            }
          ;
SIZE_EXP: SIZE LEFT_BRACE VAR RIGHT_BRACE{$$= (char *)malloc(strlen("size")+strlen("[")+strlen($3)+ strlen("]")+1); 
            sprintf($$, "size[%s]", $3); free($3);}
         ;


/* Set statement */
SET_TYPE: INT {
      if (intSize == 0) {
          $$ = (char *)malloc(strlen("int") + 1);
          sprintf($$, "int");
      }
      else if (intSize == 1) {
          $$ = (char *)malloc(strlen("long long") + 1);
          sprintf($$, "long long");
      }
  }
  | FLOAT {
      if (floatSize == 0) {
          $$ = (char *)malloc(strlen("float") + 1);
          sprintf($$, "float");
      }
      else if (floatSize == 1) {
          $$ = (char *)malloc(strlen("double") + 1);
          sprintf($$, "double");
      }
  };
SET_SIZE: BIG {$$ = (char *)malloc(strlen("big")+1); sprintf($$, "big");}
            |SMALL {$$ = (char *)malloc(strlen("small")+1); sprintf($$, "small");}
            ;

SET_STATEMENT: SET SET_TYPE SET_SIZE SEMI { 
    addToFile("SET_STATEMENT", 2);
    $$ = (char *)malloc(strlen($2) + strlen($3) + strlen(";") + 2); 
    sprintf($$, "%s %s\n", $2, $3);
    free($2); 
    free($3);

    // String comparison to set sizes
    if (strcmp($$, "int big\n") == 0) {
        intSize = 1;
    }
    if (strcmp($$, "float big\n") == 0) {
        floatSize = 1;
    }
    free($$);
    $$= (char *)malloc(2); sprintf($$,"");
};
/* Declaration Statements */
VEC_TYPE:LEFT_BRACE SET_TYPE RIGHT_BRACE 
        {$$= (char *)malloc(strlen("vector")+strlen("<")+strlen($2)+strlen(">")+1); sprintf($$, "vector<%s>", $2); free($2);}
            ; 
MIX_TYPE: SET_TYPE{$$ = (char *)malloc(strlen($1)+1); sprintf($$, "%s",$1); free($1);}
                 | VEC_TYPE{$$ = (char *)malloc(strlen($1)+1); sprintf($$, "%s",$1); free($1);} ;
TYPE : SET_TYPE {$$ = (char *)malloc(strlen($1)+1); sprintf($$, "%s",$1); free($1);}
        | VEC_TYPE {$$ = (char *)malloc(strlen($1)+1); sprintf($$, "%s",$1); free($1);}
        | LEFT_CURLY_BRACE SET_TYPE COLON MIX_TYPE RIGHT_CURLY_BRACE
        {$$= (char *)malloc(strlen("map")+strlen("<")+strlen($2)+strlen(",")+ strlen($4)+strlen(">")+1); 
            sprintf($$, "map<%s,%s>", $2,$4);  free($2);free($4);
            }
        ;     

VAR_TYPE: INTEGER {$$ = (char *)malloc(strlen($1)+3); sprintf($$, " %s ",$1); free($1);} 
            | DOUBLE {$$ = (char *)malloc(strlen($1)+3); sprintf($$, " %s ",$1); free($1);}
DEC_CONDITION: ASSIGN VAR_TYPE  {$$ = (char *)malloc(strlen(" = ")+strlen($2)+1); sprintf($$, " = %s",$2);free($2);}
             | { $$= (char *)malloc(2); sprintf($$,""); } 
             ;
VAR_LIST: VAR_LIST COMMA VAR DEC_CONDITION {$$= (char *)malloc(strlen($1)+strlen(",")+strlen($3)+ strlen($4)+1); 
            sprintf($$, "%s,%s %s", $1,$3,$4); free($1); free($3); free($4);
            }
            |  VAR DEC_CONDITION {
   $$ = (char *)malloc(strlen($1)+strlen($2)+1); sprintf($$, "%s %s",$1,$2); free($1);free($2);}

DEC_STATEMENT: TYPE VAR_LIST { 
$$= (char *)malloc(strlen($1)+strlen($2)+strlen(" ; ")+1); sprintf($$, "%s %s", $1,$2); 
                    free($1); free($2); } 
            ;  
/* Assignment Statement */
ASSIGN_STATEMENT: VAR ASSIGN EXPRESSION {$$= (char *)malloc(strlen($1)+strlen(" = ")+strlen($3)+1); 
                        sprintf($$, "%s=%s", $1,$3); free($1); free($3);} 
            ;

/* Expressions that make up boolean, arithmetic , bitwise operations */
EXPRESSION_STMT : EXPRESSION SEMI {$$ = (char *)malloc(strlen($1)+strlen(";")+1); 
                        sprintf($$, "%s;\n",$1); free($1);}
EXPRESSION : BOOLEAN_EXP  {$$ = (char *)malloc(strlen($1)+1); sprintf($$, "%s",$1); free($1);} 
           ;
ARITHMETIC_EXP : ARITHMETIC_EXP ADD_OP  MUL_EXP  {$$= (char *)malloc(strlen($1)+strlen(" + ")+strlen($3)+1); 
                    sprintf($$, "%s + %s", $1,$3); free($1);free($3);}
             
               | ARITHMETIC_EXP SUB_OP MUL_EXP {$$= (char *)malloc(strlen($1)+strlen(" - ")+strlen($3)+1); 
               sprintf($$, "%s - %s", $1,$3); free($1); free($3);}
             
               | MUL_EXP {$$ = (char *)malloc(strlen($1)+1); sprintf($$, "%s",$1); free($1);}
	            ;

MUL_EXP : MUL_EXP MULT_OP  UNARY_EXPRESSION 
        {$$= (char *)malloc(strlen($1)+strlen(" * ")+strlen($3)+1); 
        sprintf($$, "%s * %s", $1,$3); 
        free($1); free($3);}
             
        | MUL_EXP DIV_OP UNARY_EXPRESSION {$$= (char *)malloc(strlen($1)+strlen(" / ")+strlen($3)+1); 
        sprintf($$, "%s / %s", $1,$3); free($1); free($3);}
             
        | UNARY_EXPRESSION  {$$ = (char *)malloc(strlen($1)+1); sprintf($$, "%s",$1); free($1);}
        ;

UNARY_EXPRESSION : NOT_OP UNARY_EXPRESSION  {$$ = (char *)malloc(strlen("! ")+strlen($2)+1); sprintf($$, "! %s",$2); free($2);}
                 | BIT_NOT UNARY_EXPRESSION  {$$ = (char *)malloc(strlen("~ ")+strlen($2)+1); sprintf($$, "~ %s",$2); 
                            free($1);free($2);}
                 | PRIMARY_EXP  {$$ = (char *)malloc(strlen($1)+1); sprintf($$, "%s",$1); free($1);}
 
PRIMARY_EXP  : LEFT_PAREN EXPRESSION RIGHT_PAREN {$$= (char *)malloc(strlen(" ( ")+strlen($2)+strlen(" ) ")+1); 
                sprintf($$, "(%s)", $2); free($2); }
             
             | FACTOR {$$ = (char *)malloc(strlen($1)+1); sprintf($$, "%s",$1); free($1);}
             | REF_TYPE {$$ = (char *)malloc(strlen($1)+1); sprintf($$, "%s",$1); free($1);}
             ; 

BOOLEAN_EXP : BOOLEAN_EXP AND BIT_WISE_EXP{
            $$= (char *)malloc(strlen($1)+strlen("and")+strlen($3)+1); 
            sprintf($$, "%sand%s", $1,$3); free($1);  free($3);}
             
            | BOOLEAN_EXP OR BIT_WISE_EXP  
            {$$= (char *)malloc(strlen($1)+strlen(" or ")+strlen($3)+1); 
                sprintf($$, "%sor%s", $1,$3); free($1);  free($3);}
             
            |BIT_WISE_EXP {$$ = (char *)malloc(strlen($1)+1); sprintf($$, " %s ",$1); free($1);}
            ;
BIT_WISE_EXP :BIT_WISE_EXP BIT_AND RELATIONAL_EXP  
            {$$= (char *)malloc(strlen($1)+strlen(" & ")+strlen($3)+1); sprintf($$, "%s & %s", $1,$3); free($1); free($3);}
             
             | BIT_WISE_EXP BIT_XOR RELATIONAL_EXP {$$= (char *)malloc(strlen($1)+strlen(" ^ ")+strlen($3)+1); 
             sprintf($$, "%s ^ %s", $1,$3); free($1); free($3);}
             
             | BIT_WISE_EXP BIT_OR RELATIONAL_EXP {$$= (char *)malloc(strlen($1)+strlen(" | ")+strlen($3)+1); 
             sprintf($$, "%s | %s", $1,$3); free($1); free($3);}
             
             | RELATIONAL_EXP {$$ = (char *)malloc(strlen($1)+1); sprintf($$, " %s ",$1); free($1);}
             ;
RELATIONAL_EXP : RELATIONAL_EXP LEFT_ANGLE ARITHMETIC_EXP 
            {$$= (char *)malloc(strlen($1)+strlen(" < ")+strlen($3)+1); sprintf($$, " %s < %s", $1,$3); free($1); free($3); }
             
               | RELATIONAL_EXP RIGHT_ANGLE ARITHMETIC_EXP 
               {$$= (char *)malloc(strlen($1)+strlen(" > ")+strlen($3)+1); sprintf($$, " %s > %s ", $1,$3); free($1); free($3);}
             
               | RELATIONAL_EXP GREAT_THAN_EQ ARITHMETIC_EXP 
               {$$= (char *)malloc(strlen($1)+strlen(" >= ")+strlen($3)+1); sprintf($$, " %s >= %s ", $1,$3); free($1); free($3);}
             
               | RELATIONAL_EXP LESS_THAN_EQ ARITHMETIC_EXP 
               {$$= (char *)malloc(strlen($1)+strlen(" <= ")+strlen($3)+1); sprintf($$, " %s <= %s ", $1,$3); free($1); free($3);}
             
               | RELATIONAL_EXP EQUAL_TO ARITHMETIC_EXP 
               {$$= (char *)malloc(strlen($1)+strlen(" == ")+strlen($3)+1); sprintf($$, " %s == %s", $1,$3); free($1); free($3);}
             
               | RELATIONAL_EXP NOT_EQ ARITHMETIC_EXP 
                {$$= (char *)malloc(strlen($1)+strlen(" <> ")+strlen($3)+1); sprintf($$, " %s <> %s ", $1,$3); free($1); free($3);}             
               |ARITHMETIC_EXP  {$$ = (char *)malloc(strlen($1)+1); sprintf($$, " %s ",$1); free($1);}
              ;

/* For accessing arrays/functions */
ACCES_VAL: ARITHMETIC_EXP {$$ = (char *)malloc(strlen($1)+1); sprintf($$, " %s ",$1); free($1);};
FUNC_ACC_PARAM_LIST: FUNC_ACC_PARAM_LIST COMMA FACTOR 
                        {$$= (char *)malloc(strlen($1)+strlen(",")+strlen($3)+1); sprintf($$, " %s ,%s ", $1,$3); free($1); free($3);}
                  | FACTOR {$$ = (char *)malloc(strlen($1)+1); sprintf($$, " %s ",$1); free($1);}
REF_TYPE: VAR LEFT_BRACE  ACCES_VAL RIGHT_BRACE  
            {$$= (char *)malloc(strlen($1)+strlen("[")+strlen($3)+ strlen(" ] ")+1);
                     sprintf($$, "%s[%s]", $1,$3);
                     free($1);free($3); } /*Access vectors*/
            | VAR LEFT_PAREN FUNC_ACC_PARAM_LIST RIGHT_PAREN {$$= (char *)malloc(strlen($1)+strlen(" ( ")+strlen($3)+ strlen(" ) ")+1); 
            sprintf($$, "%s(%s)", $1,$3); free($1); free($3); 
            }/*Call Functions*/
            |VAR LEFT_PAREN RIGHT_PAREN {$$= (char *)malloc(strlen($1)+strlen("(")+strlen(")")+1); 
            sprintf($$, "%s()", $1); free($1); }
            ;

FACTOR : VAR  {$$ = (char *)malloc(strlen($1)+strlen("  ")+1); sprintf($$, "%s",$1);}
       | INTEGER {$$ = (char *)malloc(strlen($1)+strlen("  ")+1); sprintf($$, "%s",$1); } 
       | DOUBLE {$$ = (char *)malloc(strlen($1)+strlen("  ")+1); sprintf($$, "%s",$1); } 
       | SIZE_EXP{$$ = (char *)malloc(strlen($1)+strlen("  ")+1); sprintf($$, "%s",$1); } 
       ;
PRINTABLE: EXPRESSION {$$ = (char *)malloc(strlen($1)+1); sprintf($$, "%s",$1); free($1);};
         

%%

void yyerror(char *s) {
    fprintf(stderr, "line %d: %s\n", lineno, s);
}

extern FILE *yyin;
void INThandler(int sig) 
{

char c;
  // Catching the signal
  signal(sig,SIG_IGN);
  printf("\nDid you hit (Crtl-c)?\n Are you sure you want to close this program ? (Y/N)\n");
/*c  = getchar();
if (c=="y"||c=="Y") {
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

int main(int argc, char *argv[]) {
    if (argc < 2) {
        fprintf(stderr, "Usage: %s <input_file>\n", argv[0]);
        return EXIT_FAILURE;
    }

  fileName = strdup(argv[1]);
    FILE *inputFile = fopen(argv[1], "r");

    if (inputFile == NULL) {
        perror("Error opening file");
        return EXIT_FAILURE;
    }

    yyin = inputFile;

    do  {
        if (yyparse() != 0) {
            break; 
        }
    }while(!feof(inputFile));
    fclose(inputFile);
    return EXIT_SUCCESS;
}
