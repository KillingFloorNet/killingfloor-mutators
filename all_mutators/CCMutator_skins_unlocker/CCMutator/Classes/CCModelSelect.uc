class CCModelSelect extends KFModelSelect;

var() private string InvalidTypes, IgnoredTypes;

// Overridden to get rid of the Race combo
function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	super(LockedFloatingWindow).Initcomponent(MyController, MyOwner);

	sb_Main.SetPosition(0.040000,0.075000,0.680742,0.555859);
	sb_Main.RightPadding = 0.5;
	sb_Main.ManageComponent(CharList);

	class'xUtil'.static.GetPlayerList(PlayerList);
	RefreshCharacterList(InvalidTypes);

	// Spawn spinning character actor
	if ( SpinnyDude == None )
		SpinnyDude = PlayerOwner().spawn(class'XInterface.SpinnyWeap');

	SpinnyDude.SetDrawType(DT_Mesh);
	SpinnyDude.SetDrawScale(0.9);
	SpinnyDude.SpinRate = 0;
}

function RefreshCharacterList(string ExcludedChars, optional string Race)
{
    local int i, j;
    local array<string> Excluded;

    // Prevent list from calling OnChange events
    CharList.List.bNotify = False;
    CharList.Clear();

    Split(ExcludedChars, ";", Excluded);
    for ( i = 0; i < PlayerList.Length; i++ )
    {
    /*
		// Check that this character is selectable
		if ( PlayerList[i].Menu != "" )
		{
			for (j = 0; j < Excluded.Length; j++)
				if ( InStr(";" $ Playerlist[i].Menu $ ";", ";" $ Excluded[j] $ ";") != -1 )
					break;

			if ( j < Excluded.Length )
				continue;
		}
    */
		CharList.List.Add(Playerlist[i].Portrait, i, 0);
    }

    CharList.List.LockedMat = LockedImage;
    CharList.List.bNotify = True;
}

// Overridden to hook up Steam Checks
function bool IsUnlocked(xUtil.PlayerRecord Test)
{
	// If character has no menu filter, just return true
	//if ( PlayerOwner() == none )
	//	return super.IsUnlocked(Test);

	return true;//PlayerOwner().CharacterAvailable(Test.DefaultName);
}
/*
function HandleLockedCharacterClicked(int NewIndex)
{
	if ( PlayerOwner() != none )//&& PlayerOwner().PurchaseCharacter(Playerlist[NewIndex].DefaultName) )
	{
		Controller.CloseMenu(true);
	}
}*/

defaultproperties
{
     InvalidTypes="UDP"
     IgnoredTypes="SP"
     Begin Object Class=CCGUIVertImageListBox Name=vil_CharList
         CellStyle=CELL_FixedCount
         NoVisibleRows=4
         NoVisibleCols=5
         OnCreateComponent=vil_CharList.InternalOnCreateComponent
         WinTop=0.185119
         WinLeft=0.102888
         WinWidth=0.403407
         WinHeight=0.658125
         TabOrder=0
         bBoundToParent=True
         bScaleToParent=True
         OnChange=CCModelSelect.ListChange
     End Object
     CharList=CCGUIVertImageListBox'CCMutator.CCModelSelect.vil_CharList'

}
