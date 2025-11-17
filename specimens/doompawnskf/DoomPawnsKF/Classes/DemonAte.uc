class DemonAte extends MeleeDamage
	Abstract;

static function string DeathMessage(PlayerReplicationInfo Killer, PlayerReplicationInfo Victim)
{
	if( Killer==None )
		Return "%o was eaten by a Pinky";
	else return Default.DeathString;
}

defaultproperties
{
     DeathString="%o was eaten by %k"
}
