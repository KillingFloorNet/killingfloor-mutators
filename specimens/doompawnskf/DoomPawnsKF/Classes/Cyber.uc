//======================================================================
// Cyberdemon... the biggest enemy you encounter.
//======================================================================
class Cyber extends DoomPawns;

#exec obj load file=Cyberg.utx package=DoomPawnsKF
#exec obj load file=CybergS.uax package=DoomPawnsKF

var() texture FireAnims1[8],FireAnims2[8];
var(Sounds) sound Step;

function bool MakeGrandEntry()
{
	PlayAcquisitionSound();
	return True;
}
function float PlayMyAnim( name MyAnimName )
{
	if( MyAnimName=='Walk' || MyAnimName=='Fall' )
	{
		AnimChange = 0;
		NotifyAnimation(0);
		SetTimer(1,True);
		Return 0;
	}
	else if( MyAnimName=='Still' )
	{
		AnimChange = 1;
		NotifyAnimation(1);
		SetTimer(0,False);
		Return 0.5;
	}
	else
	{
		SetTimer(0,False);
		CallTimer(0.3,False);
		AnimChange = 2;
		NotifyAnimation(2);
		Return 0.5;
	}
}
function Timer()
{
	PlaySound(Step, SLOT_Interact,,,1100);
}
function TimedReply()
{
	Controller.Target = Controller.Enemy;
	FireProj(vect(1,0,0));
}
simulated function UpdateAnimation( byte MyRot, optional int FrameNum )
{
	if( AnimChange==0 )
		UpdateSkin(WalkTextures[MyRot]);
	else if( AnimChange==1 )
		UpdateSkin(ShootTextures[MyRot]);
	else
	{
		if( FrameNum==0 || FrameNum==1 )
		{
			bForceUnlit = True;
			UpdateSkin(FireAnims1[MyRot]);
		}
		else UpdateSkin(FireAnims2[MyRot]);
	}
}
simulated function NotifyAnimation( byte AnimNum )
{
	if( AnimNum==2 )
		Render.SetAnimatedTime(0.8,3);
	else
	{
		Render.TimeLeft = 0;
		Render.LastCheckB = 9;
	}
}

defaultproperties
{
     FireAnims1(0)=Texture'DoomPawnsKF.Cybra.CYBRE1'
     FireAnims1(1)=Texture'DoomPawnsKF.Cybra.CYBRE8'
     FireAnims1(2)=Texture'DoomPawnsKF.Cybra.CYBRE7'
     FireAnims1(3)=Texture'DoomPawnsKF.Cybra.CYBRE6'
     FireAnims1(4)=Texture'DoomPawnsKF.Cybra.CYBRE5'
     FireAnims1(5)=Texture'DoomPawnsKF.Cybra.CYBRE4'
     FireAnims1(6)=Texture'DoomPawnsKF.Cybra.CYBRE3'
     FireAnims1(7)=Texture'DoomPawnsKF.Cybra.CYBRE2'
     FireAnims2(0)=Texture'DoomPawnsKF.Cybra.CYBRF1'
     FireAnims2(1)=Texture'DoomPawnsKF.Cybra.CYBRF8'
     FireAnims2(2)=Texture'DoomPawnsKF.Cybra.CYBRF7'
     FireAnims2(3)=Texture'DoomPawnsKF.Cybra.CYBRF6'
     FireAnims2(4)=Texture'DoomPawnsKF.Cybra.CYBRF5'
     FireAnims2(5)=Texture'DoomPawnsKF.Cybra.CYBRF4'
     FireAnims2(6)=Texture'DoomPawnsKF.Cybra.CYBRF3'
     FireAnims2(7)=Texture'DoomPawnsKF.Cybra.CYBRF2'
     Step=Sound'DoomPawnsKF.Cyborg.DSHOOF'
     WalkTextures(0)=Texture'DoomPawnsKF.Cybra.CYBRA1'
     WalkTextures(1)=Texture'DoomPawnsKF.Cybra.CYBRA8'
     WalkTextures(2)=Texture'DoomPawnsKF.Cybra.CYBRA7'
     WalkTextures(3)=Texture'DoomPawnsKF.Cybra.CYBRA6'
     WalkTextures(4)=Texture'DoomPawnsKF.Cybra.CYBRA5'
     WalkTextures(5)=Texture'DoomPawnsKF.Cybra.CYBRA4'
     WalkTextures(6)=Texture'DoomPawnsKF.Cybra.CYBRA3'
     WalkTextures(7)=Texture'DoomPawnsKF.Cybra.CYBRA2'
     ShootTextures(0)=Texture'DoomPawnsKF.Cybra.CYBRD1'
     ShootTextures(1)=Texture'DoomPawnsKF.Cybra.CYBRD8'
     ShootTextures(2)=Texture'DoomPawnsKF.Cybra.CYBRD7'
     ShootTextures(3)=Texture'DoomPawnsKF.Cybra.CYBRD6'
     ShootTextures(4)=Texture'DoomPawnsKF.Cybra.CYBRD5'
     ShootTextures(5)=Texture'DoomPawnsKF.Cybra.CYBRD4'
     ShootTextures(6)=Texture'DoomPawnsKF.Cybra.CYBRD3'
     ShootTextures(7)=Texture'DoomPawnsKF.Cybra.CYBRD2'
     DieTexture=Texture'DoomPawnsKF.Cybra.CYBRH0'
     DeadEndTexture=Texture'DoomPawnsKF.Cybra.CYBRP0'
     DeathSpeed=2.500000
     RangedProjectile=Class'DoomPawnsKF.DoomRocket'
     PawnHealth=4000
     Acquire2=Sound'DoomPawnsKF.Cyborg.DSCYBSIT'
     Die2=Sound'DoomPawnsKF.Cyborg.DSCYBDTH'
     Die=Sound'DoomPawnsKF.Cyborg.DSCYBDTH'
     Acquire=Sound'DoomPawnsKF.Cyborg.DSCYBSIT'
     Threaten=Sound'DoomPawnsKF.Cyborg.DSCYBSIT'
     NumFiresAtOnce=(Min=3,Max=5)
     bHasRangedAttack=True
     bArchCanRes=False
     ScoringValue=1000
     GroundSpeed=400.000000
     AccelRate=2000.000000
     JumpZ=30.000000
     BaseEyeHeight=50.000000
     Health=4000
     MenuName="Cyberdemon"
     Texture=Texture'DoomPawnsKF.Cybra.CYBRA1'
     DrawScale=1.000000
     TransientSoundRadius=80000.000000
     CollisionRadius=54.000000
     CollisionHeight=110.000000
     Mass=5000.000000
     Buoyancy=99.000000
}
