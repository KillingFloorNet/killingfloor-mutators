//======================================================================
// Chaingun Bob
//======================================================================
class HeavyTrooper extends DoomTroop;

#exec obj load file=ChaingunB.utx package=DoomPawnsKF
#exec obj load file=ChainGunBS.uax package=DoomPawnsKF

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
		FirePistol(vect(0.3,1,0),900);
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

defaultproperties
{
     FiringTextures(0)=Texture'DoomPawnsKF.ChaingunBob.CPOSE1'
     FiringTextures(1)=Texture'DoomPawnsKF.ChaingunBob.CPOSE2'
     FiringTextures(2)=Texture'DoomPawnsKF.ChaingunBob.CPOSE3'
     FiringTextures(3)=Texture'DoomPawnsKF.ChaingunBob.CPOSE4'
     FiringTextures(4)=Texture'DoomPawnsKF.ChaingunBob.CPOSE5'
     WalkTextures(0)=Texture'DoomPawnsKF.ChaingunBob.CPOSA1'
     WalkTextures(4)=Texture'DoomPawnsKF.ChaingunBob.CPOSA5'
     WalkTextures(5)=Texture'DoomPawnsKF.ChaingunBob.CPOSA4'
     WalkTextures(6)=Texture'DoomPawnsKF.ChaingunBob.CPOSA3'
     WalkTextures(7)=Texture'DoomPawnsKF.ChaingunBob.CPOSA2'
     ShootTextures(0)=Texture'DoomPawnsKF.ChaingunBob.CPOSG1'
     ShootTextures(4)=Texture'DoomPawnsKF.ChaingunBob.CPOSG5'
     ShootTextures(5)=Texture'DoomPawnsKF.ChaingunBob.CPOSG4'
     ShootTextures(6)=Texture'DoomPawnsKF.ChaingunBob.CPOSG3'
     ShootTextures(7)=Texture'DoomPawnsKF.ChaingunBob.CPOSG2'
     DieTexture=Texture'DoomPawnsKF.ChaingunBob.CPOSH0'
     DeadEndTexture=Texture'DoomPawnsKF.ChaingunBob.CPOSN0'
     DropWhenKilled=Class'DoomPawnsKF.DoomChaingunPickup'
     PawnHealth=70
     Acquire2=Sound'DoomPawnsKF.ChaingunBob.DSPOSIT2'
     Die2=Sound'DoomPawnsKF.ChaingunBob.DSPODTH2'
     Die=Sound'DoomPawnsKF.ChaingunBob.DSPODTH1'
     Acquire=Sound'DoomPawnsKF.ChaingunBob.DSPOSIT1'
     bConstFiring=True
     RefireSpeed=0.100000
     hitdamage=(Min=3,Max=15)
     FireSound=Sound'DoomPawnsKF.ChaingunBob.BobChaingun'
     ScoringValue=18
     GroundSpeed=90.000000
     Health=70
     MenuName="Chaingun Bob"
     LightHue=42
     LightSaturation=72
     LightBrightness=250.000000
     LightRadius=6.000000
     bDynamicLight=True
     Texture=Texture'DoomPawnsKF.ChaingunBob.CPOSA1'
}
