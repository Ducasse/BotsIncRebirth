"
I test the bubbles in a world opened in a space, by simulating clicks and keys. The space is closed in tearDown.
"
Class {
	#name : 'BoSpeechBubbleLiveTest',
	#superclass : 'TestCase',
	#instVars : [
		'world',
		'turtle',
		'space'
	],
	#category : 'Botsinc-Talk-Tests',
	#package : 'Botsinc-Talk-Tests'
}

{ #category : 'helpers' }
BoSpeechBubbleLiveTest >> bubble [
	^ world talkBubbles first

]

{ #category : 'helpers' }
BoSpeechBubbleLiveTest >> clickAt: aPoint [
	"Wait first, otherwise two clicks make a double click"

	(Delay forMilliseconds: 600) wait.
	world eventSimulator events: {
		(BlMouseDownEvent primary position: aPoint; yourself).
		(BlMouseUpEvent primary position: aPoint; yourself) }

]

{ #category : 'helpers' }
BoSpeechBubbleLiveTest >> clickOnTurtle [
	self clickAt: turtle bounds inSpace bounds center

]

{ #category : 'helpers' }
BoSpeechBubbleLiveTest >> press: aKeyboardKey [
	self bubble editor eventSimulator keyPress: aKeyboardKey

]

{ #category : 'running' }
BoSpeechBubbleLiveTest >> setUp [
	super setUp.
	world := BoTurtleWorld new.
	turtle := world newTurtle.
	space := BlSpace new.
	space extent: 800 @ 600.
	space root addChild: world.
	space show.
	space settle.
	(Delay forMilliseconds: 300) wait.
	space settle

]

{ #category : 'running' }
BoSpeechBubbleLiveTest >> tearDown [
	space close.
	super tearDown

]

{ #category : 'tests' }
BoSpeechBubbleLiveTest >> testAnimatedTurtleBubbleWaitsAndFollowsTheTurtle [

	| animated start |
	animated := world newAnimatedTurtle.
	animated
		speed: 600;
		jumpTo: 200 @ 300;
		east.
	space settle.
	turtle := animated.
	self clickOnTurtle.
	start := self bubble position.
	self type: 'go: 200'.
	self press: KeyboardKey enter.
	self assert: self bubble isRunning.
	self waitUntil: [ self bubble position x > start x ].
	self waitUntil: [ world talkBubbles isEmpty ].
	self assert: animated center equals: 400 @ 300
]

{ #category : 'tests' }
BoSpeechBubbleLiveTest >> testClickOnBackgroundTalksToTheWorld [
	self clickAt: 100 @ 500.
	self assert: world talkBubbles size equals: 1.
	self assert: self bubble receiver identicalTo: world.
	self type: 'newTurtle'.
	self press: KeyboardKey enter.
	self assert: world turtles size equals: 2

]

{ #category : 'tests' }
BoSpeechBubbleLiveTest >> testClickOnTurtleOpensBubbleAboveIt [
	self clickOnTurtle.
	self assert: world talkBubbles size equals: 1.
	self assert: self bubble receiver identicalTo: turtle.
	self assert: self bubble bounds inSpace bottom <= turtle bounds inSpace top.
	self assert: (self bubble editor focusHolder hasFocus)

]

{ #category : 'tests' }
BoSpeechBubbleLiveTest >> testClickWhileABubbleIsOpenClosesIt [
	self clickOnTurtle.
	self clickAt: 100 @ 500.
	self assert: world talkBubbles isEmpty

]

{ #category : 'tests' }
BoSpeechBubbleLiveTest >> testEnterSendsTheMessage [
	self clickOnTurtle.
	self type: 'go: 100'.
	self press: KeyboardKey enter.
	self assert: turtle center equals: world startingPlace + (100 @ 0).
	self assert: world talkBubbles isEmpty

]

{ #category : 'tests' }
BoSpeechBubbleLiveTest >> testErrorOfAnimatedTurtleIsShown [

	| animated bubble |
	animated := world newAnimatedTurtle.
	animated jumpTo: 200 @ 300.
	space settle.
	turtle := animated.
	self clickOnTurtle.
	bubble := self bubble.
	self type: 'go: 10; goo: 10'.
	self press: KeyboardKey enter.
	self waitUntil: [ bubble hasError ].
	self deny: bubble isRunning.
	self deny: bubble isClosed.
	self assert: (bubble messageText includesSubstring: 'goo:')
]

{ #category : 'tests' }
BoSpeechBubbleLiveTest >> testErrorThenTypingClearsTheError [
	| bubble |
	self clickOnTurtle.
	bubble := self bubble.
	self type: 'goo: 100'.
	self press: KeyboardKey enter.
	self assert: bubble hasError.
	self deny: bubble isClosed.
	self type: 'x'.
	self deny: bubble hasError

]

{ #category : 'tests' }
BoSpeechBubbleLiveTest >> testEscapeClosesTheBubble [
	self clickOnTurtle.
	self type: 'go: 100'.
	self press: KeyboardKey escape.
	self assert: world talkBubbles isEmpty.
	self assert: turtle center equals: world startingPlace

]

{ #category : 'tests' }
BoSpeechBubbleLiveTest >> testShiftEnterAddsALine [
	self clickOnTurtle.
	self type: 'go: 10.'.
	self bubble editor eventSimulator
		shiftDown;
		keyPress: KeyboardKey enter;
		shiftUp.
	self type: 'turn: 90'.
	self assert: self bubble isMultiLine.
	self assert: turtle center equals: world startingPlace.
	self press: KeyboardKey enter.
	self assert: turtle center equals: world startingPlace + (10 @ 0).
	self assert: turtle direction equals: 90

]

{ #category : 'tests' }
BoSpeechBubbleLiveTest >> testUpArrowRecallsThePreviousMessage [
	self clickOnTurtle.
	self type: 'go: 100'.
	self press: KeyboardKey enter.
	self clickOnTurtle.
	self press: KeyboardKey up.
	self assert: self bubble text equals: 'go: 100'

]

{ #category : 'helpers' }
BoSpeechBubbleLiveTest >> type: aString [
	self bubble editor eventSimulator textInput: aString

]

{ #category : 'helpers' }
BoSpeechBubbleLiveTest >> waitUntil: aBlock [
	| deadline |
	deadline := Time millisecondClockValue + 5000.
	[ aBlock value or: [ Time millisecondClockValue > deadline ] ] whileFalse: [
		(Delay forMilliseconds: 20) wait ].
	self assert: aBlock value

]
