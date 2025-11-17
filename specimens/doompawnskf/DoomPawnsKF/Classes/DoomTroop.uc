//======================================================================
// Also known as "Zombies"
//======================================================================
class DoomTroop extends DoomPawns
	Abstract;

function float PlayMyAnim( name MyAnimName )
{
	if( MyAnimName=='Walk' || MyAnimName=='Fall' )
	{
		AnimChange = 0;
		NotifyAnimation(0);
		Return 0;
	}
	else if( MyAnimName=='Still' )
	{
		AnimChange = 1;
		NotifyAnimation(1);
		Return 0.5;
	}
	else
	{
		FirePistol(vect(0.3,1,0),750);
		PlaySound(FireSound, SLOT_Misc, 2);
		AnimChange = 2;
		NotifyAnimation(2);
		Return RefireSpeed;
	}
}
simulated function UpdateAnimation( byte MyRot, optional int FrameNum )
{
	if( MyRot==1 )
		MyRot = 7;
	else if( MyRot==2 )
		MyRot = 6;
	else if( MyRot==3 )
		MyRot = 5;
	if( AnimChange==0 )
		UpdateSkin(WalkTextures[MyRot]);
	else if( AnimChange==1 )
		UpdateSkin(ShootTextures[MyRot]);
	else SetFireAnim(MyRot,FrameNum);
}
simulated function SetFireAnim( byte MyRot, int FrameNum );
simulated function bool MirrorMe( byte Dir )
{
	if( Dir>=1 && Dir<=3 )
		Return True;
	else Return False;
}
function bool SameSpeciesAs(Pawn P)
{
	return False;
}

defaultproperties
{
     DeathSpeed=1.200000
     RangedProjectile=Class'DoomPawnsKF.ImpFlameBall'
     Acquire2=Sound'DoomPawnsKF.Imp.DSBGSIT1'
     Die2=Sound'DoomPawnsKF.Imp.DSBGDTH1'
     Roam=Sound'DoomPawnsKF.ChaingunBob.DSPOSACT'
     Die=Sound'DoomPawnsKF.Imp.DSBGDTH2'
     Acquire=Sound'DoomPawnsKF.Imp.DSBGSIT2'
     Fear=Sound'DoomPawnsKF.ChaingunBob.DSPOSACT'
     Threaten=Sound'DoomPawnsKF.ChaingunBob.DSPOSIT3'
     HitSound1=Sound'DoomPawnsKF.ChaingunBob.DSPOPAIN'
     HitSound2=Sound'DoomPawnsKF.ChaingunBob.DSPOPAIN'
     bHasRangedAttack=True
     bCanPreformFF=True
     RefireSpeed=1.000000
     GroundSpeed=150.000000
     BaseEyeHeight=24.000000
     Texture=Texture'DoomPawnsKF.Imp.TROOA1'
     DrawScale=0.400000
     CollisionRadius=24.000000
     CollisionHeight=40.000000
     Buoyancy=99.000000
}
