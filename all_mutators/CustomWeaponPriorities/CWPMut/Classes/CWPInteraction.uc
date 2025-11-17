class CWPInteraction extends Interaction
	config(CWPMut);

const MAX_Priority = 256;
const MIN_Group = 1;
const MAX_Group = 5;
const NUM_SwitchArrays = 4;
const NUM_Perks = 8;
const INDEX_PerkNeutral = 7;

struct ClassArray {
	var array< class<KFWeapon> > Weapons;
};

struct WeaponArray {
	var array<KFWeapon> Weapons;
};

var array< class<KFWeapon> > LevelWeapons;			// array of all available weapon classes with their priorities equal to the array indices
var WeaponArray SwitchArrays[NUM_SwitchArrays];		// weapons in the player's inventory
var config ClassArray PerkArrays[NUM_Perks];		// perk-specific groups of weapons used by the interaction's PrevWeapon() and NextWeapon()
var config byte forcedPerkIndex;
var config bool bDefaultSwitch, bPerkedFirst, bEmptyLast, bSkipNeverThrow, bDefaultPrevNext, bMatchCurrent;
var KFPlayerController PC;
var GUI.GUITabItem NewTab;

///////////////////////////
//		INTERACTION		//
/////////////////////////
function Initialize() {
	PC = KFPlayerController(ViewportOwner.Actor);
	if (PC == None)
		Master.RemoveInteraction(Self);
}

event NotifyLevelChange() {
	Master.RemoveInteraction(Self);
}

function bool KeyEvent(EInputKey Key, EInputAction Action, float Delta) {
	local string Alias, LeftPart, RigthPart;

	if (Action == IST_Press) {
		Alias = PC.ConsoleCommand("KEYBINDING" @ PC.ConsoleCommand("KEYNAME" @ Key));
		if (Divide(Alias, " ", LeftPart, RigthPart))
			Alias = LeftPart;

		if (Alias ~= "SwitchWeapon")
			return SwitchWeapon(RigthPart);
		else if (Alias ~= "NextWeapon")
			return NextWeapon();
		else if (Alias ~= "PrevWeapon")
			return PrevWeapon();
		else if (Alias ~= "ShowMenu")
			return ShowMenu();
	}

	return false;
}

///////////////////////////
//		PRIORITIES		//
/////////////////////////
function ClearPriorities() {
	local int i;
	
	for (i = 0; i < LevelWeapons.length; i++)
		LevelWeapons[i].static.StaticClearConfig("priority");

	PC.ClientMessage("Weapon priorities have been reset.");
}

function bool IsVariantClass(class<Inventory> aInventoryType) {
	return Left(aInventoryType, 12) ~= "KFMod.Golden" || Left(aInventoryType, 10) ~= "KFMod.Camo";
}

function UpdateVariantClasses(class<KFWeapon> aWeaponClass) {
	local class<KFWeaponPickup> P, VP;
	local class<KFWeapon> W, VW;
	local byte i;
	
	P = class<KFWeaponPickup>(aWeaponClass.default.PickupClass);
	if (P == None)
		return;
	
	for (i = 0; i < P.default.VariantClasses.length; i++) {
		VP = class<KFWeaponPickup>(P.default.VariantClasses[i]);
	
		if (VP != None) {
			W = class<KFWeapon>(P.default.InventoryType);
			VW = class<KFWeapon>(VP.default.InventoryType);
			if (VW.default.priority != W.default.priority) {
				VW.default.priority = W.default.priority;
				VW.StaticSaveConfig();
			}
		}
	}
}

