grammar JavaComments;

options {
	output=AST;
	ASTLabelType=CommonTree; // type of $stat.tree, etc.
	backtrack=true;
}

tokens {COMMENTS;}

start 	:	findComments* -> ^(COMMENTS findComments*);

findComments
    : BLOCK_COMMENT -> ^(BLOCK_COMMENT)
    | LINE_COMMENT -> ^(LINE_COMMENT)
    ;

OTHER
    : . {skip();}//~(LINE_COMMENT | BLOCK_COMMENT) {skip();}
    ;

LINE_COMMENT
    :   '//' (~('\n'|'\r')*)  ('\r\n' | '\r' | '\n')
    |   '//' (~('\n'|'\r')*)  // a line comment could appear at the end of the file without CR/LF
    ; 

BLOCK_COMMENT
    :   '/*' (options {greedy=false;} : . )* '*/'
    ;

