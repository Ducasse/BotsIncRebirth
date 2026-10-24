"
I test BoFlapTopEdge
"
Class {
	#name : 'BoFlapTopEdgeTest',
	#superclass : 'BoFlapEdgeTestCase',
	#category : 'Botsinc-Flap-Tests',
	#package : 'Botsinc-Flap-Tests'
}

{ #category : 'tests' }
BoFlapTopEdgeTest >> testGrowth [
	self assert: (BoFlapEdge top growthFor: 10 @ 3) equals: 3
]

{ #category : 'tests' }
BoFlapTopEdgeTest >> testPaneIsWide [
	flap edge: BoFlapEdge top.
	self attachToWorld.
	self assert: flap pane extent equals: 600 @ 90.
	self assert: flap tab extent equals: 70 @ 22
]

{ #category : 'tests' }
BoFlapTopEdgeTest >> testPositions [
	| edge |
	edge := BoFlapEdge top.
	self assert: (edge openPositionOf: flap in: self worldExtent) equals: 0 @ 0.
	self assert: (edge closedPositionOf: flap in: self worldExtent) equals: 0 @ -90
]
