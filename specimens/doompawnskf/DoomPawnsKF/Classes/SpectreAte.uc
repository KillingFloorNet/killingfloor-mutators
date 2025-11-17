class SpectreAte extends DemonAte
	Abstract;

static function string DeathMessage(PlayerReplicationInfo Killer, PlayerReplicationInfo Victim)
{
	if( Killer==None )
		Return "%o was eaten by a Spectre";
	else return Default.DeathString;
}

defaultproperties
{
}
