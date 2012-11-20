import java.io.File;
import java.io.FilenameFilter;
import java.util.List;

import org.antlr.runtime.*;
import org.antlr.runtime.tree.*;

import cantlr.*;

public class MultiFile {
	private static int errorCount = 0;
	private static int fileCount = 0;
	private static int COMMENT_STATEMENT=33; //token type for comments

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
			//CommonTree temp = new CommonTree();
			System.out.println("Parsing "+dir.getName());
			CommonTree temp = processFile(dir.getPath());
			System.out.println("\nFinished parsing " + dir.getName());
			System.out.println(temp.toStringTree());
			return;
		}

		CommonTree root = new CommonTree(new CommonToken(-1, "RootDoc"));
		root = processDirectory(root, dir);

		System.out.println("The root tree of " + dir.getName() + " has "+root.getChildCount()+" child(ren) (packages)");
		System.out.println(fileCount + " files were processed.");
		System.out.println(errorCount + " errors were encountered.");
		System.out.println("\nThe tree:\n");
		System.out.println(root.toStringTree());
	}

	public static CommonTree runParser(String file) throws Exception {
		ANTLRFileStream input = new ANTLRFileStream(file);
		
		COMTORLexer lexer = new COMTORLexer(input);
		
		CommonTokenStream tokens = new CommonTokenStream(lexer);
		
		COMTORParser parser = new COMTORParser(tokens);
		
		try {
            COMTORParser.start_return result = parser.start();
			return (CommonTree)result.getTree();
		} catch (RecognitionException|RewriteEmptyStreamException e) {
            throw e;
        } /*catch (RewriteEmtpyExceptionStream r)*/
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

	public static CommonTree runCommentParser(String file) throws Exception {
		ANTLRFileStream input = new ANTLRFileStream(file);
		
		JavaCommentsLexer lexer = new JavaCommentsLexer(input);
		
		CommonTokenStream tokens = new CommonTokenStream(lexer);
		
		JavaCommentsParser parser = new JavaCommentsParser(tokens);
		
		try {
            JavaCommentsParser.start_return result = parser.start();
			return (CommonTree)result.getTree();
        } catch (Exception e) {
            throw new Exception();
        }
	}

	public static CommonTree addComments(CommonTree root, CommonTree comments) {
		// Returns modified root. (Java passes by value, so no side-effects.)

		CommonTree temp;
		CommonTree comm;
		// System.out.println("In add comments");
		// System.out.println("\t" + root.getText() + " " + root.getChildCount() + " " + root.getLine());
		// System.out.println("\t" + comments.getText() + " " + comments.getChildCount() + " " + comments.getLine());

		if (comments.getChildCount() > 0) {
			comm = (CommonTree)comments.getChild(0);

			if (comm.getLine() == 1) {
				root.addChild(getCommentChild(comm));
				comments.deleteChild(0);
			}

			for (int i = 0; i < root.getChildCount() && comments.getChildCount() > 0; i++) {
				temp = (CommonTree)root.getChild(i);
				comm = (CommonTree)comments.getChild(0);
				if (comm.getLine() <= temp.getLine()) {
					temp.addChild(getCommentChild(comm));
					comments.deleteChild(0);
				}
			}

			List ch = root.getChildren();
			if (ch != null) {
				for (int i = 0; i < ch.size(); i++) {
					addComments((CommonTree)ch.get(i), comments);
				}
			}
		}
		return root;
	}

	public static CommonTree processDirectory(CommonTree root, File dir) throws Exception {
		if (dir.isDirectory()) {
			String[] files = getJavaFiles(dir);
			CommonTree temp;// = new CommonTree();
			CommonTree comments;// = new CommonTree();
			CommonTree child;
			String packageName;


			for (int i = 0; i < files.length; i++) {
				packageName = "";

				//System.out.println(dir.getPath()+"\\"+files[i]);
				
				//Run the parser on the child file.
				try {
					temp = processFile(dir.getPath()+"\\"+files[i]);//runParser(dir.getPath()+"\\"+files[i]);
				} catch (RecognitionException e) {
					System.out.println("Error parsing " + files[i]+". File skipped.");
					System.out.println("\t"+e);
					errorCount++;
					continue;
				}

				// Mix comments into tree
				try {
					comments = runCommentParser(dir.getPath()+"\\"+files[i]);
				} catch (Exception e) {
					System.out.println("Error parsing comments in " + files[i] + ". Processing aborted.");
					errorCount++;
					continue;
				}
				temp = addComments(temp, comments);
				fileCount++;

				if (hasChild(root, temp.getText())) {
					for (int j = 0; j < root.getChildCount(); j++) {
						CommonTree c = (CommonTree)root.getChild(j);
						if (temp.getText().equals(c.getText())) {
							c.addChildren(temp.getChildren());
							break;
						}
					}
				} else {
					root.addChild(temp);
				}

				// if (hasChild(temp, "package")) {
				// 	// Generate package information
				// 	List treeChildren = temp.getChildren();
				// 	child = (CommonTree)treeChildren.get(1); //should be PACKAGE
				// 	treeChildren = child.getChildren();
				// 	if (treeChildren != null) {
				// 		for (int j = 0; j < treeChildren.size(); j++) {
				// 			child = (CommonTree)treeChildren.get(j);
				// 			packageName += child.getText();
				// 		}
				// 	}
			

				// 	//System.out.println("\tpackage: "+packageName);
				// 	//System.out.println("\tToken type: "+child.getType());
				// 	//System.out.println("\tLine number: "+ child.getLine());

				// 	// Add parsed file to root under the package name subtree
				// 	if (!hasChild(root, packageName)) {
				// 		CommonTree newChild = new CommonTree(new CommonToken(child.getType(), packageName));
				// 		root.addChild(newChild);
				// 		((CommonTree)(root.getChild(0))).addChild(temp);
				// 	} else {
				// 		List c = root.getChildren();
				// 		for (int j = 0; j < c.size(); j++) {
				// 			child = (CommonTree)c.get(j);
				// 			if (packageName.equals(child.getText())) {
				// 				child.addChild(temp);
				// 				break;
				// 			}
				// 		}
				// 	}
				// }
			}

			String[] subdirs = dir.list();
			for (int i=0; i < subdirs.length; i++) {
				root = processDirectory(root, new File(dir, subdirs[i]));
			}
		}
		return root;
	}

	public static CommonTree processFile(String file) throws Exception {
		CommonTree root = new CommonTree();
		try {
			root = runParser(file);
		} catch (Exception e) {
			System.out.println("Error parsing " + file + ". File skipped.");
			System.out.println(e.getMessage());
			e.printStackTrace();
			return null;
		}
		// Run comment parser on file
		CommonTree comments;
		try {
			comments = runCommentParser(file);
		} catch (Exception e) {
			System.out.println("Error parsing comments in " + file + ". Processing aborted.");

			return null;
		}
		// Mix in comments
		//root = addComments(root, comments);

		// Return tree.
		return root;
	}

	private static CommonTree getCommentChild(CommonTree comm) {
		CommonToken tempToken = new CommonToken(COMMENT_STATEMENT, "COMMENT_STATEMENT");
		tempToken.setLine(comm.getLine());
		CommonTree tempTree = new CommonTree(tempToken);
		tempTree.addChild(comm);
		return tempTree;
	}
}