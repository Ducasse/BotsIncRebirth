"
I am attached to the tab of a flap. A click opens or closes the flap. Dragging resizes the open flap: on release the new thickness stays.
"
Class {
	#name : 'BoFlapTabHandler',
	#superclass : 'BlCustomEventHandler',
	#instVars : [
		'flap',
		'dragged',
		'startPosition',
		'startThickness'
	],
	#category : 'Botsinc-Flap',
	#package : 'Botsinc-Flap'
}

{ #category : 'instance creation' }
BoFlapTabHandler class >> flap: aFlap [
	^ self new setFlap: aFlap
]

{ #category : 'event handling' }
BoFlapTabHandler >> clickEvent: anEvent [
	"A click ending a drag must not toggle the flap"

	anEvent consumed: true.
	dragged ifFalse: [ flap toggle ]
]

{ #category : 'event handling' }
BoFlapTabHandler >> dragEndEvent: anEvent [
	anEvent consumed: true.
	self resizeFor: anEvent position
]

{ #category : 'event handling' }
BoFlapTabHandler >> dragEvent: anEvent [
	anEvent consumed: true.
	self resizeFor: anEvent position
]

{ #category : 'event handling' }
BoFlapTabHandler >> dragStartEvent: anEvent [
	anEvent consumed: true.
	dragged := true.
	startPosition := anEvent position.
	startThickness := flap isOpen
		ifTrue: [ flap thickness ]
		ifFalse: [ 0 ]
]

{ #category : 'accessing' }
BoFlapTabHandler >> eventsToHandle [
	^ { BlMouseDownEvent. BlClickEvent. BlDragStartEvent. BlDragEvent. BlDragEndEvent }
]

{ #category : 'event handling' }
BoFlapTabHandler >> mouseDownEvent: anEvent [
	dragged := false
]

{ #category : 'private' }
BoFlapTabHandler >> resizeFor: aGlobalPoint [
	flap resizeTo: startThickness + (flap edge growthFor: aGlobalPoint - startPosition)
]

{ #category : 'initialization' }
BoFlapTabHandler >> setFlap: aFlap [
	flap := aFlap.
	dragged := false
]
