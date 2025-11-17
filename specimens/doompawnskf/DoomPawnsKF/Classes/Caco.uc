//======================================================================
// Cacodemon, Evil spirit
//======================================================================
class Caco extends DoomPawns;

#exec obj load file=CacoS.uax package=DoomPawnsKF
#exec obj load file=CacoT.utx package=DoomPawnsKF

var() texture FireAnims1[5],FireAnims2[5],FireAnims3[5];

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
		AnimChange = 0;
		NotifyAnimation(0);
		Return 0.5;
	}
	else
	{
		CallTimer(0.3,False);
		AnimChange = 2;
		NotifyAnimation(2);
		Return 0.9;
	}
}
function TimedReply()
{
	Controller.Target = Controller.Enemy;
	PlaySound(Sound'DSFIRSHT');
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
	else
	{
		if( MyRot==7 )
			MyRot = 1;
		else if( MyRot==6 )
			MyRot = 2;
		else if( MyRot==5 )
			MyRot = 3;
		if( FrameNum==0 )
			UpdateSkin(FireAnims1[MyRot]);
		else if( FrameNum==1 )
			UpdateSkin(FireAnims2[MyRot]);
		else UpdateSkin(FireAnims3[MyRot]);
	}
}
simulated function NotifyAnimation( byte AnimNum )
{
	if( AnimNum==2 )
		Render.SetAnimatedTime(0.9,3);
	else
	{
		Render.TimeLeft = 0;
		Render.LastCheckB = 9;
	}
}
simulated function bool MirrorMe( byte Dir )
{
	if( Dir>=1 && Dir<=3 )
		Return True;
	else Return False;
}
function SetMovementPhysics()
{
	SetPhysics(PHYS_Flying); 
}
singular function Falling()
{
	SetPhysics(PHYS_Flying);
}

defaultproperties
{
     FireAnims1(0)=Texture'DoomPawnsKF.Cacodemon.HEADB1'
     FireAnims1(1)=Texture'DoomPawnsKF.Cacodemon.HEADB2B8'
     FireAnims1(2)=Texture'DoomPawnsKF.Cacodemon.HEADB3B7'
     FireAnims1(3)=Texture'DoomPawnsKF.Cacodemon.HEADB4B6'
     FireAnims1(4)=Texture'DoomPawnsKF.Cacodemon.HEADB5'
     FireAnims2(0)=Texture'DoomPawnsKF.Cacodemon.HEADC1'
     FireAnims2(1)=Texture'DoomPawnsKF.Cacodemon.HEADC2C8'
     FireAnims2(2)=Texture'DoomPawnsKF.Cacodemon.HEADC3C7'
     FireAnims2(3)=Texture'DoomPawnsKF.Cacodemon.HEADC4C6'
     FireAnims2(4)=Texture'DoomPawnsKF.Cacodemon.HEADC5'
     FireAnims3(0)=Texture'DoomPawnsKF.Cacodemon.HEADD1'
     FireAnims3(1)=Texture'DoomPawnsKF.Cacodemon.HEADD2D8'
     FireAnims3(2)=Texture'DoomPawnsKF.Cacodemon.HEADD3D7'
     FireAnims3(3)=Texture'DoomPawnsKF.Cacodemon.HEADD4D6'
     FireAnims3(4)=Texture'DoomPawnsKF.Cacodemon.HEADD5'
     WalkTextures(0)=Texture'DoomPawnsKF.Cacodemon.HEADA1'
     WalkTextures(4)=Texture'DoomPawnsKF.Cacodemon.HEADA5'
     WalkTextures(5)=Texture'DoomPawnsKF.Cacodemon.HEADA4A6'
     WalkTextures(6)=Texture'DoomPawnsKF.Cacodemon.HEADA3A7'
     WalkTextures(7)=Texture'DoomPawnsKF.Cacodemon.HEADA2A8'
     DieTexture=Texture'DoomPawnsKF.Cacodemon.HEADG0'
     DeadEndTexture=Texture'DoomPawnsKF.Cacodemon.HEADL0'
     DeathSpeed=1.000000
     RangedProjectile=Class'DoomPawnsKF.CacoFlameBall'
     PawnHealth=400
     Acquire2=Sound'DoomPawnsKF.Cacodemon.DSCACSIT'
     Die=Sound'DoomPawnsKF.Cacodemon.DSCACDTH'
     Acquire=Sound'DoomPawnsKF.Cacodemon.DSCACSIT'
     Threaten=Sound'DoomPawnsKF.Cacodemon.DSCACSIT'
     HitSound1=Sound'DoomPawnsKF.Imp.DSDMPAIN'
     HitSound2=Sound'DoomPawnsKF.Imp.DSDMPAIN'
     bHasRangedAttack=True
     ScoringValue=20
     bCanFly=True
     MeleeRange=30.000000
     GroundSpeed=25.000000
     AirSpeed=200.000000
     BaseEyeHeight=24.000000
     Health=400
     MenuName="Cacodemon"
     Texture=Texture'DoomPawnsKF.Cacodemon.HEADA1'
     DrawScale=0.400000
     CollisionRadius=47.000000
     CollisionHeight=47.000000
     Buoyancy=99.000000
}
