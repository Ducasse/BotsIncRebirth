"
I hold what the talk bubbles of a world share: the variables created by assignments typed in a bubble (pica := self lets the other bubbles talk about pica) and the history of the messages sent, one per class of receiver.

A world gets its environment with BoTurtleWorld>>talkEnvironment. I also play the role of the workspace of the code styler, so that the variables I hold are colored as variables.
"
Class {
	#name : 'BoTalkEnvironment',
	#superclass : 'Object',
	#instVars : [
		'bindings',
		'histories'
	],
	#category : 'Botsinc-Talk',
	#package : 'Botsinc-Talk'
}

{ #category : 'bindings' }
BoTalkEnvironment >> bindingOf: aString [
	^ bindings at: aString asSymbol ifAbsent: [ nil ]

]

{ #category : 'bindings' }
BoTalkEnvironment >> bindings [
	"Return the variables shared by the bubbles, as a dictionary from names to WorkspaceVariables"

	^ bindings

]

{ #category : 'bindings' }
BoTalkEnvironment >> declare: aString [
	"Create a variable named aString unless it exists already, and return it"

	^ bindings at: aString asSymbol ifAbsentPut: [ WorkspaceVariable key: aString asSymbol ]

]

{ #category : 'bindings' }
BoTalkEnvironment >> hasBindingOf: aString [
	^ bindings includesKey: aString asSymbol

]

{ #category : 'history' }
BoTalkEnvironment >> historyFor: anObject [
	"Return the messages sent to the objects of the class of anObject, the oldest first"

	^ (histories at: anObject class ifAbsent: [ #() ]) asArray

]

{ #category : 'history' }
BoTalkEnvironment >> historyLimit [
	^ 50

]

{ #category : 'initialization' }
BoTalkEnvironment >> initialize [
	super initialize.
	bindings := Dictionary new.
	histories := Dictionary new

]

{ #category : 'styler workspace' }
BoTalkEnvironment >> isScripting [
	^ true

]

{ #category : 'styler workspace' }
BoTalkEnvironment >> notify: aString at: anInteger in: aSourceString [
	"The styler reports the errors of the code it colors. We ignore them since the bubble reports them when the code is run"

]

{ #category : 'history' }
BoTalkEnvironment >> remember: aString for: anObject [
	"Add aString to the history of the class of anObject, unless it is the last message of this history"

	| history |
	history := histories at: anObject class ifAbsentPut: [ OrderedCollection new ].
	(history notEmpty and: [ history last = aString ]) ifTrue: [ ^ self ].
	history addLast: aString.
	history size > self historyLimit ifTrue: [ history removeFirst ]

]

{ #category : 'bindings' }
BoTalkEnvironment >> undeclare: aString [
	bindings removeKey: aString asSymbol ifAbsent: [ ]

]

{ #category : 'bindings' }
BoTalkEnvironment >> valueOf: aString [
	"Return the value of the variable named aString"

	^ (bindings at: aString asSymbol) value

]
