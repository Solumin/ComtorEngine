javac -cp .;../../lib/antlr-3.3.jar;../../lib/cantlr.jar *.java
jar cf ComtorDocs.jar *.class
del *.class
move ComtorDocs.jar ../../lib/ComtorDocs.jar