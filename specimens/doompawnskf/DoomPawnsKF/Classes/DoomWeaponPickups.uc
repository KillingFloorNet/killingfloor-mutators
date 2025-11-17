Class DoomWeaponPickups extends KFWeaponPickup
	Placeable
	Abstract;

function RespawnEffect()
{
	spawn(class'DRespawnEffect');
}
simulated event ClientTrigger()
{
	local PlasmaBallExp P;

	if ( EffectIsRelevant(Location, false) && !Level.GetLocalPlayerController().BeyondViewDistance(Location, CullDistance)  )
	{
		P = Spawn(Class'PlasmaBallExp');
		if( P!=None )
			P.RemoteRole = ROLE_None;
	}
}
function bool CheckCanCarry(KFHumanPawn Hm)
{
	local Inventory CurInv;

	for ( CurInv = Hm.Inventory; CurInv != none; CurInv = CurInv.Inventory )
	{
		if ( CurInv.Class==InventoryType )
			return true; // Allow scrawenge ammo even when can't carry.
	}
	if ( !Hm.CanCarry(Class<KFWeapon>(InventoryType).Default.Weight) )
	{
		if ( LastCantCarryTime < Level.TimeSeconds && PlayerController(Hm.Controller) != none )
		{
			LastCantCarryTime = Level.TimeSeconds + 0.5;
			PlayerController(Hm.Controller).ReceiveLocalizedMessage(Class'KFMainMessages', 2);
		}
		return false;
	}
	return true;
}
state FadeOut
{
Ignores Touch,Tick;

Begin:
	if( Level.NetMode!=NM_DedicatedServer )
		ClientTrigger();
	bClientTrigger = !bClientTrigger;
	NetUpdateTime = Level.TimeSeconds - 1;
	Sleep(0.15);
	Destroy();
}

defaultproperties
{
     RespawnTime=30.000000
     PickupSound=Sound'DoomPawnsKF.Generic.DSWPNUP'
     DrawType=DT_Sprite
     DrawScale=0.500000
}
