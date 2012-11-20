import org.antlr.runtime.*;
import org.antlr.runtime.tree.*;

public class CRDriver {
	public static void main(String[] args) throws Exception {
		CommonTree cdr;
		try {
			cdr = ComtorRootTree.genRootTree("../../test/simple/comTest.java");
		} catch (Exception e) {
			System.out.print("Couldn't run it! " + e);
			cdr = new CommonTree();
		}
		System.out.println(cdr.toStringTree());
		RootDoc rd = new RootDoc(cdr);

		System.out.print("Found " + rd.classNamed("comTest"));
	}
}