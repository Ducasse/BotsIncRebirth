"
I am the Spec application of the Bots Inc tools, the micro playground and the micro browser. I use the Toplo backend, so that the tools are Bloc elements shown in windows inside a turtle world, see BoMicroTool.
"
Class {
	#name : 'BoMicroApplication',
	#superclass : 'SpApplication',
	#category : 'Botsinc-Micro',
	#package : 'Botsinc-Micro'
}

{ #category : 'initialization' }
BoMicroApplication >> initialize [
	"The windows of the tools are Toplo inner windows, that live inside a turtle world instead of opening a native window each"

	super initialize.
	self useBackend: #Toplo.
	self backend useInnerWindowAdapter
]
