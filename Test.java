import org.antlr.runtime.*;
import org.antlr.runtime.tree.*;

public class Test {
	public static void main(String[] args) throws Exception {
		// TODO
		//- Load a file from arguments
		//- File existence checks
		ANTLRFileStream input = new ANTLRFileStream("E:\\My Documents\\ANTLR\\Comtor\\PercentageMethods.java", "UTF8");
		
		COMTORLexer lexer = new COMTORLexer(input);
		
		CommonTokenStream tokens = new CommonTokenStream(lexer);
		
		COMTORParser parser = new COMTORParser(tokens);
		
		try {
            COMTORParser.start_return result = parser.start();
			Tree tree = (Tree)result.getTree();
			System.out.println("Obtained the AST from the parser.");

			if (tree.isNil())
				System.out.println("The tree is nil.");
			else
				System.out.println("The tree is not nil!");

			System.out.println("The tree has "+tree.getChildCount()+" children.");
        } catch (RecognitionException e) {
            e.printStackTrace();
        }
	}

	public static Tree runParser(String file) throws Exception {
		ANTLRFileStream input = new ANTLRFileStream("E:\\My Documents\\ANTLR\\Comtor\\PercentageMethods.java", "UTF8");
		
		COMTORLexer lexer = new COMTORLexer(input);
		
		CommonTokenStream tokens = new CommonTokenStream(lexer);
		
		COMTORParser parser = new COMTORParser(tokens);
		
		try {
            COMTORParser.start_return result = parser.start();
			return (Tree)result.getTree();
        } catch (RecognitionException e) {
            e.printStackTrace();
        }

        return null;
	}
}

private class Tester {
	;
}