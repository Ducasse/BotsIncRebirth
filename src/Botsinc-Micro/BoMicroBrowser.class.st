"
I am a small browser to write the methods of one class, the Bloc version of the MicroBrowser of Bots Inc. I am shown in a window inside a turtle world, placed in a flap or anywhere in the world (see BoMicroTool and BoTurtleWorld class>>openWithTools).

I show the categories (protocols) of the class and the methods of the selected category. The categories that exist when I am created are protected: their methods can be read but not changed nor removed, and a new method cannot replace one of their methods. One adds a category for one's own methods, writes a method and accepts it (Cmd+S).

The code pane is colored by a BoTalkStyler, as the talk bubbles.
"
Class {
	#name : 'BoMicroBrowser',
	#superclass : 'BoMicroTool',
	#instVars : [
		'browsedClass',
		'protectedProtocols',
		'protocolList',
		'methodList',
		'codePane',
		'messageLabel',
		'protocolNameInput',
		'addProtocolButton',
		'removeProtocolButton',
		'removeMethodButton',
		'acceptButton'
	],
	#category : 'Botsinc-Micro',
	#package : 'Botsinc-Micro'
}

{ #category : 'instance creation' }
BoMicroBrowser class >> on: aClass [
	"The categories of aClass are protected"

	^ self on: aClass protecting: aClass protocolNames
]

{ #category : 'instance creation' }
BoMicroBrowser class >> on: aClass protecting: aCollectionOfProtocolNames [

	^ (self newApplication: BoMicroApplication new)
		  setClass: aClass protecting: aCollectionOfProtocolNames;
		  yourself
]

{ #category : 'actions' }
BoMicroBrowser >> accept [
	"Compile the text of the code pane in the selected category. Return the selector of the method, or nil when it is refused"

	| source selector |
	self selectedProtocol ifNil: [
			self tell: 'Select a category, or add one, for your method'.
			^ nil ].
	(self isProtected: self selectedProtocol) ifTrue: [
			self tell: 'The methods of ' , self selectedProtocol , ' cannot be changed. Add a category for your methods'.
			^ nil ].
	source := codePane text.
	selector := (OCParser parseFaultyMethod: source) selector.
	(self isProtectedSelector: selector) ifTrue: [
			self tell: 'There is already a method ' , selector , ' in ' , (browsedClass >> selector) protocolName , '. Choose another name'.
			^ nil ].
	selector := [ browsedClass compile: source classified: self selectedProtocol ]
		            on: OCCodeError , OCCompilationError
		            do: [ :error |
				            codePane showError.
				            self tell: (self explanationOf: error).
				            ^ nil ].
	self updateSelectors.
	self selectSelector: selector.
	self tell: selector , ' is accepted'.
	^ selector
]

{ #category : 'actions' }
BoMicroBrowser >> addProtocol [
	"Add a category named as written in the category field"

	self addProtocolNamed: protocolNameInput text.
	protocolNameInput text: ''
]

{ #category : 'actions' }
BoMicroBrowser >> addProtocolNamed: aString [

	| name |
	name := aString trimBoth.
	name ifEmpty: [ ^ self tell: 'Write the name of the new category first' ].
	browsedClass addProtocol: name.
	self updateProtocols.
	self selectProtocol: name
]

{ #category : 'accessing' }
BoMicroBrowser >> browsedClass [

	^ browsedClass
]

{ #category : 'accessing' }
BoMicroBrowser >> codePane [

	^ codePane
]

{ #category : 'window' }
BoMicroBrowser >> defaultExtent [

	^ 560 @ 460
]

{ #category : 'layout' }
BoMicroBrowser >> defaultLayout [
	"We do not use a paned layout: the divider of Toplo divides by its height, which is zero while the browser is in a closed flap"

	^ SpBoxLayout newTopToBottom
		  spacing: 4;
		  add: (SpBoxLayout newLeftToRight
				   spacing: 4;
				   add: protocolList;
				   add: methodList;
				   yourself)
		  height: 140;
		  add: (SpBoxLayout newLeftToRight
				   spacing: 4;
				   add: protocolNameInput;
				   add: addProtocolButton expand: false;
				   add: removeProtocolButton expand: false;
				   add: removeMethodButton expand: false;
				   add: acceptButton expand: false;
				   yourself)
		  expand: false;
		  add: codePane;
		  add: messageLabel expand: false;
		  yourself
]

{ #category : 'private' }
BoMicroBrowser >> explanationOf: aCompilationError [
	"Return the first problem found by the compiler, rather than the list of all of them"

	| notices |
	(aCompilationError isKindOf: OCCompilationError) ifFalse: [ ^ aCompilationError messageText ].
	notices := aCompilationError compilationResult ast allErrorNotices.
	^ notices ifEmpty: [ aCompilationError messageText ] ifNotEmpty: [ notices first messageText ]
]

{ #category : 'initialization' }
BoMicroBrowser >> initializePresenters [

	protocolList := self newList.
	protocolList whenSelectionChangedDo: [ self protocolSelected ].
	methodList := self newList.
	methodList whenSelectionChangedDo: [ self methodSelected ].
	codePane := self instantiate: BoCodePane.
	codePane whenTextEditedDo: [ codePane clearError ].
	codePane addShortcut: BlKeyCombination primaryS named: 'Accept' do: [ self accept ].
	protocolNameInput := self newTextInput
		                     placeholder: 'New category';
		                     yourself.
	addProtocolButton := self
		                     newButtonLabeled: 'Add category'
		                     help: 'Add a category, named as written on the left, for your methods'
		                     action: [ self addProtocol ].
	removeProtocolButton := self
		                        newButtonLabeled: 'Remove category'
		                        help: 'Remove the selected category and its methods'
		                        action: [ self removeProtocol ].
	removeMethodButton := self newButtonLabeled: 'Remove method' help: 'Remove the selected method' action: [ self removeMethod ].
	acceptButton := self
		                newButtonLabeled: 'Accept'
		                help: 'Compile the method in the selected category (Cmd+S)'
		                action: [ self accept ].
	messageLabel := self newLabel
]

{ #category : 'testing' }
BoMicroBrowser >> isProtected: aProtocolName [

	^ protectedProtocols includes: aProtocolName asSymbol
]

{ #category : 'testing' }
BoMicroBrowser >> isProtectedSelector: aSelector [
	"A method of a protected category cannot be replaced"

	^ (browsedClass includesSelector: aSelector) and: [ self isProtected: (browsedClass >> aSelector) protocolName ]
]

{ #category : 'accessing' }
BoMicroBrowser >> message [
	"Return the text shown under the code: what the last action did, or why it failed"

	^ messageLabel label
]

{ #category : 'updating' }
BoMicroBrowser >> methodSelected [

	codePane clearError.
	codePane text: (self selectedSelector ifNil: [ self template ] ifNotNil: [ :aSelector | (browsedClass >> aSelector) sourceCode ])
]

{ #category : 'accessing' }
BoMicroBrowser >> protocolNameInput [

	^ protocolNameInput
]

{ #category : 'updating' }
BoMicroBrowser >> protocolSelected [

	methodList items: self selectors
]

{ #category : 'accessing' }
BoMicroBrowser >> protocols [

	^ browsedClass protocolNames sorted
]

{ #category : 'actions' }
BoMicroBrowser >> removeMethod [

	self selectedSelector ifNotNil: [ :aSelector | self removeMethodNamed: aSelector ]
]

{ #category : 'actions' }
BoMicroBrowser >> removeMethodNamed: aSelector [

	(self isProtectedSelector: aSelector) ifTrue: [ ^ self tell: aSelector , ' cannot be removed' ].
	browsedClass removeSelector: aSelector.
	self updateSelectors.
	self tell: aSelector , ' is removed'
]

{ #category : 'actions' }
BoMicroBrowser >> removeProtocol [

	self selectedProtocol ifNotNil: [ :aProtocol | self removeProtocolNamed: aProtocol ]
]

{ #category : 'actions' }
BoMicroBrowser >> removeProtocolNamed: aProtocolName [

	(self isProtected: aProtocolName) ifTrue: [ ^ self tell: aProtocolName , ' cannot be removed' ].
	browsedClass removeProtocol: aProtocolName.
	self updateProtocols.
	self protocolSelected.
	self tell: aProtocolName , ' is removed'
]

{ #category : 'selecting' }
BoMicroBrowser >> selectProtocol: aProtocolName [

	protocolList selectItem: aProtocolName asSymbol
]

{ #category : 'selecting' }
BoMicroBrowser >> selectSelector: aSelector [

	methodList selectItem: aSelector asSymbol
]

{ #category : 'selecting' }
BoMicroBrowser >> selectedProtocol [

	^ protocolList selectedItem
]

{ #category : 'selecting' }
BoMicroBrowser >> selectedSelector [

	^ methodList selectedItem
]

{ #category : 'accessing' }
BoMicroBrowser >> selectors [
	"Return the selectors of the methods of the selected category"

	^ self selectedProtocol ifNil: [ #(  ) ] ifNotNil: [ :aProtocol | (browsedClass selectorsInProtocol: aProtocol) sorted ]
]

{ #category : 'initialization' }
BoMicroBrowser >> setClass: aClass protecting: aCollectionOfProtocolNames [

	browsedClass := aClass.
	protectedProtocols := aCollectionOfProtocolNames collect: [ :each | each asSymbol ] as: Set.
	codePane beForMethodsOf: aClass.
	self updateProtocols.
	self methodSelected
]

{ #category : 'updating' }
BoMicroBrowser >> tell: aString [

	messageLabel label: aString
]

{ #category : 'accessing' }
BoMicroBrowser >> template [

	^ '"Write your method in the following way:

name of the method with its arguments
	comment of the method

	body of the method

Do not forget to use self to speak to the receiver"'
]

{ #category : 'updating' }
BoMicroBrowser >> updateProtocols [

	| selected |
	selected := self selectedProtocol.
	protocolList items: self protocols.
	(selected notNil and: [ protocolList items includes: selected ]) ifTrue: [ protocolList selectItem: selected ]
]

{ #category : 'updating' }
BoMicroBrowser >> updateSelectors [

	| selected |
	selected := self selectedSelector.
	methodList items: self selectors.
	(selected notNil and: [ methodList items includes: selected ]) ifTrue: [ methodList selectItem: selected ]
]

{ #category : 'window' }
BoMicroBrowser >> windowTitle [
	"Spec asks for the title while initializing the receiver, before the class is set"

	^ browsedClass ifNil: [ 'Micro Browser' ] ifNotNil: [ 'Micro Browser: ' , browsedClass name ]
]
