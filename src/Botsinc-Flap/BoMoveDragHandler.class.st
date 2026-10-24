"
I let the user move an element in its parent by dragging it. I am installed on the copies dropped from a flap.
"
Class {
	#name : 'BoMoveDragHandler',
	#superclass : 'BlCustomEventHandler',
	#instVars : [
		'offset'
	],
	#category : 'Botsinc-Flap',
	#package : 'Botsinc-Flap'
}

{ #category : 'event handling' }
BoMoveDragHandler >> dragEndEvent: anEvent [
	anEvent consumed: true
]

{ #category : 'event handling' }
BoMoveDragHandler >> dragEvent: anEvent [
	| element |
	anEvent consumed: true.
	element := anEvent currentTarget.
	element position: (element parent globalPointToLocal: anEvent position) - offset
]

{ #category : 'event handling' }
BoMoveDragHandler >> dragStartEvent: anEvent [
	anEvent consumed: true
]

{ #category : 'accessing' }
BoMoveDragHandler >> eventsToHandle [
	^ { BlMouseDownEvent. BlDragStartEvent. BlDragEvent. BlDragEndEvent }
]

{ #category : 'event handling' }
BoMoveDragHandler >> mouseDownEvent: anEvent [
	offset := anEvent currentTarget globalPointToLocal: anEvent position
]
