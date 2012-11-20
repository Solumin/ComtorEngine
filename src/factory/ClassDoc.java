

import org.antlr.runtime.*;
import org.antlr.runtime.tree.*;
import java.util.List;

public class ClassDoc {
	private String name;
	//private List<MethodDoc> methods;
	//private List<ConstructorDoc> constructors;
	private List<FieldDoc> fields;

	public ClassDoc(CommonTree root) {
		List children = root.getChildren();

		this.name = root.getChild(0).getText();
		// CommonTree child;
		// for (int i = 0; i < children.size(); i++) {
		// 	child = (CommonTree)children.get(i);
			
		// }
	}

	public String name() {
		return this.name;
	}

	public String toString() {
		return this.name();
	}
}