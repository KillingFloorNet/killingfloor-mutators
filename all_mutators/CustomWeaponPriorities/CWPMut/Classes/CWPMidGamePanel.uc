class CWPMidGamePanel extends CWPBlankPanel;

const ALPHA_Disabled = 64;
const ALPHA_Enabled = 255;

var CWPInteraction MyInteraction;
var automated GUISectionBackground i_BGLeft, i_BGTopRight, i_BGBottomRight;
var automated KFIndexedGUIImage i_CurrentIcon;
var automated array<KFIndexedGUIImage> i_PerkIcons;
var automated GUIButton b_EditPriorities, b_EditGroups;
var automated moCheckbox ch_DefaultSwitch, ch_PerkedFirst, ch_EmptyLast, ch_IgnoreRequired, ch_SwitchOnPickup, ch_DefaultPrevNext, ch_MatchCurrent;

function InitComponent(GUIController MyController, GUIComponent MyOwner) {
	local int i;

	Super.InitComponent(MyController, MyOwner);

	for (i = 0; i < i_PerkIcons.length; i++) {
		if (i_PerkIcons[i] != None) {
			i_PerkIcons[i].OnClick = ButtonClicked;
			i_PerkIcons[i].index = i;
			i_PerkIcons[i].Image = GetTextureByIndex(i);
		}
	}
	
	i_BGLeft.ManageComponent(ch_DefaultSwitch);
	i_BGLeft.ManageComponent(ch_PerkedFirst);
	i_BGLeft.ManageComponent(ch_EmptyLast);
	i_BGLeft.ManageComponent(ch_IgnoreRequired);
	i_BGLeft.ManageComponent(ch_SwitchOnPickup);
	
	i_BGBottomRight.ManageComponent(ch_DefaultPrevNext);
	i_BGBottomRight.ManageComponent(ch_MatchCurrent);
}

function Texture GetTextureByIndex(int aIndex) {
	if (aIndex < 0 || aIndex >= class'KFGameType'.default.LoadedSkills.length)
		return Texture'KillingFloor2HUD.Perk_Icons.No_Perk_Icon';
	else
		return class'KFGameType'.default.LoadedSkills[aIndex].default.OnHUDIcon;
}

function UpdateCheckboxVisibility() {
	if (ch_DefaultSwitch.IsChecked()) {
		ch_PerkedFirst.DisableMe();
		ch_EmptyLast.DisableMe();
		ch_IgnoreRequired.DisableMe();
	}
	else {
		ch_PerkedFirst.EnableMe();
		ch_EmptyLast.EnableMe();
		ch_IgnoreRequired.EnableMe();
	}
	
	if (ch_DefaultPrevNext.IsChecked())
		ch_MatchCurrent.DisableMe();
	else
		ch_MatchCurrent.EnableMe();
}

function UpdateIconVisibility() {
	local int i, iconAlpha;
	
	iconAlpha = ALPHA_Enabled;
	
	if (ch_DefaultPrevNext.IsChecked()) {
		iconAlpha = ALPHA_Disabled;
		i_CurrentIcon.ImageColor.A = ALPHA_Disabled;
	}
	else {
		i_CurrentIcon.ImageColor.A = ALPHA_Enabled;
	}
		
	if (ch_MatchCurrent.IsChecked()) {
		iconAlpha = ALPHA_Disabled;
		i_CurrentIcon.Image = GetTextureByIndex(MyInteraction.GetPerkIndex());
	}
	else {
		i_CurrentIcon.Image = GetTextureByIndex(MyInteraction.forcedPerkIndex);
	}

	for (i = 0; i < i_PerkIcons.length; i++)
		i_PerkIcons[i].ImageColor.A = iconAlpha;
}

function ShowPanel(bool bShow) {
	Super.ShowPanel(bShow);

	if (bShow) {
		ch_DefaultSwitch.SetComponentValue(MyInteraction.bDefaultSwitch, true);
		ch_PerkedFirst.SetComponentValue(MyInteraction.bPerkedFirst, true);
		ch_EmptyLast.SetComponentValue(MyInteraction.bEmptyLast, true);
		ch_IgnoreRequired.SetComponentValue(MyInteraction.bSkipNeverThrow, true);
		ch_SwitchOnPickup.SetComponentValue(!PlayerOwner().bNeverSwitchOnPickup, true);
		
		ch_DefaultPrevNext.SetComponentValue(MyInteraction.bDefaultPrevNext, true);
		ch_MatchCurrent.SetComponentValue(MyInteraction.bMatchCurrent, true);
		
		UpdateCheckboxVisibility();
		UpdateIconVisibility();
	}
}

