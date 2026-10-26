"
I test the micro playground on a world that is not displayed, so that the scripts run at once.
"
Class {
	#name : 'BoMicroPlaygroundTest',
	#superclass : 'TestCase',
	#instVars : [
		'world',
		'playground'
	],
	#category : 'Botsinc-Micro-Tests',
	#package : 'Botsinc-Micro-Tests'
}

{ #category : 'running' }
BoMicroPlaygroundTest >> setUp [

	super setUp.
	world := BoTurtleWorld new.
	playground := BoMicroPlayground on: world
]

{ #category : 'tests' }
BoMicroPlaygroundTest >> testAnimateRunsTheScriptInItsOwnProcess [

	| process |
	playground codePane text: 'BoAnimatedTurtle new go: 10'.
	process := playground animate.
	self deny: process == Processor activeProcess.
	self wait: 2 seconds until: [ process isTerminated ].
	self assert: world turtles size equals: 1
]

{ #category : 'tests' }
BoMicroPlaygroundTest >> testBuiltPlaygroundShowsTheResult [
	"The playground is built with the Toplo backend, as when it is shown"

	playground build.
	playground codePane text: '3 + 4'.
	playground doItAll.
	self assert: playground message equals: '7'
]

{ #category : 'tests' }
BoMicroPlaygroundTest >> testClearAll [

	world newTurtle go: 100.
	playground clearAll.
	self assert: world turtles isEmpty.
	self assert: world trails isEmpty
]

{ #category : 'tests' }
BoMicroPlaygroundTest >> testClearTrailsKeepsTheTurtles [

	world newTurtle go: 100.
	playground clearTrails.
	self assert: world turtles size equals: 1.
	self assert: world trails isEmpty
]

{ #category : 'tests' }
BoMicroPlaygroundTest >> testCompilationErrorIsShown [

	playground codePane text: 'pica := 3 +'.
	self assert: playground doItAll isNil.
	self assert: playground codePane showsError.
	self deny: playground message isEmpty.
	self deny: (world talkEnvironment hasBindingOf: 'pica')
]

{ #category : 'tests' }
BoMicroPlaygroundTest >> testDoItAllRunsTheScriptOnTheWorld [

	playground codePane text: 'pica := self newTurtle.
pica go: 100'.
	playground doItAll.
	self assert: world turtles size equals: 1.
	self assert: (world talkEnvironment valueOf: 'pica') equals: world turtles first.
	self assert: world trails size equals: 1
]

{ #category : 'tests' }
BoMicroPlaygroundTest >> testDoItRunsTheSelection [

	playground codePane text: 'BoTurtle new. BoTurtle new'.
	playground codePane selectFrom: 1 to: 12.
	playground doIt.
	self assert: world turtles size equals: 1
]

{ #category : 'tests' }
BoMicroPlaygroundTest >> testDoItWithoutSelectionRunsTheWholeScript [

	playground codePane text: '| caro |
caro := BoTurtle new.
caro go: 100.'.
	playground codePane moveCursorTo: 30.
	playground doIt.
	self assert: playground message equals: world turtles first printString.
	self assert: world turtles size equals: 1.
	self assert: world trails size equals: 1
]

{ #category : 'tests' }
BoMicroPlaygroundTest >> testDockedWindowCannotBeResized [

	| flap |
	flap := BoFlap new.
	playground dockIn: flap.
	self deny: playground isResizable.
	self deny: playground window expandButton isEnabled.
	self assert: playground window topBarElement isEnabled.
	playground openIn: world at: 10 @ 20.
	self assert: playground isResizable.
	self assert: playground window expandButton isEnabled
]

{ #category : 'tests' }
BoMicroPlaygroundTest >> testErrorWhileRunningIsShown [

	playground codePane text: '1 / 0'.
	self assert: playground doItAll isNil.
	self assert: playground codePane showsError.
	self assert: (playground message includesSubstring: 'ZeroDivide')
]

{ #category : 'tests' }
BoMicroPlaygroundTest >> testMessagesAreNotSentToTheWorld [
	"Unlike in the talk bubbles, the script is plain Smalltalk: a message without receiver is not sent to the world"

	playground codePane text: 'newTurtle'.
	self assert: playground doItAll isNil.
	self assert: (playground message includesSubstring: 'newTurtle').
	self assert: world turtles isEmpty
]

{ #category : 'tests' }
BoMicroPlaygroundTest >> testPlainScriptAddsTheTurtlesToTheWorld [

	playground codePane text: '| caro | caro := BoTurtle new. caro go: 100.'.
	playground doItAll.
	self assert: world turtles size equals: 1.
	self assert: world turtles first parent identicalTo: world.
	self assert: world trails size equals: 1.
	self deny: (world talkEnvironment hasBindingOf: 'caro')
]

{ #category : 'tests' }
BoMicroPlaygroundTest >> testResultIsShown [

	playground codePane text: '3 + 4'.
	self assert: playground doItAll equals: 7.
	self assert: playground message equals: '7'.
	self deny: playground codePane showsError
]

{ #category : 'tests' }
BoMicroPlaygroundTest >> testScriptsAreRememberedInTheHistoryOfTheWorld [

	playground codePane text: 'BoTurtle new'.
	playground doItAll.
	self assert: (world talkEnvironment historyFor: world) equals: #( 'BoTurtle new' )
]

{ #category : 'tests' }
BoMicroPlaygroundTest >> testSelfIsTheWorld [
	"A turtle that the world creates is added once"

	playground codePane text: 'self newTurtle'.
	playground doItAll.
	self assert: world turtles size equals: 1
]

{ #category : 'tests' }
BoMicroPlaygroundTest >> testSuccessClearsTheError [

	playground codePane text: '1 / 0'.
	playground doItAll.
	playground codePane text: '1 / 1'.
	playground doItAll.
	self deny: playground codePane showsError
]

{ #category : 'tests' }
BoMicroPlaygroundTest >> testTurtlesCreatedOutsideAScriptAreInNoWorld [

	playground codePane text: 'BoTurtle new'.
	playground doItAll.
	self assert: BoCurrentWorld value isNil.
	self deny: BoTurtle new hasParent.
	self assert: world turtles size equals: 1
]

{ #category : 'tests' }
BoMicroPlaygroundTest >> testTwoPlaygroundsCanBeDockedInTheSameFlap [

	| flap other |
	flap := BoFlap new.
	other := BoMicroPlayground on: world.
	playground dockIn: flap.
	other dockIn: flap.
	self assert: flap contents equals: {
			playground window.
			other window }.
	self assert: playground flap identicalTo: flap.
	self assert: other flap identicalTo: flap
]

{ #category : 'tests' }
BoMicroPlaygroundTest >> testVariablesAreSharedWithTheBubbles [

	world talkEnvironment declare: 'pica'.
	(world talkEnvironment bindingOf: 'pica') value: world newTurtle.
	playground codePane text: 'pica go: 100'.
	playground doItAll.
	self assert: world trails size equals: 1
]

{ #category : 'tests' }
BoMicroPlaygroundTest >> testWindowCanBeDockedInAFlapOrPlacedInTheWorld [

	| flap |
	flap := BoFlap new.
	playground dockIn: flap.
	self assert: playground window parent equals: flap pane.
	self assert: playground isInFlap.
	self assert: playground flap identicalTo: flap.
	playground openIn: world at: 10 @ 20.
	self assert: playground window parent equals: world.
	self deny: playground isInFlap.
	self assert: playground window constraints position equals: 10 @ 20.
	self assert: flap pane children isEmpty
]

{ #category : 'tests' }
BoMicroPlaygroundTest >> testWindowIsASpecWindow [

	self assert: (playground windowPresenter isKindOf: SpWindowPresenter).
	self assert: playground windowPresenter presenter identicalTo: playground.
	self assert: playground windowPresenter adapter widget identicalTo: playground window.
	self assert: (playground window isKindOf: ToInnerWindow).
	self assert: playground windowPresenter title equals: playground windowTitle
]

{ #category : 'tests' }
BoMicroPlaygroundTest >> testWindowIsTitled [

	self assert: playground window title equals: 'Bot Playground'
]

{ #category : 'private' }
BoMicroPlaygroundTest >> wait: aDuration until: aBlock [

	| deadline |
	deadline := DateAndTime now + aDuration.
	[ aBlock value or: [ DateAndTime now > deadline ] ] whileFalse: [ 10 milliSeconds wait ]
]
