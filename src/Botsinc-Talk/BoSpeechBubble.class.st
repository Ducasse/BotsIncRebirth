"
I am a speech balloon pointing at an element of a turtle world, the Bloc version of the code balloons of MorphicWrappers.

A question bubble lets you talk to a turtle or to the world: click on it, type a message such as go: 100 and press Enter. The message is sent to the object (see BoTalkCompiler), Shift+Enter adds a line, the up and down arrows browse the messages already sent and Escape closes the bubble. When the message fails the text turns red, the error is explained and the receiver shakes. When it succeeds the bubble disappears and, unless the result is the receiver itself or the code ends with a period, the object answers with an answer bubble that fades away.

	BoSpeechBubble debugOnError: true
opens a debugger instead of explaining the error.
"
Class {
	#name : 'BoSpeechBubble',
	#superclass : 'BlElement',
	#instVars : [
		'target',
		'anchor',
		'environment',
		'editor',
		'messageLabel',
		'tailOnTop',
		'tipX',
		'running',
		'historyIndex',
		'draft',
		'followHandler',
		'hasError',
		'world'
	],
	#classVars : [
		'DebugOnError'
	],
	#category : 'Botsinc-Talk',
	#package : 'Botsinc-Talk'
}

{ #category : 'instance creation' }
BoSpeechBubble class >> answer: aString for: anElement at: aPoint [
	"Return a bubble showing aString, said by anElement. aPoint is used when anElement is the world"

	^ self new
		setTarget: anElement anchor: aPoint environment: nil;
		buildAnswer: aString;
		yourself

]

{ #category : 'looks' }
BoSpeechBubble class >> answerColor [
	^ Color r: 0.87 g: 0.94 b: 1.0

]

{ #category : 'settings' }
BoSpeechBubble class >> debugOnError [
	"When true, an error raised by a message sent from a bubble opens a debugger"

	^ DebugOnError ifNil: [ false ]

]

{ #category : 'settings' }
BoSpeechBubble class >> debugOnError: aBoolean [
	DebugOnError := aBoolean

]

{ #category : 'instance creation' }
BoSpeechBubble class >> question: anElement at: aPoint environment: aTalkEnvironment [
	"Return a bubble to talk to anElement. aPoint is used when anElement is the world"

	^ self new
		setTarget: anElement anchor: aPoint environment: aTalkEnvironment;
		buildQuestion;
		yourself

]

{ #category : 'looks' }
BoSpeechBubble class >> questionColor [
	^ Color r: 1.0 g: 1.0 b: 0.6

]

{ #category : 'talking' }
BoSpeechBubble >> accept [
	"Send the message typed in the receiver to its receiver"

	| source compiler method |
	running ifTrue: [ ^ self ].
	source := self text.
	source trimBoth ifEmpty: [ ^ self close ].
	compiler := BoTalkCompiler receiver: self receiver environment: environment.
	method := [ compiler compile: source ]
		on: BoTalkError
		do: [ :error | ^ self showError: error messageText ].
	self beRunning.
	self receiver bubbleEvaluate: [ self run: method with: compiler source: source ]

]

{ #category : 'layout' }
BoSpeechBubble >> addArcAt: aCenter radius: aRadius from: startAngle to: stopAngle to: points [
	startAngle to: stopAngle by: 15 do: [ :angle |
		points add: aCenter + ((angle degreeCos @ angle degreeSin) * aRadius) ]

]

{ #category : 'initialization' }
BoSpeechBubble >> addShortcutsToEditor [
	editor addEditorShortcut: (BlShortcutWithAction new
		combination: BlKeyCombination return;
		action: [ :anEvent |
			anEvent modifiers isShift
				ifTrue: [ self insertLineBreak ]
				ifFalse: [ self accept ] ];
		name: 'Send';
		description: 'Send the message to the receiver, Shift+Return adds a line';
		yourself).
	editor addEditorShortcut: (BlShortcutWithAction new
		combination: BlKeyCombination escape;
		action: [ self close ];
		name: 'Close';
		yourself).
	editor addEditorShortcut: (BlShortcutWithAction new
		combination: BlKeyCombination arrowUp;
		action: [ self historyUp ];
		name: 'Previous message';
		yourself).
	editor addEditorShortcut: (BlShortcutWithAction new
		combination: BlKeyCombination arrowDown;
		action: [ self historyDown ];
		name: 'Next message';
		yourself)

]

{ #category : 'layout' }
BoSpeechBubble >> anchorBounds [
	"Return the rectangle the tail points at, in the coordinates of the world"

	^ target == world
		  ifTrue: [ anchor extent: 0 @ 0 ]
		  ifFalse: [ target bounds inParent bounds ]
]

{ #category : 'private' }
BoSpeechBubble >> beEditable [
	running := false.
	self opacity: 1.
	editor beEditable

]

{ #category : 'private' }
BoSpeechBubble >> beRunning [
	running := true.
	self opacity: 0.6.
	editor beReadonlyWithSelection

]

{ #category : 'initialization' }
BoSpeechBubble >> buildAnswer: aString [
	self
		background: self class answerColor;
		addChild: (BlTextElement new
			text: (aString asRopedText fontSize: 13);
			yourself);
		preventMeAndChildrenMouseEvents

]

{ #category : 'initialization' }
BoSpeechBubble >> buildQuestion [
	self background: self class questionColor.
	editor := ToAlbum new.
	editor
		styler: self newStyler;
		text: '' asRopedText;
		whenTextEditedDo: [ :anEvent | self textEdited ].
	self addShortcutsToEditor.
	messageLabel := BlTextElement new
		visibility: BlVisibility gone;
		margin: (BlInsets top: 4);
		yourself.
	self addChildren: { editor. messageLabel }.
	self updateEditorExtent

]

{ #category : 'errors' }
BoSpeechBubble >> clearError [
	hasError := false.
	messageLabel visibility: BlVisibility gone.
	editor styler showsError: false.
	editor requestTextStyle

]

{ #category : 'opening' }
BoSpeechBubble >> close [
	followHandler ifNotNil: [
		target removeEventHandler: followHandler.
		followHandler := nil ].
	self removeFromParent

]

{ #category : 'accessing' }
BoSpeechBubble >> editor [
	^ editor

]

{ #category : 'opening' }
BoSpeechBubble >> fadeAway [
	"Disappear slowly after a while"

	self addAnimation: (BlOpacityAnimation new
		opacity: 0;
		delay: 2 seconds;
		duration: 1 second;
		onFinishedDo: [ self removeFromParent ];
		yourself)

]

{ #category : 'testing' }
BoSpeechBubble >> hasError [
	^ hasError

]

{ #category : 'history' }
BoSpeechBubble >> historyDown [
	| history |
	self isMultiLine ifTrue: [
		^ editor navigator
			moveDown;
			apply ].
	historyIndex ifNil: [ ^ self ].
	history := environment historyFor: self receiver.
	historyIndex := historyIndex + 1.
	historyIndex > history size
		ifTrue: [
			historyIndex := nil.
			self text: draft ]
		ifFalse: [ self text: (history at: historyIndex) ]

]

{ #category : 'history' }
BoSpeechBubble >> historyUp [
	"Replace the text by the previous message sent to an object of the same class. The text being typed is kept, see historyDown"

	| history |
	self isMultiLine ifTrue: [
		^ editor navigator
			moveUp;
			apply ].
	history := environment historyFor: self receiver.
	history ifEmpty: [ ^ self ].
	historyIndex ifNil: [
		draft := self text.
		historyIndex := history size + 1 ].
	historyIndex := historyIndex - 1 max: 1.
	self text: (history at: historyIndex)

]

{ #category : 'private' }
BoSpeechBubble >> inUIDo: aBlock [
	"The scene graph must only be changed by the UI process"

	(world isAttachedToSceneGraph and: [ world space isPulseProcessActive not ])
		ifTrue: [ world enqueueTask: (BlTaskAction new action: aBlock; yourself) ]
		ifFalse: [ aBlock value ]

]

{ #category : 'initialization' }
BoSpeechBubble >> initialize [
	super initialize.
	running := false.
	hasError := false.
	tailOnTop := false.
	tipX := 0.
	self
		layout: BlLinearLayout vertical;
		constraintsDo: [ :c |
			c horizontal fitContent.
			c vertical fitContent ];
		border: (BlBorder paint: Color darkGray width: 1);
		addEventHandlerOn: BlClickEvent do: [ :anEvent | anEvent consumed: true ].
	self updatePadding

]

{ #category : 'private' }
BoSpeechBubble >> insertLineBreak [
	editor inserter
		atCursor;
		string: String cr;
		insert

]

{ #category : 'testing' }
BoSpeechBubble >> isClosed [
	^ self hasParent not

]

{ #category : 'testing' }
BoSpeechBubble >> isMultiLine [
	^ self text includesAny: { Character cr. Character lf }

]

{ #category : 'testing' }
BoSpeechBubble >> isQuestionBubble [
	^ editor notNil

]

{ #category : 'testing' }
BoSpeechBubble >> isRunning [
	^ running

]

{ #category : 'layout' }
BoSpeechBubble >> margin [
	^ 6

]

{ #category : 'accessing' }
BoSpeechBubble >> messageText [
	"Return the explanation of the last error, or an empty string"

	^ messageLabel isVisible
		ifTrue: [ messageLabel text asString ]
		ifFalse: [ '' ]

]

{ #category : 'initialization' }
BoSpeechBubble >> newStyler [
	^ BoTalkStyler new
		workspace: environment;
		yourself

]

{ #category : 'layout' }
BoSpeechBubble >> onExtentChanged [
	super onExtentChanged.
	self placeNearAnchor
]

{ #category : 'opening' }
BoSpeechBubble >> openIn: aWorld [
	"Show the receiver in aWorld, pointing at its target. A bubble pointing at a turtle follows it"

	world := aWorld.
	aWorld addChild: self.
	target == aWorld ifFalse: [
		followHandler := BlEventHandler
			on: BlElementPositionChangedEvent
			do: [ :anEvent | self placeNearAnchor ].
		target addEventHandler: followHandler ].
	editor ifNotNil: [ editor focusHolder requestFocus ]

]

{ #category : 'layout' }
BoSpeechBubble >> outlineVertices [
	"A rounded rectangle with a tail ending at tipX, on its top or bottom side"

	| radius top bottom right points |
	radius := 8.
	right := self width.
	top := tailOnTop ifTrue: [ self tailHeight ] ifFalse: [ 0 ].
	bottom := tailOnTop ifTrue: [ self height ] ifFalse: [ self height - self tailHeight ].
	points := OrderedCollection new.
	self addArcAt: radius @ (top + radius) radius: radius from: 180 to: 270 to: points.
	tailOnTop ifTrue: [
		points
			add: tipX - 6 @ top;
			add: tipX @ 0;
			add: tipX + 6 @ top ].
	self addArcAt: right - radius @ (top + radius) radius: radius from: 270 to: 360 to: points.
	self addArcAt: right - radius @ (bottom - radius) radius: radius from: 0 to: 90 to: points.
	tailOnTop ifFalse: [
		points
			add: tipX + 6 @ bottom;
			add: tipX @ self height;
			add: tipX - 6 @ bottom ].
	self addArcAt: radius @ (bottom - radius) radius: radius from: 90 to: 180 to: points.
	^ points asArray

]

{ #category : 'layout' }
BoSpeechBubble >> placeNearAnchor [
	"Put the receiver above or below its anchor, on the side where the world clips it the least, like the balloons of MorphicWrappers"

	| anchorBounds worldBounds best bestArea |
	(self hasParent and: [ self width > 0 ]) ifFalse: [ ^ self ].
	anchorBounds := self anchorBounds.
	worldBounds := 0 @ 0 extent: self parent extent.
	bestArea := -1.
	#( false true ) do: [ :onTop |
		{ self tipInset. self width - self tipInset } do: [ :x |
			| tip place area |
			tip := onTop
				ifTrue: [ anchorBounds bottomCenter ]
				ifFalse: [ anchorBounds topCenter ].
			place := onTop
				ifTrue: [ tip - (x @ 0) ]
				ifFalse: [ tip - (x @ self height) ].
			area := ((place extent: self extent) intersects: worldBounds)
				ifTrue: [ ((place extent: self extent) intersect: worldBounds) area ]
				ifFalse: [ 0 ].
			area > bestArea ifTrue: [
				bestArea := area.
				best := { onTop. x. place } ] ] ].
	best first = tailOnTop ifFalse: [
		tailOnTop := best first.
		self updatePadding ].
	tipX := best second.
	self position: best third.
	self updateShape

]

{ #category : 'accessing' }
BoSpeechBubble >> receiver [
	"Return the object the messages are sent to"

	^ target bubbleReceiver

]

{ #category : 'talking' }
BoSpeechBubble >> run: aCompiledMethod with: aTalkCompiler source: aString [
	"Run in the process chosen by the receiver, see bubbleEvaluate:. The outcome is shown in the UI process"

	| result |
	result := [ aTalkCompiler run: aCompiledMethod ]
		on: Error
		do: [ :error |
			self inUIDo: [ self showError: error description ].
			self class debugOnError ifTrue: [ error pass ].
			^ self ].
	self inUIDo: [ self succeeded: result source: aString ]

]

{ #category : 'initialization' }
BoSpeechBubble >> setTarget: anElement anchor: aPoint environment: aTalkEnvironment [
	target := anElement.
	anchor := aPoint.
	environment := aTalkEnvironment

]

{ #category : 'errors' }
BoSpeechBubble >> shake [
	"Shake the receiver of the messages, or the bubble when talking to the world"

	| element start |
	element := target == world
		ifTrue: [ self ]
		ifFalse: [ target ].
	start := element position.
	element addAnimation: (BlNumberTransition new
		from: 0;
		to: 1;
		duration: 400 milliSeconds;
		onStepDo: [ :t | element position: start + (((t * 6 * Float pi) sin * 6 * (1 - t)) @ 0) ];
		onFinishedDo: [ element position: start ];
		yourself)

]

{ #category : 'talking' }
BoSpeechBubble >> shouldAnswer: anObject source: aString [
	"Like in MorphicWrappers, a final period means that the result does not matter"

	^ (aString trimRight endsWith: '.') not and: [ anObject ~~ self receiver ]

]

{ #category : 'errors' }
BoSpeechBubble >> showError: aString [
	"Turn the text red, explain the error and shake the receiver. The text can then be corrected"

	self isClosed ifFalse: [
		self beEditable.
		editor styler showsError: true.
		editor requestTextStyle.
		messageLabel
			text: (aString asRopedText
				foreground: Color red darker;
				fontSize: 11);
			visibility: BlVisibility visible ].
	hasError := true.
	self shake

]

{ #category : 'talking' }
BoSpeechBubble >> succeeded: anObject source: aString [
	environment remember: aString for: self receiver.
	running := false.
	self isClosed ifTrue: [ ^ self ].
	self close.
	(self shouldAnswer: anObject source: aString) ifFalse: [ ^ self ].
	(self class answer: (anObject printStringLimitedTo: 200) for: target at: anchor)
		openIn: world;
		fadeAway

]

{ #category : 'layout' }
BoSpeechBubble >> tailHeight [
	^ 14

]

{ #category : 'accessing' }
BoSpeechBubble >> target [
	^ target

]

{ #category : 'accessing' }
BoSpeechBubble >> text [
	^ editor text asString

]

{ #category : 'accessing' }
BoSpeechBubble >> text: aString [

	hasError ifTrue: [ self clearError ].
	editor text: aString asRopedText.
	editor navigator
		moveTo: aString size;
		apply.
	self updateEditorExtent
]

{ #category : 'private' }
BoSpeechBubble >> textEdited [
	hasError ifTrue: [ self clearError ].
	self updateEditorExtent

]

{ #category : 'layout' }
BoSpeechBubble >> tipInset [
	"Return the distance between the tip of the tail and the closest side of the receiver"

	^ 22 min: self width / 2

]

{ #category : 'private' }
BoSpeechBubble >> updateEditorExtent [
	"Make the editor as large as its text"

	| lines lineCount longest |
	lines := self text lines ifEmpty: [ #( '' ) ].
	lineCount := (self text count: [ :each | each = Character cr or: [ each = Character lf ] ]) + 1.
	longest := lines inject: 0 into: [ :max :each | max max: each size ].
	editor
		hExact: ((longest + 3 * 8 max: 140) min: 420);
		vExact: lineCount * 18 + 8
]

{ #category : 'layout' }
BoSpeechBubble >> updatePadding [
	self padding: (BlInsets
		top: (tailOnTop ifTrue: [ self tailHeight + self margin ] ifFalse: [ self margin ])
		left: self margin
		bottom: (tailOnTop ifTrue: [ self margin ] ifFalse: [ self tailHeight + self margin ])
		right: self margin)

]

{ #category : 'layout' }
BoSpeechBubble >> updateShape [
	self geometry: (BlPolygonGeometry vertices: self outlineVertices)

]
