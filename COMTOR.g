/*
 [The "BSD licence"]
 Copyright (c) 2007-2008 Terence Parr
 All rights reserved.

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions
 are met:
 1. Redistributions of source code must retain the above copyright
    notice, this list of conditions and the following disclaimer.
 2. Redistributions in binary form must reproduce the above copyright
    notice, this list of conditions and the following disclaimer in the
    documentation and/or other materials provided with the distribution.
 3. The name of the author may not be used to endorse or promote products
    derived from this software without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
 IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
 INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
 NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
 THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

/*
 * This file has been modified by Teddy Sudol (solumin@users.sourceforge.net),
 * using the file "java.g" by Yang Jian (yang.jiang.z@gmail.com).  See
 * http://openjdk.java.net/projects/compiler-grammar/antlrworks/Java.g or
 * http://antlr.org/grammar/list for the original file's documentation and
 * changelog. Java.g is intended to provide a standard Java-parsing grammar
 * for all projects.
 * 
 * The purpose of this file, unlike java.g, is to build a very descriptive AST 
 * of the input's components. The input is a compilable Java source code file. 
 * The output should be a tree that the COMTOR modules may use for analysis.
*/

grammar COMTOR;

options {
	output=AST;
	ASTLabelType=CommonTree; // type of $stat.tree, etc.
	backtrack=true;
	memoize=true;
}

//Imaginary tokens for tree building
tokens { UNIT; IMPORTS; NORMAL_CLASS; TYPE_PARAMS;
	ACCESS_MODIFIER; BODY; METHOD_DEC; PARAMS;
	EMPTY; TYPE; VAR_DEF; ARRAY;
	CONSTRUCTOR_CALL; ARGUMENTS; ANNOTATIONS;
	IF_STATEMENT; ELSE_STATEMENT; WHILE_BLOCK;
	DO_WHILE_BLOCK; SWITCH_STATEMENT;
	SYNCHRONIZED_BLOCK; RETURN_STATEMENT;
	LABEL; FOR_BLOCK; INIT; CAST; CONDITION;
	TRY_STATEMENT; INITIAL_VALUE; 
	COMMENT_STATEMENT; CONSTRUCTOR;
	//Used for methods/fields that have no modifier.
	PACKAGE_PRIVATE; INNER_CLASS;}

/********************************************************************************************
                          Parser section
*********************************************************************************************/

start	:	compilationUnit	;	//{System.out.println("Parsing complete.");} ;
//{System.out.println($compilationUnit.tree.toStringTree());}

compilationUnit 
    :   c=comments*
    	(   (annotations
            )?
            packageDeclaration
        )?
        (importDeclaration
        )*
        (typeDeclaration
        )* -> ^(UNIT $c? annotations? packageDeclaration? ^(IMPORTS importDeclaration+)?
        	typeDeclaration*)
    ;
    
packageDeclaration 
    :   'package' qualifiedName
        ';'
        -> ^('package' qualifiedName)
    ;

importDeclaration  
    :   comments*
    	'import' 
        ('static'
        )?
        (IDENTIFIER '.' '*')
        ';'    
        -> ^('import' 'static'? IDENTIFIER '.' '*') comments*
    |   comments*
    	'import' 
        ('static'
        )?
        i+=IDENTIFIER
        (i+='.' i+=IDENTIFIER
        )+
        (s+='.' s+='*'
        )?
        ';'
        -> ^('import' 'static'? $i+ $s*) comments*
    ;

qualifiedImportName 
    :   IDENTIFIER
        ('.' IDENTIFIER
        )*
    ;

typeDeclaration 
    :   classOrInterfaceDeclaration
    	-> classOrInterfaceDeclaration  
    |   ';' ->
    ;

classOrInterfaceDeclaration 
    :   comments* classDeclaration
    |   comments* interfaceDeclaration
    ;
    
  
modifiers  
    :
    (   'public'
    |   'protected'
    |   'private'
    |   'static'
    |   'abstract'
    |   'final'
    |   'native'
    |   'synchronized'
    |   'transient'
    |   'volatile'
    |   'strictfp'
    |	annotation
    )+
    ;


variableModifiers 
    :   (   'final'
        |   vm+=annotation
        )*
        -> 'final'* $vm?
    ;


typeParameters 
    :   '<'
            typeParameter
            (',' typeParameter
            )*
        '>'
        -> typeParameter+
    ;
classDeclaration 
    :   normalClassDeclaration
    |   enumDeclaration
    ;


normalClassDeclaration 
    :   modifiers?  'class' IDENTIFIER
        (typeParameters
        )?
        ('extends' type
        )?
        ('implements' typeList
        )?            
        classBody
        -> ^(NORMAL_CLASS IDENTIFIER 
        	^(ACCESS_MODIFIER modifiers)? ^(TYPE_PARAMS typeParameters)? ^('extends' type)? ^('implements' typeList)? 
        	^(BODY classBody)?)
    ;



typeParameter 
    :   IDENTIFIER
        ('extends' typeBound
        )?
        -> ^(IDENTIFIER ^('extends' typeBound))
    ;


typeBound 
    :   type
        ('&' type
        )*
    ;


enumDeclaration 
    :   modifiers 
        ('enum'
        ) 
        IDENTIFIER
        ('implements' typeList
        )?
        enumBody
        -> ^('enum' IDENTIFIER ^(ACCESS_MODIFIER modifiers) ^('implements' typeList) ^(BODY enumBody))
    ;
    

enumBody 
    :   '{'
    	comments?
        (enumConstants
        )? 
        comments?
        ','? 
        (enumBodyDeclarations
        )? 
        '}'
        -> comments* enumConstants? enumBodyDeclarations?
    ;

enumConstants 
    :   enumConstant
        (',' enumConstant
        )*
    ;

/**
 * NOTE: here differs from the javac grammar, missing TypeArguments.
 * EnumeratorDeclaration = AnnotationsOpt [TypeArguments] IDENTIFIER [ Arguments ] [ "{" ClassBody "}" ]
 */
enumConstant 
    :   (annotations
        )?
        IDENTIFIER
        (arguments
        )?
        (classBody
        )?
        -> IDENTIFIER annotations? arguments? ^(BODY classBody)?
        /* TODO: $GScope::name = names.empty. enum constant body is actually
        an anonymous class, where constructor isn't allowed, have to add this check*/
    ;

enumBodyDeclarations 
    :   ';' 
        (classBodyDeclaration
        )*
        -> ^(BODY classBodyDeclaration)?
    ;

interfaceDeclaration 
    :   normalInterfaceDeclaration
    |   annotationTypeDeclaration
    ;
    
normalInterfaceDeclaration 
    :   modifiers 'interface' IDENTIFIER
        (typeParameters
        )?
        ('extends' typeList
        )?
        interfaceBody
        -> ^(INTERFACE IDENTIFIER ^(ACCESS_MODIFIER modifiers) ^(TYPE_PARAMS typeParameters)? ^('extends' typeList)? ^(BODY interfaceBody))
    ;

typeList 
    :   type
        (',' type
        )*
    ;

classBody 
    :   '{' 
        (classBodyDeclaration
        )* 
        '}'
        -> classBodyDeclaration*
    ;

interfaceBody 
    :   '{' 
        (interfaceBodyDeclaration
        )* 
        '}'
        -> interfaceBodyDeclaration*
    ;

classBodyDeclaration 
    :   ';'
    |   ('static'
        )? 
        block
        -> 'static'? block
    |   memberDecl
    ;
    
memberDecl 
    :    fieldDeclaration
    |    methodDeclaration
    |    classDeclaration
    |    interfaceDeclaration
    |	 comments
<<<<<<< HEAD
    |	 innerClassOrInterfaceDeclaration //inner class!
    ;

innerClassOrInterfaceDeclaration
    :   comments* classDeclaration -> INNER_CLASS ^(COMMENT comments*) classDeclaration
    |   comments* interfaceDeclaration -> INNER_CLASS ^(COMMENT comments*) interfaceDeclaration
    ;
=======
    //|	 innerClassOrInterfaceDeclaration //inner class!
    ;

//innerClassOrInterfaceDeclaration
//    :   comments* classDeclaration -> INNER_CLASS ^(COMMENT comments*) classDeclaration
//    |   comments* interfaceDeclaration -> INNER_CLASS ^(COMMENT comments*) //interfaceDeclaration
//    ;
>>>>>>> Safe point. Committing for sanity.

