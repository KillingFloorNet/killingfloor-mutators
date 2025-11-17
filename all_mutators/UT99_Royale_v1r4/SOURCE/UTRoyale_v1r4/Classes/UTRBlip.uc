//=============================================================================
// UTRBlip.
//
// Author: Francesco Biscazzo
// Date: 2019
// ©copyright Francesco Biscazzo. All rights reserved.
//
// Description: This actor can be shown as a blip on the radar and will be interpreted basing on its type and subtype.
//=============================================================================
class UTRBlip extends Info;

var Actor actorInstigator;

var float clientLifeSpan, initialLifeSpan;

var name type, subtype;

replication {
	reliable if (bNetInitial && (Role == ROLE_Authority))
		initialLifeSpan, type, subtype, clientLifeSpan;
}

event Tick(float DeltaTime) {
	super.Tick(DeltaTime);
	
	clientLifeSpan = lifeSpan;
}

defaultproperties
{
	bAlwaysRelevant=True
	RemoteRole=ROLE_SimulatedProxy
	bHidden=True
	
	NetUpdateFrequency=100.000000
}