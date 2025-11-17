class CWPPagePriorities extends CWPPageBase;

var automated GUISectionBackground i_BGLeft, i_BGTopRight, i_BGBottomRight;
var automated GUIImage i_ItemImage;
var automated GUIButton b_Up, b_Down, b_Defaults, b_ClearAll;

function int GetGroupIndex() {
	local KFWeapon W;
	
	W = GetPawnWeapon();
	if (W != None)
		return W.default.inventoryGroup - 1;
	else
		return 0;
}

function InitComponent(GUIController MyController, GUIComponent MyOwner) {
	Super.InitComponent(MyController, MyOwner);

	co_InventoryGroup.AddItem("Melee");
	co_InventoryGroup.AddItem("Secondary");
	co_InventoryGroup.AddItem("Primary");
	co_InventoryGroup.AddItem("Specialty");
	co_InventoryGroup.AddItem("Tools");
	
	lb_Weapons.List.CompareItem = CompareWeaponPriority;
	lb_Weapons.List.OnDragDrop = WeaponsOnDragDrop;
	lb_Weapons.List.bDropSource = true;
	lb_Weapons.List.bDropTarget = true;
	lb_Weapons.List.bMultiSelect = false;

	i_BGLeft.ManageComponent(lb_Weapons);
	i_BGTopRight.ManageComponent(i_ItemImage);
	i_BGBottomRight.ManageComponent(co_InventoryGroup);
	i_BGBottomRight.ManageComponent(co_PerkName);
	i_BGBottomRight.ManageComponent(ch_OnlyInventory);
}

///////////////////////
//		LIST		//
/////////////////////
/* Swap only Item, leaving ExtraData the same. */
function SilentSwapWeapons(int locA, int locB) {
	local byte i, j;
	local string TempItem;

	if (lb_Weapons.List.IsValidIndex(locA) && lb_Weapons.List.IsValidIndex(locB)) {
		i = byte(lb_Weapons.List.GetExtraAtIndex(locA));
		j = byte(lb_Weapons.List.GetExtraAtIndex(locB));
		MyInteraction.SwapPriorities(i, j);
		
		TempItem = lb_Weapons.List.GetItemAtIndex(locA);
		lb_Weapons.List.SetItemAtIndex(locA, lb_Weapons.List.GetItemAtIndex(locB));
		lb_Weapons.List.SetItemAtIndex(locB, TempItem);

		lb_Weapons.List.SetIndex(locB);
	}
}

function SwapWeapons(int locA, int locB) {
	SilentSwapWeapons(locA, locB);
	MyInteraction.UpdatePawnWeapons();
}

function UpdateWeaponList() {
	local KFWeapon W;
	local class<KFWeapon> WC;
	local Inventory Inv, PawnInv;
	local int i, groupIndex, perkIndex;
	
	lb_Weapons.List.Clear();
	
	groupIndex = co_InventoryGroup.GetIndex() + 1;
	perkIndex = co_PerkName.GetIndex() - 1;
	if (ch_OnlyInventory.IsChecked()) {
		PawnInv = GetPawnInventory();
		for (Inv = PawnInv; Inv != None; Inv = Inv.Inventory) {
			W = KFWeapon(Inv);
			if (W != None && W.default.inventoryGroup == groupIndex && (perkIndex == -1 || groupIndex == 5 || perkIndex == class<KFWeaponPickup>(W.default.PickupClass).default.correspondingPerkIndex)) {
				WC = MyInteraction.GetClassByPriority(W.default.priority);
				lb_Weapons.List.Add(WC.default.ItemName,, string(W.default.priority));
			}
		}
	}
	else {
		for (i = 0; i < MyInteraction.LevelWeapons.length; i++) {
			WC = MyInteraction.GetClassByPriority(i);
			if (WC.default.inventoryGroup == groupIndex && (perkIndex == -1 || groupIndex == 5 || perkIndex == class<KFWeaponPickup>(WC.default.PickupClass).default.correspondingPerkIndex))
				lb_Weapons.List.Add(WC.default.ItemName,, string(WC.default.priority));
		}
	}

	if (lb_Weapons.List.itemCount > 0) {
		lb_Weapons.List.SortList();
		lb_Weapons.List.SetIndex(0);
	}
}

function UpdateImage() {
	local byte i;
	
	if (lb_Weapons.List.itemCount < 1) {
		i_ItemImage.Image = None;
	}
	else {
		i = byte(lb_Weapons.List.GetExtra());
		if (MyInteraction.LevelWeapons.length > 0 && i < MyInteraction.LevelWeapons.length)
			i_ItemImage.Image = MyInteraction.GetClassByPriority(i).default.TraderInfoTexture;
		else
			i_ItemImage.Image = None;
	}
}


