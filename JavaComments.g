grammar JavaComments;

options {
	output=AST;
	ASTLabelType=CommonTree; // type of $stat.tree, etc.
	backtrack=true;
}

tokens {COMMENTS;}
@lexer::members {boolean inString=false;}

start 	:	findComments* -> ^(COMMENTS findComments*);

findComments
    : BLOCK_COMMENT -> ^(BLOCK_COMMENT)
    | LINE_COMMENT -> ^(LINE_COMMENT)
    ;
    
LINE_COMMENT
    :   ({!inString}? => '//' (~('\n'|'\r')*)  ('\r\n' | '\r' | '\n'))
    |   ({!inString}? => '//' (~('\n'|'\r')*))  // a line comment could appear at the end of the file without CR/LF
    ; 

BLOCK_COMMENT
    :   ({!inString}? => '/*' (options {greedy=false;} : . )* '*/')
    ;

OTHER
    : c=. 
    {
    	if ((char)c == '"' && (char)input.LA(-2) != '\\')
    		inString = !inString;

    	skip();
    } 
    ;