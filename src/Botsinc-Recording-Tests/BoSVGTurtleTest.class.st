"
I check the SVG documents written by a BoSVGTurtle for simple drawings such as a square and a cross.
"
Class {
	#name : 'BoSVGTurtleTest',
	#superclass : 'TestCase',
	#instVars : [
		'turtle'
	],
	#category : 'Botsinc-Recording-Tests',
	#package : 'Botsinc-Recording-Tests'
}

{ #category : 'helpers' }
BoSVGTurtleTest >> pathsOf: aString [
	"The data of each path element"

	^ (aString lines select: [ :each | each beginsWith: '<path ' ]) asArray collect: [ :each |
		each copyFrom: (each indexOfSubCollection: 'd="') + 3 to: each size - 3 ]

]

{ #category : 'running' }
BoSVGTurtleTest >> setUp [
	super setUp.
	turtle := BoSVGTurtle new

]

{ #category : 'helpers' }
BoSVGTurtleTest >> svgElementOf: aString [
	^ aString lines detect: [ :each | each beginsWith: '<svg ' ]

]

{ #category : 'tests' }
BoSVGTurtleTest >> testCross [
	4 timesRepeat: [ turtle go: 50; jump: -50; turnLeft: 90 ].
	self
		assert: (self pathsOf: turtle document)
		equals: #( 'M 300 420 L 350 420 M 300 420 L 300 370 M 300 420 L 250 420 M 300 420 L 300 470 M 300 420' ).
	self assert: ((self svgElementOf: turtle document) endsWith: 'viewBox="240 360 120 120">')

]

{ #category : 'tests' }
BoSVGTurtleTest >> testDocumentForScriptWithTwoTurtles [
	self
		assert: (self pathsOf: (BoSVGTurtle documentForScript: '| marge daly | marge := Bot new. daly := Bot new. marge go: 100. daly north; go: 50'))
		equals: #( 'M 300 420 L 400 420' 'M 300 420 L 300 370' )

]

{ #category : 'tests' }
BoSVGTurtleTest >> testDocumentStructure [
	| lines |
	lines := turtle document lines.
	self assert: lines first equals: '<?xml version="1.0" encoding="UTF-8"?>'.
	self assert: (lines second beginsWith: '<svg xmlns="http://www.w3.org/2000/svg"').
	self assert: (lines last: 2) asArray equals: #( '</g>' '</svg>' )

]

{ #category : 'tests' }
BoSVGTurtleTest >> testNothingDrawnHasNoPath [
	turtle jump: 50.
	self assert: (self pathsOf: turtle document) isEmpty

]

{ #category : 'tests' }
BoSVGTurtleTest >> testPenChangesStartANewPathElement [
	turtle go: 10.
	turtle penSize: 3; penColor: Color red.
	turtle go: 10.
	self
		assert: (turtle document lines select: [ :each | each beginsWith: '<path ' ]) asArray
		equals: #( '<path stroke="#000000" stroke-width="1" d="M 300 420 L 310 420"/>' '<path stroke="#ff0000" stroke-width="3" d="M 310 420 L 320 420"/>' )

]

{ #category : 'tests' }
BoSVGTurtleTest >> testSquare [
	"The y axis of SVG goes down as in Bloc"

	4 timesRepeat: [ turtle go: 100; turnLeft: 90 ].
	self assert: (self pathsOf: turtle document) equals: #( 'M 300 420 L 400 420 L 400 320 L 300 320 L 300 420' ).
	self
		assert: (self svgElementOf: turtle document)
		equals: '<svg xmlns="http://www.w3.org/2000/svg" width="120pt" height="120pt" viewBox="290 310 120 120">'

]

{ #category : 'tests' }
BoSVGTurtleTest >> testWriteScriptsOfProtocol [
	| directory |
	directory := FileSystem memory / 'figures'.
	BoSVGTurtle writeScriptsOf: BoEPSScriptsForTest inProtocol: 'ChShapes' to: directory.
	self assert: (directory children collect: [ :each | each basename ]) asSet equals: #( 'cross.svg' 'square.svg' ) asSet.
	self
		assert: (directory / 'square.svg') contents
		equals: (BoSVGTurtle documentFor: [ :pica | 4 timesRepeat: [ pica go: 100; turnLeft: 90 ] ])

]
