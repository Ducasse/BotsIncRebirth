Extension { #name : 'SpToploWindowLikeAdapter' }

{ #category : '*Botsinc-Micro' }
SpToploWindowLikeAdapter >> updateStatusBar [
	"Inspired on SpAbstractMorphicWindowAdapter>>#addStatusBarTo:"

	model statusbar ifNil: [ ^ widget root removeStatusBar ].
	widget root statusBar: model statusbar build
]
