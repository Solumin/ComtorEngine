require 'rake/clean'

#Configure the default Clean task to recurse 
CLEAN.include('src/*/*.class')
#Clobber cleans CLEAN + all these:
CLOBBER.include('*src/*/*.jar')
CLOBBER.include('src/cantlr/*.java')
CLOBBER.include('src/cantlr/*.tokens')

LIB = 'lib'
ANTLR = "#{LIB}/antlr-3.3.jar"
#We need a 32-bit Java VM in order to run Java from Ruby.
JAVA32 = "E:\\Programs\\Java\\jdk1.7.0_13\\bin\\java.exe"

desc "Run the cantlr Rakefile"
task :cantlr do
	Rake::Task["cantlr:default"].invoke
end

task :crdriver do
	puts "Error - crdriver task not implemented."
	#Rake::Task["crdriver:default"].invoke
end

import "./src/cantlr/Rakefrag.rb"
import "./src/factory/Rakefrag.rb"