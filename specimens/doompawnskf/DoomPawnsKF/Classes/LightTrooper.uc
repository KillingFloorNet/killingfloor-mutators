//======================================================================
// Zombieman
//======================================================================
class LightTrooper extends DoomTroop;

#exec obj load file=GunGuy.utx package=DoomPawnsKF

var() texture FireAnims1[5],FireAnims2[5];

simulated function SetFireAnim( byte MyRot, int FrameNum )
{
	if( MyRot==7 )
		MyRot = 1;
	else if( MyRot==6 )
		MyRot = 2;
	else if( MyRot==5 )
		MyRot = 3;
	if( FrameNum==0 )
		UpdateSkin(FireAnims1[MyRot]);
	else UpdateSkin(FireAnims2[MyRot]);
}
simulated function NotifyAnimation( byte AnimNum )
{
	if( AnimNum==2 )
		Render.SetAnimatedTime(0.2,2);
	else
	{
		Render.TimeLeft = 0;
		Render.LastCheckB = 9;
	}
}

defaultproperties
{
     FireAnims1(0)=Texture'DoomPawnsKF.Zombie.POSSE1'
     FireAnims1(1)=Texture'DoomPawnsKF.Zombie.POSSE2E8'
     FireAnims1(2)=Texture'DoomPawnsKF.Zombie.POSSE3E7'
     FireAnims1(3)=Texture'DoomPawnsKF.Zombie.POSSE4E6'
     FireAnims1(4)=Texture'DoomPawnsKF.Zombie.POSSE5'
     FireAnims2(0)=Texture'DoomPawnsKF.Zombie.POSSF1'
     FireAnims2(1)=Texture'DoomPawnsKF.Zombie.POSSF2F8'
     FireAnims2(2)=Texture'DoomPawnsKF.Zombie.POSSF3F7'
     FireAnims2(3)=Texture'DoomPawnsKF.Zombie.POSSF4F6'
     FireAnims2(4)=Texture'DoomPawnsKF.Zombie.POSSF5'
     WalkTextures(0)=Texture'DoomPawnsKF.Zombie.POSSA1'
     WalkTextures(4)=Texture'DoomPawnsKF.Zombie.POSSA5'
     WalkTextures(5)=Texture'DoomPawnsKF.Zombie.POSSA4A6'
     WalkTextures(6)=Texture'DoomPawnsKF.Zombie.POSSA3A7'
     WalkTextures(7)=Texture'DoomPawnsKF.Zombie.POSSA2A8'
     ShootTextures(0)=Texture'DoomPawnsKF.Zombie.POSSE1'
     ShootTextures(4)=Texture'DoomPawnsKF.Zombie.POSSE5'
     ShootTextures(5)=Texture'DoomPawnsKF.Zombie.POSSE4E6'
     ShootTextures(6)=Texture'DoomPawnsKF.Zombie.POSSE3E7'
     ShootTextures(7)=Texture'DoomPawnsKF.Zombie.POSSE2E8'
     DieTexture=Texture'DoomPawnsKF.Zombie.POSSH0'
     DeadEndTexture=Texture'DoomPawnsKF.Zombie.POSSL0'
     DropWhenKilled=Class'DoomPawnsKF.DoomPistolAmmoPickup'
     PawnHealth=20
     Acquire2=Sound'DoomPawnsKF.ChaingunBob.DSPOSIT2'
     Die2=Sound'DoomPawnsKF.ChaingunBob.DSPODTH2'
     Die=Sound'DoomPawnsKF.ChaingunBob.DSPODTH1'
     Acquire=Sound'DoomPawnsKF.ChaingunBob.DSPOSIT1'
     PauseAfterShooting=0.800000
     RefireSpeed=0.200000
     hitdamage=(Min=3,Max=15)
     FireSound=Sound'DoomPawnsKF.Marine.DSPISTOL'
     ScoringValue=5
     GroundSpeed=120.000000
     Health=20
     MenuName="Zombieman"
     Texture=Texture'DoomPawnsKF.Zombie.POSSA1'
}
