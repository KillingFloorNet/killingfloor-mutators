//=============================================================================
// KFpubShowDmgGT
//=============================================================================
// Created by r1v3t
// © 2011, KFpub :: www.kfpub.com
//=============================================================================
class KFpubShowDmgGT extends SRGameType
	CacheExempt;

function PlayerDamaged(int Damage, PlayerController PC)
{
	if(Damage == 0)
	{
		return;
	}
	KFpubShowDmgPC(PC).OnPlayerDamaged(Damage);
}

function int ReduceDamage(int Damage, Pawn injured, Pawn instigatedBy, Vector HitLocation, out Vector Momentum, class<DamageType> DamageType)
{
	local int realDamage;
	Damage = super.ReduceDamage(Damage, injured, instigatedBy, HitLocation, Momentum, DamageType);
	realDamage=Damage;
	if(Damage>injured.Health) realDamage=injured.Health;
	if(PlayerController(instigatedBy.Controller) != none)
	{
		PlayerDamaged(realDamage, PlayerController(instigatedBy.Controller));
	}
	return Damage;
}