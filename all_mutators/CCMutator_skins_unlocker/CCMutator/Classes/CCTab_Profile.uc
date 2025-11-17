class CCTab_Profile extends KFTab_Profile;

function bool PickModel(GUIComponent Sender)
{
	if ( Controller.OpenMenu("CCMutator.CCModelSelect", PlayerRec.DefaultName, Eval(Controller.CtrlPressed, PlayerRec.Race, "")) )
	{
		Controller.ActivePage.OnClose = ModelSelectClosed;
	}

	return true;
}

function SaveSettings()
{
	local PlayerController PC;

	PC = PlayerOwner();

	if ( sChar != sCharD )
	{
		sCharD = sChar;
		PC.ConsoleCommand("ChangeCharacter"@sChar);

		if ( !PC.IsA('xPlayer') )
		{
			PC.UpdateURL("Character", sChar, True);
		}

		if ( PlayerRec.Sex ~= "Female" )
		{
			PC.UpdateURL("Sex", "F", True);
		}
		else
		{
			PC.UpdateURL("Sex", "M", True);
		}
	}

	class'KFPlayerController'.default.SelectedVeterancy = class'KFGameType'.default.LoadedSkills[lb_PerkSelect.GetIndex()];

	if ( KFPlayerController(PC) != none )
	{
		KFPlayerController(PC).SelectedVeterancy = class'KFGameType'.default.LoadedSkills[lb_PerkSelect.GetIndex()];
		KFPlayerController(PC).SendSelectedVeterancyToServer();
		PC.SaveConfig();
	}
	else
	{
		class'KFPlayerController'.static.StaticSaveConfig();
	}
}

defaultproperties
{
}
