class MutM249Shop extends Mutator;

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
		KF.KFLRules = Spawn(class'M249LevelRules');
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
			K.PickupClasses[i] = Class'M249Pickup';
			K.PickupWeight[i] = 2;
			break;
		}
}

defaultproperties
{
     bAddToServerPackages=True
     GroupName="KF-M249Shop"
     FriendlyName="M249Shop Mutator"
     Description="Adds the M249 in Shop."
     bAlwaysRelevant=True
     RemoteRole=ROLE_SimulatedProxy
}
