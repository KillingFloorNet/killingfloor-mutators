class ZomBurned extends Burned
	Abstract;

static function string DeathMessage(PlayerReplicationInfo Killer, PlayerReplicationInfo Victim)
{
	if( Killer==None )
		Return "%o was elecrified by a Plasma Zombie";
	else return Default.DeathString;
}

defaultproperties
{
     DeathString="%o was elecrified by %k"
     FemaleSuicide="%o was elecrified by a Plasma Zombie's plasma ball"
     MaleSuicide="%o was elecrified by a Plasma Zombie's plasma ball"
}
