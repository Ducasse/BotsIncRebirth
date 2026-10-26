"
I am a turtle that records what I draw as an Encapsulated PostScript (EPS) document, to produce the figures of the book from the scripts themselves.

I am the Bloc version of the PostscriptTurtle written in 2002 for the first edition. I move and draw like any BoTurtle, and each of my moves is also written as a PostScript command: a #go: becomes a lineto, a #jump: a moveto. Changing the pen size or color strokes the current path and starts a new one.

An EPS document must give its bounding box in its header, before the drawing. Instead of running a script twice, once to measure and once to draw, I keep the commands in memory and extend my bounding box while I move. The header is computed when the document is asked for, and put in front of the commands. So a script runs only once.

Coordinates: my starting place is put at the center of an A4 page (300@420 points) and the y axis is flipped, because it goes down in Bloc and up in PostScript. A margin of 10 points is added around the drawing.

From a block:

	BoEPSTurtle epsFor: [ :pica | 4 timesRepeat: [ pica go: 100; turnLeft: 90 ] ]

From a script of the book, where turtles are created with Bot new (all the turtles of the script end up in the same picture):

	BoEPSTurtle
		writeScript: '| pica | pica := Bot new. 4 timesRepeat: [ pica go: 100; turnLeft: 90 ]'
		to: 'square.eps'

As in 2002, the scripts of a chapter can be methods grouped in a protocol: one EPS file is written per script, named after its selector:

	BoEPSTurtle writeScriptsOf: BoBookScripts inProtocol: 'ChLoop' to: 'figures'

Or directly:

	| pica |
	pica := BoEPSTurtle new.
	pica penSize: 3.
	4 timesRepeat: [ pica go: 50; jump: -50; turnLeft: 90 ].
	pica writeTo: 'cross.eps'
	
"
Class {
	#name : 'BoEPSTurtle',
	#superclass : 'BoTurtle',
	#instVars : [
		'path',
		'minPoint',
		'maxPoint',
		'lastPoint'
	],
	#classInstVars : [
		'createdTurtles'
	],
	#category : 'Botsinc-EPS',
	#package : 'Botsinc-EPS'
}

