//-----------------------------------------------------------
// Written by Marco
//-----------------------------------------------------------
class DoomWepsMut extends Mutator
	config(DoomPawnsKF);

var() config bool bReplaceShopWeps,bReplaceInitWeps,bRemoveMapKFWeps;

function PostBeginPlay()
{
	if( bReplaceShopWeps )
		SetTimer(0.1,False);
}
function Timer()
{
	local KFGameType KF;

	KF = KFGameType(Level.Game);
	if ( KF!=None )
	{
		if( KF.KFLRules!=None )
			KF.KFLRules.Destroy();
		KF.KFLRules = Spawn(Class'KFDoomLevelRules');
	}
}
function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	if( bReplaceInitWeps && KFHumanPawn(Other)!=None )
	{
		KFHumanPawn(Other).RequiredEquipment[0] = string(Class'DoomFist');
		KFHumanPawn(Other).RequiredEquipment[1] = "KFMod.Syringe";
		KFHumanPawn(Other).RequiredEquipment[2] = "KFMod.Welder";
		KFHumanPawn(Other).RequiredEquipment[3] = string(Class'DoomPistol');
		KFHumanPawn(Other).RequiredEquipment[4] = "";
	}
	else if( bRemoveMapKFWeps && KFWeaponPickup(Other)!=None && DoomWeaponPickups(Other)==None )
		return false;
	return true;
}
static function FillPlayInfo(PlayInfo PlayInfo)
{
	Super.FillPlayInfo(PlayInfo);
	PlayInfo.AddSetting(default.RulesGroup, "bReplaceShopWeps", "Replace shop weapons:", 0, 0, "Check");
	PlayInfo.AddSetting(default.RulesGroup, "bReplaceInitWeps", "Replace initial weapons:", 0, 0, "Check");
	PlayInfo.AddSetting(default.RulesGroup, "bRemoveMapKFWeps", "Remove map KF weapons:", 0, 0, "Check");
}
static event string GetDescriptionText(string PropName)
{
	switch(PropName)
	{
		case "bReplaceShopWeps":
			return "Should replace all shop weapons with Doom weapons.";
		case "bReplaceInitWeps":
			return "Should replace initial weapons with Doom weapons.";
		case "bRemoveMapKFWeps":
			return "Should remove all Killing Floor weapon pickups from the maps.";
		default:
			return Super.GetDescriptionText(PropName);
	}
}

defaultproperties
{
     bReplaceShopWeps=True
     bReplaceInitWeps=True
     bRemoveMapKFWeps=True
     bAddToServerPackages=True
     GroupName="KF-WeaponMut"
     FriendlyName="Doom Weapons Mode!"
     Description="Use classic ol' Doom '95 weapons."
}
