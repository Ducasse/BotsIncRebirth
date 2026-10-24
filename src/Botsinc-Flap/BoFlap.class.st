"
I am a flap, in the spirit of Squeak Supplies flaps: a drawer stuck to one edge of a world element, holding prototypes of graphical objects. I span the whole side of the world I am attached to, and follow it when it is resized.

Clicking my tab slides me open or closed. Dragging one of my items drops a fresh copy into the world. Since Bloc elements cannot be copied, I store prototypes as blocks that create a new element each time.

The world must have a real size (a fresh BlElement is only 50@50 and clips its children), so make it fill the space:

```
| world flap |
world := BlElement new
	background: Color white;
	constraintsDo: [ :c |
		c horizontal matchParent.
		c vertical matchParent ];
	yourself.
flap := BoFlap new edge: BoFlapEdge left; yourself.
flap addPrototype: [ BlElement new extent: 40@40; background: Color red; yourself ].
flap attachTo: world.
world openInSpace
```
"
Class {
	#name : 'BoFlap',
	#superclass : 'BlElement',
	#instVars : [
		'edge',
		'open',
		'pane',
		'tab',
		'prototypes',
		'thickness',
		'tabThickness',
		'tabLength'
	],
	#category : 'Botsinc-Flap',
	#package : 'Botsinc-Flap'
}

