// Zombie Monster for KF Invasion gametype
class ZClot extends ZombieClot;

simulated function ClawDamageTarget()
{
	local vector PushDir;
	local KFPawn KFP;
	local float UsedMeleeDamage;


	if( MeleeDamage > 1 )
    {
	   UsedMeleeDamage = (MeleeDamage - (MeleeDamage * 0.05)) + (MeleeDamage * (FRand() * 0.1));
	}
	else
	{
	   UsedMeleeDamage = MeleeDamage;
	}

	// If zombie has latched onto us...
	if ( MeleeDamageTarget( UsedMeleeDamage, PushDir))
	{
		KFP = KFPawn(Controller.Target);

        	PlaySound(MeleeAttackHitSound, SLOT_Interact, 2.0);

        	/*if( !bDecapitated && KFP != none )
        	{
			if ( KFPlayerReplicationInfo(KFP.PlayerReplicationInfo) == none ||
				 KFP.GetVeteran().static.CanBeGrabbed(KFPlayerReplicationInfo(KFP.PlayerReplicationInfo), self))
			{
				if( DisabledPawn != none )
				{
				     //DisabledPawn.bMovementDisabled = false;
				}

				//KFP.DisableMovement(GrappleDuration);
				//DisabledPawn = KFP;
			}
		}*/
	}
}

defaultproperties
{
     GroundSpeed=140.000000
}
