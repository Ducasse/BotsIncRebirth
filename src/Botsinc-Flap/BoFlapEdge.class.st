"
I represent the edge of a world element to which a flap is attached.
I know how to lay out the pane and the tab of a flap and where the flap is when open or closed.

Use my class side (`left`, `right`, `top`, `bottom`) to get an instance.
"
Class {
	#name : 'BoFlapEdge',
	#superclass : 'Object',
	#category : 'Botsinc-Flap',
	#package : 'Botsinc-Flap'
}

{ #category : 'instance creation' }
BoFlapEdge class >> bottom [
	^ BoFlapBottomEdge new
]

{ #category : 'instance creation' }
BoFlapEdge class >> left [
	^ BoFlapLeftEdge new
]

{ #category : 'instance creation' }
BoFlapEdge class >> right [
	^ BoFlapRightEdge new
]

{ #category : 'instance creation' }
BoFlapEdge class >> top [
	^ BoFlapTopEdge new
]

{ #category : 'layout' }
BoFlapEdge >> arrangePane: aPane tab: aTab in: aFlap [
	"Add aPane and aTab to aFlap so that the tab is on the world side"

	^ self subclassResponsibility
]

{ #category : 'positions' }
BoFlapEdge >> availableThicknessOf: aFlap in: aWorldExtent [
	^ self subclassResponsibility
]

{ #category : 'positions' }
BoFlapEdge >> closedPositionOf: aFlap in: aWorldExtent [
	"Only the tab of aFlap stays visible"

	^ self subclassResponsibility
]

{ #category : 'geometry' }
BoFlapEdge >> contentLayout [
	"Return the layout of the tools held by a flap stuck to the receiver: they are placed along the edge"

	^ self subclassResponsibility
]

{ #category : 'resizing' }
BoFlapEdge >> growthFor: aDelta [
	"Return how much the pane grows when the pointer moves by aDelta"

	^ self subclassResponsibility
]

{ #category : 'layout' }
BoFlapEdge >> layout [
	"Return the layout arranging the pane and the tab of a flap"

	^ self subclassResponsibility
]

{ #category : 'positions' }
BoFlapEdge >> openPositionOf: aFlap in: aWorldExtent [
	^ self subclassResponsibility
]

{ #category : 'layout' }
BoFlapEdge >> paneExtentFor: aFlap in: aWorldExtent [
	"The pane spans the whole side of the world"

	^ self subclassResponsibility
]

{ #category : 'layout' }
BoFlapEdge >> tabCornerRadii: aRadius [
	"Return the corner radii of the tab: the corners touching the pane are square, the other ones are rounded by aRadius"

	^ self subclassResponsibility
]

{ #category : 'layout' }
BoFlapEdge >> tabExtentFor: aFlap [
	^ self subclassResponsibility
]
