//======================================================================
// Baron of Hell.. A boss @ Doom
//======================================================================
class Baron extends Knight;

#exec obj load file=BaronS.uax package=DoomPawnsKF
#exec obj load file=BaronT.utx package=DoomPawnsKF

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
	else
	{
		if( MyRot==7 )
			MyRot = 1;
		else if( MyRot==6 )
			MyRot = 2;
		else if( MyRot==5 )
			MyRot = 3;
		if( FrameNum==0 || FrameNum==1 )
		{
			bForceUnlit = True;
			Render.Skins[0] = FireAnims1[MyRot];
		}
		else if( FrameNum==2 )
			UpdateSkin(FireAnims2[MyRot]);
		else UpdateSkin(FireAnims3[MyRot]);
	}
}

defaultproperties
{
     FireAnims1(0)=Texture'DoomPawnsKF.Baron.BOSSE1'
     FireAnims1(1)=Texture'DoomPawnsKF.Baron.BOSSE2'
     FireAnims1(2)=Texture'DoomPawnsKF.Baron.BOSSE3'
     FireAnims1(3)=Texture'DoomPawnsKF.Baron.BOSSE4'
     FireAnims1(4)=Texture'DoomPawnsKF.Baron.BOSSE5'
     FireAnims2(0)=Texture'DoomPawnsKF.Baron.BOSSF1'
     FireAnims2(1)=Texture'DoomPawnsKF.Baron.BOSSF2'
     FireAnims2(2)=Texture'DoomPawnsKF.Baron.BOSSF3'
     FireAnims2(3)=Texture'DoomPawnsKF.Baron.BOSSF4'
     FireAnims2(4)=Texture'DoomPawnsKF.Baron.BOSSF5'
     FireAnims3(0)=Texture'DoomPawnsKF.Baron.BOSSG1'
     FireAnims3(1)=Texture'DoomPawnsKF.Baron.BOSSG2'
     FireAnims3(2)=Texture'DoomPawnsKF.Baron.BOSSG3'
     FireAnims3(3)=Texture'DoomPawnsKF.Baron.BOSSG4'
     FireAnims3(4)=Texture'DoomPawnsKF.Baron.BOSSG5'
     WalkTextures(0)=Texture'DoomPawnsKF.Baron.BOSSA1'
     WalkTextures(4)=Texture'DoomPawnsKF.Baron.BOSSA5'
     WalkTextures(5)=Texture'DoomPawnsKF.Baron.BOSSA4A6'
     WalkTextures(6)=Texture'DoomPawnsKF.Baron.BOSSA3A7'
     WalkTextures(7)=Texture'DoomPawnsKF.Baron.BOSSA2A8'
     ShootTextures(0)=Texture'DoomPawnsKF.Baron.BOSSD1'
     ShootTextures(4)=Texture'DoomPawnsKF.Baron.BOSSD5'
     ShootTextures(5)=Texture'DoomPawnsKF.Baron.BOSSD4D6'
     ShootTextures(6)=Texture'DoomPawnsKF.Baron.BOSSD3D7'
     ShootTextures(7)=Texture'DoomPawnsKF.Baron.BOSSD2D8'
     DieTexture=Texture'DoomPawnsKF.Baron.BOSSI0'
     DeadEndTexture=Texture'DoomPawnsKF.Baron.BOSSO0'
     PawnHealth=1000
     Acquire2=Sound'DoomPawnsKF.Baron.DSBRSSIT'
     Die2=Sound'DoomPawnsKF.Baron.DSBRSDTH'
     Die=Sound'DoomPawnsKF.Baron.DSBRSDTH'
     Acquire=Sound'DoomPawnsKF.Baron.DSBRSSIT'
     Threaten=Sound'DoomPawnsKF.Baron.DSBRSSIT'
     ScoringValue=38
     Health=1000
     MenuName="Baron of Hell"
     Texture=Texture'DoomPawnsKF.Baron.BOSSA1'
     Mass=1500.000000
     Buoyancy=1500.000000
}
