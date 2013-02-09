import org.antlr.runtime.*;
import org.antlr.runtime.tree.*;
import java.util.ArrayList;

public class CRDriver {
	public static void main(String[] args) throws Exception {
		CommonTree cdr;
		try {
			cdr = ComtorRootTree.genRootTree("../../test/simple/Features.java");
		} catch (Exception e) {
			System.out.print("Couldn't run it! " + e);
			cdr = new CommonTree();
		}
		System.out.println(cdr.toStringTree());
		RootDoc rd = new RootDoc(cdr);

		if (rd.getClasses().isEmpty())
			System.out.println("The rootdoc is empty!");
		else {
			System.out.println("Classes in rootdoc:");
			ArrayList<ClassDoc> classes = rd.getClasses();
			for (ClassDoc c : classes) {
				System.out.println(c.getName());
			}
			System.out.println("Found " + rd.findClass("Features<Square, Circle>"));
		}
	}
}