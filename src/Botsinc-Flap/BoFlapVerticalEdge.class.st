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
BoFlapVerticalEdge >> crossPositionOf: aFlap in: aWorldExtent [
	^ (aWorldExtent y - aFlap length) / 2
]

{ #category : 'layout' }
BoFlapVerticalEdge >> layout [
	^ BlLinearLayout horizontal alignCenter
]

{ #category : 'layout' }
BoFlapVerticalEdge >> paneExtentFor: aFlap [
	^ aFlap thickness @ aFlap length
]

{ #category : 'layout' }
BoFlapVerticalEdge >> tabExtentFor: aFlap [
	^ aFlap tabThickness @ aFlap tabLength
]
