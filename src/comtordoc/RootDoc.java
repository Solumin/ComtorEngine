import org.antlr.runtime.*;
import org.antlr.runtime.tree.*;
import java.util.List;
import java.util.ArrayList;

public class RootDoc {

	private ArrayList<ClassDoc> classes;

	/*
	Build a RootDoc from a parse tree.
	Extracts classes, packages and comments.
	*/
	public RootDoc(CommonTree root) {
		List pkgs = root.getChildren();
		this.classes = new ArrayList<ClassDoc>();

		System.out.print("There are " + pkgs.size()+ " packages in " + root.getText() +"\n");

		for (int i = 0; i < pkgs.size(); i++) {
			CommonTree pkg = (CommonTree)pkgs.get(i);

			List cls = pkg.getChildren();
			System.out.print(pkg.getText()+": "+cls.size()+" children\n");

			for (int j = 0; j < cls.size(); j++) {
				CommonTree cl = (CommonTree)cls.get(j);
				System.out.print("\t"+cl.getText()+"\n");
				if (cl.getText().equals("NORMAL_CLASS")) {
					CommonTree imps = (CommonTree)cls.get(j+1);
					this.classes.add(new ClassDoc(cl, imps));

				}
			}
		}
	}

	public ClassDoc[] classes() {
		return (ClassDoc[])this.classes.toArray();
	}

	public ClassDoc classNamed(String name) {
		for (ClassDoc c : classes) {
			if (c.name().equals(name))
				return c;
		}
		return null;
	}
}