"
I compile the code typed in a talk bubble so that it can be run with the receiver of the bubble as self.

A top-level statement that does not say to whom it speaks is sent to the receiver: 'go: 100; turn: 90' becomes 'self go: 100; turn: 90' and 'home' becomes 'self home'. A statement starting with a variable, a global, a literal or self is left as is. Inside a block nothing is changed: self must be written, so '4 timesRepeat: [ go: 100 ]' does not compile while '4 timesRepeat: [ self go: 100 ]' does. Assigning an undeclared variable creates it in the environment.

	(BoTalkCompiler receiver: BoTurtle new environment: BoTalkEnvironment new) intendedSource: 'go: 100'
"
Class {
	#name : 'BoTalkCompiler',
	#superclass : 'Object',
	#instVars : [
		'receiver',
		'environment',
		'addsReceivers'
	],
	#category : 'Botsinc-Talk',
	#package : 'Botsinc-Talk'
}

{ #category : 'instance creation' }
BoTalkCompiler class >> receiver: anObject environment: aTalkEnvironment [
	^ self new setReceiver: anObject environment: aTalkEnvironment

]

{ #category : 'accessing' }
BoTalkCompiler >> addsReceivers [

	^ addsReceivers
]

{ #category : 'accessing' }
BoTalkCompiler >> addsReceivers: aBoolean [
	"When aBoolean is true, as in the bubbles, a statement that does not say to whom it speaks is sent to the receiver (see intendedSource:). When it is false, as in the micro playground, the code is compiled as it is written"

	addsReceivers := aBoolean
]

{ #category : 'private' }
BoTalkCompiler >> allNodesOf: anAST [
	"Return anAST and all its nodes"

	^ anAST allChildren copyWith: anAST
]

{ #category : 'private' }
BoTalkCompiler >> assignedNamesIn: aString [
	"Return the names of the variables assigned by aString that it does not declare"

	| nodes declared |
	nodes := self allNodesOf: (OCParser parseFaultyExpression: aString).
	declared := Set new.
	nodes do: [ :each |
		(each isSequence or: [ each isBlock ]) ifTrue: [
			declared addAll: (each temporaries collect: [ :temp | temp name ]) ].
		each isBlock ifTrue: [ declared addAll: each argumentNames ] ].
	^ ((nodes select: [ :each | each isAssignment ])
		collect: [ :each | each variable name ]
		as: Set)
		reject: [ :each |
			(declared includes: each)
				or: [ (receiver class hasSlotNamed: each)
				or: [ Smalltalk globals includesKey: each asSymbol ] ] ]
]

{ #category : 'compiling' }
BoTalkCompiler >> compile: aString [
	"Return a method that runs aString with the receiver as self, see run:. Signal a BoTalkError when aString does not compile. The variables assigned by aString are created in the environment, unless aString does not compile"

	| source created |
	source := addsReceivers
		          ifTrue: [ self intendedSource: aString ]
		          ifFalse: [ aString ].
	created := (self assignedNamesIn: source) reject: [ :each | environment hasBindingOf: each ].
	created do: [ :each | environment declare: each ].
	^ [
		  OpalCompiler new
			  source: source;
			  receiver: receiver;
			  bindings: environment bindings values;
			  compile ]
		  on: OCCodeError
		  do: [ :error |
				  created do: [ :each | environment undeclare: each ].
				  BoTalkError new signal: error messageText ]
]

{ #category : 'private' }
BoTalkCompiler >> declaredNamesIn: anAST [
	"Return the names that anAST may use without speaking to the receiver"

	| names |
	names := Set new.
	anAST isSequence ifTrue: [ names addAll: (anAST temporaries collect: [ :each | each name ]) ].
	((self allNodesOf: anAST) select: [ :each | each isAssignment ]) do: [ :each | names add: each variable name ].
	^ names
]

{ #category : 'accessing' }
BoTalkCompiler >> environment [
	^ environment

]

{ #category : 'compiling' }
BoTalkCompiler >> intendedSource: aString [
	"Return aString where each statement that does not say to whom it speaks is sent to the receiver: 'go: 100; turn: 90' becomes 'self go: 100; turn: 90'"

	| ast known result |
	ast := OCParser parseFaultyExpression: aString.
	known := self declaredNamesIn: ast.
	result := aString.
	((self statementsOf: ast)
		select: [ :each | self isSpeakingToNobody: each knowing: known ]
		thenCollect: [ :each | (self leftmostReceiverOf: each) start ])
			asSortedCollection reverseDo: [ :each |
				result := result copyReplaceFrom: each to: each - 1 with: 'self ' ].
	^ result

]

{ #category : 'private' }
BoTalkCompiler >> isKnownName: aString knowing: declaredNames [
	^ (#( 'self' 'super' 'thisContext' ) includes: aString)
		or: [ (declaredNames includes: aString)
		or: [ (environment hasBindingOf: aString)
		or: [ aString first isUppercase
		or: [ Smalltalk globals includesKey: aString asSymbol ] ] ] ]

]

{ #category : 'private' }
BoTalkCompiler >> isSpeakingToNobody: aStatement knowing: declaredNames [
	"A message without receiver (go: 100) or starting with a name that is not a variable (home) speaks to nobody"

	| node |
	node := self leftmostReceiverOf: aStatement.
	node isParseError ifTrue: [
		^ node ~~ aStatement and: [ node value isEmpty ] ].
	^ node isVariable and: [ (self isKnownName: node name knowing: declaredNames) not ]

]

{ #category : 'private' }
BoTalkCompiler >> leftmostReceiverOf: aNode [
	| node |
	node := aNode.
	[ node isCascade or: [ node isMessage ] ] whileTrue: [ node := node receiver ].
	^ node

]

{ #category : 'accessing' }
BoTalkCompiler >> receiver [
	^ receiver

]

{ #category : 'running' }
BoTalkCompiler >> run: aCompiledMethod [
	"Run a method returned by compile: and return its result"

	^ receiver withArgs: #() executeMethod: aCompiledMethod

]

{ #category : 'initialization' }
BoTalkCompiler >> setReceiver: anObject environment: aTalkEnvironment [

	receiver := anObject.
	environment := aTalkEnvironment.
	addsReceivers := true
]

{ #category : 'private' }
BoTalkCompiler >> statementsOf: anAST [
	^ anAST isSequence
		ifTrue: [ anAST statements ]
		ifFalse: [ { anAST } ]

]