methodDeclaration 
    :
        /* For constructor, return type is null, name is 'init' */
         modifiers?
        (typeParameters
        )?
        IDENTIFIER
        formalParameters
        ('throws' qualifiedNameList
        )?
        '{' 
        (explicitConstructorInvocation
        )?
        (blockStatement
        )*
        '}'
        -> ^(CONSTRUCTOR IDENTIFIER ^(ACCESS_MODIFIER modifiers)? ^(PARAMS formalParameters)? ^(TYPE_PARAMS typeParameters)?
        	^(THROWS qualifiedNameList)? ^(BODY explicitConstructorInvocation? blockStatement*))
    | //no modifiers
    	(typeParameters)?
    	(t=type
    	|   v='void'
        )
        IDENTIFIER
        formalParameters
        ('[' ']'
        )*
        ('throws' qualifiedNameList
        )?            
        (        
            block
        |   ';' 
        )
        -> ^(METHOD_DEC IDENTIFIER ^(ACCESS_MODIFIER PACKAGE_PRIVATE) ^(TYPE $t? $v?) ^(PARAMS formalParameters)? ^(TYPE_PARAMS typeParameters)?
        	^(THROWS qualifiedNameList)? ^(BODY block? (';')?) )
    |   modifiers
        (typeParameters
        )?
        (t=type
        |   v='void'
        )
        IDENTIFIER
        formalParameters
        ('[' ']'
        )*
        ('throws' qualifiedNameList
        )?            
        (        
            block
        |   ';' 
        )
        -> ^(METHOD_DEC IDENTIFIER ^(ACCESS_MODIFIER modifiers)? ^(TYPE $t? $v?) ^(PARAMS formalParameters)? ^(TYPE_PARAMS typeParameters)?
        	^(THROWS qualifiedNameList)? ^(BODY block? (';')?) )

    ;

fieldDeclaration 
    :   modifiers*
        type
        variableDeclarator
        (',' variableDeclarator
        )*
        ';'
        -> ^(VAR_DEF variableDeclarator+ ^(ACCESS_MODIFIER modifiers)? ^(TYPE type))
    ;

variableDeclarator 
    :   IDENTIFIER
        (b+='[' b+=']'
        )*
        ('=' variableInitializer 
        )?
        -> IDENTIFIER ^(INITIAL_VALUE variableInitializer)? ^(ARRAY $b*)?
<<<<<<< HEAD
    |   j=IDENTIFIER '.' i=IDENTIFIER
        (b+='[' b+=']'
        )*
        ('=' variableInitializer 
        )?
        -> $i ^(CLASS $j) ^(INITIAL_VALUE variableInitializer)? ^(ARRAY $b*)?
=======
//    |   j=IDENTIFIER '.' i=IDENTIFIER
//        (b+='[' b+=']'
//        )*
//        ('=' variableInitializer 
//        )?
//        -> $i ^(CLASS $j) ^(INITIAL_VALUE variableInitializer)? ^(ARRAY $b*)?
>>>>>>> Safe point. Committing for sanity.
    ;

/**
 *TODO: add predicates
 */
interfaceBodyDeclaration 
    :
        interfaceFieldDeclaration
    |   interfaceMethodDeclaration
    |   interfaceDeclaration
    |   classDeclaration
    |	comments
    |   ';'
    ;

interfaceMethodDeclaration 
    :   modifiers?
        (typeParameters
        )?
        (t=type
        |v='void'
        )
        IDENTIFIER
        formalParameters
        ('[' ']'
        )*
        ('throws' qualifiedNameList
        )? ';'
        -> ^(METHOD_DEC IDENTIFIER ^(ACCESS_MODIFIER modifiers)? ^(TYPE_PARAMS typeParameters)? ^(TYPE $t? $v?) ^(PARAMS formalParameters)?
        	^(THROWS qualifiedNameList)?)
    ;

/**
 * NOTE, should not use variableDeclarator here, as it doesn't necessary require
 * an initializer, while an interface field does, or judge by the returned value.
 * But this gives better diagnostic message, or antlr won't predict this rule.
 */
interfaceFieldDeclaration 
    :   modifiers type variableDeclarator
        (',' variableDeclarator
        )*
        ';'
        -> ^(VAR_DEF modifiers type variableDeclarator)+
    ;


type 
    :   classOrInterfaceType
        (b+='[' b+=']'
        )*
        -> classOrInterfaceType ^(ARRAY $b*)?
    |   primitiveType
        (b+='[' b+=']'
        )*
        -> primitiveType ^(ARRAY $b*)?
    ;


classOrInterfaceType 
    :   IDENTIFIER
        (typeArguments
        )?
        ('.' IDENTIFIER
            (typeArguments
            )?
        )*
    ;

primitiveType  
    :   'boolean'
    |   'char'
    |   'byte'
    |   'short'
    |   'int'
    |   'long'
    |   'float'
    |   'double'
    ;

typeArguments 
    :   '<' typeArgument
        (',' typeArgument
        )* 
        '>'
        -> typeArgument*
    ;

typeArgument 
    :   type
    |   '?'
        (
            (e='extends'
            |s='super'
            )
            type
        )?
        -> $e? $s? type
    ;

qualifiedNameList 
    :   qualifiedName
        (',' qualifiedName
        )*
        -> qualifiedName+
    ;

formalParameters 
    :   '('
        (formalParameterDecls
        )? 
        ')'
        -> formalParameterDecls?
    ;

formalParameterDecls 
    :   ellipsisParameterDecl
    |   n+=normalParameterDecl
        (',' n+=normalParameterDecl
        )*
        -> $n
    |   (n+=normalParameterDecl
        ','
        )+ 
        ellipsisParameterDecl
        -> $n ellipsisParameterDecl
    ;

normalParameterDecl 
    :   variableModifiers type IDENTIFIER
        (b+='[' b+=']'
        )*
        -> IDENTIFIER ^(ACCESS_MODIFIER variableModifiers)? ^(TYPE type ^(ARRAY $b*)?)
    ;

ellipsisParameterDecl 
    :   variableModifiers
        type  '...'
        IDENTIFIER
        -> IDENTIFIER ^(ACCESS_MODIFIER variableModifiers) ^(TYPE type)
    ;


qualifiedName 
    :   IDENTIFIER
        ('.' IDENTIFIER
        )*
        -> IDENTIFIER ('.' IDENTIFIER)*
    ;
explicitConstructorInvocation 
    :   (nonWildcardTypeArguments
        )?     //NOTE: the position of Identifier 'super' is set to the type args position here
        (t='this'
        |s='super'
        )
        arguments ';'
        -> ^(CONSTRUCTOR_CALL $s? $t? ^(ARGUMENTS arguments) nonWildcardTypeArguments?)
    |   primary
        '.'
        (nonWildcardTypeArguments
        )?
        'super'
        arguments ';'
        -> ^(CONSTRUCTOR_CALL 'super' primary ^(ARGUMENTS arguments) nonWildcardTypeArguments?)
    ;
    
annotations 
    :   (annotation
        )+
        -> ^(ANNOTATIONS annotation*)
    ;

/**
 *  Using an annotation. 
 * '@' is flaged in modifier
 */
annotation 
    :   '@' qualifiedName
        (   '('   
                  (   elementValuePairs
                  |   elementValue
                  )? 
            ')' 
        )?
        -> ^(qualifiedName elementValuePairs? elementValue?)
    ;

elementValuePairs 
    :   elementValuePair
        (',' elementValuePair
        )*
        -> ^(elementValuePair)+
    ;

elementValuePair 
    :   IDENTIFIER '=' elementValue
    ->	IDENTIFIER elementValue
    ;

elementValue 
    :   conditionalExpression
    |   annotation
    |   elementValueArrayInitializer
    ;

elementValueArrayInitializer 
    :   '{'
        (elementValue
            (',' elementValue
            )*
        )? (',')? '}'
        -> elementValue+
    ;


/**
 * Annotation declaration.
*/
annotationTypeDeclaration 
    :   modifiers '@'
        'interface'
        IDENTIFIER
        annotationTypeBody
    ;
 

annotationTypeBody 
    :   '{' 
        (annotationTypeElementDeclaration
        )* 
        '}'
        -> annotationTypeElementDeclaration*
    ;

