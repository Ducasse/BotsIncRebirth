"
I test that the pieces work together, as in BoTurtleWorld class>>openWithTools: a world opened in a space, with a micro browser docked in a flap on the right (flap, open) and a micro playground docked in a flap at the bottom (playgroundFlap, closed). I simulate clicks and drags, as a user does. The browsed class is anonymous, so that the classes of the system are not changed. The space is closed in tearDown.
"
Class {
	#name : 'BoMicroToolsIntegrationTest',
	#superclass : 'TestCase',
	#instVars : [
		'browsedClass',
		'browser',
		'playground',
		'world',
		'flap',
		'playgroundFlap',
		'space'
	],
	#category : 'Botsinc-Micro-Tests',
	#package : 'Botsinc-Micro-Tests'
}

{ #category : 'private' }
BoMicroToolsIntegrationTest >> clickOn: aString in: aSpListPresenter [

	| label |
	label := (self labelsOf: aSpListPresenter) detect: [ :each | each text asString = aString ].
	label eventSimulator click.
	self settle
]

{ #category : 'private' }
BoMicroToolsIntegrationTest >> labelsOf: aSpListPresenter [
	"Return the label elements shown by the Toplo list of aSpListPresenter"

	| labels |
	labels := OrderedCollection new.
	aSpListPresenter adapter widget allChildrenBreadthFirstDo: [ :each | (each isKindOf: ToLabel) ifTrue: [ labels add: each ] ].
	^ labels
]

{ #category : 'running' }
BoMicroToolsIntegrationTest >> setUp [

	super setUp.
	browsedClass := Object newAnonymousSubclass.
	browsedClass
		compile: 'square
	^ 4'
		classified: 'drawing'.
	browsedClass
		compile: 'circle
	^ 3'
		classified: 'shapes'.
	browser := BoMicroBrowser on: browsedClass.
	world := BoTurtleWorld new.
	playground := BoMicroPlayground on: world.
	flap := BoFlap new
		        edge: BoFlapEdge right;
		        thickness: 460;
		        yourself.
	browser dockIn: flap.
	flap attachTo: world.
	playgroundFlap := BoFlap new
		                 edge: BoFlapEdge bottom;
		                 thickness: 240;
		                 yourself.
	playground dockIn: playgroundFlap.
	playgroundFlap attachTo: world.
	space := BlSpace new.
	space extent: 900 @ 600.
	space root addChild: world.
	space show.
	self settle.
	flap open.
	self settle
]

{ #category : 'private' }
BoMicroToolsIntegrationTest >> settle [
	"Let the space lay out its elements and the flap finish sliding"

	space settle.
	(Delay forMilliseconds: 300) wait.
	space settle
]

{ #category : 'private' }
BoMicroToolsIntegrationTest >> showPlaygroundFlap [
	"Close the flap of the browser, that covers the right of the playground, and open the flap of the playground"

	flap close.
	playgroundFlap open.
	self settle
]

{ #category : 'private' }
BoMicroToolsIntegrationTest >> shownTextsOf: aSpListPresenter [

	^ (self labelsOf: aSpListPresenter) collect: [ :each | each text asString ] as: Array
]

{ #category : 'running' }
BoMicroToolsIntegrationTest >> tearDown [

	space close.
	super tearDown
]

{ #category : 'tests' }
BoMicroToolsIntegrationTest >> testClickOnAnotherProtocolReplacesTheMethods [

	self clickOn: 'drawing' in: (browser instVarNamed: #protocolList).
	self clickOn: 'shapes' in: (browser instVarNamed: #protocolList).
	self assert: browser selectedProtocol equals: #shapes.
	self assert: (self shownTextsOf: (browser instVarNamed: #methodList)) equals: #( 'circle' )
]

{ #category : 'tests' }
BoMicroToolsIntegrationTest >> testClickOnMethodShowsItsSource [

	self clickOn: 'drawing' in: (browser instVarNamed: #protocolList).
	self clickOn: 'square' in: (browser instVarNamed: #methodList).
	self assert: browser selectedSelector equals: #square.
	self assert: browser codePane text equals: (browsedClass >> #square) sourceCode
]

{ #category : 'tests' }
BoMicroToolsIntegrationTest >> testClickOnProtocolShowsItsMethods [

	self clickOn: 'drawing' in: (browser instVarNamed: #protocolList).
	self assert: browser selectedProtocol equals: #drawing.
	self assert: (self shownTextsOf: (browser instVarNamed: #methodList)) equals: #( 'square' )
]

{ #category : 'tests' }
BoMicroToolsIntegrationTest >> testDockedBrowserFillsTheFlap [

	| paneBounds |
	paneBounds := flap pane bounds inSpace asRectangle insetBy: flap pane padding asMargin.
	self assert: browser window bounds inSpace asRectangle equals: paneBounds
]

{ #category : 'tests' }
BoMicroToolsIntegrationTest >> testDockedPlaygroundTakesHalfOfTheFlap [

	| paneBounds |
	self showPlaygroundFlap.
	paneBounds := playgroundFlap pane bounds inSpace asRectangle insetBy: playgroundFlap pane padding asMargin.
	self
		assert: playground window bounds inSpace asRectangle
		equals: (paneBounds origin extent: paneBounds width / 2 @ paneBounds height)
]

{ #category : 'tests' }
BoMicroToolsIntegrationTest >> testDragTitleBarPullsTheBrowserOutOfTheFlap [

	| titleBar before after |
	self assert: browser isInFlap.
	titleBar := browser window topBarElement.
	before := browser window bounds inSpace asRectangle origin.
	titleBar eventSimulator dragBy: -200 @ 50.
	self settle.
	self deny: browser isInFlap.
	self assert: browser window parent identicalTo: world.
	self assert: flap pane children isEmpty.
	after := browser window bounds inSpace asRectangle origin.
	self assert: (after - before - (-200 @ 50)) r < 2
]

{ #category : 'tests' }
BoMicroToolsIntegrationTest >> testDragTitleBarPullsThePlaygroundOutOfTheFlap [

	| before after |
	self showPlaygroundFlap.
	self assert: playground isInFlap.
	before := playground window bounds inSpace asRectangle origin.
	playground window topBarElement eventSimulator dragBy: 100 @ -200.
	self settle.
	self deny: playground isInFlap.
	self assert: playground window parent identicalTo: world.
	self assert: playgroundFlap pane children isEmpty.
	after := playground window bounds inSpace asRectangle origin.
	self assert: (after - before - (100 @ -200)) r < 2
]

{ #category : 'tests' }
BoMicroToolsIntegrationTest >> testFlapIsOpenAndShowsTheProtocols [

	self assert: flap isOpen.
	self assert: flap pane bounds inSpace left < space extent x.
	self assert: (self shownTextsOf: (browser instVarNamed: #protocolList)) equals: #( 'drawing' 'shapes' )
]

{ #category : 'tests' }
BoMicroToolsIntegrationTest >> testPulledOutPlaygroundLeavesTheOtherOnItsHalf [

	| other paneBounds |
	other := BoMicroPlayground on: world.
	other dockIn: playgroundFlap.
	self showPlaygroundFlap.
	other window topBarElement eventSimulator dragBy: -100 @ -200.
	self settle.
	self deny: other isInFlap.
	self assert: other isResizable.
	paneBounds := playgroundFlap pane bounds inSpace asRectangle insetBy: playgroundFlap pane padding asMargin.
	self
		assert: playground window bounds inSpace asRectangle
		equals: (paneBounds origin extent: paneBounds width / 2 @ paneBounds height)
]

{ #category : 'tests' }
BoMicroToolsIntegrationTest >> testPulledOutPlaygroundRunsScriptsOnTheWorld [

	self showPlaygroundFlap.
	playground window topBarElement eventSimulator dragBy: 100 @ -200.
	self settle.
	playground codePane text: 'self newTurtle'.
	playground doItAll.
	self settle.
	self assert: world turtles size equals: 1
]

{ #category : 'tests' }
BoMicroToolsIntegrationTest >> testSecondDragMovesThePulledOutBrowser [

	| titleBar before after |
	titleBar := browser window topBarElement.
	titleBar eventSimulator dragBy: -200 @ 50.
	self settle.
	before := browser window bounds inSpace asRectangle origin.
	titleBar eventSimulator dragBy: 30 @ 40.
	self settle.
	after := browser window bounds inSpace asRectangle origin.
	self assert: browser window parent identicalTo: world.
	self assert: (after - before - (30 @ 40)) r < 2
]

{ #category : 'tests' }
BoMicroToolsIntegrationTest >> testSecondDragMovesThePulledOutPlayground [

	| titleBar before after |
	self showPlaygroundFlap.
	titleBar := playground window topBarElement.
	titleBar eventSimulator dragBy: 100 @ -200.
	self settle.
	before := playground window bounds inSpace asRectangle origin.
	titleBar eventSimulator dragBy: 30 @ 40.
	self settle.
	after := playground window bounds inSpace asRectangle origin.
	self assert: playground window parent identicalTo: world.
	self assert: (after - before - (30 @ 40)) r < 2
]

{ #category : 'tests' }
BoMicroToolsIntegrationTest >> testTwoPlaygroundsShareTheFlapSideBySide [

	| other paneBounds left right |
	other := BoMicroPlayground on: world.
	other dockIn: playgroundFlap.
	self showPlaygroundFlap.
	paneBounds := playgroundFlap pane bounds inSpace asRectangle insetBy: playgroundFlap pane padding asMargin.
	left := playground window bounds inSpace asRectangle.
	right := other window bounds inSpace asRectangle.
	self assert: left height equals: paneBounds height.
	self assert: right height equals: paneBounds height.
	self assert: left width equals: paneBounds width / 2.
	self assert: left right equals: right left.
	self assert: right right equals: paneBounds right
]
