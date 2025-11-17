class DamTypeFloodLight extends KFWeaponDamageType
	abstract;

defaultproperties
{
	DeathString="%o was turned into swiss cheese by %k."
	FemaleSuicide="%o was shot and killed by her own FloodLight."
	MaleSuicide="%o was shot and killed by his own FloodLight."

	bRagdollBullet=False
	KDeathVel=105.000000
	KDamageImpulse=500
	KDeathUpKick=15
	bSniperWeapon=False
	bCheckForHeadShots=True
}
