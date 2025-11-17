Class ZEDSniper extends ZEDSoldierBase;

var Pawn FirstContact;
var byte NumHides;

function DesireAttackPoint( out float Desire, NavigationPoint N, Pawn Enemy )
{
	// Prefer to attack from distance.
	Desire = VSizeSquared(N.Location-Enemy.Location);
	if( Desire>25000000 )
		Desire*=0.4f;
	else Desire+=Desire*FRand();
}

function bool LurkBackOff( Pawn Enemy )
{
	if( FirstContact != Enemy )
	{
		FirstContact = Enemy;
		NumHides = 0;
		return true; // Always hide off with first contact.
	}
	if( NumHides>5 )
	{
		NumHides = Rand(6);
		return false;
	}
	++NumHides;
	return Super.LurkBackOff(Enemy);
}

defaultproperties
{
	WeaponFireSound=SoundGroup'KF_RifleSnd.Rifle_Fire'
	WeaponReloadSound=SoundGroup'KF_RifleSnd.Rifle_Reload'
	WAttachClass=Class'KFMod.WinchesterAttachment'
	AmmoPerClip=5
	WeaponHitDamage(0)=15
	WeaponHitDamage(1)=10 //8
	WeaponFireRate=1.000000
	WeaponMissRate=0.010000
	WeaponFireTime=2.500000
	AimingError=50.000000
	WeaponReloadAnim="Reload1"
	bReloadClipAtTime=True
	bLurker=True
	//OriginalGroundSpeed=250.000000
	//HealthMax=350.000000
	//Health=350
	//HeadHealth=250.000000
	ScoringValue=35
	MenuName="Civil Sharpshooter"
	Mesh=SkeletalMesh'KFSoldiers.Cpl'
	Skins(0)=Texture'KFCharacters.PowersSkin'
}