/**
 * NOTE: here use interfaceFieldDeclaration for field declared inside annotation. they are sytactically the same.
 */
annotationTypeElementDeclaration 
    :   annotationMethodDeclaration
    |   interfaceFieldDeclaration
    |   normalClassDeclaration
    |   normalInterfaceDeclaration
    |   enumDeclaration
    |   annotationTypeDeclaration
    |   ';' ->
    ;

annotationMethodDeclaration 
    :   modifiers type IDENTIFIER
        '(' ')' ('default' elementValue
                )?
        ';'
        -> IDENTIFIER ^(ACCESS_MODIFIER modifiers) ^(TYPE type) ^('default' elementValue)?
        ;

block 
    :   '{'
        (blockStatement
        )*
        '}'
        -> blockStatement*
    ;

/*
staticBlock returns [JCBlock tree]
        @init {
            ListBuffer<JCStatement> stats = new ListBuffer<JCStatement>();
            int pos = ((AntlrJavacToken) $start).getStartIndex();
        }
        @after {
            $tree = T.at(pos).Block(Flags.STATIC, stats.toList());
            pu.storeEnd($tree, $stop);
            // construct a dummy static modifiers for end position
            pu.storeEnd(T.at(pos).Modifiers(Flags.STATIC,  com.sun.tools.javac.util.List.<JCAnnotation>nil()),$st);
        }
    :   st_1='static' '{' 
        (blockStatement
            {
                if ($blockStatement.tree == null) {
                    stats.appendList($blockStatement.list);
                } else {
                    stats.append($blockStatement.tree);
                }
            }
        )* '}'
    ;
*/

blockStatement 
    :   localVariableDeclarationStatement
    |   classOrInterfaceDeclaration
    |   statement
    |	comments
    ;


localVariableDeclarationStatement 
    :   localVariableDeclaration
        ';'
        -> localVariableDeclaration
    ;

localVariableDeclaration 
    :   variableModifiers type
        variableDeclarator
        (',' variableDeclarator
        )*
        -> ^(VAR_DEF variableDeclarator ^(ACCESS_MODIFIER variableModifiers)? ^(TYPE type))+
    ;

statement 
    :   block
            
    |   ('assert'
        )
        expression (':' expression)? ';'
        -> ^(ASSERT expression+)
    |   'assert'  expression (':' expression)? ';'
    	-> ^(ASSERT expression+)    
    |   'if' parExpression statement ('else' el=statement)?
    	-> ^(IF_STATEMENT ^(CONDITION parExpression) ^(BODY statement) ^(ELSE_STATEMENT ^(BODY $el))?)        
    |   forstatement
    |   'while' parExpression statement
    	-> ^(WHILE_BLOCK ^(CONDITION parExpression) ^(BODY statement))
    |   'do' statement 'while' parExpression ';'
    	-> ^(DO_WHILE_BLOCK ^(CONDITION parExpression) ^(BODY statement))
    |   trystatement
    	-> trystatement
    |   'switch' parExpression '{' switchBlockStatementGroups '}'
    	-> ^(SWITCH_STATEMENT ^(CONDITION parExpression) ^(BODY switchBlockStatementGroups))
    |   'synchronized' parExpression block
    	-> ^(SYNCHRONIZED_BLOCK parExpression ^(BODY block) )
    |   'return' (expression )? ';'
    	-> ^(RETURN_STATEMENT expression?)
    |   'throw' expression ';'
    	-> ^(THROWS expression)
    |   'break'
            (IDENTIFIER
            )? ';'
        -> ^('break' IDENTIFIER?)
    |   'continue'
            (IDENTIFIER
            )? ';'
        -> ^('continue' IDENTIFIER?)
    |   expression  ';' -> expression    
    |   IDENTIFIER ':' statement
    	-> ^(statement ^(LABEL IDENTIFIER))
    |   ';' ->
    |	comments
    ;


switchBlockStatementGroups 
    :   (switchBlockStatementGroup )*
    ;

switchBlockStatementGroup 
    :
        switchLabel
        (blockStatement
        )*
    ;

switchLabel 
    :   'case' expression ';'
    |   'default' ';'
    ;


trystatement 
    :   'try' block comments*
        (   c=catches f='finally' b=block
        |   c=catches
        |   f='finally' b=block
        )
        -> ^(TRY_STATEMENT ^(BODY block) comments* ^(CATCH $c? $f? ^(BODY $b)?))
     ;

catches 
    :   catchClause
        (catchClause
        )*
    ;

catchClause 
    :   'catch' '(' formalParameter
        ')' block?
        -> 'catch' ^(PARAMS formalParameter) ^(BODY block)?
    ;

formalParameter 
    :   variableModifiers type IDENTIFIER
        (b+='[' b+=']'
        )*
        -> ^(VAR_DEF IDENTIFIER ^(ACCESS_MODIFIER variableModifiers)? ^(TYPE type ^(ARRAY $b*)?))
    ;

forstatement 
    :   
        // enhanced for loop
        'for' '(' variableModifiers? type IDENTIFIER ':' 
        expression ')' statement
        -> ^(FOR_BLOCK ^(INIT IDENTIFIER ^(ACCESS_MODIFIER variableModifiers)? ^(TYPE type) expression) ^(BODY statement))
        // normal for loop
    |   'for' '(' 
                (forInit
                )? ';' 
                (expression
                )? ';' 
                (expressionList
                )? ')' statement
        -> ^(FOR_BLOCK forInit? expression? expressionList? ^(BODY statement))
    ;

forInit 
    :   localVariableDeclaration
    |   expressionList
    ;

parExpression 
    :   '(' expression ')'
    	-> expression
    ;

expressionList 
    :   expression
        (',' expression
        )*
        -> expression+
    ;


expression 
    :   conditionalExpression
        (assignmentOperator expression
        )?
    ;


assignmentOperator 
    :   '='
    |   '+='
    |   '-='
    |   '*='
    |   '/='
    |   '&='
    |   '|='
    |   '^='
    |   '%='
    |    '<' '<' '='
    |    '>' '>' '>' '='
    |    '>' '>' '='
    ;


conditionalExpression 
    :   conditionalOrExpression
        ('?' expression ':' conditionalExpression
        )?
    ;

conditionalOrExpression 
    :   conditionalAndExpression
        ('||' conditionalAndExpression
        )*
    ;

conditionalAndExpression 
    :   inclusiveOrExpression
        ('&&' inclusiveOrExpression
        )*
    ;

inclusiveOrExpression 
    :   exclusiveOrExpression
        ('|' exclusiveOrExpression
        )*
    ;

exclusiveOrExpression 
    :   andExpression
        ('^' andExpression
        )*
    ;

andExpression 
    :   equalityExpression
        ('&' equalityExpression
        )*
    ;

equalityExpression 
    :   instanceOfExpression
        (   
            (   '=='
            |   '!='
            )
            instanceOfExpression
        )*
    ;

instanceOfExpression 
    :   relationalExpression
        ('instanceof' type
        )?
    ;

relationalExpression 
    :   shiftExpression
        (relationalOp shiftExpression
        )*
    ;

relationalOp 
    :    '<' '='
    |    '>' '='
    |   '<'
    |   '>'
    ;

shiftExpression 
    :   additiveExpression
        (shiftOp additiveExpression
        )*
    ;


shiftOp 
    :    '<' '<'
    |    '>' '>' '>'
    |    '>' '>'
    ;


additiveExpression 
    :   multiplicativeExpression
        (   
            (   '+'
            |   '-'
            )
            multiplicativeExpression
         )*
    ;

multiplicativeExpression 
    :
        unaryExpression
        (   
            (   '*'
            |   '/'
            |   '%'
            )
            unaryExpression
        )*
    ;

/**
 * NOTE: for '+' and '-', if the next token is int or long interal, then it's not a unary expression.
 *       it's a literal with signed value. INTLTERAL AND LONG LITERAL are added here for this.
 */
unaryExpression 
    :   '+'  unaryExpression
    |   '-' unaryExpression
    |   '++' unaryExpression
    |   '--' unaryExpression
    |   unaryExpressionNotPlusMinus
    ;

unaryExpressionNotPlusMinus 
    :   '~' unaryExpression
    |   '!' unaryExpression
    |   castExpression
    |   primary
        (selector
        )*
        (   '++'
        |   '--'
        )?
    ;

