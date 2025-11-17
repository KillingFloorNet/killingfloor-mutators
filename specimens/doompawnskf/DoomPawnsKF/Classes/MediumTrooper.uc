//======================================================================
// Shotgun Dude
//======================================================================
class MediumTrooper extends DoomTroop;

#exec obj load file=ShotGunDood.utx package=DoomPawnsKF

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
	{
		bForceUnlit = True;
		UpdateSkin(FireAnims1[MyRot]);
	}
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
function float PlayMyAnim( name MyAnimName )
{
	local int i;
	
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
		for( i=0; i<7; i++ )
			FirePistol(vect(0.3,1,0),1600);
		PlaySound(FireSound, SLOT_Misc, 2);
		AnimChange = 2;
		NotifyAnimation(2);
		if( PlayerController(Controller)!=None )
			Return (RefireSpeed+PauseAfterShooting);
		Return RefireSpeed;
	}
}

defaultproperties
{
     FireAnims1(0)=Texture'DoomPawnsKF.ShotgunD.SPOSE1'
     FireAnims1(1)=Texture'DoomPawnsKF.ShotgunD.SPOSE2E8'
     FireAnims1(2)=Texture'DoomPawnsKF.ShotgunD.SPOSE3E7'
     FireAnims1(3)=Texture'DoomPawnsKF.ShotgunD.SPOSE4E6'
     FireAnims1(4)=Texture'DoomPawnsKF.ShotgunD.SPOSE5'
     FireAnims2(0)=Texture'DoomPawnsKF.ShotgunD.SPOSF1'
     FireAnims2(1)=Texture'DoomPawnsKF.ShotgunD.SPOSF2F8'
     FireAnims2(2)=Texture'DoomPawnsKF.ShotgunD.SPOSF3F7'
     FireAnims2(3)=Texture'DoomPawnsKF.ShotgunD.SPOSF4F6'
     FireAnims2(4)=Texture'DoomPawnsKF.ShotgunD.SPOSF5'
     WalkTextures(0)=Texture'DoomPawnsKF.ShotgunD.SPOSA1'
     WalkTextures(4)=Texture'DoomPawnsKF.ShotgunD.SPOSA5'
     WalkTextures(5)=Texture'DoomPawnsKF.ShotgunD.SPOSA4A6'
     WalkTextures(6)=Texture'DoomPawnsKF.ShotgunD.SPOSA3A7'
     WalkTextures(7)=Texture'DoomPawnsKF.ShotgunD.SPOSA2A8'
     ShootTextures(0)=Texture'DoomPawnsKF.ShotgunD.SPOSE1'
     ShootTextures(4)=Texture'DoomPawnsKF.ShotgunD.SPOSE5'
     ShootTextures(5)=Texture'DoomPawnsKF.ShotgunD.SPOSE4E6'
     ShootTextures(6)=Texture'DoomPawnsKF.ShotgunD.SPOSE3E7'
     ShootTextures(7)=Texture'DoomPawnsKF.ShotgunD.SPOSE2E8'
     DieTexture=Texture'DoomPawnsKF.ShotgunD.SPOSH0'
     DeadEndTexture=Texture'DoomPawnsKF.ShotgunD.SPOSL0'
     DropWhenKilled=Class'DoomPawnsKF.DoomShotgunPickup'
     PawnHealth=30
     Acquire2=Sound'DoomPawnsKF.ChaingunBob.DSPOSIT2'
     Die2=Sound'DoomPawnsKF.ChaingunBob.DSPODTH2'
     Die=Sound'DoomPawnsKF.ChaingunBob.DSPODTH1'
     Acquire=Sound'DoomPawnsKF.ChaingunBob.DSPOSIT1'
     PauseAfterShooting=0.600000
     RefireSpeed=0.200000
     hitdamage=(Min=3,Max=15)
     FireSound=Sound'DoomPawnsKF.ChaingunBob.BobChaingun'
     ScoringValue=10
     GroundSpeed=115.000000
     Health=30
     MenuName="Shotgun Dude"
     Texture=Texture'DoomPawnsKF.ShotgunD.SPOSA1'
}
