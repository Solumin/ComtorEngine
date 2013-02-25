namespace :crdriver do
	file "CRDriver.java" do
		sh "javac -cp .;#{ANTLR};../../lib/cantlr.jar;../../lib/ComtorDocs.jar CRDriver.java"
		sh "jar cfm CRDriver.jar META-INF.txt *.class"
	end

	task :default do end
end