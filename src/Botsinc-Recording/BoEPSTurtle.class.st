"
I am a recording turtle that writes Encapsulated PostScript (EPS), the format used for the figures of the first edition of the book. I am the Bloc version of the PostscriptTurtle written in 2002.

Each recorded move becomes a PostScript command: a #go: becomes a lineto and a #jump: a moveto. A path starts with its line width and color and ends with a stroke.

An EPS document must give its bounding box in its header, before the drawing. Instead of running a script twice, once to measure and once to draw, I keep the commands in memory while my superclass extends the bounding box. The header is computed when the document is asked for and put in front of the commands.

	BoEPSTurtle documentFor: [ :pica | 4 timesRepeat: [ pica go: 100; turnLeft: 90 ] ]

	| pica |
	pica := BoEPSTurtle new.
	pica penSize: 3.
	4 timesRepeat: [ pica go: 50; jump: -50; turnLeft: 90 ].
	pica writeTo: 'cross.eps'
"
Class {
	#name : 'BoEPSTurtle',
	#superclass : 'BoRecordingTurtle',
	#instVars : [
		'path'
	],
	#category : 'Botsinc-Recording',
	#package : 'Botsinc-Recording'
}

{ #category : 'document' }
BoEPSTurtle class >> documentOf: aCollection [
	"Answer an EPS document showing the drawings of all the turtles in aCollection.
	The paths were recorded while the turtles moved, so the bounding box is known now and is written in the header: the scripts run only once"

	| bounds |
	bounds := self boundsOf: aCollection.
	^ String streamContents: [ :aStream |
		aStream
			nextPutAll: '%!PS-Adobe-3.0 EPSF-3.0'; lf;
			nextPutAll: '%%BoundingBox: '; print: bounds left; space; print: bounds top; space; print: bounds right; space; print: bounds bottom; lf;
			nextPutAll: '%%Creator: Bots Inc'; lf;
			nextPutAll: '%%EndComments'; lf;
			nextPutAll: '1 setlinecap 1 setlinejoin'; lf.
		aCollection do: [ :each | aStream nextPutAll: each pathContents ].
		aStream
			nextPutAll: 'showpage'; lf;
			nextPutAll: '%%EOF'; lf ]

]

{ #category : 'document' }
BoEPSTurtle class >> fileExtension [
	^ '.eps'

]

{ #category : 'initialization' }
BoEPSTurtle >> initializeRecording [
	path := WriteStream on: (String new: 200)

]

{ #category : 'postscript' }
BoEPSTurtle >> pathContents [
	"The PostScript drawing what the receiver did, ending with the stroke of the current path. The receiver can continue to move afterwards"

	^ path contents , 'stroke' , String lf

]

{ #category : 'recording' }
BoEPSTurtle >> writeColor [
	{ penColor red. penColor green. penColor blue } do: [ :each |
		path nextPutAll: (each printShowingDecimalPlaces: 3); space ].
	path nextPutAll: 'setrgbcolor'; lf

]

{ #category : 'writing' }
BoEPSTurtle >> writeMoveTo: aPoint drawing: aBoolean [
	"A go: becomes a lineto, a jump: a moveto"

	self writePoint: aPoint operator: (aBoolean ifTrue: [ 'lineto' ] ifFalse: [ 'moveto' ])

]

{ #category : 'writing' }
BoEPSTurtle >> writePathEnd [
	path nextPutAll: 'stroke'; lf

]

{ #category : 'writing' }
BoEPSTurtle >> writePathStart [
	"Set the pen, then start a new path"

	self class print: penSize on: path.
	path nextPutAll: ' setlinewidth'; lf.
	self writeColor.
	path nextPutAll: 'newpath'; lf

]

{ #category : 'recording' }
BoEPSTurtle >> writePoint: aPoint operator: aString [
	self class print: aPoint x on: path.
	path space.
	self class print: aPoint y on: path.
	path space; nextPutAll: aString; lf

]
