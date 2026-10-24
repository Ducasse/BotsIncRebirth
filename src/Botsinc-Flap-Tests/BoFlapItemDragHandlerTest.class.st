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
