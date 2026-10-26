"
I am a small workspace to write scripts for the turtles of a world, the Bloc version of the MicroWorkspace of Bots Inc. I am shown in a window inside the world, placed in a flap or anywhere in the world (see BoMicroTool and BoTurtleWorld class>>openWithTools).

My scripts are plain Smalltalk: unlike in the talk bubbles, no receiver is added to the messages. self is the world. The turtles created while a script runs go in the world (see BoCurrentWorld). The variables that a script assigns without declaring them are shared with the bubbles of the world; the declared ones are not.

	| caro |
	caro := BoTurtle new.
	4 timesRepeat: [ caro go: 100; turnLeft: 90 ]

Do it runs the selected text, or the whole script when nothing is selected (Cmd+D), Do it all runs the whole script. Both run in the UI process, so that any turtle can be used. Animate runs the whole script in its own process, so that the moves of animated turtles (BoAnimatedTurtle new) can be followed.
"
Class {
	#name : 'BoMicroWorkspace',
	#superclass : 'BoMicroTool',
	#instVars : [
		'world',
		'codePane',
		'messageLabel',
		'doItButton',
		'doItAllButton',
		'animateButton',
		'clearTrailsButton',
		'clearTurtlesButton',
		'clearAllButton'
	],
	#category : 'Botsinc-Micro',
	#package : 'Botsinc-Micro'
}

{ #category : 'instance creation' }
BoMicroWorkspace class >> on: aWorld [

	^ (self newApplication: BoMicroApplication new)
		  setWorld: aWorld;
		  yourself
]

{ #category : 'running' }
BoMicroWorkspace >> animate [
	"Run the whole script in its own process, so that the world is redrawn while animated turtles move. Return the process"

	| source method |
	source := codePane text.
	method := (self compile: source) ifNil: [ ^ nil ].
	^ [ self run: method source: source ] forkAt: Processor userBackgroundPriority named: 'BoMicroWorkspace script'
]

{ #category : 'cleaning' }
BoMicroWorkspace >> clearAll [

	self
		clearTurtles;
		clearTrails
]

{ #category : 'cleaning' }
BoMicroWorkspace >> clearTrails [

	world clearTrails
]

{ #category : 'cleaning' }
BoMicroWorkspace >> clearTurtles [

	world removeTurtles
]

{ #category : 'accessing' }
BoMicroWorkspace >> codePane [

	^ codePane
]

{ #category : 'private' }
BoMicroWorkspace >> compile: aString [
	"Return a method running aString, or nil after showing why it does not compile"

	aString trimBoth ifEmpty: [ ^ nil ].
	^ [ self compiler compile: aString ]
		  on: BoTalkError
		  do: [ :error |
				  self showError: error messageText.
				  nil ]
]

{ #category : 'running' }
BoMicroWorkspace >> compiler [
	"The scripts of the workspace are plain Smalltalk: unlike in the bubbles, the receiver of a message is never added"

	^ (BoTalkCompiler receiver: world environment: world talkEnvironment)
		  addsReceivers: false;
		  yourself
]

{ #category : 'layout' }
BoMicroWorkspace >> defaultLayout [

	^ SpBoxLayout newTopToBottom
		  spacing: 4;
		  add: (SpBoxLayout newLeftToRight
				   spacing: 4;
				   add: doItButton;
				   add: doItAllButton;
				   add: animateButton;
				   add: clearTrailsButton;
				   add: clearTurtlesButton;
				   add: clearAllButton;
				   yourself)
		  expand: false;
		  add: codePane;
		  add: messageLabel expand: false;
		  yourself
]

{ #category : 'running' }
BoMicroWorkspace >> doIt [
	"Run the selected text, or the whole script when nothing is selected, as the MicroWorkspace of Bots Inc did, and return its result"

	^ self evaluate: codePane selectionOrText
]

{ #category : 'running' }
BoMicroWorkspace >> doItAll [
	"Run the whole script and return its result"

	^ self evaluate: codePane text
]

{ #category : 'running' }
BoMicroWorkspace >> evaluate: aString [
	"Run aString with the world as receiver and show its result. Return the result, or nil when aString fails"

	| method |
	method := (self compile: aString) ifNil: [ ^ nil ].
	^ self run: method source: aString
]

{ #category : 'private' }
BoMicroWorkspace >> inUIDo: aBlock [
	"The scene graph must only be changed by the UI process"

	(world isAttachedToSceneGraph and: [ world space isPulseProcessActive not ])
		ifTrue: [
				world enqueueTask: (BlTaskAction new
						 action: aBlock;
						 yourself) ]
		ifFalse: [ aBlock value ]
]

{ #category : 'initialization' }
BoMicroWorkspace >> initializePresenters [

	codePane := self instantiate: BoCodePane.
	codePane whenTextEditedDo: [ codePane clearError ].
	codePane addShortcut: BlKeyCombination primaryD named: 'Do it' do: [ self doIt ].
	doItButton := self
		              newButtonLabeled: 'Do it'
		              help: 'Run the selected text, or the whole script when nothing is selected (Cmd+D)'
		              action: [ self doIt ].
	doItAllButton := self newButtonLabeled: 'Do it all' help: 'Run the whole script' action: [ self doItAll ].
	animateButton := self
		                 newButtonLabeled: 'Animate'
		                 help: 'Run the whole script step by step, so that animated turtles can be followed'
		                 action: [ self animate ].
	clearTrailsButton := self newButtonLabeled: 'Clear trails' help: 'Remove the trails of the turtles' action: [ self clearTrails ].
	clearTurtlesButton := self
		                      newButtonLabeled: 'Clear turtles'
		                      help: 'Remove the turtles from the world'
		                      action: [ self clearTurtles ].
	clearAllButton := self newButtonLabeled: 'Clear all' help: 'Remove the turtles and their trails' action: [ self clearAll ].
	messageLabel := self newLabel
]

{ #category : 'accessing' }
BoMicroWorkspace >> message [
	"Return the text shown under the script: the result of the last script, or why it failed"

	^ messageLabel label
]

{ #category : 'running' }
BoMicroWorkspace >> run: aCompiledMethod source: aString [
	"Run a method returned by compile: and show its result. The turtles created by the method go in the world, see BoCurrentWorld. Return the result, or nil when it fails"

	| result |
	result := [ BoCurrentWorld value: world during: [ self compiler run: aCompiledMethod ] ]
		          on: Error
		          do: [ :error |
				          self inUIDo: [ self showError: error description ].
				          BoSpeechBubble debugOnError ifTrue: [ error pass ].
				          ^ nil ].
	world talkEnvironment remember: aString for: world.
	self inUIDo: [ self showResult: result ].
	^ result
]

{ #category : 'initialization' }
BoMicroWorkspace >> setWorld: aWorld [

	world := aWorld.
	codePane environment: aWorld talkEnvironment
]

{ #category : 'private' }
BoMicroWorkspace >> showError: aString [

	codePane showError.
	messageLabel label: aString
]

{ #category : 'private' }
BoMicroWorkspace >> showResult: anObject [

	codePane clearError.
	messageLabel label: (anObject printStringLimitedTo: 200)
]

{ #category : 'window' }
BoMicroWorkspace >> windowTitle [

	^ 'Bot Workspace'
]

{ #category : 'accessing' }
BoMicroWorkspace >> world [

	^ world
]
