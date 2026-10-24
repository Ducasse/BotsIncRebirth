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
	flap forceLayout.
	self assert: flap pane extent equals: 300 @ 90.
	self assert: flap tab extent equals: 70 @ 22
]

{ #category : 'tests' }
BoFlapTopEdgeTest >> testPositions [
	| edge |
	edge := BoFlapEdge top.
	self assert: (edge openPositionOf: flap in: self worldExtent) equals: 150 @ 0.
	self assert: (edge closedPositionOf: flap in: self worldExtent) equals: 150 @ -90
]
