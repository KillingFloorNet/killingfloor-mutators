class CacoBurned extends Burned
	Abstract;

static function string DeathMessage(PlayerReplicationInfo Killer, PlayerReplicationInfo Victim)
{
	if( Killer==None )
		Return "%o was smitted by a Cacodemon";
	else return Default.DeathString;
}

defaultproperties
{
     DeathString="%o was smitted by %k"
     FemaleSuicide="%o was burned by a Cacodemon's fireball"
     MaleSuicide="%o was burned by a Cacodemon's fireball"
}
