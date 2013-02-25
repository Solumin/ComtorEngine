namespace :cantlr do
	dir = 'src/cantlr'
	#Collecet ANTLR files
	antlr = FileList["#{dir}/*.g"]
	#And the java files, too
	java = antlr.map do |g|
		[g.sub('.g', 'Parser.java'), g.sub('.g', 'Lexer.java')]
	end
	java.flatten!

	processed = []

	rule(/(Parser|Lexer)\.java$/ => [ proc { |j| j.sub(/(Parser|Lexer)\.java/, '.g') }]) do |t|
		source = t.source.split('/').last
		if processed.include? source
			return
		end
		cd dir
		sh "#{JAVA32} org.antlr.Tool #{source}"
		processed << source
		cd '../..'
	end
	rule 'Lexer.java'

	file "#{dir}/cantlr.jar" => java do
		cd dir
		sh "javac -cp .;../../lib/antlr-3.3.jar *.java"
		sh 'jar cf cantlr.jar *.class'
		cd '../..'
	end

	file "lib/cantlr.jar" => "#{dir}/cantlr.jar"

	task :install => ["lib/cantlr.jar"] do
		copy "#{dir}/cantlr.jar", 'lib/cantlr.jar'
	end

	desc "Installs (and builds if needed) cantlr.jar to lib/"
	task :default => [:install, :clean]
end