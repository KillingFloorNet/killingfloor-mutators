class PhoenixMut extends Mutator
	Config(PhoenixMut); 

var array<xPlayer> NewPlayers;
var() globalconfig array<string> PhoenixPlayerIDs;

function PreBeginPlay()
{
    AddToPackageMap("Phoenix");
    Class'KFGameType'.Default.AvailableChars[Class'KFGameType'.Default.AvailableChars.Length] = "Phoenix.Phoenix";
}

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	if( xPlayer(Other)!=None)
    {
        NewPlayers[NewPlayers.Length] = xPlayer(Other);
        SetTimer(0.1,false);
    }
    return true;
}

function Timer()
{
    while( NewPlayers.Length>0 )
    {
		log("IDHash"@NewPlayers[0].GetPlayerIDHash());
        if( NewPlayers[0]!=None && NewPlayers[0].Player!=None && ShouldPhoenix(NewPlayers[0].GetPlayerIDHash()) )
            NewPlayers[0].SetPawnClass("","Phoenix.Phoenix");
        NewPlayers.Remove(0,1);
    }
}

final function bool ShouldPhoenix( string ID )
{
    local int i;

	log("PhoenixPlayerIDs.Length"@PhoenixPlayerIDs.Length);
    for( i=(PhoenixPlayerIDs.Length-1); i>=0; --i )
        if( PhoenixPlayerIDs[i]==ID )
            return true;
    return false;
}

defaultproperties
{
     GroupName="KF_Phoenix"
     FriendlyName="Phoenix"
     Description="Phoenix"
}
