Class {
	#name : 'BoAnimatedTurtleTest',
	#superclass : 'BoTurtleTest',
	#category : 'Botsinc-Turtle-Tests',
	#package : 'Botsinc-Turtle-Tests'
}

{ #category : 'testing' }
BoAnimatedTurtleTest class >> shouldInheritSelectors [
	^ true
]

{ #category : 'running' }
BoAnimatedTurtleTest >> setUp [
	super setUp.
	world removeTurtles.
	turtle := world newAnimatedTurtle
]

{ #category : 'tests' }
BoAnimatedTurtleTest >> testNotAnimatedWhenNotDisplayed [
	self deny: turtle isAnimating
]

{ #category : 'tests' }
BoAnimatedTurtleTest >> testWorldTurtles [
	| second |
	second := world newAnimatedTurtle.
	self assert: world turtles asArray equals: { turtle. second }.
	world removeTurtles.
	self assert: world turtles isEmpty
]
