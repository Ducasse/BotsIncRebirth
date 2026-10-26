"
I test the micro browser on an anonymous class whose category drawing is protected, so that the classes of the system are not changed.

Most tests do not show the browser. The tests that click show the window of the browser in a space (see showBrowser), which is closed in tearDown.
"
Class {
	#name : 'BoMicroBrowserTest',
	#superclass : 'TestCase',
	#instVars : [
		'browsedClass',
		'browser',
		'space'
	],
	#category : 'Botsinc-Micro-Tests',
	#package : 'Botsinc-Micro-Tests'
}

{ #category : 'showing' }
BoMicroBrowserTest >> clickOn: aString in: aSpListPresenter [

	| label |
	label := (self labelsOf: aSpListPresenter) detect: [ :each | each text asString = aString ].
	label eventSimulator click.
	self settle
]

{ #category : 'showing' }
BoMicroBrowserTest >> labelsOf: aSpListPresenter [
	"Return the label elements shown by the Toplo list of aSpListPresenter"

	| labels |
	labels := OrderedCollection new.
	aSpListPresenter adapter widget allChildrenBreadthFirstDo: [ :each | (each isKindOf: ToLabel) ifTrue: [ labels add: each ] ].
	^ labels
]

{ #category : 'running' }
BoMicroBrowserTest >> setUp [

	super setUp.
	browsedClass := Object newAnonymousSubclass.
	browsedClass
		compile: 'square
	^ 4'
		classified: 'drawing'.
	browser := BoMicroBrowser on: browsedClass
]

{ #category : 'showing' }
BoMicroBrowserTest >> settle [

	space settle.
	(Delay forMilliseconds: 300) wait.
	space settle
]

{ #category : 'showing' }
BoMicroBrowserTest >> showBrowser [
	"Show the window of the browser in a space, as when the browser is in a world"

	space := BlSpace new.
	space extent: 600 @ 500.
	space root addChild: browser window.
	space show.
	self settle
]

{ #category : 'showing' }
BoMicroBrowserTest >> shownTextsOf: aSpListPresenter [

	^ (self labelsOf: aSpListPresenter) collect: [ :each | each text asString ] as: Array
]

{ #category : 'running' }
BoMicroBrowserTest >> tearDown [

	space ifNotNil: [ space close ].
	super tearDown
]

{ #category : 'tests' }
BoMicroBrowserTest >> testAcceptCannotReplaceAProtectedMethod [

	browser addProtocolNamed: 'mine'.
	browser codePane text: 'square
	^ 5'.
	self assert: browser accept isNil.
	self assert: (browsedClass >> #square) protocolName equals: #drawing.
	self assert: (browsedClass new perform: #square) equals: 4
]

{ #category : 'tests' }
BoMicroBrowserTest >> testAcceptCompilesInTheSelectedCategory [

	browser addProtocolNamed: 'mine'.
	browser codePane text: 'circle
	^ 3'.
	self assert: browser accept equals: #circle.
	self assert: (browsedClass >> #circle) protocolName equals: #mine.
	self assert: browser selectedSelector equals: #circle
]

{ #category : 'tests' }
BoMicroBrowserTest >> testAcceptIsRefusedInAProtectedCategory [

	browser selectProtocol: 'drawing'.
	browser codePane text: 'circle
	^ 3'.
	self assert: browser accept isNil.
	self deny: (browsedClass includesSelector: #circle)
]

{ #category : 'tests' }
BoMicroBrowserTest >> testAcceptNeedsACategory [

	browser codePane text: 'circle
	^ 3'.
	self assert: browser accept isNil.
	self deny: (browsedClass includesSelector: #circle)
]

{ #category : 'tests' }
BoMicroBrowserTest >> testAddCategoryUsesTheCategoryField [

	browser protocolNameInput text: 'mine'.
	browser addProtocol.
	self assert: browser selectedProtocol equals: #mine.
	self assert: browser protocolNameInput text isEmpty
]

{ #category : 'tests' }
BoMicroBrowserTest >> testAddedCategoryIsSelectedAndNotProtected [

	browser addProtocolNamed: ' mine '.
	self assert: browser selectedProtocol equals: #mine.
	self deny: (browser isProtected: 'mine')
]

{ #category : 'tests' }
BoMicroBrowserTest >> testBuiltListsFollowTheChanges [
	"The lists are built with the Toplo backend, as when the browser is shown"

	| protocolWidget methodWidget |
	browser build.
	protocolWidget := (browser instVarNamed: #protocolList) adapter widget.
	methodWidget := (browser instVarNamed: #methodList) adapter widget.
	browser addProtocolNamed: 'mine'.
	self assert: protocolWidget dataAccessor asArray equals: #( #drawing #mine ).
	browser codePane text: 'circle
	^ 3'.
	browser accept.
	self assert: methodWidget dataAccessor asArray equals: #( #circle ).
	browser removeMethod.
	self assert: methodWidget dataAccessor asArray equals: #(  ).
	browser removeProtocol.
	self assert: protocolWidget dataAccessor asArray equals: #( #drawing )
]

{ #category : 'tests' }
BoMicroBrowserTest >> testCategoriesAreListed [

	self assert: browser protocols equals: #( #drawing ).
	self assert: (browser isProtected: 'drawing')
]

{ #category : 'tests - shown' }
BoMicroBrowserTest >> testClickOnAnotherCategoryReplacesTheMethods [

	browsedClass
		compile: 'circle
	^ 3'
		classified: 'shapes'.
	browser updateProtocols.
	self showBrowser.
	self clickOn: 'drawing' in: (browser instVarNamed: #protocolList).
	self clickOn: 'shapes' in: (browser instVarNamed: #protocolList).
	self assert: browser selectedProtocol equals: #shapes.
	self assert: (self shownTextsOf: (browser instVarNamed: #methodList)) equals: #( 'circle' )
]

{ #category : 'tests - shown' }
BoMicroBrowserTest >> testClickOnCategoryShowsItsMethods [

	self showBrowser.
	self clickOn: 'drawing' in: (browser instVarNamed: #protocolList).
	self assert: browser selectedProtocol equals: #drawing.
	self assert: (self shownTextsOf: (browser instVarNamed: #methodList)) equals: #( 'square' )
]

{ #category : 'tests - shown' }
BoMicroBrowserTest >> testClickOnMethodShowsItsSource [

	self showBrowser.
	self clickOn: 'drawing' in: (browser instVarNamed: #protocolList).
	self clickOn: 'square' in: (browser instVarNamed: #methodList).
	self assert: browser selectedSelector equals: #square.
	self assert: browser codePane text equals: (browsedClass >> #square) sourceCode
]

{ #category : 'tests' }
BoMicroBrowserTest >> testCompilationErrorIsShown [

	browser addProtocolNamed: 'mine'.
	browser codePane text: 'circle
	^ ^'.
	self assert: browser accept isNil.
	self assert: browser codePane showsError.
	self assert: browser message equals: 'Variable or expression expected'.
	self deny: (browsedClass includesSelector: #circle)
]

{ #category : 'tests - shown' }
BoMicroBrowserTest >> testDropOfAnElementOnAListIsIgnored [
	"Moving a window over the browser drops its title bar on a list, which is not a drag of Spec"

	| list drop |
	self showBrowser.
	list := (browser instVarNamed: #protocolList) adapter widget.
	drop := BlDropEvent new
		        gestureSource: BlElement new;
		        yourself.
	self shouldnt: [ BlEvent fireEvent: drop target: list ] raise: Error.
	self assert: browser selectedProtocol isNil
]

{ #category : 'tests' }
BoMicroBrowserTest >> testProtectedCategoryCannotBeRemoved [

	browser selectProtocol: 'drawing'.
	browser removeProtocol.
	self assert: (browser protocols includes: #drawing).
	self assert: (browsedClass includesSelector: #square)
]

{ #category : 'tests' }
BoMicroBrowserTest >> testProtectedMethodCannotBeRemoved [

	browser selectProtocol: 'drawing'.
	browser selectSelector: #square.
	browser removeMethod.
	self assert: (browsedClass includesSelector: #square)
]

{ #category : 'tests' }
BoMicroBrowserTest >> testRemoveOwnCategory [

	browser addProtocolNamed: 'mine'.
	browser codePane text: 'circle
	^ 3'.
	browser accept.
	browser removeProtocol.
	self deny: (browser protocols includes: #mine).
	self deny: (browsedClass includesSelector: #circle)
]

{ #category : 'tests' }
BoMicroBrowserTest >> testRemoveOwnMethod [

	browser addProtocolNamed: 'mine'.
	browser codePane text: 'circle
	^ 3'.
	browser accept.
	browser removeMethod.
	self deny: (browsedClass includesSelector: #circle).
	self assert: browser selectors isEmpty
]

{ #category : 'tests' }
BoMicroBrowserTest >> testSelectingACategoryUpdatesTheBuiltMethodList [
	"The lists are built with the Toplo backend, as when the browser is shown"

	| methodWidget |
	browser build.
	browser selectProtocol: 'drawing'.
	methodWidget := (browser instVarNamed: #methodList) adapter widget.
	self assert: methodWidget dataAccessor asArray equals: #( #square )
]

{ #category : 'tests' }
BoMicroBrowserTest >> testSelectingAMethodShowsItsSource [

	browser selectProtocol: 'drawing'.
	self assert: browser selectors equals: #( #square ).
	browser selectSelector: #square.
	self assert: browser codePane text equals: (browsedClass >> #square) sourceCode
]

{ #category : 'tests - shown' }
BoMicroBrowserTest >> testShownBrowserListsTheCategories [

	self showBrowser.
	self assert: (self shownTextsOf: (browser instVarNamed: #protocolList)) equals: #( 'drawing' )
]

{ #category : 'tests' }
BoMicroBrowserTest >> testTemplateIsShownWhenNoMethodIsSelected [

	self assert: browser codePane text equals: browser template
]

{ #category : 'tests' }
BoMicroBrowserTest >> testWindowCanBeDockedInAFlapOrPlacedInTheWorld [

	| flap world |
	flap := BoFlap new.
	world := BoTurtleWorld new.
	browser dockIn: flap.
	self assert: browser window parent equals: flap pane.
	browser openIn: world at: 10 @ 20.
	self assert: browser window parent equals: world.
	self assert: flap pane children isEmpty
]

{ #category : 'tests' }
BoMicroBrowserTest >> testWindowIsASpecWindow [

	self assert: (browser windowPresenter isKindOf: SpWindowPresenter).
	self assert: browser windowPresenter presenter identicalTo: browser.
	self assert: browser windowPresenter adapter widget identicalTo: browser window.
	self assert: (browser window isKindOf: ToInnerWindow).
	self assert: browser windowPresenter title equals: browser windowTitle
]
