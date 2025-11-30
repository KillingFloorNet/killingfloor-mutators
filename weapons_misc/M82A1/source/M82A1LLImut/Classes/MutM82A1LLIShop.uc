class MutM82A1LLIShop extends Mutator;

simulated function PostBeginPlay()
{
   SetTimer(0.1,false)  ;

}

 function Timer()
{
	local KFGameType KF;

	KF = KFGameType(Level.Game);
	if ( KF!=None )
	{
		if( KF.KFLRules!=None )
			KF.KFLRules.Destroy();
		KF.KFLRules = Spawn(class'M82A1LLILevelRules');
	}

}

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	if( KFRandomItemSpawn(Other)!=None )
		AddPickup(KFRandomItemSpawn(Other));
	return true;
}

final function AddPickup( KFRandomSpawn K )
{
	local int i;

	for( i=0; i<ArrayCount(K.PickupClasses); ++i )
		if( K.PickupClasses[i]==None )
		{
			K.PickupClasses[i] = Class'M82A1LLIPickup';
			K.PickupWeight[i] = 2;
			break;
		}
}

defaultproperties
{
     bAddToServerPackages=True
     GroupName="KF-M82A1LLIShop"
     FriendlyName="M82A1LLI Shop Mutator"
     Description="Adds the M82A1 in Shop."
     bAlwaysRelevant=True
     RemoteRole=ROLE_SimulatedProxy
}
