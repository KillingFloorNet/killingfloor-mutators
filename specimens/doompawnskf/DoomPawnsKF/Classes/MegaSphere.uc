Class MegaSphere extends DoomPickups;

auto state Pickup
{
	function Touch( actor Other )
	{
		if ( ValidTouch(Other) && (Pawn(Other).ShieldStrength<200 || Pawn(Other).Health<200) )
		{
			Pawn(Other).ShieldStrength = Max(Pawn(Other).ShieldStrength,200);
			Pawn(Other).Health = Max(Pawn(Other).Health,200);
			AnnouncePickup(Pawn(Other));
			PlaySound(PickupSound,,2);
			SetRespawn();
		}
	}
}

defaultproperties
{
     PickupMessage="You got a Mega sphere"
     PickupSound=Sound'DoomPawnsKF.Generic.DSGETPOW'
     Texture=Texture'DoomPawnsKF.Armor.MEGAA0'
     DrawScale=1.500000
}
