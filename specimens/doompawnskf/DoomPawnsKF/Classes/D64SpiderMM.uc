//======================================================================
// Doom 64 Spider MasterMind.
//======================================================================
class D64SpiderMM extends SpiderMM;

function TimedReply()
{
	if( bFootsteps )
	{
		PlaySound(Sound'DSBSPWLK',,,,1000);
		Return;
	}
	Controller.Target = Controller.Enemy;
	PlaySound(Sound'DSDSHTGN64',,,,1000);
	FirePistol(vect(1,0,0),400);
	FirePistol(vect(1,0,0),400);
}

defaultproperties
{
     PawnHealth=8000
     Acquire2=Sound'DoomPawnsKF.D64Snd.DSSPISIT64'
     Die2=Sound'DoomPawnsKF.D64Snd.DSSPIDTH64'
     Die=Sound'DoomPawnsKF.D64Snd.DSSPIDTH64'
     Acquire=Sound'DoomPawnsKF.D64Snd.DSSPISIT64'
     Threaten=Sound'DoomPawnsKF.D64Snd.DSSPISIT64'
     hitdamage=(Min=10,Max=25)
     ScoringValue=27
     Health=8000
}
