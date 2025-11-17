class AddActorsMut extends Mutator
    Config(AddActorsMut);

var() globalconfig array<string> Actors;
var() config bool bDebug;

function PreBeginPlay()
{
    local int i;
    local class<Actor> aClass;
    local Actor A;

    for(i=0;i<Actors.Length;i++)
    {
        aClass = class<Actor>(DynamicLoadObject(Actors[i], class'Class'));
        A = Spawn(aClass);
        if(bDebug)
            log("Add Actor"@Actors[i]);
    }
}

defaultproperties
{
    bAddToServerPackages=True
    GroupName="KF_AddActorsMut"
    FriendlyName="AddActorsMut"
    Description="AddActorsMut"
    bAlwaysRelevant=True
}