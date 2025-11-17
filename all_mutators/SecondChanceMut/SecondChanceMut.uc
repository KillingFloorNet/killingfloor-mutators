class SecondChanceMut extends Mutator;

var SecondChanceRules Rules;

function PostBeginPlay()
{
	if( Rules==None )
		Rules = Spawn(Class'SecondChanceRules');
}

defaultproperties
{
	GroupName="KF-SecondChance"
	FriendlyName="SecondChanceMut"
	Description="SecondChanceMut"
}