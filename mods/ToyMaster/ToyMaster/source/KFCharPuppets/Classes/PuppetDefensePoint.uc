class PuppetDefensePoint extends KFDoorMover;

var () bool bBotWeldInvicible;
var () bool bExplosiveInvincible;

/*  @ Dave - this is how I would set it up

There is a var 'bIsExplosive' in the KFWeaponDamageType class we can
use to check if the damage being dealt is from a grenade / rocket.

If so, we return before the super call

- Alex

*/

function TakeDamage( int Damage, Pawn InstigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> damageType, optional int HitIndex)
{
	local class<KFWeaponDamageType> 	KFDamage;

	if(bExplosiveInvincible)
	{
		KFDamage = class<KFWeaponDamageType>(damageType) ;
		if(KFDamage != none && KFDamage.default.bIsExplosive)
		{
			return;
		}
	}

	//Keeps bots from unwelding the defense point. They still try which is ok because it kinda simulates players
	//trying to protect it.
	if ( bBotWeldInvicible && (damageType == class 'DamTypeWelder' || damageType == class 'DamTypeUnWeld') )
	{
		 return;
	}

	Super.TakeDamage(Damage,InstigatedBy,HitLocation,Momentum,damageType,HitIndex);
}

defaultproperties
{
     bBotWeldInvicible=True
     bExplosiveInvincible=True
}
