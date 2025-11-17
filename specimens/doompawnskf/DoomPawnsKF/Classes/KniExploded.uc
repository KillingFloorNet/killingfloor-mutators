class KniExploded extends MeleeDamage
	Abstract;

static function string DeathMessage(PlayerReplicationInfo Killer, PlayerReplicationInfo Victim)
{
	if( Killer==None )
		Return "%o got some green shit up on their ass by a Hell Knight";
	else return Default.DeathString;
}

defaultproperties
{
     DeathString="%o got some green shit up on their ass by %k"
     FemaleSuicide="%o got hit by a flameball by some monster"
     MaleSuicide="%o got hit by a flameball by some monster"
}
