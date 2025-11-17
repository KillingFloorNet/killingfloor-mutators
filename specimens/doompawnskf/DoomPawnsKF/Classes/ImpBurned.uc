class ImpBurned extends Burned
	Abstract;

static function string DeathMessage(PlayerReplicationInfo Killer, PlayerReplicationInfo Victim)
{
	if( Killer==None )
		Return "%o was burned by an Imp";
	else return Default.DeathString;
}

defaultproperties
{
     DeathString="%o was burned by %k's fireball"
     FemaleSuicide="%o was burned by a Imp's fireball"
     MaleSuicide="%o was burned by a Imp's fireball"
}
