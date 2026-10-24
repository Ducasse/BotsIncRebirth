"
I am attached to an item of a flap. When the item is dragged, I create a new element from the prototype, add it to the world and make it follow the pointer. Dropping it back over the flap discards it.
"
Class {
	#name : 'BoFlapItemDragHandler',
	#superclass : 'BlCustomEventHandler',
	#instVars : [
		'flap',
		'prototype',
		'copy',
		'offset'
	],
	#category : 'Botsinc-Flap',
	#package : 'Botsinc-Flap'
}

{ #category : 'instance creation' }
BoFlapItemDragHandler class >> flap: aFlap prototype: aBlock [
	^ self new setFlap: aFlap prototype: aBlock
]

{ #category : 'event handling' }
BoFlapItemDragHandler >> dragEndEvent: anEvent [
	"Dropping the copy back over the flap cancels it"

	anEvent consumed: true.
	copy elevation: (BlRelativeElevation elevation: 0).
	(flap containsGlobalPoint: anEvent position)
		ifTrue: [ copy removeFromParent ]
]

{ #category : 'event handling' }
BoFlapItemDragHandler >> dragEvent: anEvent [
	anEvent consumed: true.
	self moveCopyTo: anEvent position
]

{ #category : 'event handling' }
BoFlapItemDragHandler >> dragStartEvent: anEvent [
	"The copy is held above the flap while it is dragged"

	anEvent consumed: true.
	copy := prototype value.
	copy elevation: (BlRelativeElevation elevation: flap elevation elevation + 1).
	copy addEventHandler: BoMoveDragHandler new.
	flap parent addChild: copy.
	self moveCopyTo: anEvent position
]

{ #category : 'accessing' }
BoFlapItemDragHandler >> eventsToHandle [
	^ { BlMouseDownEvent. BlDragStartEvent. BlDragEvent. BlDragEndEvent }
]

{ #category : 'event handling' }
BoFlapItemDragHandler >> mouseDownEvent: anEvent [
	"Remember where the item is grabbed: the drag starts only after the pointer has moved a little"

	offset := anEvent currentTarget globalPointToLocal: anEvent position
]

{ #category : 'private' }
BoFlapItemDragHandler >> moveCopyTo: aGlobalPoint [
	copy position: (flap parent globalPointToLocal: aGlobalPoint) - offset
]

{ #category : 'initialization' }
BoFlapItemDragHandler >> setFlap: aFlap prototype: aBlock [
	flap := aFlap.
	prototype := aBlock
]
