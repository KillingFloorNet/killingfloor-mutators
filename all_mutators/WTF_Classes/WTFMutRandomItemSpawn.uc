class WTFMutRandomItemSpawn extends KFRandomItemSpawn;

var() class<Pickup> CommonItems[6];
var() class<Pickup> RareItems[9];
var() class<Pickup> RarestItems[9];

simulated function PostBeginPlay()
{
	local int i;

	if ( Level.NetMode!=NM_Client )
	{
		SetRandPowerUp();
	}
	
	if ( Level.NetMode != NM_DedicatedServer )
	{
		for ( i=0; i< ArrayCount(CommonItems); i++ )
			CommonItems[i].static.StaticPrecache(Level);
			
		for ( i=0; i< ArrayCount(RareItems); i++ )
			RareItems[i].static.StaticPrecache(Level);
			
		for ( i=0; i< ArrayCount(RarestItems); i++ )
			RarestItems[i].static.StaticPrecache(Level);
	}

	if ( KFGameType(Level.Game) != none )
	{
		KFGameType(Level.Game).WeaponPickups[KFGameType(Level.Game).WeaponPickups.Length] = self;
		DisableMe();
	}

	SetLocation(Location - vect(0,0,1)); // adjust because reduced drawscale
}

function SetRandPowerUp()
{
	local float r;
	local int RarestItemsLastIndex, RareItemsLastIndex, CommonItemsLastIndex;
	
	RarestItemsLastIndex = ArrayCount(RarestItems) - 1;
	RareItemsLastIndex = ArrayCount(RareItems) - 1;
	CommonItemsLastIndex = ArrayCount(CommonItems) - 1;
	
	r = FRand();
	
	if (r < 0.05)
		PowerUp = RarestItems[rand(RarestItemsLastIndex)]; //rarest items 5% of the time
	else if (r < 0.2)
		PowerUp = RareItems[rand(RareItemsLastIndex)]; //rare items 20% of the time
	else
		PowerUp = CommonItems[rand(CommonItemsLastIndex)]; //rest of the time common items
	
}

function int GetWeightedRandClass();

function TurnOn()
{
	SetRandPowerUp();
	
	if( myPickup != none )
		myPickup.Destroy();

	SpawnPickup();
	SetTimer(InitialWaitTime+InitialWaitTime*FRand(), false);
}

defaultproperties
{
     CommonItems(0)=Class'WTF.WTFEquipShotgunPickup'
     CommonItems(1)=Class'WTF.WTFEquipMachineDualiesPickup'
     CommonItems(2)=Class'KFMod.WinchesterPickup'
     CommonItems(3)=Class'WTF.WTFEquipBulldogPickup'
     CommonItems(4)=Class'KFMod.MachetePickup'
     CommonItems(5)=Class'WTF.WTFEquipFlaregunPickup'
     RareItems(0)=Class'WTF.WTFEquipBoomStickPickup'
     RareItems(1)=Class'KFMod.DeaglePickup'
     RareItems(2)=Class'WTF.WTFEquipCrossbowPickup'
     RareItems(3)=Class'WTF.WTFEquipAK48SPickup'
     RareItems(4)=Class'WTF.WTFEquipFireAxePickup'
     RareItems(5)=Class'WTF.WTFEquipFTPickup'
     RareItems(6)=Class'WTF.WTFEquipM79CFPickup'
     RareItems(7)=Class'WTF.WTFEquipMP7M2Pickup'
     RareItems(8)=Class'WTF.WTFEquipLethalInjectionPickup'
     RarestItems(0)=Class'WTF.WTFEquipRocketLauncherPickup'
     RarestItems(1)=Class'WTF.WTFEquipAFS12Pickup'
     RarestItems(2)=Class'KFMod.M14EBRPickup'
     RarestItems(3)=Class'WTF.WTFEquipSCAR19Pickup'
     RarestItems(4)=Class'WTF.WTFEquipChainsawPickup'
     RarestItems(5)=Class'WTF.WTFEquipKatanaPickup'
     RarestItems(6)=Class'KFMod.PipeBombPickup'
     RarestItems(7)=Class'WTF.WTFEquipUM32Pickup'
     RarestItems(8)=Class'WTF.WTFEquipSelfDestructPickup'
}
