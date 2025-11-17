class CWPPageGroups extends CWPPageBase;

var automated GUISectionBackground i_BGTopLeft, i_BGBottomLeft, i_BGTopRight, i_BGBottomRight;
var automated moComboBox co_GroupName;
var automated GUIListBox lb_GroupWeapons;
var automated GUIButton b_Add, b_AddAll, b_Remove, b_RemoveAll;

var string lastRemovedExtra;

function InitComponent(GUIController MyController, GUIComponent MyOwner) {
	Super.InitComponent(MyController, MyOwner);

	co_InventoryGroup.AddItem("All groups");
	co_InventoryGroup.AddItem("Melee");
	co_InventoryGroup.AddItem("Secondary");
	co_InventoryGroup.AddItem("Primary");
	co_InventoryGroup.AddItem("Specialty");
	co_InventoryGroup.AddItem("Tools");
	
	co_GroupName.AddItem("Perk-neutral");
	co_GroupName.AddItem("Medic");
	co_GroupName.AddItem("Support Specialist");
	co_GroupName.AddItem("Sharpshooter");
	co_GroupName.AddItem("Commando");
	co_GroupName.AddItem("Berserker");
	co_GroupName.AddItem("Firebug");
	co_GroupName.AddItem("Demolitions");
	
	lb_Weapons.List.bDropSource = true;
	lb_Weapons.List.bDropTarget = false;
	lb_Weapons.List.bMultiSelect = false;
	lb_GroupWeapons.List.bSorted = true;

	lb_Weapons.List.OnDblClick = AddOnClick;
	
	lb_GroupWeapons.List.OnDblClick = RemoveOnClick;
	lb_GroupWeapons.List.OnMouseRelease = GroupOnMouseRelease;
	lb_GroupWeapons.List.OnDragDrop = GroupOnDragDrop;
	lb_GroupWeapons.List.bDropSource = true;
	lb_GroupWeapons.List.bDropTarget = true;
	lb_GroupWeapons.List.bMultiSelect = false;
	lb_GroupWeapons.List.bSorted = false;

	i_BGTopLeft.ManageComponent(co_InventoryGroup);
	i_BGTopLeft.ManageComponent(co_PerkName);
	i_BGTopLeft.ManageComponent(ch_OnlyInventory);
	i_BGBottomLeft.ManageComponent(lb_Weapons);
	i_BGTopRight.ManageComponent(co_GroupName);
	i_BGBottomRight.ManageComponent(lb_GroupWeapons);
}

///////////////////////
//		LIST		//
/////////////////////
function bool MatchesPerkName(class<KFWeapon> aWeaponClass) {
	local byte perkIndex;
	
	perkIndex = co_PerkName.GetIndex();
	if (perkIndex == 0)
		return true;
	
	if (aWeaponClass.default.inventoryGroup == MyInteraction.MAX_Group)
		return false;

	return class<KFWeaponPickup>(aWeaponClass.default.PickupClass).default.correspondingPerkIndex == --perkIndex;
}

/* Check whether a given weapon is in the lb_GroupWeapons list. */
function bool NotInCurrentGroup(class<KFWeapon> aWeapon) {
	local byte i, j;
	
	j = aWeapon.default.priority;
	for (i = 0; i < lb_GroupWeapons.List.itemCount; i++)
		if (j == byte(lb_GroupWeapons.List.GetExtraAtIndex(i)))
			return false;

	return true;
}

function UpdatePerkArray() {
	local int i, j;
	
	i = co_GroupName.GetIndex() - 1;
	if (i < 0)
		i = MyInteraction.INDEX_PerkNeutral;
		
	MyInteraction.PerkArrays[i].Weapons.length = 0;
	for (j = 0; j < lb_GroupWeapons.List.itemCount; j++)
		MyInteraction.PerkArrays[i].Weapons[j] = MyInteraction.GetClassByPriority(lb_GroupWeapons.List.GetExtraAtIndex(j));
	
	MyInteraction.SaveConfig();
}

function UpdateGroupList() {
	local class<KFWeapon> WC;
	local int i, j, k;

	lb_GroupWeapons.List.Clear();

	i = co_GroupName.GetIndex() - 1;
	if (i < 0)
		i = MyInteraction.INDEX_PerkNeutral;
		
	k = MyInteraction.PerkArrays[i].Weapons.length;
	for (j = 0; j < k; j++) {
		WC = MyInteraction.PerkArrays[i].Weapons[j];
		lb_GroupWeapons.List.Add(WC.default.ItemName,, string(WC.default.priority));
	}
}

