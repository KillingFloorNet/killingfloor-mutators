Class ZEDFlamer extends ZEDSoldierBase;

// Only ready to attack once close enough.
function bool ReadyToFire( Pawn Enemy )
{
	return (VSizeSquared(Location-Enemy.Location)<1000000 && Super.ReadyToFire(Enemy));
}
function FireWeaponOnce()
{
	local vector Start;
	local rotator R;
	local Projectile P;

	Controller.Target = Controller.Enemy;

	if ( !SavedFireProperties.bInitialized )
	{
		SavedFireProperties.AmmoClass = Class'FlameAmmo';
		SavedFireProperties.ProjectileClass = Class'FlameTendril';
		SavedFireProperties.WarnTargetPct = 0.2;
		SavedFireProperties.MaxRange = 920;
		SavedFireProperties.bTossed = True;
		SavedFireProperties.bTrySplash = True;
		SavedFireProperties.bLeadTarget = True;
		SavedFireProperties.bInstantHit = false;
		SavedFireProperties.bInitialized = true;
	}

	Start = GetFirePosStart();
	R = AdjustAim(SavedFireProperties,Start,AimingError);

	P = Spawn(Class'FlameTendril',,,Start,R);
	if( P!=None )
		P.Velocity.Z -= P.TossZ;

	SetAnimAction(FireAnim);
	PlaySound(WeaponFireSound,SLOT_Interact,TransientSoundVolume * 1.5,,TransientSoundRadius,(1.0 + FRand()*0.015f),false);
}
function DesireAttackPoint( out float Desire, NavigationPoint N, Pawn Enemy )
{
	// Must attack from close distance.
	Desire = VSizeSquared(N.Location-Enemy.Location);
	if( Desire>846400 )
		Desire = -1;
	else Desire+=Desire*FRand();
}
function PrepareToAttack( Pawn Enemy )
{
	Super.PrepareToAttack(Enemy);
	bWantsToCrouch = false;
}

function TakeDamage(int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, class<DamageType> damageType, optional int HitIndex )
{
	if( Class<DamTypeBurned>(damageType)==None && Class<DamTypeFlamethrower>(damageType)==None ) // Immune to fire.
		Super.TakeDamage(Damage,instigatedBy,hitlocation,momentum,damageType,HitIndex);
}

defaultproperties
{
	WeaponFireSound=SoundGroup'KF_FlamethrowerSnd.FT_Fire1Shot'
	WeaponReloadSound=Sound'KF_FlamethrowerSnd.Reload.FT_Reload3'
	WAttachClass=Class'KFMod.FlameThrowerAttachment'
	AmmoPerClip=100
	WeaponFireRate=0.070000
	WeaponMissRate=0.150000
	FireOffset=(X=0.900000,Y=0.300000,Z=0.100000)
	WeaponFireTime=3.500000
	AimingError=250.000000
	FireAnim="FlameThrowerFire"
	WeaponReloadAnim="ReloadPistol"
	//OriginalGroundSpeed=120.000000
	//HealthMax=420.000000
	//Health=420
	//HeadHealth=350.000000
	ScoringValue=40
	MenuName="Civil Firebug"
	Mesh=SkeletalMesh'KFSoldiers.Hazmat'
	Skins(0)=Combiner'KFCharacters.CombinerHazmat'
	Skins(1)=Shader'KFCharacters.HazmatVisorShader'
}