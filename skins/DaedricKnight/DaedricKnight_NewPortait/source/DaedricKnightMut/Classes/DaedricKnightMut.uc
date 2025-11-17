class DaedricKnightMut extends Mutator;

var array<xPlayer> NewPlayers;
var config array<string> PlayerIDs;

function PostBeginPlay()
{
	AddToPackageMap("DaedricKnightMod");
	Class'KFGameType'.Default.AvailableChars[Class'KFGameType'.Default.AvailableChars.Length] = "DaedricKnight";
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
		if( NewPlayers[0]!=None && NewPlayers[0].Player!=None && 
			ShouldSkin(NewPlayers[0].GetPlayerIDHash()) )
			NewPlayers[0].SetPawnClass("","DaedricKnight");
		NewPlayers.Remove(0,1);
	}
}

final function bool ShouldSkin( string ID )
{
	local int i;

	for( i=(PlayerIDs.Length-1); i>=0; --i )
		if( PlayerIDs[i]==ID )
			return true;
	return false;
}

defaultproperties
{
     bAddToServerPackages=True
     GroupName="KF_DaedricKnight"
     FriendlyName="DaedricKnight character"
     Description="DaedricKnight character"
     bAlwaysRelevant=True
}