function bool InternalOnPreDraw(Canvas C) {
	local float w, wB, h, h1, h2, x1, x2, y, center, spacing, ratioMod, padding, iconX, iconY, iconSize, bgSize;
	local int i, j;

	// BG SECTIONS
	padding = 0.2;
	w = ActualWidth() * 0.47;
	spacing = w / 100;
	h = ActualHeight() * (b_KFButtons[0].winTop - 2 * padding);
	
	ratioMod = C.clipX * 4 / (C.clipY * 5);
	if (ratioMod ~= 1)
		h1 = h * 0.56;
	else
		h1 = h * (0.56 - 0.16 * (ratioMod - 1));

	h2 = h - h1 - spacing;
	center = ActualLeft() + ActualWidth() / 2;
	x1 = center - w - spacing;
	x2 = center + spacing;
	y = ActualTop() + ActualHeight() * b_KFButtons[0].winTop * padding;
	
	i_BGLeft.SetPosition(x1, y, w, h, true);
	i_BGTopRight.SetPosition(x2, y, w, h1, true);
	i_BGBottomRight.SetPosition(x2, y + h1 + spacing, w, h2, true);
	
	// ICONS
	padding = 0.1;
	j = i_PerkIcons.length;
	bgSize = h1 - i_BGTopRight.ImageOffset[1];
	iconSize = FMin((1.0 - 2 * padding) * w / j, (1.0 - 2 * padding) * bgSize / 3);
	iconX = x2 + (w - iconSize * j) / 2;
	iconY = y + (1.0 - padding) * h1 - iconSize;
	
	j--;
	for (i = 0; i < j; i++) {
		i_PerkIcons[i].SetPosition(iconX, iconY, iconSize, iconSize, true);
		iconX += iconSize;
	}
	
	i_PerkIcons[j].SetPosition(iconX, iconY + iconSize * padding, iconSize, iconSize, true);
	
	iconSize = (1.0 - padding) * bgSize - iconSize - padding * h1;
	iconX = x2 + (w - iconSize) / 2;
	iconY = y + i_BGTopRight.ImageOffset[1] + padding * bgSize / 2;
	
	i_CurrentIcon.SetPosition(iconX, iconY, iconSize, iconSize, true);
	
	// BUTTONS
	wB = b_EditPriorities.ActualWidth();
	x2 += w - wB;
	y += h + spacing;
	h = b_EditPriorities.ActualHeight();
	
	b_EditPriorities.SetPosition(x1, y, wB, h, true);
	b_EditGroups.SetPosition(x2, y, wB, h, true);
	
	return Super.InternalOnPreDraw(C);
}

function bool ButtonClicked(GUIComponent Sender) {
	local KFIndexedGUIImage Img;
	
	switch (Sender) {
		case b_EditPriorities:
			Controller.OpenMenu("CWPMut.CWPPagePriorities");
			break;
		case b_EditGroups:
			Controller.OpenMenu("CWPMut.CWPPageGroups");
			break;
		default:
			Img = KFIndexedGUIImage(Sender);
			if (Img != None && Img.ImageColor.A == ALPHA_Enabled && i_CurrentIcon.index != Img.index) {
				i_CurrentIcon.index = Img.index;
				i_CurrentIcon.Image = Img.Image;
				
				if (Img.index < 0)
					MyInteraction.forcedPerkIndex = MyInteraction.INDEX_PerkNeutral;
				else
					MyInteraction.forcedPerkIndex = Img.index;
				
				MyInteraction.SaveConfig();
			}
			
			break;
	}

	return Super.ButtonClicked(Sender);
}

function InternalOnChange(GUIComponent Sender) {
	switch (Sender) {
		case ch_DefaultSwitch:
			MyInteraction.bDefaultSwitch = ch_DefaultSwitch.IsChecked();
			MyInteraction.SaveConfig();
			UpdateCheckboxVisibility();
			break;
		case ch_PerkedFirst:
			MyInteraction.bPerkedFirst = ch_PerkedFirst.IsChecked();
			MyInteraction.SaveConfig();
			break;
		case ch_EmptyLast:
			MyInteraction.bEmptyLast = ch_EmptyLast.IsChecked();
			MyInteraction.SaveConfig();
			break;
		case ch_IgnoreRequired:
			MyInteraction.bSkipNeverThrow = ch_IgnoreRequired.IsChecked();
			MyInteraction.SaveConfig();
			break;
		case ch_SwitchOnPickup:
			PlayerOwner().bNeverSwitchOnPickup = !ch_SwitchOnPickup.IsChecked();
			class'Engine.PlayerController'.default.bNeverSwitchOnPickup = !ch_SwitchOnPickup.IsChecked();
			class'Engine.PlayerController'.static.StaticSaveConfig();
			break;
		case ch_DefaultPrevNext:
			MyInteraction.bDefaultPrevNext = ch_DefaultPrevNext.IsChecked();
			MyInteraction.SaveConfig();
			UpdateCheckboxVisibility();
			UpdateIconVisibility();
			break;
		case ch_MatchCurrent:
			MyInteraction.bMatchCurrent = ch_MatchCurrent.IsChecked();
			MyInteraction.SaveConfig();
			UpdateIconVisibility();
			break;
	}
}