///////////////////////////
//		DELEGATES		//
/////////////////////////
function bool InternalOnPreDraw(Canvas C) {
	local float w, h1, h2, h3, hB, x1, x2, y1, y2, center, spacing, padding;

	padding = 0.07;
	w = ActualWidth() * (0.5 - padding);
	spacing = w / 100;
	hB = b_Up.ActualHeight();
	h1 = ActualHeight() * (1.0 - 2 * padding) - 2 * (hB + spacing);
	h2 = h1 * 0.54;
	h3 = h1 - h2 - spacing;
	center = ActualLeft() + ActualWidth() / 2;
	x1 = center - w - spacing;
	x2 = center + spacing;
	y1 = ActualTop() + ActualHeight() * padding;
	y2 = y1 + h2 + spacing;
	
	i_BGLeft.SetPosition(x1, y1, w, h1, true);
	i_BGTopRight.SetPosition(x2, y1, w, h2, true);
	i_BGBottomRight.SetPosition(x2, y2, w, h3, true);
	
	w = b_Up.ActualWidth();
	x2 = center - 2 * spacing - w;
	y1 += h1 + spacing;
	y2 = y1 + hB + spacing;
	
	b_Up.SetPosition(x1, y1, w, hB, true);
	b_Down.SetPosition(x1, y2, w, hB, true);
	b_Defaults.SetPosition(x2, y1, w, hB, true);
	b_ClearAll.SetPosition(x2, y2, w, hB, true);

	return Super.InternalOnPreDraw(C);
}

function InternalOnOpen() {
	Super.InternalOnOpen();

	co_InventoryGroup.SetIndex(GetGroupIndex());
	if (PlayerOwner().Pawn != None)
		ch_OnlyInventory.SetComponentValue(true, true);
	else
		ch_OnlyInventory.SetComponentValue(false, true);

	UpdateWeaponList();
}

function InternalOnChange(GUIComponent Sender) {
	switch (Sender) {
		case co_InventoryGroup:
		case co_PerkName:
		case ch_OnlyInventory:
			UpdateWeaponList();
			break;
		case lb_Weapons:
			UpdateImage();
			break;
	}
}

function bool ButtonClicked(GUIComponent Sender) {
	switch (Sender) {
		case b_Defaults:
			MyInteraction.DefaultPriorities();
			UpdateWeaponList();
			break;
		case b_ClearAll:
			Controller.OpenMenu("CWPMut.CWPPageQuit");
			break;
	}

	return true;
}

///////////////////////////////
//		LIST DELEGATES		//
/////////////////////////////
function int CompareWeaponPriority(GUIListElem ElemA, GUIListElem ElemB) {
	local int priorityDiff;

	priorityDiff = byte(ElemB.ExtraStrData) - byte(ElemA.ExtraStrData);
	if (priorityDiff != 0)
		return priorityDiff;
	else
		return StrCmp(ElemA.Item, ElemB.Item);
}

function bool DecreasePriority(GUIComponent Sender) {
	if (lb_Weapons.List.itemCount > 1 && lb_Weapons.List.index < lb_Weapons.List.itemCount - 1)
		SwapWeapons(lb_Weapons.List.index, lb_Weapons.List.index + 1);

	return true;
}

function bool IncreasePriority(GUIComponent Sender) {
	if (lb_Weapons.List.itemCount > 1 && lb_Weapons.List.index > 0)
		SwapWeapons(lb_Weapons.List.index, lb_Weapons.List.index - 1);

	return true;
}

function bool WeaponsOnDragDrop(GUIComponent Sender) {
	local GUIList WL;
	local int i;

	WL = lb_Weapons.List;
	if (Controller.DropSource != WL)
		return false;

	if (!WL.IsValidIndex(WL.dropIndex))
		WL.dropIndex = WL.itemCount - 1;
	
	if (WL.dropIndex != WL.index && WL.SelectedItems.length > 0) {
		if (WL.SelectedItems[0] < WL.dropIndex)
			for (i = WL.SelectedItems[0]; i < WL.dropIndex; i++)
				SilentSwapWeapons(i, i + 1);
		else
			for (i = WL.SelectedItems[0]; i > WL.dropIndex; i--)
				SilentSwapWeapons(i - 1, i);
		
		WL.SetIndex(WL.dropIndex);
		MyInteraction.UpdatePawnWeapons();

		return true;
	}

	return false;
}

