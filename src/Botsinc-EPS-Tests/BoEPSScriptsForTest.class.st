"
I hold turtle scripts as methods grouped in protocols, the way the scripts of a chapter were grouped in 2002, to test the generation of the figures of a chapter.
"
Class {
	#name : 'BoEPSScriptsForTest',
	#superclass : 'Object',
	#category : 'Botsinc-EPS-Tests',
	#package : 'Botsinc-EPS-Tests'
}

{ #category : 'ChShapes' }
BoEPSScriptsForTest >> cross [
	| pica |
	pica := BoTurtle new.
	4 timesRepeat: [ pica go: 50; jump: -50; turnLeft: 90 ]

]

{ #category : 'ChOther' }
BoEPSScriptsForTest >> line [
	| pica |
	pica := BoTurtle new.
	pica go: 100

]

{ #category : 'ChShapes' }
BoEPSScriptsForTest >> polygon: n [
	"Not a script: it needs an argument"

	| pica |
	pica := BoTurtle new.
	n timesRepeat: [ pica go: 50; turnLeft: 360 / n ]

]

{ #category : 'ChShapes' }
BoEPSScriptsForTest >> square [
	"A square of 100"

	| pica |
	pica := BoTurtle new.
	4 timesRepeat: [ pica go: 100; turnLeft: 90 ]

]
