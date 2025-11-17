//======================================================================
// Revenant.
//======================================================================
class Skeleton extends DoomPawns;

#exec obj load file=SkelS.uax package=DoomPawnsKF
#exec obj load file=Skel.utx package=DoomPawnsKF

var() texture FireAnims1[5],FireAnims2[5],FireAnims3[5],FireAnims4[5],FireAnims5[5];
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
		if( MyAnimName=='Melee' )
		{
			PlaySound(Sound'DSSKESWG');
			bMelee = True;
			AnimChange = 2;
			NotifyAnimation(2);
			CallTimer(0.3,False);
		}
		else
		{
			PlaySound(Sound'DSSKEATK');
			bMelee = False;
			AnimChange = 3;
			NotifyAnimation(3);
			CallTimer(0.6,False);
		}
		if( bMelee )
			Return 0.5;
		else Return 1;
	}
}
function TimedReply()
{
	if( bMelee )
	{
		if( MeleeDamageTarget(GetFromRange(DeMeleeDamage), vect(0,0,0)) )
			PlaySound(Sound'DSSKEPCH');
	}
	else
	{
		PlaySound(Sound'DSRLAUNC');
		FireProj(vect(1,0,0.7));
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
		if( MyRot==7 )
			MyRot = 1;
		else if( MyRot==6 )
			MyRot = 2;
		else if( MyRot==5 )
			MyRot = 3;
		if( FrameNum==0 )
		{
			bForceUnlit = !bMelee;
			UpdateSkin(FireAnims1[MyRot]);
		}
		else if( FrameNum==1 )
		{
			UpdateSkin(FireAnims2[MyRot]);
			bForceUnlit = !bMelee;
		}
		else if( FrameNum==2 )
			UpdateSkin(FireAnims3[MyRot]);
		else if( FrameNum==3 )
			UpdateSkin(FireAnims4[MyRot]);
		else UpdateSkin(FireAnims5[MyRot]);
	}
}
simulated function NotifyAnimation( byte AnimNum )
{
	bMelee = (AnimNum==2);
	if( AnimNum==2 )
		Render.SetAnimatedTime(0.6,2);
	else if( AnimNum==3 )
		Render.SetAnimatedTime(1,4);
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
     FireAnims1(0)=Texture'DoomPawnsKF.Skeleton.SKELG1'
     FireAnims1(1)=Texture'DoomPawnsKF.Skeleton.SKELG2'
     FireAnims1(2)=Texture'DoomPawnsKF.Skeleton.SKELG3'
     FireAnims1(3)=Texture'DoomPawnsKF.Skeleton.SKELG4'
     FireAnims1(4)=Texture'DoomPawnsKF.Skeleton.SKELG5'
     FireAnims2(0)=Texture'DoomPawnsKF.Skeleton.SKELH1'
     FireAnims2(1)=Texture'DoomPawnsKF.Skeleton.SKELH2'
     FireAnims2(2)=Texture'DoomPawnsKF.Skeleton.SKELH3'
     FireAnims2(3)=Texture'DoomPawnsKF.Skeleton.SKELH4'
     FireAnims2(4)=Texture'DoomPawnsKF.Skeleton.SKELH5'
     FireAnims3(0)=Texture'DoomPawnsKF.Skeleton.SKELI1'
     FireAnims3(1)=Texture'DoomPawnsKF.Skeleton.SKELI2'
     FireAnims3(2)=Texture'DoomPawnsKF.Skeleton.SKELI3'
     FireAnims3(3)=Texture'DoomPawnsKF.Skeleton.SKELI4'
     FireAnims3(4)=Texture'DoomPawnsKF.Skeleton.SKELI5'
     FireAnims4(0)=Texture'DoomPawnsKF.Skeleton.SKELJ1'
     FireAnims4(1)=Texture'DoomPawnsKF.Skeleton.SKELJ2'
     FireAnims4(2)=Texture'DoomPawnsKF.Skeleton.SKELJ3'
     FireAnims4(3)=Texture'DoomPawnsKF.Skeleton.SKELJ4'
     FireAnims4(4)=Texture'DoomPawnsKF.Skeleton.SKELJ5'
     FireAnims5(0)=Texture'DoomPawnsKF.Skeleton.SKELK1'
     FireAnims5(1)=Texture'DoomPawnsKF.Skeleton.SKELK2'
     FireAnims5(2)=Texture'DoomPawnsKF.Skeleton.SKELK3'
     FireAnims5(3)=Texture'DoomPawnsKF.Skeleton.SKELK4'
     FireAnims5(4)=Texture'DoomPawnsKF.Skeleton.SKELK5'
     WalkTextures(0)=Texture'DoomPawnsKF.Skeleton.SKELA1D1'
     WalkTextures(4)=Texture'DoomPawnsKF.Skeleton.SKELA5D5'
     WalkTextures(5)=Texture'DoomPawnsKF.Skeleton.SKELA4D6'
     WalkTextures(6)=Texture'DoomPawnsKF.Skeleton.SKELA3D7'
     WalkTextures(7)=Texture'DoomPawnsKF.Skeleton.SKELA2D8'
     ShootTextures(0)=Texture'DoomPawnsKF.Skeleton.SKELC1F1'
     ShootTextures(4)=Texture'DoomPawnsKF.Skeleton.SKELC5F5'
     ShootTextures(5)=Texture'DoomPawnsKF.Skeleton.SKELC4F6'
     ShootTextures(6)=Texture'DoomPawnsKF.Skeleton.SKELC3F7'
     ShootTextures(7)=Texture'DoomPawnsKF.Skeleton.SKELC2F8'
     DieTexture=Texture'DoomPawnsKF.Skeleton.SKELM0'
     DeadEndTexture=Texture'DoomPawnsKF.Skeleton.SKELQ0'
     DeathSpeed=1.000000
     RangedProjectile=Class'DoomPawnsKF.SkeleRocket'
     PawnHealth=300
     Acquire2=Sound'DoomPawnsKF.Skeleton.DSSKESIT'
     Roam=Sound'DoomPawnsKF.Skeleton.DSSKEACT'
     Die=Sound'DoomPawnsKF.Skeleton.DSSKEDTH'
     Acquire=Sound'DoomPawnsKF.Skeleton.DSSKESIT'
     Fear=Sound'DoomPawnsKF.Skeleton.DSSKEACT'
     Threaten=Sound'DoomPawnsKF.Skeleton.DSSKESIT'
     HitSound1=Sound'DoomPawnsKF.Imp.DSDMPAIN'
     HitSound2=Sound'DoomPawnsKF.Imp.DSDMPAIN'
     NumFiresAtOnce=(Min=3,Max=6)
     DeMeleeDamage=(Min=6,Max=60)
     bHasMelee=True
     bHasRangedAttack=True
     StartMeleeRange=600.000000
     ScoringValue=40
     MeleeRange=30.000000
     GroundSpeed=500.000000
     AccelRate=500.000000
     BaseEyeHeight=24.000000
     Health=300
     MenuName="Revenant"
     Texture=Texture'DoomPawnsKF.Skeleton.SKELA1D1'
     DrawScale=0.700000
     CollisionRadius=40.000000
     CollisionHeight=60.000000
     Buoyancy=99.000000
}
