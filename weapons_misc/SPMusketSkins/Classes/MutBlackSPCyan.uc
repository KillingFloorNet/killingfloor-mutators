class MutBlackSPCyan extends Mutator;

simulated function PostBeginPlay()
{
	class'KFMod.SPSniperRifle'.default.Skinrefs[1]="SPMusketSkins.Black_cmb";
	class'KFMod.SPSniperRifle'.default.Skins[1]=Combiner'SPMusketSkins.Black_cmb';
	class'KFMod.SPSniperRifle'.default.Skinrefs[2]="SPMusketSkins.ReticleBlue_scope_shader";
	class'KFMod.SPSniperRifle'.default.Skins[2]=Shader'SPMusketSkins.ReticleBlue_scope_shader';
}

defaultproperties
{
     bAddToServerPackages=True
     GroupName="KF-SPMusketSwitch"
     FriendlyName="SP Musket (black+cyan)"
     Description="This mutator changes the Single Piston Longmusket's body texture to a desaturated one, and the sight to the cyan German No. 4-ish reticle"
     bAlwaysRelevant=True
     RemoteRole=ROLE_SimulatedProxy
}
