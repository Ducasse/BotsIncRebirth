"
I am an edge running horizontally (top or bottom): my flaps are wide and slide vertically.
"
Class {
	#name : 'BoFlapHorizontalEdge',
	#superclass : 'BoFlapEdge',
	#category : 'Botsinc-Flap',
	#package : 'Botsinc-Flap'
}

{ #category : 'positions' }
BoFlapHorizontalEdge >> availableThicknessOf: aFlap in: aWorldExtent [
	^ aWorldExtent y - aFlap tabThickness
]

{ #category : 'layout' }
BoFlapHorizontalEdge >> layout [
	^ BlLinearLayout vertical alignCenter
]

{ #category : 'layout' }
BoFlapHorizontalEdge >> paneExtentFor: aFlap in: aWorldExtent [
	^ aWorldExtent x @ aFlap thickness
]

{ #category : 'layout' }
BoFlapHorizontalEdge >> tabExtentFor: aFlap [
	^ aFlap tabLength @ aFlap tabThickness
]