{ #category : 'examples' }
BoFlap class >> example [
	"Open a world with a flap on each edge"

	<sampleInstance>
	| world |
	world := BlElement new
		background: Color white;
		constraintsDo: [ :c |
			c horizontal matchParent.
			c vertical matchParent ];
		yourself.
	{ BoFlapEdge left. BoFlapEdge right. BoFlapEdge top. BoFlapEdge bottom } do: [ :anEdge |
		| flap |
		flap := BoFlap new edge: anEdge; yourself.
		flap addPrototype: [ BlElement new extent: 40 @ 40; background: Color red; yourself ].
		flap addPrototype: [ BlElement new extent: 40 @ 40; background: Color blue; geometry: BlCircleGeometry new; yourself ].
		flap addPrototype: [ BlTextElement new text: 'Hello' asRopedText; yourself ].
		flap attachTo: world ].
	world openInSpace.
	^ world
]

{ #category : 'adding' }
BoFlap >> addPrototype: aBlock [
	"aBlock returns a new element each time it is evaluated"

	prototypes add: aBlock.
	pane addChild: (self newItemFor: aBlock)
]

{ #category : 'attaching' }
BoFlap >> attachTo: aWorldElement [
	"The world fills its parent: an unsized element is 50@50 and clips its children, which would hide the flap"

	aWorldElement constraintsDo: [ :c |
		c horizontal matchParent.
		c vertical matchParent ].
	aWorldElement addChild: self.
	aWorldElement
		addEventHandlerOn: BlElementExtentChangedEvent
		do: [ :anEvent | self updateGeometry ].
	self updateGeometry
]

{ #category : 'opening' }
BoFlap >> close [
	open := false.
	self slideToCurrentPosition
]

{ #category : 'private' }
BoFlap >> currentPosition [
	^ open
		ifTrue: [ edge openPositionOf: self in: self parent extent ]
		ifFalse: [ edge closedPositionOf: self in: self parent extent ]
]

{ #category : 'accessing' }
BoFlap >> edge [
	^ edge
]

{ #category : 'accessing' }
BoFlap >> edge: aFlapEdge [
	edge := aFlapEdge.
	self rebuild
]

{ #category : 'initialization' }
BoFlap >> initialize [
	super initialize.
	edge := BoFlapEdge left.
	open := false.
	prototypes := OrderedCollection new.
	thickness := 90.
	tabThickness := 22.
	tabLength := 70.
	pane := self newPane.
	tab := self newTab.
	self constraintsDo: [ :c |
		c horizontal fitContent.
		c vertical fitContent ].
	self elevation: (BlRelativeElevation elevation: 1000).
	self rebuild
]

{ #category : 'testing' }
BoFlap >> isOpen [
	^ open
]

{ #category : 'accessing' }
BoFlap >> items [
	^ pane children
]

{ #category : 'accessing' }
BoFlap >> maxThickness [
	"The tab must stay inside the world"

	self hasParent ifFalse: [ ^ thickness ].
	^ (edge availableThicknessOf: self in: self parent extent) max: self minThickness
]

{ #category : 'accessing' }
BoFlap >> minThickness [
	^ 40
]

{ #category : 'initialization' }
BoFlap >> newItemFor: aPrototypeBlock [
	"Return a cell showing a fresh instance of the prototype. The instance ignores the mouse so that the cell receives the drag events"

	^ BlElement new
		layout: BlFrameLayout new;
		constraintsDo: [ :c |
			c horizontal fitContent.
			c vertical fitContent ];
		margin: (BlInsets all: 4);
		addChild: (aPrototypeBlock value preventMouseEvents; yourself);
		addEventHandler: (BoFlapItemDragHandler flap: self prototype: aPrototypeBlock);
		yourself
]

{ #category : 'initialization' }
BoFlap >> newPane [
	^ BlElement new
		layout: BlFlowLayout horizontal;
		padding: (BlInsets all: 6);
		background: (Color gray: 0.92);
		border: (BlBorder paint: Color gray width: 1);
		clipChildren: true;
		yourself
]

{ #category : 'initialization' }
BoFlap >> newTab [
	^ BlElement new
		background: Color orange;
		geometry: (BlRoundedRectangleGeometry cornerRadius: 6);
		addEventHandler: (BoFlapTabHandler flap: self);
		yourself
]

{ #category : 'opening' }
BoFlap >> open [
	open := true.
	self slideToCurrentPosition
]

{ #category : 'accessing' }
BoFlap >> pane [
	^ pane
]

{ #category : 'accessing' }
BoFlap >> prototypes [
	^ prototypes
]

{ #category : 'private' }
BoFlap >> rebuild [
	self removeChildren.
	self layout: edge layout.
	tab extent: (edge tabExtentFor: self).
	edge arrangePane: pane tab: tab in: self.
	self updateGeometry
]

{ #category : 'resizing' }
BoFlap >> resizeTo: aNumber [
	"Open the flap with a new thickness, kept between the minimum and the maximum, without animation"

	thickness := (aNumber max: self minThickness) min: self maxThickness.
	open := true.
	self rebuild
]

{ #category : 'private' }
BoFlap >> slideToCurrentPosition [
	| from to |
	self hasParent ifFalse: [ ^ self ].
	from := self position.
	to := self currentPosition.
	self addAnimation: (BlNumberTransition new
		from: 0;
		to: 1;
		duration: 200 milliSeconds;
		onStepDo: [ :aValue | self position: (from interpolateTo: to at: aValue) ];
		onFinishedDo: [ self position: self currentPosition ];
		yourself)
]

{ #category : 'accessing' }
BoFlap >> tab [
	^ tab
]

{ #category : 'accessing' }
BoFlap >> tabLength [
	^ tabLength
]

{ #category : 'accessing' }
BoFlap >> tabThickness [
	^ tabThickness
]

{ #category : 'accessing' }
BoFlap >> thickness [
	"Return the size of the pane perpendicular to the edge"

	^ thickness
]

{ #category : 'accessing' }
BoFlap >> thickness: aNumber [
	thickness := aNumber.
	self rebuild
]

{ #category : 'opening' }
BoFlap >> toggle [
	open
		ifTrue: [ self close ]
		ifFalse: [ self open ]
]

{ #category : 'private' }
BoFlap >> updateGeometry [
	"Size the pane to the side of the world and place the flap"

	self hasParent ifFalse: [ ^ self ].
	pane extent: (edge paneExtentFor: self in: self parent extent).
	self position: self currentPosition
]
