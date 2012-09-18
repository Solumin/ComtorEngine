import java.io.File;
import java.io.FilenameFilter;
import java.util.List;

import org.antlr.runtime.*;
import org.antlr.runtime.tree.*;

public class MultiFile {
	private static int errorCount = 0;

	private static FilenameFilter javaFilter = new FilenameFilter() { 
		public boolean accept(File dir, String name) {
			return name.endsWith(".java");
		}
	};

	private static FilenameFilter dirFilter = new FilenameFilter() {
		public boolean accept(File dir, String name) {
			return dir.isDirectory();
		}
	};

	public static void main(String[] args) throws Exception {
		File dir;

		try {
			dir = new File(args[0]);
		} catch (ArrayIndexOutOfBoundsException e) {
			System.out.println("The COMTOR parser must be called with a file or a directory as the first argument.");
			System.out.println("(No argument was given.)");
			return;
		}

		if (!dir.exists()) {
			System.out.println("The file or directory " + args[0] + " does not exist.");
			return;
		}

		if (dir.isFile()) {
			CommonTree temp = new CommonTree();
			System.out.println("Parsing "+dir.getName());
			temp = runParser(dir.getPath());
			return;
		}

		CommonTree root = new CommonTree();
		root = processDirectory(root, dir);
		
		System.out.println("The root tree of " + dir.getName() + " has "+root.getChildCount()+" child(ren) (packages)");
		System.out.println(errorCount + " errors were encountered.");
	}

	public static CommonTree runParser(String file) throws Exception {
		//ANTLRFileStream input = new ANTLRFileStream("E:\\My Documents\\ANTLR\\Comtor\\PercentageMethods.java", "UTF8");
		ANTLRFileStream input = new ANTLRFileStream(file);
		
		COMTORLexer lexer = new COMTORLexer(input);
		
		CommonTokenStream tokens = new CommonTokenStream(lexer);
		
		COMTORParser parser = new COMTORParser(tokens);
		
		try {
            COMTORParser.start_return result = parser.start();
			return (CommonTree)result.getTree();
        } catch (Exception e) {
            throw new Exception();
        }
	}

	public static String[] getJavaFiles(File dir) {
		return dir.list(javaFilter);
	}

	public static boolean hasChild(CommonTree tree, String text) {
		List children = tree.getChildren();
		if (children == null) return false;
		CommonTree child;
		for (int i = 0; i < children.size(); i++) {
			child = (CommonTree)children.get(i);
			if (text.equals(child.getText()))
				return true;
		}
		return false;
	}

	public static CommonTree processDirectory(CommonTree root, File dir) throws Exception {
		if (dir.isDirectory()) {
			String[] files = getJavaFiles(dir);
			CommonTree temp = new CommonTree();
			CommonTree child;
			String packageName;


			for (int i = 0; i < files.length; i++) {
				packageName = "";

				//System.out.println(files[i]);
				
				//Run the parser on the child file.
				try {
					temp = runParser(dir.getPath()+"\\"+files[i]);
				} catch (Exception e) {
					System.out.println("Error parsing " + files[i]+". File skipped.");
					errorCount++;
					continue;
				}

				List treeChildren = temp.getChildren();
				child = (CommonTree)treeChildren.get(1); //should be PACKAGE
				treeChildren = child.getChildren();

				for (int j = 0; j < treeChildren.size(); j++) {
					child = (CommonTree)treeChildren.get(j);
					packageName += child.getText();
				}

				//System.out.println("\tpackage: "+packageName);
				//System.out.println("\tToken type: "+child.getType());
				//System.out.println("\tLine number: "+ child.getLine());

				if (!hasChild(root, packageName)) {
					CommonTree newChild = new CommonTree(new CommonToken(child.getType(), packageName));
					root.addChild(newChild);
					((CommonTree)(root.getChild(0))).addChild(temp);
				} else {
					List c = root.getChildren();
					for (int j = 0; j < c.size(); j++) {
						child = (CommonTree)c.get(j);
						if (packageName.equals(child.getText())) {
							child.addChild(temp);
							break;
						}
					}
				}
			}

			String[] subdirs = dir.list();
			for (int i=0; i < subdirs.length; i++) {
				root = processDirectory(root, new File(dir, subdirs[i]));
			}
		}
		return root;
	}
}