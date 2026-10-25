"
I am the surface on which turtles move and draw. The trails left by the turtles are kept in a layer behind the turtles.

	BoTurtleWorld example
"
Class {
	#name : 'BoTurtleWorld',
	#superclass : 'BlElement',
	#instVars : [
		'trails'
	],
	#category : 'Botsinc-Turtle',
	#package : 'Botsinc-Turtle'
}

{ #category : 'examples' }
BoTurtleWorld class >> example [
	"Three turtles, one for each look, drawing a square, a star and a spiral"

	<sampleInstance>
	| world bot circle triangle |
	world := self new.
	bot := world newTurtle.
	bot jumpTo: 150 @ 200; penColor: Color blue; penSize: 2.
	4 timesRepeat: [ bot go: 100; turnLeft: 90 ].
	circle := world newTurtle.
	circle lookLikeCircle; color: Color green; jumpTo: 400 @ 150; penColor: Color red.
	5 timesRepeat: [ circle go: 120; turnRight: 144 ].
	triangle := world newTurtle.
	triangle lookLikeTriangle; color: Color orange; jumpTo: 620 @ 300; penColor: Color magenta.
	1 to: 40 do: [ :i | triangle go: i * 3; turnLeft: 30 ].
	world openInSpace.
	^ world
]

{ #category : 'drawing' }
BoTurtleWorld >> addLine: aSegment [
	trails addChild: aSegment
]

{ #category : 'adding' }
BoTurtleWorld >> addTurtle: aTurtle [
	"Add aTurtle at the center of the receiver"

	self addChild: aTurtle.
	aTurtle home.
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
	self addChild: trails
]

{ #category : 'testing' }
BoTurtleWorld >> isTurtleWorld [
	^ true
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
BoTurtleWorld >> removeTurtles [

	self turtles do: [ :each | each removeFromParent ]
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

	^ self children select: [ :each | each isTurtle ]
]
