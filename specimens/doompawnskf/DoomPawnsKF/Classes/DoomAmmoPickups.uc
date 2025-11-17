Class DoomAmmoPickups extends KFAmmoPickup
	Abstract;

var bool bWasAdded;

event PostBeginPlay()
{
	// Add to KFGameType.AmmoPickups array
	if ( KFGameType(Level.Game)!=none && KFSPGameType(Level.Game)==None )
	{
		bWasAdded = true;
		KFGameType(Level.Game).AmmoPickups[KFGameType(Level.Game).AmmoPickups.Length] = self;
	}
}
function Destroyed()
{
	local KFGameType KF;
	local int i;

	Super.Destroyed();

	// Remove from KFGameType.AmmoPickups array
	KF = KFGameType(Level.Game);
	if ( KF!=none && bWasAdded )
	{
		for( i=0; i<KF.AmmoPickups.Length; i++ )
			if( KF.AmmoPickups[i]==None || KF.AmmoPickups[i]==Self )
				KF.AmmoPickups.Remove(i--,1);
		bWasAdded = false;
	}
}
function float DetourWeight(Pawn Other,float PathWeight)
{
	local Inventory inv;
	local Weapon W;
	local float Desire;
	
	if ( Other.Weapon.AIRating >= 0.5 )
		return 0;
	
	for ( Inv=Other.Inventory; Inv!=None; Inv=Inv.Inventory )
	{
		W = Weapon(Inv);
		if ( W != None )
		{
			Desire = W.DesireAmmo(InventoryType, true);
			if ( Desire != 0 )
				return Desire * MaxDesireability/PathWeight;
		}
	}
	return 0;
}
function float BotDesireability(Pawn Bot)
{
	local Inventory inv;
	local Weapon W;
	local float Desire;
	local Ammunition M;
	
	if ( Bot.Controller.bHuntPlayer )
		return 0;
	for ( Inv=Bot.Inventory; Inv!=None; Inv=Inv.Inventory )
	{
		W = Weapon(Inv);
		if ( W != None )
		{
			Desire = W.DesireAmmo(InventoryType, false);
			if ( Desire != 0 )
				return Desire * MaxDesireability;
		}
	}
	M = Ammunition(Bot.FindInventoryType(InventoryType));
	if ( (M != None) && (M.AmmoAmount >= M.MaxAmmo) )
		return -1;
	return 0.25 * MaxDesireability;
}
function inventory SpawnCopy( Pawn Other )
{
	local Inventory Copy;

	Copy = Super(Pickup).SpawnCopy(Other);
	Ammunition(Copy).AmmoAmount = AmmoAmount;
	return Copy;
}
function RespawnEffect()
{
	spawn(class'DRespawnEffect');
}

// Be initially enabled.
Auto state Pickup
{
	// When touched by an actor.
	function Touch( actor Other )
	{
		local Inventory Copy;

		// If touched by a player pawn, let him pick this up.
		if( ValidTouch(Other) )
		{
			Copy = SpawnCopy(Pawn(Other));
			AnnouncePickup(Pawn(Other));
			SetRespawn();
			if ( Copy != None )
				Copy.PickupFunction(Pawn(Other));
		}
	}
}

defaultproperties
{
     PickupSound=Sound'DoomPawnsKF.Generic.DSITEMUP'
     DrawType=DT_Sprite
}