function UpdateWeaponList() {
	local KFWeapon W;
	local class<KFWeapon> WC;
	local Inventory Inv, PawnInv;
	local int i, groupIndex;
	
	lb_Weapons.List.Clear();
	
	groupIndex = co_InventoryGroup.GetIndex();
	if (ch_OnlyInventory.IsChecked()) {
		PawnInv = GetPawnInventory();
		for (Inv = PawnInv; Inv != None; Inv = Inv.Inventory) {
			W = KFWeapon(Inv);
			if (W != None && Frag(W) == None && (groupIndex == 0 || W.default.inventoryGroup == groupIndex) && (groupIndex == 5 || MatchesPerkName(W.Class)) && NotInCurrentGroup(W.Class)) {
				WC = MyInteraction.GetClassByPriority(W.default.priority);
				lb_Weapons.List.Add(WC.default.ItemName,, string(W.default.priority));
			}
		}
	}
	else {
		for (i = 0; i < MyInteraction.LevelWeapons.length; i++) {
			WC = MyInteraction.GetClassByPriority(i);
			if (WC != None && class<Frag>(WC) == None && (groupIndex == 0 || WC.default.inventoryGroup == groupIndex) && (groupIndex == 5 || MatchesPerkName(WC)) && NotInCurrentGroup(WC))
				lb_Weapons.List.Add(WC.default.ItemName,, string(WC.default.priority));
		}
	}

	lb_Weapons.List.SortList();
	lb_Weapons.List.SetIndex(0);
}

function SelectLastRemoved() {
	local byte i;

	if (lb_Weapons.List.itemCount == 0)
		return;

	if (lastRemovedExtra != "")
		for (i = 0; i < lb_Weapons.List.itemCount; i++)
			if (lb_Weapons.List.GetExtraAtIndex(i) ~= lastRemovedExtra)
				break;
	
	lb_Weapons.List.SetIndex(i);
}

///////////////////////////
//		DELEGATES		//
/////////////////////////
function bool InternalOnPreDraw(Canvas C) {
	local float w, wB, h, h1, h2, hB, x1, x2, y1, y2, center, spacing, padding;

	// BG SECTIONS
	padding = 0.07;
	w = ActualWidth() * (0.5 - padding);
	spacing = w / 100;
	hB = b_AddAll.ActualHeight();
	h = ActualHeight() * (1.0 - 2 * padding) - hB - spacing;
	h1 = h * 0.36;
	h2 = h - h1 - spacing;
	center = ActualLeft() + ActualWidth() / 2;
	x1 = center - w - spacing;
	x2 = center + spacing;
	y1 = ActualTop() + ActualHeight() * padding;
	y2 = y1 + h1 + spacing;
	
	i_BGTopLeft.SetPosition(x1, y1, w, h1, true);
	i_BGBottomLeft.SetPosition(x1, y2, w, h2, true);
	i_BGTopRight.SetPosition(x2, y1, w, h1, true);
	i_BGBottomRight.SetPosition(x2, y2, w, h2, true);
	
	// BUTTONS
	wB = b_AddAll.ActualWidth();
	y2 += h2 + spacing;
	
	b_AddAll.SetPosition(x1, y2, wB, hB, true);
	b_Add.SetPosition(center - spacing * 2 - wB, y2, wB, hB, true);
	b_Remove.SetPosition(x2, y2, wB, hB, true);
	
	x2 += w - wB;
	
	b_RemoveAll.SetPosition(x2, y2, wB, hB, true);

	return Super.InternalOnPreDraw(C);
}

function InternalOnOpen() {
	Super.InternalOnOpen();

	ch_OnlyInventory.SetComponentValue(true, true);
	co_InventoryGroup.SetIndex(0);
	co_GroupName.SetIndex(MyInteraction.PerkToListIndex());

	UpdateGroupList();
	UpdateWeaponList();
}

function InternalOnChange(GUIComponent Sender) {
	switch (Sender) {
		case co_InventoryGroup:
		case co_PerkName:
		case ch_OnlyInventory:
		case co_GroupName:
			UpdateGroupList();
			UpdateWeaponList();
			break;
	}
}

