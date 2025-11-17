class ArenaMenu extends UT2K4GUIPage;

var Automated GUIImage		MyBack, Box_Unused, Box_Used;
var Automated GUIButton		BDone, BCancel, BAdd, BRemove, BAddAll, BRemoveAll;
var automated GUIHeader		MyHeader;
var automated GUIListBox	lb_UsedWeapons, lb_UnusedWeapons;
var automated moCheckbox	ch_Random, ch_PerSpawn;

var() localized string Headings[2];

function int WeaponRank(string PackageName, optional string ClassName)
{

	if (PackageName == "KF")
		return 0;
	if (PackageName == "KFMod")
		return 1;
	if (PackageName == "O")
		return 50;
	return 110;
}

// Used by SortList.
function int MyCompareItem(GUIListElem ElemA, GUIListElem ElemB)
{
	local int i, AR, BR;

	if (ElemA.bSection)
		AR = WeaponRank(ElemA.ExtraStrData);
	else
	{
		i = InStr(ElemA.ExtraStrData, ".");
		if (i > 0)
			AR = WeaponRank(left(ElemA.ExtraStrData, i), ElemA.ExtraStrData);
	}

	if (ElemB.bSection)
		BR = WeaponRank(ElemB.ExtraStrData);
	else
	{
		i = InStr(ElemB.ExtraStrData, ".");
		if (i > 0)
			BR = WeaponRank(left(ElemB.ExtraStrData, i), ElemB.ExtraStrData);
	}

	if (AR == BR)
		return StrCmp(ElemA.Item, ElemB.Item);
	else
		return AR-BR;
}

function bool InternalOnDragDrop(GUIComponent Sender)
{
	local array<GUIListElem> NewItem;
	local int i;
	local GUIList L;

	L = GUIList(Sender);
	if (L != None && Sender.Controller.DropTarget == Sender)
	{
		if (Sender.Controller.DropSource == L)
			return false;

		if (Sender.Controller.DropSource != None && GUIList(Sender.Controller.DropSource) != None)
		{
			NewItem = GUIList(Sender.Controller.DropSource).GetPendingElements();
			for (i=NewItem.Length;i>-1;i--)
				if (NewItem[i].bSection)
					NewItem.Remove(i, 1);

			if ( !L.IsValidIndex(L.DropIndex) )
				L.DropIndex = L.ItemCount;

			for (i = NewItem.Length - 1; i >= 0; i--)
				L.Insert(L.DropIndex, NewItem[i].Item, NewItem[i].ExtraData, NewItem[i].ExtraStrData);

			L.SetIndex(L.DropIndex);
			return true;
		}
	}
	return false;
}

function InternalOnEndDrag(GUIComponent Accepting, bool bAccepted)
{
	local int i;
	local GUIList L;

	L = lb_UnusedWeapons.List;

	if (bAccepted && Accepting != None)
	{
		L.GetPendingElements();
		if ( Accepting != Self )
		{
			for ( i = 0; i < L.SelectedElements.Length; i++ )
				if (!L.SelectedElements[i].bSection)
					L.RemoveElement(L.SelectedElements[i]);
		}

		L.bRepeatClick = False;
	}

	// Simulate repeat click if the operation was a failure to prevent InternalOnMouseRelease from clearing
	// the SelectedItems array
	// This way we don't lose the items we clicked on
	if (Accepting == None)
		L.bRepeatClick = True;

	L.SetOutlineAlpha(255);
	if ( L.bNotify )
		L.CheckLinkedObjects(L);
}

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	local array<CacheManager.WeaponRecord> Recs;
	local int i, j;

	Super.InitComponent(MyController, MyOwner);

	lb_UnusedWeapons.List.CompareItem = MyCompareItem;

