"
I am a tool of a turtle world, such as the micro workspace or the micro browser. I am a Spec presenter built with the Toplo backend. My window is a Spec window presenter whose adapter is a Toplo inner window (see BoMicroApplication), so that it lives inside the world: it can be placed anywhere in the world (openIn:at:) or in a flap (dockIn:). It is moved by its title bar and resized by its borders. Dragging its title bar while it is in a flap pulls it out of the flap into the world.
"
Class {
	#name : 'BoMicroTool',
	#superclass : 'SpPresenter',
	#instVars : [
		'windowPresenter',
		'window'
	],
	#category : 'Botsinc-Micro',
	#package : 'Botsinc-Micro'
}

{ #category : 'window' }
BoMicroTool >> beResizable: aBoolean [
	"Enable or disable the resize handles and the maximize button of the window. The title bar, that moves the window, stays enabled"

	self window children do: [ :each |
		((each isKindOf: ToHandle) and: [ each ~~ self window topBarElement ]) ifTrue: [ each enabled: aBoolean ] ].
	self window expandButton ifNotNil: [ :aButton | aButton enabled: aBoolean ]
]

{ #category : 'window' }
BoMicroTool >> defaultExtent [

	^ 560 @ 320
]

{ #category : 'window' }
BoMicroTool >> dockIn: aFlap [
	"Place the window of the receiver in aFlap, next to the tools already there. The window fills its part of the flap, so it cannot be resized nor maximized. Return the window"

	self window removeFromParent.
	self beResizable: false.
	aFlap addContent: self window.
	^ self window
]

{ #category : 'window' }
BoMicroTool >> flap [
	"Return the flap holding the window of the receiver, or nil when the window is not in a flap"

	| pane |
	pane := self window parent ifNil: [ ^ nil ].
	^ (pane parent isKindOf: BoFlap)
		  ifTrue: [ pane parent ]
		  ifFalse: [ nil ]
]

{ #category : 'initialization' }
BoMicroTool >> initializeWindow: aWindowPresenter [

	super initializeWindow: aWindowPresenter.
	aWindowPresenter
		title: self windowTitle;
		initialExtent: self defaultExtent
]

{ #category : 'testing' }
BoMicroTool >> isInFlap [

	^ self flap notNil
]

{ #category : 'testing' }
BoMicroTool >> isResizable [

	^ self window children anySatisfy: [ :each |
		  (each isKindOf: ToHandle) and: [ each ~~ self window topBarElement and: [ each isEnabled ] ] ]
]

{ #category : 'initialization' }
BoMicroTool >> newButtonLabeled: aString help: aHelpString action: aBlock [

	^ self newButton
		  label: aString;
		  help: aHelpString;
		  action: aBlock;
		  yourself
]

{ #category : 'window' }
BoMicroTool >> newWindow [
	"Build the Spec window of the receiver. We place it ourselves in a flap or in the world instead of opening it. The clicks in the window do not reach the world, so that they do not open talk bubbles"

	| aWindow |
	windowPresenter := self asWindow.
	windowPresenter buildWithSpecLayout: self layout.
	windowPresenter updateTitle.
	aWindow := windowPresenter adapter widget.
	aWindow
		elevation: (BlRelativeElevation elevation: 500);
		addEventHandlerOn: BlClickEvent do: [ :anEvent | anEvent consumed: true ].
	aWindow topBarElement addEventHandlerOn: BlDragStartEvent do: [ :anEvent | self pullOutOfFlapWith: anEvent currentTarget ].
	^ aWindow
]

{ #category : 'window' }
BoMicroTool >> openIn: aWorld at: aPoint [
	"Place the window of the receiver in aWorld, its top left corner at aPoint. The window floats over the world, as inner windows do. Return the window"

	self window
		removeFromParent;
		extent: self defaultExtent;
		constraintsDo: [ :c | c ignoreByLayout ].
	self beResizable: true.
	aWorld addChild: self window.
	self window position: aPoint.
	^ self window
]

{ #category : 'window' }
BoMicroTool >> pullOutOfFlapWith: aDragHandle [
	"A drag of the title bar starts. When the window is in a flap, put it in the world at the same place, so that the drag moves it in the world. The drag handle notes where the window is when the drag starts, but the window is laid out in the world only at the next frame. So we tell the handle where the window is at the first move"

	| aFlap world position firstMove |
	aFlap := self flap ifNil: [ ^ self ].
	world := aFlap parent ifNil: [ ^ self ].
	position := world globalPointToLocal: (self window localPointToGlobal: 0 @ 0).
	self openIn: world at: position.
	firstMove := BlEventHandler
		             on: BlDragEvent
		             do: [ :anEvent |
				             aDragHandle initialPosition: position.
				             aDragHandle removeEventFilter: firstMove ].
	aDragHandle addEventFilter: firstMove
]

{ #category : 'window' }
BoMicroTool >> window [
	"Return the inner window showing the receiver, see openIn:at: and dockIn:"

	^ window ifNil: [ window := self newWindow ]
]

{ #category : 'window' }
BoMicroTool >> windowPresenter [
	"Return the Spec window presenter of the receiver, see window"

	self window.
	^ windowPresenter
]
