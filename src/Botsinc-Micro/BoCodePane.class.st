"
I am the code editor of the micro playground and the micro browser: a Toplo album, the editor of the talk bubbles, embedded in a Spec presenter.

My text is colored by a BoTalkStyler whose workspace is a BoTalkEnvironment, so that the variables shared with the talk bubbles of a world are colored as variables. When the code fails I show my whole text in red until it is edited, see showError.
"
Class {
	#name : 'BoCodePane',
	#superclass : 'SpPresenter',
	#instVars : [
		'album',
		'editorPresenter',
		'environment'
	],
	#category : 'Botsinc-Micro',
	#package : 'Botsinc-Micro'
}

{ #category : 'events' }
BoCodePane >> addShortcut: aKeyCombination named: aString do: aBlock [

	album addEditorShortcut: (BlShortcutWithAction new
			 combination: aKeyCombination;
			 action: [ aBlock value ];
			 name: aString;
			 yourself)
]

{ #category : 'accessing' }
BoCodePane >> album [

	^ album
]

{ #category : 'styling' }
BoCodePane >> beForMethodsOf: aClass [
	"Color the text as a method of aClass instead of a script"

	album styler
		isScripting: false;
		classOrMetaClass: aClass.
	album requestTextStyle
]

{ #category : 'errors' }
BoCodePane >> clearError [

	album styler showsError ifFalse: [ ^ self ].
	album styler showsError: false.
	album requestTextStyle
]

{ #category : 'layout' }
BoCodePane >> defaultLayout [

	^ SpBoxLayout newTopToBottom
		  add: editorPresenter;
		  yourself
]

{ #category : 'accessing' }
BoCodePane >> environment [

	^ environment ifNil: [ environment := BoTalkEnvironment new ]
]

{ #category : 'accessing' }
BoCodePane >> environment: aTalkEnvironment [

	environment := aTalkEnvironment.
	album styler workspace: aTalkEnvironment.
	album requestTextStyle
]

{ #category : 'initialization' }
BoCodePane >> initializePresenters [

	album := self newAlbum.
	editorPresenter := self instantiate: SpBlocPresenter.
	editorPresenter blocElement: album
]

{ #category : 'editing' }
BoCodePane >> moveCursorTo: anIndex [
	"Put the cursor after the character at anIndex, 0 being the start of the text"

	album editor selectNone.
	album navigator
		moveTo: anIndex;
		apply
]

{ #category : 'initialization' }
BoCodePane >> newAlbum [

	^ ToAlbum new
		  styler: (BoTalkStyler new
				   workspace: self environment;
				   yourself);
		  background: Color white;
		  constraintsDo: [ :c |
				  c horizontal matchParent.
				  c vertical matchParent ];
		  yourself
]

{ #category : 'editing' }
BoCodePane >> selectFrom: start to: stop [
	"Select the characters from start to stop, the first character being at 1"

	album selecter
		from: start - 1 to: stop;
		select
]

{ #category : 'accessing' }
BoCodePane >> selectionOrText [
	"Return the selected text, or the whole text when nothing is selected"

	album editor hasSelection ifTrue: [ ^ album editor selectedText asString ].
	^ self text
]

{ #category : 'errors' }
BoCodePane >> showError [

	album styler showsError: true.
	album requestTextStyle
]

{ #category : 'testing' }
BoCodePane >> showsError [

	^ album styler showsError
]

{ #category : 'accessing' }
BoCodePane >> text [

	^ album text asString
]

{ #category : 'accessing' }
BoCodePane >> text: aString [

	album text: aString asRopedText
]

{ #category : 'events' }
BoCodePane >> whenTextEditedDo: aBlock [

	album whenTextEditedDo: [ :anEvent | aBlock value ]
]
