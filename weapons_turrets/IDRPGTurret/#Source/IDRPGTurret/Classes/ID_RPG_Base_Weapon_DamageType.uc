class ID_RPG_Base_Weapon_DamageType extends WeaponDamageType;

var float	HeadShotDamageMult;

var bool IsShotgun;
var bool IsPistol;
var bool IsSubMachineGun;
var bool IsMachineGun;
var bool IsSniper;
var bool IsFlamer;
var bool IsExplosive;
var bool IsMelee;
var bool CheckForHeadShots;

defaultproperties
{
    HeadShotDamageMult=1.3
    bKUseOwnDeathVel=True
    CheckForHeadShots=True
    bBulletHit=True
    GibPerterbation=0.25
    KDamageImpulse=15000
    KDeathVel=200
    KDeathUpKick=100
    HumanObliterationThreshhold=25000
}
