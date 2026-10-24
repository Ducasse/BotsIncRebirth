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
	anEvent consumed: true.
	offset := anEvent currentTarget globalPointToLocal: anEvent position.
	copy := prototype value.
	copy addEventHandler: BoMoveDragHandler new.
	flap parent addChild: copy.
	self moveCopyTo: anEvent position
]

{ #category : 'accessing' }
BoFlapItemDragHandler >> eventsToHandle [
	^ { BlDragStartEvent. BlDragEvent. BlDragEndEvent }
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
