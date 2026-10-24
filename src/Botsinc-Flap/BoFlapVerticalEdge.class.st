"
I am an edge running vertically (left or right): my flaps are tall and slide horizontally.
"
Class {
	#name : 'BoFlapVerticalEdge',
	#superclass : 'BoFlapEdge',
	#category : 'Botsinc-Flap',
	#package : 'Botsinc-Flap'
}

{ #category : 'positions' }
BoFlapVerticalEdge >> availableThicknessOf: aFlap in: aWorldExtent [
	^ aWorldExtent x - aFlap tabThickness
]

{ #category : 'layout' }
BoFlapVerticalEdge >> layout [
	^ BlLinearLayout horizontal alignCenter
]

{ #category : 'layout' }
BoFlapVerticalEdge >> paneExtentFor: aFlap in: aWorldExtent [
	^ aFlap thickness @ aWorldExtent y
]

{ #category : 'layout' }
BoFlapVerticalEdge >> tabExtentFor: aFlap [
	^ aFlap tabThickness @ aFlap tabLength
]
