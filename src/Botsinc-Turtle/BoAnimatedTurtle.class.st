"
I am a turtle whose moves and turns are animated, so that one can follow what a script does.

A script must run outside of the UI process, otherwise the world is not redrawn while I wait between two steps. When I am asked to move from the UI process, or when I am not displayed, I behave like a BoTurtle and move at once.

	| world turtle |
	world := BoTurtleWorld new.
	world openInSpace.
	turtle := world newAnimatedTurtle.
	turtle animate: [ :t | 36 timesRepeat: [ t go: 150; turnLeft: 170 ] ]

My speed is in pixels per second, turns are made at two degrees per pixel. A Monitor prevents two scripts from mixing the moves of the same turtle.
"
Class {
	#name : 'BoAnimatedTurtle',
	#superclass : 'BoTurtle',
	#instVars : [
		'speed',
		'actionMonitor'
	],
	#category : 'Botsinc-Turtle',
	#package : 'Botsinc-Turtle'
}

{ #category : 'examples' }
BoAnimatedTurtle class >> example [
	"An animated turtle drawing a star with 36 branches"

	<sampleInstance>
	| world turtle |
	world := BoTurtleWorld new.
	world openInSpace.
	turtle := world newAnimatedTurtle.
	turtle penColor: Color blue.
	turtle animate: [ :t |
		t jumpTo: 300 @ 300; east.
		36 timesRepeat: [ t go: 200; turnLeft: 170 ] ].
	^ world
]

{ #category : 'scripting' }
BoAnimatedTurtle >> animate: aBlock [
	"Run aBlock with the receiver as argument in its own process so that the world is redrawn between the steps"

	^ [ aBlock value: self ] forkAt: Processor userBackgroundPriority named: 'BoTurtle script'
]

{ #category : 'private' }
BoAnimatedTurtle >> degreesPerStep [
	^ self pixelsPerStep * 2
]

{ #category : 'basic operations' }
BoAnimatedTurtle >> go: distance [
	self performAction: [ super go: distance ]
]

{ #category : 'basic operations' }
BoAnimatedTurtle >> goTo: aPoint [
	self performAction: [ super goTo: aPoint ]
]

{ #category : 'private' }
BoAnimatedTurtle >> inUIDo: aBlock [
	"The scene graph must only be changed by the UI process"

	self isAnimating
		ifTrue: [ self enqueueTask: (BlTaskAction new action: aBlock; yourself) ]
		ifFalse: [ aBlock value ]
]

{ #category : 'initialization' }
BoAnimatedTurtle >> initialize [
	actionMonitor := Monitor new.
	speed := 300.
	super initialize.
	color := Color green
]

{ #category : 'testing' }
BoAnimatedTurtle >> isAnimating [
	"Waiting between two steps is only possible when the receiver is displayed and we are not in the UI process"

	^ self isAttachedToSceneGraph and: [ self space isPulseProcessActive not ]
]

{ #category : 'basic operations' }
BoAnimatedTurtle >> jump: distance [
	self performAction: [ super jump: distance ]
]

{ #category : 'basic operations' }
BoAnimatedTurtle >> jumpTo: aPoint [
	self performAction: [ super jumpTo: aPoint ]
]

{ #category : 'private' }
BoAnimatedTurtle >> moveTo: aPoint trail: aBoolean [
	"Move to aPoint in small steps. A single segment of the trail follows the receiver"

	| start steps segment |
	self isAnimating ifFalse: [ ^ super moveTo: aPoint trail: aBoolean ].
	start := location.
	segment := (aBoolean and: [ self turtleWorld notNil ])
		ifTrue: [ self newTrailFrom: start ]
		ifFalse: [ nil ].
	steps := ((start distanceTo: aPoint) / self pixelsPerStep) ceiling max: 1.
	1 to: steps do: [ :i |
		| aLocation |
		aLocation := i = steps
			ifTrue: [ aPoint ]
			ifFalse: [ start + ((aPoint - start) * i / steps) ].
		location := aLocation.
		segment ifNotNil: [
			self inUIDo: [ self turtleWorld setLine: segment from: start to: aLocation ] ].
		self updatePosition.
		self waitStep ]
]

{ #category : 'private' }
BoAnimatedTurtle >> newTrailFrom: aPoint [
	| aWorld segment |
	aWorld := self turtleWorld.
	segment := aWorld newLineFrom: aPoint to: aPoint color: penColor width: penSize.
	self inUIDo: [ aWorld addLine: segment ].
	^ segment
]

{ #category : 'private' }
BoAnimatedTurtle >> performAction: aBlock [
	actionMonitor critical: aBlock
]

{ #category : 'private' }
BoAnimatedTurtle >> pixelsPerStep [
	^ speed * self stepDuration asMilliSeconds / 1000
]

{ #category : 'accessing' }
BoAnimatedTurtle >> speed [
	"Return the speed in pixels per second"

	^ speed
]

{ #category : 'accessing' }
BoAnimatedTurtle >> speed: aNumber [
	speed := aNumber max: 1
]

{ #category : 'private' }
BoAnimatedTurtle >> stepDuration [
	"About one frame"

	^ 16 milliSeconds
]

{ #category : 'private' }
BoAnimatedTurtle >> stepwiseTurn: degrees to: anAngle [
	"Turn by degrees in small steps. The last step sets anAngle exactly, so that no rounding error accumulates"

	| start steps |
	(self isAnimating and: [ degrees ~= 0 ]) ifFalse: [ ^ self direction: anAngle ].
	start := direction.
	steps := (degrees abs / self degreesPerStep) ceiling max: 1.
	1 to: steps - 1 do: [ :i |
		self direction: start + (degrees * i / steps).
		self waitStep ].
	self direction: anAngle.
	self waitStep
]

{ #category : 'turning' }
BoAnimatedTurtle >> turn: degrees [
	self performAction: [ self stepwiseTurn: degrees to: direction + degrees ]
]

{ #category : 'turning' }
BoAnimatedTurtle >> turnTo: anAngle [
	"Turn by the shortest way"

	self performAction: [ self stepwiseTurn: (self canonicalAngle: anAngle - direction) to: anAngle ]
]

{ #category : 'private' }
BoAnimatedTurtle >> updatePosition [
	| aPosition |
	aPosition := location - (bodyExtent / 2).
	self inUIDo: [ self position: aPosition ]
]

{ #category : 'private' }
BoAnimatedTurtle >> updateRotation [
	| anAngle |
	anAngle := direction.
	self inUIDo: [ self transformDo: [ :t | t rotateBy: anAngle negated ] ]
]

{ #category : 'private' }
BoAnimatedTurtle >> waitStep [
	self stepDuration wait
]
