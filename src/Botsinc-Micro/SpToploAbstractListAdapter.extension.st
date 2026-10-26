Extension { #name : 'SpToploAbstractListAdapter' }

{ #category : '*Botsinc-Micro' }
SpToploAbstractListAdapter >> refreshList: anAnnouncement [
	"Spec of Pharo 14 sends me when the items of the list presenter change (see SpAbstractListPresenter>>model:), but Spec-Toplo v0.10.0 does not implement me. Reload the items as when the model changes"

	self updateItems
]
