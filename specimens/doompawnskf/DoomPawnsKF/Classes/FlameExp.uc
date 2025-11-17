//=============================================================================
// FlameExp.
//=============================================================================
class FlameExp extends Effects;

var() sound EffectSound1;
var int CurAnimFrame,TotalLen;
var array<Texture> ExpAnimation;
var() Texture ExploAnim;

simulated Function Timer()
{
	CurAnimFrame++;
	if( CurAnimFrame>=TotalLen )
		Return;
	Texture = ExpAnimation[CurAnimFrame];
}
simulated function PostBeginPlay()
{
	if( Level.NetMode==NM_DedicatedServer )
		return;
	ExpAnimation = Class'DRendering'.Static.GetAnimation(ExploAnim);
	TotalLen = ExpAnimation.Length;
	PlaySound(EffectSound1);
	SetTimer(LifeSpan/TotalLen,True);
	Texture = ExpAnimation[0];
}

defaultproperties
{
     EffectSound1=Sound'DoomPawnsKF.Imp.DSFIRXPL'
     ExploAnim=Texture'DoomPawnsKF.Imp.BAL1C0'
     LightHue=5
     LightSaturation=63
     LifeSpan=0.800000
     DrawScale=1.800000
     TransientSoundVolume=1.500000
     TransientSoundRadius=400.000000
}
