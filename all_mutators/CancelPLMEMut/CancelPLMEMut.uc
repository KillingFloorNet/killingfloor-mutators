class CancelPLMEMut extends Mutator;

var CancelPLMERules Rules;

function PostBeginPlay()
{
    if( Rules==None )
        Rules = Spawn(Class'CancelPLMERules');
}

defaultproperties
{
    GroupName="KF-CancelPLME"
    FriendlyName="CancelPLMEMut"
    Description="CancelPLMEMut"
}