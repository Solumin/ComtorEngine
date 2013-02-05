// $ANTLR 3.3 Nov 30, 2010 12:50:56 JavaComments.g 2012-11-20 12:18:02

import org.antlr.runtime.*;
import java.util.Stack;
import java.util.List;
import java.util.ArrayList;
import java.util.Map;
import java.util.HashMap;

import org.antlr.runtime.tree.*;

public class JavaCommentsParser extends Parser {
    public static final String[] tokenNames = new String[] {
        "<invalid>", "<EOR>", "<DOWN>", "<UP>", "COMMENTS", "BLOCK_COMMENT", "LINE_COMMENT", "OTHER"
    };
    public static final int EOF=-1;
    public static final int COMMENTS=4;
    public static final int BLOCK_COMMENT=5;
    public static final int LINE_COMMENT=6;
    public static final int OTHER=7;

    // delegates
    // delegators


        public JavaCommentsParser(TokenStream input) {
            this(input, new RecognizerSharedState());
        }
        public JavaCommentsParser(TokenStream input, RecognizerSharedState state) {
            super(input, state);
             
        }
        
    protected TreeAdaptor adaptor = new CommonTreeAdaptor();

    public void setTreeAdaptor(TreeAdaptor adaptor) {
        this.adaptor = adaptor;
    }
    public TreeAdaptor getTreeAdaptor() {
        return adaptor;
    }

    public String[] getTokenNames() { return JavaCommentsParser.tokenNames; }
    public String getGrammarFileName() { return "JavaComments.g"; }


    public static class start_return extends ParserRuleReturnScope {
        CommonTree tree;
        public Object getTree() { return tree; }
    };

    // $ANTLR start "start"
    // JavaComments.g:13:1: start : ( findComments )* -> ^( COMMENTS ( findComments )* ) ;
    public final JavaCommentsParser.start_return start() throws RecognitionException {
        JavaCommentsParser.start_return retval = new JavaCommentsParser.start_return();
        retval.start = input.LT(1);

        CommonTree root_0 = null;

        JavaCommentsParser.findComments_return findComments1 = null;


        RewriteRuleSubtreeStream stream_findComments=new RewriteRuleSubtreeStream(adaptor,"rule findComments");
        try {
            // JavaComments.g:13:8: ( ( findComments )* -> ^( COMMENTS ( findComments )* ) )
            // JavaComments.g:13:10: ( findComments )*
            {
            // JavaComments.g:13:10: ( findComments )*
            loop1:
            do {
                int alt1=2;
                int LA1_0 = input.LA(1);

                if ( ((LA1_0>=BLOCK_COMMENT && LA1_0<=LINE_COMMENT)) ) {
                    alt1=1;
                }


                switch (alt1) {
            	case 1 :
            	    // JavaComments.g:0:0: findComments
            	    {
            	    pushFollow(FOLLOW_findComments_in_start50);
            	    findComments1=findComments();

            	    state._fsp--;
            	    if (state.failed) return retval;
            	    if ( state.backtracking==0 ) stream_findComments.add(findComments1.getTree());

            	    }
            	    break;

            	default :
            	    break loop1;
                }
            } while (true);



            // AST REWRITE
            // elements: findComments
            // token labels: 
            // rule labels: retval
            // token list labels: 
            // rule list labels: 
            // wildcard labels: 
            if ( state.backtracking==0 ) {
            retval.tree = root_0;
            RewriteRuleSubtreeStream stream_retval=new RewriteRuleSubtreeStream(adaptor,"rule retval",retval!=null?retval.tree:null);

            root_0 = (CommonTree)adaptor.nil();
            // 13:24: -> ^( COMMENTS ( findComments )* )
            {
                // JavaComments.g:13:27: ^( COMMENTS ( findComments )* )
                {
                CommonTree root_1 = (CommonTree)adaptor.nil();
                root_1 = (CommonTree)adaptor.becomeRoot((CommonTree)adaptor.create(COMMENTS, "COMMENTS"), root_1);

                // JavaComments.g:13:38: ( findComments )*
                while ( stream_findComments.hasNext() ) {
                    adaptor.addChild(root_1, stream_findComments.nextTree());

                }
                stream_findComments.reset();

                adaptor.addChild(root_0, root_1);
                }

            }

            retval.tree = root_0;}
            }

            retval.stop = input.LT(-1);

            if ( state.backtracking==0 ) {

            retval.tree = (CommonTree)adaptor.rulePostProcessing(root_0);
            adaptor.setTokenBoundaries(retval.tree, retval.start, retval.stop);
            }
        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
    	retval.tree = (CommonTree)adaptor.errorNode(input, retval.start, input.LT(-1), re);

        }
        finally {
        }
        return retval;
    }
    // $ANTLR end "start"

    public static class findComments_return extends ParserRuleReturnScope {
        CommonTree tree;
        public Object getTree() { return tree; }
    };