{ #category : 'postscript' }
BoEPSTurtle class >> encapsulatedPostscriptOf: aCollection [
	"Answer an EPS document showing the drawings of all the turtles in aCollection.
	The paths were recorded while the turtles moved, so the bounding box is known now and is written in the header: the scripts run only once"

	| low high |
	low := (aCollection collect: [ :each | each minPoint ]) inject: aCollection first minPoint into: [ :a :b | a min: b ].
	high := (aCollection collect: [ :each | each maxPoint ]) inject: aCollection first maxPoint into: [ :a :b | a max: b ].
	low := (low - self margin) floor.
	high := (high + self margin) ceiling.
	^ String streamContents: [ :aStream |
		aStream
			nextPutAll: '%!PS-Adobe-3.0 EPSF-3.0'; lf;
			nextPutAll: '%%BoundingBox: '; print: low x; space; print: low y; space; print: high x; space; print: high y; lf;
			nextPutAll: '%%Creator: Bots Inc'; lf;
			nextPutAll: '%%EndComments'; lf;
			nextPutAll: '1 setlinecap 1 setlinejoin'; lf.
		aCollection do: [ :each | aStream nextPutAll: each pathContents ].
		aStream
			nextPutAll: 'showpage'; lf;
			nextPutAll: '%%EOF'; lf ]

]

{ #category : 'postscript' }
BoEPSTurtle class >> epsFor: aBlock [
	"Answer the EPS document of the drawing made by a new turtle given to aBlock.
	self epsFor: [ :pica | 4 timesRepeat: [ pica go: 100; turnLeft: 90 ] ]"

	| turtle |
	turtle := self new.
	aBlock value: turtle.
	^ turtle encapsulatedPostscript

]

{ #category : 'chapter generation' }
BoEPSTurtle class >> epsForMethod: aCompiledMethod [
	"Answer the EPS document of a script written as a method"

	^ self epsForScript: (self scriptSourceOf: aCompiledMethod)

]

{ #category : 'postscript' }
BoEPSTurtle class >> epsForScript: aString [
	"Run a script of the book, where turtles are created with Bot new or BoTurtle new, and answer the EPS document of all the turtles it created.
	As in the 2002 PostscriptTurtle the script names other turtles classes, here they are bound to the receiver instead of rewriting the source.
	self epsForScript: '| pica | pica := Bot new. 4 timesRepeat: [ pica go: 100; turnLeft: 90 ]'"

	| turtles |
	turtles := OrderedCollection new.
	createdTurtles := turtles.
	[ OpalCompiler new
		bindings: (self scriptClassNames collect: [ :each | each -> self ]);
		source: aString;
		evaluate ] ensure: [ createdTurtles := nil ].
	turtles ifEmpty: [ ^ self error: 'The script does not create any turtle' ].
	^ self encapsulatedPostscriptOf: turtles

]

{ #category : 'accessing' }
BoEPSTurtle class >> margin [
	"Space added around the drawing in the bounding box, so that thick lines are not cut"

	^ 10

]

{ #category : 'instance creation' }
BoEPSTurtle class >> new [
	"Remember the turtles created while a script runs, see #epsForScript:"

	| turtle |
	turtle := super new.
	createdTurtles ifNotNil: [ createdTurtles add: turtle ].
	^ turtle

]

{ #category : 'accessing' }
BoEPSTurtle class >> pageCenter [
	"The center of an A4 page in points, where turtles start (as in the 2002 PostscriptTurtle)"

	^ 300 @ 420

]

{ #category : 'private' }
BoEPSTurtle class >> print: aNumber on: aStream [
	"PostScript accepts decimals but not the exponents nor fractions Pharo may print"

	aNumber isInteger ifTrue: [ ^ aStream print: aNumber ].
	aNumber = aNumber rounded ifTrue: [ ^ aStream print: aNumber rounded ].
	aStream nextPutAll: (aNumber printShowingDecimalPlaces: 2)

]

{ #category : 'private' }
BoEPSTurtle class >> scriptClassNames [
	"The names under which scripts create turtles"

	^ #( #Bot #BoTurtle #Turtle )

]

{ #category : 'chapter generation' }
BoEPSTurtle class >> scriptSourceOf: aCompiledMethod [
	"The body of a script method, with its temporaries but without its selector, as the 2002 version removed the first line of the method"

	^ aCompiledMethod ast body sourceCode

]

{ #category : 'chapter generation' }
BoEPSTurtle class >> scriptsOf: aClass inProtocol: aProtocolName [
	"The script methods of a protocol, sorted by selector. Methods with arguments cannot be run alone and are not scripts"

	^ ((aClass methodsInProtocol: aProtocolName) select: [ :each | each numArgs = 0 ])
		asSortedCollection: [ :a :b | a selector <= b selector ]

]

{ #category : 'postscript' }
BoEPSTurtle class >> writeScript: aString to: aFileReference [
	"Write the EPS document of a script into a file, as the figures of the book were produced.
	self writeScript: '| pica | pica := Bot new. pica go: 100' to: 'line.eps'"

	aFileReference asFileReference
		ensureDelete;
		writeStreamDo: [ :aStream | aStream nextPutAll: (self epsForScript: aString) ]

]

{ #category : 'chapter generation' }
BoEPSTurtle class >> writeScriptsOf: aClass inProtocol: aProtocolName to: aDirectory [
	"Write one EPS file per script of a protocol, named after its selector, and answer the files.
	In 2002 the scripts of each chapter were methods of Turtle grouped in a category (ChLoop, ChTurn, ...); categories are called protocols in Pharo.
	self writeScriptsOf: BoBookScripts inProtocol: 'ChLoop' to: 'figures'"

	^ self writeScriptsOf: aClass inProtocol: aProtocolName to: aDirectory prefix: ''

]

{ #category : 'chapter generation' }
BoEPSTurtle class >> writeScriptsOf: aClass inProtocol: aProtocolName to: aDirectory prefix: aString [
	"Same as writeScriptsOf:inProtocol:to: but the file names start with aString, for example the name of the chapter, to keep the figures of the chapters apart in one directory"

	| directory |
	directory := aDirectory asFileReference ensureCreateDirectory.
	^ (self scriptsOf: aClass inProtocol: aProtocolName) asArray collect: [ :each | | file |
		file := directory / (aString , each selector , '.eps').
		self writeScript: (self scriptSourceOf: each) to: file.
		file ]

]

{ #category : 'postscript' }
BoEPSTurtle >> encapsulatedPostscript [
	"Answer the EPS document of what the receiver drew so far"

	^ self class encapsulatedPostscriptOf: { self }

]

{ #category : 'recording' }
BoEPSTurtle >> includeInBounds: aPoint [
	minPoint := minPoint ifNil: [ aPoint ] ifNotNil: [ minPoint min: aPoint ].
	maxPoint := maxPoint ifNil: [ aPoint ] ifNotNil: [ maxPoint max: aPoint ]

]

{ #category : 'initialization' }
BoEPSTurtle >> initialize [
	"Start the path at the current location, with the default pen"

	super initialize.
	path := WriteStream on: (String new: 200).
	self startSubpath

]

{ #category : 'accessing' }
BoEPSTurtle >> lastPoint [
	"Where the pen is, in PostScript coordinates"

	^ lastPoint

]

{ #category : 'accessing' }
BoEPSTurtle >> maxPoint [
	"The top right corner of the drawing, in PostScript coordinates"

	^ maxPoint

]

{ #category : 'accessing' }
BoEPSTurtle >> minPoint [
	"The bottom left corner of the drawing, in PostScript coordinates"

	^ minPoint

]

{ #category : 'private' }
BoEPSTurtle >> moveTo: aPoint trail: aBoolean [
	"Every move of a turtle ends up here: draw a line when there is a trail, otherwise only move the pen"

	super moveTo: aPoint trail: aBoolean.
	self recordMoveTo: location drawing: aBoolean

]

{ #category : 'converting' }
BoEPSTurtle >> pagePointFor: aPoint [
	"Bloc's y axis goes down while PostScript's goes up. The starting place of the receiver is put at the center of an A4 page"

	| relative |
	relative := aPoint - self startingPlace.
	^ self class pageCenter + (relative x @ relative y negated)

]

{ #category : 'postscript' }
BoEPSTurtle >> pathContents [
	"The PostScript drawing what the receiver did, ending with the stroke of the current path. The receiver can continue to move afterwards"

	^ path contents , 'stroke' , String lf

]

{ #category : 'pen' }
BoEPSTurtle >> penColor: aColor [
	"Like the width, the color applies to a whole path: stroke what was drawn so far and start a new path"

	super penColor: aColor.
	self restartSubpath

]

{ #category : 'pen' }
BoEPSTurtle >> penSize: aNumber [
	"PostScript draws a path with a single width: stroke what was drawn so far and start a new path with the new width"

	super penSize: aNumber.
	self restartSubpath

]

{ #category : 'private' }
BoEPSTurtle >> placeAt: aPoint [
	"Being placed in a world is a move without trail"

	super placeAt: aPoint.
	self recordMoveTo: location drawing: false

]

{ #category : 'recording' }
BoEPSTurtle >> recordMoveTo: aPoint drawing: aBoolean [
	"Append a lineto or a moveto to the path and extend the bounding box"

	lastPoint := self pagePointFor: aPoint.
	self includeInBounds: lastPoint.
	self writePoint: lastPoint operator: (aBoolean ifTrue: [ 'lineto' ] ifFalse: [ 'moveto' ])

]

{ #category : 'recording' }
BoEPSTurtle >> restartSubpath [
	path nextPutAll: 'stroke'; lf.
	self startSubpath

]

{ #category : 'recording' }
BoEPSTurtle >> startSubpath [
	"Set the pen of the path, then start it where the receiver stands"

	self class print: penSize on: path.
	path nextPutAll: ' setlinewidth'; lf.
	self writeColor.
	path nextPutAll: 'newpath'; lf.
	self recordMoveTo: location drawing: false

]

{ #category : 'recording' }
BoEPSTurtle >> writeColor [
	{ penColor red. penColor green. penColor blue } do: [ :each |
		path nextPutAll: (each printShowingDecimalPlaces: 3); space ].
	path nextPutAll: 'setrgbcolor'; lf

]

{ #category : 'recording' }
BoEPSTurtle >> writePoint: aPoint operator: aString [
	self class print: aPoint x on: path.
	path space.
	self class print: aPoint y on: path.
	path space; nextPutAll: aString; lf

]

{ #category : 'postscript' }
BoEPSTurtle >> writeTo: aFileReference [
	"Write the EPS document of the receiver into aFileReference, replacing its contents"

	aFileReference asFileReference
		ensureDelete;
		writeStreamDo: [ :aStream | aStream nextPutAll: self encapsulatedPostscript ]

]
