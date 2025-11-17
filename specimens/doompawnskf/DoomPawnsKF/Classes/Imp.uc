//======================================================================
// Imp, brown ugly enemy. :P
//======================================================================
class Imp extends DoomPawns;

#exec obj load file=Imp.utx package=DoomPawnsKF
#exec obj load file=ImpSnds.uax package=DoomPawnsKF

var() texture FireAnims1[8],FireAnims2[8],FireAnims3[8];
var bool bMelee;

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
		CallTimer(0.3,False);
		if( MyAnimName=='Melee' )
		{
			PlaySound(Sound'DSCLAW');
			bMelee = True;
		}
		else bMelee = False;
		AnimChange = 2;
		NotifyAnimation(2);
		if( bMelee )
			Return 0.7;
		else Return 1.5;
	}
}
function TimedReply()
{
	if( bMelee )
		MeleeDamageTarget(GetFromRange(DeMeleeDamage), vect(0,0,0));
	else
	{
		PlaySound(Sound'DSFIRSHT');
		FireProj(vect(1,0,0));
	}
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
		Render.SetAnimatedTime(0.7,3);
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
     FireAnims1(0)=Texture'DoomPawnsKF.Imp.TROOE1'
     FireAnims1(4)=Texture'DoomPawnsKF.Imp.TROOE5'
     FireAnims1(5)=Texture'DoomPawnsKF.Imp.TROOE4'
     FireAnims1(6)=Texture'DoomPawnsKF.Imp.TROOE3'
     FireAnims1(7)=Texture'DoomPawnsKF.Imp.TROOE2'
     FireAnims2(0)=Texture'DoomPawnsKF.Imp.TROOF1'
     FireAnims2(4)=Texture'DoomPawnsKF.Imp.TROOF5'
     FireAnims2(5)=Texture'DoomPawnsKF.Imp.TROOF4'
     FireAnims2(6)=Texture'DoomPawnsKF.Imp.TROOF3'
     FireAnims2(7)=Texture'DoomPawnsKF.Imp.TROOF2'
     FireAnims3(0)=Texture'DoomPawnsKF.Imp.TROOG1'
     FireAnims3(4)=Texture'DoomPawnsKF.Imp.TROOG5'
     FireAnims3(5)=Texture'DoomPawnsKF.Imp.TROOG4'
     FireAnims3(6)=Texture'DoomPawnsKF.Imp.TROOG3'
     FireAnims3(7)=Texture'DoomPawnsKF.Imp.TROOG2'
     WalkTextures(0)=Texture'DoomPawnsKF.Imp.TROOA1'
     WalkTextures(4)=Texture'DoomPawnsKF.Imp.TROOA5'
     WalkTextures(5)=Texture'DoomPawnsKF.Imp.TROOA4'
     WalkTextures(6)=Texture'DoomPawnsKF.Imp.TROOA3'
     WalkTextures(7)=Texture'DoomPawnsKF.Imp.TROOA2'
     ShootTextures(0)=Texture'DoomPawnsKF.Imp.TROOD1'
     ShootTextures(4)=Texture'DoomPawnsKF.Imp.TROOD5'
     ShootTextures(5)=Texture'DoomPawnsKF.Imp.TROOD4'
     ShootTextures(6)=Texture'DoomPawnsKF.Imp.TROOD3'
     ShootTextures(7)=Texture'DoomPawnsKF.Imp.TROOD2'
     DieTexture=Texture'DoomPawnsKF.Imp.TROOI0'
     DeadEndTexture=Texture'DoomPawnsKF.Imp.TROOM0'
     DeathSpeed=0.800000
     RangedProjectile=Class'DoomPawnsKF.ImpFlameBall'
     PawnHealth=60
     Acquire2=Sound'DoomPawnsKF.Imp.DSBGSIT1'
     Die2=Sound'DoomPawnsKF.Imp.DSBGDTH1'
     Roam=Sound'DoomPawnsKF.Imp.DSBGACT'
     Die=Sound'DoomPawnsKF.Imp.DSBGDTH2'
     Acquire=Sound'DoomPawnsKF.Imp.DSBGSIT2'
     Fear=Sound'DoomPawnsKF.Imp.DSBGACT'
     Threaten=Sound'DoomPawnsKF.Imp.DSBGSIT2'
     HitSound1=Sound'DoomPawnsKF.Imp.DSDMPAIN'
     HitSound2=Sound'DoomPawnsKF.Imp.DSDMPAIN'
     NumFiresAtOnce=(Max=2)
     DeMeleeDamage=(Min=3,Max=24)
     bHasMelee=True
     bHasRangedAttack=True
     ScoringValue=7
     MeleeRange=30.000000
     GroundSpeed=120.000000
     BaseEyeHeight=24.000000
     Health=60
     MenuName="Imp"
     Texture=Texture'DoomPawnsKF.Imp.TROOA1'
     DrawScale=0.400000
     CollisionRadius=24.000000
     CollisionHeight=40.000000
     Buoyancy=99.000000
}
