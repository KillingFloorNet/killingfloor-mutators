class SpookedDmg extends DamageType
	Abstract;

static function string DeathMessage(PlayerReplicationInfo Killer, PlayerReplicationInfo Victim)
{
	if( Killer==None )
		Return "%o was spooked a Lost Soul";
	else return Default.DeathString;
}

defaultproperties
{
     DeathString="%o was spooked by %k"
     FemaleSuicide="%o was spooked by a Lost Soul"
     MaleSuicide="%o was spooked by a Lost Soul"
}
