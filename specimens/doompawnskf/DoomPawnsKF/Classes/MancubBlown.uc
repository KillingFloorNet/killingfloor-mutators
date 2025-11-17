class MancubBlown extends DamTypeExploBarrel
	Abstract;

static function string DeathMessage(PlayerReplicationInfo Killer, PlayerReplicationInfo Victim)
{
	if( Killer==None )
		Return "%o was squished by a Mancubus";
	else return Default.DeathString;
}

defaultproperties
{
     DeathString="%o was squished by %k"
     FemaleSuicide="%o let a Mancubus' flameball get her"
     MaleSuicide="%o let a Mancubus' flameball get him"
}
