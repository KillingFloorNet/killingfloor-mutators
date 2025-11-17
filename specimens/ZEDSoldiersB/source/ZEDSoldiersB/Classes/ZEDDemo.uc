Class ZEDDemo extends ZEDSoldierBase;

function FireWeaponOnce()
{
	local vector Start;
	local rotator R;

	Controller.Target = Controller.Enemy;

	if ( !SavedFireProperties.bInitialized )
	{
		SavedFireProperties.AmmoClass = Class'LAWAmmo';
		SavedFireProperties.ProjectileClass = Class'LAWProj';
		SavedFireProperties.WarnTargetPct = 0.15;
		SavedFireProperties.MaxRange = 10000;
		SavedFireProperties.bTossed = False;
		SavedFireProperties.bTrySplash = True;
		SavedFireProperties.bLeadTarget = True;
		SavedFireProperties.bInstantHit = false;
		SavedFireProperties.bInitialized = true;
	}

	Start = GetFirePosStart();
	R = AdjustAim(SavedFireProperties,Start,AimingError);

	Spawn(Class'LAWProjDM',,,Start,R);

	if( GunAttachment!=None )
	{
		SetAnimAction(FireAnim);
		GunAttachment.NetUpdateTime = Level.TimeSeconds - 1;
		GunAttachment.FlashCount++;
		if( Level.NetMode!=NM_DedicatedServer )
			GunAttachment.ThirdPersonEffects();
	}

	PlaySound(WeaponFireSound,SLOT_Interact,TransientSoundVolume * 1.5,,TransientSoundRadius,(1.0 + FRand()*0.015f),false);
}
State FiringWeapon
{
	function BeginState()
	{
		SetTimer(WeaponFireTime*0.7f,false);
	}
	function Timer()
	{
		FireWeaponOnce();
		++ClipCount;
	}
}

defaultproperties
{
	WeaponFireSound=SoundGroup'KF_LAWSnd.LAW_Fire'
	WeaponReloadSound=Sound'KF_LAWSnd.LAW_Reload_076'
	WAttachClass=Class'KFMod.LAWAttachment'
	AmmoPerClip=1
	FireOffset=(X=0.900000,Y=0.300000,Z=0.700000)
	WeaponFireTime=3.500000
	FireAnim="LAWFire"
	WeaponReloadAnim="Reload1"
	OriginalGroundSpeed=100.000000 //160.000000
	GroundSpeed=100.000000
	IdleHeavyAnim="LawIdle"
	IdleRifleAnim="LawIdle"
	//HealthMax=600.000000
	//Health=600
	//HeadHealth=350.000000
	ScoringValue=45
	MenuName="Civil Demolition"
	IdleWeaponAnim="LawIdle"
	IdleRestAnim="LawIdle"
	Mesh=SkeletalMesh'KFSoldiers.Powers'
	Skins(0)=Texture'KFCharacters.PowersSkin'
}