//-----------------------------------------------------------
//
//-----------------------------------------------------------
class MutChatter extends Mutator;
var ChatterSpectator GlobalInstance;

function PostBeginPlay()
{
    AddToPackageMap();

    GlobalInstance = Spawn(class'ChatterSpectator', self);
    class'MutChatter'.default.GlobalInstance = GlobalInstance;

}

static function AddListener(ChatterListener listener)
{
    if (listener == None)
        return;

    Instance().Listeners.Length = Instance().Listeners.Length + 1;
    Instance().Listeners[Instance().Listeners.Length-1] = listener;
}

static function bool IsLoaded()
{
    return (class'MutChatter'.default.GlobalInstance != None);
}

static function ChatterSpectator Instance()
{
    return class'MutChatter'.default.GlobalInstance;
}

defaultproperties
{
     GroupName="KF-Utility-Chatter"
     FriendlyName="Utility: Chatter"
     Description="Utility: Gives the ability to mutators to catch and process chat."
}
