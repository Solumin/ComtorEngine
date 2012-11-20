javac -cp .;../../lib/antlr-3.3.jar *.java
jar cf cantlr.jar *.class
del *.class
move cantlr.jar ../../lib/cantlr.jar