//======================================================================
// Arch-Vile, brrrr...
//======================================================================
class Vile extends DoomPawns;

#exec obj load file=ArchTex.utx package=DoomPawnsKF
#exec obj load file=ArchSnd.uax package=DoomPawnsKF

var FlameEffects MyEffect;
var bool bMakeNewFX;
var() texture FireFrames1[10],FireFrames2[10],FireFrames3[10],FireFrames4[10],FireFrames5[10];

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
	else if( MyAnimName=='Fire2' )
	{
		AnimChange = 1;
		NotifyAnimation(1);
		Return 0.8;
	}
	else
	{
		bMakeNewFX = True;
		CallTimer(0.1,True);
		PlaySound(Sound'DSVILATK');
		AnimChange = 2;
		NotifyAnimation(2);
		Return 2;
	}
}
function TimedReply()
{
	if( !bMakeNewFX )
	{
		if( MyEffect==None )
			StopTimer();
		else if( Controller.Target!=None )
			MyEffect.Affected = Controller.Target;
		Return;
	}
	if( Controller.Target==None ) Return;
	if( Controller.LineOfSightTo(Controller.Target) )
		MyEffect = Spawn(class'FlameEffects',Self,,Controller.Target.Location);
	else MyEffect = Spawn(class'FlameEffects',Self,,Location+vector(Rotation)*100);
	MyEffect.Affected = Controller.Target;
	bMakeNewFX = False;
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
		if( MyRot==0 )
			UpdateSkin(FireFrames1[FrameNum]);
		else if( MyRot==7 )
			UpdateSkin(FireFrames2[FrameNum]);
		else if( MyRot==6 )
			UpdateSkin(FireFrames3[FrameNum]);
		else if( MyRot==5 )
			UpdateSkin(FireFrames4[FrameNum]);
		else UpdateSkin(FireFrames5[FrameNum]);
	}
}
simulated function NotifyAnimation( byte AnimNum )
{
	if( AnimNum==2 )
		Render.SetAnimatedTime(2,9);
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

defaultproperties
{
     FireFrames1(0)=Texture'DoomPawnsKF.ArchVile.VILEG1'
     FireFrames1(1)=Texture'DoomPawnsKF.ArchVile.VILEH1'
     FireFrames1(2)=Texture'DoomPawnsKF.ArchVile.VILEI1'
     FireFrames1(3)=Texture'DoomPawnsKF.ArchVile.VILEJ1'
     FireFrames1(4)=Texture'DoomPawnsKF.ArchVile.VILEK1'
     FireFrames1(5)=Texture'DoomPawnsKF.ArchVile.VILEL1'
     FireFrames1(6)=Texture'DoomPawnsKF.ArchVile.VILEM1'
     FireFrames1(7)=Texture'DoomPawnsKF.ArchVile.VILEN1'
     FireFrames1(8)=Texture'DoomPawnsKF.ArchVile.VILEO1'
     FireFrames1(9)=Texture'DoomPawnsKF.ArchVile.VILEP1'
     FireFrames2(0)=Texture'DoomPawnsKF.ArchVile.VILEG2'
     FireFrames2(1)=Texture'DoomPawnsKF.ArchVile.VILEH2'
     FireFrames2(2)=Texture'DoomPawnsKF.ArchVile.VILEI2'
     FireFrames2(3)=Texture'DoomPawnsKF.ArchVile.VILEJ2'
     FireFrames2(4)=Texture'DoomPawnsKF.ArchVile.VILEK2'
     FireFrames2(5)=Texture'DoomPawnsKF.ArchVile.VILEL2'
     FireFrames2(6)=Texture'DoomPawnsKF.ArchVile.VILEM2'
     FireFrames2(7)=Texture'DoomPawnsKF.ArchVile.VILEN2'
     FireFrames2(8)=Texture'DoomPawnsKF.ArchVile.VILEO2'
     FireFrames2(9)=Texture'DoomPawnsKF.ArchVile.VILEP2'
     FireFrames3(0)=Texture'DoomPawnsKF.ArchVile.VILEG3'
     FireFrames3(1)=Texture'DoomPawnsKF.ArchVile.VILEH3'
     FireFrames3(2)=Texture'DoomPawnsKF.ArchVile.VILEI3'
     FireFrames3(3)=Texture'DoomPawnsKF.ArchVile.VILEJ3'
     FireFrames3(4)=Texture'DoomPawnsKF.ArchVile.VILEK3'
     FireFrames3(5)=Texture'DoomPawnsKF.ArchVile.VILEL3'
     FireFrames3(6)=Texture'DoomPawnsKF.ArchVile.VILEM3'
     FireFrames3(7)=Texture'DoomPawnsKF.ArchVile.VILEN3'
     FireFrames3(8)=Texture'DoomPawnsKF.ArchVile.VILEO3'
     FireFrames3(9)=Texture'DoomPawnsKF.ArchVile.VILEP3'
     FireFrames4(0)=Texture'DoomPawnsKF.ArchVile.VILEG4'
     FireFrames4(1)=Texture'DoomPawnsKF.ArchVile.VILEH4'
     FireFrames4(2)=Texture'DoomPawnsKF.ArchVile.VILEI4'
     FireFrames4(3)=Texture'DoomPawnsKF.ArchVile.VILEJ4'
     FireFrames4(4)=Texture'DoomPawnsKF.ArchVile.VILEK4'
     FireFrames4(5)=Texture'DoomPawnsKF.ArchVile.VILEL4'
     FireFrames4(6)=Texture'DoomPawnsKF.ArchVile.VILEM4'
     FireFrames4(7)=Texture'DoomPawnsKF.ArchVile.VILEN4'
     FireFrames4(8)=Texture'DoomPawnsKF.ArchVile.VILEO4'
     FireFrames4(9)=Texture'DoomPawnsKF.ArchVile.VILEP4'
     FireFrames5(0)=Texture'DoomPawnsKF.ArchVile.VILEG5'
     FireFrames5(1)=Texture'DoomPawnsKF.ArchVile.VILEH5'
     FireFrames5(2)=Texture'DoomPawnsKF.ArchVile.VILEI5'
     FireFrames5(3)=Texture'DoomPawnsKF.ArchVile.VILEJ5'
     FireFrames5(4)=Texture'DoomPawnsKF.ArchVile.VILEK5'
     FireFrames5(5)=Texture'DoomPawnsKF.ArchVile.VILEL5'
     FireFrames5(6)=Texture'DoomPawnsKF.ArchVile.VILEM5'
     FireFrames5(7)=Texture'DoomPawnsKF.ArchVile.VILEN5'
     FireFrames5(8)=Texture'DoomPawnsKF.ArchVile.VILEO5'
     FireFrames5(9)=Texture'DoomPawnsKF.ArchVile.VILEP5'
     WalkTextures(0)=Texture'DoomPawnsKF.ArchVile.VILEA1D1'
     WalkTextures(4)=Texture'DoomPawnsKF.ArchVile.VILEA5D5'
     WalkTextures(5)=Texture'DoomPawnsKF.ArchVile.VILEA4D6'
     WalkTextures(6)=Texture'DoomPawnsKF.ArchVile.VILEA3D7'
     WalkTextures(7)=Texture'DoomPawnsKF.ArchVile.VILEA2D8'
     ShootTextures(0)=Texture'DoomPawnsKF.ArchVile.VI1'
     ShootTextures(4)=Texture'DoomPawnsKF.ArchVile.VI5'
     ShootTextures(5)=Texture'DoomPawnsKF.ArchVile.VI4'
     ShootTextures(6)=Texture'DoomPawnsKF.ArchVile.VI3'
     ShootTextures(7)=Texture'DoomPawnsKF.ArchVile.VI2'
     DieTexture=Texture'DoomPawnsKF.ArchVile.VILER0'
     DeadEndTexture=Texture'DoomPawnsKF.ArchVile.VILEZ0'
     DeathSpeed=2.000000
     DieSizeChange=-1.500000
     PawnHealth=700
     Acquire2=Sound'DoomPawnsKF.ArchVile.DSVILSIT'
     Die2=Sound'DoomPawnsKF.ArchVile.DSVILDTH'
     Roam=Sound'DoomPawnsKF.ArchVile.DSVILACT'
     Die=Sound'DoomPawnsKF.ArchVile.DSVILDTH'
     Acquire=Sound'DoomPawnsKF.ArchVile.DSVILSIT'
     Fear=Sound'DoomPawnsKF.ArchVile.DSVILACT'
     Threaten=Sound'DoomPawnsKF.ArchVile.DSVILSIT'
     HitSound1=Sound'DoomPawnsKF.ArchVile.DSVIPAIN'
     HitSound2=Sound'DoomPawnsKF.ArchVile.DSVIPAIN'
     bHasRangedAttack=True
     bArchCanRes=False
     ScoringValue=200
     GroundSpeed=400.000000
     AccelRate=2000.000000
     JumpZ=450.000000
     BaseEyeHeight=24.000000
     Health=700
     MenuName="Arch-Vile"
     ControllerClass=Class'DoomPawnsKF.ArchController'
     Texture=Texture'DoomPawnsKF.ArchVile.VI1'
     DrawScale=0.700000
     TransientSoundRadius=1700.000000
     CollisionRadius=30.000000
     CollisionHeight=56.000000
     Mass=300.000000
     Buoyancy=300.000000
}
