Class ZEDCommando extends ZEDSoldierBase;

defaultproperties
{
	WeaponFireSound=SoundGroup'KF_SCARSnd.SCAR_Fire'
	WeaponReloadSound=Sound'KF_SCARSnd.SCAR_Reload_014'
	WAttachClass=Class'KFMod.SCARMK17Attachment'
	AmmoPerClip=15
	WeaponHitDamage(0)=3 //5
	WeaponHitDamage(1)=2 //5
	WeaponFireRate=0.096000
	WeaponMissRate=0.045000
	WeaponFireTime=1.500000
	OriginalGroundSpeed=110.000000 //350.000000
	GroundSpeed=110.000000
	HealthMax=350.000000 //500.000000
	Health=350 //500
	HeadHealth=325.000000 //450.000000
	ScoringValue=30
	MenuName="Civil Commando"
	Mesh=SkeletalMesh'KFSoldiers.Masterson'
	Skins(0)=Texture'KFCharacters.Masterson'
}