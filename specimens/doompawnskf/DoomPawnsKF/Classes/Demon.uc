//======================================================================
// Demon bites you hard.
//======================================================================
class Demon extends DoomPawns;

#exec obj load file=DemonS.uax package=DoomPawnsKF
#exec obj load file=DemonT.utx package=DoomPawnsKF

var() texture BiteAnims1[5],BiteAnims2[5],BiteAnims3[5];

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
		if( MyAnimName!='Eat' )
			CallTimer(0.5,False);
		PlaySound(Sound'DSSGTATK');
		AnimChange = 2;
		NotifyAnimation(2);
		Return 0.7;
	}
}
function TimedReply()
{
	MeleeDamageTarget(GetFromRange(DeMeleeDamage), vect(0,0,0));
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
		if( FrameNum==0 || FrameNum==1 )
			UpdateSkin(BiteAnims1[MyRot]);
		else if( FrameNum==2 )
			UpdateSkin(BiteAnims2[MyRot]);
		else UpdateSkin(BiteAnims3[MyRot]);
	}
}
simulated function NotifyAnimation( byte AnimNum )
{
	if( AnimNum==2 )
		Render.SetAnimatedTime(0.7,4);
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
     BiteAnims1(0)=Texture'DoomPawnsKF.Demon.SARGE1'
     BiteAnims1(1)=Texture'DoomPawnsKF.Demon.SARGE2'
     BiteAnims1(2)=Texture'DoomPawnsKF.Demon.SARGE3'
     BiteAnims1(3)=Texture'DoomPawnsKF.Demon.SARGE4'
     BiteAnims1(4)=Texture'DoomPawnsKF.Demon.SARGE5'
     BiteAnims2(0)=Texture'DoomPawnsKF.Demon.SARGF1'
     BiteAnims2(1)=Texture'DoomPawnsKF.Demon.SARGF2'
     BiteAnims2(2)=Texture'DoomPawnsKF.Demon.SARGF3'
     BiteAnims2(3)=Texture'DoomPawnsKF.Demon.SARGF4'
     BiteAnims2(4)=Texture'DoomPawnsKF.Demon.SARGF5'
     BiteAnims3(0)=Texture'DoomPawnsKF.Demon.SARGG1'
     BiteAnims3(1)=Texture'DoomPawnsKF.Demon.SARGG2'
     BiteAnims3(2)=Texture'DoomPawnsKF.Demon.SARGG3'
     BiteAnims3(3)=Texture'DoomPawnsKF.Demon.SARGG4'
     BiteAnims3(4)=Texture'DoomPawnsKF.Demon.SARGG5'
     WalkTextures(0)=Texture'DoomPawnsKF.Demon.SARGA1'
     WalkTextures(4)=Texture'DoomPawnsKF.Demon.SARGA5'
     WalkTextures(5)=Texture'DoomPawnsKF.Demon.SARGA4A6'
     WalkTextures(6)=Texture'DoomPawnsKF.Demon.SARGA3A7'
     WalkTextures(7)=Texture'DoomPawnsKF.Demon.SARGA2A8'
     ShootTextures(0)=Texture'DoomPawnsKF.Demon.SARGE1'
     ShootTextures(4)=Texture'DoomPawnsKF.Demon.SARGE5'
     ShootTextures(5)=Texture'DoomPawnsKF.Demon.SARGE4'
     ShootTextures(6)=Texture'DoomPawnsKF.Demon.SARGE3'
     ShootTextures(7)=Texture'DoomPawnsKF.Demon.SARGE2'
     DieTexture=Texture'DoomPawnsKF.Demon.SARGI0'
     DeadEndTexture=Texture'DoomPawnsKF.Demon.SARGN0'
     MeleeDamageType=Class'DoomPawnsKF.DemonAte'
     PawnHealth=150
     Acquire2=Sound'DoomPawnsKF.Demon.DSSGTSIT'
     Die2=Sound'DoomPawnsKF.Demon.DSSGTDTH'
     Roam=Sound'DoomPawnsKF.Demon.DSDMACT'
     Die=Sound'DoomPawnsKF.Demon.DSSGTDTH'
     Acquire=Sound'DoomPawnsKF.Demon.DSSGTSIT'
     Fear=Sound'DoomPawnsKF.Demon.DSDMACT'
     Threaten=Sound'DoomPawnsKF.Demon.DSSGTSIT'
     HitSound1=Sound'DoomPawnsKF.Imp.DSDMPAIN'
     HitSound2=Sound'DoomPawnsKF.Imp.DSDMPAIN'
     DeMeleeDamage=(Min=4,Max=40)
     bHasMelee=True
     ScoringValue=16
     MeleeRange=40.000000
     GroundSpeed=300.000000
     AccelRate=2000.000000
     BaseEyeHeight=24.000000
     MenuName="Pinky"
     Texture=Texture'DoomPawnsKF.Demon.SARGA1'
     CollisionRadius=24.000000
     CollisionHeight=40.000000
     Buoyancy=99.000000
}
