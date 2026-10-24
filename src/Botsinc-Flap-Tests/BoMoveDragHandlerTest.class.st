"
I test BoMoveDragHandler
"
Class {
	#name : 'BoMoveDragHandlerTest',
	#superclass : 'BoSpaceTestCase',
	#category : 'Botsinc-Flap-Tests',
	#package : 'Botsinc-Flap-Tests'
}

{ #category : 'tests' }
BoMoveDragHandlerTest >> testCopyCanBeMoved [
	| copy start |
	flap items first eventSimulator dragBy: 200 @ 50.
	space settle.
	copy := world children last.
	start := copy position.
	copy eventSimulator dragBy: 30 @ 20.
	space settle.
	self assert: copy position equals: start + (30 @ 20)
]
