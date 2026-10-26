Extension { #name : 'BoTurtleWorld' }

{ #category : '*Botsinc-Micro' }
BoTurtleWorld class >> openWithTools [
	"Open a world in a single window, with a workspace in a flap at the bottom and a browser of the turtles in a flap on the right. Click on the tab of a flap to open it. The tools use a light theme, as the world is white"

	<script>
	| world workspaceFlap browserFlap |
	world := self new.
	workspaceFlap := BoFlap new
		                 edge: BoFlapEdge bottom;
		                 thickness: 240;
		                 yourself.
	(BoMicroWorkspace on: world) dockIn: workspaceFlap.
	workspaceFlap attachTo: world.
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
