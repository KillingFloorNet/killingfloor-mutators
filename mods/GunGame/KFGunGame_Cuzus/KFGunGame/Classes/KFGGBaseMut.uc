class KFGGBaseMut 
	extends KillingFloorMut HideDropDown CacheExempt
	config(KFGunGameLinkStat); // MutOpenCustomLink

// <!--
// MutOpenCustomLink
var globalconfig array<string> PlayersCustomLinkShown;
var array<KFPlayerController> PendingPlayers;
// -->

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	if (Controller(Other) != None)
	{
		Controller(Other).PlayerReplicationInfoClass = Class'KFGGPRI';
	}

	// <!--
	// MutOpenCustomLink
	if (KFPlayerController(Other) != none)
	{
		PendingPlayers[PendingPlayers.Length] = KFPlayerController(Other);
		SetTimer(1.0, false);
	}
	// -->

	return true;
}

// <!--
// MutOpenCustomLink
function Timer()
{
	local int i;
    local string str;
	
	for (i = 0; i < PendingPlayers.Length; i++)
	{
        str = PendingPlayers[i].GetPlayerIDHash();

        if (!IsCustomLinkShown(str))
        {
            PendingPlayers[i].ClientOpenMenu(string(class'UT2K4GUIPageOpenLink'), false);
            PlayersCustomLinkShown[PlayersCustomLinkShown.Length] = str;
			SaveConfig();
        }
	}
	
	PendingPlayers.Length = 0;
}

function bool IsCustomLinkShown(string id)
{
	local int i;

	if (PlayersCustomLinkShown.Length == 0)
	{
		return false;
	}
	
	for (i = 0; i < PlayersCustomLinkShown.Length; i++)
	{
		if (PlayersCustomLinkShown[i] ~= id)
		{
			return true;
		}
	}
	
	return false;
}
// -->