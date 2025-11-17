class DamTypeV94LLI extends DamTypeKFSnipe
	abstract;

static function GetHitEffects(out class<xEmitter> HitEffects[4], int VictimHealth)
{
	HitEffects[0] = class'HitSmoke';
	if( VictimHealth <= 0 )
		HitEffects[1] = class'KFHitFlame';
	else if ( FRand() < 0.8 )
		HitEffects[1] = class'KFHitFlame';
}

defaultproperties
{
     HeadShotDamageMult=8.000000
     WeaponClass=Class'V94LLImut.V94LLI'
     DeathString="%k killed %o (V-94 Volga)."
     KDamageImpulse=6000.000000
     KDeathVel=600.000000
     KDeathUpKick=200.000000
}