function bool AddOnClick(GUIComponent Sender) {
	local GUIList GL, WL;
	local array<GUIListElem> PendingElements;
	local int i;

	GL = lb_GroupWeapons.List;
	WL = lb_Weapons.List;

	if (!WL.IsValid())
		return false;

	PendingElements = WL.GetPendingElements(true);

	for (i = 0; i < PendingElements.length; i++) {
		WL.RemoveElement(PendingElements[i],, true);
		GL.AddElement(PendingElements[i]);
	}

	WL.ClearPendingElements();
	if (WL.IsValid())
		WL.SetIndex(WL.index);
	else if (WL.itemCount > 0)
		WL.SetIndex(WL.itemCount - 1);

	WL.Sort();

	if (GL.itemCount > 0);
		GL.SetIndex(GL.itemCount - 1);

	UpdatePerkArray();
	
	return true;
}

function bool AddAllOnClick(GUIComponent Sender) {
	local GUIList GL, WL;
	local GUIListElem TempElem;
	local int oldCount;

	GL = lb_GroupWeapons.List;
	WL = lb_Weapons.List;

	if (WL.itemCount == 0)
		return false;

	oldCount = GL.itemCount;
	while (WL.itemCount > 0) {
		TempElem = WL.Elements[0];
		WL.RemoveElement(TempElem,, true);
		GL.AddElement(TempElem);
	}

	UpdatePerkArray();
	if (oldCount < GL.itemCount)
		GL.SetIndex(oldCount - 1);
	
	return true;
}

function bool RemoveOnClick(GUIComponent Sender) {
	local GUIList GL;
	local int lastRemovedIndex;

	GL = lb_GroupWeapons.List;

	if (!GL.IsValid())
		return false;

	lastRemovedIndex = GL.index;
	lastRemovedExtra = GL.GetExtra();
	GL.Remove(GL.index, 1, true);

	if (!GL.IsValidIndex(lastRemovedIndex) && GL.itemCount > 0)
		lastRemovedIndex = GL.itemCount - 1;

	UpdatePerkArray();
	UpdateWeaponList();
	SelectLastRemoved();
	GL.SetIndex(lastRemovedIndex);
	
	return true;
}

function bool RemoveAllOnClick(GUIComponent Sender) {
	local GUIList GL, WL;
	local int oldIndex;

	GL = lb_GroupWeapons.List;
	WL = lb_Weapons.List;
	if (GL.itemCount == 0)
		return false;

	lastRemovedExtra = "";
	GL.Remove(0, GL.itemCount, true);

	if (WL.IsValid())
		oldIndex = WL.index;
	else
		oldIndex = WL.itemCount - 1;
	
	UpdatePerkArray();
	UpdateWeaponList();
	WL.SetIndex(oldIndex);
	
	return true;
}

///////////////////////////////
//		LIST DELEGATES		//
/////////////////////////////
function GroupOnMouseRelease(GUIComponent Sender) {
	lb_GroupWeapons.List.InternalOnMouseRelease(Sender);
	
	if (lb_GroupWeapons.List.SelectedItems.length > 0) {
		RemoveOnClick(Sender);
		lb_GroupWeapons.List.SelectedItems.length = 0;
	}	
}

function bool GroupOnDragDrop(GUIComponent Sender) {
	local bool bRes;

	bRes = lb_GroupWeapons.List.InternalOnDragDrop(Sender);
	if (bRes)
		UpdatePerkArray();

	return bRes;
}

