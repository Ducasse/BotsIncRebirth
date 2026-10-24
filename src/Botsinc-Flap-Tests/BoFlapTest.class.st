"
I test BoFlap without opening a window.
"
Class {
	#name : 'BoFlapTest',
	#superclass : 'TestCase',
	#category : 'Botsinc-Flap-Tests',
	#package : 'Botsinc-Flap-Tests'
}

{ #category : 'tests' }
BoFlapTest >> testAddPrototypeCreatesItem [
	| flap |
	flap := BoFlap new.
	flap addPrototype: [ BlElement new extent: 20 @ 20; yourself ].
	self assert: flap prototypes size equals: 1.
	self assert: flap items size equals: 1
]

{ #category : 'tests' }
BoFlapTest >> testAttachMakesWorldFillItsParent [
	| world |
	world := BlElement new.
	BoFlap new attachTo: world.
	self assert: world constraints horizontal resizer isMatchParent.
	self assert: world constraints vertical resizer isMatchParent
]

{ #category : 'tests' }
BoFlapTest >> testAttachPlacesFlapClosed [
	| parent world flap |
	parent := BlElement new extent: 600 @ 400; yourself.
	world := BlElement new.
	parent addChild: world.
	flap := BoFlap new.
	flap attachTo: world.
	parent forceLayout.
	self assert: flap position equals: -90 @ 0
]

{ #category : 'tests' }
BoFlapTest >> testIsClosedByDefault [
	self deny: BoFlap new isOpen
]

{ #category : 'tests' }
BoFlapTest >> testPaneFollowsWorldResize [
	| parent world flap |
	parent := BlElement new extent: 600 @ 400; yourself.
	world := BlElement new.
	parent addChild: world.
	flap := BoFlap new.
	flap attachTo: world.
	parent forceLayout.
	parent extent: 500 @ 300.
	parent forceLayout.
	self assert: flap pane extent equals: 90 @ 300
]

{ #category : 'tests' }
BoFlapTest >> testResizeToIsClampedToMinimum [
	| flap |
	flap := BoFlap new.
	flap resizeTo: 5.
	self assert: flap thickness equals: flap minThickness.
	self assert: flap isOpen
]

{ #category : 'tests' }
BoFlapTest >> testToggle [
	| flap |
	flap := BoFlap new.
	flap toggle.
	self assert: flap isOpen.
	flap toggle.
	self deny: flap isOpen
]
