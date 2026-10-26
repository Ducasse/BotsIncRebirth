"
I test a flap holding a tool instead of prototypes, see BoFlap>>content:.
"
Class {
	#name : 'BoFlapContentTest',
	#superclass : 'BoSpaceTestCase',
	#category : 'Botsinc-Flap-Tests',
	#package : 'Botsinc-Flap-Tests'
}

{ #category : 'tests' }
BoFlapContentTest >> testClickInContentDoesNotReachTheWorld [

	| clicked content |
	clicked := false.
	world addEventHandlerOn: BlClickEvent do: [ :anEvent | clicked := true ].
	content := BlElement new.
	flap content: content.
	space settle.
	content eventSimulator click.
	self deny: clicked
]

{ #category : 'tests' }
BoFlapContentTest >> testContentTakesItsShareOfThePane [

	| bottomFlap content paneBounds |
	bottomFlap := BoFlap new
		              edge: BoFlapEdge bottom;
		              thickness: 150;
		              yourself.
	bottomFlap attachTo: world.
	content := BlElement new.
	bottomFlap addContent: content share: 1 / 4.
	bottomFlap open.
	space settle.
	(Delay forMilliseconds: 300) wait.
	space settle.
	paneBounds := bottomFlap pane bounds inSpace asRectangle insetBy: bottomFlap pane padding asMargin.
	self assert: content bounds inSpace asRectangle height equals: paneBounds height.
	self assert: content bounds inSpace asRectangle width equals: paneBounds width / 4
]

{ #category : 'tests' }
BoFlapContentTest >> testContentsOfABottomFlapAreSideBySide [

	| bottomFlap first second paneBounds |
	bottomFlap := BoFlap new
		              edge: BoFlapEdge bottom;
		              thickness: 150;
		              yourself.
	bottomFlap attachTo: world.
	first := BlElement new.
	second := BlElement new.
	bottomFlap content: first.
	bottomFlap addContent: second.
	bottomFlap open.
	space settle.
	(Delay forMilliseconds: 300) wait.
	space settle.
	paneBounds := bottomFlap pane bounds inSpace asRectangle insetBy: bottomFlap pane padding asMargin.
	self assert: first bounds inSpace asRectangle height equals: paneBounds height.
	self assert: first bounds inSpace asRectangle width equals: paneBounds width / 2.
	self assert: first bounds inSpace asRectangle right equals: second bounds inSpace asRectangle left
]

{ #category : 'tests' }
BoFlapContentTest >> testContentsOfALeftFlapAreStackedAndShareThePane [

	| first second paneBounds |
	first := BlElement new.
	second := BlElement new.
	flap content: first.
	flap addContent: second.
	space settle.
	paneBounds := flap pane bounds inSpace asRectangle insetBy: flap pane padding asMargin.
	self assert: first bounds inSpace asRectangle width equals: paneBounds width.
	self assert: second bounds inSpace asRectangle width equals: paneBounds width.
	self assert: first bounds inSpace asRectangle height equals: paneBounds height / 2.
	self assert: first bounds inSpace asRectangle bottom equals: second bounds inSpace asRectangle top
]

{ #category : 'tests' }
BoFlapContentTest >> testRemovedContentGivesItsPlaceToTheOthers [

	| first second paneBounds |
	first := BlElement new.
	second := BlElement new.
	flap content: first.
	flap addContent: second.
	space settle.
	second removeFromParent.
	space settle.
	paneBounds := flap pane bounds inSpace asRectangle insetBy: flap pane padding asMargin.
	self assert: first bounds inSpace asRectangle equals: paneBounds
]
