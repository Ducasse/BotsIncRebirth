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
