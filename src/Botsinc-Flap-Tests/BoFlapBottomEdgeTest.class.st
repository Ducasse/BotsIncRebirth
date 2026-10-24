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
BoFlapBottomEdgeTest >> testGrowth [
	self assert: (BoFlapEdge bottom growthFor: 10 @ 3) equals: -3
]

{ #category : 'tests' }
BoFlapBottomEdgeTest >> testPositions [
	| edge |
	edge := BoFlapEdge bottom.
	self assert: (edge openPositionOf: flap in: self worldExtent) equals: 0 @ 288.
	self assert: (edge closedPositionOf: flap in: self worldExtent) equals: 0 @ 378
]

{ #category : 'tests' }
BoFlapBottomEdgeTest >> testTabComesBeforePane [
	flap edge: BoFlapEdge bottom.
	self assert: flap children asArray equals: { flap tab. flap pane }
]
