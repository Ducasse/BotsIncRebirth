"
I color the code typed in a talk bubble. When the message failed, I show the whole text in red until it is corrected, see BoSpeechBubble>>showError:.
"
Class {
	#name : 'BoTalkStyler',
	#superclass : 'BlPharoCodeStyler',
	#instVars : [
		'showsError'
	],
	#category : 'Botsinc-Talk',
	#package : 'Botsinc-Talk'
}

{ #category : 'initialization' }
BoTalkStyler >> initialize [
	super initialize.
	showsError := false.
	self isScripting: true

]

{ #category : 'private' }
BoTalkStyler >> privateStyle: aText [
	showsError ifFalse: [ ^ super privateStyle: aText ].
	aText foreground: Color red.
	fontName ifNotNil: [ aText fontName: fontName ].
	^ aText

]

{ #category : 'accessing' }
BoTalkStyler >> showsError [
	^ showsError

]

{ #category : 'accessing' }
BoTalkStyler >> showsError: aBoolean [
	showsError := aBoolean

]