/*
	lb_UnusedWeapons.List.Add("KF Standard",,"KF",true);
	lb_UnusedWeapons.List.Add("Other",,"O",true);
*/
	lb_UnusedWeapons.List.Add(Headings[0],,"KF",true);
	lb_UnusedWeapons.List.Add(Headings[1],,"O",true);

	class'CacheManager'.static.GetWeaponList(Recs);
	for (i=0;i<Recs.Length;i++)
	{
		for (j=0;j<class'AdvArena'.default.WeaponClassNames.length;j++)
			if (class'AdvArena'.default.WeaponClassNames[j] ~= Recs[i].ClassName)
			{
				lb_UsedWeapons.List.Add(Recs[i].FriendlyName, , Recs[i].ClassName);
				break;
			}
		if (j >= class'AdvArena'.default.WeaponClassNames.length)
			lb_UnusedWeapons.List.Add(Recs[i].FriendlyName, , Recs[i].ClassName);
	}

	ch_Random.Checked(class'AdvArena'.default.bRandomPickOne);
	ch_PerSpawn.Checked(class'AdvArena'.default.bRandomPerSpawn);

    lb_UnusedWeapons.List.bDropSource = True;
    lb_UnusedWeapons.List.bDropTarget = True;
    lb_UnusedWeapons.List.OnDragDrop = InternalOnDragDrop;
    lb_UnusedWeapons.List.OnBeginDrag = lb_UnusedWeapons.List.InternalOnBeginDrag;
    lb_UnusedWeapons.List.OnEndDrag = InternalOnEndDrag;
	lb_UnusedWeapons.List.OnDblClick = InternalOnDblClick;

    lb_UsedWeapons.List.bDropSource = True;
    lb_UsedWeapons.List.bDropTarget = True;
    lb_UsedWeapons.List.OnDragDrop = InternalOnDragDrop;
    lb_UsedWeapons.List.OnBeginDrag = lb_UsedWeapons.List.InternalOnBeginDrag;
    lb_UsedWeapons.List.OnEndDrag = lb_UsedWeapons.List.InternalOnEndDrag;
	lb_UsedWeapons.List.OnDblClick = InternalOnDblClick;
}

function bool InternalOnKeyEvent(out byte Key, out byte State, float delta)
{
	if (Key == 0x0D && State == 3)	// Enter
		return InternalOnClick(BDone);

	return false;
}

function InternalOnClose(optional Bool bCanceled)
{
	Super.OnClose(bCanceled);
}

function bool InternalOnClick(GUIComponent Sender)
{
	local int i;

	if (Sender==BCancel) // CANCEL
		Controller.CloseMenu();

	else if (Sender==BAddAll) // ADD ALL
	{
		for (i=lb_UnusedWeapons.List.Elements.Length-1;i>-1;i--)
			if (!lb_UnusedWeapons.List.Elements[i].bSection)
			{
				lb_UsedWeapons.List.Add(lb_UnusedWeapons.List.GetItemAtIndex(i), , lb_UnusedWeapons.List.GetExtraAtIndex(i));
				lb_UnusedWeapons.List.Remove(i);
			}
	}
	else if (Sender==BRemoveAll) // REMOVE ALL
	{
		while(lb_UsedWeapons.List.Elements.Length > 0)
		{
			lb_UnusedWeapons.List.Add(lb_UsedWeapons.List.GetItemAtIndex(0), , lb_UsedWeapons.List.GetExtraAtIndex(0));
			lb_UsedWeapons.List.Remove(0);
		}
	}
	else if (Sender==BAdd) // ADD
	{
		if (!lb_UnusedWeapons.List.IsSection())
		{
			lb_UsedWeapons.List.Add(lb_UnusedWeapons.List.Get(), , lb_UnusedWeapons.List.GetExtra());
			lb_UnusedWeapons.List.Remove(lb_UnusedWeapons.List.Index);
		}
	}
	else if (Sender==BRemove) // REMOVE
	{

		lb_UnusedWeapons.List.Add(lb_UsedWeapons.List.Get(), , lb_UsedWeapons.List.GetExtra());
		lb_UsedWeapons.List.Remove(lb_UsedWeapons.List.Index);
	}
	else if (Sender==BDone) // DONE
	{
		if (lb_UsedWeapons.List.Elements.length < 1)
			class'AdvArena'.default.WeaponClassNames.length = 1;
		else
		{
			class'AdvArena'.default.WeaponClassNames.length = 0;
			for (i=0;i<lb_UsedWeapons.List.Elements.length;i++)
				class'AdvArena'.default.WeaponClassNames[i] = lb_UsedWeapons.List.GetExtraAtIndex(i);

		}
		class'AdvArena'.default.bRandomPickOne = ch_Random.IsChecked();
		class'AdvArena'.default.bRandomPerSpawn = ch_PerSpawn.IsChecked();
		class'AdvArena'.static.StaticSaveConfig();
		Controller.CloseMenu();
	}

	return true;
}

