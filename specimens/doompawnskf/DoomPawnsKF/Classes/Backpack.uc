Class Backpack extends DoomPickups;

auto state Pickup
{
	function Touch( actor Other )
	{
		local Inventory I;

		if ( ValidTouch(Other) )
		{
			for( I=Other.Inventory; I!=None; I=I.Inventory )
				if( Ammunition(I)!=None )
				{
					Ammunition(I).MaxAmmo = Max(Ammunition(I).Default.MaxAmmo*2,Ammunition(I).MaxAmmo);
					Ammunition(I).AddAmmo(Ammunition(I).InitialAmount*0.5);
				}
			AnnouncePickup(Pawn(Other));
			PlaySound(PickupSound,,2);
			SetRespawn();
		}
	}
}

defaultproperties
{
     PickupMessage="You got an ammo backpack"
     PickupSound=Sound'DoomPawnsKF.Generic.DSWPNUP'
     Texture=Texture'DoomPawnsKF.Armor.BPAKA0'
     DrawScale=1.250000
}