/* Make sure all weapon classes have unique priorities by creating an ordered linked list. */
function InitLevelWeapons() {
	local KFLevelRules LR;
	local CWPList WeaponList;
	local CWPNode N;
	local int i, j;
	
	forEach PC.DynamicActors(Class'KFLevelRules', LR)
		break;
	
	if (LR == None)
		return;

	WeaponList = new(None) class'CWPList';
	for (i = 0; i < LR.MediItemForSale.length; i++) {
		if (class<KFWeaponPickup>(LR.MediItemForSale[i]) == None || class<KFWeapon>(LR.MediItemForSale[i].default.InventoryType) == None || IsVariantClass(LR.MediItemForSale[i].default.InventoryType))
			continue;
		
		WeaponList.AddInOrder(class<KFWeapon>(LR.MediItemForSale[i].default.InventoryType));
	}
	
	for (i = 0; i < LR.SuppItemForSale.length; i++) {
		if (class<KFWeaponPickup>(LR.SuppItemForSale[i]) == None || class<KFWeapon>(LR.SuppItemForSale[i].default.InventoryType) == None || IsVariantClass(LR.SuppItemForSale[i].default.InventoryType))
			continue;
		
		WeaponList.AddInOrder(class<KFWeapon>(LR.SuppItemForSale[i].default.InventoryType));
	}
	
	for (i = 0; i < LR.ShrpItemForSale.length; i++) {
		if (class<KFWeaponPickup>(LR.ShrpItemForSale[i]) == None || class<KFWeapon>(LR.ShrpItemForSale[i].default.InventoryType) == None || IsVariantClass(LR.ShrpItemForSale[i].default.InventoryType))
			continue;
		
		WeaponList.AddInOrder(class<KFWeapon>(LR.ShrpItemForSale[i].default.InventoryType));
	}
	
	for (i = 0; i < LR.CommItemForSale.length; i++) {
		if (class<KFWeaponPickup>(LR.CommItemForSale[i]) == None || class<KFWeapon>(LR.CommItemForSale[i].default.InventoryType) == None || IsVariantClass(LR.CommItemForSale[i].default.InventoryType))
			continue;
		
		WeaponList.AddInOrder(class<KFWeapon>(LR.CommItemForSale[i].default.InventoryType));
	}
	
	for (i = 0; i < LR.BersItemForSale.length; i++) {
		if (class<KFWeaponPickup>(LR.BersItemForSale[i]) == None || class<KFWeapon>(LR.BersItemForSale[i].default.InventoryType) == None || IsVariantClass(LR.BersItemForSale[i].default.InventoryType))
			continue;
		
		WeaponList.AddInOrder(class<KFWeapon>(LR.BersItemForSale[i].default.InventoryType));
	}
	
	for (i = 0; i < LR.FireItemForSale.length; i++) {
		if (class<KFWeaponPickup>(LR.FireItemForSale[i]) == None || class<KFWeapon>(LR.FireItemForSale[i].default.InventoryType) == None || IsVariantClass(LR.FireItemForSale[i].default.InventoryType))
			continue;
		
		WeaponList.AddInOrder(class<KFWeapon>(LR.FireItemForSale[i].default.InventoryType));
	}
	
	for (i = 0; i < LR.DemoItemForSale.length; i++) {
		if (class<KFWeaponPickup>(LR.DemoItemForSale[i]) == None || class<KFWeapon>(LR.DemoItemForSale[i].default.InventoryType) == None || IsVariantClass(LR.DemoItemForSale[i].default.InventoryType))
			continue;
		
		WeaponList.AddInOrder(class<KFWeapon>(LR.DemoItemForSale[i].default.InventoryType));
	}
	
	for (i = 0; i < LR.NeutItemForSale.length; i++) {
		if (class<KFWeaponPickup>(LR.NeutItemForSale[i]) == None || class<KFWeapon>(LR.NeutItemForSale[i].default.InventoryType) == None || IsVariantClass(LR.NeutItemForSale[i].default.InventoryType))
			continue;
		
		WeaponList.AddInOrder(class<KFWeapon>(LR.NeutItemForSale[i].default.InventoryType));
	}

	WeaponList.InsertHead(class'KFMod.Welder');
	WeaponList.InsertHead(class'KFMod.Syringe');
	
	j = WeaponList.itemCount;
	LevelWeapons.length = 0;
	LevelWeapons.length = j;
	for (N = WeaponList.Head; N != None; N = N.Next) {
		LevelWeapons[--j] = N.WeaponClass;
		if (N.WeaponClass.default.priority != j) {
			N.WeaponClass.default.priority = j;
			N.WeaponClass.static.StaticSaveConfig();
		}
		
		UpdateVariantClasses(N.WeaponClass);
	}
}

