//======================================================================
// Player Marine
//======================================================================
class Marine extends DoomTroop;

#exec obj load file=MarineT.utx package=DoomPawnsKF
#exec obj load file=MarineS.uax package=DoomPawnsKF

var() texture FireTextures1[5],FireTextures2[5];
struct WeaponsType
{
	var() class<Projectile> Projectile;
	var() bool bShootProj;
	var() sound FireSound;
	var() int NumShots,MissingAmount;
	var() IntRange NumRapidShots,TraceHitDamage;
	var() float LoadingTime;
};
var() array<WeaponsType> MarineWeapon;
var() byte MyFireMode;
var int NumFiresLeft;
var Actor MegaNode;
var Pawn FollowingTarget;
var bool bHasAlerted;

function PreBeginPlay()
{
	Super.PreBeginPlay();
	if( bDeleteMe ) Return;
	// Initialize firemode.
	if( MyFireMode==255 )
		MyFireMode = Rand(MarineWeapon.Length);
	RangedProjectile = MarineWeapon[MyFireMode].Projectile;
	FireSound = MarineWeapon[MyFireMode].FireSound;
	HitDamage = MarineWeapon[MyFireMode].TraceHitDamage;
}
function int PickNumFires()
{
	Return GetFromRange(MarineWeapon[MyFireMode].NumRapidShots);
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
		if( MarineWeapon[MyFireMode].bShootProj )
		{
			For( i=MarineWeapon[MyFireMode].NumShots; i>0; i-- )
				FireProj(vect(1,0,0));
		}
		else
		{
			For( i=MarineWeapon[MyFireMode].NumShots; i>0; i-- )
				FirePistol(vect(1,0,0),MarineWeapon[MyFireMode].MissingAmount);
		}
		PlaySound(FireSound, SLOT_Misc, 2);
		AnimChange = 2;
		NotifyAnimation(2);
		Return MarineWeapon[MyFireMode].LoadingTime;
	}
}
simulated function SetFireAnim( byte MyRot, int FrameNum )
{
	if( MyRot==7 ) MyRot = 1;
	else if( MyRot==6 ) MyRot = 2;
	else if( MyRot==5 ) MyRot = 3;
	if( FrameNum==0 )
	{
		bForceUnlit = True;
		UpdateSkin(FireTextures1[MyRot]);
	}
	else UpdateSkin(FireTextures2[MyRot]);
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
     FireTextures1(0)=Texture'DoomPawnsKF.Marine.PLAYE1'
     FireTextures1(1)=Texture'DoomPawnsKF.Marine.PLAYE2E8'
     FireTextures1(2)=Texture'DoomPawnsKF.Marine.PLAYE3E7'
     FireTextures1(3)=Texture'DoomPawnsKF.Marine.PLAYE4E6'
     FireTextures1(4)=Texture'DoomPawnsKF.Marine.PLAYE5'
     FireTextures2(0)=Texture'DoomPawnsKF.Marine.PLAYF1'
     FireTextures2(1)=Texture'DoomPawnsKF.Marine.PLAYF2F8'
     FireTextures2(2)=Texture'DoomPawnsKF.Marine.PLAYF3F7'
     FireTextures2(3)=Texture'DoomPawnsKF.Marine.PLAYF4F6'
     FireTextures2(4)=Texture'DoomPawnsKF.Marine.PLAYF5'
     MarineWeapon(0)=(FireSound=Sound'DoomPawnsKF.Marine.DSPISTOL',NumShots=1,MissingAmount=100,NumRapidShots=(Min=3,Max=6),TraceHitDamage=(Min=10,Max=35),LoadingTime=0.400000)
     MarineWeapon(1)=(FireSound=Sound'DoomPawnsKF.ChaingunBob.BobChaingun',NumShots=7,MissingAmount=2000,NumRapidShots=(Min=2,Max=4),TraceHitDamage=(Min=5,Max=25),LoadingTime=1.500000)
     MarineWeapon(2)=(Projectile=Class'DoomPawnsKF.DoomRocket',bShootProj=True,NumShots=1,MissingAmount=500,NumRapidShots=(Min=1,Max=2),LoadingTime=0.800000)
     MyFireMode=255
     WalkTextures(0)=Texture'DoomPawnsKF.Marine.PLAYA1'
     WalkTextures(4)=Texture'DoomPawnsKF.Marine.PLAYA5'
     WalkTextures(5)=Texture'DoomPawnsKF.Marine.PLAYA4A6'
     WalkTextures(6)=Texture'DoomPawnsKF.Marine.PLAYA3A7'
     WalkTextures(7)=Texture'DoomPawnsKF.Marine.PLAYA2A8'
     ShootTextures(0)=Texture'DoomPawnsKF.Marine.PLAYE1'
     ShootTextures(4)=Texture'DoomPawnsKF.Marine.PLAYE5'
     ShootTextures(5)=Texture'DoomPawnsKF.Marine.PLAYE4E6'
     ShootTextures(6)=Texture'DoomPawnsKF.Marine.PLAYE3E7'
     ShootTextures(7)=Texture'DoomPawnsKF.Marine.PLAYE2E8'
     DieTexture=Texture'DoomPawnsKF.Marine.PLAYH0'
     DeadEndTexture=Texture'DoomPawnsKF.Marine.PLAYN0'
     DeathSpeed=1.000000
     PawnHealth=150
     Die2=Sound'DoomPawnsKF.Marine.DSPLDETH'
     Die=Sound'DoomPawnsKF.Marine.DSPDIEHI'
     bArchCanRes=False
     ScoringValue=-5
     MenuName="Marine"
     ControllerClass=Class'DoomPawnsKF.MarineController'
}
