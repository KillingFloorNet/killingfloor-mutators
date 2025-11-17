class SpiBurned extends PlasmaZapped
	Abstract;

static function string DeathMessage(PlayerReplicationInfo Killer, PlayerReplicationInfo Victim)
{
	if( Killer==None )
		Return "%o let an Arachnotron get him";
	else return Default.DeathString;
}

defaultproperties
{
     DeathString="%o let %k get him"
     FemaleSuicide="%o let an Arachnotron's plasmaball get her"
     MaleSuicide="%o let an Arachnotron's plasmaball get him"
}