defaultproperties {
	Begin Object Class=GUISectionBackground Name=BGLeft
		bFillClient=True
		Caption="Available Weapons"
		OnPreDraw=BGLeft.InternalPreDraw
	End Object
	i_BGLeft=GUISectionBackground'CWPPagePriorities.BGLeft'

	Begin Object Class=GUISectionBackground Name=BGTopRight
		bFillClient=True
		Caption="Selected Weapon"
		OnPreDraw=BGTopRight.InternalPreDraw
	End Object
	i_BGTopRight=GUISectionBackground'CWPPagePriorities.BGTopRight'
	
	Begin Object Class=GUISectionBackground Name=BGBottomRight
		bFillClient=True
		Caption="Filter Available Weapons"
		OnPreDraw=BGBottomRight.InternalPreDraw
	End Object
	i_BGBottomRight=GUISectionBackground'CWPPagePriorities.BGBottomRight'
	
	Begin Object Class=GUIListBox Name=WeaponsList
		Hint="Available weapons sorted by priority."
		bVisibleWhenEmpty=True
		RenderWeight=0.510000
		TabOrder=1
		OnCreateComponent=WeaponsList.InternalOnCreateComponent
		OnChange=CWPPagePriorities.InternalOnChange
	End Object
	lb_Weapons=GUIListBox'CWPPagePriorities.WeaponsList'

	Begin Object Class=GUIButton Name=UpButton
		Caption="Raise priority"
		Hint="Increase the priority of the selected weapon."
		TabOrder=2
		WinWidth=0.147268
		WinHeight=0.048769
		bBoundToParent=True
		bScaleToParent=True
		bNeverFocus=True
		OnClick=CWPPagePriorities.IncreasePriority
		OnKeyEvent=UpButton.InternalOnKeyEvent
	End Object
	b_Up=GUIButton'CWPPagePriorities.UpButton'

	Begin Object Class=GUIButton Name=DownButton
		Caption="Lower priority"
		Hint="Decrease the priority of the selected weapon."
		TabOrder=3
		bBoundToParent=True
		bScaleToParent=True
		bNeverFocus=True
		OnClick=CWPPagePriorities.DecreasePriority
		OnKeyEvent=DownButton.InternalOnKeyEvent
	End Object
	b_Down=GUIButton'CWPPagePriorities.DownButton'
	
	Begin Object Class=GUIButton Name=DefaultsButton
		Caption="Defaults"
		Hint="Use the default priorities to sort the list."
		TabOrder=4
		bBoundToParent=True
		bScaleToParent=True
		bNeverFocus=True
		OnClick=CWPPagePriorities.ButtonClicked
		OnKeyEvent=DefaultsButton.InternalOnKeyEvent
	End Object
	b_Defaults=GUIButton'CWPPagePriorities.DefaultsButton'
	
	Begin Object Class=GUIButton Name=ClearAllButton
		Caption="Clear all"
		Hint="Clear all custom priorities, switch to the default functions and remove the tab."
		TabOrder=5
		bBoundToParent=True
		bScaleToParent=True
		bNeverFocus=True
		OnClick=CWPPagePriorities.ButtonClicked
		OnKeyEvent=ClearAllButton.InternalOnKeyEvent
	End Object
	b_ClearAll=GUIButton'CWPPagePriorities.ClearAllButton'
	
	Begin Object Class=GUIImage Name=ItemImage
		ImageStyle=ISTY_Justified
		ImageAlign=IMGA_Center
		RenderWeight=2.0
		bBoundToParent=True
		bScaleToParent=True
	End Object
	i_ItemImage=GUIImage'CWPPagePriorities.ItemImage'
	
	Begin Object Class=moComboBox Name=InventoryGroup
		bReadOnly=True
		Caption="By group";
		Hint="Select an inventory group.";
		TabOrder=6
		OnCreateComponent=InventoryGroup.InternalOnCreateComponent
		OnChange=CWPPagePriorities.InternalOnChange
	End Object
	co_InventoryGroup=moComboBox'CWPPagePriorities.InventoryGroup'
	
	Begin Object Class=moComboBox Name=PerkName
		bReadOnly=True
		Caption="By perk";
		Hint="Select a perk.";
		TabOrder=7
		OnCreateComponent=PerkName.InternalOnCreateComponent
		OnChange=CWPPagePriorities.InternalOnChange
	End Object
	co_PerkName=moComboBox'CWPPagePriorities.PerkName'
	
	Begin Object Class=moCheckBox Name=OnlyInventory
		Caption="Current inventory";
		Hint="Show only the current inventory.";
		TabOrder=8
		OnCreateComponent=OnlyInventory.InternalOnCreateComponent
		OnChange=CWPPagePriorities.InternalOnChange
	End Object
	ch_OnlyInventory=moCheckBox'CWPPagePriorities.OnlyInventory'
	
	WindowName="Weapon Priorities"
	OnOpen=CWPPagePriorities.InternalOnOpen
}