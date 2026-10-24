"
I test BoFlapRightEdge
"
Class {
	#name : 'BoFlapRightEdgeTest',
	#superclass : 'BoFlapEdgeTestCase',
	#category : 'Botsinc-Flap-Tests',
	#package : 'Botsinc-Flap-Tests'
}

{ #category : 'tests' }
BoFlapRightEdgeTest >> testPositions [
	| edge |
	edge := BoFlapEdge right.
	self assert: (edge openPositionOf: flap in: self worldExtent) equals: 488 @ 50.
	self assert: (edge closedPositionOf: flap in: self worldExtent) equals: 578 @ 50
]

{ #category : 'tests' }
BoFlapRightEdgeTest >> testTabComesBeforePane [
	flap edge: BoFlapEdge right.
	self assert: flap children asArray equals: { flap tab. flap pane }
]
