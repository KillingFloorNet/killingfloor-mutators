class MutChromeSPCyan extends Mutator;

simulated function PostBeginPlay()
{
	class'KFMod.SPSniperRifle'.default.Skinrefs[1]="SPMusketSkins.Chrome_cmb";
	class'KFMod.SPSniperRifle'.default.Skins[1]=Combiner'SPMusketSkins.Chrome_cmb';
	class'KFMod.SPSniperRifle'.default.Skinrefs[2]="SPMusketSkins.ReticleBlue_scope_shader";
	class'KFMod.SPSniperRifle'.default.Skins[2]=Shader'SPMusketSkins.ReticleBlue_scope_shader';
}

defaultproperties
{
     bAddToServerPackages=True
     GroupName="KF-SPMusketSwitch"
     FriendlyName="SP Musket (chrome+cyan)"
     Description="This mutator changes the Single Piston Longmusket's body texture to a chrome-covered one, and the sight to the cyan German No. 4-ish reticle"
     bAlwaysRelevant=True
     RemoteRole=ROLE_SimulatedProxy
}
