class CCGUIVertImageList extends KFGUIVertImageList;

function int SetIndex(int NewIndex)
{
	if ( Elements[NewIndex].Locked == 1 )
	{
		log(MenuOwner.MenuOwner);

		if ( CCModelSelect(MenuOwner.MenuOwner) != none )
		{
			CCModelSelect(MenuOwner.MenuOwner).HandleLockedCharacterClicked(NewIndex);
		}

		return Index;
	}

	return super.SetIndex(NewIndex);
}

defaultproperties
{
}
