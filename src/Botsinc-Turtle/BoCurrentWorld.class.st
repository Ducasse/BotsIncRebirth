"
I hold the world where the turtles created by a script go, while the script runs: BoTurtle new adds the turtle to me. The micro playground sets me (see BoMicroPlayground>>run:source:), so that a plain script such as

	| caro | caro := BoTurtle new. caro go: 100

draws in the world of the playground. Outside such a script I am nil and BoTurtle new creates a turtle in no world. I am a dynamic variable, so that I am set only in the process that runs the script.
"
Class {
	#name : 'BoCurrentWorld',
	#superclass : 'DynamicVariable',
	#category : 'Botsinc-Turtle',
	#package : 'Botsinc-Turtle'
}
