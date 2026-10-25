"
I test the bubbles of a world that is not displayed: the messages are sent at once, without simulating events.
"
Class {
	#name : 'BoSpeechBubbleTest',
	#superclass : 'TestCase',
	#instVars : [
		'world',
		'turtle'
	],
	#category : 'Botsinc-Talk-Tests',
	#package : 'Botsinc-Talk-Tests'
}

{ #category : 'helpers' }
BoSpeechBubbleTest >> answers [
	^ world children select: [ :each | (each isKindOf: BoSpeechBubble) and: [ each isQuestionBubble not ] ]

]

{ #category : 'helpers' }
BoSpeechBubbleTest >> bubbleFor: anElement saying: aString [
	^ (world openTalkBubbleFor: anElement at: 100 @ 100)
		text: aString;
		accept;
		yourself

]

{ #category : 'running' }
BoSpeechBubbleTest >> setUp [
	super setUp.
	world := BoTurtleWorld new.
	turtle := world newTurtle

]

{ #category : 'tests' }
BoSpeechBubbleTest >> testAnswerIsTheResult [
	self bubbleFor: turtle saying: 'direction + 5'.
	self assert: self answers size equals: 1.
	self assert: self answers first children first text asString equals: '5'

]

{ #category : 'tests' }
BoSpeechBubbleTest >> testBubbleClosesAfterSuccess [
	| bubble |
	bubble := self bubbleFor: turtle saying: 'go: 100'.
	self assert: bubble isClosed.
	self assert: turtle center equals: world startingPlace + (100 @ 0).
	self assert: world talkBubbles isEmpty

]

{ #category : 'tests' }
BoSpeechBubbleTest >> testCompilationErrorKeepsBubbleOpen [
	| bubble |
	bubble := self bubbleFor: turtle saying: 'go: 100 +'.
	self deny: bubble isClosed.
	self assert: bubble hasError.
	self deny: bubble messageText isEmpty.
	self assert: bubble editor styler showsError.
	self assert: turtle center equals: world startingPlace

]

{ #category : 'tests' }
BoSpeechBubbleTest >> testEmptyTextClosesBubble [
	self assert: (self bubbleFor: turtle saying: '   ') isClosed

]

{ #category : 'tests' }
BoSpeechBubbleTest >> testFinalPeriodMeansNoAnswer [
	self bubbleFor: turtle saying: 'direction + 5.'.
	self assert: self answers isEmpty

]

{ #category : 'tests' }
BoSpeechBubbleTest >> testHistoryBrowsing [
	| bubble |
	self bubbleFor: turtle saying: 'go: 10'.
	self bubbleFor: turtle saying: 'turn: 90'.
	bubble := world openTalkBubbleFor: turtle at: 0 @ 0.
	bubble text: 'jump'.
	bubble historyUp.
	self assert: bubble text equals: 'turn: 90'.
	bubble historyUp.
	self assert: bubble text equals: 'go: 10'.
	bubble historyUp.
	self assert: bubble text equals: 'go: 10'.
	bubble historyDown.
	self assert: bubble text equals: 'turn: 90'.
	bubble historyDown.
	self assert: bubble text equals: 'jump'

]

{ #category : 'tests' }
BoSpeechBubbleTest >> testHistoryIsSharedByTurtles [
	| bubble |
	self bubbleFor: turtle saying: 'go: 10'.
	bubble := world openTalkBubbleFor: world newTurtle at: 0 @ 0.
	bubble historyUp.
	self assert: bubble text equals: 'go: 10'

]

{ #category : 'tests' }
BoSpeechBubbleTest >> testOnlyOneQuestionPerReceiverIsKeptAfterSuccess [
	self bubbleFor: turtle saying: 'go: 10'.
	self bubbleFor: turtle saying: 'go: 10'.
	self assert: world talkBubbles isEmpty

]

{ #category : 'tests' }
BoSpeechBubbleTest >> testRecallingAMessageClearsTheError [
	| bubble |
	self bubbleFor: turtle saying: 'go: 10'.
	bubble := self bubbleFor: turtle saying: 'goo: 10'.
	self assert: bubble hasError.
	bubble historyUp.
	self deny: bubble hasError.
	self deny: bubble editor styler showsError.
	self assert: bubble messageText isEmpty

]

{ #category : 'tests' }
BoSpeechBubbleTest >> testResultIsTheReceiverMeansNoAnswer [
	self bubbleFor: turtle saying: 'yourself'.
	self assert: self answers isEmpty

]

{ #category : 'tests' }
BoSpeechBubbleTest >> testRuntimeErrorIsNotRemembered [
	self bubbleFor: turtle saying: 'goo: 100'.
	self assert: (world talkEnvironment historyFor: turtle) isEmpty

]

{ #category : 'tests' }
BoSpeechBubbleTest >> testRuntimeErrorKeepsBubbleOpen [
	| bubble |
	bubble := self bubbleFor: turtle saying: 'goo: 100'.
	self deny: bubble isClosed.
	self assert: bubble hasError.
	self deny: bubble isRunning.
	self assert: (bubble messageText includesSubstring: 'goo:')

]

{ #category : 'tests' }
BoSpeechBubbleTest >> testSuccessIsRemembered [
	self bubbleFor: turtle saying: 'go: 100'.
	self assert: (world talkEnvironment historyFor: turtle) equals: #( 'go: 100' )

]

{ #category : 'tests' }
BoSpeechBubbleTest >> testTalkingToTheWorld [
	self bubbleFor: world saying: 'newTurtle'.
	self assert: world turtles size equals: 2

]

{ #category : 'tests' }
BoSpeechBubbleTest >> testTurtleNamedInATurtleBubbleIsUsedInTheWorldBubble [
	self bubbleFor: turtle saying: 'pica := self.'.
	self bubbleFor: world saying: 'pica go: 30.'.
	self assert: turtle center equals: world startingPlace + (30 @ 0)

]
