Class DoomHealthPickups extends TournamentHealth
	Abstract
	Placeable;

#exec obj load file=DPickups.utx package=DoomPawnsKF

function RespawnEffect()
{
	spawn(class'DRespawnEffect');
}
function int GetHealMax(Pawn P)
{
	if (bSuperHeal)
		return (P.HealthMax*2);
	return P.HealthMax;
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
			if ( P.Health<i )
			{ // Override hardcoded limit on KFPawn
				P.Health = Min(P.Health+HealingAmount,i);
				AnnouncePickup(P);
				PlaySound(PickupSound,,2);
				SetRespawn();
			}
		}
	}
}

defaultproperties
{
     PickupSound=Sound'DoomPawnsKF.Generic.DSITEMUP'
     DrawType=DT_Sprite
}
