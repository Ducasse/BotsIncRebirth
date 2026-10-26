Extension { #name : 'BoTurtleWorld' }

{ #category : '*Botsinc-Micro' }
BoTurtleWorld class >> openWithTools [
	"Open a world in a single window, with a playground in a flap at the bottom and a browser of the turtles in a flap on the right. Click on the tab of a flap to open it. The tools use a light theme, as the world is white"

	<script>
	| world playgroundFlap browserFlap |
	world := self new.
	playgroundFlap := BoFlap new
		                 edge: BoFlapEdge bottom;
		                 thickness: 240;
		                 yourself.
	(BoMicroPlayground on: world) dockIn: playgroundFlap.
	playgroundFlap attachTo: world.
	browserFlap := BoFlap new
		               edge: BoFlapEdge right;
		               thickness: 460;
		               yourself.
	(BoMicroBrowser on: BoTurtle) dockIn: browserFlap.
	browserFlap attachTo: world.
	world openInSpace.
	world space toTheme: ToBeeTheme new.
	^ world
]
