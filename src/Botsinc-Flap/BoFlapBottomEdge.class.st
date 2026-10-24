"
I am the bottom edge of a world.
"
Class {
	#name : 'BoFlapBottomEdge',
	#superclass : 'BoFlapHorizontalEdge',
	#category : 'Botsinc-Flap',
	#package : 'Botsinc-Flap'
}

{ #category : 'layout' }
BoFlapBottomEdge >> arrangePane: aPane tab: aTab in: aFlap [
	aFlap addChildren: { aTab. aPane }
]

{ #category : 'positions' }
BoFlapBottomEdge >> closedPositionOf: aFlap in: aWorldExtent [
	^ (self crossPositionOf: aFlap in: aWorldExtent) @ (aWorldExtent y - aFlap tabThickness)
]

{ #category : 'positions' }
BoFlapBottomEdge >> openPositionOf: aFlap in: aWorldExtent [
	^ (self crossPositionOf: aFlap in: aWorldExtent) @ (aWorldExtent y - aFlap thickness - aFlap tabThickness)
]
