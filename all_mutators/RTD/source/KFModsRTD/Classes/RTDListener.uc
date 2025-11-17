//-----------------------------------------------------------
//
//-----------------------------------------------------------
class RTDListener extends ChatterListener;

var MutRTD Mutator;
function OnMessage(coerce string Message, name Type, PlayerReplicationInfo PRI)
{
    if (((string(Type) ~= "say") || (string(Type) ~= "sayteam") || (string(Type) ~= "teamsay")) && (Message ~= "!rtd"))
    {
       Mutator.RollRequested(PRI);
    }
}

defaultproperties
{
}
