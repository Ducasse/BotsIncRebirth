"
I test animated turtles in a world opened in a real window, since animation only happens when a turtle is displayed. The window is closed in tearDown.
"
Class {
	#name : 'BoAnimatedTurtleLiveTest',
	#superclass : 'TestCase',
	#instVars : [
		'world',
		'processes',
		'space'
	],
	#category : 'Botsinc-Turtle-Tests',
	#package : 'Botsinc-Turtle-Tests'
}

{ #category : 'helpers' }
BoAnimatedTurtleLiveTest >> animate: aTurtle with: aBlock [
	^ processes add: (aTurtle animate: aBlock)
]

{ #category : 'helpers' }
BoAnimatedTurtleLiveTest >> newTurtle [
	"A fast turtle, so that the tests do not last too long"

	^ world newAnimatedTurtle
		speed: 1500;
		yourself
]

{ #category : 'running' }
BoAnimatedTurtleLiveTest >> setUp [
	super setUp.
	processes := OrderedCollection new.
	world := BoTurtleWorld new.
	world openInSpace.
	space := world space.
	self waitUntil: [ space isOpened ]
]

{ #category : 'running' }
BoAnimatedTurtleLiveTest >> tearDown [
	processes do: [ :each | each isTerminated ifFalse: [ each terminate ] ].
	space ifNotNil: [ space close ].
	super tearDown
]

{ #category : 'tests' }
BoAnimatedTurtleLiveTest >> testJumpToHeadsBeforeMoving [
	"The turtle turns in place toward the target, then moves"

	| turtle start sawTurnInPlace |
	turtle := self newTurtle.
	turtle speed: 300.
	start := turtle center.
	sawTurnInPlace := false.
	self animate: turtle with: [ :t | t jumpTo: start - (100 @ 0) ].
	[ processes first isTerminated ] whileFalse: [
		(turtle center = start and: [ turtle direction between: 1 and: 179 ])
			ifTrue: [ sawTurnInPlace := true ].
		self deny: (turtle center ~= start and: [ turtle direction ~= 180 ]).
		(Delay forMilliseconds: 10) wait ].
	self assert: sawTurnInPlace.
	self assert: turtle center equals: start - (100 @ 0).
	self assert: turtle direction equals: 180
]

{ #category : 'tests' }
BoAnimatedTurtleLiveTest >> testMovesAreStepwise [
	| turtle positions |
	turtle := self newTurtle.
	turtle speed: 300.
	positions := Set new.
	self animate: turtle with: [ :t | t go: 100 ].
	[ processes first isTerminated ] whileFalse: [
		positions add: turtle center.
		(Delay forMilliseconds: 20) wait ].
	self assert: turtle center equals: world startingPlace + (100 @ 0).
	self assert: positions size > 3.
	self assert: world trails size equals: 1
]

{ #category : 'tests' }
BoAnimatedTurtleLiveTest >> testNewTurtleAppearsAtCenterAtOnce [
	| turtle |
	turtle := self newTurtle.
	self assert: turtle center equals: world startingPlace.
	self assert: turtle direction equals: 0
]

{ #category : 'tests' }
BoAnimatedTurtleLiveTest >> testSquaresOfTwoTurtles [
	| caro bob |
	caro := self newTurtle.
	bob := self newTurtle.
	self animate: caro with: [ :t |
		t jumpTo: 200 @ 300; east.
		4 timesRepeat: [ t go: 100; turnLeft: 90 ] ].
	self animate: bob with: [ :t |
		t jumpTo: 600 @ 300; east.
		4 timesRepeat: [ t go: 100; turnRight: 90 ] ].
	self waitForScripts.
	self assert: caro center equals: 200 @ 300.
	self assert: bob center equals: 600 @ 300.
	self assert: caro direction equals: 0.
	self assert: bob direction equals: 0.
	self assert: world trails size equals: 8
]

{ #category : 'tests' }
BoAnimatedTurtleLiveTest >> testTurtleIsAnimatingWhenDisplayed [
	self assert: self newTurtle isAnimating
]

{ #category : 'tests' }
BoAnimatedTurtleLiveTest >> testTwoScriptsOfTheSameTurtleDoNotMix [
	| turtle ends |
	turtle := self newTurtle.
	ends := OrderedCollection new.
	self animate: turtle with: [ :t |
		t jumpTo: 100 @ 100; east; go: 200.
		ends add: t center ].
	self animate: turtle with: [ :t |
		t jumpTo: 100 @ 400; east; go: 200.
		ends add: t center ].
	self waitForScripts.
	self assert: ends asArray equals: { 300 @ 100. 300 @ 400 }
]

{ #category : 'tests' }
BoAnimatedTurtleLiveTest >> testTwoTurtlesRunInParallel [
	"Both turtles have moved before any of them has finished its script"

	| caro bob bothMoving |
	caro := self newTurtle.
	bob := self newTurtle.
	caro speed: 300.
	bob speed: 300.
	bothMoving := false.
	self animate: caro with: [ :t | t go: 150 ].
	self animate: bob with: [ :t | t west; go: 150 ].
	[ processes anySatisfy: [ :each | each isTerminated ] ] whileFalse: [
		(caro center ~= world startingPlace and: [ bob center ~= world startingPlace ])
			ifTrue: [ bothMoving := true ].
		(Delay forMilliseconds: 20) wait ].
	self waitForScripts.
	self assert: bothMoving.
	self assert: caro center equals: world startingPlace + (150 @ 0).
	self assert: bob center equals: world startingPlace - (150 @ 0).
	self assert: world trails size equals: 2
]

{ #category : 'helpers' }
BoAnimatedTurtleLiveTest >> waitForScripts [
	self waitUntil: [ processes allSatisfy: [ :each | each isTerminated ] ]
]

{ #category : 'helpers' }
BoAnimatedTurtleLiveTest >> waitUntil: aBlock [
	| deadline |
	deadline := Time millisecondClockValue + 5000.
	[ aBlock value ] whileFalse: [
		Time millisecondClockValue > deadline ifTrue: [ ^ self fail: 'Timeout' ].
		(Delay forMilliseconds: 20) wait ]
]
