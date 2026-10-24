"
I am the superclass of tests that simulate events: they need a shown space, closed in tearDown.
"
Class {
	#name : 'BoSpaceTestCase',
	#superclass : 'TestCase',
	#instVars : [
		'space',
		'world',
		'flap'
	],
	#category : 'Botsinc-Flap-Tests',
	#package : 'Botsinc-Flap-Tests'
}

{ #category : 'testing' }
BoSpaceTestCase class >> isAbstract [
	^ self == BoSpaceTestCase
]

{ #category : 'running' }
BoSpaceTestCase >> setUp [
	super setUp.
	space := BlSpace new.
	space extent: 600 @ 400.
	world := BlElement new
		constraintsDo: [ :c |
			c horizontal matchParent.
			c vertical matchParent ];
		yourself.
	space root addChild: world.
	flap := BoFlap new.
	flap addPrototype: [ BlElement new extent: 40 @ 40; background: Color red; yourself ].
	flap attachTo: world.
	flap open.
	space show.
	space settle.
	(Delay forMilliseconds: 300) wait.
	space settle
]

{ #category : 'running' }
BoSpaceTestCase >> tearDown [
	space close.
	super tearDown
]
