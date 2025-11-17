class DamagePopupGameRules extends GameRules;

var Pawn LastDamagePawn;
var int LastDamage;

function int NetDamage( int OriginalDamage, int Damage, pawn injured, pawn instigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType )
{
	if ( NextGameRules != None )
		damage = NextGameRules.NetDamage(OriginalDamage,Damage,injured,instigatedBy,HitLocation,Momentum,DamageType );
	if( injured!=None )
	{
		if( Monster(injured)!=None )
		{
			if( !Class'mutDamagePopup'.Default.bMsgZedsDamage )
				return Damage;
		}
		else if( !Class'mutDamagePopup'.Default.bMsgPlayersDamage )
			return Damage;

		if( LastDamagePawn!=None && LastDamagePawn!=injured )
		{
			Timer();
			LastDamagePawn = None;
		}
		if( LastDamagePawn==None )
		{
			LastDamagePawn = injured;
			LastDamage = 0;
			SetTimer(0.1,false);
		}
		LastDamage+=Damage;
	}
	return Damage;
}
function Timer()
{
	if( LastDamagePawn!=None )
	{
		class'DamagePopup'.static.showdamage(LastDamagePawn,LastDamagePawn.Location+vect(0,0,1)*LastDamagePawn.CollisionHeight,LastDamage);
		LastDamagePawn=none;
		LastDamage=0;
	}
}

defaultproperties
{
}
