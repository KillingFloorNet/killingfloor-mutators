//======================================================================
// Spider..
//======================================================================
class Spider extends DoomPawns;

#exec obj load file=SpiderS.uax package=DoomPawnsKF
#exec obj load file=SpiderT.utx package=DoomPawnsKF

var() texture FireAnim[5];
var bool bFootsteps;

function float PlayMyAnim( name MyAnimName )
{
	if( MyAnimName=='Walk' || MyAnimName=='Fall' )
	{
		if( !bFootsteps )
		{
			bFootsteps = True;
			CallTimer(0.5,True);
		}
		AnimChange = 0;
		NotifyAnimation(0);
		Return 0;
	}
	else if( MyAnimName=='Still' )
	{
		if( bFootsteps )
		{
			bFootsteps = False;
			CallTimer(0,False);
		}
		AnimChange = 1;
		NotifyAnimation(1);
		Return 0.5;
	}
	else
	{
		bFootsteps = False;
		CallTimer(0.05,False);
		AnimChange = 2;
		NotifyAnimation(2);
		Return 0.3;
	}
}
function TimedReply()
{
	if( bFootsteps )
	{
		PlaySound(Sound'DSBSPWLK');
		Return;
	}
	PlaySound(Sound'DSPLASMA');
	FireProj(vect(1,0,0));
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
	else
	{
		bForceUnlit = True;
		if( MyRot==7 )
			MyRot = 1;
		else if( MyRot==6 )
			MyRot = 2;
		else if( MyRot==5 )
			MyRot = 3;
		UpdateSkin(FireAnim[MyRot]);
	}
}
simulated function bool MirrorMe( byte Dir )
{
	if( Dir>=1 && Dir<=3 )
		Return True;
	else Return False;
}

defaultproperties
{
     FireAnim(0)=Texture'DoomPawnsKF.Spider.BSPIG1'
     FireAnim(1)=Texture'DoomPawnsKF.Spider.BSPIG2G8'
     FireAnim(2)=Texture'DoomPawnsKF.Spider.BSPIG3G7'
     FireAnim(3)=Texture'DoomPawnsKF.Spider.BSPIG4G6'
     FireAnim(4)=Texture'DoomPawnsKF.Spider.BSPIG5'
     RenderingClass=Class'DoomPawnsKF.FlatDisplay'
     WalkTextures(0)=Texture'DoomPawnsKF.Spider.BSPIA1D1'
     WalkTextures(4)=Texture'DoomPawnsKF.Spider.BSPIA5D5'
     WalkTextures(5)=Texture'DoomPawnsKF.Spider.BSPIA4A6'
     WalkTextures(6)=Texture'DoomPawnsKF.Spider.BSPIA3A7'
     WalkTextures(7)=Texture'DoomPawnsKF.Spider.BSPIA2A8'
     ShootTextures(0)=Texture'DoomPawnsKF.Spider.BSPIC1F1'
     ShootTextures(4)=Texture'DoomPawnsKF.Spider.BSPIC5F5'
     ShootTextures(5)=Texture'DoomPawnsKF.Spider.BSPIF4F6'
     ShootTextures(6)=Texture'DoomPawnsKF.Spider.BSPIF3F7'
     ShootTextures(7)=Texture'DoomPawnsKF.Spider.BSPIF2F8'
     DieTexture=Texture'DoomPawnsKF.Spider.BSPIJ0'
     DeadEndTexture=Texture'DoomPawnsKF.Spider.BSPIP0'
     RangedProjectile=Class'DoomPawnsKF.SpiderBall'
     PawnHealth=500
     Acquire2=Sound'DoomPawnsKF.Spider.DSBSPSIT'
     Die2=Sound'DoomPawnsKF.Spider.DSBSPDTH'
     Roam=Sound'DoomPawnsKF.Spider.DSBSPACT'
     Die=Sound'DoomPawnsKF.Spider.DSBSPDTH'
     Acquire=Sound'DoomPawnsKF.Spider.DSBSPSIT'
     Fear=Sound'DoomPawnsKF.Spider.DSBSPACT'
     Threaten=Sound'DoomPawnsKF.Spider.DSBSPSIT'
     bConstFiring=True
     bHasMelee=True
     bHasRangedAttack=True
     ScoringValue=20
     MeleeRange=45.000000
     GroundSpeed=300.000000
     AccelRate=2000.000000
     BaseEyeHeight=34.000000
     Health=500
     MenuName="Arachnotron"
     Texture=Texture'DoomPawnsKF.Spider.BSPIA1D1'
     CollisionRadius=60.000000
     CollisionHeight=38.000000
     Mass=700.000000
     Buoyancy=700.000000
}
