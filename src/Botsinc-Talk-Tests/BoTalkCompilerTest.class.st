"
I test BoTalkCompiler: which statements are sent to the receiver, the variables created by assignments and the compilation errors.
"
Class {
	#name : 'BoTalkCompilerTest',
	#superclass : 'TestCase',
	#instVars : [
		'environment',
		'turtle',
		'compiler'
	],
	#category : 'Botsinc-Talk-Tests',
	#package : 'Botsinc-Talk-Tests'
}

{ #category : 'helpers' }
BoTalkCompilerTest >> assertIntended: aString is: anotherString [
	self assert: (compiler intendedSource: aString) equals: anotherString

]

{ #category : 'helpers' }
BoTalkCompilerTest >> assertUnchanged: aString [
	self assertIntended: aString is: aString

]

{ #category : 'helpers' }
BoTalkCompilerTest >> evaluate: aString [
	^ compiler run: (compiler compile: aString)

]

{ #category : 'running' }
BoTalkCompilerTest >> setUp [
	super setUp.
	environment := BoTalkEnvironment new.
	turtle := BoTurtle new.
	compiler := BoTalkCompiler receiver: turtle environment: environment

]

{ #category : 'tests - compiling' }
BoTalkCompilerTest >> testAssignmentCreatesSharedVariable [
	self evaluate: 'pica := self'.
	self assert: (environment valueOf: 'pica') identicalTo: turtle

]

{ #category : 'tests - intended source' }
BoTalkCompilerTest >> testBinaryMessageIsSentToTheReceiver [
	self assertIntended: '+ 3' is: 'self + 3'

]

{ #category : 'tests - intended source' }
BoTalkCompilerTest >> testCascadeIsSentToTheReceiver [
	self assertIntended: 'go: 100; turn: 90' is: 'self go: 100; turn: 90'

]

{ #category : 'tests - intended source' }
BoTalkCompilerTest >> testEachStatementIsSentToTheReceiver [
	self assertIntended: 'go: 10. turn: 90' is: 'self go: 10. self turn: 90'

]

{ #category : 'tests - compiling' }
BoTalkCompilerTest >> testFailedCompilationCreatesNoVariable [
	self should: [ compiler compile: 'pica := 3 +' ] raise: BoTalkError.
	self deny: (environment hasBindingOf: 'pica')

]

{ #category : 'tests - intended source' }
BoTalkCompilerTest >> testGlobalsAreUnchanged [
	self assertUnchanged: 'BoTurtle new'.
	self assertUnchanged: 'Smalltalk version'

]

{ #category : 'tests - intended source' }
BoTalkCompilerTest >> testKeywordMessageIsSentToTheReceiver [
	self assertIntended: 'go: 100' is: 'self go: 100'

]

{ #category : 'tests - intended source' }
BoTalkCompilerTest >> testLeadingSpacesAreKept [
	self assertIntended: '  turn: 4' is: '  self turn: 4'

]

{ #category : 'tests - intended source' }
BoTalkCompilerTest >> testLiteralsAreUnchanged [
	self assertUnchanged: '3 + 4'.
	self assertUnchanged: '#foo size'.
	self assertUnchanged: '''abc'' size'.
	self assertUnchanged: '[ :each | each ] value: 3'.
	self assertUnchanged: '{ 1. 2 }'.
	self assertUnchanged: 'nil isNil'

]

{ #category : 'tests - compiling' }
BoTalkCompilerTest >> testMessageIsSentToTheReceiver [
	self evaluate: 'go: 100'.
	self assert: turtle center equals: 100 @ 0

]

{ #category : 'tests - compiling' }
BoTalkCompilerTest >> testMessageWithoutReceiverInBlockIsAnError [
	self should: [ compiler compile: '4 timesRepeat: [ go: 100; turn: 90 ]' ] raise: BoTalkError.
	self should: [ compiler compile: '4 timesRepeat: [ home ]' ] raise: BoTalkError

]

{ #category : 'tests - intended source' }
BoTalkCompilerTest >> testMessagesInBlocksAreUnchanged [
	"Only the statements typed at the top level are sent to the receiver: inside a block, self must be written"

	self assertUnchanged: '4 timesRepeat: [ go: 100; turn: 90 ]'.
	self assertUnchanged: '[ home ] value'

]

{ #category : 'tests - intended source' }
BoTalkCompilerTest >> testPseudoVariablesAreUnchanged [
	self assertUnchanged: 'self go: 3'.
	self assertUnchanged: 'super printString'.
	self assertUnchanged: 'thisContext'

]

{ #category : 'tests - compiling' }
BoTalkCompilerTest >> testResultIsReturned [
	self assert: (self evaluate: 'direction + 5') equals: 5

]

{ #category : 'tests - compiling' }
BoTalkCompilerTest >> testSelfInBlockSpeaksToTheReceiver [
	"A square brings the turtle back to its start"

	self evaluate: '4 timesRepeat: [ self go: 100; turn: 90 ]'.
	self assert: turtle center equals: 0 @ 0.
	self assert: turtle direction equals: 0
]

{ #category : 'tests - compiling' }
BoTalkCompilerTest >> testSharedVariableIsUsedByAnotherReceiver [
	| other |
	self evaluate: 'pica := self'.
	other := BoTalkCompiler receiver: BoTurtle new environment: environment.
	other run: (other compile: 'pica go: 50').
	self assert: turtle center equals: 50 @ 0

]

{ #category : 'tests - intended source' }
BoTalkCompilerTest >> testSharedVariablesAreUnchanged [
	environment declare: 'pica'.
	self assertUnchanged: 'pica go: 1'

]

{ #category : 'tests - compiling' }
BoTalkCompilerTest >> testSyntaxErrorIsExplained [
	| error |
	error := [ compiler compile: 'go: 100 +' ]
		on: BoTalkError
		do: [ :each | each ].
	self assert: (error isKindOf: BoTalkError).
	self deny: error messageText isEmpty

]

{ #category : 'tests - intended source' }
BoTalkCompilerTest >> testSyntaxErrorsAreUnchanged [
	self assertUnchanged: ')'.
	self assertUnchanged: '3 +'

]

{ #category : 'tests - intended source' }
BoTalkCompilerTest >> testTemporariesAndAssignedVariablesAreUnchanged [
	self assertUnchanged: '| t | t := 4. t go: 1'.
	self assertUnchanged: 'x := 3. x + 1'

]

{ #category : 'tests - compiling' }
BoTalkCompilerTest >> testTemporaryIsNotShared [
	self evaluate: '| t | t := 3'.
	self deny: (environment hasBindingOf: 't')

]

{ #category : 'tests - intended source' }
BoTalkCompilerTest >> testUnaryMessageIsSentToTheReceiver [
	self assertIntended: 'home' is: 'self home'.
	self assertIntended: 'home; north' is: 'self home; north'.
	self assertIntended: 'direction + 5' is: 'self direction + 5'

]
