Extension { #name : 'SpToploAbstractListAdapter' }

{ #category : '*Botsinc-Micro' }
SpToploAbstractListAdapter >> buildWidget [
	"Spec-Toplo v0.10.0 handles any drop on the list as a drag of Spec, and fails on the drop of an element without Spec model, such as the title bar of a moved window. We ignore such drops"

	| list |
	list := ToListElement new
		        nodeBuilder: [ :node :dataItem :holder |
				        | child |
				        child := self newItemElementFor: dataItem.
				        model dragEnabled ifTrue: [ self addEventsToChild: child ].
				        node addChild: child ];
		        yourself.
	list addEventHandlerOn: BlDropEvent do: [ :e |
			e gestureSource userData
				at: #specModel
				ifPresent: [ :transferedModel | self model acceptDrop cull: (SpToploTransfer new passenger: { transferedModel }) ] ].
	^ list
]

{ #category : '*Botsinc-Micro' }
SpToploAbstractListAdapter >> refreshList: anAnnouncement [
	"Spec of Pharo 14 sends me when the items of the list presenter change (see SpAbstractListPresenter>>model:), but Spec-Toplo v0.10.0 does not implement me. Reload the items as when the model changes"

	self updateItems
]
