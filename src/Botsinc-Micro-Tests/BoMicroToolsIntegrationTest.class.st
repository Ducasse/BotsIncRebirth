"
I test that the pieces work together, as in BoTurtleWorld class>>openWithTools: a world opened in a space, with a micro browser docked in a flap on the right (flap, open) and a micro workspace docked in a flap at the bottom (workspaceFlap, closed). I simulate clicks and drags, as a user does. The browsed class is anonymous, so that the classes of the system are not changed. The space is closed in tearDown.
"
Class {
	#name : 'BoMicroToolsIntegrationTest',
	#superclass : 'TestCase',
	#instVars : [
		'browsedClass',
		'browser',
		'workspace',
		'world',
		'flap',
		'workspaceFlap',
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
	workspace := BoMicroWorkspace on: world.
	flap := BoFlap new
		        edge: BoFlapEdge right;
		        thickness: 460;
		        yourself.
	browser dockIn: flap.
	flap attachTo: world.
	workspaceFlap := BoFlap new
		                 edge: BoFlapEdge bottom;
		                 thickness: 240;
		                 yourself.
	workspace dockIn: workspaceFlap.
	workspaceFlap attachTo: world.
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
BoMicroToolsIntegrationTest >> showWorkspaceFlap [
	"Close the flap of the browser, that covers the right of the workspace, and open the flap of the workspace"

	flap close.
	workspaceFlap open.
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
BoMicroToolsIntegrationTest >> testClickOnAnotherCategoryReplacesTheMethods [

	self clickOn: 'drawing' in: (browser instVarNamed: #protocolList).
	self clickOn: 'shapes' in: (browser instVarNamed: #protocolList).
	self assert: browser selectedProtocol equals: #shapes.
	self assert: (self shownTextsOf: (browser instVarNamed: #methodList)) equals: #( 'circle' )
]

{ #category : 'tests' }
BoMicroToolsIntegrationTest >> testClickOnCategoryShowsItsMethods [

	self clickOn: 'drawing' in: (browser instVarNamed: #protocolList).
	self assert: browser selectedProtocol equals: #drawing.
	self assert: (self shownTextsOf: (browser instVarNamed: #methodList)) equals: #( 'square' )
]

{ #category : 'tests' }
BoMicroToolsIntegrationTest >> testClickOnMethodShowsItsSource [

	self clickOn: 'drawing' in: (browser instVarNamed: #protocolList).
	self clickOn: 'square' in: (browser instVarNamed: #methodList).
	self assert: browser selectedSelector equals: #square.
	self assert: browser codePane text equals: (browsedClass >> #square) sourceCode
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
BoMicroToolsIntegrationTest >> testDragTitleBarPullsTheWorkspaceOutOfTheFlap [

	| before after |
	self showWorkspaceFlap.
	self assert: workspace isInFlap.
	before := workspace window bounds inSpace asRectangle origin.
	workspace window topBarElement eventSimulator dragBy: 100 @ -200.
	self settle.
	self deny: workspace isInFlap.
	self assert: workspace window parent identicalTo: world.
	self assert: workspaceFlap pane children isEmpty.
	after := workspace window bounds inSpace asRectangle origin.
	self assert: (after - before - (100 @ -200)) r < 2
]

{ #category : 'tests' }
BoMicroToolsIntegrationTest >> testFlapIsOpenAndShowsTheCategories [

	self assert: flap isOpen.
	self assert: flap pane bounds inSpace left < space extent x.
	self assert: (self shownTextsOf: (browser instVarNamed: #protocolList)) equals: #( 'drawing' 'shapes' )
]

{ #category : 'tests' }
BoMicroToolsIntegrationTest >> testPulledOutWorkspaceRunsScriptsOnTheWorld [

	self showWorkspaceFlap.
	workspace window topBarElement eventSimulator dragBy: 100 @ -200.
	self settle.
	workspace codePane text: 'self newTurtle'.
	workspace doItAll.
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
BoMicroToolsIntegrationTest >> testSecondDragMovesThePulledOutWorkspace [

	| titleBar before after |
	self showWorkspaceFlap.
	titleBar := workspace window topBarElement.
	titleBar eventSimulator dragBy: 100 @ -200.
	self settle.
	before := workspace window bounds inSpace asRectangle origin.
	titleBar eventSimulator dragBy: 30 @ 40.
	self settle.
	after := workspace window bounds inSpace asRectangle origin.
	self assert: workspace window parent identicalTo: world.
	self assert: (after - before - (30 @ 40)) r < 2
]
