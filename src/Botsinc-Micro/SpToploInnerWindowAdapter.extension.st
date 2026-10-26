Extension { #name : 'SpToploInnerWindowAdapter' }

{ #category : '*Botsinc-Micro' }
SpToploInnerWindowAdapter >> updateStatusBar [

	model hasStatusbar ifFalse: [ ^ self container removeStatusBar ].

	"Build new Toplo status bar from presenter spec and set it."
	self container statusBar: model statusbar build
]
