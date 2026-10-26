"
I am an abstract turtle that records what I draw, to produce a picture of it in a file format given by my subclasses: BoEPSTurtle, BoSVGTurtle and BoPDFTurtle.

I move and draw like any BoTurtle. Every move is converted to page coordinates and given to my subclass with #writeMoveTo:drawing:, drawing when the turtle goes and not drawing when it jumps. A path is drawn with a single pen: when the pen size or color changes, I end the current path (#writePathEnd) and start a new one (#writePathStart) at the same place.

While recording I extend a bounding box (#minPoint and #maxPoint), so that a format that needs it in its header can be written once the script is over: a script runs only once. This is the idea of the 2002 PostscriptTurtle.

Page coordinates: my starting place is put at the center of an A4 page (300@420 points) and the y axis goes up, as in PostScript and PDF. A margin of 10 points is added around the drawing.

My subclasses define:
- #initializeRecording to create what they write into,
- #writePathStart, #writePathEnd and #writeMoveTo:drawing:,
- on the class side, #documentOf: which makes one document of the drawings of several turtles, and #fileExtension.

My class side runs the scripts of the book, where turtles are created with Bot new, and writes the figures of a chapter whose scripts are the methods of a protocol:

	BoSVGTurtle documentFor: [ :pica | 4 timesRepeat: [ pica go: 100; turnLeft: 90 ] ].
	BoPDFTurtle writeScript: '| pica | pica := Bot new. 4 timesRepeat: [ pica go: 100; turnLeft: 90 ]' to: 'square.pdf'.
	BoEPSTurtle writeScriptsOf: BoBookScripts inProtocol: 'ChLoop' to: 'figures'
"
Class {
	#name : 'BoRecordingTurtle',
	#superclass : 'BoTurtle',
	#instVars : [
		'minPoint',
		'maxPoint',
		'lastPoint'
	],
	#classInstVars : [
		'createdTurtles'
	],
	#category : 'Botsinc-Recording',
	#package : 'Botsinc-Recording'
}

