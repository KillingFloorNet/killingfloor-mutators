class RevenBlown extends DamTypeExploBarrel
	Abstract;

static function string DeathMessage(PlayerReplicationInfo Killer, PlayerReplicationInfo Victim)
{
	if( Killer==None )
		Return "%o couldn't evade a Revenant's fireball";
	else return Default.DeathString;
}

defaultproperties
{
     DeathString="%o couldn't evade %k's fireball"
     FemaleSuicide="%o was orally pleasured by a Revenant's fireball"
     MaleSuicide="%o was orally pleasured by a Revenant's fireball"
}
