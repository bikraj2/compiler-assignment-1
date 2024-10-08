alphabet  [a-zA-Z] 
underscore [_]
number    [0-9]

%{ 
#include <stdio.h>
#include "y.tab.h"
#include "string.h"
%}
%{
int lineno = 1;
FILE  * tokenFile;
FILE * parsedFile;
/* 
  1 --> token
  2 --> statement
*/
void addToFile(char * s ,int t);

%}
%%
[0-9]+ {  yylval.intval= atoi(yytext);
        char output[128];
        strcpy(output, "Integer Value :"); 
        addToFile(strcat(output,yytext),1); 
        return INTEGER; 
     };
([0-9]+\.[0-9]+) { yylval.floatval= atof(yytext); 
        char output[128];
        strcpy(output, "Float Value :"); 
        addToFile(strcat(output,yytext),1); 
        return DOUBLE;
        };

int { addToFile("Type : int",1);return INT;}; 
float { addToFile("Type : float",1);return FLOAT;};
big {addToFile("Type : big",1); return BIG;}
small { addToFile("Type : small",1);return SMALL;}

\(  { addToFile("Punctuation : Function Call : (",1);return LEFT_PAREN;}
\)  { addToFile("Punctuation : )",1);return RIGHT_PAREN;}
\{  { addToFile("Punctuation : {",1);return LEFT_CURLY_BRACE;}
\}  { addToFile("Punctuation : }",1);return RIGHT_CURLY_BRACE;}
\[  { addToFile("Punctuation : Access Operator : [",1);return LEFT_BRACE;}
\]  { addToFile("Punctuation : ]",1);return RIGHT_BRACE;}
: { addToFile("Punctuation : :(Colon)",1);return COLON;}
\? { addToFile("Ternary(IF) : ?",1);return TERNARY;}
\> {  addToFile("Punctuation : Comparison Operator : >",1);return RIGHT_ANGLE;}
\< { addToFile("Punctuation : Comparison Operator : <",1);return LEFT_ANGLE;}
, { addToFile("Punctuation : ,",1);return COMMA;}

if { return IF;};
else { addToFile("Reserved Word : else",1); return ELSE;};
set {addToFile("Reserved Word : set",1) ; return SET;}
loop {addToFile("Reserved Word : loop",1) ;return LOOP;}
finally { addToFile("Reserved Word : finally",1); return FINALLY;}
func {addToFile("Reserved Word : func",1) ; return FUNC;}
print { addToFile("Reserved Word : print",1); return PRINT;}
size { addToFile("Reserved Word : size",1) ;return SIZE;}
return { addToFile("Reserved Word : return",1); return RETURN;};


\-\> { addToFile("Access Operator : ->",1); return RIGHT_ACCESS;}
\<\- {addToFile("Access Operator : <-",1); return LEFT_ACCESS;}

\+ { addToFile("Operator : +",1);return ADD_OP;}
\- { addToFile("Operator : -",1);return SUB_OP;}
\/ { addToFile("Operator : /",1);return DIV_OP;}
\* { addToFile("Operator : *",1);return MULT_OP;}
% { addToFile("Operator : %",1); return MOD_OP;}
= { addToFile("Operator : =",1);return ASSIGN;}

or { addToFile("Reserved Word : or",1); return OR;}
and { addToFile("Reserved Word : and",1); return AND;}
not { addToFile("Reserved Word : not",1); return NOT;}

\^ { addToFile("Operator : ^",1);return BIT_XOR;}
\| { addToFile("Operator : |",1);return BIT_OR;}
& { addToFile("Operator : &",1);return BIT_AND;}
~ { addToFile("Operator : ~",1);return BIT_NOT;}

\<= { addToFile("Operator : <=",1);return LESS_THAN_EQ;}
\>= { addToFile("Operator : >=",1);return GREAT_THAN_EQ;}
\<\> { addToFile("Operator : <>",1);return NOT_EQ;}
\== { addToFile("Operator : ==",1);return EQUAL_TO;}
! { addToFile("Operator : !",1);return NOT_OP;}


"#".*\n            {lineno++;};
[ \t]+ {  /* Ignore whitespace */ } {/* [\n] {return EOL;} */}
[\n] {
printf("here\n");
  lineno++;}
; { return SEMI;}
(_)*({alphabet})({alphabet}|{number}|(_))*  { 
    char output[128];
    strcpy(output, "Identifier: ");  
    yylval.sVal = strdup(yytext);
    addToFile( strcat(output, yytext) ,1);
    printf("%s",yylval.sVal);
    return VAR;
    }

.  {};
%%

int yywrap(){ 
    return 1;
}
FILE * file;

void addToFile(char * s, int t) {
   

  switch (t) {
    case  1 : {
    file=fopen("output/token.txt","a+");
    break;
     } 
    case 2 :{
    file=fopen("output/parsed.txt","a+");
    break;
     } 
    default: {
      printf("Invalid Logging Type Passed.\n");
      exit(1);
      } 
  }
  if (file==NULL)
    {
  printf("File not found and also couldnot be created.\n");
  exit(1);
    }
  fprintf(file, "%d : %s\n",lineno,s);
    fclose(file); 
}