defaultproperties {
	Begin Object Class=GUISectionBackground Name=BGTopLeft
		bFillClient=True
		Caption="Filter Available Weapons"
		OnPreDraw=BGTopLeft.InternalPreDraw
	End Object
	i_BGTopLeft=GUISectionBackground'CWPPageGroups.BGTopLeft'

	Begin Object Class=GUISectionBackground Name=BGBottomLeft
		bFillClient=True
		Caption="Available Weapons"
		OnPreDraw=BGBottomLeft.InternalPreDraw
	End Object
	i_BGBottomLeft=GUISectionBackground'CWPPageGroups.BGBottomLeft'
	
	Begin Object Class=GUISectionBackground Name=BGTopRight
		bFillClient=True
		Caption="Selected Custom Group"
		OnPreDraw=BGTopRight.InternalPreDraw
	End Object
	i_BGTopRight=GUISectionBackground'CWPPageGroups.BGTopRight'
	
	Begin Object Class=GUISectionBackground Name=BGBottomRight
		bFillClient=True
		Caption="Selected Weapons"
		OnPreDraw=BGBottomRight.InternalPreDraw
	End Object
	i_BGBottomRight=GUISectionBackground'CWPPageGroups.BGBottomRight'
	
	Begin Object Class=moComboBox Name=InventoryGroup
		bReadOnly=True
		Caption="By group";
		Hint="Select an inventory group.";
		TabOrder=1
		OnCreateComponent=InventoryGroup.InternalOnCreateComponent
		OnChange=CWPPageGroups.InternalOnChange
	End Object
	co_InventoryGroup=moComboBox'CWPPageGroups.InventoryGroup'
	
	Begin Object Class=moComboBox Name=PerkName
		bReadOnly=True
		Caption="By perk";
		Hint="Select a perk.";
		TabOrder=2
		OnCreateComponent=PerkName.InternalOnCreateComponent
		OnChange=CWPPageGroups.InternalOnChange
	End Object
	co_PerkName=moComboBox'CWPPageGroups.PerkName'
	
	Begin Object Class=moCheckBox Name=OnlyInventory
		Caption="Current inventory";
		Hint="Show only the current inventory.";
		TabOrder=3
		OnCreateComponent=OnlyInventory.InternalOnCreateComponent
		OnChange=CWPPageGroups.InternalOnChange
	End Object
	ch_OnlyInventory=moCheckBox'CWPPageGroups.OnlyInventory'
	
	Begin Object Class=GUIListBox Name=WeaponsList
		Hint="Available weapons sorted alphabetically."
		bVisibleWhenEmpty=True
		RenderWeight=0.510000
		TabOrder=4
		OnCreateComponent=WeaponsList.InternalOnCreateComponent
	End Object
	lb_Weapons=GUIListBox'CWPPageGroups.WeaponsList'

	Begin Object Class=GUIButton Name=AddAllButton
		Caption="Add all"
		Hint="Add all weapons to the group."
		TabOrder=5
		WinWidth=0.147268
		WinHeight=0.048769
		bBoundToParent=True
		bScaleToParent=True
		OnClick=CWPPageGroups.AddAllOnClick
	End Object
	b_AddAll=GUIButton'CWPPageGroups.AddAllButton'
	
	Begin Object Class=GUIButton Name=AddButton
		Caption="Add"
		Hint="Add the selected weapon to the group."
		TabOrder=6
		bBoundToParent=True
		bScaleToParent=True
		OnClick=CWPPageGroups.AddOnClick
	End Object
	b_Add=GUIButton'CWPPageGroups.AddButton'
	
	Begin Object Class=moComboBox Name=GroupName
		bReadOnly=True
		Caption="Custom group"
		Hint="Select a weapon group corresponding to one of the perks."
		TabOrder=7
		OnCreateComponent=GroupName.InternalOnCreateComponent
		OnChange=CWPPageGroups.InternalOnChange
	End Object
	co_GroupName=moComboBox'CWPPageGroups.GroupName'
	
	Begin Object Class=GUIListBox Name=GroupWeaponsList
		Hint="Drag and drop weapons to change their order within the selected group."
		bVisibleWhenEmpty=True
		RenderWeight=0.510000
		TabOrder=8
		OnCreateComponent=GroupWeaponsList.InternalOnCreateComponent
		OnChange=CWPPageGroups.InternalOnChange
	End Object
	lb_GroupWeapons=GUIListBox'CWPPageGroups.GroupWeaponsList'
	
	Begin Object Class=GUIButton Name=RemoveButton
		Caption="Remove"
		Hint="Remove the selected weapon from the group."
		TabOrder=9
		bBoundToParent=True
		bScaleToParent=True
		OnClick=CWPPageGroups.RemoveOnClick
	End Object
	b_Remove=GUIButton'CWPPageGroups.RemoveButton'
	
	Begin Object Class=GUIButton Name=RemoveAllButton
		Caption="Remove all"
		Hint="Remove all weapons from the group."
		TabOrder=10
		bBoundToParent=True
		bScaleToParent=True
		OnClick=CWPPageGroups.RemoveAllOnClick
	End Object
	b_RemoveAll=GUIButton'CWPPageGroups.RemoveAllButton'
	
	WindowName="Custom Weapon Groups"
	OnOpen=CWPPageGroups.InternalOnOpen
}