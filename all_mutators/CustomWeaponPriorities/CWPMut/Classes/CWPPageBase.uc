class CWPPageBase extends LargeWindow;

var CWPInteraction MyInteraction;
var automated moComboBox co_InventoryGroup, co_PerkName;
var automated moCheckbox ch_OnlyInventory;
var automated GUIListBox lb_Weapons;

function Inventory GetPawnInventory() {
	if (PlayerOwner().Pawn != None)
		return PlayerOwner().Pawn.Inventory;
	else
		return None;
}

function KFWeapon GetPawnWeapon() {
	if (PlayerOwner().Pawn != None)
		return KFWeapon(PlayerOwner().Pawn.Weapon);
	else
		return None;
}

function byte GetPerkIndex() {
	local KFPlayerReplicationInfo PRI;

	PRI = KFPlayerReplicationInfo(PlayerOwner().PlayerReplicationInfo);
	if (PRI != None && PRI.ClientVeteranSkill != None)
		return PRI.ClientVeteranSkill.default.perkIndex + 1;
	else
		return 0;
}

function string GetSizingCaption() {
	local int i;
	local string S;

	for (i = 0; i < Controls.Length; i++)
		if (GUIButton(Controls[i]) != None)
			if (S == "" || Len(GUIButton(Controls[i]).Caption) > Len(S))
				S = GUIButton(Controls[i]).Caption;

	return S;
}

function InitComponent(GUIController MyController, GUIComponent MyOwner) {
	local GUIButton B;
	local int i;
	local string S;
	
	Super.InitComponent(MyController, MyOwner);

	S = GetSizingCaption();
	for (i = 0; i < Controls.length; i++) {
		B = GUIButton(Controls[i]);
		if (B != None) {
			B.bAutoSize = true;
			B.SizingCaption = S;
			B.AutoSizePadding.HorzPerc = 0.25;
			B.AutoSizePadding.VertPerc = 0.5;
		}
	}
	
	if (co_PerkName != None) {
		co_PerkName.AddItem("All perks");
		co_PerkName.AddItem("Medic");
		co_PerkName.AddItem("Support Specialist");
		co_PerkName.AddItem("Sharpshooter");
		co_PerkName.AddItem("Commando");
		co_PerkName.AddItem("Berserker");
		co_PerkName.AddItem("Firebug");
		co_PerkName.AddItem("Demolitions");
	}
	
	if (lb_Weapons != None)
		lb_Weapons.List.OnMouseRelease = WeaponsOnMouseRelease;
}

function InternalOnOpen() {
	local KFInvasionLoginMenu LoginMenu;
	local CWPMidGamePanel MyPanel;
	
	LoginMenu = KFInvasionLoginMenu(Controller.FindMenuByClass(class'KFGui.KFInvasionLoginMenu'));

	if (LoginMenu != None)
		MyPanel = CWPMidGamePanel(LoginMenu.c_Main.FindPanelClass(class'CWPMut.CWPMidGamePanel'));

	if (MyPanel != None)
		MyInteraction = MyPanel.MyInteraction;
	
	if (MyInteraction == None)
		Controller.CloseMenu();
	else
		co_PerkName.SetIndex(0);
}

function WeaponsOnMouseRelease(GUIComponent Sender) {
	lb_Weapons.List.InternalOnMouseRelease(Sender);
	
	if (lb_Weapons.List.SelectedItems.length > 0)
		lb_Weapons.List.SelectedItems.length = 0;
}

defaultproperties {
	WinTop=0.100000
	WinLeft=0.100000
	WinWidth=0.800000
	WinHeight=0.800000
	bAcceptsInput=False
	OnOpen=CWPPageBase.InternalOnOpen
}