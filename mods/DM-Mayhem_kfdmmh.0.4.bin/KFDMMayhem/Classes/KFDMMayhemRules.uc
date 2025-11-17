class KFDMMayhemRules extends GameRules;

function scoreKill( Controller killer,Controller killed )
{
	if( MHPlayerController( killer ) != none && MHPlayerController( killed ) != none )
	{
		if( killer != killed ) MHPlayerReplicationInfo( killer.playerReplicationInfo ).fragCount++;
		if( killer == killed ) MHPlayerReplicationInfo( killer.playerReplicationInfo ).fragCount--;
	}

	if ( nextGameRules != none )
		nextGameRules.scoreKill( killer,killed );
}

function int NetDamage( int OriginalDamage, int Damage, pawn injured, pawn instigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType )
{
	log( "RLOG: original net damage =" @ damage );

	if( MHHumanPawn( injured ) != none && MHHumanPawn( instigatedBy ) != none && ClassIsChildOf( DamageType,class'DamTypeMelee' ) )
		Damage *= 3;

	log( "RLOG: modified net damage =" @ damage );

	if ( NextGameRules != None )
		return NextGameRules.NetDamage( OriginalDamage,Damage,injured,instigatedBy,HitLocation,Momentum,DamageType );

	log( "RLOG: final net damage =" @ damage );

	return Damage;
}

defaultproperties
{
}
