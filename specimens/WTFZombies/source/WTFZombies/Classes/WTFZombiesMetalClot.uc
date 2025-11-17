class WTFZombiesMetalClot extends ZombieClot_Standard;

simulated function ZombieCrispUp()
{
	bAshen = true;
	bCrispified = true;

	SetBurningBehavior();

	if ( Level.NetMode == NM_DedicatedServer || class'GameInfo'.static.UseLowGore() )
	{
		Return;
	}

	// Metal Clot doesn't show skin changes from burns for right now
	/*
	Skins[0]=Texture 'PatchTex.Common.ZedBurnSkin';
	Skins[1]=Texture 'PatchTex.Common.ZedBurnSkin';
	Skins[2]=Texture 'PatchTex.Common.ZedBurnSkin';
	Skins[3]=Texture 'PatchTex.Common.ZedBurnSkin';
	*/
}

defaultproperties
{
	HeadHealth=20.000000
	GroundSpeed=50.000000
	WaterSpeed=50.000000
	HealthMax=3910.000000
	Health=3910
	MenuName="Metal Clot"
	Skins(0)=Texture'WTFZombies_T.IronClot'
}
