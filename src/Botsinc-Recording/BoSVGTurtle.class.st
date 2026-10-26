"
I am a recording turtle that writes Scalable Vector Graphics (SVG), to show the figures in a web browser or in HTML versions of the book.

Each path becomes a path element with its stroke color and width: a #go: becomes an L command and a #jump: an M command. A path made only of jumps draws nothing and is left out.

The y axis of SVG goes down as in Bloc, so I redefine #pagePointFor: not to flip it. The view box of the document is the bounding box of the drawing and its size is given in points, so that my documents print at the same size as EPS and PDF ones.

	BoSVGTurtle documentFor: [ :pica | 4 timesRepeat: [ pica go: 100; turnLeft: 90 ] ]

	BoSVGTurtle
		writeScript: '| pica | pica := Bot new. 36 timesRepeat: [ pica go: 20; turnLeft: 10 ]'
		to: 'circle.svg'
"
Class {
	#name : 'BoSVGTurtle',
	#superclass : 'BoRecordingTurtle',
	#instVars : [
		'pathStart',
		'pathData',
		'pathHasLine'
	],
	#category : 'Botsinc-Recording',
	#package : 'Botsinc-Recording'
}

{ #category : 'document' }
BoSVGTurtle class >> documentOf: aCollection [
	"Answer an SVG document showing the drawings of all the turtles in aCollection. Its view box is the bounding box of the drawings, and its size is given in points as in EPS and PDF, so the three print at the same size"

	| bounds |
	bounds := self boundsOf: aCollection.
	^ String streamContents: [ :aStream |
		aStream
			nextPutAll: '<?xml version="1.0" encoding="UTF-8"?>'; lf;
			nextPutAll: '<svg xmlns="http://www.w3.org/2000/svg" width="'; print: bounds width;
			nextPutAll: 'pt" height="'; print: bounds height;
			nextPutAll: 'pt" viewBox="'; print: bounds left; space; print: bounds top; space; print: bounds width; space; print: bounds height;
			nextPutAll: '">'; lf;
			nextPutAll: '<g fill="none" stroke-linecap="round" stroke-linejoin="round">'; lf.
		aCollection do: [ :each | aStream nextPutAll: each pathElements ].
		aStream
			nextPutAll: '</g>'; lf;
			nextPutAll: '</svg>'; lf ]

]

{ #category : 'document' }
BoSVGTurtle class >> fileExtension [
	^ '.svg'

]

{ #category : 'document' }
BoSVGTurtle >> currentPathElement [
	"The element of the current path. A path made only of moves draws nothing and has no element"

	pathHasLine ifFalse: [ ^ '' ].
	^ pathStart , pathData contents , '"/>' , String lf

]

{ #category : 'converting' }
BoSVGTurtle >> pagePointFor: aPoint [
	"The y axis of SVG goes down as in Bloc: no flip, the starting place is only moved to the center of the page"

	^ self class pageCenter + (aPoint - self startingPlace)

]

{ #category : 'document' }
BoSVGTurtle >> pathElements [
	"The path elements of the drawing of the receiver, including the current path. The receiver can continue to move afterwards"

	^ output contents , self currentPathElement

]

{ #category : 'writing' }
BoSVGTurtle >> writeMoveTo: aPoint drawing: aBoolean [
	"A go: becomes a L(ine) command, a jump: a M(ove) command"

	pathData isEmpty ifFalse: [ pathData space ].
	pathData nextPutAll: (aBoolean ifTrue: [ 'L ' ] ifFalse: [ 'M ' ]).
	self class print: aPoint x on: pathData.
	pathData space.
	self class print: aPoint y on: pathData.
	pathHasLine := pathHasLine or: [ aBoolean ]

]

{ #category : 'writing' }
BoSVGTurtle >> writePathEnd [
	output nextPutAll: self currentPathElement

]

{ #category : 'writing' }
BoSVGTurtle >> writePathStart [
	"Prepare a path element with the current pen. Its data is collected until the path ends"

	pathStart := String streamContents: [ :aStream |
		aStream nextPutAll: '<path stroke="#'; nextPutAll: penColor asHexString asLowercase; nextPutAll: '" stroke-width="'.
		self class print: penSize on: aStream.
		aStream nextPutAll: '" d="' ].
	pathData := WriteStream on: (String new: 100).
	pathHasLine := false

]
