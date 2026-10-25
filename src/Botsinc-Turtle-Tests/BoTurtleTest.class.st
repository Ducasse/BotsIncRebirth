Class {
	#name : 'BoTurtleTest',
	#superclass : 'TestCase',
	#instVars : [
		'world',
		'turtle'
	],
	#category : 'Botsinc-Turtle-Tests',
	#package : 'Botsinc-Turtle-Tests'
}

{ #category : 'running' }
BoTurtleTest >> setUp [
	super setUp.
	world := BoTurtleWorld new.
	turtle := world newTurtle
]

{ #category : 'tests' }
BoTurtleTest >> testAngleToBeInPosition [
	turtle east.
	self assert: (turtle angleToPointInDirection: 45) equals: 45.
	self assert: (turtle angleToPointInDirection: -45) equals: -45.
	self assert: (turtle angleToPointInDirection: 0) equals: 0.
	self assert: (turtle angleToPointInDirection: 90) equals: 90.
	self assert: (turtle angleToPointInDirection: 180) equals: 180.
	turtle north.
	self assert: (turtle angleToPointInDirection: 135) equals: 45.
	self assert: (turtle angleToPointInDirection: 45) equals: -45.
	self assert: (turtle angleToPointInDirection: 225) equals: 135.
	turtle west.
	self assert: (turtle angleToPointInDirection: 135) equals: -45.
	self assert: (turtle angleToPointInDirection: 225) equals: 45.
	turtle east.
	self assert: (turtle angleToPointInDirection: 179) equals: 179.
	self assert: (turtle angleToPointInDirection: 181) equals: -179.
	self assert: (turtle angleToPointInDirection: -179) equals: -179.
	self assert: (turtle angleToPointInDirection: -181) equals: 179
]

{ #category : 'tests' }
BoTurtleTest >> testAngleToPointAt [
	turtle jumpTo: 100 @ 100.
	turtle east.
	self assert: (turtle absoluteAngleToPointAt: 200 @ 0) equals: 45.
	self assert: (turtle angleToPointAt: 200 @ 0) equals: 45.
	turtle north.
	self assert: (turtle absoluteAngleToPointAt: 200 @ 0) equals: 45.
	self assert: (turtle angleToPointAt: 200 @ 0) equals: -45.
	self assert: (turtle absoluteAngleToPointAt: 100 @ 200) equals: -90.
	self assert: (turtle angleToPointAt: 100 @ 200) equals: -180.
	self assert: (turtle absoluteAngleToPointAt: 0 @ 200) equals: 225.
	self assert: (turtle angleToPointAt: 0 @ 200) equals: 135.
	self assert: (turtle angleToPointAt: 100 @ 100) equals: -90
]

{ #category : 'tests' }
BoTurtleTest >> testCanonicalAngle [
	self assert: (turtle canonicalAngle: 45) equals: 45.
	self assert: (turtle canonicalAngle: -45) equals: -45.
	self assert: (turtle canonicalAngle: 0) equals: 0.
	self assert: (turtle canonicalAngle: 90) equals: 90.
	self assert: (turtle canonicalAngle: 180) equals: 180.
	self assert: (turtle canonicalAngle: 225) equals: -135.
	self assert: (turtle canonicalAngle: 179) equals: 179.
	self assert: (turtle canonicalAngle: 181) equals: -179.
	self assert: (turtle canonicalAngle: -179) equals: -179.
	self assert: (turtle canonicalAngle: -181) equals: 179
]

{ #category : 'tests' }
BoTurtleTest >> testCenterAndPosition [
	"The pen of a turtle is at its center, the position of an element is its top left corner"

	turtle jumpTo: 100 @ 100.
	self assert: turtle center equals: 100 @ 100.
	self assert: turtle constraints position equals: 75 @ 75
]

{ #category : 'tests' }
BoTurtleTest >> testDirectionToPointAt [
	turtle jumpTo: 100 @ 100.
	self assert: (turtle absoluteAngleToPointAt: 200 @ 0) equals: 45.
	self assert: (turtle absoluteAngleToPointAt: 200 @ 200) equals: -45.
	self assert: (turtle absoluteAngleToPointAt: 100 @ 0) equals: 90.
	self assert: (turtle absoluteAngleToPointAt: 200 @ 100) equals: 0.
	self assert: (turtle absoluteAngleToPointAt: 0 @ 100) equals: 180.
	self assert: (turtle absoluteAngleToPointAt: 0 @ 0) equals: 135.
	self assert: (turtle absoluteAngleToPointAt: 0 @ 200) equals: 225
]

{ #category : 'tests' }
BoTurtleTest >> testDistance [
	turtle jumpTo: 100 @ 100.
	self assert: (turtle distanceFrom: 140 @ 130) equals: 50
]

{ #category : 'tests' }
BoTurtleTest >> testGoLeavesATrail [
	turtle jumpTo: 100 @ 100.
	turtle east.
	turtle go: 50.
	self assert: turtle center equals: 150 @ 100.
	self assert: world trails size equals: 1.
	turtle north.
	turtle go: 30.
	self assert: turtle center equals: 150 @ 70.
	self assert: world trails size equals: 2
]

{ #category : 'tests' }
BoTurtleTest >> testHome [
	self assert: turtle center equals: world startingPlace.
	turtle jumpTo: 10 @ 10.
	turtle home.
	self assert: turtle center equals: world startingPlace
]

{ #category : 'tests' }
BoTurtleTest >> testJumpLeavesNoTrail [
	turtle jumpTo: 100 @ 100.
	turtle west.
	turtle jump: 50.
	self assert: turtle center equals: 50 @ 100.
	self assert: world trails isEmpty
]

{ #category : 'tests' }
BoTurtleTest >> testLooks [
	turtle lookLikeCircle.
	self assert: turtle children size equals: 2.
	turtle lookLikeTriangle.
	self assert: turtle children size equals: 1.
	turtle lookLikeBot.
	self assert: turtle children size equals: 6
]

{ #category : 'tests' }
BoTurtleTest >> testMemorizedPoints [
	turtle jumpTo: 10 @ 20.
	turtle rememberPosition.
	turtle jumpTo: 30 @ 40.
	turtle rememberPosition.
	self assert: turtle memorizedPoints asArray equals: { 10 @ 20. 30 @ 40 }.
	turtle resetMemorizedPoints.
	self assert: turtle memorizedPoints isEmpty
]

{ #category : 'tests' }
BoTurtleTest >> testPointingAt [
	turtle jumpTo: 100 @ 100.
	turtle pointAt: 200 @ 0.
	self assert: turtle direction equals: 45.
	turtle pointAt: 200 @ 200.
	self assert: turtle direction equals: -45.
	turtle pointAt: 100 @ 0.
	self assert: turtle direction equals: 90.
	turtle pointAt: 200 @ 100.
	self assert: turtle direction equals: 0.
	turtle pointAt: 0 @ 100.
	self assert: turtle direction equals: 180.
	turtle pointAt: 0 @ 0.
	self assert: turtle direction equals: 135.
	turtle pointAt: 0 @ 200.
	self assert: turtle direction equals: -135
]

{ #category : 'tests' }
BoTurtleTest >> testSquareComesBack [
	turtle jumpTo: 100 @ 100.
	4 timesRepeat: [ turtle go: 80; turnLeft: 90 ].
	self assert: turtle center equals: 100 @ 100.
	self assert: turtle direction equals: 0.
	self assert: world trails size equals: 4.
	world clearTrails.
	self assert: world trails isEmpty
]

{ #category : 'tests' }
BoTurtleTest >> testTurn [
	turtle east.
	turtle turnLeft: 90.
	self assert: turtle direction equals: 90.
	turtle turnRight: 180.
	self assert: turtle direction equals: -90.
	turtle turn: 270.
	self assert: turtle direction equals: 180
]

{ #category : 'tests' }
BoTurtleTest >> testVariables [
	self deny: (turtle isVariableDefined: #side).
	turtle set: #side to: 40.
	self assert: (turtle isVariableDefined: #side).
	self assert: (turtle valueOf: #side) equals: 40.
	self should: [ turtle valueOf: #missing ] raise: Error
]

{ #category : 'tests' }
BoTurtleTest >> testWorldTurtles [
	| second |
	second := world newTurtle.
	self assert: world turtles asArray equals: { turtle. second }.
	world removeTurtles.
	self assert: world turtles isEmpty
]
