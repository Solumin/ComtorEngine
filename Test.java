import org.antlr.runtime.*;
import org.antlr.runtime.tree.*;

public class Test {
	public static void main(String[] args) throws Exception {
		ANTLRFileStream input = new ANTLRFileStream("E:\\My Documents\\ANTLR\\Comtor\\PercentageMethods.java", "UTF8");
		
		COMTORLexer lexer = new COMTORLexer(input);
		
		CommonTokenStream tokens = new CommonTokenStream(lexer);
		
		COMTORParser parser = new COMTORParser(tokens);
		
		try {
            COMTORParser.start_return result = parser.start();
			CommonTree tree = (CommonTree)result.getTree();
			
        } catch (RecognitionException e) {
            e.printStackTrace();
        }
	}
}