function UpdatePawnWeapons() {
	local Inventory PawnInv, Inv;
	local KFWeapon W;
	
	PawnInv = GetPawnInventory();
	for (Inv = PawnInv; Inv != None; Inv = Inv.Inventory) {
		W = KFWeapon(Inv);
		if (W != None && Frag(W) == None)
			W.priority = W.default.priority;
	}
}

function DefaultPriorities() {
	ClearPriorities();
	InitLevelWeapons();
	UpdatePawnWeapons();
}

function ClearAll() {
	local GUIController GC;
	local GUIPage MyPage;
	local KFInvasionLoginMenu LoginMenu;

	ClearPriorities();

	GC = GUIController(ViewportOwner.GUIController);
	if (GC == None)
		return;

	GC.CloseMenu();
	MyPage = GC.FindMenuByClass(class'CWPMut.CWPPagePriorities');
	if (MyPage != None)
		GC.RemoveMenu(MyPage);
	
	LoginMenu = KFInvasionLoginMenu(GC.FindMenuByClass(class'KFGui.KFInvasionLoginMenu'));
	if (LoginMenu != None)
		LoginMenu.c_Main.RemoveTab(NewTab.Caption);

	Master.RemoveInteraction(Self);
}

function SwapPriorities(byte indexA, byte indexB) {
	local class<KFWeapon> TempClass;
	
	TempClass = LevelWeapons[indexA];
	LevelWeapons[indexA] = LevelWeapons[indexB];
	LevelWeapons[indexB] = TempClass;
	
	LevelWeapons[indexA].default.priority = indexA;
	LevelWeapons[indexA].static.StaticSaveConfig();
	UpdateVariantClasses(LevelWeapons[indexA]);
	
	LevelWeapons[indexB].default.priority = indexB;
	LevelWeapons[indexB].static.StaticSaveConfig();
	UpdateVariantClasses(LevelWeapons[indexB]);
}

///////////////////////////////
//		PAWN AND WEAPON		//
/////////////////////////////
function Inventory GetPawnInventory() {
	if (PC.Pawn != None)
		return PC.Pawn.Inventory;
	else
		return None;
}

function KFWeapon GetPawnWeapon() {
	if (PC.Pawn != None)
		return KFWeapon(PC.Pawn.Weapon);
	else
		return None;
}

function bool IsPerked(KFWeapon aWeapon) {
	local KFPlayerReplicationInfo PRI;

	if (aWeapon == None)
		return false;
	
	PRI = KFPlayerReplicationInfo(PC.PlayerReplicationInfo);
	if (PRI != None && PRI.ClientVeteranSkill != None && class<KFWeaponPickup>(aWeapon.default.PickupClass) != None)
		return class<KFWeaponPickup>(aWeapon.default.PickupClass).default.correspondingPerkIndex == PRI.ClientVeteranSkill.default.perkIndex;
	else
		return false;
}

function byte GetPerkIndex() {
	local KFPlayerReplicationInfo PRI;

	PRI = KFPlayerReplicationInfo(PC.PlayerReplicationInfo);
	if (PRI != None && PRI.ClientVeteranSkill != None)
		return PRI.ClientVeteranSkill.default.perkIndex;
	else
		return INDEX_PerkNeutral;
}

function byte PerkToListIndex() {
	local byte i;
	
	if (bMatchCurrent)
		i = GetPerkIndex();
	else
		i = forcedPerkIndex;
	
	return ++i % (INDEX_PerkNeutral + 1);
}

