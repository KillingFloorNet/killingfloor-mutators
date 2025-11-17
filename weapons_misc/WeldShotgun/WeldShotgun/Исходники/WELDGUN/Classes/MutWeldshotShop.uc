class MutWeldshotShop extends Mutator;

simulated function PostBeginPlay()
{
	if ( Level.NetMode != NM_Standalone && Level.NetMode != NM_ListenServer )
		return;
	SetTimer(0.1,false);
}

 function Timer()
{
	local KFGameType KF;

	KF = KFGameType(Level.Game);
	if( KF.KFLRules == None || KF.KFLRules.Class == class'KFLevelRules' )
	{
		if ( KF.KFLRules != None ) KF.KFLRules.Destroy();
			KF.KFLRules = Spawn(class'WeldShotLevelRules');
	}
	KF.KFLRules.ItemForSale[KF.KFLRules.ItemForSale.Length] = class'WeldshotPickup';
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
			K.PickupClasses[i] = Class'WeldshotPickup';
			K.PickupWeight[i] = 2;
			break;
		}
}

defaultproperties
{
     bAddToServerPackages=True
     GroupName="KF-WeldshotShop"
     FriendlyName="WeldshotShop Mutator"
     Description="Adds the Weldshot in Shop."
}
