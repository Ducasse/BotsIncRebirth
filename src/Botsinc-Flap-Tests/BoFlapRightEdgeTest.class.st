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
BoFlapRightEdgeTest >> testGrowth [
	self assert: (BoFlapEdge right growthFor: 10 @ 3) equals: -10
]

{ #category : 'tests' }
BoFlapRightEdgeTest >> testPositions [
	| edge |
	edge := BoFlapEdge right.
	self assert: (edge openPositionOf: flap in: self worldExtent) equals: 488 @ 0.
	self assert: (edge closedPositionOf: flap in: self worldExtent) equals: 578 @ 0
]

{ #category : 'tests' }
BoFlapRightEdgeTest >> testTabComesBeforePane [
	flap edge: BoFlapEdge right.
	self assert: flap children asArray equals: { flap tab. flap pane }
]
