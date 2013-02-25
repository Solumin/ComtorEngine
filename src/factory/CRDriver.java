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
			ClassDoc features = rd.findClass("Features<Square, Circle>");
			System.out.println("Found " + features);

			ArrayList<MethodDoc> methods = features.getMethods();
			for (MethodDoc m : methods) {
				System.out.println(m.getName() + ": " + m.getComment().getTags());
			}
		}
	}
}