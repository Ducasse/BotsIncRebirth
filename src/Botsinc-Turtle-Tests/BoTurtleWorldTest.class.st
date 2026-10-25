"
I test a world with several turtles: they are independent, they share the trails of the world and they can refer to each other.
"
Class {
	#name : 'BoTurtleWorldTest',
	#superclass : 'TestCase',
	#instVars : [
		'world',
		'caro',
		'bob'
	],
	#category : 'Botsinc-Turtle-Tests',
	#package : 'Botsinc-Turtle-Tests'
}

{ #category : 'running' }
BoTurtleWorldTest >> setUp [
	super setUp.
	world := BoTurtleWorld new.
	caro := world newTurtle.
	bob := world newTurtle
]

{ #category : 'tests - mixing' }
BoTurtleWorldTest >> testAnimatedAndPlainTurtlesShareAWorld [
	| ani |
	ani := world newAnimatedTurtle.
	self assert: world turtles size equals: 3.
	ani penColor: Color green.
	ani goTo: 500 @ 300.
	caro go: 10.
	self assert: ani center equals: 500 @ 300.
	self assert: world trails size equals: 2.
	self assert: world trails first border paint color equals: Color green
]

{ #category : 'tests - trails' }
BoTurtleWorldTest >> testClearTrailsKeepsTurtles [
	caro go: 50.
	bob west; go: 50.
	world clearTrails.
	self assert: world trails isEmpty.
	self assert: world turtles asArray equals: { caro. bob }.
	self assert: caro center equals: world startingPlace + (50 @ 0).
	self assert: bob center equals: world startingPlace - (50 @ 0)
]

{ #category : 'tests - relations' }
BoTurtleWorldTest >> testDistanceBetweenTurtles [
	caro jumpTo: 100 @ 100.
	bob jumpTo: 130 @ 140.
	self assert: (caro distanceFrom: bob center) equals: 50.
	self assert: (bob distanceFrom: caro center) equals: 50
]

{ #category : 'tests - relations' }
BoTurtleWorldTest >> testFollower [
	"bob follows caro: at each step caro goes forward by 20 and bob goes half the way to her. The distance between them goes from 100 to 20, where it stays since bob then catches up with what caro just did"

	caro jumpTo: 100 @ 100; east.
	bob jumpTo: 100 @ 200.
	10 timesRepeat: [
		caro go: 20.
		bob pointAt: caro center.
		bob go: (bob distanceFrom: caro center) / 2 ].
	self assert: ((bob distanceFrom: caro center) between: 19 and: 21).
	self assert: bob center x > 100.
	self assert: world trails size equals: 20
]

{ #category : 'tests - ordering' }
BoTurtleWorldTest >> testForegroundBringsTurtleToFront [
	self assert: (world childIndexOf: caro) < (world childIndexOf: bob).
	caro foreground.
	self assert: (world childIndexOf: caro) > (world childIndexOf: bob).
	self assert: world turtles asArray equals: { caro. bob }
]

{ #category : 'tests - relations' }
BoTurtleWorldTest >> testGoToAnotherTurtle [
	caro jumpTo: 100 @ 100.
	bob jumpTo: 100 @ 300.
	caro goTo: bob center.
	self assert: caro center equals: bob center.
	self assert: caro direction equals: -90.
	self assert: world trails size equals: 1
]

{ #category : 'tests - independence' }
BoTurtleWorldTest >> testLooksAreIndependent [
	caro lookLikeTriangle; color: Color orange.
	self assert: caro children size equals: 1.
	self assert: bob children size equals: 6.
	self assert: caro color equals: Color orange.
	self deny: bob color equals: Color orange
]

{ #category : 'tests - independence' }
BoTurtleWorldTest >> testMemorizedPointsAreIndependent [
	caro jumpTo: 10 @ 10; rememberPosition.
	bob jumpTo: 20 @ 20; rememberPosition; jumpTo: 30 @ 30; rememberPosition.
	self assert: caro memorizedPoints asArray equals: { 10 @ 10 }.
	self assert: bob memorizedPoints asArray equals: { 20 @ 20. 30 @ 30 }
]

{ #category : 'tests - independence' }
BoTurtleWorldTest >> testMovingOneTurtleDoesNotMoveTheOther [
	caro jumpTo: 100 @ 100; east.
	caro go: 50.
	self assert: caro center equals: 150 @ 100.
	self assert: bob center equals: world startingPlace.
	self assert: bob direction equals: 0.
	bob north; go: 30.
	self assert: bob center equals: world startingPlace - (0 @ 30).
	self assert: caro center equals: 150 @ 100.
	self assert: caro direction equals: 0
]

{ #category : 'tests - creation' }
BoTurtleWorldTest >> testNewTurtlesStartAtCenterHeadingEast [
	self assert: world turtles asArray equals: { caro. bob }.
	world turtles do: [ :each |
		self assert: each center equals: world startingPlace.
		self assert: each direction equals: 0.
		self assert: each turtleWorld equals: world ]
]

{ #category : 'tests - independence' }
BoTurtleWorldTest >> testPensAreIndependent [
	| trails |
	caro penColor: Color red; penSize: 3.
	bob penColor: Color blue; penSize: 1.
	caro go: 40.
	bob north; go: 40.
	trails := world trails.
	self assert: trails size equals: 2.
	self assert: trails first border paint color equals: Color red.
	self assert: trails first border width equals: 3.
	self assert: trails second border paint color equals: Color blue.
	self assert: trails second border width equals: 1
]

{ #category : 'tests - relations' }
BoTurtleWorldTest >> testPointAtAnotherTurtle [
	caro jumpTo: 100 @ 100.
	bob jumpTo: 200 @ 0.
	caro pointAt: bob center.
	self assert: caro direction equals: 45.
	bob pointAt: caro center.
	self assert: bob direction equals: -135
]

{ #category : 'tests - removing' }
BoTurtleWorldTest >> testRemoveAllTurtles [
	world newTurtle.
	self assert: world turtles size equals: 3.
	world removeTurtles.
	self assert: world turtles isEmpty.
	"only the trail layer is left"
	self assert: world children size equals: 1
]

{ #category : 'tests - removing' }
BoTurtleWorldTest >> testRemoveOneTurtle [
	caro go: 50.
	world removeTurtle: caro.
	self assert: world turtles asArray equals: { bob }.
	self deny: caro hasParent.
	self assert: caro turtleWorld isNil.
	self assert: bob turtleWorld equals: world.
	self assert: world trails size equals: 1
]

{ #category : 'tests - removing' }
BoTurtleWorldTest >> testRemovedTurtleDoesNotDrawInTheWorld [
	world removeTurtle: caro.
	caro go: 50.
	self assert: world trails isEmpty.
	bob go: 50.
	self assert: world trails size equals: 1
]

{ #category : 'tests - trails' }
BoTurtleWorldTest >> testTrailsAreBehindTurtles [
	"The trail layer is the first child of the world, so it is drawn before the turtles"

	caro go: 50.
	bob go: 50.
	self assert: world children first children asArray equals: world trails asArray.
	world turtles do: [ :each | self assert: (world childIndexOf: each) > 1 ]
]

{ #category : 'tests - trails' }
BoTurtleWorldTest >> testTrailsOfAllTurtlesAccumulate [
	caro jumpTo: 100 @ 100; east.
	bob jumpTo: 300 @ 100; east.
	4 timesRepeat: [
		caro go: 50; turnLeft: 90.
		bob go: 50; turnRight: 90 ].
	self assert: world trails size equals: 8.
	self assert: caro center equals: 100 @ 100.
	self assert: bob center equals: 300 @ 100
]

{ #category : 'tests - independence' }
BoTurtleWorldTest >> testTurningOneTurtleDoesNotTurnTheOther [
	caro turnLeft: 90.
	bob turnRight: 45.
	self assert: caro direction equals: 90.
	self assert: bob direction equals: -45
]

{ #category : 'tests - independence' }
BoTurtleWorldTest >> testVariablesAreIndependent [
	caro set: #side to: 40.
	bob set: #side to: 70.
	self assert: (caro valueOf: #side) equals: 40.
	self assert: (bob valueOf: #side) equals: 70.
	caro set: #name to: #caro.
	self deny: (bob isVariableDefined: #name)
]