function class<KFWeapon> GetClassByPriority(coerce byte aPriority) {
	if (LevelWeapons.length == 0 || aPriority >= LevelWeapons.length)
		return None;
	else
		return LevelWeapons[aPriority];
}

///////////////////////////////////////////
//		NEXT AND PREVIOUS FUNCTIONS		//
/////////////////////////////////////////
function bool OrigPrevWeapon() {
	local HUDKillingFloor HUD;
	
	HUD = HUDKillingFloor(PC.MyHUD);
	if (HUD != None) {
		HUD.PrevWeapon();
		HUD.SelectWeapon();
	}
	else {
		PC.PrevWeapon();
	}
		
	return true;
}

function bool OrigNextWeapon() {
	local HUDKillingFloor HUD;
	
	HUD = HUDKillingFloor(PC.MyHUD);
	if (HUD != None) {
		HUD.NextWeapon();
		HUD.SelectWeapon();
	}
	else {
		PC.NextWeapon();
	}
		
	return true;
}

function int GetPerkArrayIndex() {
	local int perkIndex;
	
	if (bMatchCurrent)
		perkIndex = GetPerkIndex();
	else
		perkIndex = forcedPerkIndex;
		
	if (PerkArrays[perkIndex].Weapons.length > 0)
		return perkIndex;
	else
		return -1;
}

/* The position of a given weapon within the array corresponding to the current custom group. */
function int GetClassIndex(KFWeapon aWeapon) {
	local int i;
	local int perkIndex;
	
	if (aWeapon == None)
		return -1;
	
	perkIndex = GetPerkArrayIndex();
	if (perkIndex == -1)
		return -1;

	for (i = 0; i < PerkArrays[perkIndex].Weapons.length; i++)
		if (aWeapon.default.priority == PerkArrays[perkIndex].Weapons[i].default.priority)
			return i;

	return -1;
}

function KFWeapon FindPrevWeapon(KFWeapon aCurrent, byte aPerkIndex) {
	local Inventory PawnInv, Inv;
	local KFWeapon W, PrevWeapon;
	local int i, startIndex, endIndex, curIndex;
	
	PawnInv = GetPawnInventory();
	curIndex = GetClassIndex(aCurrent);
	
	startIndex = curIndex - 1;
	endIndex = 0;
	for (i = startIndex; i >= endIndex; i--) {
		for (Inv = PawnInv; Inv != None; Inv = Inv.Inventory) {
			W = KFWeapon(Inv);
			if (W != None && Frag(W) == None && W.default.priority == PerkArrays[aPerkIndex].Weapons[i].default.priority) {
				PrevWeapon = W;
				endIndex = i + 1;
			}
		}
	}
	
	if (PrevWeapon != None)
		return PrevWeapon;
	
	startIndex = PerkArrays[aPerkIndex].Weapons.length - 1;
	endIndex = curIndex + 1;
	for (i = startIndex; i >= endIndex; i--) {
		for (Inv = PawnInv; Inv != None; Inv = Inv.Inventory) {
			W = KFWeapon(Inv);
			if (W != None && Frag(W) == None && W.default.priority == PerkArrays[aPerkIndex].Weapons[i].default.priority) {
				PrevWeapon = W;
				endIndex = i + 1;
			}
		}
	}
	
	return PrevWeapon;
}

