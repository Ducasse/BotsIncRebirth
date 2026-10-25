"
I am installed on each turtle world, see BoTurtleWorld>>enableTalking. A click on a turtle opens a bubble to talk to it, a click on the background opens a bubble to talk to the world, and a click while a bubble is open closes it.
"
Class {
	#name : 'BoTalkClickHandler',
	#superclass : 'BlCustomEventHandler',
	#category : 'Botsinc-Talk',
	#package : 'Botsinc-Talk'
}

{ #category : 'class initialization' }
BoTalkClickHandler class >> initialize [
	BoTurtleWorld
		registerInteraction: [ :aWorld | aWorld enableTalking ]
		named: #talk

]

{ #category : 'class initialization' }
BoTalkClickHandler class >> unload [
	BoTurtleWorld unregisterInteractionNamed: #talk

]

{ #category : 'mouse handlers' }
BoTalkClickHandler >> clickEvent: anEvent [
	| world bubbles |
	world := anEvent currentTarget.
	anEvent consumed: true.
	bubbles := world talkBubbles.
	bubbles ifNotEmpty: [ ^ bubbles do: [ :each | each close ] ].
	world
		openTalkBubbleFor: ((world turtleAt: anEvent position) ifNil: [ world ])
		at: (world globalPointToLocal: anEvent position)

]

{ #category : 'accessing' }
BoTalkClickHandler >> eventsToHandle [
	^ { BlClickEvent }

]
