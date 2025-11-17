class CCPlayerController extends KFPlayerController;

exec function ChangeCharacter(string newCharacter, optional string inClass)
{
	local CCLastChar CCLC;
	if ( NewCharacter != "" ) // && CharacterAvailable(newCharacter) )
	{
		SetPawnClass(string(PawnClass), newCharacter);
		UpdateURL("Character", newCharacter, true);
		SaveConfig();
		CCLC = new class'CCLastChar'; 
		CCLC.SetLastChar(newCharacter);
	}
}

function SetPawnClass(string inClass, string inCharacter)
{
	PawnClass = Class'KFHumanPawn';
	inCharacter = Class'CCMutator'.Static.GetCharacterList(inCharacter);
	PawnSetupRecord = class'xUtil'.static.FindPlayerRecord(inCharacter);
	PlayerReplicationInfo.SetCharacterName(inCharacter);
}

defaultproperties
{
     LobbyMenuClassString="CCMutator.CCLobbyMenu"
}
