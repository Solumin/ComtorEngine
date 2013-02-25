grammar JavaComments;

options {
	output=AST;
	// type of $stat.tree, etc.
	ASTLabelType=CommonTree;
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
@after{
	String g = getText();
	//remove '//' at start of string
	String s = g.substring(2);
	//remove leading and trailing whitespace.
	s = s.trim();
	setText(s);
}
    :   ({!inString}? => '//' (~('\n'|'\r')*)) 
	;

BLOCK_COMMENT
@after{
	String g = getText();
	//remove leading '/*' and trailing '*/'
	String s = g.substring(2, g.length()-2);
	//remove JavaDoc '*' (leftover from '/**')
	if (s.charAt(0) == '*')
		s = s.substring(1);
	//remove all '*' at the beginning on lines.
	s = s.replaceAll("[\n\r]\\s*\\*\\s*", "\n");
	//remove leading and trailing whitespace
	s = s.trim();
	//Finally, set the text of this node to the formatted comment.
	setText(s);
}
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