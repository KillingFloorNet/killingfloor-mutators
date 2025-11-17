//======================================================================
// Wolfenstein Schutzstaffel.
//======================================================================
class WolfSS extends HeavyTrooper;

#exec obj load file=WolfS.uax package=DoomPawnsKF
#exec obj load file=WolfT.utx package=DoomPawnsKF

defaultproperties
{
     FiringTextures(0)=Texture'DoomPawnsKF.Wolfie.SSWVF0'
     FiringTextures(1)=Texture'DoomPawnsKF.Wolfie.SSWVD2'
     FiringTextures(2)=Texture'DoomPawnsKF.Wolfie.SSWVD3'
     FiringTextures(3)=Texture'DoomPawnsKF.Wolfie.SSWVD4'
     FiringTextures(4)=Texture'DoomPawnsKF.Wolfie.SSWVD5'
     WalkTextures(0)=Texture'DoomPawnsKF.Wolfie.SSWVA1'
     WalkTextures(4)=Texture'DoomPawnsKF.Wolfie.SSWVA5'
     WalkTextures(5)=Texture'DoomPawnsKF.Wolfie.SSWVA4'
     WalkTextures(6)=Texture'DoomPawnsKF.Wolfie.SSWVA3'
     WalkTextures(7)=Texture'DoomPawnsKF.Wolfie.SSWVA2'
     ShootTextures(0)=Texture'DoomPawnsKF.Wolfie.SSWVE0'
     ShootTextures(4)=Texture'DoomPawnsKF.Wolfie.SSWVD5'
     ShootTextures(5)=Texture'DoomPawnsKF.Wolfie.SSWVD4'
     ShootTextures(6)=Texture'DoomPawnsKF.Wolfie.SSWVD3'
     ShootTextures(7)=Texture'DoomPawnsKF.Wolfie.SSWVD2'
     DieTexture=Texture'DoomPawnsKF.Wolfie.SSWVJ0'
     DeadEndTexture=Texture'DoomPawnsKF.Wolfie.SSWVM0'
     DeathSpeed=0.700000
     DropWhenKilled=None
     PawnHealth=85
     Acquire2=Sound'DoomPawnsKF.Wolfie.DSSSSIT'
     Die2=Sound'DoomPawnsKF.Wolfie.DSSSDTH'
     Die=Sound'DoomPawnsKF.Wolfie.DSSSDTH'
     Acquire=Sound'DoomPawnsKF.Wolfie.DSSSSIT'
     Threaten=Sound'DoomPawnsKF.Wolfie.DSSSSIT'
     HitSound1=None
     HitSound2=None
     RefireSpeed=0.200000
     ShotDamageType=Class'DoomPawnsKF.NaziDmg'
     ScoringValue=14
     GroundSpeed=110.000000
     Health=85
     MenuName="Nazi"
     Texture=Texture'DoomPawnsKF.Wolfie.SSWVA1'
}
