javac -cp .;../../lib/antlr-3.3.jar;../../lib/cantlr.jar;../../lib/ComtorDocs.jar CRDriver.java
jar cfm CRDriver.jar META-INF.txt *.class
del *.class