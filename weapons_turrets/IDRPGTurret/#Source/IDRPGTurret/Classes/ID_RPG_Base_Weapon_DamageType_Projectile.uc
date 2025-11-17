class ID_RPG_Base_Weapon_DamageType_Projectile extends ID_RPG_Base_Weapon_DamageType
	abstract;

defaultproperties
{
    PawnDamageEmitter=Class'ROEffects.ROBloodPuff'
    LowGoreDamageEmitter=Class'ROEffects.ROBloodPuffNoGore'
    LowDetailEmitter=Class'ROEffects.ROBloodPuffSmall'
}
