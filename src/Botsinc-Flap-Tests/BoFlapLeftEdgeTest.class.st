"
I test BoFlapLeftEdge
"
Class {
	#name : 'BoFlapLeftEdgeTest',
	#superclass : 'BoFlapEdgeTestCase',
	#category : 'Botsinc-Flap-Tests',
	#package : 'Botsinc-Flap-Tests'
}

{ #category : 'tests' }
BoFlapLeftEdgeTest >> testGrowth [
	self assert: (BoFlapEdge left growthFor: 10 @ 3) equals: 10
]

{ #category : 'tests' }
BoFlapLeftEdgeTest >> testPaneComesBeforeTab [
	flap edge: BoFlapEdge left.
	flap forceLayout.
	self assert: flap children asArray equals: { flap pane. flap tab }.
	self assert: flap pane extent equals: 90 @ 300
]

{ #category : 'tests' }
BoFlapLeftEdgeTest >> testPositions [
	| edge |
	edge := BoFlapEdge left.
	self assert: (edge openPositionOf: flap in: self worldExtent) equals: 0 @ 50.
	self assert: (edge closedPositionOf: flap in: self worldExtent) equals: -90 @ 50
]
