"
I load the Bots Inc packages: turtles, flaps and talk bubbles, written with Bloc and Toplo.

Toplo is pinned to the commit used to develop Bots Inc in Pharo 14 (head of its Pharo14 branch); it brings Bloc and Album.

Metacello new
	baseline: 'BotsIncRebirth';
	repository: 'github://Ducasse/BotsIncRebirth:master/src';
	load
"
Class {
	#name : 'BaselineOfBotsIncRebirth',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfBotsIncRebirth',
	#package : 'BaselineOfBotsIncRebirth'
}

{ #category : 'baselines' }
BaselineOfBotsIncRebirth >> baseline: spec [

	<baseline>
	spec for: #common do: [
		self dependencies: spec.
		self packages: spec.
		self groups: spec ]
]

{ #category : 'baselines' }
BaselineOfBotsIncRebirth >> dependencies: spec [
	"Toplo is pinned to the head of its Pharo14 branch used during development; it loads Bloc and Album"

	spec
		baseline: 'Toplo'
		with: [ spec repository: 'github://pharo-graphics/Toplo:c98994edc7c21b92128828e40c93ba5c744de5dd/src' ]
]

{ #category : 'baselines' }
BaselineOfBotsIncRebirth >> groups: spec [

	spec
		group: 'Core' with: #( 'Botsinc-Turtle' 'Botsinc-Flap' 'Botsinc-Talk' );
		group: 'Tests' with: #( 'Botsinc-Turtle-Tests' 'Botsinc-Flap-Tests' 'Botsinc-Talk-Tests' );
		group: 'default' with: #( 'Core' 'Tests' )
]

{ #category : 'baselines' }
BaselineOfBotsIncRebirth >> packages: spec [

	spec
		package: 'Botsinc-Turtle' with: [ spec requires: #( 'Toplo' ) ];
		package: 'Botsinc-Turtle-Tests' with: [ spec requires: #( 'Botsinc-Turtle' ) ];
		package: 'Botsinc-Flap' with: [ spec requires: #( 'Toplo' ) ];
		package: 'Botsinc-Flap-Tests' with: [ spec requires: #( 'Botsinc-Flap' ) ];
		package: 'Botsinc-Talk' with: [ spec requires: #( 'Botsinc-Turtle' ) ];
		package: 'Botsinc-Talk-Tests' with: [ spec requires: #( 'Botsinc-Talk' ) ]
]
