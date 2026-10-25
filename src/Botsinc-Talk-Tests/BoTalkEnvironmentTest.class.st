"
I test BoTalkEnvironment: the shared variables and the history of the messages.
"
Class {
	#name : 'BoTalkEnvironmentTest',
	#superclass : 'TestCase',
	#instVars : [
		'environment'
	],
	#category : 'Botsinc-Talk-Tests',
	#package : 'Botsinc-Talk-Tests'
}

{ #category : 'running' }
BoTalkEnvironmentTest >> setUp [
	super setUp.
	environment := BoTalkEnvironment new

]

{ #category : 'tests' }
BoTalkEnvironmentTest >> testDeclareCreatesVariableOnce [
	| variable |
	variable := environment declare: 'pica'.
	variable value: 3.
	self assert: (environment declare: 'pica') identicalTo: variable.
	self assert: (environment valueOf: 'pica') equals: 3

]

{ #category : 'tests' }
BoTalkEnvironmentTest >> testHistoryDoesNotRepeatTheLastMessage [
	environment remember: 'go: 10' for: BoTurtle new.
	environment remember: 'go: 10' for: BoTurtle new.
	environment remember: 'turn: 90' for: BoTurtle new.
	environment remember: 'go: 10' for: BoTurtle new.
	self
		assert: (environment historyFor: BoTurtle new)
		equals: #( 'go: 10' 'turn: 90' 'go: 10' )

]

{ #category : 'tests' }
BoTalkEnvironmentTest >> testHistoryIsLimited [
	1 to: environment historyLimit + 5 do: [ :each |
		environment remember: 'go: ' , each printString for: BoTurtle new ].
	self assert: (environment historyFor: BoTurtle new) size equals: environment historyLimit.
	self assert: (environment historyFor: BoTurtle new) first equals: 'go: 6'

]

{ #category : 'tests' }
BoTalkEnvironmentTest >> testHistoryIsSharedByTheObjectsOfAClass [
	environment remember: 'go: 10' for: BoTurtle new.
	environment remember: 'clearTrails' for: BoTurtleWorld new.
	self assert: (environment historyFor: BoTurtle new) equals: #( 'go: 10' ).
	self assert: (environment historyFor: BoTurtleWorld new) equals: #( 'clearTrails' ).
	self assert: (environment historyFor: 3) isEmpty

]

{ #category : 'tests' }
BoTalkEnvironmentTest >> testUndeclareRemovesVariable [
	environment declare: 'pica'.
	environment undeclare: 'pica'.
	self deny: (environment hasBindingOf: 'pica')

]
