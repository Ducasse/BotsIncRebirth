"
I am a recording turtle that logs what it would write, to test the recording independently of any file format.
"
Class {
	#name : 'BoRecordingTurtleForTest',
	#superclass : 'BoRecordingTurtle',
	#instVars : [
		'log'
	],
	#category : 'Botsinc-Recording-Tests',
	#package : 'Botsinc-Recording-Tests'
}

{ #category : 'initialization' }
BoRecordingTurtleForTest >> initializeRecording [
	log := OrderedCollection new

]

{ #category : 'accessing' }
BoRecordingTurtleForTest >> log [
	^ log asArray

]

{ #category : 'writing' }
BoRecordingTurtleForTest >> writeMoveTo: aPoint drawing: aBoolean [
	log add: (aBoolean ifTrue: [ #line ] ifFalse: [ #move ]) -> aPoint

]

{ #category : 'writing' }
BoRecordingTurtleForTest >> writePathEnd [
	log add: #end

]

{ #category : 'writing' }
BoRecordingTurtleForTest >> writePathStart [
	log add: #start

]
