class NaziDmg extends ShotDmg 
	Abstract;

static function string DeathMessage(PlayerReplicationInfo Killer, PlayerReplicationInfo Victim)
{
	if( Killer==None )
		Return "%o met a Nazi";
	else return Default.DeathString;
}

defaultproperties
{
     DeathString="%o met %k"
     FemaleSuicide="%o was gunned down by a Nazi"
     MaleSuicide="%o was gunned down by a Nazi"
}