castExpression 
    :   '(' primitiveType ')' unaryExpression
    	-> unaryExpression ^(CAST primitiveType)
    |   '(' type ')' unaryExpressionNotPlusMinus
    	-> unaryExpressionNotPlusMinus ^(CAST type)
    ;

/**
 * have to use scope here, parameter passing isn't well supported in antlr.
 */
primary 
    :   parExpression            
    |   'this'
        ('.' IDENTIFIER
        )*
        (identifierSuffix
        )?
    |   IDENTIFIER
        ('.' IDENTIFIER
        )*
        (identifierSuffix
        )?
    |   'super'
        superSuffix
    |   literal
    |   creator
    |   primitiveType
        (b+='[' b+=']'
        )*
        '.' 'class'
        -> primitiveType '.' 'class' ^(ARRAY $b*)?
    |   'void' '.' 'class'
    ;
    

superSuffix  
    :   arguments
    |   '.' (typeArguments
        )?
        IDENTIFIER
        (arguments
        )?
        -> IDENTIFIER typeArguments? arguments?
    ;


identifierSuffix 
    :   ('[' ']'
        )+
        '.' 'class'
    |   ('[' expression ']'
        )+
    |   arguments
    |   '.' 'class'
    |   '.' nonWildcardTypeArguments IDENTIFIER arguments
    |   '.' 'this'
    |   '.' 'super' arguments
    |   innerCreator
    ;


selector  
    :   '.' IDENTIFIER
        (arguments
        )?
    |   '.' 'this'
    |   '.' 'super'
        superSuffix
    |   innerCreator
    |   '[' expression ']'
    ;
//STOPPED
creator 
    :   'new' nonWildcardTypeArguments classOrInterfaceType classCreatorRest
    |   'new' classOrInterfaceType classCreatorRest
    |   arrayCreator
    ;

arrayCreator 
    :   'new' createdName
        '[' ']'
        ('[' ']'
        )*
        arrayInitializer

    |   'new' createdName
        '[' expression
        ']'
        (   '[' expression
            ']'
        )*
        ('[' ']'
        )*
    ;

variableInitializer 
    :   arrayInitializer comments? -> arrayInitializer ^(COMMENT comments)?
    |   expression comments? -> expression ^(COMMENT comments)?
    |   comments -> ^(COMMENT comments)
    ;

arrayInitializer 
    :   '{' 
            (v+=variableInitializer
                (',' c+=comments? v+=variableInitializer
                )*
            )? 
            (',')? 
        '}'             //Yang's fix, position change.
         -> $v? ^(COMMENT $c)?
    ;


createdName 
    :   classOrInterfaceType
    |   primitiveType
    ;

innerCreator  
    :   '.' 'new'
        (nonWildcardTypeArguments
        )?
        IDENTIFIER
        (typeArguments
        )?
        classCreatorRest
    ;


classCreatorRest 
    :   arguments
        (classBody
        )?
    ;


nonWildcardTypeArguments 
    :   '<' typeList
        '>'
    ;

arguments 
    :   '(' (expressionList
        )? ')'
    ;

literal 
    :   INTLITERAL
    |   LONGLITERAL
    |   FLOATLITERAL
    |   DOUBLELITERAL
    |   CHARLITERAL
    |   STRINGLITERAL
    |   TRUE
    |   FALSE
    |   NULL
    ;

/**
 * These are headers help to make syntatical predicates, not necessary but helps to make grammar faster.
 */
 
classHeader 
    :   modifiers 'class' IDENTIFIER
    ;

enumHeader 
    :   modifiers ('enum'|IDENTIFIER) IDENTIFIER
    ;

interfaceHeader 
    :   modifiers 'interface' IDENTIFIER
    ;

annotationHeader 
    :   modifiers '@' 'interface' IDENTIFIER
    ;

typeHeader 
    :   modifiers ('class'|'enum'|('@' ? 'interface')) IDENTIFIER
    ;

methodHeader 
    :   modifiers typeParameters? (type|'void')? IDENTIFIER '('
    ;

fieldHeader 
    :   modifiers type IDENTIFIER ('['']')* ('='|','|';')
    ;

localVariableHeader 
    :   variableModifiers type IDENTIFIER ('['']')* ('='|','|';')
    ;

comments
    :   COMMENT -> ^(COMMENT_STATEMENT COMMENT)
    |   LINE_COMMENT -> ^(COMMENT_STATEMENT LINE_COMMENT)
    ;


/********************************************************************************************
                  Lexer section
*********************************************************************************************/

LONGLITERAL
    :   IntegerNumber LongSuffix
    ;

    
INTLITERAL
    :   IntegerNumber 
    ;
    
fragment
IntegerNumber
    :   '0' 
    |   '1'..'9' ('0'..'9')*    
    |   '0' ('0'..'7')+         
    |   HexPrefix HexDigit+        
    ;

fragment
HexPrefix
    :   '0x' | '0X'
    ;
        
fragment
HexDigit
    :   ('0'..'9'|'a'..'f'|'A'..'F')
    ;

fragment
LongSuffix
    :   'l' | 'L'
    ;


fragment
NonIntegerNumber
    :   ('0' .. '9')+ '.' ('0' .. '9')* Exponent?  
    |   '.' ( '0' .. '9' )+ Exponent?  
    |   ('0' .. '9')+ Exponent  
    |   ('0' .. '9')+ 
    |   
        HexPrefix (HexDigit )* 
        (    () 
        |    ('.' (HexDigit )* ) 
        ) 
        ( 'p' | 'P' ) 
        ( '+' | '-' )? 
        ( '0' .. '9' )+
        ;
        
fragment 
Exponent    
    :   ( 'e' | 'E' ) ( '+' | '-' )? ( '0' .. '9' )+ 
    ;
    
fragment 
FloatSuffix
    :   'f' | 'F' 
    ;     

fragment
DoubleSuffix
    :   'd' | 'D'
    ;
        
FLOATLITERAL
    :   NonIntegerNumber FloatSuffix
    ;
    
DOUBLELITERAL
    :   NonIntegerNumber DoubleSuffix?
    ;

CHARLITERAL
    :   '\'' 
        (   EscapeSequence 
        |   ~( '\'' | '\\' | '\r' | '\n' )
        ) 
        '\''
    ; 

STRINGLITERAL
    :   '"' 
        (   EscapeSequence
        |   ~( '\\' | '"' | '\r' | '\n' )        
        )* 
        '"' 
    ;

fragment
EscapeSequence 
    :   '\\' (
                 'b' 
             |   't' 
             |   'n' 
             |   'f' 
             |   'r' 
             |   '\"' 
             |   '\'' 
             |   '\\' 
             |       
                 ('0'..'3') ('0'..'7') ('0'..'7')
             |       
                 ('0'..'7') ('0'..'7') 
             |       
                 ('0'..'7')
             )          
;     

WS  
    :   (
             ' '
        |    '\r'
        |    '\t'
        |    '\u000C'
        |    '\n'
        ) 
            {
                skip();
            }          
    ;
    
COMMENT
//         @init{
//           boolean isJavaDoc = false;
//        }
    :   '/*'
//            {
 //               if((char)input.LA(1) == '*'){
 //                   isJavaDoc = true;
 //              }
//            }
        (options {greedy=false;} : . )* 
        '*/'
           // {
//                if(isJavaDoc==true){
     //               $channel=HIDDEN;
//                }else{
                    //skip();
//                }
            //}
    ;

LINE_COMMENT
    :   '//' c=(~('\n'|'\r')*)  ('\r\n' | '\r' | '\n') 
           {
              // skip();
          }
    |   '//' ~('\n'|'\r')*     // a line comment could appear at the end of the file without CR/LF
           {
             // skip();
          }
    ;   

ABSTRACT
    :   'abstract'
    ;
    
ASSERT
    :   'assert'
    ;
    
BOOLEAN
    :   'boolean'
    ;
    
BREAK
    :   'break'
    ;
    
BYTE
    :   'byte'
    ;
    
CASE
    :   'case'
    ;
    
CATCH
    :   'catch'
    ;
    
CHAR
    :   'char'
    ;
    
CLASS
    :   'class'
    ;
    
CONST
    :   'const'
    ;

