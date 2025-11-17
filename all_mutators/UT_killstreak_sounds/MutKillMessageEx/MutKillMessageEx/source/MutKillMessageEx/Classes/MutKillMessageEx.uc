// Mutator created by Marco.
Class MutKillMessageEx extends Mutator;

function PreBeginPlay()
{
	Spawn(Class'KillsRulesEx');
	AddToPackageMap();
}

defaultproperties
{
     GroupName="KF-MessageMutEx"
     FriendlyName="Kill Messages Ex"
     Description="Add zombie kill messages on screen."
     LifeSpan=0.100000
}
