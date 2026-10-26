"
I test the micro workspace on a world that is not displayed, so that the scripts run at once.
"
Class {
	#name : 'BoMicroWorkspaceTest',
	#superclass : 'TestCase',
	#instVars : [
		'world',
		'workspace'
	],
	#category : 'Botsinc-Micro-Tests',
	#package : 'Botsinc-Micro-Tests'
}

{ #category : 'running' }
BoMicroWorkspaceTest >> setUp [

	super setUp.
	world := BoTurtleWorld new.
	workspace := BoMicroWorkspace on: world
]

{ #category : 'tests' }
BoMicroWorkspaceTest >> testAnimateRunsTheScriptInItsOwnProcess [

	| process |
	workspace codePane text: 'BoAnimatedTurtle new go: 10'.
	process := workspace animate.
	self deny: process == Processor activeProcess.
	self wait: 2 seconds until: [ process isTerminated ].
	self assert: world turtles size equals: 1
]

{ #category : 'tests' }
BoMicroWorkspaceTest >> testBuiltWorkspaceShowsTheResult [
	"The workspace is built with the Toplo backend, as when it is shown"

	workspace build.
	workspace codePane text: '3 + 4'.
	workspace doItAll.
	self assert: workspace message equals: '7'
]

{ #category : 'tests' }
BoMicroWorkspaceTest >> testClearAll [

	world newTurtle go: 100.
	workspace clearAll.
	self assert: world turtles isEmpty.
	self assert: world trails isEmpty
]

{ #category : 'tests' }
BoMicroWorkspaceTest >> testClearTrailsKeepsTheTurtles [

	world newTurtle go: 100.
	workspace clearTrails.
	self assert: world turtles size equals: 1.
	self assert: world trails isEmpty
]

{ #category : 'tests' }
BoMicroWorkspaceTest >> testCompilationErrorIsShown [

	workspace codePane text: 'pica := 3 +'.
	self assert: workspace doItAll isNil.
	self assert: workspace codePane showsError.
	self deny: workspace message isEmpty.
	self deny: (world talkEnvironment hasBindingOf: 'pica')
]

{ #category : 'tests' }
BoMicroWorkspaceTest >> testDoItAllRunsTheScriptOnTheWorld [

	workspace codePane text: 'pica := self newTurtle.
pica go: 100'.
	workspace doItAll.
	self assert: world turtles size equals: 1.
	self assert: (world talkEnvironment valueOf: 'pica') equals: world turtles first.
	self assert: world trails size equals: 1
]

{ #category : 'tests' }
BoMicroWorkspaceTest >> testDoItRunsTheSelection [

	workspace codePane text: 'BoTurtle new. BoTurtle new'.
	workspace codePane selectFrom: 1 to: 12.
	workspace doIt.
	self assert: world turtles size equals: 1
]

{ #category : 'tests' }
BoMicroWorkspaceTest >> testDoItWithoutSelectionRunsTheWholeScript [

	workspace codePane text: '| caro |
caro := BoTurtle new.
caro go: 100.'.
	workspace codePane moveCursorTo: 30.
	workspace doIt.
	self assert: workspace message equals: world turtles first printString.
	self assert: world turtles size equals: 1.
	self assert: world trails size equals: 1
]

{ #category : 'tests' }
BoMicroWorkspaceTest >> testDockedWindowCannotBeResized [

	| flap |
	flap := BoFlap new.
	workspace dockIn: flap.
	self deny: workspace isResizable.
	self deny: workspace window expandButton isEnabled.
	self assert: workspace window topBarElement isEnabled.
	workspace openIn: world at: 10 @ 20.
	self assert: workspace isResizable.
	self assert: workspace window expandButton isEnabled
]

{ #category : 'tests' }
BoMicroWorkspaceTest >> testErrorWhileRunningIsShown [

	workspace codePane text: '1 / 0'.
	self assert: workspace doItAll isNil.
	self assert: workspace codePane showsError.
	self assert: (workspace message includesSubstring: 'ZeroDivide')
]

{ #category : 'tests' }
BoMicroWorkspaceTest >> testMessagesAreNotSentToTheWorld [
	"Unlike in the talk bubbles, the script is plain Smalltalk: a message without receiver is not sent to the world"

	workspace codePane text: 'newTurtle'.
	self assert: workspace doItAll isNil.
	self assert: (workspace message includesSubstring: 'newTurtle').
	self assert: world turtles isEmpty
]

{ #category : 'tests' }
BoMicroWorkspaceTest >> testPlainScriptAddsTheTurtlesToTheWorld [

	workspace codePane text: '| caro | caro := BoTurtle new. caro go: 100.'.
	workspace doItAll.
	self assert: world turtles size equals: 1.
	self assert: world turtles first parent identicalTo: world.
	self assert: world trails size equals: 1.
	self deny: (world talkEnvironment hasBindingOf: 'caro')
]

{ #category : 'tests' }
BoMicroWorkspaceTest >> testResultIsShown [

	workspace codePane text: '3 + 4'.
	self assert: workspace doItAll equals: 7.
	self assert: workspace message equals: '7'.
	self deny: workspace codePane showsError
]

{ #category : 'tests' }
BoMicroWorkspaceTest >> testScriptsAreRememberedInTheHistoryOfTheWorld [

	workspace codePane text: 'BoTurtle new'.
	workspace doItAll.
	self assert: (world talkEnvironment historyFor: world) equals: #( 'BoTurtle new' )
]

{ #category : 'tests' }
BoMicroWorkspaceTest >> testSelfIsTheWorld [
	"A turtle that the world creates is added once"

	workspace codePane text: 'self newTurtle'.
	workspace doItAll.
	self assert: world turtles size equals: 1
]

{ #category : 'tests' }
BoMicroWorkspaceTest >> testSuccessClearsTheError [

	workspace codePane text: '1 / 0'.
	workspace doItAll.
	workspace codePane text: '1 / 1'.
	workspace doItAll.
	self deny: workspace codePane showsError
]

{ #category : 'tests' }
BoMicroWorkspaceTest >> testTurtlesCreatedOutsideAScriptAreInNoWorld [

	workspace codePane text: 'BoTurtle new'.
	workspace doItAll.
	self assert: BoCurrentWorld value isNil.
	self deny: BoTurtle new hasParent.
	self assert: world turtles size equals: 1
]

{ #category : 'tests' }
BoMicroWorkspaceTest >> testTwoWorkspacesCanBeDockedInTheSameFlap [

	| flap other |
	flap := BoFlap new.
	other := BoMicroWorkspace on: world.
	workspace dockIn: flap.
	other dockIn: flap.
	self assert: flap contents equals: {
			workspace window.
			other window }.
	self assert: workspace flap identicalTo: flap.
	self assert: other flap identicalTo: flap
]

{ #category : 'tests' }
BoMicroWorkspaceTest >> testVariablesAreSharedWithTheBubbles [

	world talkEnvironment declare: 'pica'.
	(world talkEnvironment bindingOf: 'pica') value: world newTurtle.
	workspace codePane text: 'pica go: 100'.
	workspace doItAll.
	self assert: world trails size equals: 1
]

{ #category : 'tests' }
BoMicroWorkspaceTest >> testWindowCanBeDockedInAFlapOrPlacedInTheWorld [

	| flap |
	flap := BoFlap new.
	workspace dockIn: flap.
	self assert: workspace window parent equals: flap pane.
	self assert: workspace isInFlap.
	self assert: workspace flap identicalTo: flap.
	workspace openIn: world at: 10 @ 20.
	self assert: workspace window parent equals: world.
	self deny: workspace isInFlap.
	self assert: workspace window constraints position equals: 10 @ 20.
	self assert: flap pane children isEmpty
]

{ #category : 'tests' }
BoMicroWorkspaceTest >> testWindowIsASpecWindow [

	self assert: (workspace windowPresenter isKindOf: SpWindowPresenter).
	self assert: workspace windowPresenter presenter identicalTo: workspace.
	self assert: workspace windowPresenter adapter widget identicalTo: workspace window.
	self assert: (workspace window isKindOf: ToInnerWindow).
	self assert: workspace windowPresenter title equals: workspace windowTitle
]

{ #category : 'tests' }
BoMicroWorkspaceTest >> testWindowIsTitled [

	self assert: workspace window title equals: 'Bot Workspace'
]

{ #category : 'private' }
BoMicroWorkspaceTest >> wait: aDuration until: aBlock [

	| deadline |
	deadline := DateAndTime now + aDuration.
	[ aBlock value or: [ DateAndTime now > deadline ] ] whileFalse: [ 10 milliSeconds wait ]
]
