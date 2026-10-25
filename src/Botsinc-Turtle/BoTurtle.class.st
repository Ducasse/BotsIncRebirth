"
I am a Logo-like turtle. I move on a BoTurtleWorld and leave a trail when I go forward.

My location is my center. My direction is an angle in degrees, between -179 and 180: 0 is east, 90 is north, 180 is west and -90 is south. Positive turns are anticlockwise.

	| world turtle |
	world := BoTurtleWorld new.
	turtle := world newTurtle.
	4 timesRepeat: [ turtle go: 100; turnLeft: 90 ].
	world openInSpace
"
Class {
	#name : 'BoTurtle',
	#superclass : 'BlElement',
	#instVars : [
		'location',
		'direction',
		'color',
		'penColor',
		'penSize',
		'shape',
		'vars',
		'memorizedPoints',
		'bodyExtent',
		'world'
	],
	#category : 'Botsinc-Turtle',
	#package : 'Botsinc-Turtle'
}

{ #category : 'operations' }
BoTurtle >> absoluteAngleToPointAt: aPoint [
	"Return the direction the receiver should have to point at aPoint"

	| dx dy |
	dx := aPoint x - location x.
	dy := aPoint y - location y.
	^ dx > 0
		ifTrue: [ (dy / dx) arcTan radiansToDegrees negated ]
		ifFalse: [
			dx < 0
				ifTrue: [ 180 + (dy / dx) arcTan radiansToDegrees negated ]
				ifFalse: [ 90 * dy negated sign ] ]
]

{ #category : 'shapes' }
BoTurtle >> addBotShape [
	"Two wheels along the heading, a body, a nose and an antenna with a red tip showing the heading"

	| center diameter radius wheel nose |
	center := bodyExtent / 2.
	diameter := bodyExtent x min: bodyExtent y.
	radius := diameter / 2.
	wheel := diameter * 0.55 @ (diameter * 0.14).
	self
		addPart: (BlRoundedRectangleGeometry cornerRadius: wheel y / 2)
		extent: wheel
		at: center - (0 @ (radius * 0.72))
		color: Color darkGray.
	self
		addPart: (BlRoundedRectangleGeometry cornerRadius: wheel y / 2)
		extent: wheel
		at: center + (0 @ (radius * 0.72))
		color: Color darkGray.
	self
		addPart: BlEllipseGeometry new
		extent: (diameter * 0.62) asPoint
		at: center
		color: color.
	nose := radius * 0.4 @ (radius * 0.5).
	self
		addPart: (BlPolygonGeometry vertices: {
					 (0 @ 0).
					 (0 @ nose y).
					 (nose x @ (nose y / 2)) })
		extent: nose
		at: center + (radius * 0.28 @ 0)
		color: Color white.
	self
		addPart: BlRectangleGeometry new
		extent: radius - 3 @ 2
		at: center + (radius - 3 / 2 @ 0)
		color: Color black.
	self
		addPart: BlEllipseGeometry new
		extent: 6 @ 6
		at: center + (radius - 3 @ 0)
		color: Color red
]

{ #category : 'shapes' }
BoTurtle >> addCircleShape [
	| center diameter |
	center := bodyExtent / 2.
	diameter := bodyExtent x min: bodyExtent y.
	self addPart: BlEllipseGeometry new extent: (diameter * 0.85) asPoint at: center color: color.
	self addPart: BlRectangleGeometry new extent: (diameter / 2 - 1) @ 2 at: center + ((diameter / 2 - 1) / 2 @ 0) color: Color black
]

{ #category : 'shapes' }
BoTurtle >> addPart: aGeometry extent: anExtent at: aCenter color: aColor [
	self addChild: (BlElement new
		geometry: aGeometry;
		extent: anExtent;
		position: aCenter - (anExtent / 2);
		background: aColor;
		yourself)
]

{ #category : 'shapes' }
BoTurtle >> addTriangleShape [
	| radius corner |
	radius := (bodyExtent x min: bodyExtent y) / 2.
	corner := (radius / 2 sqrt) truncated.
	self addChild: (BlElement new
		geometry: (BlPolygonGeometry vertices: {
			(radius - corner) @ (radius - corner + 2).
			(radius - corner) @ (radius + corner - 2).
			(2 * radius) @ radius });
		extent: bodyExtent;
		position: (bodyExtent / 2) - radius;
		background: color;
		yourself)
]

{ #category : 'operations' }
BoTurtle >> angleToPointAt: aPoint [
	"Return the angle between the current direction and the direction pointing at aPoint"

	^ (self absoluteAngleToPointAt: aPoint) - (direction \\ 360)
]

{ #category : 'operations' }
BoTurtle >> angleToPointInDirection: anAngle [
	^ self canonicalAngle: anAngle - direction
]

{ #category : 'looks' }
BoTurtle >> beInvisible [
	self visibility: BlVisibility hidden
]

{ #category : 'looks' }
BoTurtle >> beVisible [
	self visibility: BlVisibility visible
]

{ #category : 'accessing' }
BoTurtle >> bodyExtent [
	"Return the extent of the receiver. Unlike extent, it is known before the receiver is laid out"

	^ bodyExtent
]

{ #category : 'private' }
BoTurtle >> canonicalAngle: anAngle [
	"Return anAngle between -179 and 180"

	| angle |
	angle := anAngle \\ 360.
	^ angle > 180
		ifTrue: [ angle - 360 ]
		ifFalse: [ angle ]
]

{ #category : 'accessing' }
BoTurtle >> center [
	"Return the location of the receiver, which is the point where its pen draws"

	^ location
]

{ #category : 'looks' }
BoTurtle >> color [
	^ color
]

{ #category : 'looks' }
BoTurtle >> color: aColor [
	color := aColor.
	self rebuildShape
]

{ #category : 'initialization' }
BoTurtle >> defaultExtent [
	^ 50 @ 50
]

{ #category : 'accessing' }
BoTurtle >> direction [
	^ direction
]

{ #category : 'private' }
BoTurtle >> direction: anAngle [
	direction := self canonicalAngle: anAngle.
	self updateRotation
]

{ #category : 'operations' }
BoTurtle >> distanceFrom: aPoint [
	^ location distanceTo: aPoint
]

{ #category : 'directions' }
BoTurtle >> down [
	"Make the receiver point to the bottom of the screen"

	self south
]

{ #category : 'private' }
BoTurtle >> drawTrailFrom: startPoint to: endPoint [
	self turtleWorld ifNotNil: [ :aWorld |
		aWorld drawLineFrom: startPoint to: endPoint color: penColor width: penSize ]
]

{ #category : 'absolute directions' }
BoTurtle >> east [
	self turnTo: 0
]

{ #category : 'accessing' }
BoTurtle >> extent: aPoint [
	"Change the size of the receiver, keeping its center at the same place"

	bodyExtent := aPoint.
	super extent: aPoint.
	self rebuildShape.
	self updatePosition
]

{ #category : 'looks' }
BoTurtle >> foreground [
	"Bring the receiver in front of the other turtles"

	| aParent |
	self hasParent ifFalse: [ ^ self ].
	aParent := self parent.
	self removeFromParent.
	aParent addChild: self
]

{ #category : 'basic operations' }
BoTurtle >> go: distance [
	"Make the receiver go forward from a given distance, leaving a trail"

	self moveTo: (self positionInDirectionForDistance: distance) trail: true
]

{ #category : 'basic operations' }
BoTurtle >> goTo: aPoint [
	"Make the receiver head to aPoint and go there, leaving a trail. The receiver keeps its new heading"

	self headTo: aPoint.
	self moveTo: aPoint trail: true
]

{ #category : 'private' }
BoTurtle >> headTo: aPoint [
	"Make the receiver point at aPoint, unless it is already there"

	aPoint = location ifTrue: [ ^ self ].
	self pointAt: aPoint
]

{ #category : 'basic operations' }
BoTurtle >> home [
	"Make the receiver jump to the center of its world. Like any jump, the receiver heads to the center"

	self jumpTo: self startingPlace
]

{ #category : 'initialization' }
BoTurtle >> initialize [
	super initialize.
	location := 0 @ 0.
	direction := 0.
	color := Color blue alpha: 0.85.
	penColor := Color black.
	penSize := 1.
	shape := #addBotShape.
	vars := Dictionary new.
	memorizedPoints := OrderedCollection new.
	self preventMeAndChildrenMouseEvents.
	self extent: self defaultExtent
]

{ #category : 'variables' }
BoTurtle >> isVariableDefined: aSymbol [
	^ vars includesKey: aSymbol
]

{ #category : 'basic operations' }
BoTurtle >> jump: distance [
	"Make the receiver go forward from a given distance without leaving a trail"

	self moveTo: (self positionInDirectionForDistance: distance) trail: false
]

{ #category : 'basic operations' }
BoTurtle >> jumpTo: aPoint [
	"Make the receiver head to aPoint and jump there without leaving a trail. The receiver keeps its new heading"

	self headTo: aPoint.
	self moveTo: aPoint trail: false
]

{ #category : 'directions' }
BoTurtle >> left [
	"Make the receiver point to the left of the screen"

	self west
]

{ #category : 'looks' }
BoTurtle >> lookLikeBot [
	self shape: #addBotShape
]

{ #category : 'looks' }
BoTurtle >> lookLikeCircle [
	self shape: #addCircleShape
]

{ #category : 'looks' }
BoTurtle >> lookLikeTriangle [
	self shape: #addTriangleShape
]

{ #category : 'memory' }
BoTurtle >> memorizedPoints [
	^ memorizedPoints
]

{ #category : 'private' }
BoTurtle >> moveTo: aPoint trail: aBoolean [
	"Place the center of the receiver at aPoint without changing its heading"

	aBoolean ifTrue: [ self drawTrailFrom: location to: aPoint ].
	location := aPoint.
	self updatePosition
]

{ #category : 'absolute directions' }
BoTurtle >> north [
	self turnTo: 90
]

{ #category : 'absolute directions' }
BoTurtle >> northEast [
	self turnTo: 45
]

{ #category : 'absolute directions' }
BoTurtle >> northWest [
	self turnTo: 135
]

{ #category : 'pen' }
BoTurtle >> penColor [
	^ penColor
]

{ #category : 'pen' }
BoTurtle >> penColor: aColor [
	penColor := aColor
]

{ #category : 'pen' }
BoTurtle >> penSize [
	^ penSize
]

{ #category : 'pen' }
BoTurtle >> penSize: aNumber [
	penSize := aNumber
]

{ #category : 'private' }
BoTurtle >> placeAt: aPoint [
	"Put the center of the receiver at aPoint at once, without heading to it nor animation. Used to install the receiver in a world"

	location := aPoint.
	self updatePosition
]

{ #category : 'turning' }
BoTurtle >> pointAt: aPoint [
	self turnTo: (self absoluteAngleToPointAt: aPoint)
]

{ #category : 'operations' }
BoTurtle >> positionInDirectionForDistance: aDistance [
	"Return the point at aDistance in the direction of the receiver"

	^ location + (direction degreeCos @ direction degreeSin negated * aDistance) rounded
]

{ #category : 'printing' }
BoTurtle >> printOn: aStream [
	super printOn: aStream.
	aStream
		nextPutAll: ' direction: ';
		print: direction;
		nextPutAll: ' position: ';
		print: location
]

{ #category : 'shapes' }
BoTurtle >> rebuildShape [
	"The shape is drawn pointing to the east, the rotation is done by the transformation of the receiver"

	self removeChildren.
	self perform: shape
]

{ #category : 'memory' }
BoTurtle >> rememberPosition [
	memorizedPoints add: location
]

{ #category : 'memory' }
BoTurtle >> resetMemorizedPoints [
	memorizedPoints := OrderedCollection new
]

{ #category : 'directions' }
BoTurtle >> right [
	"Make the receiver point to the right of the screen"

	self east
]

{ #category : 'variables' }
BoTurtle >> set: aSymbol to: anObject [
	"Define a turtle variable named aSymbol with anObject as value"

	vars at: aSymbol put: anObject
]

{ #category : 'private' }
BoTurtle >> shape: aSelector [
	shape := aSelector.
	self rebuildShape
]

{ #category : 'absolute directions' }
BoTurtle >> south [
	self turnTo: 270
]

{ #category : 'absolute directions' }
BoTurtle >> southEast [
	self turnTo: 315
]

{ #category : 'absolute directions' }
BoTurtle >> southWest [
	self turnTo: 225
]

{ #category : 'accessing' }
BoTurtle >> startingPlace [
	^ self turtleWorld
		ifNil: [ 0 @ 0 ]
		ifNotNil: [ :aWorld | aWorld startingPlace ]
]

{ #category : 'turning' }
BoTurtle >> turn: degrees [
	"Change the direction of the receiver by degrees. As in trigonometry, a positive number turns anticlockwise and a negative one clockwise"

	self direction: direction + degrees
]

{ #category : 'turning' }
BoTurtle >> turnLeft: degrees [
	self turn: degrees
]

{ #category : 'turning' }
BoTurtle >> turnRight: degrees [
	self turn: degrees negated
]

{ #category : 'turning' }
BoTurtle >> turnTo: anAngle [
	"Make the receiver point at the absolute angle anAngle. See the class comment"

	self direction: anAngle
]

{ #category : 'accessing' }
BoTurtle >> turtleWorld [
	"Return the world in which the receiver lives or nil"

	^ world
]

{ #category : 'directions' }
BoTurtle >> up [
	"Make the receiver point to the top of the screen"

	self north
]

{ #category : 'private' }
BoTurtle >> updatePosition [
	self position: location - (bodyExtent / 2)
]

{ #category : 'private' }
BoTurtle >> updateRotation [
	"The shape is drawn pointing to the east, Bloc rotates clockwise"

	self transformDo: [ :t | t rotateBy: direction negated ]
]

{ #category : 'variables' }
BoTurtle >> valueOf: aSymbol [
	^ vars
		at: aSymbol
		ifAbsent: [ self error: 'the turtle variable ' , aSymbol asString , ' is not defined' ]
]

{ #category : 'absolute directions' }
BoTurtle >> west [
	self turnTo: 180
]

{ #category : 'accessing' }
BoTurtle >> world: aTurtleWorld [
	"Set the world in which the receiver lives, see BoTurtleWorld>>addTurtle:"

	world := aTurtleWorld
]
