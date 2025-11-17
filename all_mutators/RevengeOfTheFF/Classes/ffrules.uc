class ffRules extends GameRules;



function int NetDamage( int OriginalDamage, int Damage, pawn injured, pawn instigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType )
{
	if ( injured.isa('kfhumanpawn') && instigatedby.isa('kfhumanpawn') && injured!=instigatedby)
	{
		instigatedby.takedamage(damage, instigatedBy, hitlocation, momentum, damageType);
		damage=0;
		return Damage;
	}
}

defaultproperties
{
}
