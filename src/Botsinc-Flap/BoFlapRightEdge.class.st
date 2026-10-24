"
I am the right edge of a world.
"
Class {
	#name : 'BoFlapRightEdge',
	#superclass : 'BoFlapVerticalEdge',
	#category : 'Botsinc-Flap',
	#package : 'Botsinc-Flap'
}

{ #category : 'layout' }
BoFlapRightEdge >> arrangePane: aPane tab: aTab in: aFlap [
	aFlap addChildren: { aTab. aPane }
]

{ #category : 'positions' }
BoFlapRightEdge >> closedPositionOf: aFlap in: aWorldExtent [
	^ (aWorldExtent x - aFlap tabThickness) @ (self crossPositionOf: aFlap in: aWorldExtent)
]

{ #category : 'resizing' }
BoFlapRightEdge >> growthFor: aDelta [
	^ aDelta x negated
]

{ #category : 'positions' }
BoFlapRightEdge >> openPositionOf: aFlap in: aWorldExtent [
	^ (aWorldExtent x - aFlap thickness - aFlap tabThickness) @ (self crossPositionOf: aFlap in: aWorldExtent)
]
