Class DoomArmorPickups extends DoomHealthPickups
	Abstract
	Placeable;

function int GetHealMax(Pawn P)
{
	if (bSuperHeal)
		return 200;
	return 100;
}
auto state Pickup
{
	function Touch( actor Other )
	{
		local Pawn P;
		local int i;

		if ( ValidTouch(Other) )
		{
			P = Pawn(Other);
			i = GetHealMax(P);
			if ( P.ShieldStrength<i )
			{
				P.ShieldStrength = Min(P.ShieldStrength+HealingAmount,i);
				AnnouncePickup(P);
				PlaySound(PickupSound,,2);
				SetRespawn();
			}
		}
	}
}

defaultproperties
{
}
