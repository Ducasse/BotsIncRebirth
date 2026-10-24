"
I am the left edge of a world.
"
Class {
	#name : 'BoFlapLeftEdge',
	#superclass : 'BoFlapVerticalEdge',
	#category : 'Botsinc-Flap',
	#package : 'Botsinc-Flap'
}

{ #category : 'layout' }
BoFlapLeftEdge >> arrangePane: aPane tab: aTab in: aFlap [
	aFlap addChildren: { aPane. aTab }
]

{ #category : 'positions' }
BoFlapLeftEdge >> closedPositionOf: aFlap in: aWorldExtent [
	^ aFlap thickness negated @ 0
]

{ #category : 'resizing' }
BoFlapLeftEdge >> growthFor: aDelta [
	^ aDelta x
]

{ #category : 'positions' }
BoFlapLeftEdge >> openPositionOf: aFlap in: aWorldExtent [
	^ 0 @ 0
]