function bool InternalOnDblClick(GUIComponent Sender)
{
	if (Sender==lb_UnusedWeapons.List)
		InternalOnClick(BAdd);
	else if (Sender==lb_UsedWeapons.List)
		InternalOnClick(BRemove);
	return true;
}

defaultproperties
{
     Begin Object Class=GUIImage Name=BackImage
         Image=Texture'2K4Menus.NewControls.Display95'
         ImageStyle=ISTY_Stretched
         WinTop=0.200000
         WinLeft=0.050000
         WinWidth=0.900000
         WinHeight=0.700000
         RenderWeight=0.001000
     End Object
     MyBack=GUIImage'ArenaMut.ArenaMenu.BackImage'

     Begin Object Class=GUIImage Name=ImageBoxUnused
         Image=Texture'2K4Menus.NewControls.Display99'
         ImageStyle=ISTY_Stretched
         WinTop=0.225000
         WinLeft=0.087500
         WinWidth=0.375000
         WinHeight=0.500000
         RenderWeight=0.002000
     End Object
     Box_Unused=GUIImage'ArenaMut.ArenaMenu.ImageBoxUnused'

     Begin Object Class=GUIImage Name=ImageBoxUsed
         Image=Texture'2K4Menus.NewControls.Display99'
         ImageStyle=ISTY_Stretched
         WinTop=0.225000
         WinLeft=0.537500
         WinWidth=0.375000
         WinHeight=0.500000
         RenderWeight=0.002000
     End Object
     Box_Used=GUIImage'ArenaMut.ArenaMenu.ImageBoxUsed'

     Begin Object Class=GUIButton Name=DoneButton
         Caption="DONE"
         WinTop=0.525000
         WinLeft=0.450000
         WinWidth=0.100000
         TabOrder=0
         OnClick=ArenaMenu.InternalOnClick
         OnKeyEvent=DoneButton.InternalOnKeyEvent
     End Object
     bDone=GUIButton'ArenaMut.ArenaMenu.DoneButton'

     Begin Object Class=GUIButton Name=CancelButton
         Caption="CANCEL"
         WinTop=0.575000
         WinLeft=0.450000
         WinWidth=0.100000
         TabOrder=1
         OnClick=ArenaMenu.InternalOnClick
         OnKeyEvent=CancelButton.InternalOnKeyEvent
     End Object
     bCancel=GUIButton'ArenaMut.ArenaMenu.CancelButton'

     Begin Object Class=GUIButton Name=AddButton
         Caption="ADD"
         WinTop=0.375000
         WinLeft=0.450000
         WinWidth=0.100000
         TabOrder=0
         OnClick=ArenaMenu.InternalOnClick
         OnKeyEvent=AddButton.InternalOnKeyEvent
     End Object
     bAdd=GUIButton'ArenaMut.ArenaMenu.AddButton'

     Begin Object Class=GUIButton Name=RemoveButton
         Caption="REMOVE"
         WinTop=0.425000
         WinLeft=0.450000
         WinWidth=0.100000
         TabOrder=0
         OnClick=ArenaMenu.InternalOnClick
         OnKeyEvent=RemoveButton.InternalOnKeyEvent
     End Object
     bRemove=GUIButton'ArenaMut.ArenaMenu.RemoveButton'

     Begin Object Class=GUIButton Name=AddAllButton
         Caption="FILL"
         WinTop=0.250000
         WinLeft=0.450000
         WinWidth=0.100000
         TabOrder=0
         OnClick=ArenaMenu.InternalOnClick
         OnKeyEvent=AddAllButton.InternalOnKeyEvent
     End Object
     BAddAll=GUIButton'ArenaMut.ArenaMenu.AddAllButton'

     Begin Object Class=GUIButton Name=RemoveAllButton
         Caption="EMPTY"
         WinTop=0.300000
         WinLeft=0.450000
         WinWidth=0.100000
         TabOrder=0
         OnClick=ArenaMenu.InternalOnClick
         OnKeyEvent=RemoveAllButton.InternalOnKeyEvent
     End Object
     BRemoveAll=GUIButton'ArenaMut.ArenaMenu.RemoveAllButton'

     Begin Object Class=GUIHeader Name=DaBeegHeader
         bUseTextHeight=True
         Caption="Advanced Arena Options"
         WinTop=0.200000
         WinLeft=0.050000
         WinWidth=0.900000
         WinHeight=0.700000
     End Object
     MyHeader=GUIHeader'ArenaMut.ArenaMenu.DaBeegHeader'

     Begin Object Class=GUIListBox Name=UsedWeaponList
         bVisibleWhenEmpty=True
         OnCreateComponent=UsedWeaponList.InternalOnCreateComponent
         IniOption="@Internal"
         Hint="Used Weapons. Drag, Double click or use Remove button to take them out the match."
         WinTop=0.270000
         WinLeft=0.550000
         WinWidth=0.350000
         WinHeight=0.425000
         RenderWeight=0.510000
         TabOrder=1
     End Object
     lb_UsedWeapons=GUIListBox'ArenaMut.ArenaMenu.UsedWeaponList'

     Begin Object Class=GUIListBox Name=UnusedWeaponList
         bVisibleWhenEmpty=True
         bSorted=True
         OnCreateComponent=UnusedWeaponList.InternalOnCreateComponent
         IniOption="@Internal"
         Hint="Spare Weapons. Drag, Double click or use Add button to put them in the match."
         WinTop=0.270000
         WinLeft=0.100000
         WinWidth=0.350000
         WinHeight=0.425000
         RenderWeight=0.510000
         TabOrder=1
     End Object
     lb_UnusedWeapons=GUIListBox'ArenaMut.ArenaMenu.UnusedWeaponList'

     Begin Object Class=moCheckBox Name=RandomCheck
         ComponentJustification=TXTA_Left
         CaptionWidth=0.900000
         Caption="One Random Weapon"
         OnCreateComponent=RandomCheck.InternalOnCreateComponent
         IniOption="@Internal"
         Hint="Gives players one random weapon from the list of weapons you have chosen."
         WinTop=0.800000
         WinLeft=0.550000
         WinWidth=0.350000
         WinHeight=0.040000
     End Object
     ch_Random=moCheckBox'ArenaMut.ArenaMenu.RandomCheck'

     Begin Object Class=moCheckBox Name=PerSpawnCheck
         ComponentJustification=TXTA_Left
         CaptionWidth=0.900000
         Caption="Random Per Spawn"
         OnCreateComponent=PerSpawnCheck.InternalOnCreateComponent
         IniOption="@Internal"
         Hint="Players get a different random weapon from the chosen list each time they spawn."
         WinTop=0.800000
         WinLeft=0.100000
         WinWidth=0.350000
         WinHeight=0.040000
     End Object
     ch_PerSpawn=moCheckBox'ArenaMut.ArenaMenu.PerSpawnCheck'

     Headings(0)="Killing Floor Standard"
     Headings(1)="Other"
     bRenderWorld=True
     bAllowedAsLast=True
     OnClose=ArenaMenu.InternalOnClose
     OnKeyEvent=ArenaMenu.InternalOnKeyEvent
}
