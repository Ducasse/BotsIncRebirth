"
I load the Bots Inc packages: turtles, flaps, talk bubbles, the turtles recording their drawings as EPS, SVG and PDF, and the micro workspace and micro browser, written with Bloc, Toplo and Spec.

Toplo and its Spec backend Spec-Toplo are pinned to their v0.10.0 releases; they bring Bloc and Album.

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
	"Spec-Toplo and Toplo are pinned to their v0.10.0 releases, which bring Bloc and Album. We only load the Spec-Toplo package of Spec-Toplo: its other packages are examples, tests and a Roassal binding"

	spec baseline: 'Toplo' with: [ spec repository: 'github://pharo-graphics/Toplo:v0.10.0/src' ].
	spec baseline: 'SpecToplo' with: [
			spec
				repository: 'github://pharo-graphics/Spec-Toplo:v0.10.0/src';
				loads: #( 'Spec-Toplo' ) ]
]

{ #category : 'baselines' }
BaselineOfBotsIncRebirth >> groups: spec [

	spec
		group: 'Core' with: #( 'Botsinc-Turtle' 'Botsinc-Flap' 'Botsinc-Talk' 'Botsinc-Recording' 'Botsinc-Micro' );
		group: 'Tests'
		with: #( 'Botsinc-Turtle-Tests' 'Botsinc-Flap-Tests' 'Botsinc-Talk-Tests' 'Botsinc-Recording-Tests' 'Botsinc-Micro-Tests' );
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
		package: 'Botsinc-Talk-Tests' with: [ spec requires: #( 'Botsinc-Talk' ) ];
		package: 'Botsinc-Recording' with: [ spec requires: #( 'Botsinc-Turtle' ) ];
		package: 'Botsinc-Recording-Tests' with: [ spec requires: #( 'Botsinc-Recording' ) ];
		package: 'Botsinc-Micro' with: [ spec requires: #( 'Botsinc-Talk' 'Botsinc-Flap' 'SpecToplo' ) ];
		package: 'Botsinc-Micro-Tests' with: [ spec requires: #( 'Botsinc-Micro' ) ]
]