defaultproperties {
	Begin Object Class=GUISectionBackground Name=BGLeft
		bFillClient=True
		Caption="Switching Weapons"
		OnPreDraw=BGLeft.InternalPreDraw
	End Object
	i_BGLeft=GUISectionBackground'CWPMidGamePanel.BGLeft'

	Begin Object Class=GUISectionBackground Name=BGTopRight
		bFillClient=True
		Caption="Current Group"
		OnPreDraw=BGTopRight.InternalPreDraw
	End Object
	i_BGTopRight=GUISectionBackground'CWPMidGamePanel.BGTopRight'
	
	Begin Object Class=GUISectionBackground Name=BGBottomRight
		bFillClient=True
		Caption="Previous and Next Weapon"
		OnPreDraw=BGBottomRight.InternalPreDraw
	End Object
	i_BGBottomRight=GUISectionBackground'CWPMidGamePanel.BGBottomRight'
	
	Begin Object Class=moCheckBox Name=DefaultSwitch
		Caption="Default function"
		Hint="Use the default function to switch weapons from the five inventory groups. This applies to SwitchWeapon keybindings."
		TabOrder=1
		OnCreateComponent=DefaultSwitch.InternalOnCreateComponent
		OnChange=CWPMidGamePanel.InternalOnChange
	End Object
	ch_DefaultSwitch=moCheckBox'CWPMidGamePanel.DefaultSwitch'
	
		Begin Object Class=moCheckBox Name=PerkedFirst
		Caption="Perked first"
		Hint="Perked weapons have higher priority."
		TabOrder=2
		OnCreateComponent=PerkedFirst.InternalOnCreateComponent
		OnChange=CWPMidGamePanel.InternalOnChange
	End Object
	ch_PerkedFirst=moCheckBox'CWPMidGamePanel.PerkedFirst'

	Begin Object Class=moCheckBox Name=EmptyLast
		Caption="Empty last"
		Hint="Empty weapons have lower priority."
		TabOrder=3
		OnCreateComponent=EmptyLast.InternalOnCreateComponent
		OnChange=CWPMidGamePanel.InternalOnChange
	End Object
	ch_EmptyLast=moCheckBox'CWPMidGamePanel.EmptyLast'
	
	Begin Object Class=moCheckBox Name=IgnoreRequired
		Caption="Skip default equipment"
		Hint="Skip the Knife and the 9mm Tactical."
		TabOrder=4
		OnCreateComponent=IgnoreRequired.InternalOnCreateComponent
		OnChange=CWPMidGamePanel.InternalOnChange
	End Object
	ch_IgnoreRequired=moCheckBox'CWPMidGamePanel.IgnoreRequired'
	
	Begin Object Class=moCheckBox Name=SwitchOnPickup
		Caption="Switch on pickup"
		Hint="Automatically change weapons when you pick up a better one."
		TabOrder=5
		OnCreateComponent=SwitchOnPickup.InternalOnCreateComponent
		OnChange=CWPMidGamePanel.InternalOnChange
	End Object
	ch_SwitchOnPickup=moCheckBox'CWPMidGamePanel.SwitchOnPickup'
	
	Begin Object Class=GUIButton Name=EditPrioritiesButton
		Caption="Priorities"
		Hint="Edit weapon priorities."
		TabOrder=6
		bBoundToParent=True
		OnClick=CWPMidGamePanel.ButtonClicked
	End Object
	b_EditPriorities=GUIButton'CWPMidGamePanel.EditPrioritiesButton'
	
	Begin Object Class=moCheckBox Name=DefaultPrevNext
		Caption="Default functions"
		Hint="Use the default functions to switch to the previous and to the next weapon. This applies to PrevWeapon and NextWeapon keybindings."
		TabOrder=7
		OnCreateComponent=DefaultPrevNext.InternalOnCreateComponent
		OnChange=CWPMidGamePanel.InternalOnChange
	End Object
	ch_DefaultPrevNext=moCheckBox'CWPMidGamePanel.DefaultPrevNext'
	
	Begin Object Class=moCheckBox Name=MatchCurrent
		Caption="Match current perk"
		Hint="Automatically select a group to match the current perk."
		TabOrder=8
		OnCreateComponent=MatchCurrent.InternalOnCreateComponent
		OnChange=CWPMidGamePanel.InternalOnChange
	End Object
	ch_MatchCurrent=moCheckBox'CWPMidGamePanel.MatchCurrent'
	
	Begin Object Class=GUIButton Name=EditGroupsButton
		Caption="Groups"
		Hint="Edit weapon groups."
		TabOrder=9
		bBoundToParent=True
		bScaleToParent=True
		OnClick=CWPMidGamePanel.ButtonClicked
	End Object
	b_EditGroups=GUIButton'CWPMidGamePanel.EditGroupsButton'
	
	Begin Object Class=KFIndexedGUIImage Name=CurrentIcon
		Index=-1
		ImageStyle=ISTY_Justified
		ImageAlign=IMGA_Center
		RenderWeight=2.0
		bBoundToParent=True
		bScaleToParent=True
	End Object
	i_CurrentIcon=KFIndexedGUIImage'CWPMidGamePanel.CurrentIcon'
	
	Begin Object Class=KFIndexedGUIImage Name=PerkIcons0
		ImageStyle=ISTY_Justified
		ImageAlign=IMGA_Center
		RenderWeight=2.0
		bBoundToParent=True
		bScaleToParent=True
	End Object
	i_PerkIcons(0)=KFIndexedGUIImage'CWPMidGamePanel.PerkIcons0'
	
	Begin Object Class=KFIndexedGUIImage Name=PerkIcons1
		ImageStyle=ISTY_Justified
		ImageAlign=IMGA_Center
		RenderWeight=2.0
		bBoundToParent=True
		bScaleToParent=True
	End Object
	i_PerkIcons(1)=KFIndexedGUIImage'CWPMidGamePanel.PerkIcons1'
	
	Begin Object Class=KFIndexedGUIImage Name=PerkIcons2
		ImageStyle=ISTY_Justified
		ImageAlign=IMGA_Center
		RenderWeight=2.0
		bBoundToParent=True
		bScaleToParent=True
	End Object
	i_PerkIcons(2)=KFIndexedGUIImage'CWPMidGamePanel.PerkIcons2'
	
	Begin Object Class=KFIndexedGUIImage Name=PerkIcons3
		ImageStyle=ISTY_Justified
		ImageAlign=IMGA_Center
		RenderWeight=2.0
		bBoundToParent=True
		bScaleToParent=True
	End Object
	i_PerkIcons(3)=KFIndexedGUIImage'CWPMidGamePanel.PerkIcons3'
	
	Begin Object Class=KFIndexedGUIImage Name=PerkIcons4
		ImageStyle=ISTY_Justified
		ImageAlign=IMGA_Center
		RenderWeight=2.0
		bBoundToParent=True
		bScaleToParent=True
	End Object
	i_PerkIcons(4)=KFIndexedGUIImage'CWPMidGamePanel.PerkIcons4'
	
	Begin Object Class=KFIndexedGUIImage Name=PerkIcons5
		ImageStyle=ISTY_Justified
		ImageAlign=IMGA_Center
		RenderWeight=2.0
		bBoundToParent=True
		bScaleToParent=True
	End Object
	i_PerkIcons(5)=KFIndexedGUIImage'CWPMidGamePanel.PerkIcons5'
	
	Begin Object Class=KFIndexedGUIImage Name=PerkIcons6
		ImageStyle=ISTY_Justified
		ImageAlign=IMGA_Center
		RenderWeight=2.0
		bBoundToParent=True
		bScaleToParent=True
	End Object
	i_PerkIcons(6)=KFIndexedGUIImage'CWPMidGamePanel.PerkIcons6'
	
	Begin Object Class=KFIndexedGUIImage Name=PerkIcons7
		ImageStyle=ISTY_Justified
		ImageAlign=IMGA_Center
		RenderWeight=2.0
		bBoundToParent=True
		bScaleToParent=True
	End Object
	i_PerkIcons(7)=KFIndexedGUIImage'CWPMidGamePanel.PerkIcons7'
}