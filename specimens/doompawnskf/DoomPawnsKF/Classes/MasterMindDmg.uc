class MasterMindDmg extends ShotDmg 
	Abstract;

static function string DeathMessage(PlayerReplicationInfo Killer, PlayerReplicationInfo Victim)
{
	if( Killer==None )
		Return "%o stood in awe of the Spider MasterMind";
	else return Default.DeathString;
}

defaultproperties
{
     DeathString="%o stood in awe of %k"
     FemaleSuicide="%o was gunned down by a Spider"
     MaleSuicide="%o was gunned down by a Spider"
}
