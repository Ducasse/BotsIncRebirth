"
I test BoFlapItemDragHandler
"
Class {
	#name : 'BoFlapItemDragHandlerTest',
	#superclass : 'BoSpaceTestCase',
	#category : 'Botsinc-Flap-Tests',
	#package : 'Botsinc-Flap-Tests'
}

{ #category : 'tests' }
BoFlapItemDragHandlerTest >> testCopyIsHeldUnderPointer [
	"Grabbing 15@10 inside the item keeps that point under the pointer, above the flap"

	| item sim copy |
	item := flap items first.
	sim := item eventSimulator.
	sim
		mouseDownAt: item boundsInSpace origin + (15 @ 10);
		mouseMoveAt: 35 @ 180;
		mouseMoveAt: 315 @ 370.
	copy := world children last.
	self assert: copy position equals: 300 @ 360.
	self assert: copy elevation elevation > flap elevation elevation.
	sim mouseUpAt: 315 @ 370.
	self assert: copy elevation elevation equals: 0
]

{ #category : 'tests' }
BoFlapItemDragHandlerTest >> testDragOutAddsCopyToWorld [
	flap items first eventSimulator dragBy: 200 @ 50.
	space settle.
	self assert: world children size equals: 2.
	self deny: world children last equals: flap.
	self assert: flap items size equals: 1
]

{ #category : 'tests' }
BoFlapItemDragHandlerTest >> testDropOnFlapDiscardsCopy [
	flap items first eventSimulator dragBy: 5 @ 5.
	space settle.
	self assert: world children asArray equals: { flap }
]
