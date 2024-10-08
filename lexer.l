alphabet  [a-zA-Z] 
underscore [_]
number    [0-9]

%{ 
#include <stdio.h>
#include "y.tab.h"

%}
%{
int lineno = 1;
/* 
  1 --> token
  2 --> statement
*/
void addToFile(char * s ,int t);

%}
%%
[0-9]+ {  yylval.intval= atoi(yytext); return INTEGER; };
([0-9]+\.[0-9]+) { yylval.floatval= atof(yytext); return DOUBLE;};

int { addToFile("random",1);return INT;}; 
float { return FLOAT;};
big { return BIG;}
small { return SMALL;}

\(  { return LEFT_PAREN;}
\)  { return RIGHT_PAREN;}
\{  { return LEFT_CURLY_BRACE;}
\}  { return RIGHT_CURLY_BRACE;}
\[  { return LEFT_BRACE;}
\]  { return RIGHT_BRACE;}
: { return COLON;}
\? { return TERNARY;}
\> { return RIGHT_ANGLE;}
\< { return LEFT_ANGLE;}
, { return COMMA;}

if { return IF;};
else { return ELSE;};
set { return SET;}
loop {return LOOP;}
finally { return FINALLY;}
func { return FUNC;}
print { return PRINT;}
size { return SIZE;}
return { return RETURN;};


\-\> { return RIGHT_ACCESS;}
\<\- { return LEFT_ACCESS;}

\+ { return ADD_OP;}
\- { return SUB_OP;}
\/ { return DIV_OP;}
\* { return MULT_OP;}
% { return MOD_OP;}
= { return ASSIGN;}

or { return OR;}
and { return AND;}
not { return NOT;}

\^ { return BIT_XOR;}
\| { return BIT_OR;}
& { return BIT_AND;}
~ { return BIT_NOT;}

\<= { return LESS_THAN_EQ;}
\>= { return GREAT_THAN_EQ;}
\<\> { return NOT_EQ;}
\== { return EQUAL_TO;}
! { return NOT_OP;}


"#".*\n            {};
[ \t]+ {  /* Ignore whitespace */ } {/* [\n] {return EOL;} */}
[\n] {lineno++;}
; { return SEMI;}
(_)*({alphabet})({alphabet}|{number}|(_))*  { return VAR;}/*variable name can start with "_"provided that the first character after "_" is a alphabet not a number*/

.  {};
%%

int yywrap(){ 
    return 1;
}

FILE * file;

void addToFile(char * s, int t) {
  switch (t) {
    case  1 : {
    file= fopen("output/token.txt", "a");
    printf("Printhere");
    break;
     } 
    case 2 :{
    file= fopen("output/parsed.txt", "a");
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