    // $ANTLR start "findComments"
    // JavaComments.g:15:1: findComments : ( BLOCK_COMMENT -> ^( BLOCK_COMMENT ) | LINE_COMMENT -> ^( LINE_COMMENT ) );
    public final JavaCommentsParser.findComments_return findComments() throws RecognitionException {
        JavaCommentsParser.findComments_return retval = new JavaCommentsParser.findComments_return();
        retval.start = input.LT(1);

        CommonTree root_0 = null;

        Token BLOCK_COMMENT2=null;
        Token LINE_COMMENT3=null;

        CommonTree BLOCK_COMMENT2_tree=null;
        CommonTree LINE_COMMENT3_tree=null;
        RewriteRuleTokenStream stream_BLOCK_COMMENT=new RewriteRuleTokenStream(adaptor,"token BLOCK_COMMENT");
        RewriteRuleTokenStream stream_LINE_COMMENT=new RewriteRuleTokenStream(adaptor,"token LINE_COMMENT");

        try {
            // JavaComments.g:16:5: ( BLOCK_COMMENT -> ^( BLOCK_COMMENT ) | LINE_COMMENT -> ^( LINE_COMMENT ) )
            int alt2=2;
            int LA2_0 = input.LA(1);

            if ( (LA2_0==BLOCK_COMMENT) ) {
                alt2=1;
            }
            else if ( (LA2_0==LINE_COMMENT) ) {
                alt2=2;
            }
            else {
                if (state.backtracking>0) {state.failed=true; return retval;}
                NoViableAltException nvae =
                    new NoViableAltException("", 2, 0, input);

                throw nvae;
            }
            switch (alt2) {
                case 1 :
                    // JavaComments.g:16:7: BLOCK_COMMENT
                    {
                    BLOCK_COMMENT2=(Token)match(input,BLOCK_COMMENT,FOLLOW_BLOCK_COMMENT_in_findComments72); if (state.failed) return retval; 
                    if ( state.backtracking==0 ) stream_BLOCK_COMMENT.add(BLOCK_COMMENT2);



                    // AST REWRITE
                    // elements: BLOCK_COMMENT
                    // token labels: 
                    // rule labels: retval
                    // token list labels: 
                    // rule list labels: 
                    // wildcard labels: 
                    if ( state.backtracking==0 ) {
                    retval.tree = root_0;
                    RewriteRuleSubtreeStream stream_retval=new RewriteRuleSubtreeStream(adaptor,"rule retval",retval!=null?retval.tree:null);

                    root_0 = (CommonTree)adaptor.nil();
                    // 16:21: -> ^( BLOCK_COMMENT )
                    {
                        // JavaComments.g:16:24: ^( BLOCK_COMMENT )
                        {
                        CommonTree root_1 = (CommonTree)adaptor.nil();
                        root_1 = (CommonTree)adaptor.becomeRoot(stream_BLOCK_COMMENT.nextNode(), root_1);

                        adaptor.addChild(root_0, root_1);
                        }

                    }

                    retval.tree = root_0;}
                    }
                    break;
                case 2 :
                    // JavaComments.g:17:7: LINE_COMMENT
                    {
                    LINE_COMMENT3=(Token)match(input,LINE_COMMENT,FOLLOW_LINE_COMMENT_in_findComments86); if (state.failed) return retval; 
                    if ( state.backtracking==0 ) stream_LINE_COMMENT.add(LINE_COMMENT3);



                    // AST REWRITE
                    // elements: LINE_COMMENT
                    // token labels: 
                    // rule labels: retval
                    // token list labels: 
                    // rule list labels: 
                    // wildcard labels: 
                    if ( state.backtracking==0 ) {
                    retval.tree = root_0;
                    RewriteRuleSubtreeStream stream_retval=new RewriteRuleSubtreeStream(adaptor,"rule retval",retval!=null?retval.tree:null);

                    root_0 = (CommonTree)adaptor.nil();
                    // 17:20: -> ^( LINE_COMMENT )
                    {
                        // JavaComments.g:17:23: ^( LINE_COMMENT )
                        {
                        CommonTree root_1 = (CommonTree)adaptor.nil();
                        root_1 = (CommonTree)adaptor.becomeRoot(stream_LINE_COMMENT.nextNode(), root_1);

                        adaptor.addChild(root_0, root_1);
                        }

                    }

                    retval.tree = root_0;}
                    }
                    break;

            }
            retval.stop = input.LT(-1);

            if ( state.backtracking==0 ) {

            retval.tree = (CommonTree)adaptor.rulePostProcessing(root_0);
            adaptor.setTokenBoundaries(retval.tree, retval.start, retval.stop);
            }
        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
    	retval.tree = (CommonTree)adaptor.errorNode(input, retval.start, input.LT(-1), re);

        }
        finally {
        }
        return retval;
    }
    // $ANTLR end "findComments"

    // Delegated rules


 

    public static final BitSet FOLLOW_findComments_in_start50 = new BitSet(new long[]{0x0000000000000062L});
    public static final BitSet FOLLOW_BLOCK_COMMENT_in_findComments72 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_LINE_COMMENT_in_findComments86 = new BitSet(new long[]{0x0000000000000002L});

}