// Spawn Random items / weapons in to keep the envirments searchable and dynamic :)/>/>
// Modded from WildcardBase to allow for all pickup classtypes, not just tournament ones.
class PFRandomItemSpawn extends KFRandomItemSpawn;

struct PickupRespawnInfo
{
	var class<Pickup> Pickup;
	var int	Weight;
};

struct WavePickupsType
{
	var array<PickupRespawnInfo> Pickups;
};

var int WaveNum,MaxSellValue;
var array<WavePickupsType> WavePickups;

function bool InitPickupsArray(array<WavePickupsType> WPT)
{
	local int i,n,j,m;

	while ( WavePickups.Length > 0 )
	{
		WavePickups.Remove(0,1);
	}

	WavePickups = WPT;

	/*
	n = WPT.Length;
	WavePickups.Insert(0,n);

	for(i=0; i<n; i++)
	{
	  m = WPT[i].Pickups.Length;
	  WavePickups[i].Pickups.Insert(0,m);

	  for(j=0; j<m; j++)
	  {
	   WavePickups[i].Pickups[j] = WPT[i].Pickups[j];
	  }
	}
	*/

	return true;
}

simulated function PostBeginPlay()
{
	local int i;

	WaveNum = KFGameType(Level.Game).WaveNum;
	NumClasses = WavePickups[WaveNum].Pickups.Length;
	if ( Level.NetMode != NM_Client )
	{
		CurrentClass = GetWeightedRandClass();
		PowerUp = WavePickups[WaveNum].Pickups[CurrentClass].Pickup;
	}
	if ( Level.NetMode != NM_DedicatedServer )
	{
		for ( i=0; i< NumClasses; i++ )
		{
			WavePickups[WaveNum].Pickups[i].Pickup.static.StaticPrecache(Level);
		}
	}
	// Add to KFGameType.WeaponPickups array
	if ( KFGameType(Level.Game) != none )
	{
		KFGameType(Level.Game).WeaponPickups[KFGameType(Level.Game).WeaponPickups.Length] = self;
		DisableMe();
	}
	
	SetLocation(Location - vect(0,0,1)); // adjust because reduced drawscale
}

function NotifyNewWave(int CurrentWave, int FinalWave)
{
	WaveNum = CurrentWave;
}

function TurnOn()
{
	CurrentClass=GetWeightedRandClass();
	PowerUp = WavePickups[WaveNum].Pickups[CurrentClass].Pickup;
	if( myPickup != none )
		myPickup.Destroy();
	SpawnPickup();
	SetTimer(InitialWaitTime+InitialWaitTime*FRand(), false);
}

function int GetWeightedRandClass()
{
	local int RandIndex;
	local int Tally;
	local int i,n;

	WeightTotal = 0;
	n = WavePickups[WaveNum].Pickups.Length;

	for(i=0; i<n; i++)
	{
		WeightTotal += WavePickups[WaveNum].Pickups[i].Weight;
	}
	
	RandIndex = rand(WeightTotal+1); // rand always returns a value between 0 and max-1
	Tally = WavePickups[WaveNum].Pickups[0].Weight;
	i = 0;
	
	while( Tally < RandIndex )
	{
		++i;
		Tally += WavePickups[WaveNum].Pickups[i].Weight;
	}

	return i;
}

function SpawnPickup()
{
	super.SpawnPickup();
	if ( KFWeaponPickup(myPickup) != none )
	{
		KFWeaponPickup(myPickup).SellValue = Min(MaxSellValue,KFWeaponPickup(myPickup).SellValue);
	}
}

defaultproperties
{
}