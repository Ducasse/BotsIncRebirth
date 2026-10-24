"
I am the top edge of a world.
"
Class {
	#name : 'BoFlapTopEdge',
	#superclass : 'BoFlapHorizontalEdge',
	#category : 'Botsinc-Flap',
	#package : 'Botsinc-Flap'
}

{ #category : 'layout' }
BoFlapTopEdge >> arrangePane: aPane tab: aTab in: aFlap [
	aFlap addChildren: { aPane. aTab }
]

{ #category : 'positions' }
BoFlapTopEdge >> closedPositionOf: aFlap in: aWorldExtent [
	^ (self crossPositionOf: aFlap in: aWorldExtent) @ aFlap thickness negated
]

{ #category : 'positions' }
BoFlapTopEdge >> openPositionOf: aFlap in: aWorldExtent [
	^ (self crossPositionOf: aFlap in: aWorldExtent) @ 0
]
