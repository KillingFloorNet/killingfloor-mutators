//======================================================================
// Mancub.. 1 of most common enemy in Doom2 and so on...
//======================================================================
class Mancub extends DoomPawns;

#exec obj load file=Manc.utx package=DoomPawnsKF
#exec obj load file=MancS.uax package=DoomPawnsKF

var() texture FireAnims1[5],FireAnims2[5];
var int FireNum;
var rotator MyAiming;
var bool bOldDir;

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
		CallTimer(0.4,True);
		PlaySound(Sound'DSMANATK');
		AnimChange = 2;
		NotifyAnimation(2);
		FireNum = 0;
		Return 1.5;
	}
}
function TimedReply()
{
	bOldDir = !bOldDir;
	FireNum++;
	if( Controller!=None && Controller.Target!=None )
	{
		MyAiming = rotator(Controller.Target.Location-Location);
		MyAiming.Pitch = 0;
		SetRotation(MyAiming);
	}
	MyAiming = rot(0,0,0);
	if( FRand()<0.5 )
	{
		FireProj(vect(1,0.2,0));
		if( FireNum==1 )
			FireNum = 2;
		MyAiming = rot(0,0,0);
		if( bOldDir )
			MyAiming.Yaw = 3000;
		else MyAiming.Yaw = 3000;
		FireProj(vect(1,-0.2,0));
		PlaySound(Sound'DSFIRSHT', SLOT_None,4.2);
	}
	else
	{
		FireProj(vect(1,-0.2,0));
		if( FireNum==1 )
			FireNum = 2;
		MyAiming = rot(0,0,0);
		if( bOldDir )
			MyAiming.Yaw = 1500;
		else MyAiming.Yaw = 1500;
		FireProj(vect(1,0.2,0));
		PlaySound(Sound'DSFIRSHT', SLOT_None,4.2);
	}
	if( FireNum==4 )
		StopTimer();
}
function projectile FireProj( vector StartOffset )
{
	local vector X,Y,Z, projStart;
	local Projectile P;

	if( RangedProjectile==None || Level.NetMode==NM_Client ) Return None;
	MakeNoise(1.0);
	GetAxes(Rotation,X,Y,Z);
	projStart = Location + StartOffset.X * CollisionRadius * X + StartOffset.Y * CollisionRadius * Y + StartOffset.Z * CollisionRadius * Z;
	if ( !SavedFireProperties.bInitialized )
	{
		SavedFireProperties.AmmoClass = Class'SkaarjAmmo'; // Dosent really matter (just to avoid warnings or errors)!
		SavedFireProperties.ProjectileClass = RangedProjectile;
		SavedFireProperties.WarnTargetPct = 0.25;
		if( RangedProjectile.Default.LifeSpan==0 )
			SavedFireProperties.MaxRange = 10000;
		else SavedFireProperties.MaxRange = RangedProjectile.Default.LifeSpan*RangedProjectile.Default.Speed;
		SavedFireProperties.bTossed = False;
		SavedFireProperties.bTrySplash = False;
		SavedFireProperties.bLeadTarget = false;
		SavedFireProperties.bInstantHit = False;
		SavedFireProperties.bInitialized = true;
	}
	MyAiming = Controller.AdjustAim(SavedFireProperties,projStart,200)+MyAiming;
	P = Spawn(RangedProjectile,,,projStart,MyAiming);
	Return P;
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
		if( MyRot==7 )
			MyRot = 1;
		else if( MyRot==6 )
			MyRot = 2;
		else if( MyRot==5 )
			MyRot = 3;
		if( FrameNum==0 || FrameNum==2 || FrameNum==4 )
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
		Render.SetAnimatedTime(1.5,6);
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
     FireAnims1(0)=Texture'DoomPawnsKF.Mancub.FATTG1'
     FireAnims1(1)=Texture'DoomPawnsKF.Mancub.FATTG2G8'
     FireAnims1(2)=Texture'DoomPawnsKF.Mancub.FATTG3G7'
     FireAnims1(3)=Texture'DoomPawnsKF.Mancub.FATTG4G6'
     FireAnims1(4)=Texture'DoomPawnsKF.Mancub.FATTG5'
     FireAnims2(0)=Texture'DoomPawnsKF.Mancub.FATTH1'
     FireAnims2(1)=Texture'DoomPawnsKF.Mancub.FATTH2H8'
     FireAnims2(2)=Texture'DoomPawnsKF.Mancub.FATTH3H7'
     FireAnims2(3)=Texture'DoomPawnsKF.Mancub.FATTH4H6'
     FireAnims2(4)=Texture'DoomPawnsKF.Mancub.FATTH5'
     WalkTextures(0)=Texture'DoomPawnsKF.Mancub.FATTA1'
     WalkTextures(4)=Texture'DoomPawnsKF.Mancub.FATTA5'
     WalkTextures(5)=Texture'DoomPawnsKF.Mancub.FATTA4A6'
     WalkTextures(6)=Texture'DoomPawnsKF.Mancub.FATTA3A7'
     WalkTextures(7)=Texture'DoomPawnsKF.Mancub.FATTA2A8'
     ShootTextures(0)=Texture'DoomPawnsKF.Mancub.FATTG1'
     ShootTextures(4)=Texture'DoomPawnsKF.Mancub.FATTG5'
     ShootTextures(5)=Texture'DoomPawnsKF.Mancub.FATTG4G6'
     ShootTextures(6)=Texture'DoomPawnsKF.Mancub.FATTG3G7'
     ShootTextures(7)=Texture'DoomPawnsKF.Mancub.FATTG2G8'
     DieTexture=Texture'DoomPawnsKF.Mancub.FATTK0'
     DeadEndTexture=Texture'DoomPawnsKF.Mancub.FATTT0'
     DeathSpeed=1.000000
     RangedProjectile=Class'DoomPawnsKF.MancubRocket'
     PawnHealth=600
     Acquire2=Sound'DoomPawnsKF.Mancub.DSMANSIT'
     Die2=Sound'DoomPawnsKF.Mancub.DSMANDTH'
     Roam=Sound'DoomPawnsKF.Imp.DSBGACT'
     Die=Sound'DoomPawnsKF.Mancub.DSMANDTH'
     Acquire=Sound'DoomPawnsKF.Mancub.DSMANSIT'
     Fear=Sound'DoomPawnsKF.Imp.DSBGACT'
     Threaten=Sound'DoomPawnsKF.Mancub.DSMANSIT'
     HitSound1=Sound'DoomPawnsKF.Mancub.DSMNPAIN'
     bHasRangedAttack=True
     ScoringValue=40
     MeleeRange=45.000000
     GroundSpeed=130.000000
     JumpZ=100.000000
     BaseEyeHeight=34.000000
     Health=600
     MenuName="Mancubus"
     Texture=Texture'DoomPawnsKF.Mancub.FATTA1'
     DrawScale=0.975000
     CollisionRadius=70.000000
     CollisionHeight=50.000000
     Mass=1000.000000
     Buoyancy=800.000000
}
