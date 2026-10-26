"
I am a flap, in the spirit of Squeak Supplies flaps: a drawer stuck to one edge of a world element, holding prototypes of graphical objects. I span the whole side of the world I am attached to, and follow it when it is resized.

Instead of prototypes, I can hold tools such as micro playgrounds (see addContent:). They are placed along my edge, side by side in a top or bottom flap and stacked in a left or right flap, and each takes its share of my pane (see addContent:share:): a micro playground takes half of it.

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
BoFlap >> addContent: anElement [
	"Add anElement, a tool such as a playground, to the pane, see addContent:share:"

	self addContent: anElement share: 1
]

{ #category : 'adding' }
BoFlap >> addContent: anElement share: aFraction [
	"Add anElement, a tool such as a playground, to the pane. The tools are placed along my edge. anElement takes aFraction of the length of the pane, 1 being the whole pane, and fills its thickness, even when it floats over its parent elsewhere, such as an inner window. When the shares of the tools add up to more than 1, the tools share the pane in proportion"

	pane layout: edge contentLayout.
	anElement constraintsDo: [ :c |
			c accountByLayout.
			c horizontal matchParent.
			c vertical matchParent.
			c linear weight: aFraction ].
	pane addChild: anElement.
	anElement addEventHandlerOn: BlElementRemovedFromParentEvent do: [ :anEvent | self updateShares ].
	self updateShares
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

{ #category : 'adding' }
BoFlap >> content: anElement [
	"Fill the pane with anElement, a tool such as a playground, instead of prototypes or other tools"

	pane removeChildren.
	self addContent: anElement
]

{ #category : 'accessing' }
BoFlap >> contents [
	"Return the tools that the pane holds, see addContent:"

	^ pane children asArray
]

{ #category : 'private' }
BoFlap >> currentPosition [
	^ open
		ifTrue: [ edge openPositionOf: self in: self parent extent ]
		ifFalse: [ edge closedPositionOf: self in: self parent extent ]
]

{ #category : 'initialization' }
BoFlap >> defaultElevation [
	"A flap passes over the windows of the world, even the window brought to the front by Toplo (see ToBasicWindowElement>>defaultElevation, SmallInteger maxVal - 1000), but stays below the menus and tooltips of Toplo"

	^ BlRelativeElevation elevation: SmallInteger maxVal - 950
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
	self elevation: self defaultElevation.
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
	"The clicks in the pane do not reach the world, so that they do not open talk bubbles"

	^ BlElement new
		  layout: BlFlowLayout horizontal;
		  padding: (BlInsets all: 6);
		  background: (Color gray: 0.92);
		  border: (BlBorder paint: Color gray width: 1);
		  clipChildren: true;
		  addEventHandlerOn: BlClickEvent do: [ :anEvent | anEvent consumed: true ];
		  yourself
]

{ #category : 'initialization' }
BoFlap >> newTab [
	"The geometry of the tab depends on the edge, see rebuild"

	^ BlElement new
		  background: Color orange;
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
	tab geometry: (BlRoundedRectangleGeometry cornerRadii: (edge tabCornerRadii: 6)).
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

{ #category : 'private' }
BoFlap >> updateShares [
	"The length of the pane is 1, unless the tools ask for more, see addContent:share:"

	(pane layout isKindOf: BlLinearLayout) ifFalse: [ ^ self ].
	pane layout weightSum: ((pane children inject: 0 into: [ :sum :each | sum + each constraints linear weight ]) max: 1)
]
