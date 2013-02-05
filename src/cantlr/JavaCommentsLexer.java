// $ANTLR 3.3 Nov 30, 2010 12:50:56 JavaComments.g 2012-11-20 12:18:02

import org.antlr.runtime.*;
import java.util.Stack;
import java.util.List;
import java.util.ArrayList;

public class JavaCommentsLexer extends Lexer {
    public static final int EOF=-1;
    public static final int COMMENTS=4;
    public static final int BLOCK_COMMENT=5;
    public static final int LINE_COMMENT=6;
    public static final int OTHER=7;
    boolean inString=false;

    // delegates
    // delegators

    public JavaCommentsLexer() {;} 
    public JavaCommentsLexer(CharStream input) {
        this(input, new RecognizerSharedState());
    }
    public JavaCommentsLexer(CharStream input, RecognizerSharedState state) {
        super(input,state);

    }
    public String getGrammarFileName() { return "JavaComments.g"; }

    // $ANTLR start "LINE_COMMENT"
    public final void mLINE_COMMENT() throws RecognitionException {
        try {
            int _type = LINE_COMMENT;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // JavaComments.g:29:5: ( ({...}? => '//' ( (~ ( '\\n' | '\\r' ) )* ) ) )
            // JavaComments.g:29:9: ({...}? => '//' ( (~ ( '\\n' | '\\r' ) )* ) )
            {
            // JavaComments.g:29:9: ({...}? => '//' ( (~ ( '\\n' | '\\r' ) )* ) )
            // JavaComments.g:29:10: {...}? => '//' ( (~ ( '\\n' | '\\r' ) )* )
            {
            if ( !((!inString)) ) {
                throw new FailedPredicateException(input, "LINE_COMMENT", "!inString");
            }
            match("//"); 

            // JavaComments.g:29:31: ( (~ ( '\\n' | '\\r' ) )* )
            // JavaComments.g:29:32: (~ ( '\\n' | '\\r' ) )*
            {
            // JavaComments.g:29:32: (~ ( '\\n' | '\\r' ) )*
            loop1:
            do {
                int alt1=2;
                int LA1_0 = input.LA(1);

                if ( ((LA1_0>='\u0000' && LA1_0<='\t')||(LA1_0>='\u000B' && LA1_0<='\f')||(LA1_0>='\u000E' && LA1_0<='\uFFFF')) ) {
                    alt1=1;
                }


                switch (alt1) {
            	case 1 :
            	    // JavaComments.g:29:32: ~ ( '\\n' | '\\r' )
            	    {
            	    if ( (input.LA(1)>='\u0000' && input.LA(1)<='\t')||(input.LA(1)>='\u000B' && input.LA(1)<='\f')||(input.LA(1)>='\u000E' && input.LA(1)<='\uFFFF') ) {
            	        input.consume();

            	    }
            	    else {
            	        MismatchedSetException mse = new MismatchedSetException(null,input);
            	        recover(mse);
            	        throw mse;}


            	    }
            	    break;

            	default :
            	    break loop1;
                }
            } while (true);


            }


            }


            }

            state.type = _type;
            state.channel = _channel;

            	String g = getText();
            	//remove '//' at start of string
            	String s = g.substring(2);
            	//remove leading and trailing whitespace.
            	s = s.trim();
            	setText(s);
        }
        finally {
        }
    }
    // $ANTLR end "LINE_COMMENT"

    // $ANTLR start "BLOCK_COMMENT"
    public final void mBLOCK_COMMENT() throws RecognitionException {
        try {
            int _type = BLOCK_COMMENT;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // JavaComments.g:48:5: ( ({...}? => '/*' ( options {greedy=false; } : . )* '*/' ) )
            // JavaComments.g:48:9: ({...}? => '/*' ( options {greedy=false; } : . )* '*/' )
            {
            // JavaComments.g:48:9: ({...}? => '/*' ( options {greedy=false; } : . )* '*/' )
            // JavaComments.g:48:10: {...}? => '/*' ( options {greedy=false; } : . )* '*/'
            {
            if ( !((!inString)) ) {
                throw new FailedPredicateException(input, "BLOCK_COMMENT", "!inString");
            }
            match("/*"); 

            // JavaComments.g:48:31: ( options {greedy=false; } : . )*
            loop2:
            do {
                int alt2=2;
                int LA2_0 = input.LA(1);

                if ( (LA2_0=='*') ) {
                    int LA2_1 = input.LA(2);

                    if ( (LA2_1=='/') ) {
                        alt2=2;
                    }
                    else if ( ((LA2_1>='\u0000' && LA2_1<='.')||(LA2_1>='0' && LA2_1<='\uFFFF')) ) {
                        alt2=1;
                    }


                }
                else if ( ((LA2_0>='\u0000' && LA2_0<=')')||(LA2_0>='+' && LA2_0<='\uFFFF')) ) {
                    alt2=1;
                }


                switch (alt2) {
            	case 1 :
            	    // JavaComments.g:48:58: .
            	    {
            	    matchAny(); 

            	    }
            	    break;

            	default :
            	    break loop2;
                }
            } while (true);

            match("*/"); 


            }


            }

            state.type = _type;
            state.channel = _channel;

            	String g = getText();
            	//remove leading '/*' and trailing '*/'
            	String s = g.substring(2, g.length()-2);
            	//remove JavaDoc '*' (leftover from '/**')
            	if (s.charAt(0) == '*')
            		s = s.substring(1);
            	//replace all '*' at the beginning on lines.
            	s = s.replaceAll("[\n\r]\\s*\\*", "");
            	//remove whitespace at the ends of lines and replace with just a space
            	s = s.replaceAll("\\s+$", " ");
            	//remove leading and trailing whitespace
            	s = s.trim();
            	setText(s);
        }
        finally {
        }
    }
    // $ANTLR end "BLOCK_COMMENT"

    // $ANTLR start "OTHER"
    public final void mOTHER() throws RecognitionException {
        try {
            int _type = OTHER;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            int c;

            // JavaComments.g:52:5: (c= . )
            // JavaComments.g:52:7: c= .
            {
            c = input.LA(1);
            matchAny(); 

                	if ((char)c == '"' && (char)input.LA(-2) != '\\')
                		inString = !inString;

                	skip();
                

            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "OTHER"

    public void mTokens() throws RecognitionException {
        // JavaComments.g:1:8: ( LINE_COMMENT | BLOCK_COMMENT | OTHER )
        int alt3=3;
        int LA3_0 = input.LA(1);

        if ( (LA3_0=='/') ) {
            int LA3_1 = input.LA(2);

            if ( (LA3_1=='/') && ((!inString))) {
                alt3=1;
            }
            else if ( (LA3_1=='*') && ((!inString))) {
                alt3=2;
            }
            else {
                alt3=3;}
        }
        else if ( ((LA3_0>='\u0000' && LA3_0<='.')||(LA3_0>='0' && LA3_0<='\uFFFF')) ) {
            alt3=3;
        }
        else {
            NoViableAltException nvae =
                new NoViableAltException("", 3, 0, input);

            throw nvae;
        }
        switch (alt3) {
            case 1 :
                // JavaComments.g:1:10: LINE_COMMENT
                {
                mLINE_COMMENT(); 

                }
                break;
            case 2 :
                // JavaComments.g:1:23: BLOCK_COMMENT
                {
                mBLOCK_COMMENT(); 

                }
                break;
            case 3 :
                // JavaComments.g:1:37: OTHER
                {
                mOTHER(); 

                }
                break;

        }

    }


 

}