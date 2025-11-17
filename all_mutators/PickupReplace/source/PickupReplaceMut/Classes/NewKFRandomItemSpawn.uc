class NewKFRandomItemSpawn extends KFRandomItemSpawn;

var PickupReplaceMut Mut;

simulated function PostBeginPlay()
{
	Mut=PickupReplaceMut(Owner);
	if ( Level.NetMode != NM_Client )
		PowerUp = class<Pickup>(DynamicLoadObject(Mut.GetNewWeaponClassName(), class'Class'));
	if ( KFGameType(Level.Game) != none )
	{
		KFGameType(Level.Game).WeaponPickups[KFGameType(Level.Game).WeaponPickups.Length] = self;
		DisableMe();
	}
	SetLocation(Location - vect(0,0,1));
}

function TurnOn()
{
	PowerUp = class<Pickup>(DynamicLoadObject(Mut.GetNewWeaponClassName(), class'Class'));
	if( myPickup != none )
		myPickup.Destroy();
	SpawnPickup();
	SetTimer(InitialWaitTime+InitialWaitTime*FRand(), false);
}