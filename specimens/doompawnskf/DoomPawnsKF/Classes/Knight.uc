//======================================================================
// Hell Knight... Easier version of the red one...
//======================================================================
class Knight extends DoomPawns;

#exec obj load file=HellKnightS.uax package=DoomPawnsKF
#exec obj load file=HellKnight.utx package=DoomPawnsKF

var() texture FireAnims1[5],FireAnims2[5],FireAnims3[5],FireAnims4[5];
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
		CallTimer(0.5,False);
		if( MyAnimName=='Melee' )
		{
			PlaySound(Sound'DSCLAW');
			bMelee = True;
		}
		else bMelee = False;
		AnimChange = 2;
		NotifyAnimation(2);
		Return 0.9;
	}
}
function TimedReply()
{
	if( bMelee )
		MeleeDamageTarget(GetFromRange(DeMeleeDamage), vect(0,0,0));
	else
	{
		PlaySound(FireSound);
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
		else if( FrameNum==2 )
			UpdateSkin(FireAnims3[MyRot]);
		else UpdateSkin(FireAnims4[MyRot]);
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

defaultproperties
{
     FireAnims1(0)=Texture'DoomPawnsKF.HellKnight.BOS2E1'
     FireAnims1(1)=Texture'DoomPawnsKF.HellKnight.BOS2E2'
     FireAnims1(2)=Texture'DoomPawnsKF.HellKnight.BOS2E3'
     FireAnims1(3)=Texture'DoomPawnsKF.HellKnight.BOS2E4'
     FireAnims1(4)=Texture'DoomPawnsKF.HellKnight.BOS2E5'
     FireAnims2(0)=Texture'DoomPawnsKF.HellKnight.BOS2F1'
     FireAnims2(1)=Texture'DoomPawnsKF.HellKnight.BOS2F2'
     FireAnims2(2)=Texture'DoomPawnsKF.HellKnight.BOS2F3'
     FireAnims2(3)=Texture'DoomPawnsKF.HellKnight.BOS2F4'
     FireAnims2(4)=Texture'DoomPawnsKF.HellKnight.BOS2F5'
     FireAnims3(0)=Texture'DoomPawnsKF.HellKnight.BOS2G1'
     FireAnims3(1)=Texture'DoomPawnsKF.HellKnight.BOS2G2'
     FireAnims3(2)=Texture'DoomPawnsKF.HellKnight.BOS2G3'
     FireAnims3(3)=Texture'DoomPawnsKF.HellKnight.BOS2G4'
     FireAnims3(4)=Texture'DoomPawnsKF.HellKnight.BOS2G5'
     FireAnims4(0)=Texture'DoomPawnsKF.HellKnight.BOS2H1'
     FireAnims4(1)=Texture'DoomPawnsKF.HellKnight.BOS2H2'
     FireAnims4(2)=Texture'DoomPawnsKF.HellKnight.BOS2H3'
     FireAnims4(3)=Texture'DoomPawnsKF.HellKnight.BOS2H4'
     FireAnims4(4)=Texture'DoomPawnsKF.HellKnight.BOS2H5'
     RenderingClass=Class'DoomPawnsKF.TallModel'
     WalkTextures(0)=Texture'DoomPawnsKF.HellKnight.BOS2A1C1'
     WalkTextures(4)=Texture'DoomPawnsKF.HellKnight.BOS2A5C5'
     WalkTextures(5)=Texture'DoomPawnsKF.HellKnight.BOS2A4C6'
     WalkTextures(6)=Texture'DoomPawnsKF.HellKnight.BOS2A3C7'
     WalkTextures(7)=Texture'DoomPawnsKF.HellKnight.BOS2A2C8'
     ShootTextures(0)=Texture'DoomPawnsKF.HellKnight.BOS2B1D1'
     ShootTextures(4)=Texture'DoomPawnsKF.HellKnight.BOS2B5D5'
     ShootTextures(5)=Texture'DoomPawnsKF.HellKnight.BOS2B4D6'
     ShootTextures(6)=Texture'DoomPawnsKF.HellKnight.BOS2B3D7'
     ShootTextures(7)=Texture'DoomPawnsKF.HellKnight.BOS2B2D8'
     DieTexture=Texture'DoomPawnsKF.HellKnight.BOS2I0'
     DeadEndTexture=Texture'DoomPawnsKF.HellKnight.BOS2N0'
     RangedProjectile=Class'DoomPawnsKF.HellFlameBall'
     PawnHealth=500
     Acquire2=Sound'DoomPawnsKF.HellsKnight.DSKNTSIT'
     Die2=Sound'DoomPawnsKF.HellsKnight.DSKNTDTH'
     Roam=Sound'DoomPawnsKF.Demon.DSDMACT'
     Die=Sound'DoomPawnsKF.HellsKnight.DSKNTDTH'
     Acquire=Sound'DoomPawnsKF.HellsKnight.DSKNTSIT'
     Fear=Sound'DoomPawnsKF.Demon.DSDMACT'
     Threaten=Sound'DoomPawnsKF.HellsKnight.DSKNTSIT'
     HitSound1=Sound'DoomPawnsKF.Imp.DSDMPAIN'
     HitSound2=Sound'DoomPawnsKF.Imp.DSDMPAIN'
     DeMeleeDamage=(Min=10,Max=80)
     bHasMelee=True
     bHasRangedAttack=True
     FireSound=Sound'DoomPawnsKF.Imp.DSFIRSHT'
     ScoringValue=20
     MeleeRange=45.000000
     GroundSpeed=200.000000
     BaseEyeHeight=34.000000
     Health=500
     MenuName="Hell Knight"
     Texture=Texture'DoomPawnsKF.HellKnight.BOS2B1D1'
     DrawScale=0.450000
     CollisionRadius=35.000000
     CollisionHeight=60.000000
     Mass=700.000000
     Buoyancy=700.000000
}
