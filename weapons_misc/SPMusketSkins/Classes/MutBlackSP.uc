class MutBlackSP extends Mutator;

#exec OBJ LOAD FILE=SPMusketSkins.utx Package=SPMusketSkins
#exec OBJ LOAD FILE=KF_IJC_Summer_Weapons.utx

simulated function PostBeginPlay()
{
	class'KFMod.SPSniperRifle'.default.Skinrefs[1]="SPMusketSkins.Black_cmb";
	class'KFMod.SPSniperRifle'.default.Skins[1]=Combiner'SPMusketSkins.Black_cmb';
	class'KFMod.SPSniperRifle'.default.Skinrefs[2]="SPMusketSkins.ReticleFixed_shader";
	class'KFMod.SPSniperRifle'.default.Skins[2]=Shader'SPMusketSkins.ReticleFixed_shader';
}

defaultproperties
{
     bAddToServerPackages=True
     GroupName="KF-SPMusketSwitch"
     FriendlyName="SP Musket (black)"
     Description="This mutator changes the Single Piston Longmusket's body texture to a desaturated one."
     bAlwaysRelevant=True
     RemoteRole=ROLE_SimulatedProxy
}
