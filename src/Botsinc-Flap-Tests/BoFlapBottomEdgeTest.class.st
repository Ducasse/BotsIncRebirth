"
I test BoFlapBottomEdge
"
Class {
	#name : 'BoFlapBottomEdgeTest',
	#superclass : 'BoFlapEdgeTestCase',
	#category : 'Botsinc-Flap-Tests',
	#package : 'Botsinc-Flap-Tests'
}

{ #category : 'tests' }
BoFlapBottomEdgeTest >> testPositions [
	| edge |
	edge := BoFlapEdge bottom.
	self assert: (edge openPositionOf: flap in: self worldExtent) equals: 150 @ 288.
	self assert: (edge closedPositionOf: flap in: self worldExtent) equals: 150 @ 378
]

{ #category : 'tests' }
BoFlapBottomEdgeTest >> testTabComesBeforePane [
	flap edge: BoFlapEdge bottom.
	self assert: flap children asArray equals: { flap tab. flap pane }
]
