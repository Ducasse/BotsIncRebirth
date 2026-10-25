Extension { #name : 'BlElement' }

{ #category : '*Botsinc-Talk' }
BlElement >> bubbleEvaluate: aBlock [
	"Evaluate aBlock, which runs a message typed in a talk bubble. Subclasses may run it in another process"

	aBlock value

]

{ #category : '*Botsinc-Talk' }
BlElement >> bubbleReceiver [
	"Return the object to which a talk bubble pointing at the receiver sends its messages, or nil when the receiver cannot be talked to"

	^ nil

]

{ #category : '*Botsinc-Talk' }
BlElement >> isQuestionBubble [
	^ false

]