{ #category : 'document' }
BoRecordingTurtle class >> boundsOf: aCollection [
	"The rectangle, with whole coordinates, holding the drawings of all the turtles in aCollection plus a margin"

	| low high |
	low := (aCollection collect: [ :each | each minPoint ]) inject: aCollection first minPoint into: [ :a :b | a min: b ].
	high := (aCollection collect: [ :each | each maxPoint ]) inject: aCollection first maxPoint into: [ :a :b | a max: b ].
	^ (low - self margin) floor corner: (high + self margin) ceiling

]

{ #category : 'scripts' }
BoRecordingTurtle class >> documentFor: aBlock [
	"Answer the document of the drawing made by a new turtle given to aBlock.
	BoEPSTurtle documentFor: [ :pica | 4 timesRepeat: [ pica go: 100; turnLeft: 90 ] ]"

	| turtle |
	turtle := self new.
	aBlock value: turtle.
	^ turtle document

]

{ #category : 'chapter generation' }
BoRecordingTurtle class >> documentForMethod: aCompiledMethod [
	"Answer the document of a script written as a method"

	^ self documentForScript: (self scriptSourceOf: aCompiledMethod)

]

{ #category : 'scripts' }
BoRecordingTurtle class >> documentForScript: aString [
	"Run a script of the book, where turtles are created with Bot new or BoTurtle new, and answer the document of all the turtles it created.
	As in the 2002 PostscriptTurtle the script names other turtle classes: here they are bound to the receiver instead of rewriting the source.
	BoSVGTurtle documentForScript: '| pica | pica := Bot new. 4 timesRepeat: [ pica go: 100; turnLeft: 90 ]'"

	| turtles |
	turtles := OrderedCollection new.
	createdTurtles := turtles.
	[ OpalCompiler new
		bindings: (self scriptClassNames collect: [ :each | each -> self ]);
		source: aString;
		evaluate ] ensure: [ createdTurtles := nil ].
	turtles ifEmpty: [ ^ self error: 'The script does not create any turtle' ].
	^ self documentOf: turtles

]

{ #category : 'document' }
BoRecordingTurtle class >> documentOf: aCollection [
	"Answer a document showing the drawings of all the turtles in aCollection"

	self subclassResponsibility

]

{ #category : 'document' }
BoRecordingTurtle class >> fileExtension [
	"The extension of the files written by the receiver, with its dot"

	self subclassResponsibility

]

{ #category : 'testing' }
BoRecordingTurtle class >> isAbstract [
	^ self == BoRecordingTurtle

]

{ #category : 'accessing' }
BoRecordingTurtle class >> margin [
	"Space added around the drawing in the bounding box, so that thick lines are not cut"

	^ 10

]

{ #category : 'instance creation' }
BoRecordingTurtle class >> new [
	"Remember the turtles created while a script runs, see #documentForScript:"

	| turtle |
	turtle := super new.
	createdTurtles ifNotNil: [ createdTurtles add: turtle ].
	^ turtle

]

{ #category : 'accessing' }
BoRecordingTurtle class >> pageCenter [
	"The center of an A4 page in points, where turtles start (as in the 2002 PostscriptTurtle)"

	^ 300 @ 420

]

{ #category : 'private' }
BoRecordingTurtle class >> print: aNumber on: aStream [
	"File formats accept decimals but not the exponents nor fractions Pharo may print"

	aNumber isInteger ifTrue: [ ^ aStream print: aNumber ].
	aNumber = aNumber rounded ifTrue: [ ^ aStream print: aNumber rounded ].
	aStream nextPutAll: (aNumber printShowingDecimalPlaces: 2)

]

{ #category : 'scripts' }
BoRecordingTurtle class >> scriptClassNames [
	"The names under which scripts create turtles"

	^ #( #Bot #BoTurtle #Turtle )

]

{ #category : 'chapter generation' }
BoRecordingTurtle class >> scriptSourceOf: aCompiledMethod [
	"The body of a script method, with its temporaries but without its selector, as the 2002 version removed the first line of the method"

	^ aCompiledMethod ast body sourceCode

]

{ #category : 'chapter generation' }
BoRecordingTurtle class >> scriptsOf: aClass inProtocol: aProtocolName [
	"The script methods of a protocol, sorted by selector. Methods with arguments cannot be run alone and are not scripts"

	^ ((aClass methodsInProtocol: aProtocolName) select: [ :each | each numArgs = 0 ])
		asSortedCollection: [ :a :b | a selector <= b selector ]

]

{ #category : 'scripts' }
BoRecordingTurtle class >> writeScript: aString to: aFileReference [
	"Write the document of a script into a file, as the figures of the book were produced.
	BoPDFTurtle writeScript: '| pica | pica := Bot new. pica go: 100' to: 'line.pdf'"

	aFileReference asFileReference
		ensureDelete;
		writeStreamDo: [ :aStream | aStream nextPutAll: (self documentForScript: aString) ]

]

{ #category : 'chapter generation' }
BoRecordingTurtle class >> writeScriptsOf: aClass inProtocol: aProtocolName to: aDirectory [
	"Write one file per script of a protocol, named after its selector with the extension of the receiver, and answer the files.
	In 2002 the scripts of each chapter were methods of Turtle grouped in a category (ChLoop, ChTurn, ...); categories are called protocols in Pharo.
	BoEPSTurtle writeScriptsOf: BoBookScripts inProtocol: 'ChLoop' to: 'figures'"

	^ self writeScriptsOf: aClass inProtocol: aProtocolName to: aDirectory prefix: ''

]

{ #category : 'chapter generation' }
BoRecordingTurtle class >> writeScriptsOf: aClass inProtocol: aProtocolName to: aDirectory prefix: aString [
	"Same as writeScriptsOf:inProtocol:to: but the file names start with aString, for example the name of the chapter, to keep the figures of the chapters apart in one directory"

	| directory |
	directory := aDirectory asFileReference ensureCreateDirectory.
	^ (self scriptsOf: aClass inProtocol: aProtocolName) asArray collect: [ :each | | file |
		file := directory / (aString , each selector , self fileExtension).
		self writeScript: (self scriptSourceOf: each) to: file.
		file ]

]

{ #category : 'document' }
BoRecordingTurtle >> document [
	"Answer the document of what the receiver drew so far, in the format of its class"

	^ self class documentOf: { self }

]

{ #category : 'recording' }
BoRecordingTurtle >> endPath [
	self writePathEnd

]

{ #category : 'recording' }
BoRecordingTurtle >> includeInBounds: aPoint [
	minPoint := minPoint ifNil: [ aPoint ] ifNotNil: [ minPoint min: aPoint ].
	maxPoint := maxPoint ifNil: [ aPoint ] ifNotNil: [ maxPoint max: aPoint ]

]

{ #category : 'initialization' }
BoRecordingTurtle >> initialize [
	"Prepare the recording, then start the first path where the receiver stands"

	super initialize.
	self initializeRecording.
	self startPath

]

{ #category : 'initialization' }
BoRecordingTurtle >> initializeRecording [
	"Subclasses create here what they write into, before the first path starts"

]

{ #category : 'accessing' }
BoRecordingTurtle >> lastPoint [
	"Where the pen is, in page coordinates"

	^ lastPoint

]

{ #category : 'accessing' }
BoRecordingTurtle >> maxPoint [
	"The top right corner of the drawing, in page coordinates"

	^ maxPoint

]

{ #category : 'accessing' }
BoRecordingTurtle >> minPoint [
	"The bottom left corner of the drawing, in page coordinates"

	^ minPoint

]

{ #category : 'private' }
BoRecordingTurtle >> moveTo: aPoint trail: aBoolean [
	"Every move of a turtle ends up here: record a line when there is a trail, otherwise only a move of the pen"

	super moveTo: aPoint trail: aBoolean.
	self recordMoveTo: location drawing: aBoolean

]

{ #category : 'converting' }
BoRecordingTurtle >> pagePointFor: aPoint [
	"Bloc's y axis goes down while the y axis of a page goes up, as in PostScript and PDF. The starting place of the receiver is put at the center of an A4 page. A format whose y axis goes down, such as SVG, would redefine this method"

	| relative |
	relative := aPoint - self startingPlace.
	^ self class pageCenter + (relative x @ relative y negated)

]

{ #category : 'recording' }
BoRecordingTurtle >> penChanged [
	"A path is drawn with a single pen: end the current path and start a new one with the new pen"

	self endPath.
	self startPath

]

{ #category : 'pen' }
BoRecordingTurtle >> penColor: aColor [
	super penColor: aColor.
	self penChanged

]

{ #category : 'pen' }
BoRecordingTurtle >> penSize: aNumber [
	super penSize: aNumber.
	self penChanged

]

{ #category : 'private' }
BoRecordingTurtle >> placeAt: aPoint [
	"Being placed in a world is a move without trail"

	super placeAt: aPoint.
	self recordMoveTo: location drawing: false

]

{ #category : 'recording' }
BoRecordingTurtle >> recordMoveTo: aPoint drawing: aBoolean [
	"Convert aPoint to page coordinates, extend the bounding box and let the subclass write the move"

	lastPoint := self pagePointFor: aPoint.
	self includeInBounds: lastPoint.
	self writeMoveTo: lastPoint drawing: aBoolean

]

{ #category : 'recording' }
BoRecordingTurtle >> startPath [
	"Start a path with the current pen, where the receiver stands"

	self writePathStart.
	self recordMoveTo: location drawing: false

]

{ #category : 'writing' }
BoRecordingTurtle >> writeMoveTo: aPoint drawing: aBoolean [
	"Write a move of the pen to aPoint, in page coordinates, drawing a line when aBoolean is true"

	self subclassResponsibility

]

{ #category : 'writing' }
BoRecordingTurtle >> writePathEnd [
	"Write the end of the current path"

	self subclassResponsibility

]

{ #category : 'writing' }
BoRecordingTurtle >> writePathStart [
	"Write the beginning of a path drawn with the current pen size and color"

	self subclassResponsibility

]

{ #category : 'document' }
BoRecordingTurtle >> writeTo: aFileReference [
	"Write the document of the receiver into aFileReference, replacing its contents"

	aFileReference asFileReference
		ensureDelete;
		writeStreamDo: [ :aStream | aStream nextPutAll: self document ]

]
