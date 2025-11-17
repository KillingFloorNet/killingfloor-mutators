//=============================================================================
// Only One Job by Phada | 1 April 2010 | http://phada.2ya.com/kf.xhtml
//=============================================================================
class MutOneJob extends Mutator config;

var KFGameType KF;
var bool bExtraChecked;
var config bool bLimitSyringe, bLimitWelder, bLimitNades;
var localized string sOption[3], sToolTip[3];

function PostBeginPlay() {
	if (KFGameType(level.Game) != None) {
		KF = KFGameType(level.Game);
		SetTimer(2.0, true);
	}
	else
		Destroy();
}

function Timer() {
	if (KF.bWaveInProgress) { // we cannot change class during waves
		if (!bExtraChecked) { // check one more time in case someone changed his perk in the 2 last seconds
			MutUpdate();
			bExtraChecked = true;
		}
	}
	else { // before first wave and during trader time
		MutUpdate();
		bExtraChecked = false;
	}
}

function MutUpdate() {
	local Controller C;
	for (C=Level.ControllerList; C!=None; C=C.NextController)
		if (C.bIsPlayer && C.Pawn != None && C.Pawn.Health > 0)
			CheckPlayerTools(C);
}

function CheckPlayerTools(Controller C) {
	local class<KFVeterancyTypes> MyVetClass;
	local Inventory Inv;
	local KFMeleeGun MySyringe, MyWelder, NewTool;
	local bool bNeedSwitch;

	if (C.PlayerReplicationInfo == None || KFPlayerReplicationInfo(C.PlayerReplicationInfo) == None)
		return;

	MyVetClass = KFPlayerReplicationInfo(C.PlayerReplicationInfo).ClientVeteranSkill;

	for (Inv=C.Pawn.Inventory; Inv!=None; Inv=Inv.Inventory) { // getting the references of all tools
		if (Inv != None) {
			if (Syringe(Inv) != None) MySyringe = Syringe(Inv);
			else if (Welder(Inv) != None) MyWelder = Welder(Inv);
		}
	}

	if (bLimitSyringe) {
		if (MyVetClass == class'KFVetFieldMedic') {
			if (MySyringe == None) {
				NewTool = Spawn(class'Syringe');
				if (NewTool != None && C.Pawn.AddInventory(NewTool)) {
					NewToolMsg(C, 0);
					log(C.PlayerReplicationInfo.PlayerName@"switches to Medic -> adding Syringe");
				}
			}
		}
		else if (MySyringe != None) {
			RemToolMsg(C, 0);
			bNeedSwitch = (C.Pawn.Weapon == MySyringe);
			MySyringe.Destroy();
			if (bNeedSwitch) C.SwitchToBestWeapon();
			log(C.PlayerReplicationInfo.PlayerName@"is NOT Medic -> removing Syringe");
		}
	}

	if (bLimitWelder) {
		if (MyVetClass == class'KFVetSupportSpec') {
			if (MyWelder == None) {
				NewTool = Spawn(class'Welder');
				if (NewTool != None && C.Pawn.AddInventory(NewTool)) {
					NewToolMsg(C, 1);
					log(C.PlayerReplicationInfo.PlayerName@"switches to Support -> adding Welder");
				}
			}
		}
		else if (MyWelder != None) {
			RemToolMsg(C, 1);
			bNeedSwitch = (C.Pawn.Weapon == MyWelder);
			MyWelder.Destroy();
			if (bNeedSwitch) C.SwitchToBestWeapon();
			log(C.PlayerReplicationInfo.PlayerName@"is NOT Support -> removing Welder");
		}
	}
}

function LimitNumNades(Controller C) {
	local class<KFVeterancyTypes> MyVetClass;
	local Inventory Inv;
	local int NumGrenades;

	if (C.PlayerReplicationInfo == None || KFPlayerReplicationInfo(C.PlayerReplicationInfo) == None)
		return;
		
	MyVetClass = KFPlayerReplicationInfo(C.PlayerReplicationInfo).ClientVeteranSkill;
	if (MyVetClass == None) // no perk at all
		NumGrenades = 1;
	else if (MyVetClass == class'KFVetDemolitions' || MyVetClass == class'KFVetSupportSpec')
		return; //NumGrenades = 3; // default amount
	else if (MyVetClass == class'KFVetFirebug')
		NumGrenades = 2;
	else // all other perks
		NumGrenades = 1;

	for (Inv=C.Pawn.Inventory; Inv!=None; Inv=Inv.Inventory) {
		if (Inv != None && FragAmmo(Inv) != None) {
			FragAmmo(Inv).AmmoAmount = NumGrenades;
			log(C.PlayerReplicationInfo.PlayerName@"spawn with only"@NumGrenades@"Grenade(s), his perk:"$MyVetClass);
			if (PlayerController(C) != None)
				PlayerController(C).ReceiveLocalizedMessage(class'KFOneJob.OneJobNadeMsg', NumGrenades, C.PlayerReplicationInfo); 
			break;
		}
	}
}

function NewToolMsg(Controller C, byte Switch) {
	if (PlayerController(C) != None)
		PlayerController(C).ReceiveLocalizedMessage(class'KFOneJob.OneJobNewMsg', Switch);
}

function RemToolMsg(Controller C, byte Switch) {
	if (PlayerController(C) != None)
		PlayerController(C).ReceiveLocalizedMessage(class'KFOneJob.OneJobRemMsg', Switch, C.PlayerReplicationInfo); 
}

function ModifyPlayer(Pawn Other) {
	if (Other.Controller != None) {
		CheckPlayerTools(Other.Controller); // instant check at spawn
		if (bLimitNades)
			LimitNumNades(Other.Controller);
	}
	
	Super.ModifyPlayer(Other);
}

function bool CheckReplacement(Actor Other, out byte bSuperRelevant) { // always delete tools instead of drop them while dying
	if (bLimitSyringe && Other.IsA('SyringePickup'))
		return false;

	if (bLimitWelder && Other.IsA('WelderPickup'))
		return false;

	return true;
}

// config stuff from here
static event string GetDescriptionText(string PropName) {
	switch(PropName) {
		case "bLimitSyringe": return default.sToolTip[0];
		case "bLimitWelder": return default.sToolTip[1];
		case "bLimitNades": return default.sToolTip[2];
	}
	return Super.GetDescriptionText(PropName);
}

static function FillPlayInfo(PlayInfo PlayInfo) {
	Super.FillPlayInfo(PlayInfo);
	PlayInfo.AddSetting(default.GameGroup, "bLimitSyringe", default.sOption[0], 0, 0, "Check");
	PlayInfo.AddSetting(default.GameGroup, "bLimitWelder", default.sOption[1], 0, 1, "Check");
	PlayInfo.AddSetting(default.GameGroup, "bLimitNades", default.sOption[2], 0, 2, "Check");
}

DefaultProperties
{
	bLimitSyringe=true
	bLimitWelder=true
	sOption(0)="Only Medics have Syringe"
	sOption(1)="Only Support Specialists have Welder"
	sOption(2)="Limit the amount of Grenades at spawn"
	sToolTip(0)="Enable Syringe restriction."
	sToolTip(1)="Enable Welder restriction."
	sToolTip(2)="3 for Demo and Supp, 2 for Firebug, 1 for all others."
	bAddToServerPackages=True
	Description="Restricts the use of the Syringe and the Welder to their respective perk.|Can also reduce the default amount of Grenades at spawn depending on the perk played.||[Configurable]"
	FriendlyName="Only One Job"
	GroupName="KFOneJob"
}