//======================================================================
// Spider MasterMind, the boss.
//======================================================================
class SpiderMM extends Spider;

#exec obj load file=SpiderMMT.utx package=DoomPawnsKF
#exec obj load file=SpiderMMS.uax package=DoomPawnsKF
#exec AUDIO IMPORT FILE="Sounds\DSMETAL.wav" NAME="DSMETAL" GROUP="SpiderMM"

function TimedReply()
{
	if( bFootsteps )
	{
		PlaySound(Sound'DSMETAL',,,,1000);
		Return;
	}
	PlaySound(Sound'BobChaingun',,,,1000);
	FirePistol(vect(1,0,0),400);
	FirePistol(vect(1,0,0),400);
}
function float PlayMyAnim( name MyAnimName )
{
	if( MyAnimName=='Walk' || MyAnimName=='Fall' )
	{
		if( !bFootsteps )
		{
			bFootsteps = True;
			CallTimer(0.4,True);
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
		Return 0.15;
	}
}
function bool SameSpeciesAs(Pawn P)
{
	return False;
}

defaultproperties
{
     FireAnim(0)=Texture'DoomPawnsKF.SpiderMM.SPIDG1'
     FireAnim(1)=Texture'DoomPawnsKF.SpiderMM.SPIDG2G8'
     FireAnim(2)=Texture'DoomPawnsKF.SpiderMM.SPIDG3G7'
     FireAnim(3)=Texture'DoomPawnsKF.SpiderMM.SPIDG4G6'
     FireAnim(4)=Texture'DoomPawnsKF.SpiderMM.SPIDG5'
     WalkTextures(0)=Texture'DoomPawnsKF.SpiderMM.SPIDA1D1'
     WalkTextures(4)=Texture'DoomPawnsKF.SpiderMM.SPIDA5D5'
     WalkTextures(5)=Texture'DoomPawnsKF.SpiderMM.SPIDA4A6'
     WalkTextures(6)=Texture'DoomPawnsKF.SpiderMM.SPIDA3A7'
     WalkTextures(7)=Texture'DoomPawnsKF.SpiderMM.SPIDA2A8'
     ShootTextures(0)=Texture'DoomPawnsKF.SpiderMM.SPIDC1F1'
     ShootTextures(4)=Texture'DoomPawnsKF.SpiderMM.SPIDC5F5'
     ShootTextures(5)=Texture'DoomPawnsKF.SpiderMM.SPIDF4F6'
     ShootTextures(6)=Texture'DoomPawnsKF.SpiderMM.SPIDF3F7'
     ShootTextures(7)=Texture'DoomPawnsKF.SpiderMM.SPIDF2F8'
     DieTexture=Texture'DoomPawnsKF.SpiderMM.SPIDJ0'
     DeadEndTexture=Texture'DoomPawnsKF.SpiderMM.SPIDS0'
     DeathSpeed=2.500000
     PawnHealth=3000
     Acquire2=Sound'DoomPawnsKF.SpiderMM.DSSPISIT'
     Die2=Sound'DoomPawnsKF.SpiderMM.DSSPIDTH'
     Die=Sound'DoomPawnsKF.SpiderMM.DSSPIDTH'
     Acquire=Sound'DoomPawnsKF.SpiderMM.DSSPISIT'
     Threaten=Sound'DoomPawnsKF.SpiderMM.DSSPISIT'
     bHasMelee=False
     bArchCanRes=False
     bCanPreformFF=True
     hitdamage=(Min=3,Max=10)
     ShotDamageType=Class'DoomPawnsKF.MasterMindDmg'
     bBoss=True
     ScoringValue=800
     GroundSpeed=450.000000
     Health=3000
     MenuName="Spider MasterMind"
     LightHue=42
     LightSaturation=72
     LightBrightness=250.000000
     LightRadius=6.000000
     bDynamicLight=True
     Texture=Texture'DoomPawnsKF.SpiderMM.SPIDA1D1'
     DrawScale=0.900000
     TransientSoundRadius=80000.000000
     CollisionRadius=120.000000
     CollisionHeight=72.000000
}
