//=============================================================================
// KFpubShowDmg
//=============================================================================
// Show Damage Mutator
// Version 0.4
// Last-Modified: 04 October 2012
//=============================================================================
// Created by r1v3t
// © 2011, KFpub :: www.kfpub.com
//=============================================================================
class KFpubShowDmg extends Mutator;

var() globalconfig int DamageColorR,DamageColorG,DamageColorB;
var localized string ShowDamageGroup;
var KFGameType KFGT;

function PostBeginPlay()
{
	KFGT = KFGameType(Level.Game);
	if(KFpubShowDmgGT(Level.Game) == none)
	{
		Level.ServerTravel("?Game=ShowDamageMut.KFpubShowDmgGT", true);
	}
	if(Level.Game.HUDType ~= class'KFGameType'.default.HUDType)
	{
		Level.Game.HUDType = string(class'KFpubShowDmgHUD');
	}
	if(Level.Game.PlayerControllerClass == class'KFPlayerController')
	{
		Level.Game.PlayerControllerClass = class'KFpubShowDmgPC';
		Level.Game.PlayerControllerClassName = string(class'KFpubShowDmgPC');
	}
	Log("Show Damage is starting...");
}

static function FillPlayInfo(PlayInfo PlayInfo)
{
	Super.FillPlayInfo(PlayInfo);

	PlayInfo.AddSetting(default.ShowDamageGroup,"DamageColorR","1. RED",1,0, "Text", "3;0:255",,,True);
	PlayInfo.AddSetting(default.ShowDamageGroup,"DamageColorG","2. GREEN",1,0, "Text", "3;0:255",,,True);
	PlayInfo.AddSetting(default.ShowDamageGroup,"DamageColorB","3. BLUE",1,0, "Text", "3;0:255",,,True);
}

static event string GetDescriptionText(string PropName)
{
	switch (PropName)
	{
		case "DamageColorR":			return "Choose a Color Scheme (Red))";
		case "DamageColorG":			return "Choose a Color Scheme (Green))";
		case "DamageColorB":			return "Choose a Color Scheme (Blue))";
	}
	return Super.GetDescriptionText(PropName);
}

defaultproperties
{
	GroupName="KF-KFpubShowDamage"
	FriendlyName="Show Damage Mutator"
	Description="Shows a HP damage you cause to enemy.|Show Damage Mutator|by KFpub Team|www.kfpub.com"
	DamageColorR=255
	DamageColorG=215
	DamageColorB=255
}