"
I am the common superclass of the flap edge tests. Flaps are 90 thick, 300 long with a 22x70 tab, in a 600x400 world.
"
Class {
	#name : 'BoFlapEdgeTestCase',
	#superclass : 'TestCase',
	#instVars : [
		'flap'
	],
	#category : 'Botsinc-Flap-Tests',
	#package : 'Botsinc-Flap-Tests'
}

{ #category : 'testing' }
BoFlapEdgeTestCase class >> isAbstract [
	^ self == BoFlapEdgeTestCase
]

{ #category : 'running' }
BoFlapEdgeTestCase >> setUp [
	super setUp.
	flap := BoFlap new
]

{ #category : 'accessing' }
BoFlapEdgeTestCase >> worldExtent [
	^ 600 @ 400
]
