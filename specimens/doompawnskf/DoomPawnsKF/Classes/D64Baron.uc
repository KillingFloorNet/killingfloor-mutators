//======================================================================
// Doom 64 Baron
//======================================================================
class D64Baron extends Baron;

#exec obj load file=Doom64.uax package=DoomPawnsKF

defaultproperties
{
     RangedProjectile=Class'DoomPawnsKF.D64HellFlameBall'
     PawnHealth=3800
     Acquire2=Sound'DoomPawnsKF.D64Snd.DSBRSSIT64'
     Die2=Sound'DoomPawnsKF.D64Snd.DSBRSDTH64'
     Die=Sound'DoomPawnsKF.D64Snd.DSBRSDTH64'
     Acquire=Sound'DoomPawnsKF.D64Snd.DSBRSSIT64'
     Threaten=Sound'DoomPawnsKF.D64Snd.DSBRSSIT64'
     FireSound=Sound'DoomPawnsKF.D64Snd.DSFIRSHT64'
     ScoringValue=13
     Health=3800
}
