class CyberBlown extends RLBlown
	Abstract;

static function string DeathMessage(PlayerReplicationInfo Killer, PlayerReplicationInfo Victim)
{
	if( Killer==None )
		Return "%o was splattered by a Cyberdemon";
	else return Default.DeathString;
}

defaultproperties
{
     FemaleSuicide="%o put a Cyberdemon's rocket in her ass"
     MaleSuicide="%o put a Cyberdemon's rocket in his ass"
}
