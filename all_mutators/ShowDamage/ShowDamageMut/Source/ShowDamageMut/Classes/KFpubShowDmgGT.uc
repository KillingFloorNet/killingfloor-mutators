//=============================================================================
// KFpubShowDmgGT
//=============================================================================
// Created by r1v3t
// © 2011, KFpub :: www.kfpub.com
//=============================================================================
class KFpubShowDmgGT extends KFGameType
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
	Damage = super.ReduceDamage(Damage, injured, instigatedBy, HitLocation, Momentum, DamageType);
	if(PlayerController(instigatedBy.Controller) != none)
	{
		PlayerDamaged(Damage, PlayerController(instigatedBy.Controller));
	}
	return Damage;
}