CONTINUE
    :   'continue'
    ;

DEFAULT
    :   'default'
    ;

DO
    :   'do'
    ;

DOUBLE
    :   'double'
    ;

ELSE
    :   'else'
    ;

ENUM
    :   'enum'
    ;             

EXTENDS
    :   'extends'
    ;

FINAL
    :   'final'
    ;

FINALLY
    :   'finally'
    ;

FLOAT
    :   'float'
    ;

FOR
    :   'for'
    ;

GOTO
    :   'goto'
    ;

IF
    :   'if'
    ;

IMPLEMENTS
    :   'implements'
    ;

IMPORT
    :   'import'
    ;

INSTANCEOF
    :   'instanceof'
    ;

INT
    :   'int'
    ;

INTERFACE
    :   'interface'
    ;

LONG
    :   'long'
    ;

NATIVE
    :   'native'
    ;

NEW
    :   'new'
    ;

PACKAGE
    :   'package'
    ;

PRIVATE
    :   'private'
    ;

PROTECTED
    :   'protected'
    ;

PUBLIC
    :   'public'
    ;

RETURN
    :   'return'
    ;

SHORT
    :   'short'
    ;

STATIC
    :   'static'
    ;

STRICTFP
    :   'strictfp'
    ;

SUPER
    :   'super'
    ;

SWITCH
    :   'switch'
    ;

SYNCHRONIZED
    :   'synchronized'
    ;

THIS
    :   'this'
    ;

THROW
    :   'throw'
    ;

THROWS
    :   'throws'
    ;

TRANSIENT
    :   'transient'
    ;

TRY
    :   'try'
    ;

VOID
    :   'void'
    ;

VOLATILE
    :   'volatile'
    ;

WHILE
    :   'while'
    ;

TRUE
    :   'true'
    ;

FALSE
    :   'false'
    ;

NULL
    :   'null'
    ;

LPAREN
    :   '('
    ;

RPAREN
    :   ')'
    ;

LBRACE
    :   '{'
    ;

RBRACE
    :   '}'
    ;

LBRACKET
    :   '['
    ;

RBRACKET
    :   ']'
    ;

SEMI //Do not include semicolons in the tree
    :   ';'
    ;

COMMA
    :   ','
    ;

DOT
    :   '.'
    ;

ELLIPSIS
    :   '...'
    ;

EQ
    :   '='
    ;

BANG
    :   '!'
    ;

TILDE
    :   '~'
    ;

QUES
    :   '?'
    ;

COLON
    :   ':'
    ;

EQEQ
    :   '=='
    ;

AMPAMP
    :   '&&'
    ;

BARBAR
    :   '||'
    ;

PLUSPLUS
    :   '++'
    ;

SUBSUB
    :   '--'
    ;

PLUS
    :   '+'
    ;

SUB
    :   '-'
    ;

STAR
    :   '*'
    ;

SLASH
    :   '/'
    ;

AMP
    :   '&'
    ;

BAR
    :   '|'
    ;

CARET
    :   '^'
    ;

PERCENT
    :   '%'
    ;

PLUSEQ
    :   '+='
    ; 
    
SUBEQ
    :   '-='
    ;

STAREQ
    :   '*='
    ;

SLASHEQ
    :   '/='
    ;

AMPEQ
    :   '&='
    ;

BAREQ
    :   '|='
    ;

CARETEQ
    :   '^='
    ;

PERCENTEQ
    :   '%='
    ;

MONKEYS_AT
    :   '@'
    ;

BANGEQ
    :   '!='
    ;

GT
    :   '>'
    ;

LT
    :   '<'
    ;        
              
IDENTIFIER
    :   IdentifierStart IdentifierPart*
    ;

fragment
SurrogateIdentifer 
    :   ('\ud800'..'\udbff') ('\udc00'..'\udfff') 
    ;                 

