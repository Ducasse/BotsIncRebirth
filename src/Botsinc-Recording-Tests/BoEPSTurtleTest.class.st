"
I check that a BoEPSTurtle writes the right EPS commands and bounding box for simple drawings such as a square and a cross, and that the scripts of the book can be turned into EPS documents.
"
Class {
	#name : 'BoEPSTurtleTest',
	#superclass : 'TestCase',
	#instVars : [
		'turtle'
	],
	#category : 'Botsinc-Recording-Tests',
	#package : 'Botsinc-Recording-Tests'
}

{ #category : 'helpers' }
BoEPSTurtleTest >> bodyOf: anEPSString [
	"The drawing commands, without the header nor the trailer"

	| lines |
	lines := anEPSString lines.
	^ (lines copyFrom: (lines indexOf: '1 setlinecap 1 setlinejoin') + 1 to: lines size - 2) asArray

]

{ #category : 'helpers' }
BoEPSTurtleTest >> boundingBoxOf: anEPSString [
	^ (anEPSString lines detect: [ :each | each beginsWith: '%%BoundingBox: ' ])
		allButFirst: '%%BoundingBox: ' size

]

{ #category : 'helpers' }
BoEPSTurtleTest >> drawCross [
	"Four branches of 50 starting from the center: go out then jump back"

	4 timesRepeat: [ turtle go: 50; jump: -50; turnLeft: 90 ]

]

{ #category : 'helpers' }
BoEPSTurtleTest >> drawSquare [
	4 timesRepeat: [ turtle go: 100; turnLeft: 90 ]

]

{ #category : 'helpers' }
BoEPSTurtleTest >> pathOperatorsOf: anEPSString [
	^ ((self bodyOf: anEPSString) select: [ :each | (each endsWith: 'moveto') or: [ each endsWith: 'lineto' ] ]) asArray

]

{ #category : 'running' }
BoEPSTurtleTest >> setUp [
	super setUp.
	turtle := BoEPSTurtle new

]

{ #category : 'tests' }
BoEPSTurtleTest >> testCrossBoundingBox [
	self drawCross.
	self assert: (self boundingBoxOf: turtle document) equals: '240 360 360 480'

]

{ #category : 'tests' }
BoEPSTurtleTest >> testCrossPath [
	self drawCross.
	self
		assert: (self pathOperatorsOf: turtle document)
		equals: #( '300 420 moveto'
			'350 420 lineto' '300 420 moveto'
			'300 470 lineto' '300 420 moveto'
			'250 420 lineto' '300 420 moveto'
			'300 370 lineto' '300 420 moveto' )

]

{ #category : 'tests' }
BoEPSTurtleTest >> testDocumentCanBeAskedTwice [
	"Asking for the document does not end the drawing"

	turtle go: 100.
	self assert: turtle document equals: turtle document.
	turtle turnLeft: 90; go: 100.
	self assert: (self boundingBoxOf: turtle document) equals: '290 410 410 530'

]

{ #category : 'tests' }
BoEPSTurtleTest >> testDocumentFor [
	self drawSquare.
	self
		assert: (BoEPSTurtle documentFor: [ :pica | 4 timesRepeat: [ pica go: 100; turnLeft: 90 ] ])
		equals: turtle document
]

{ #category : 'tests' }
BoEPSTurtleTest >> testDocumentForBookScript [
	"The scripts of the book create turtles with Bot new: they draw into EPS as they are"

	self drawSquare.
	self
		assert: (BoEPSTurtle documentForScript: '| pica | pica := Bot new. 4 timesRepeat: [ pica go: 100; turnLeft: 90 ]')
		equals: turtle document

]

{ #category : 'tests - chapters' }
BoEPSTurtleTest >> testDocumentForMethod [
	self drawSquare.
	self assert: (BoEPSTurtle documentForMethod: BoEPSScriptsForTest >> #square) equals: turtle document

]

{ #category : 'tests' }
BoEPSTurtleTest >> testDocumentForScriptWithTwoTurtles [
	| eps |
	eps := BoEPSTurtle documentForScript: '| marge daly | marge := Bot new. daly := BoTurtle new. marge go: 100. daly north; go: 50'.
	self assert: (self boundingBoxOf: eps) equals: '290 410 410 480'.
	self assert: (self pathOperatorsOf: eps) equals: #( '300 420 moveto' '400 420 lineto' '300 420 moveto' '300 470 lineto' )

]

{ #category : 'tests' }
BoEPSTurtleTest >> testDocumentForScriptWithoutTurtle [
	self should: [ BoEPSTurtle documentForScript: '3 + 4' ] raise: Error

]

{ #category : 'tests' }
BoEPSTurtleTest >> testDocumentStructure [
	| lines |
	lines := turtle document lines.
	self assert: lines first equals: '%!PS-Adobe-3.0 EPSF-3.0'.
	self assert: (lines second beginsWith: '%%BoundingBox: ').
	self assert: (lines includes: '%%EndComments').
	self assert: (lines last: 2) asArray equals: #( 'showpage' '%%EOF' )

]

{ #category : 'tests' }
BoEPSTurtleTest >> testJumpDoesNotDraw [
	turtle jump: 100.
	self assert: (self pathOperatorsOf: turtle document) equals: #( '300 420 moveto' '400 420 moveto' )

]

{ #category : 'tests' }
BoEPSTurtleTest >> testNothingDrawnHasAMarginAroundTheStart [
	self assert: (self boundingBoxOf: turtle document) equals: '290 410 310 430'

]

{ #category : 'tests' }
BoEPSTurtleTest >> testPenColor [
	turtle penColor: Color red.
	turtle go: 10.
	self assert: ((self bodyOf: turtle document) includes: '1.000 0.000 0.000 setrgbcolor')

]

{ #category : 'tests' }
BoEPSTurtleTest >> testPenSizeStartsANewPath [
	"The width applies to a whole path: what was drawn before keeps its width"

	turtle go: 10.
	turtle penSize: 3.
	turtle go: 10.
	self
		assert: (self bodyOf: turtle document)
		equals: #( '1 setlinewidth' '0.000 0.000 0.000 setrgbcolor' 'newpath' '300 420 moveto' '310 420 lineto' 'stroke'
			'3 setlinewidth' '0.000 0.000 0.000 setrgbcolor' 'newpath' '310 420 moveto' '320 420 lineto' 'stroke' )

]

{ #category : 'tests - chapters' }
BoEPSTurtleTest >> testScriptSourceOfMethodDropsTheSelector [
	self
		assert: (BoEPSTurtle scriptSourceOf: BoEPSScriptsForTest >> #line)
		equals: ('| pica |
	pica := BoTurtle new.
	pica go: 100' copyReplaceAll: String lf with: String cr)

]

{ #category : 'tests' }
BoEPSTurtleTest >> testScriptsDoNotChangeTheirClasses [
	"Bot is only bound while the script runs"

	BoEPSTurtle documentForScript: '| pica | pica := BoTurtle new. pica go: 10'.
	self assert: BoTurtle new class equals: BoTurtle

]

{ #category : 'tests - chapters' }
BoEPSTurtleTest >> testScriptsOfProtocolSkipMethodsWithArguments [
	self
		assert: ((BoEPSTurtle scriptsOf: BoEPSScriptsForTest inProtocol: 'ChShapes') collect: [ :each | each selector ]) asArray
		equals: #( #cross #square )

]

{ #category : 'tests' }
BoEPSTurtleTest >> testSquareBoundingBox [
	self drawSquare.
	self assert: turtle minPoint equals: 300 @ 420.
	self assert: turtle maxPoint equals: 400 @ 520.
	self assert: (self boundingBoxOf: turtle document) equals: '290 410 410 530'

]

{ #category : 'tests' }
BoEPSTurtleTest >> testSquarePath [
	self drawSquare.
	self
		assert: (self pathOperatorsOf: turtle document)
		equals: #( '300 420 moveto' '400 420 lineto' '400 520 lineto' '300 520 lineto' '300 420 lineto' )

]

{ #category : 'tests' }
BoEPSTurtleTest >> testStartsAtThePageCenter [
	self assert: turtle lastPoint equals: 300 @ 420.
	self assert: (self pathOperatorsOf: turtle document) equals: #( '300 420 moveto' )

]

{ #category : 'tests' }
BoEPSTurtleTest >> testWriteScriptToFile [
	| file |
	file := FileSystem memory / 'square.eps'.
	BoEPSTurtle writeScript: '| pica | pica := Bot new. 4 timesRepeat: [ pica go: 100; turnLeft: 90 ]' to: file.
	self drawSquare.
	self assert: file contents equals: turtle document

]

{ #category : 'tests - chapters' }
BoEPSTurtleTest >> testWriteScriptsOfEmptyProtocol [
	self assert: (BoEPSTurtle writeScriptsOf: BoEPSScriptsForTest inProtocol: 'Nothing' to: FileSystem memory / 'figures') isEmpty

]

{ #category : 'tests - chapters' }
BoEPSTurtleTest >> testWriteScriptsOfProtocol [
	| directory files |
	directory := FileSystem memory / 'figures'.
	files := BoEPSTurtle writeScriptsOf: BoEPSScriptsForTest inProtocol: 'ChShapes' to: directory.
	self assert: (files collect: [ :each | each basename ]) equals: #( 'cross.eps' 'square.eps' ).
	self assert: (directory children collect: [ :each | each basename ]) asSet equals: #( 'cross.eps' 'square.eps' ) asSet.
	self drawSquare.
	self assert: (directory / 'square.eps') contents equals: turtle document

]

{ #category : 'tests - chapters' }
BoEPSTurtleTest >> testWriteScriptsOfProtocolWithPrefix [
	| directory |
	directory := FileSystem memory / 'figures'.
	BoEPSTurtle writeScriptsOf: BoEPSScriptsForTest inProtocol: 'ChShapes' to: directory prefix: 'ChShapes-'.
	BoEPSTurtle writeScriptsOf: BoEPSScriptsForTest inProtocol: 'ChOther' to: directory prefix: 'ChOther-'.
	self
		assert: (directory children collect: [ :each | each basename ]) asSet
		equals: #( 'ChShapes-cross.eps' 'ChShapes-square.eps' 'ChOther-line.eps' ) asSet

]

{ #category : 'tests' }
BoEPSTurtleTest >> testWriteTo [
	| file |
	file := FileSystem memory / 'cross.eps'.
	self drawCross.
	turtle writeTo: file.
	self assert: file contents equals: turtle document

]

{ #category : 'tests' }
BoEPSTurtleTest >> testYAxisGoesUp [
	"In Bloc going north decreases y, in PostScript it increases it"

	turtle north.
	turtle go: 100.
	self assert: turtle center equals: 0 @ -100.
	self assert: turtle lastPoint equals: 300 @ 520

]
