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
	^ 0 @ aFlap thickness negated
]

{ #category : 'resizing' }
BoFlapTopEdge >> growthFor: aDelta [
	^ aDelta y
]

{ #category : 'positions' }
BoFlapTopEdge >> openPositionOf: aFlap in: aWorldExtent [
	^ 0 @ 0
]
