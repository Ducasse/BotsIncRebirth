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
	^ 0 @ (aWorldExtent y - aFlap tabThickness)
]

{ #category : 'resizing' }
BoFlapBottomEdge >> growthFor: aDelta [
	^ aDelta y negated
]

{ #category : 'positions' }
BoFlapBottomEdge >> openPositionOf: aFlap in: aWorldExtent [
	^ 0 @ (aWorldExtent y - aFlap thickness - aFlap tabThickness)
]

{ #category : 'layout' }
BoFlapBottomEdge >> tabCornerRadii: aRadius [

	^ BlCornerRadii new
		  topLeft: aRadius;
		  topRight: aRadius;
		  bottomLeft: 0;
		  bottomRight: 0;
		  yourself
]