function KFWeapon FindNextWeapon(KFWeapon aCurrent, byte aPerkIndex) {
	local Inventory PawnInv, Inv;
	local KFWeapon W, NextWeapon;
	local int i, startIndex, endIndex, curIndex;
	
	PawnInv = GetPawnInventory();
	curIndex = GetClassIndex(aCurrent);
	
	startIndex = curIndex + 1;
	endIndex = PerkArrays[aPerkIndex].Weapons.length;
	for (i = startIndex; i < endIndex; i++) {
		for (Inv = PawnInv; Inv != None; Inv = Inv.Inventory) {
			W = KFWeapon(Inv);
			if (W != None && Frag(W) == None && W.default.priority == PerkArrays[aPerkIndex].Weapons[i].default.priority) {
				NextWeapon = W;
				endIndex = i;
			}
		}
	}
	
	if (NextWeapon != None)
		return NextWeapon;
	
	startIndex = 0;
	endIndex = curIndex;
	for (i = startIndex; i < endIndex; i++) {
		for (Inv = PawnInv; Inv != None; Inv = Inv.Inventory) {
			W = KFWeapon(Inv);
			if (W != None && Frag(W) == None && W.default.priority == PerkArrays[aPerkIndex].Weapons[i].default.priority) {
				NextWeapon = W;
				endIndex = i;
			}
		}
	}
	
	return NextWeapon;
}

function bool PrevWeapon() {
	local KFHumanPawn PCPawn;
	local KFWeapon Pending, Current;
	local int perkIndex;

	if (bDefaultPrevNext)
		return false;

	PCPawn = KFHumanPawn(PC.Pawn);
	if (PCPawn == None || PCPawn.PendingWeapon != None && PCPawn.PendingWeapon.bForceSwitch)
		return true;

	perkIndex = GetPerkArrayIndex();
	if (perkIndex == -1)
		return OrigPrevWeapon();
		
	Current = GetPawnWeapon();
	Pending = FindPrevWeapon(Current, perkIndex);
	if (Pending == None) {
		if (GetClassIndex(Current) != -1)
			return true;
		else
			return OrigPrevWeapon();
	}

	PCPawn.PendingWeapon = Pending;
	if (Current == None)			
		PCPawn.ChangedWeapon();
	else
		PCPawn.Weapon.PutDown();

	return true;
}

function bool NextWeapon() {
	local KFHumanPawn PCPawn;
	local KFWeapon Pending, Current;
	local int perkIndex;
	
	if (bDefaultPrevNext)
		return false;

	PCPawn = KFHumanPawn(PC.Pawn);
	if (PCPawn == None || PCPawn.PendingWeapon != None && PCPawn.PendingWeapon.bForceSwitch)
		return true;
	
	perkIndex = GetPerkArrayIndex();
	if (perkIndex == -1)
		return OrigNextWeapon();
	
	Current = GetPawnWeapon();
	Pending = FindNextWeapon(Current, perkIndex);
	if (Pending == None) {
		if (GetClassIndex(Current) != -1)
			return true;
		else
			return OrigNextWeapon();
	}

	PCPawn.PendingWeapon = Pending;
	if (Current == None)			
		PCPawn.ChangedWeapon();
	else
		PCPawn.Weapon.PutDown();

	return true;
}

///////////////////////////////
//		SWITCH FUNCTION		//
/////////////////////////////
/**
  * The index of the array containing a given weapon:
  * 0 - perked
  * 1 - unperked
  * 2 - perked empty
  * 3 - unperked empty
  */
function int GetSwitchIndex(KFWeapon aWeapon) {
	local byte i;
	
	if (aWeapon == None)
		return -1;

	if (aWeapon.default.inventoryGroup == MAX_Group)
		return 0;
	
	if (bPerkedFirst && !IsPerked(aWeapon))
		i += 1;	
	if (bEmptyLast && aWeapon.AmmoAmount(0) == 0)
		i += 2;
	
	return i;
}

function KFWeapon HighestPriorityWeapon(byte aSwitchIndex, int aPriority) {
	local KFWeapon W;
	local int i, j;

	if (SwitchArrays[aSwitchIndex].Weapons.length == 0)
		return None;

	j = -1;
	for (i = 0; i < SwitchArrays[aSwitchIndex].Weapons.length; i++) {
		if (j < SwitchArrays[aSwitchIndex].Weapons[i].priority && SwitchArrays[aSwitchIndex].Weapons[i].priority < aPriority) {
			W = SwitchArrays[aSwitchIndex].Weapons[i];
			j = W.priority;
		}
	}

	return W;
}

