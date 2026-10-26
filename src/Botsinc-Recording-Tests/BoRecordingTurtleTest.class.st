"
I check what a BoRecordingTurtle records: paths, moves in page coordinates, pen changes and bounds.
"
Class {
	#name : 'BoRecordingTurtleTest',
	#superclass : 'TestCase',
	#instVars : [
		'turtle'
	],
	#category : 'Botsinc-Recording-Tests',
	#package : 'Botsinc-Recording-Tests'
}

{ #category : 'running' }
BoRecordingTurtleTest >> setUp [
	super setUp.
	turtle := BoRecordingTurtleForTest new

]

{ #category : 'tests' }
BoRecordingTurtleTest >> testBoundsOfASquare [
	4 timesRepeat: [ turtle go: 100; turnLeft: 90 ].
	self assert: turtle minPoint equals: 300 @ 420.
	self assert: turtle maxPoint equals: 400 @ 520

]

{ #category : 'tests' }
BoRecordingTurtleTest >> testGoDrawsAndJumpMoves [
	turtle go: 10; jump: 10.
	self assert: (turtle log last: 2) equals: { #line -> (310 @ 420). #move -> (320 @ 420) }

]

{ #category : 'tests' }
BoRecordingTurtleTest >> testIsAbstract [
	self assert: BoRecordingTurtle isAbstract.
	self deny: BoEPSTurtle isAbstract.
	self should: [ BoRecordingTurtle new ] raise: SubclassResponsibility

]

{ #category : 'tests' }
BoRecordingTurtleTest >> testPenChangeStartsANewPath [
	turtle go: 10.
	turtle penSize: 3.
	turtle penColor: Color red.
	self
		assert: (turtle log allButFirst: 3)
		equals: { #end. #start. #move -> (310 @ 420). #end. #start. #move -> (310 @ 420) }

]

{ #category : 'tests' }
BoRecordingTurtleTest >> testRecordingStartsWithAPathAtThePageCenter [
	self assert: turtle log equals: { #start. #move -> (300 @ 420) }

]

{ #category : 'tests' }
BoRecordingTurtleTest >> testYAxisGoesUp [
	turtle north; go: 10.
	self assert: turtle log last equals: #line -> (300 @ 430)

]
