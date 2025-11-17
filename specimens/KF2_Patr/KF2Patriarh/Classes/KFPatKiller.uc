class KFPatKiller extends Mutator;

var PatriarchOldKillRules RulesMod1;
var PatriarchNewKillRules RulesMod2;

function PostBeginPlay()
{
	if( RulesMod1==None )
		RulesMod1 = Spawn(Class'PatriarchOldKillRules');
	if( RulesMod2==None )
		RulesMod2 = Spawn(Class'PatriarchNewKillRules');		
}

defaultproperties
{
     bAddToServerPackages=True
     GroupName="KF-PatKiller"
     FriendlyName="Patriarch Killer"
     Description="Shows up who killed the Patriarch"
}
