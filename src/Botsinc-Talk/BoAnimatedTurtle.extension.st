Extension { #name : 'BoAnimatedTurtle' }

{ #category : '*Botsinc-Talk' }
BoAnimatedTurtle >> bubbleEvaluate: aBlock [
	"Run the message in its own process so that the moves are shown step by step"

	self animate: [ :aTurtle | aBlock value ]

]
