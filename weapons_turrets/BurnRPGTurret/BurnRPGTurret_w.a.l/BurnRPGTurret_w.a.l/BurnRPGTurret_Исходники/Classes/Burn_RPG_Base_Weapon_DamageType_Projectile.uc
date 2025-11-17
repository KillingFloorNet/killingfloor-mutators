class Burn_RPG_Base_Weapon_DamageType_Projectile extends Burn_RPG_Base_Weapon_DamageType
	abstract;

defaultproperties
{
    PawnDamageEmitter=Class'ROEffects.ROBloodPuff'
    LowGoreDamageEmitter=Class'ROEffects.ROBloodPuffNoGore'
    LowDetailEmitter=Class'ROEffects.ROBloodPuffSmall'
}
