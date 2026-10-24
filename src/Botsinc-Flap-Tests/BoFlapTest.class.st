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
BoFlapTest >> testAttachPlacesFlapClosed [
	| world flap |
	world := BlElement new extent: 600 @ 400; yourself.
	flap := BoFlap new.
	flap attachTo: world.
	world forceLayout.
	self assert: flap parent equals: world.
	self assert: flap position equals: -90 @ 50
]

{ #category : 'tests' }
BoFlapTest >> testIsClosedByDefault [
	self deny: BoFlap new isOpen
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
