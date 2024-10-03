alphabet  [a-zA-Z] 
underscore [_]
number    [0-9]

%{ 
#include <stdio.h>
#include "y.tab.h"

%}

%%
[0-9]+ {  yylval.intval= atoi(yytext); return INTEGER; };
([0-9]+\.[0-9]+) { yylval.floatval= atof(yytext); return DOUBLE;};

int { return INT;}; 
float { return FLOAT;};
big {return BIG;}
small { return SMALL;}

\(  {return LEFT_PAREN;}
\)  {return RIGHT_PAREN;}
\{  {return LEFT_CURLY_BRACE;}
\}  {return RIGHT_CURLY_BRACE;}
\[  {return LEFT_BRACE;}
\]  {return RIGHT_BRACE;}
: { return COLON;}
\? { return TERNARY;}
\< { return RIGHT_ANGLE;}
\> { return LEFT_ANGLE;}

if { return IF;};
else { return ELSE;};
set { return SET;}
loop {return LOOP;}
finally { return FINALLY;}
func { return FUNC;}
print { return PRINT;}
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

\^ { return POW_OP;}/*Power operator will have a return type double*/
\| { return BIT_OR;}
& { return BIT_AND;}
~ { return BIT_NOT;}

\<= { return LESS_THAN_EQ;}
\>= { return GREAT_THAN_EQ;}
\<\> { return NOT_EQ;}
\=== { return EQUAL_TO;}
! { return COMPLEMENT;}

"#".*\n            { return SINGLE_LINE_COMMENT ;};
[ \t]+ {  /* Ignore whitespace */ } {/* [\n] {return EOL;} */}
; { return SEMI;}
(_)*({alphabet})({alphabet}|{number}|(_))*  { return VAR;}/*variable name can start with "_"provided that the first character after "_" is a alphabet not a number*/

.  {};
%%

int yywrap(){ 
    return 1;
}



