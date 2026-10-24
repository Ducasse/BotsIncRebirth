"
I test BoFlapTabHandler: clicking toggles, dragging resizes.
"
Class {
	#name : 'BoFlapTabHandlerTest',
	#superclass : 'BoSpaceTestCase',
	#category : 'Botsinc-Flap-Tests',
	#package : 'Botsinc-Flap-Tests'
}

{ #category : 'tests' }
BoFlapTabHandlerTest >> testClickAfterDragToggles [
	flap tab eventSimulator dragBy: 60 @ 0.
	flap tab eventSimulator click.
	self deny: flap isOpen
]

{ #category : 'tests' }
BoFlapTabHandlerTest >> testClickToggles [
	"Wait between clicks, otherwise they form a double click"

	flap tab eventSimulator click.
	self deny: flap isOpen.
	(Delay forMilliseconds: 600) wait.
	flap tab eventSimulator click.
	self assert: flap isOpen
]

{ #category : 'tests' }
BoFlapTabHandlerTest >> testDragKeepsTabInWorld [
	flap tab eventSimulator dragBy: 2000 @ 0.
	space settle.
	self assert: flap thickness equals: 578
]

{ #category : 'tests' }
BoFlapTabHandlerTest >> testDragSetsThickness [
	flap tab eventSimulator dragBy: 60 @ 0.
	space settle.
	self assert: flap isOpen.
	self assert: flap thickness equals: 150
]
