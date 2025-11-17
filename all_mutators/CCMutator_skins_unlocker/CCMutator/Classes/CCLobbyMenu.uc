class CCLobbyMenu extends LobbyMenu;

function bool ShowPerkMenu(GUIComponent Sender)
{
	if ( PlayerOwner() != none)
		PlayerOwner().ClientOpenMenu(string(Class'CCProfilePage'), false);
	return true;
}

defaultproperties
{
}