/* Distribute player's weapons into four arrays. */
function UpdateSwitchArrays(byte aGroup, KFWeapon aCurrent) {
	local Inventory PawnInv, Inv;
	local KFWeapon W, NeverThrown;
	local int i, j;

	for (i = 0; i < NUM_SwitchArrays; i++)
		SwitchArrays[i].Weapons.length = 0;

	PawnInv = GetPawnInventory();
	for (Inv = PawnInv; Inv != None; Inv = Inv.Inventory) {
		if (Inv.inventoryGroup != aGroup)
			continue;

		W = KFWeapon(Inv);
		if (W != None && Frag(W) == None && W != aCurrent) {
			if (bSkipNeverThrow && aGroup < MAX_Group && W.default.bKFNeverThrow) {
				NeverThrown = W;
				break;
			}
			
			i = GetSwitchIndex(W);
			SwitchArrays[i].Weapons[SwitchArrays[i].Weapons.length] = W;
		}
	}
	
	if (bSkipNeverThrow) {
		if (aCurrent == None || aCurrent.default.inventoryGroup != aGroup) {
			for (i = 0; i < NUM_SwitchArrays; i++)
				j += SwitchArrays[i].Weapons.length;
		
			if (j == 0)
				SwitchArrays[0].Weapons[0] = NeverThrown;
		}
	}
}

/* Switch weapons based on the SwitchArrays index and their priority. */
function bool SwitchWeapon(coerce byte aGroup) {
	local KFHumanPawn PCPawn;
	local KFWeapon Pending, Current;
	local int i, j, indexOffset;
	
	if (bDefaultSwitch || aGroup < MIN_Group || aGroup > MAX_Group)
		return false;

	PCPawn = KFHumanPawn(PC.Pawn);
	if (PCPawn == None || PCPawn.PendingWeapon != None && PCPawn.PendingWeapon.bForceSwitch)
		return true;

	Current = GetPawnWeapon();
	UpdateSwitchArrays(aGroup, Current);
	
	if (Current != None && Current.default.inventoryGroup == aGroup) {
		indexOffset = GetSwitchIndex(Current);
		Pending = HighestPriorityWeapon(indexOffset, Current.default.priority);
	}
	else {
		indexOffset = -1;
	}
	
	if (Pending == None) {
		for (i = 1; i <= NUM_SwitchArrays; i++) {
			j = (indexOffset + i) % NUM_SwitchArrays;
			Pending = HighestPriorityWeapon(j, MAX_Priority);
			if (Pending != None)
				break;
		}
	}

	if (Pending == None)
		return true;

	PCPawn.PendingWeapon = Pending;
	if (Current == None)			
		PCPawn.ChangedWeapon();
	else
		PCPawn.Weapon.PutDown();

	return true;
}

///////////////////
//		GUI		//
/////////////////
function bool ShowMenu() {
	local GUIController GC;
	local KFInvasionLoginMenu LoginMenu;
	local CWPMidGamePanel Panel;

	GC = GUIController(ViewportOwner.GUIController);
	if (GC == None)
		return false;

	if (GC.ActivePage == None)
		PC.ShowMenu();

	LoginMenu = KFInvasionLoginMenu(GC.ActivePage);
	if (LoginMenu != None && LoginMenu.c_Main.TabIndex(NewTab.Caption) == -1) {
		Panel = CWPMidGamePanel(LoginMenu.c_Main.AddTabItem(NewTab));
		if (Panel != None) {
			Panel.ModifiedChatRestriction = LoginMenu.UpdateChatRestriction;
			Panel.MyInteraction = Self;
			Panel.MyButton.SetHint(NewTab.Hint);
		}
	}

	return true;
}

defaultproperties {
	forcedPerkIndex=7
	bMatchCurrent=True
	NewTab=(ClassName="CWPMut.CWPMidGamePanel",Caption="C.W.P.",Hint="Options to customize weapon priorities.")
}
