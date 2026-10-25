Extension { #name : 'BoTurtleWorld' }

{ #category : '*Botsinc-Talk' }
BoTurtleWorld >> bubbleReceiver [
	^ self

]

{ #category : '*Botsinc-Talk' }
BoTurtleWorld >> enableTalking [
	"Let the user talk to the receiver and its turtles by clicking on them"

	(self userData at: #talking ifAbsent: [ false ]) ifTrue: [ ^ self ].
	self userData at: #talking put: true.
	self addEventHandler: BoTalkClickHandler new

]

{ #category : '*Botsinc-Talk' }
BoTurtleWorld >> openTalkBubbleFor: anElement at: aPoint [
	"Open a bubble to talk to anElement, a turtle or the receiver. aPoint, in the coordinates of the receiver, is where a bubble talking to the receiver points at"

	^ (BoSpeechBubble question: anElement at: aPoint environment: self talkEnvironment)
		openIn: self;
		yourself

]

{ #category : '*Botsinc-Talk' }
BoTurtleWorld >> talkBubbles [
	"Return the bubbles in which the user can type"

	^ self children select: [ :each | each isQuestionBubble ]

]

{ #category : '*Botsinc-Talk' }
BoTurtleWorld >> talkEnvironment [
	"Return the variables and the history shared by the bubbles of the receiver"

	^ self userData at: #talkEnvironment ifAbsentPut: [ BoTalkEnvironment new ]

]

{ #category : '*Botsinc-Talk' }
BoTurtleWorld >> turtleAt: aPoint [
	"Return the visible turtle in front at aPoint, in the coordinates of the space, or nil"

	^ self children reversed
		detect: [ :each |
			(self turtles includes: each)
				and: [ each isVisible and: [ each containsGlobalPoint: aPoint ] ] ]
		ifNone: [ nil ]

]
