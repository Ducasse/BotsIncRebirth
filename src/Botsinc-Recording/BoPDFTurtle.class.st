"
I am a recording turtle that writes Portable Document Format (PDF) documents of a single page as large as the drawing, to be included in a LaTeX or Pillar book.

My page content uses the PDF operators, close to the PostScript ones: a #go: becomes l (lineto), a #jump: m (moveto); a path starts with its width (w) and its stroke color (RG) and is stroked with S.

A PDF file is a list of numbered objects (catalog, pages, page, content stream) followed by a cross-reference table giving the position of each object in the file. As my documents are pure ASCII, a position in the string is a position in the file. I write no compression nor fonts, so the files stay readable.

	BoPDFTurtle documentFor: [ :pica | 4 timesRepeat: [ pica go: 100; turnLeft: 90 ] ]

	BoPDFTurtle
		writeScript: '| pica | pica := Bot new. 4 timesRepeat: [ pica go: 50; jump: -50; turnLeft: 90 ]'
		to: 'cross.pdf'
"
Class {
	#name : 'BoPDFTurtle',
	#superclass : 'BoRecordingTurtle',
	#category : 'Botsinc-Recording',
	#package : 'Botsinc-Recording'
}

{ #category : 'document' }
BoPDFTurtle class >> documentOf: aCollection [
	"Answer a PDF document of one page, as large as the bounding box of the drawings of all the turtles in aCollection.
	A PDF file is a list of numbered objects followed by a cross-reference table giving the position of each object in the file. The document only uses ASCII characters, so a position in the string is a position in the file"

	| bounds pageContent objects offsets xrefOffset |
	bounds := self boundsOf: aCollection.
	pageContent := self pageContentOf: aCollection.
	objects := {
		'<< /Type /Catalog /Pages 2 0 R >>'.
		'<< /Type /Pages /Kids [ 3 0 R ] /Count 1 >>'.
		'<< /Type /Page /Parent 2 0 R /MediaBox [ ' , bounds left printString , ' ' , bounds top printString , ' ' , bounds right printString , ' ' , bounds bottom printString , ' ] /Resources << >> /Contents 4 0 R >>'.
		'<< /Length ' , pageContent size printString , ' >>' , String lf , 'stream' , String lf , pageContent , String lf , 'endstream' }.
	offsets := OrderedCollection new.
	^ String streamContents: [ :aStream |
		aStream nextPutAll: '%PDF-1.4'; lf.
		objects withIndexDo: [ :each :index |
			offsets add: aStream position.
			aStream print: index; nextPutAll: ' 0 obj'; lf; nextPutAll: each; lf; nextPutAll: 'endobj'; lf ].
		xrefOffset := aStream position.
		aStream
			nextPutAll: 'xref'; lf;
			nextPutAll: '0 '; print: objects size + 1; lf;
			nextPutAll: '0000000000 65535 f '; lf.
		offsets do: [ :each |
			aStream nextPutAll: (each printPaddedWith: $0 to: 10); nextPutAll: ' 00000 n '; lf ].
		aStream
			nextPutAll: 'trailer'; lf;
			nextPutAll: '<< /Size '; print: objects size + 1; nextPutAll: ' /Root 1 0 R >>'; lf;
			nextPutAll: 'startxref'; lf;
			print: xrefOffset; lf;
			nextPutAll: '%%EOF'; lf ]

]

{ #category : 'document' }
BoPDFTurtle class >> fileExtension [
	^ '.pdf'

]

{ #category : 'document' }
BoPDFTurtle class >> pageContentOf: aCollection [
	"The content stream of the single page: round caps and joins, then the paths of each turtle"

	^ String streamContents: [ :aStream |
		aStream nextPutAll: '1 J 1 j'; lf.
		aCollection do: [ :each | aStream nextPutAll: each contentStream ] ]

]

{ #category : 'document' }
BoPDFTurtle >> contentStream [
	"The PDF operators drawing what the receiver did, ending with the stroke of the current path. The receiver can continue to move afterwards"

	^ output contents , 'S' , String lf

]

{ #category : 'writing' }
BoPDFTurtle >> writeMoveTo: aPoint drawing: aBoolean [
	"A go: becomes a l(ineto), a jump: a m(oveto), as in PostScript"

	self class print: aPoint x on: output.
	output space.
	self class print: aPoint y on: output.
	output nextPutAll: (aBoolean ifTrue: [ ' l' ] ifFalse: [ ' m' ]); lf

]

{ #category : 'writing' }
BoPDFTurtle >> writePathEnd [
	"Stroke the path"

	output nextPutAll: 'S'; lf

]

{ #category : 'writing' }
BoPDFTurtle >> writePathStart [
	"Set the width (w) and the stroke color (RG) of the new path"

	self class print: penSize on: output.
	output nextPutAll: ' w'; lf.
	{ penColor red. penColor green. penColor blue } do: [ :each |
		output nextPutAll: (each printShowingDecimalPlaces: 3); space ].
	output nextPutAll: 'RG'; lf

]
