class VileCursed extends DamTypeExploBarrel
	Abstract;

static function string DeathMessage(PlayerReplicationInfo Killer, PlayerReplicationInfo Victim)
{
	if( Killer==None )
		Return "%o burned in hell with the curse from an Arch-Vile";
	else return Default.DeathString;
}

defaultproperties
{
     DeathString="%o burned in hell with the curse from %k"
     FemaleSuicide="%o let a curse from a dead Arch-Vile get her"
     MaleSuicide="%o let a curse from a dead Arch-Vile get him"
}
