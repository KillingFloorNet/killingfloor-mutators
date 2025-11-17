//=============================================================================
// BloodSplatEffect.
//=============================================================================
class BloodSplatEffect extends FlameExp;

#exec obj load file=ExtraFX.utx package=DoomPawnsKF

simulated function PostBeginPlay()
{
	LifeSpan = 1+FRand()*0.5;
	ExpAnimation = Class'DRendering'.Static.GetAnimation(ExploAnim);
	TotalLen = ExpAnimation.Length;
	SetTimer(0.2/TotalLen,True);
	Texture = ExpAnimation[0];
	Velocity = VRand()*30;
}

defaultproperties
{
     EffectSound1=None
     ExploAnim=Texture'DoomPawnsKF.Blood.BLUDA0'
     Physics=PHYS_Falling
     RemoteRole=ROLE_SimulatedProxy
     LifeSpan=0.300000
     DrawScale=1.350000
     bCollideWorld=True
}