fragment
IdentifierStart
    :   '\u0024'
    |   '\u0041'..'\u005a'
    |   '\u005f'
    |   '\u0061'..'\u007a'
    |   '\u00a2'..'\u00a5'
    |   '\u00aa'
    |   '\u00b5'
    |   '\u00ba'
    |   '\u00c0'..'\u00d6'
    |   '\u00d8'..'\u00f6'
    |   '\u00f8'..'\u0236'
    |   '\u0250'..'\u02c1'
    |   '\u02c6'..'\u02d1'
    |   '\u02e0'..'\u02e4'
    |   '\u02ee'
    |   '\u037a'
    |   '\u0386'
    |   '\u0388'..'\u038a'
    |   '\u038c'
    |   '\u038e'..'\u03a1'
    |   '\u03a3'..'\u03ce'
    |   '\u03d0'..'\u03f5'
    |   '\u03f7'..'\u03fb'
    |   '\u0400'..'\u0481'
    |   '\u048a'..'\u04ce'
    |   '\u04d0'..'\u04f5'
    |   '\u04f8'..'\u04f9'
    |   '\u0500'..'\u050f'
    |   '\u0531'..'\u0556'
    |   '\u0559'
    |   '\u0561'..'\u0587'
    |   '\u05d0'..'\u05ea'
    |   '\u05f0'..'\u05f2'
    |   '\u0621'..'\u063a'
    |   '\u0640'..'\u064a'
    |   '\u066e'..'\u066f'
    |   '\u0671'..'\u06d3'
    |   '\u06d5'
    |   '\u06e5'..'\u06e6'
    |   '\u06ee'..'\u06ef'
    |   '\u06fa'..'\u06fc'
    |   '\u06ff'
    |   '\u0710'
    |   '\u0712'..'\u072f'
    |   '\u074d'..'\u074f'
    |   '\u0780'..'\u07a5'
    |   '\u07b1'
    |   '\u0904'..'\u0939'
    |   '\u093d'
    |   '\u0950'
    |   '\u0958'..'\u0961'
    |   '\u0985'..'\u098c'
    |   '\u098f'..'\u0990'
    |   '\u0993'..'\u09a8'
    |   '\u09aa'..'\u09b0'
    |   '\u09b2'
    |   '\u09b6'..'\u09b9'
    |   '\u09bd'
    |   '\u09dc'..'\u09dd'
    |   '\u09df'..'\u09e1'
    |   '\u09f0'..'\u09f3'
    |   '\u0a05'..'\u0a0a'
    |   '\u0a0f'..'\u0a10'
    |   '\u0a13'..'\u0a28'
    |   '\u0a2a'..'\u0a30'
    |   '\u0a32'..'\u0a33'
    |   '\u0a35'..'\u0a36'
    |   '\u0a38'..'\u0a39'
    |   '\u0a59'..'\u0a5c'
    |   '\u0a5e'
    |   '\u0a72'..'\u0a74'
    |   '\u0a85'..'\u0a8d'
    |   '\u0a8f'..'\u0a91'
    |   '\u0a93'..'\u0aa8'
    |   '\u0aaa'..'\u0ab0'
    |   '\u0ab2'..'\u0ab3'
    |   '\u0ab5'..'\u0ab9'
    |   '\u0abd'
    |   '\u0ad0'
    |   '\u0ae0'..'\u0ae1'
    |   '\u0af1'
    |   '\u0b05'..'\u0b0c'
    |   '\u0b0f'..'\u0b10'
    |   '\u0b13'..'\u0b28'
    |   '\u0b2a'..'\u0b30'
    |   '\u0b32'..'\u0b33'
    |   '\u0b35'..'\u0b39'
    |   '\u0b3d'
    |   '\u0b5c'..'\u0b5d'
    |   '\u0b5f'..'\u0b61'
    |   '\u0b71'
    |   '\u0b83'
    |   '\u0b85'..'\u0b8a'
    |   '\u0b8e'..'\u0b90'
    |   '\u0b92'..'\u0b95'
    |   '\u0b99'..'\u0b9a'
    |   '\u0b9c'
    |   '\u0b9e'..'\u0b9f'
    |   '\u0ba3'..'\u0ba4'
    |   '\u0ba8'..'\u0baa'
    |   '\u0bae'..'\u0bb5'
    |   '\u0bb7'..'\u0bb9'
    |   '\u0bf9'
    |   '\u0c05'..'\u0c0c'
    |   '\u0c0e'..'\u0c10'
    |   '\u0c12'..'\u0c28'
    |   '\u0c2a'..'\u0c33'
    |   '\u0c35'..'\u0c39'
    |   '\u0c60'..'\u0c61'
    |   '\u0c85'..'\u0c8c'
    |   '\u0c8e'..'\u0c90'
    |   '\u0c92'..'\u0ca8'
    |   '\u0caa'..'\u0cb3'
    |   '\u0cb5'..'\u0cb9'
    |   '\u0cbd'
    |   '\u0cde'
    |   '\u0ce0'..'\u0ce1'
    |   '\u0d05'..'\u0d0c'
    |   '\u0d0e'..'\u0d10'
    |   '\u0d12'..'\u0d28'
    |   '\u0d2a'..'\u0d39'
    |   '\u0d60'..'\u0d61'
    |   '\u0d85'..'\u0d96'
    |   '\u0d9a'..'\u0db1'
    |   '\u0db3'..'\u0dbb'
    |   '\u0dbd'
    |   '\u0dc0'..'\u0dc6'
    |   '\u0e01'..'\u0e30'
    |   '\u0e32'..'\u0e33'
    |   '\u0e3f'..'\u0e46'
    |   '\u0e81'..'\u0e82'
    |   '\u0e84'
    |   '\u0e87'..'\u0e88'
    |   '\u0e8a'
    |   '\u0e8d'
    |   '\u0e94'..'\u0e97'
    |   '\u0e99'..'\u0e9f'
    |   '\u0ea1'..'\u0ea3'
    |   '\u0ea5'
    |   '\u0ea7'
    |   '\u0eaa'..'\u0eab'
    |   '\u0ead'..'\u0eb0'
    |   '\u0eb2'..'\u0eb3'
    |   '\u0ebd'
    |   '\u0ec0'..'\u0ec4'
    |   '\u0ec6'
    |   '\u0edc'..'\u0edd'
    |   '\u0f00'
    |   '\u0f40'..'\u0f47'
    |   '\u0f49'..'\u0f6a'
    |   '\u0f88'..'\u0f8b'
    |   '\u1000'..'\u1021'
    |   '\u1023'..'\u1027'
    |   '\u1029'..'\u102a'
    |   '\u1050'..'\u1055'
    |   '\u10a0'..'\u10c5'
    |   '\u10d0'..'\u10f8'
    |   '\u1100'..'\u1159'
    |   '\u115f'..'\u11a2'
    |   '\u11a8'..'\u11f9'
    |   '\u1200'..'\u1206'
    |   '\u1208'..'\u1246'
    |   '\u1248'
    |   '\u124a'..'\u124d'
    |   '\u1250'..'\u1256'
    |   '\u1258'
    |   '\u125a'..'\u125d'
    |   '\u1260'..'\u1286'
    |   '\u1288'
    |   '\u128a'..'\u128d'
    |   '\u1290'..'\u12ae'
    |   '\u12b0'
    |   '\u12b2'..'\u12b5'
    |   '\u12b8'..'\u12be'
    |   '\u12c0'
    |   '\u12c2'..'\u12c5'
    |   '\u12c8'..'\u12ce'
    |   '\u12d0'..'\u12d6'
    |   '\u12d8'..'\u12ee'
    |   '\u12f0'..'\u130e'
    |   '\u1310'
    |   '\u1312'..'\u1315'
    |   '\u1318'..'\u131e'
    |   '\u1320'..'\u1346'
    |   '\u1348'..'\u135a'
    |   '\u13a0'..'\u13f4'
    |   '\u1401'..'\u166c'
    |   '\u166f'..'\u1676'
    |   '\u1681'..'\u169a'
    |   '\u16a0'..'\u16ea'
    |   '\u16ee'..'\u16f0'
    |   '\u1700'..'\u170c'
    |   '\u170e'..'\u1711'
    |   '\u1720'..'\u1731'
    |   '\u1740'..'\u1751'
    |   '\u1760'..'\u176c'
    |   '\u176e'..'\u1770'
    |   '\u1780'..'\u17b3'
    |   '\u17d7' 
    |   '\u17db'..'\u17dc'
    |   '\u1820'..'\u1877'
    |   '\u1880'..'\u18a8'
    |   '\u1900'..'\u191c'
    |   '\u1950'..'\u196d'
    |   '\u1970'..'\u1974'
    |   '\u1d00'..'\u1d6b'
    |   '\u1e00'..'\u1e9b'
    |   '\u1ea0'..'\u1ef9'
    |   '\u1f00'..'\u1f15'
    |   '\u1f18'..'\u1f1d'
    |   '\u1f20'..'\u1f45'
    |   '\u1f48'..'\u1f4d'
    |   '\u1f50'..'\u1f57'
    |   '\u1f59'
    |   '\u1f5b'
    |   '\u1f5d'
    |   '\u1f5f'..'\u1f7d'
    |   '\u1f80'..'\u1fb4'
    |   '\u1fb6'..'\u1fbc'
    |   '\u1fbe'
    |   '\u1fc2'..'\u1fc4'
    |   '\u1fc6'..'\u1fcc'
    |   '\u1fd0'..'\u1fd3'
    |   '\u1fd6'..'\u1fdb'
    |   '\u1fe0'..'\u1fec'
    |   '\u1ff2'..'\u1ff4'
    |   '\u1ff6'..'\u1ffc'
    |   '\u203f'..'\u2040'
    |   '\u2054'
    |   '\u2071'
    |   '\u207f'
    |   '\u20a0'..'\u20b1'
    |   '\u2102'
    |   '\u2107'
    |   '\u210a'..'\u2113'
    |   '\u2115'
    |   '\u2119'..'\u211d'
    |   '\u2124'
    |   '\u2126'
    |   '\u2128'
    |   '\u212a'..'\u212d'
    |   '\u212f'..'\u2131'
    |   '\u2133'..'\u2139'
    |   '\u213d'..'\u213f'
    |   '\u2145'..'\u2149'
    |   '\u2160'..'\u2183'
    |   '\u3005'..'\u3007'
    |   '\u3021'..'\u3029'
    |   '\u3031'..'\u3035'
    |   '\u3038'..'\u303c'
    |   '\u3041'..'\u3096'
    |   '\u309d'..'\u309f'
    |   '\u30a1'..'\u30ff'
    |   '\u3105'..'\u312c'
    |   '\u3131'..'\u318e'
    |   '\u31a0'..'\u31b7'
    |   '\u31f0'..'\u31ff'
    |   '\u3400'..'\u4db5'
    |   '\u4e00'..'\u9fa5'
    |   '\ua000'..'\ua48c'
    |   '\uac00'..'\ud7a3'
    |   '\uf900'..'\ufa2d'
    |   '\ufa30'..'\ufa6a'
    |   '\ufb00'..'\ufb06'
    |   '\ufb13'..'\ufb17'
    |   '\ufb1d'
    |   '\ufb1f'..'\ufb28'
    |   '\ufb2a'..'\ufb36'
    |   '\ufb38'..'\ufb3c'
    |   '\ufb3e'
    |   '\ufb40'..'\ufb41'
    |   '\ufb43'..'\ufb44'
    |   '\ufb46'..'\ufbb1'
    |   '\ufbd3'..'\ufd3d'
    |   '\ufd50'..'\ufd8f'
    |   '\ufd92'..'\ufdc7'
    |   '\ufdf0'..'\ufdfc'
    |   '\ufe33'..'\ufe34'
    |   '\ufe4d'..'\ufe4f'
    |   '\ufe69'
    |   '\ufe70'..'\ufe74'
    |   '\ufe76'..'\ufefc'
    |   '\uff04'
    |   '\uff21'..'\uff3a'
    |   '\uff3f'
    |   '\uff41'..'\uff5a'
    |   '\uff65'..'\uffbe'
    |   '\uffc2'..'\uffc7'
    |   '\uffca'..'\uffcf'
    |   '\uffd2'..'\uffd7'
    |   '\uffda'..'\uffdc'
    |   '\uffe0'..'\uffe1'
    |   '\uffe5'..'\uffe6'
    |   ('\ud800'..'\udbff') ('\udc00'..'\udfff') 
    ;                
                       
