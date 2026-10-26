"
I check the PDF documents written by a BoPDFTurtle: the page content for simple drawings and the positions of the cross-reference table.
"
Class {
	#name : 'BoPDFTurtleTest',
	#superclass : 'TestCase',
	#instVars : [
		'turtle'
	],
	#category : 'Botsinc-Recording-Tests',
	#package : 'Botsinc-Recording-Tests'
}

{ #category : 'helpers' }
BoPDFTurtleTest >> contentOf: aString [
	"The operators of the page, between stream and endstream"

	| lines |
	lines := aString lines.
	^ (lines copyFrom: (lines indexOf: 'stream') + 1 to: (lines indexOf: 'endstream') - 2) asArray

]

{ #category : 'helpers' }
BoPDFTurtleTest >> offsetsOf: aString [
	"The positions given by the cross-reference table, without the free entry"

	| lines first |
	lines := aString lines.
	first := (lines indexOf: 'xref') + 3.
	^ ((lines copyFrom: first to: (lines indexOf: 'trailer') - 1) collect: [ :each | (each first: 10) asNumber ]) asArray

]

{ #category : 'running' }
BoPDFTurtleTest >> setUp [
	super setUp.
	turtle := BoPDFTurtle new

]

{ #category : 'tests' }
BoPDFTurtleTest >> testCross [
	4 timesRepeat: [ turtle go: 50; jump: -50; turnLeft: 90 ].
	self assert: (turtle document includesSubstring: '/MediaBox [ 240 360 360 480 ]').
	self
		assert: ((self contentOf: turtle document) select: [ :each | each endsWith: ' l' ])
		equals: #( '350 420 l' '300 470 l' '250 420 l' '300 370 l' )

]

{ #category : 'tests' }
BoPDFTurtleTest >> testCrossReferenceTablePointsToTheObjects [
	"A reader finds the objects through the positions of the cross-reference table: they must be exact"

	| pdf |
	4 timesRepeat: [ turtle go: 100; turnLeft: 90 ].
	pdf := turtle document.
	(self offsetsOf: pdf) withIndexDo: [ :offset :index |
		self assert: (pdf copyFrom: offset + 1 to: offset + 7) equals: index printString , ' 0 obj' ].
	self
		assert: (pdf copyFrom: (pdf lines at: pdf lines size - 1) asNumber + 1 to: (pdf lines at: pdf lines size - 1) asNumber + 4)
		equals: 'xref'

]

{ #category : 'tests' }
BoPDFTurtleTest >> testDocumentStructure [
	| pdf |
	pdf := turtle document.
	self assert: (pdf beginsWith: '%PDF-1.4').
	self assert: (pdf lines last: 3) asArray first equals: 'startxref'.
	self assert: pdf lines last equals: '%%EOF'

]

{ #category : 'tests' }
BoPDFTurtleTest >> testPenSizeStartsANewPath [
	turtle go: 10.
	turtle penSize: 3.
	turtle go: 10.
	self
		assert: ((self contentOf: turtle document) allButFirst: 5)
		equals: #( 'S' '3 w' '0.000 0.000 0.000 RG' '310 420 m' '320 420 l' 'S' )

]

{ #category : 'tests' }
BoPDFTurtleTest >> testSquare [
	4 timesRepeat: [ turtle go: 100; turnLeft: 90 ].
	self assert: (turtle document includesSubstring: '/MediaBox [ 290 410 410 530 ]').
	self
		assert: (self contentOf: turtle document)
		equals: #( '1 J 1 j' '1 w' '0.000 0.000 0.000 RG' '300 420 m' '400 420 l' '400 520 l' '300 520 l' '300 420 l' 'S' )

]

{ #category : 'tests' }
BoPDFTurtleTest >> testStreamLength [
	| pdf length start |
	turtle go: 100.
	pdf := turtle document.
	length := ((pdf lines detect: [ :each | each beginsWith: '<< /Length ' ]) substrings at: 3) asNumber.
	start := (pdf indexOfSubCollection: 'stream' , String lf) + 7.
	self assert: (pdf copyFrom: start + length to: start + length + 9) equals: String lf , 'endstream'

]

{ #category : 'tests' }
BoPDFTurtleTest >> testWriteTo [
	| file |
	file := FileSystem memory / 'line.pdf'.
	turtle go: 100.
	turtle writeTo: file.
	self assert: file contents equals: turtle document

]
