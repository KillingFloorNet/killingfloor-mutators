class HitmanMut extends Mutator
	Config(HitmanMut); 

var array<xPlayer> NewPlayers;
var() globalconfig array<string> HitmanPlayerIDs;

function PreBeginPlay()
{
    AddToPackageMap("Hitman");
    Class'KFGameType'.Default.AvailableChars[Class'KFGameType'.Default.AvailableChars.Length] = "Hitman.Hitman";
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
        if( NewPlayers[0]!=None && NewPlayers[0].Player!=None && ShouldHitman(NewPlayers[0].GetPlayerIDHash()) )
            NewPlayers[0].SetPawnClass("","Hitman.Hitman");
        NewPlayers.Remove(0,1);
    }
}

final function bool ShouldHitman( string ID )
{
    local int i;

	log("HitmanPlayerIDs.Length"@HitmanPlayerIDs.Length);
    for( i=(HitmanPlayerIDs.Length-1); i>=0; --i )
        if( HitmanPlayerIDs[i]==ID )
            return true;
    return false;
}

defaultproperties
{
     GroupName="KF_Hitman"
     FriendlyName="AddHitman"
     Description="Hitman"
}