fragment 
IdentifierPart
    :   '\u0000'..'\u0008'
    |   '\u000e'..'\u001b'
    |   '\u0024'
    |   '\u0030'..'\u0039'
    |   '\u0041'..'\u005a'
    |   '\u005f'
    |   '\u0061'..'\u007a'
    |   '\u007f'..'\u009f'
    |   '\u00a2'..'\u00a5'
    |   '\u00aa'
    |   '\u00ad'
    |   '\u00b5'
    |   '\u00ba'
    |   '\u00c0'..'\u00d6'
    |   '\u00d8'..'\u00f6'
    |   '\u00f8'..'\u0236'
    |   '\u0250'..'\u02c1'
    |   '\u02c6'..'\u02d1'
    |   '\u02e0'..'\u02e4'
    |   '\u02ee'
    |   '\u0300'..'\u0357'
    |   '\u035d'..'\u036f'
    |   '\u037a'
    |   '\u0386'
    |   '\u0388'..'\u038a'
    |   '\u038c'
    |   '\u038e'..'\u03a1'
    |   '\u03a3'..'\u03ce'
    |   '\u03d0'..'\u03f5'
    |   '\u03f7'..'\u03fb'
    |   '\u0400'..'\u0481'
    |   '\u0483'..'\u0486'
    |   '\u048a'..'\u04ce'
    |   '\u04d0'..'\u04f5'
    |   '\u04f8'..'\u04f9'
    |   '\u0500'..'\u050f'
    |   '\u0531'..'\u0556'
    |   '\u0559'
    |   '\u0561'..'\u0587'
    |   '\u0591'..'\u05a1'
    |   '\u05a3'..'\u05b9'
    |   '\u05bb'..'\u05bd'
    |   '\u05bf'
    |   '\u05c1'..'\u05c2'
    |   '\u05c4'
    |   '\u05d0'..'\u05ea'
    |   '\u05f0'..'\u05f2'
    |   '\u0600'..'\u0603'
    |   '\u0610'..'\u0615'
    |   '\u0621'..'\u063a'
    |   '\u0640'..'\u0658'
    |   '\u0660'..'\u0669'
    |   '\u066e'..'\u06d3'
    |   '\u06d5'..'\u06dd'
    |   '\u06df'..'\u06e8'
    |   '\u06ea'..'\u06fc'
    |   '\u06ff'
    |   '\u070f'..'\u074a'
    |   '\u074d'..'\u074f'
    |   '\u0780'..'\u07b1'
    |   '\u0901'..'\u0939'
    |   '\u093c'..'\u094d'
    |   '\u0950'..'\u0954'
    |   '\u0958'..'\u0963'
    |   '\u0966'..'\u096f'
    |   '\u0981'..'\u0983'
    |   '\u0985'..'\u098c'
    |   '\u098f'..'\u0990'
    |   '\u0993'..'\u09a8'
    |   '\u09aa'..'\u09b0'
    |   '\u09b2'
    |   '\u09b6'..'\u09b9'
    |   '\u09bc'..'\u09c4'
    |   '\u09c7'..'\u09c8'
    |   '\u09cb'..'\u09cd'
    |   '\u09d7'
    |   '\u09dc'..'\u09dd'
    |   '\u09df'..'\u09e3'
    |   '\u09e6'..'\u09f3'
    |   '\u0a01'..'\u0a03'
    |   '\u0a05'..'\u0a0a'
    |   '\u0a0f'..'\u0a10'
    |   '\u0a13'..'\u0a28'
    |   '\u0a2a'..'\u0a30'
    |   '\u0a32'..'\u0a33'
    |   '\u0a35'..'\u0a36'
    |   '\u0a38'..'\u0a39'
    |   '\u0a3c'
    |   '\u0a3e'..'\u0a42'
    |   '\u0a47'..'\u0a48'
    |   '\u0a4b'..'\u0a4d'
    |   '\u0a59'..'\u0a5c'
    |   '\u0a5e'
    |   '\u0a66'..'\u0a74'
    |   '\u0a81'..'\u0a83'
    |   '\u0a85'..'\u0a8d'
    |   '\u0a8f'..'\u0a91'
    |   '\u0a93'..'\u0aa8'
    |   '\u0aaa'..'\u0ab0'
    |   '\u0ab2'..'\u0ab3'
    |   '\u0ab5'..'\u0ab9'
    |   '\u0abc'..'\u0ac5'
    |   '\u0ac7'..'\u0ac9'
    |   '\u0acb'..'\u0acd'
    |   '\u0ad0'
    |   '\u0ae0'..'\u0ae3'
    |   '\u0ae6'..'\u0aef'
    |   '\u0af1'
    |   '\u0b01'..'\u0b03'
    |   '\u0b05'..'\u0b0c'        
    |   '\u0b0f'..'\u0b10'
    |   '\u0b13'..'\u0b28'
    |   '\u0b2a'..'\u0b30'
    |   '\u0b32'..'\u0b33'
    |   '\u0b35'..'\u0b39'
    |   '\u0b3c'..'\u0b43'
    |   '\u0b47'..'\u0b48'
    |   '\u0b4b'..'\u0b4d'
    |   '\u0b56'..'\u0b57'
    |   '\u0b5c'..'\u0b5d'
    |   '\u0b5f'..'\u0b61'
    |   '\u0b66'..'\u0b6f'
    |   '\u0b71'
    |   '\u0b82'..'\u0b83'
    |   '\u0b85'..'\u0b8a'
    |   '\u0b8e'..'\u0b90'
    |   '\u0b92'..'\u0b95'
    |   '\u0b99'..'\u0b9a'
    |   '\u0b9c'
    |   '\u0b9e'..'\u0b9f'
    |   '\u0ba3'..'\u0ba4'
    |   '\u0ba8'..'\u0baa'
    |   '\u0bae'..'\u0bb5'
    |   '\u0bb7'..'\u0bb9'
    |   '\u0bbe'..'\u0bc2'
    |   '\u0bc6'..'\u0bc8'
    |   '\u0bca'..'\u0bcd'
    |   '\u0bd7'
    |   '\u0be7'..'\u0bef'
    |   '\u0bf9'
    |   '\u0c01'..'\u0c03'
    |   '\u0c05'..'\u0c0c'
    |   '\u0c0e'..'\u0c10'
    |   '\u0c12'..'\u0c28'
    |   '\u0c2a'..'\u0c33'
    |   '\u0c35'..'\u0c39'
    |   '\u0c3e'..'\u0c44'
    |   '\u0c46'..'\u0c48'
    |   '\u0c4a'..'\u0c4d'
    |   '\u0c55'..'\u0c56'
    |   '\u0c60'..'\u0c61'
    |   '\u0c66'..'\u0c6f'        
    |   '\u0c82'..'\u0c83'
    |   '\u0c85'..'\u0c8c'
    |   '\u0c8e'..'\u0c90'
    |   '\u0c92'..'\u0ca8'
    |   '\u0caa'..'\u0cb3'
    |   '\u0cb5'..'\u0cb9'
    |   '\u0cbc'..'\u0cc4'
    |   '\u0cc6'..'\u0cc8'
    |   '\u0cca'..'\u0ccd'
    |   '\u0cd5'..'\u0cd6'
    |   '\u0cde'
    |   '\u0ce0'..'\u0ce1'
    |   '\u0ce6'..'\u0cef'
    |   '\u0d02'..'\u0d03'
    |   '\u0d05'..'\u0d0c'
    |   '\u0d0e'..'\u0d10'
    |   '\u0d12'..'\u0d28'
    |   '\u0d2a'..'\u0d39'
    |   '\u0d3e'..'\u0d43'
    |   '\u0d46'..'\u0d48'
    |   '\u0d4a'..'\u0d4d'
    |   '\u0d57'
    |   '\u0d60'..'\u0d61'
    |   '\u0d66'..'\u0d6f'
    |   '\u0d82'..'\u0d83'
    |   '\u0d85'..'\u0d96'
    |   '\u0d9a'..'\u0db1'
    |   '\u0db3'..'\u0dbb'
    |   '\u0dbd'
    |   '\u0dc0'..'\u0dc6'
    |   '\u0dca'
    |   '\u0dcf'..'\u0dd4'
    |   '\u0dd6'
    |   '\u0dd8'..'\u0ddf'
    |   '\u0df2'..'\u0df3'
    |   '\u0e01'..'\u0e3a'
    |   '\u0e3f'..'\u0e4e'
    |   '\u0e50'..'\u0e59'
    |   '\u0e81'..'\u0e82'
    |   '\u0e84'
    |   '\u0e87'..'\u0e88'        
    |   '\u0e8a'
    |   '\u0e8d'
    |   '\u0e94'..'\u0e97'
    |   '\u0e99'..'\u0e9f'
    |   '\u0ea1'..'\u0ea3'
    |   '\u0ea5'
    |   '\u0ea7'
    |   '\u0eaa'..'\u0eab'
    |   '\u0ead'..'\u0eb9'
    |   '\u0ebb'..'\u0ebd'
    |   '\u0ec0'..'\u0ec4'
    |   '\u0ec6'
    |   '\u0ec8'..'\u0ecd'
    |   '\u0ed0'..'\u0ed9'
    |   '\u0edc'..'\u0edd'
    |   '\u0f00'
    |   '\u0f18'..'\u0f19'
    |   '\u0f20'..'\u0f29'
    |   '\u0f35'
    |   '\u0f37'
    |   '\u0f39'
    |   '\u0f3e'..'\u0f47'
    |   '\u0f49'..'\u0f6a'
    |   '\u0f71'..'\u0f84'
    |   '\u0f86'..'\u0f8b'
    |   '\u0f90'..'\u0f97'
    |   '\u0f99'..'\u0fbc'
    |   '\u0fc6'
    |   '\u1000'..'\u1021'
    |   '\u1023'..'\u1027'
    |   '\u1029'..'\u102a'
    |   '\u102c'..'\u1032'
    |   '\u1036'..'\u1039'
    |   '\u1040'..'\u1049'
    |   '\u1050'..'\u1059'
    |   '\u10a0'..'\u10c5'
    |   '\u10d0'..'\u10f8'
    |   '\u1100'..'\u1159'
    |   '\u115f'..'\u11a2'
    |   '\u11a8'..'\u11f9'
    |   '\u1200'..'\u1206'        
    |   '\u1208'..'\u1246'
    |   '\u1248'
    |   '\u124a'..'\u124d'
    |   '\u1250'..'\u1256'
    |   '\u1258'
    |   '\u125a'..'\u125d'
    |   '\u1260'..'\u1286'
    |   '\u1288'        
    |   '\u128a'..'\u128d'
    |   '\u1290'..'\u12ae'
    |   '\u12b0'
    |   '\u12b2'..'\u12b5'
    |   '\u12b8'..'\u12be'
    |   '\u12c0'
    |   '\u12c2'..'\u12c5'
    |   '\u12c8'..'\u12ce'
    |   '\u12d0'..'\u12d6'
    |   '\u12d8'..'\u12ee'
    |   '\u12f0'..'\u130e'
    |   '\u1310'
    |   '\u1312'..'\u1315'
    |   '\u1318'..'\u131e'
    |   '\u1320'..'\u1346'
    |   '\u1348'..'\u135a'
    |   '\u1369'..'\u1371'
    |   '\u13a0'..'\u13f4'
    |   '\u1401'..'\u166c'
    |   '\u166f'..'\u1676'
    |   '\u1681'..'\u169a'
    |   '\u16a0'..'\u16ea'
    |   '\u16ee'..'\u16f0'
    |   '\u1700'..'\u170c'
    |   '\u170e'..'\u1714'
    |   '\u1720'..'\u1734'
    |   '\u1740'..'\u1753'
    |   '\u1760'..'\u176c'
    |   '\u176e'..'\u1770'
    |   '\u1772'..'\u1773'
    |   '\u1780'..'\u17d3'
    |   '\u17d7'
    |   '\u17db'..'\u17dd'
    |   '\u17e0'..'\u17e9'
    |   '\u180b'..'\u180d'
    |   '\u1810'..'\u1819'
    |   '\u1820'..'\u1877'
    |   '\u1880'..'\u18a9'
    |   '\u1900'..'\u191c'
    |   '\u1920'..'\u192b'
    |   '\u1930'..'\u193b'
    |   '\u1946'..'\u196d'
    |   '\u1970'..'\u1974'
    |   '\u1d00'..'\u1d6b'
    |   '\u1e00'..'\u1e9b'
    |   '\u1ea0'..'\u1ef9'
    |   '\u1f00'..'\u1f15'
    |   '\u1f18'..'\u1f1d'
    |   '\u1f20'..'\u1f45'
    |   '\u1f48'..'\u1f4d'
    |   '\u1f50'..'\u1f57'
    |   '\u1f59'
    |   '\u1f5b'
    |   '\u1f5d'
    |   '\u1f5f'..'\u1f7d'
    |   '\u1f80'..'\u1fb4'
    |   '\u1fb6'..'\u1fbc'        
    |   '\u1fbe'
    |   '\u1fc2'..'\u1fc4'
    |   '\u1fc6'..'\u1fcc'
    |   '\u1fd0'..'\u1fd3'
    |   '\u1fd6'..'\u1fdb'
    |   '\u1fe0'..'\u1fec'
    |   '\u1ff2'..'\u1ff4'
    |   '\u1ff6'..'\u1ffc'
    |   '\u200c'..'\u200f'
    |   '\u202a'..'\u202e'
    |   '\u203f'..'\u2040'
    |   '\u2054'
    |   '\u2060'..'\u2063'
    |   '\u206a'..'\u206f'
    |   '\u2071'
    |   '\u207f'
    |   '\u20a0'..'\u20b1'
    |   '\u20d0'..'\u20dc'
    |   '\u20e1'
    |   '\u20e5'..'\u20ea'
    |   '\u2102'
    |   '\u2107'
    |   '\u210a'..'\u2113'
    |   '\u2115'
    |   '\u2119'..'\u211d'
    |   '\u2124'
    |   '\u2126'
    |   '\u2128'
    |   '\u212a'..'\u212d'
    |   '\u212f'..'\u2131'
    |   '\u2133'..'\u2139'
    |   '\u213d'..'\u213f'
    |   '\u2145'..'\u2149'
    |   '\u2160'..'\u2183'
    |   '\u3005'..'\u3007'
    |   '\u3021'..'\u302f'        
    |   '\u3031'..'\u3035'
    |   '\u3038'..'\u303c'
    |   '\u3041'..'\u3096'
    |   '\u3099'..'\u309a'
    |   '\u309d'..'\u309f'
    |   '\u30a1'..'\u30ff'
    |   '\u3105'..'\u312c'
    |   '\u3131'..'\u318e'
    |   '\u31a0'..'\u31b7'
    |   '\u31f0'..'\u31ff'
    |   '\u3400'..'\u4db5'
    |   '\u4e00'..'\u9fa5'
    |   '\ua000'..'\ua48c'
    |   '\uac00'..'\ud7a3'
    |   '\uf900'..'\ufa2d'
    |   '\ufa30'..'\ufa6a'
    |   '\ufb00'..'\ufb06'
    |   '\ufb13'..'\ufb17'
    |   '\ufb1d'..'\ufb28'
    |   '\ufb2a'..'\ufb36'
    |   '\ufb38'..'\ufb3c'
    |   '\ufb3e'
    |   '\ufb40'..'\ufb41'
    |   '\ufb43'..'\ufb44'
    |   '\ufb46'..'\ufbb1'
    |   '\ufbd3'..'\ufd3d'
    |   '\ufd50'..'\ufd8f'
    |   '\ufd92'..'\ufdc7'
    |   '\ufdf0'..'\ufdfc'
    |   '\ufe00'..'\ufe0f'
    |   '\ufe20'..'\ufe23'
    |   '\ufe33'..'\ufe34'
    |   '\ufe4d'..'\ufe4f'
    |   '\ufe69'
    |   '\ufe70'..'\ufe74'
    |   '\ufe76'..'\ufefc'
    |   '\ufeff'
    |   '\uff04'
    |   '\uff10'..'\uff19'
    |   '\uff21'..'\uff3a'
    |   '\uff3f'
    |   '\uff41'..'\uff5a'
    |   '\uff65'..'\uffbe'
    |   '\uffc2'..'\uffc7'
    |   '\uffca'..'\uffcf'
    |   '\uffd2'..'\uffd7'
    |   '\uffda'..'\uffdc'
    |   '\uffe0'..'\uffe1'
    |   '\uffe5'..'\uffe6'
    |   '\ufff9'..'\ufffb' 
    |   ('\ud800'..'\udbff') ('\udc00'..'\udfff')
    ;

