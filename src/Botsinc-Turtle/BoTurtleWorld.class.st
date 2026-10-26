"
I am the surface on which turtles move and draw. The trails left by the turtles are kept in a layer behind the turtles.

	BoTurtleWorld example
"
Class {
	#name : 'BoTurtleWorld',
	#superclass : 'BlElement',
	#instVars : [
		'trails',
		'turtles'
	],
	#classVars : [
		'InteractionInstallers'
	],
	#category : 'Botsinc-Turtle',
	#package : 'Botsinc-Turtle'
}

{ #category : 'examples' }
BoTurtleWorld class >> example [
	"Three turtles, one for each look, drawing a square, a star and a spiral. Since jumpTo: changes the heading, each turtle sets it before drawing"

	<sampleInstance>
	| world bot circle triangle |
	world := self new.
	bot := world newTurtle.
	bot jumpTo: 150 @ 200; east; penColor: Color blue; penSize: 2.
	4 timesRepeat: [ bot go: 100; turnLeft: 90 ].
	circle := world newTurtle.
	circle lookLikeCircle; color: Color green; jumpTo: 400 @ 150; east; penColor: Color red.
	5 timesRepeat: [ circle go: 120; turnRight: 144 ].
	triangle := world newTurtle.
	triangle lookLikeTriangle; color: Color orange; jumpTo: 620 @ 300; east; penColor: Color magenta.
	1 to: 40 do: [ :i | triangle go: i * 3; turnLeft: 30 ].
	world openInSpace.
	^ world
]

{ #category : 'interactions' }
BoTurtleWorld class >> interactionInstallers [
	"Return the blocks, indexed by name, that install an interaction on each new world. Other packages add theirs with registerInteraction:named:, see initializeInteractions"

	^ InteractionInstallers ifNil: [ InteractionInstallers := Dictionary new ]

]

{ #category : 'interactions' }
BoTurtleWorld class >> registerInteraction: aBlock named: aSymbol [
	"aBlock will be evaluated with each new world as argument"

	self interactionInstallers at: aSymbol put: aBlock

]

{ #category : 'interactions' }
BoTurtleWorld class >> unregisterInteractionNamed: aSymbol [
	self interactionInstallers removeKey: aSymbol ifAbsent: [ ]

]

{ #category : 'drawing' }
BoTurtleWorld >> addLine: aSegment [
	trails addChild: aSegment
]

{ #category : 'turtles' }
BoTurtleWorld >> addTurtle: aTurtle [
	"Add aTurtle at the center of the receiver, unless it is already there"

	(turtles includes: aTurtle) ifTrue: [ ^ aTurtle ].
	turtles add: aTurtle.
	aTurtle world: self.
	self addChild: aTurtle.
	aTurtle placeAt: self startingPlace.
	^ aTurtle
]

{ #category : 'drawing' }
BoTurtleWorld >> clearTrails [
	"Remove all the trails left by the turtles"

	trails removeChildren
]

{ #category : 'drawing' }
BoTurtleWorld >> drawLineFrom: startPoint to: endPoint color: aColor width: aNumber [
	"Add a segment between startPoint and endPoint to the trails"

	^ self addLine: (self newLineFrom: startPoint to: endPoint color: aColor width: aNumber)
]

{ #category : 'initialization' }
BoTurtleWorld >> initialize [
	super initialize.
	turtles := OrderedCollection new.
	self
		background: Color white;
		constraintsDo: [ :c |
			c horizontal matchParent.
			c vertical matchParent ].
	trails := BlElement new
		constraintsDo: [ :c |
			c horizontal matchParent.
			c vertical matchParent ];
		preventMouseEvents;
		yourself.
	self addChild: trails.
	self initializeInteractions

]

{ #category : 'initialization' }
BoTurtleWorld >> initializeInteractions [
	"Let the packages that registered an interaction install it on the receiver, see BoTurtleWorld class>>registerInteraction:named:"

	self class interactionInstallers do: [ :each | each value: self ]

]

{ #category : 'adding' }
BoTurtleWorld >> newAnimatedTurtle [
	^ self addTurtle: BoAnimatedTurtle new
]

{ #category : 'drawing' }
BoTurtleWorld >> newLineFrom: startPoint to: endPoint color: aColor width: aNumber [
	"Return a segment that is not yet part of the trails, see addLine:"

	^ self
		setLine: (BlElement new
			outskirts: BlOutskirts centered;
			border: (BlBorder paint: aColor width: aNumber);
			preventMouseEvents;
			yourself)
		from: startPoint
		to: endPoint
]

{ #category : 'adding' }
BoTurtleWorld >> newTurtle [

	^ self addTurtle: BoTurtle new
]

{ #category : 'adding' }
BoTurtleWorld >> removeTurtle: aTurtle [
	turtles remove: aTurtle.
	aTurtle world: nil.
	aTurtle removeFromParent
]

{ #category : 'adding' }
BoTurtleWorld >> removeTurtles [
	turtles copy do: [ :each | self removeTurtle: each ]
]

{ #category : 'drawing' }
BoTurtleWorld >> setLine: aSegment from: startPoint to: endPoint [
	"Make aSegment join startPoint and endPoint"

	| origin |
	origin := startPoint min: endPoint.
	^ aSegment
		geometry: (BlPolylineGeometry vertices: { startPoint - origin. endPoint - origin });
		extent: ((endPoint - startPoint) abs max: 1 @ 1);
		position: origin;
		yourself
]

{ #category : 'accessing' }
BoTurtleWorld >> startingPlace [
	"Return the center of the receiver. Before being laid out the receiver has no extent, so we use the default size of a space"

	| anExtent |
	anExtent := self extent.
	(anExtent x = 0 or: [ anExtent y = 0 ]) ifTrue: [ anExtent := 800 @ 600 ].
	^ anExtent // 2
]

{ #category : 'accessing' }
BoTurtleWorld >> trails [
	"Return the segments drawn by the turtles"

	^ trails children
]

{ #category : 'accessing' }
BoTurtleWorld >> turtles [
	^ turtles
]
