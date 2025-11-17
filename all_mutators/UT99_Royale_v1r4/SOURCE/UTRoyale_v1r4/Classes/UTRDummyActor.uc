//=============================================================================
// UTRDummyActor.
//
// Author: Francesco Biscazzo
// Date: 2019
// ©copyright Francesco Biscazzo. All rights reserved.
//
// Description: Sometimes you just need an empty actor, this is for those cases.
//=============================================================================
class UTRDummyActor extends Actor;

defaultproperties
{
	RemoteRole=ROLE_DumbProxy
	bStatic=False
	bNoDelete=False
    bHidden=True
    bCollideWhenPlacing=False
	bCollideWorld=False
	bCollideActors=False
	bBlockActors=False
	bBlockPlayers=False
	bAlwaysRelevant=True
}