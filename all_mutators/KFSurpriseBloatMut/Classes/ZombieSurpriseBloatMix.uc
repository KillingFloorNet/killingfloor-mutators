// Zombie Monster for KF Invasion gametype
class ZombieSurpriseBloatMix extends ZombieSurpriseBloat;

simulated function BeginPlay()
{
	//LinkSkelAnim(MeshAnimation'BloatSet');
	Super.BeginPlay();
}

defaultproperties
{
     Skins(0)=Texture'KFCharacters.PoundSkin'
     Skins(1)=Shader'KFCharacters.PoundBitsShader'
     Skins(2)=FinalBlend'KFCharacters.YellowPoundMeter'
     Skins(3)=Shader'KFCharacters.FPAmberBloomShader'
}
