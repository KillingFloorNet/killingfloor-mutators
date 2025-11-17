class CommFixMut extends Mutator;

function PostBeginPlay()
{
    local CommFixRules RulesMod;
    if(RulesMod==None) RulesMod=Spawn(Class'CommFixRules');
}

defaultproperties
{
    GroupName="KF-CommFix"
    FriendlyName="CommFixMut"
    Description="Add damage bonus for 6 lvl Commando"
}