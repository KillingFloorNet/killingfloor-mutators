//======================================================================
// Plasma Zombie, skin made by Hybrid Zero
//======================================================================
class PlasmaTrooper extends DoomTroop;

#exec obj load file=PlasmaZ.utx package=DoomPawnsKF

var() texture FiringTextures[5];

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
		FireProj(vect(0.8,0.2,0));
		PlaySound(FireSound, SLOT_Misc, 2);
		AnimChange = 2;
		NotifyAnimation(2);
		Return RefireSpeed;
	}
}
simulated function SetFireAnim( byte MyRot, int FrameNum )
{
	if( MyRot==0 )
		UpdateSkin(FiringTextures[0]);
	else if( MyRot==7 )
		UpdateSkin(FiringTextures[1]);
	else if( MyRot==6 )
		UpdateSkin(FiringTextures[2]);
	else if( MyRot==5 )
		UpdateSkin(FiringTextures[3]);
	else UpdateSkin(FiringTextures[4]);
}
function bool SameSpeciesAs(Pawn P)
{
	return (P.Class==Class);
}

defaultproperties
{
     FiringTextures(0)=Texture'DoomPawnsKF.PlasmaZ.EvilPlaye1'
     FiringTextures(1)=Texture'DoomPawnsKF.PlasmaZ.EvilPlaye2e8'
     FiringTextures(2)=Texture'DoomPawnsKF.PlasmaZ.EvilPlaye3e7'
     FiringTextures(3)=Texture'DoomPawnsKF.PlasmaZ.EvilPlaye4e6'
     FiringTextures(4)=Texture'DoomPawnsKF.PlasmaZ.EvilPlaye5'
     WalkTextures(0)=Texture'DoomPawnsKF.PlasmaZ.EvilPlaya1'
     WalkTextures(4)=Texture'DoomPawnsKF.PlasmaZ.EvilPlaya5'
     WalkTextures(5)=Texture'DoomPawnsKF.PlasmaZ.EvilPlaya4a6'
     WalkTextures(6)=Texture'DoomPawnsKF.PlasmaZ.EvilPlaya3a7'
     WalkTextures(7)=Texture'DoomPawnsKF.PlasmaZ.EvilPlaya2a8'
     ShootTextures(0)=Texture'DoomPawnsKF.PlasmaZ.EvilPlayd1'
     ShootTextures(4)=Texture'DoomPawnsKF.PlasmaZ.EvilPlayd5'
     ShootTextures(5)=Texture'DoomPawnsKF.PlasmaZ.EvilPlayd4d6'
     ShootTextures(6)=Texture'DoomPawnsKF.PlasmaZ.EvilPlayd3d7'
     ShootTextures(7)=Texture'DoomPawnsKF.PlasmaZ.EvilPlayd2d8'
     DieTexture=Texture'DoomPawnsKF.PlasmaZ.EvilPLAYO0'
     DeadEndTexture=Texture'DoomPawnsKF.PlasmaZ.EvilPLAYW0'
     RangedProjectile=Class'DoomPawnsKF.ZombieBall'
     DropWhenKilled=Class'DoomPawnsKF.DoomPlasmaPickup'
     PawnHealth=90
     Acquire2=Sound'DoomPawnsKF.ChaingunBob.DSPOSIT2'
     Die2=Sound'DoomPawnsKF.ChaingunBob.DSPODTH2'
     Die=Sound'DoomPawnsKF.ChaingunBob.DSPODTH1'
     Acquire=Sound'DoomPawnsKF.ChaingunBob.DSPOSIT1'
     bConstFiring=True
     bCanPreformFF=False
     RefireSpeed=0.100000
     FireSound=Sound'DoomPawnsKF.D64Snd.DSPLASMA64'
     ScoringValue=5
     Health=90
     MenuName="Plasma Zombie"
     LightHue=85
     LightSaturation=127
     LightBrightness=250.000000
     LightRadius=6.000000
     bDynamicLight=True
     Texture=Texture'DoomPawnsKF.PlasmaZ.EvilPlaya1'
}
