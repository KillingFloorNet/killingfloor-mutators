class WTFZombiesMetalClot extends ZombieClot_Standard;

/*
#exec OBJ LOAD FILE=PlayerSounds.uax
#exec OBJ LOAD FILE=KF_Freaks_Trip.ukx
#exec OBJ LOAD FILE=KF_Specimens_Trip_T.utx
*/

simulated function ZombieCrispUp()
{
	bAshen = true;
	bCrispified = true;
	SetBurningBehavior();
	if ( Level.NetMode == NM_DedicatedServer || class'GameInfo'.static.UseLowGore() )
	{
		return;
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
	Skins(0)=Texture'WTF_A.WTFZombies.IronClot'
}
