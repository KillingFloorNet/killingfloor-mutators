//=============================================================================
// Weapon stat generator	25-October-2012	Benjamin
//
// KNOWN ISSUES
//
//		Cannot detect where different fire modes share the same
//		ammo (boomstick)
//
//		Cannot detect penetration for all weapons, must check manually.
//
// ===== INFO
//
// HEAD SHOTS
//
// Every weapon's head shot multiplier is stored in its associated damagetype
// class, except (some of) those weapons whose projectiles implement
// ProcessTouch themselves: CrossbowArrow, M99Bullet CrossbuzzsawBlade. These
// projectiles have their own HeadShotDamageMult variable.
//
// NOTES
//
// (1) Certain classes don't use AmmoPerFire: MP7MAltFire, M7A3MAltFire
// (2) Hardcoded penetration values: Deagle, MK23, 44Magnum, Crossbow, M99,
// and Buzzsaw bow. Look in script files manually for these stats.
// (3) Weapons only have a single ReloadRate stat (none for alt-fire)
// (4) Weapons that auto-reload with a specific time:
//
//     Hunting shotgun - ReloadCountDown stored in BoomStick.uc
//     M79 - FireRate (fire + reload are same animation)
//     Crossbow - FireRate (fire + reload are same animation)
//     LAW - FireRate (fire + reload are same animation)
//     M99 - FireRate (fire + reload are same animation)
//     Buzzsaw Bow - FireRate (fire + reload are same animation)
//=============================================================================
class WeaponConfig extends Mutator dependson(WeaponConfigObject);

// Weapons
var array< class<KFWeaponPickup> > AdditionalWeapons;
var class<KFWeaponPickup> Pickup;
var class<KFWeapon> Weapon;
var class<WeaponFire> Fire[2];
var class<DamageType> DamageType[2];
var class<Ammunition> AmmoClass[2];
//var class<InstantFire> InstantFire;
var class<BaseProjectileFire> BaseProjectileFire;
var class<Projectile> Projectile;
var class<KFMonster> KFM;

// Specimens
var int SpecimenCount;
var array<float> GameDifficulty;
var array<float> BountyMultiplier;
var array<float> HealthMultiplier;
var array<float> HeadHealthMultiplier;
var array<float> SpeedMultiplier;
var array<float> DamageMultiplier;

var int l,l2;
var array<WeaponConfigObject> WeaponCFG;
var WeaponConfigObject tWeaponCFG;

var int curIndex, curIndexTest;
var bool bClientNeedUpdateWeapons;

var StringReplicationInfo RDataServer, RDataClient;
var int RDataRevisionServer, RDataRevisionClient;
var const string rDataDelim;

// open menu on client side
var PlayerController menuPC;
var int menuNum, menuNumClient;

/*
// receive weapon settings from client GUI
var array<string> mutateStr;
var int mutateStrLen;

var WeaponConfigObject rTest;*/

var StringReplicationInfo RDataGUI;
var int RDataGUIRev;

replication
{
	reliable if (ROLE == ROLE_Authority)
		RDataServer, RDataRevisionServer, RDataGUI,
		menuNum, menuPC;
}

//--------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------
simulated function PreBeginPlay()
{
	local int i,x;
	local array<string> Names;
	local WeaponConfigObject WI;

	if (Level.NetMode == NM_Client)
	{
		SetTimer(3.0, true);
		return;
	}
	else if (Level.NetMode == NM_Standalone)
		SetTimer(3.0, true);

	rDataServer = spawn(class'StringReplicationInfo', self);

	// читаем конфиг
	Names = class'WeaponConfigObject'.static.GetNames();
	for (i = 0; i < Names.length; i++)
		WeaponCFG[i] = new(None, Names[i]) class'WeaponConfigObject';

	// грузим в default, чтобы затем использовать в static функциях
	for (i=0;i<WeaponCFG.Length;i++)
	{
		WI = WeaponCFG[i];
		if (Len(WI.WeaponClass)==0) continue;
		Weapon = class<KFWeapon>(DynamicLoadObject(WI.WeaponClass, Class'Class'));
		if (Weapon==none) continue;
		Pickup = class<KFWeaponPickup>(Weapon.default.PickupClass);
		if (Pickup==none) continue;
		for (x = 0; x < 2; x++)
		{
			if (Weapon.default.FireModeClass[x] != none && IsTrueFire(Weapon.default.FireModeClass[x]))
				Fire[x] = Weapon.default.FireModeClass[x];
			else
			{
				Fire[x] = none;
				continue;
			}
			if (class<BaseProjectileFire>(Fire[x])!=none)
				WeaponCFG[i].DamageType[x] = class<BaseProjectileFire>(Fire[x]).default.ProjectileClass.default.MyDamageType;
			else if (class<InstantFire>(Fire[x]) != none)
				WeaponCFG[i].DamageType[x] = class<InstantFire>(Fire[x]).default.DamageType;

			WeaponCFG[i].AmmoClass[x] = Fire[x].default.AmmoClass;
			WeaponCFG[i].PickupClass = Weapon.default.PickupClass;
		}
		WeaponCFG[i].SaveConfig();
		default.WeaponCFG[i] = WeaponCFG[i];
	}
	SetWeaponStats();
	MakeReplicationDataString();
}
//--------------------------------------------------------------------------------------------------
function MakeReplicationDataString()
{
	local int i;
	local string s,prevStr/*,test*/;

	prevStr = RDataServer.GetString();

	for (i=0; i<WeaponCFG.Length; i++)
	{
		if (Len(s)!=0)
			s $= rDataDelim $ WeaponCFG[i].Serialize();
		else
			s $= WeaponCFG[i].Serialize();
	}
	if (prevStr!=s)
	{
		RDataServer.SetString(s);
		RDataRevisionServer++;
	}
}
//--------------------------------------------------------------------------------------------------
simulated function LM(string i)
{
	if (Level != none && Level.NetMode != NM_DedicatedServer)
		Level.GetLocalPlayerController().ClientMessage("WeaponConfig:"@i);
}
//--------------------------------------------------------------------------------------------------
simulated function ApplyRData(StringReplicationInfo RData)
{
	local int i,n,j,bBadCRC;
	local string s;
	local array<string> iSplit;
	local bool bFound;
	local bool bDebug;
	bDebug = false;

	if (bDebug) LM("RData()");

	s = RData.GetString(bBadCRC);
	if (bBadCRC!=0)
	{
		if (bDebug) LM("ApplyRData failed, bBadCRC="$bBadCRC);
		return;
	}
	n = Split(s,rDataDelim,iSplit);
	for (i=0; i<n; i++)
	{
		bFound=false;
		if (len(iSplit[i])==0)
			continue;

		if (bDebug) LM("split"@i@"Length"@Len(iSplit[i]));

		if (tWeaponCFG==none)
			tWeaponCFG = new(None, "temp") class'WeaponConfigObject';
		tWeaponCFG.Unserialize(iSplit[i]);
		if (bDebug) LM("tWeapon.WeaponClass"@tWeaponCFG.WeaponClass);
		if (bDebug) LM("WeaponCFG.Length"@WeaponCFG.Length);
		for (j=0;j<WeaponCFG.Length;j++)
		{
			if (bDebug) LM("WeaponCFG["$j$"].WeaponClass"@WeaponCFG[j].WeaponClass);
			if(WeaponCFG[j]!=none && WeaponCFG[j].WeaponClass == tWeaponCFG.WeaponClass)
			{
				bFound=true;
				WeaponCFG[j].Unserialize(iSplit[i]);
				if (bDebug) LM("Already Have"@WeaponCFG[j].WeaponClass@"so just renew. FireRate="@WeaponCFG[j].FireRate[0].value);
				break;
			}
		}
		if (bFound==false)
		{
			j = WeaponCFG.Length;
			if (WeaponCFG[j]==none)
			{
				s = string((class<KFWeapon>(DynamicLoadObject(tWeaponCFG.WeaponClass, Class'Class'))).Name);
				if (bDebug) LM("tWeaponCFG.WeaponClass classname"@s);
				WeaponCFG[j] = new(None, s) class'WeaponConfigObject';
			}
			WeaponCFG[j].Unserialize(iSplit[i]);
			if (bDebug) LM("Added"@WeaponCFG[j].WeaponClass@"FireRate="@WeaponCFG[j].FireRate[0].value);
		}

	}
	LM("New weapon settings arrived");
	if (bDebug) LM("WeaponCFG.Length"@WeaponCFG.Length@"now copy to default");

	for (i=0;i<WeaponCFG.Length;i++)
		default.WeaponCFG[i] = WeaponCFG[i];
	if (bDebug) LM("default.WeaponCFG.Length"@default.WeaponCFG.Length);
	if (bDebug) LM("*WeaponCFG.Length"@WeaponCFG.Length);

	SetWeaponStats();
}
simulated function Timer()
{
	local int bBadCRC;
	local string s;
	local bool bDebug;
	bDebug = false;

	if (Level.NetMode == NM_Client || Level.NetMode == NM_Standalone)
	{
		if (RDataRevisionClient != RDataRevisionServer
			&& RDataServer != none)
		{
			s = RDataServer.GetString(bBadCRC);
			if (bBadCRC!=0 || Len(s)==0) return;
			if (RDataClient == none)
				RDataClient = RDataServer;
			RDataClient.SetString(s);
			RDataRevisionClient = RDataRevisionServer;
			if (bDebug) LM("Timer() apply");
			//ApplyRDataClient();
			ApplyRData(RDataClient);
		}
	}
}
//--------------------------------------------------------------------------------------------------
simulated function Tick(float dt)
{
	local string s;
	local int bBadCRC;
	if (Level!=none && RDataGUI != none)
	{
		// Apply arrived new RDataGUI on ServerSide
		if (Level.NetMode != NM_Client	&& RDataGUIRev != RDataGUI.revision)
		{
			s = RDataGUI.GetString(bBadCRC);
			if (bBadCRC==0)
			{
				RDataGUIRev = RDataGUI.revision;
				ApplyRData(RDataGUI);
				MakeReplicationDataString();
			}
		}
		// Open menu on client with arrived RDataGUI
		if (Level.NetMode != NM_DedicatedServer)
		{
			if (menuNum != menuNumClient && menuPC!=none && menuPC == Level.GetLocalPlayerController())
			{
				RDataGUI.GetString(bBadCRC);
				if (bBadCRC==0)
				{
					menuNumClient = menuNum;
					menuPC.ClientOpenMenu(string(Class'WeaponConfigMenu'),,,);
				}
			}
		}
	}
}
//--------------------------------------------------------------------------------------------------
simulated function PostNetReceive()
{
	if (rDataClient != rDataServer)
		rDataClient = rDataServer;
}
//--------------------------------------------------------------------------------------------------
function Mutate(string input, PlayerController PC)
{
	local float		FArray[2];
	local int		IArray[2];
	local int		ioutput[2];
	local float		foutput[2];
	local array<string> iSplit, aString;
	local int i,n,x, WeaponCFGIndex;
	local bool bset1, bset2;
	local WeaponConfigObject WI;
	local string S;

	n = Split(input," ",iSplit);
	if (n<1 || Caps(iSplit[0])!=Caps("WPN") ) return;

	/*if (!Level.Game.AccessControl.IsAdmin(PC))
	{
		PC.ClientMessage("Only admins allowed to access this command");
		return;
	}*/

	DamageType[0]=none;
	DamageType[1]=none;
	AmmoClass[0]=none;
	AmmoClass[1]=none;
	Weapon = class<KFWeapon>(DynamicLoadObject(string(PC.Pawn.Weapon.Class), Class'Class'));
	if (Weapon==none) goto end;
	Pickup = class<KFWeaponPickup>(Weapon.default.PickupClass);
	if (Pickup==none) goto end;
	for (x = 0; x < 2; x++)
	{
		if (Weapon.default.FireModeClass[x] != none && IsTrueFire(Weapon.default.FireModeClass[x]))
			Fire[x] = Weapon.default.FireModeClass[x];
		else
		{
			Fire[x] = none;
			continue;
		}
		if (class<BaseProjectileFire>(Fire[x])!=none)
			DamageType[x] = class<BaseProjectileFire>(Fire[x]).default.ProjectileClass.default.MyDamageType;
		else if (class<InstantFire>(Fire[x]) != none)
			DamageType[x] = class<InstantFire>(Fire[x]).default.DamageType;

		AmmoClass[x] = (Fire[x].default.AmmoClass);
	}
	WeaponCFGIndex=-1;
	for (i=0; i<WeaponCFG.Length; i++)
		if (WeaponCFG[i].WeaponClass == string(PC.Pawn.Weapon.Class))
			{WeaponCFGIndex = i; break;}

	if (WeaponCFGIndex==-1)
	{
		WI = new(None, string(PC.Pawn.Weapon.Class.Name)) class'WeaponConfigObject';
		WI.WeaponClass = string(PC.Pawn.Weapon.Class);
		GetDamage(IArray);
		WI.Damage[0].value = IArray[0];
		WI.Damage[1].value = IArray[1];
		GetHeadMultiplier(FArray);
		WI.HeadMult[0].value = FArray[0];
		WI.HeadMult[1].value = FArray[1];
		GetCost(IArray[0]);
		WI.Cost.value = IArray[0];
		GetAmmoCost(IArray[0]);
		WI.AmmoCost.value = IArray[0];
		GetCapacity(IArray);
		WI.Capacity[0].value = IArray[0];
		WI.Capacity[1].value = IArray[1];
		GetMagazineSize(IArray);
		WI.MagSize.value = IArray[0];
		GetWeight(IArray[0]);
		WI.Weight.value = IArray[0];
		GetFireRate(FArray);
		WI.FireRate[0].value = FArray[0];
		WI.FireRate[1].value = FArray[1];
		GetSpread(FArray);
		WI.Spread[0].value = FArray[0];
		WI.Spread[1].value = FArray[1];
		GetReloadRate(WI.ReloadRate.value);
		GetRecoilX(FArray);
		WI.RecoilX[0] = FArray[0];
		WI.RecoilX[1] = FArray[1];
		GetRecoilY(FArray);
		WI.RecoilY[0] = FArray[0];
		WI.RecoilY[1] = FArray[1];

		WI.DamageType[0] = DamageType[0];
		WI.DamageType[1] = DamageType[1];
		WI.AmmoClass[0] = AmmoClass[0];
		WI.AmmoClass[1] = AmmoClass[1];
		WI.PickupClass = Pickup;
		WI.SaveConfig();
		i = WeaponCFG.Length;
		WeaponCFG[i] = WI;
		default.WeaponCFG[i] = WeaponCFG[i];
	}

	for (i=0; i<WeaponCFG.Length; i++)
		if (WeaponCFG[i].WeaponClass == string(PC.Pawn.Weapon.Class))
			{WeaponCFGIndex = i; break;}

	if (iSplit.Length > 2 && len(iSplit[2])>0) {bset1=true;FArray[0]=float(iSplit[2]);IArray[0]=FArray[0];}
	if (iSplit.Length > 3 && len(iSplit[3])>0) {bset2=true;FArray[1]=float(iSplit[3]);IArray[1]=FArray[1];}

	switch (iSplit[1])
	{
		case "Menu":
			menuPC = PC;
			menuNum++;
			if (RDataGUI==none)
				RDataGUI = Spawn(class'StringReplicationInfo', PC);
			RDataGUI.SetOwner(PC);
			RDataGUI.OwnerPC = PC;
			RDataGUI.bMenuStr = true;
			RDataGUI.SetString(WeaponCFG[WeaponCFGIndex].Serialize());
			break;
		case "FireRate":
			if (bset1 || bset2)
			{
				if (bset1) WeaponCFG[WeaponCFGIndex].FireRate[0].value = FArray[0];
				if (bset2) WeaponCFG[WeaponCFGIndex].FireRate[1].value = FArray[1];
				SetFireRate(FArray);
			}
			else GetFireRate(foutput);
			break;
		case "FireRateBonusMax":
			if (WeaponCFGIndex==-1) {PC.ClientMessage("WeaponNotFound in Array");break;}
			if (bset1 || bset2)
			{
				if (bset1) WeaponCFG[WeaponCFGIndex].FireRate[0].BonusMax = FArray[0];
				if (bset2) WeaponCFG[WeaponCFGIndex].FireRate[0].BonusMax = FArray[1];
			}
			else
			{
				foutput[0] = WeaponCFG[WeaponCFGIndex].FireRate[0].BonusMax;
				foutput[1] = WeaponCFG[WeaponCFGIndex].FireRate[1].BonusMax;
			}
			break;
		case "Damage":
			if (bset1 || bset2)
			{
				if (bset1) WeaponCFG[WeaponCFGIndex].Damage[0].value = IArray[0];
				if (bset2) WeaponCFG[WeaponCFGIndex].Damage[1].value = IArray[1];
				SetDamage(IArray);
			}
			else GetDamage(ioutput);
			break;
		case "DamageBonusMax":
			if (WeaponCFGIndex==-1) {PC.ClientMessage("WeaponNotFound in Array");break;}
			if (bset1 || bset2)
			{
				if (bset1) WeaponCFG[WeaponCFGIndex].Damage[0].BonusMax = FArray[0];
				if (bset2) WeaponCFG[WeaponCFGIndex].Damage[0].BonusMax = FArray[1];
			}
			else
			{
				foutput[0] = WeaponCFG[WeaponCFGIndex].Damage[0].BonusMax;
				foutput[1] = WeaponCFG[WeaponCFGIndex].Damage[1].BonusMax;
			}
			break;
		case "Cost":
			if (bset1 || bset2)
			{
				WeaponCFG[WeaponCFGIndex].Cost.value = IArray[0];
				SetCost(IArray[0]);
			}
			else GetCost(ioutput[0]);
			break;
		case "CostBonusMax":
			if (WeaponCFGIndex==-1) {PC.ClientMessage("WeaponNotFound in Array");break;}
			if (bset1)
				WeaponCFG[WeaponCFGIndex].Cost.BonusMax = FArray[0];
			else
				foutput[0] = WeaponCFG[WeaponCFGIndex].Cost.BonusMax;
			break;
		case "HeadMult":
			if (bset1 || bset2)
			{
				if (bset1) WeaponCFG[WeaponCFGIndex].HeadMult[0].value = FArray[0];
				if (bset2) WeaponCFG[WeaponCFGIndex].HeadMult[1].value = FArray[1];
				SetHeadMultiplier(FArray);
			}
			else GetHeadMultiplier(foutput);
			break;
		case "HeadMultBonusMax":
			if (WeaponCFGIndex==-1) {PC.ClientMessage("WeaponNotFound in Array");break;}
			if (bset1 || bset2)
			{
				if (bset1) WeaponCFG[WeaponCFGIndex].HeadMult[0].BonusMax = FArray[0];
				if (bset2) WeaponCFG[WeaponCFGIndex].HeadMult[1].BonusMax = FArray[1];
			}
			else
			{
				foutput[0] = WeaponCFG[WeaponCFGIndex].HeadMult[0].BonusMax;
				foutput[1] = WeaponCFG[WeaponCFGIndex].HeadMult[1].BonusMax;
			}
			break;
		case "Weight":
			if (bset1 || bset2)
			{
				if (bset1) WeaponCFG[WeaponCFGIndex].Weight.value = int(FArray[0]);
				SetWeight(IArray[0]);
			}
			else GetWeight(ioutput[0]);
			break;
		case "Capacity":
			if (bset1 || bset2)
			{
				if (bset1) WeaponCFG[WeaponCFGIndex].Capacity[0].value = IArray[0];
				if (bset2) WeaponCFG[WeaponCFGIndex].Capacity[1].value = IArray[1];
				SetCapacity(IArray);
			}
			else GetCapacity(ioutput);
			break;
		case "CapacityBonusMax":
			if (WeaponCFGIndex==-1) {PC.ClientMessage("WeaponNotFound in Array");break;}
			if (bset1 || bset2)
			{
				if (bset1) WeaponCFG[WeaponCFGIndex].Capacity[0].BonusMax = FArray[0];
				if (bset2) WeaponCFG[WeaponCFGIndex].Capacity[1].BonusMax = FArray[1];
			}
			else
			{
				foutput[0] = WeaponCFG[WeaponCFGIndex].Capacity[0].BonusMax;
				foutput[1] = WeaponCFG[WeaponCFGIndex].Capacity[1].BonusMax;
			}
			break;
		case "AmmoCost":
			if (bset1 || bset2)
			{
				if (bset1) WeaponCFG[WeaponCFGIndex].AmmoCost.value = IArray[0];
				SetAmmoCost(IArray[0]);
			}
			else GetAmmoCost(ioutput[0]);
			break;
		case "MagSize":
			if (bset1 || bset2)
			{
				if (bset1) WeaponCFG[WeaponCFGIndex].MagSize.value = IArray[0];
				SetMagazineSize(IArray[0]);
			}
			else GetMagazineSize(ioutput); //yes, array
			break;
		case "MagSizeBonusMax":
			if (WeaponCFGIndex==-1) {PC.ClientMessage("WeaponNotFound in Array");break;}
			if (bset1)
				WeaponCFG[WeaponCFGIndex].MagSize.BonusMax = FArray[0];
			else
				foutput[0] = WeaponCFG[WeaponCFGIndex].MagSize.BonusMax;
			break;
		case "Spread":
			if (bset1 || bset2)
			{
				if (bset1) WeaponCFG[WeaponCFGIndex].Spread[0].value = FArray[0];
				if (bset2) WeaponCFG[WeaponCFGIndex].Spread[1].value = FArray[1];
				SetSpread(FArray);
			}
			else GetSpread(foutput);
			break;
		case "SpreadBonusMax":
			if (WeaponCFGIndex==-1) {PC.ClientMessage("WeaponNotFound in Array");break;}
			if (bset1 || bset2)
			{
				if (bset1) WeaponCFG[WeaponCFGIndex].Spread[0].BonusMax = FArray[0];
				if (bset2) WeaponCFG[WeaponCFGIndex].Spread[1].BonusMax = FArray[1];
			}
			else
			{
				foutput[0] = WeaponCFG[WeaponCFGIndex].Spread[0].BonusMax;
				foutput[1] = WeaponCFG[WeaponCFGIndex].Spread[1].BonusMax;
			}
			break;
		case "Stats":
			aString = GetWeaponStats(WeaponCFG[WeaponCFGIndex]);
			for (i=0;i<aString.Length;i++)
				PC.ClientMessage(aString[i]);
			return;
		default:
			PC.ClientMessage("cant find"@iSplit[1]@" command routine.");
			PC.ClientMessage("List: AmmoCost, Capacity, CapacityBonusMax, Cost, CostBonusMax, Damage, DamageBonusMax, FireRate,");
			PC.ClientMessage("FireRateBonusMax, HeadMult, HeadMultBonusMax, MagSize, MagSizeBonusMax, Spread, SpreadBonusMax, Weight, Stats");
			return;
			break;
	}

	for (i=0;i<WeaponCFG.Length;i++)
	{
		WeaponCFG[i].SaveConfig();
		default.WeaponCFG[i] = WeaponCFG[i];
	}
	MakeReplicationDataString();
	
	if (iSplit[1]~="Menu")
		return;

end:
	if (foutput[0]+foutput[1] != 0.f)
	{
		if (foutput[0]!=0.f)
			s=string(foutput[0]);
		else s = "-";
		if (foutput[1]!=0.f)
			s=s@string(foutput[1]);
		PC.ClientMessage(s);
	}
	else if (ioutput[0]+ioutput[1] != 0)
	{
		if (ioutput[0]!=0)
			s=string(ioutput[0]);
		else s = "-";
		if (ioutput[1]!=0)
			s=s@string(ioutput[1]);
		PC.ClientMessage(s);
	}
	else if (bset1 || bset2)
	{
		PC.ClientMessage("settings saved");

		aString = GetWeaponStats(WeaponCFG[WeaponCFGIndex]);
		for (i=0;i<aString.Length;i++)
			PC.ClientMessage(aString[i]);
	}
	else
		PC.ClientMessage("no information :(");
}
//--------------------------------------------------------------------------------------------------
static simulated function bool IsAllowedInShop(class<KFWeaponPickup> Item, class<KFVeterancyTypes> vet, float lvlmult)
{
	local int i,j;
	local bool bClassNotSpecified,bLevelNotSpecified;
	bClassNotSpecified=true;
	bLevelNotSpecified=true;


	for (i=0; i<default.WeaponCFG.Length; i++)
	{
		if (default.WeaponCFG[i].PickupClass == Item)
		{
			if (default.WeaponCFG[i].AllowInShopAt.value > 0)
				bLevelNotSpecified=false;

			for (j=0;j<default.WeaponCFG[i].AllowInShopFor.Length;j++)
				if (default.WeaponCFG[i].AllowInShopFor[j] != none)
					{bClassNotSpecified=false;break;}
		}
	}
	if (bClassNotSpecified && bLevelNotSpecified)
		return false;

	for (i=0; i<default.WeaponCFG.Length; i++)
	{
		if (default.WeaponCFG[i].PickupClass == Item)
		{
			if (bClassNotSpecified)
			{
				if (bLevelNotSpecified)
					return true;
				else
				{
					if (default.WeaponCFG[i].AllowInShopAt.value <= lvlmult)
						return true;
					else
						return false;
				}
			}
			else
			{
				for (j=0;j<default.WeaponCFG[i].AllowInShopFor.Length;j++)
				{
					if (default.WeaponCFG[i].AllowInShopFor[j] == vet)
					{
						if (bLevelNotSpecified)
							return false;
						else
						{
							if (default.WeaponCFG[i].AllowInShopAt.value <= lvlmult)
								return true;
							else
								return false;
						}
					}
				}
			}
		}
	}
	return false;
}
//--------------------------------------------------------------------------------------------------
static function float GetLogScale(float lvlmult, float log)
{
	local float float1;
	if (log==0.f)
		return lvlmult;
	float1 = (0.f-log)*(lvlmult**2.f) + (1.f+log)*(lvlmult);
	float1 = FClamp(float1,0.f,1.f);
	return float1;
}
//--------------------------------------------------------------------------------------------------
static function float GetCoeff(WeaponConfigObject.Param P, float lvlmult, optional bool bInverseCoeff)
{
	local float flt;
	if (P.BonusMax==0)
		return 1.f;
	if (bInverseCoeff)
	{
		flt = 1.f - FClamp(P.BonusMax,0.f,1.f);
		flt *= GetLogScale(lvlmult, P.BonusLog);
		flt = 1.f - flt;
		return flt;
	}
	else
	{
		flt = P.BonusMax;
		if (flt>=1.f)
			flt -= 1.f;
		flt *= GetLogScale(lvlmult, P.BonusLog);
		flt += 1.f;
		return flt;
	}
}
//--------------------------------------------------------------------------------------------------
static simulated function float GetCostBonus(class<Pickup> Item, class<KFVeterancyTypes> vet, float lvlmult)
{
	local int i,j;
	for (i=0; i<default.WeaponCFG.Length; i++)
			if (default.WeaponCFG[i].PickupClass == Item)
				for (j=0;j<default.WeaponCFG[i].BonusFor.Length;j++)
					if (default.WeaponCFG[i].BonusFor[j] == vet)
						return GetCoeff(default.WeaponCFG[i].Cost, lvlmult, true);
	return 1.f;
}
//--------------------------------------------------------------------------------------------------
static simulated function float GetMagCapacityBonus(Weapon W, class<KFVeterancyTypes> vet, float lvlmult)
{
	local int i,j;
	for (i=0; i<default.WeaponCFG.Length; i++)
			if (default.WeaponCFG[i].WeaponClass == string(W.default.Class))
				for (j=0;j<default.WeaponCFG[i].BonusFor.Length;j++)
					if (default.WeaponCFG[i].BonusFor[j] == vet)
						return GetCoeff(default.WeaponCFG[i].MagSize, lvlmult);
	return 1.f;
}
//--------------------------------------------------------------------------------------------------
static simulated function float GetCapacityBonus(class<Ammunition> AmmoType, class<KFVeterancyTypes> vet, float lvlmult)
{
	local int i,j,n;
	for (i=0; i<default.WeaponCFG.Length; i++)
		for (n=0;n<default.WeaponCFG[i].BonusFor.Length;n++)
				if (default.WeaponCFG[i].BonusFor[n] == vet)
					for (j=0; j<2; j++)
						if (default.WeaponCFG[i].AmmoClass[j] == AmmoType)
							return GetCoeff(default.WeaponCFG[i].Capacity[j], lvlmult);
	return 1.f;
}
//--------------------------------------------------------------------------------------------------
static simulated function float GetHeadMultBonus(class<DamageType> DmgType, class<KFVeterancyTypes> vet, float lvlmult)
{
	local int i,j,n;
	for (i=0; i<default.WeaponCFG.Length; i++)
		for (n=0;n<default.WeaponCFG[i].BonusFor.Length;n++)
				if (default.WeaponCFG[i].BonusFor[n] == vet)
					for (j=0; j<2; j++)
						if (default.WeaponCFG[i].DamageType[j] == DmgType)
							return GetCoeff(default.WeaponCFG[i].HeadMult[j], lvlmult);
	return 1.f;
}
//--------------------------------------------------------------------------------------------------
static simulated function float GetDamageBonus(class<DamageType> DmgType, class<KFVeterancyTypes> vet, float lvlmult, int InDamage)
{
	local int i,j,n;
	for (i=0; i<default.WeaponCFG.Length; i++)
		for (n=0;n<default.WeaponCFG[i].BonusFor.Length;n++)
				if (default.WeaponCFG[i].BonusFor[n] == vet)
					for (j=0; j<2; j++)
						if (default.WeaponCFG[i].DamageType[j] == DmgType)
							return GetCoeff(default.WeaponCFG[i].Damage[j], lvlmult);
	return 1.f;
}
//--------------------------------------------------------------------------------------------------
//simulated function GenerateWeaponStats()
//--------------------------------------------------------------------------------------------------
/*simulated function float GetInvCoeff(float f, float lvlmult)
{
	local float ret;
	ret = (1-(f*lvlmult));
	if (ret==0)
		return 1;
	return ret;
}
simulated function float GetCoeff(float f, float lvlmult)
{
	local float ret;
	ret = f * lvlmult;
	if (ret==0)
		return 1;
	return ret;
}*/
//--------------------------------------------------------------------------------------------------
simulated function array<string> GetWeaponStats(WeaponConfigObject WI)
{
	local float		fltA[2], fvalue;
	local array<float> lvlmult;
	local int 		intA[2], i,j;
	local string	str;
	local bool		bHaveBonusPerks;
	local array<string> tOutput;
	local string delim;
	delim = "***";

	lvlmult[0]=0.f;
	lvlmult[1]=0.5f;
	lvlmult[2]=0.8f;
	lvlmult[3]=1.f;

	GetName(str);
	str@="BonusPerks:";
	for (i=0;i<WI.BonusFor.Length;i++)
	{
		str @= WI.BonusFor[i].Name$",";
		bHaveBonusPerks=true;
	}
	if (!bHaveBonusPerks)
		str@="doesnt have BonusPerks";
	str$=delim;

	GetDamage(intA);
	GetHeadMultiplier(fltA);
	for (i=0;i<2;i++)
	{
		str$="DAMAGE["$i$"]"$delim;
		str$="Default:"@intA[i]$delim;
		if (bHaveBonusPerks)
		{
			for (j=0;j<lvlmult.Length;j++)
			{
				fvalue = float(intA[i]) * GetCoeff(WI.Damage[i], lvlmult[j]);
				str$="Bonus["@lvlmult[j]@"]:"@ fvalue $ delim;
			}
		}
		str$="HEAD DAMAGE["$i$"]"$delim;
		fvalue = float(intA[i]) * WI.HeadMult[i].value;
		str$="Default:"@fvalue$delim;
		if (bHaveBonusPerks)
		{
			for (j=0;j<lvlmult.Length;j++)
			{
				fvalue = float(intA[i]) * GetCoeff(WI.Damage[i], lvlmult[j]);
				fvalue = fvalue * WI.HeadMult[i].value;
				fvalue = fvalue * GetCoeff(WI.HeadMult[i], lvlmult[j]);
				str$="Bonus["@lvlmult[j]@"]:"@ fvalue $ delim;
			}
		}
	}

	GetCost(intA[0]);
	str$="COST:"$delim;
	str$="Default:"@intA[0]$delim;
	if (bHaveBonusPerks)
	{
		for (j=0;j<lvlmult.Length;j++)
		{
			fvalue = float(intA[0]) * GetCoeff(WI.Cost, lvlmult[j], true);
			str$="Bonus["@lvlmult[j]@"]:"@ fvalue $delim;
		}
	}
	str$="-----"$delim;

	GetCapacity(intA);
	for (i=0;i<2;i++)
	{
		str$="CAPACITY["$i$"]"$delim;
		str$="Default:"@intA[i]$delim;
		if (bHaveBonusPerks)
		{
			for (j=0;j<lvlmult.Length;j++)
				str$="Bonus["@lvlmult[j]@"]:"@float(intA[i]) * GetCoeff(WI.Capacity[i], lvlmult[j])$delim;
		}
	}
	str$="-----"$delim;

	Split(str,delim,tOutput);
	/*GetWeight(Weight);
	GetMagazineSize(MagazineSize);
	GetFireRate(FireRate);
	GetReloadSpeed(ReloadSpeed);
	GetSpread(Spread);
	GetDamage(Damage);
	GetDamageRadius(DamageRadius);
	GetPellets(Pellets);
	GetMaxPens(MaxPens);
	GetPenReduction(PenReduction);
	GetRange(Range);*/

	return tOutput;
}
//--------------------------------------------------------------------------------------------------
simulated function SetWeaponStats()
{
	local int i, x, IArray[2];
	local float FArray[2];
	local WeaponConfigObject WI;
	local bool bDebug;
	bDebug=false;

	if (bDebug && Level != none && Level.NetMode==NM_Client)
		LM("SetWeaponStats routine");

	if (bDebug) LM("WeaponCFG.Length"@WeaponCFG.Length);
	if (bDebug) LM("default.WeaponCFG.Length"@default.WeaponCFG.Length);
	for (i = 0; i < WeaponCFG.Length; i++)
	{
		WI = WeaponCFG[i];
		if (WI==none || Len(WI.WeaponClass)==0) continue;
		if (bDebug) LM("SetWeaponStats"@WI.WeaponClass);
		Weapon = class<KFWeapon>(DynamicLoadObject(WI.WeaponClass, Class'Class'));
		if (Weapon==none) continue;
		Pickup = class<KFWeaponPickup>(Weapon.default.PickupClass);
		if (Pickup==none) continue;

		for (x = 0; x < 2; x++)
		{
			if (Weapon.default.FireModeClass[x] != none && IsTrueFire(Weapon.default.FireModeClass[x]))
				Fire[x] = Weapon.default.FireModeClass[x];
			else
				Fire[x] = none;
		}
		IArray[0] = WI.Damage[0].value;
		IArray[1] = WI.Damage[1].value;
		SetDamage(IArray);
		FArray[0] = WI.HeadMult[0].value;
		FArray[1] = WI.HeadMult[1].value;
		SetHeadMultiplier(FArray);
		SetCost(int(WI.Cost.value));
		SetAmmoCost(int(WI.AmmoCost.value));
		IArray[0] = WI.Capacity[0].value;
		IArray[1] = WI.Capacity[1].value;
		SetCapacity(IArray);
		SetMagazineSize(int(WI.MagSize.value));
		SetWeight(int(WI.Weight.value));
		SetReloadRate(WI.ReloadRate.value);
		FArray[0] = WI.Spread[0].value;
		FArray[1] = WI.Spread[1].value;
		SetSpread(FArray);
		SetRecoilX(WI.RecoilX);
		SetRecoilY(WI.RecoilY);
		FArray[0] = WI.FireRate[0].value;
		FArray[1] = WI.FireRate[1].value;
		SetFireRate(FArray);

		//SetDamageMult(WI.DamageMult);
		/*
		GetName(Name);
		GetPerk(Perk);
		GetCost(Cost);
		GetAmmoCost(AmmoCost);
		GetWeight(Weight);
		GetCapacity(Capacity);
		GetMagazineSize(MagazineSize);
		GetFireRate(FireRate);
		GetReloadSpeed(ReloadSpeed);
		GetSpread(Spread);
		GetDamage(Damage);
		GetDamageRadius(DamageRadius);
		GetHeadMultiplier(HeadMultiplier);
		GetPellets(Pellets);
		GetMaxPens(MaxPens);
		GetPenReduction(PenReduction);
		GetRange(Range);

		OutputStat("Name", 			Name);
		OutputStat("Perk",			Perk);
		OutputStatNum("Cost", 		Cost);
		OutputStatNum("Weight",	 	Weight);
		OutputStatNum("Ammo cost",	AmmoCost);
		OutputStatNum("Capacity", 	Capacity[0], Capacity[1]);
		OutputStatNum("Magazine", 	MagazineSize[0], MagazineSize[1]);
		OutputStatNum("Damage", 	Damage[0], Damage[1]);
		OutputStatNum("Radius", 	DamageRadius[0], DamageRadius[0]);
		OutputStatNum("Head", 		HeadMultiplier[0], HeadMultiplier[1] );
		OutputStatNum("Pellets", 	Pellets[0], Pellets[1]);
		OutputStatNum("Spread", 	Spread[0], Spread[1]);
		OutputStatNum("Max pens",	MaxPens[0], MaxPens[1]);
		OutputStatNum("Pen reduc",	PenReduction[0], PenReduction[1]);
		OutputStatNum("Fire rate", 	FireRate[0], FireRate[1]);
		OutputStatNum("Reload sp",	ReloadSpeed[0], ReloadSpeed[1]);
		Log("");
		*/
	}
}
//--------------------------------------------------------------------------------------------------
simulated function GenerateSpecimenStats()
{
	local string	Name;
	local int		Bounty[5];
	local int		Health[5];
	local float		HeadHealth[5];
	local float		Speed[5];
	local int		Damage[5];
	local float		Range;

	local KFGameType KF;
	local int i;

	KF = KFGameType(Level.Game);

	Log("===========================================================");
	Log("SPECIMEN STATS ============================================");
	Log("===========================================================");

	SpecimenCount = KF.StandardMonsterClasses.Length;
	for (i = 0; i < SpecimenCount; i++)
	{
		// Log("Specimen #" $ i $ ":" @ class'KFGameType'.default.StandardMonsterClasses[i].MClassName);

		KFM = class<KFMonster>(DynamicLoadObject(class'KFGameType'.default.
			StandardMonsterClasses[i].MClassName, class'class'));

		GetSpecimenName(Name);
		GetSpecimenBounty(Bounty);
		GetSpecimenHealth(Health);
		GetSpecimenHeadHealth(HeadHealth);
		GetSpecimenSpeed(Speed);
		GetSpecimenDamage(Damage);
		GetSpecimenRange(Range);

		Log("Name:       " $ Name);
		Log("Bounty:     " $ Bounty[0] @ Bounty[1] @ Bounty[2] @ Bounty[3] @ Bounty[4]);
		Log("Health:     " $ Health[0] @ Health[1] @ Health[2] @ Health[3] @ Health[4]);
		Log("HeadHealth: " $ HeadHealth[0] @ HeadHealth[1] @ HeadHealth[2] @ HeadHealth[3] @ HeadHealth[4]);
		Log("Speed:      " $ Speed[0] @ Speed[1] @ Speed[2] @ Speed[3] @ Speed[4]);
		Log("Damage:     " $ Damage[0] @ Damage[1] @ Damage[2] @ Damage[3] @ Damage[4]);
		Log("Range:      " $ Range);
		Log("");
	}

	Log("");
}
//--------------------------------------------------------------------------------------------------
/*simulated function PostBeginPlay()
{
	GenerateWeaponStats();
	GenerateSpecimenStats();
}*/

///////////////////////////////////////////////////////////////////////////////
// SPECIMEN STAT CALCULATION
///////////////////////////////////////////////////////////////////////////////

simulated function GetSpecimenName(out string Name)
{
	Name = KFM.default.MenuName;
}

simulated function GetSpecimenBounty(out int KillScore[5])
{
	local int i;

	for (i = 0; i < 5; i++)
		KillScore[i] = Max(1, int(KFM.default.ScoringValue * BountyMultiplier[i]));
}

simulated function GetSpecimenHealth(out int Health[5])
{
	local int i;

	for (i = 0; i < 5; i++)
		Health[i] = Ceil(KFM.default.Health * HealthMultiplier[i]);
}

simulated function GetSpecimenHeadHealth(out float HeadHealth[5])
{
	local int i;

	for (i = 0; i < 5; i++)
		HeadHealth[i] = Ceil(KFM.default.HeadHealth * HeadHealthMultiplier[i]);
}

simulated function GetSpecimenSpeed(out float Speed[5])
{
	local int i;

	for (i = 0; i < 5; i++)
		Speed[i] = KFM.default.GroundSpeed * SpeedMultiplier[i];
}

simulated function GetSpecimenDamage(out int Damage[5])
{
	local int i;

	for (i = 0; i < 5; i++)
		Damage[i] = KFM.default.MeleeDamage * DamageMultiplier[i];
}

simulated function GetSpecimenRange(out float Range)
{
	Range = KFM.default.MeleeRange;
}

///////////////////////////////////////////////////////////////////////////////
// WEAPON STAT CALCULATION
///////////////////////////////////////////////////////////////////////////////

simulated function GetName(out string Name)
{
	Name = Pickup.default.ItemName;
}

simulated function GetPerk(out string Perk)
{
	Perk = KFGameType(Level.Game).default.
		LoadedSkills[Pickup.default.CorrespondingPerkIndex].default.VeterancyName;
}
//--------------------------------------------------------------------------------------------------
simulated function SetCost(int Cost)
{
	if (Cost==0) return;
	Pickup.default.Cost = Cost;
}
//--------------------------------------------------------------------------------------------------
simulated function GetCost(out int Cost)
{
	Cost = Pickup.default.Cost;
}
//--------------------------------------------------------------------------------------------------
simulated function SetAmmoCost(int AmmoCost)
{
	if (AmmoCost==0) return;
	Pickup.default.AmmoCost = AmmoCost;
}
//--------------------------------------------------------------------------------------------------
simulated function GetAmmoCost(out int AmmoCost)
{
	AmmoCost = Pickup.default.AmmoCost;
}
//--------------------------------------------------------------------------------------------------
simulated function SetWeight(int Weight)
{
	if (Weight==0)
		return;
	Weapon.default.Weight = Weight;
	Pickup.default.Weight = Weight;
}
//--------------------------------------------------------------------------------------------------
simulated function GetWeight(out int Weight)
{
	Weight = Pickup.default.Weight;
}
//--------------------------------------------------------------------------------------------------
simulated function SetCapacity(int Capacity[2], optional int Index)
{
	if (Index == 0) SetCapacity(Capacity, 1);
	if (Capacity[Index] == 0) return;
	if (Fire[Index] != none && !IsMeleeFire(Fire[Index]) && Fire[Index].default.AmmoClass != none)
		Fire[Index].default.AmmoClass.default.MaxAmmo = Capacity[Index];
}
//--------------------------------------------------------------------------------------------------
simulated function GetCapacity(out int Capacity[2], optional int Index)
{
	Capacity[Index] = 0;
	if (Index == 0) GetCapacity(Capacity, 1);

	if (Fire[Index] != none && !IsMeleeFire(Fire[Index]) && Fire[Index].default.AmmoClass != none)
		Capacity[Index] = Fire[Index].default.AmmoClass.default.MaxAmmo;
}
//--------------------------------------------------------------------------------------------------
simulated function SetMagazineSize(int MagazineSize)
{
	if (MagazineSize==0) return;
	 Weapon.default.MagCapacity = MagazineSize;
	//MagazineSize[1] = 0; // Can't be obtained normally
}
//--------------------------------------------------------------------------------------------------
simulated function GetMagazineSize(out int MagazineSize[2])
{
	MagazineSize[0] = Weapon.default.MagCapacity;
	MagazineSize[1] = 0; // Can't be obtained normally
}
//--------------------------------------------------------------------------------------------------
simulated function SetFireRate(float FireRate[2], optional int Index)
{
	local float coeff;

	if (Index == 0) SetFirerate(FireRate, 1);
	if (FireRate[Index] == 0.f) return;
	if (!IsAutoReloadingWeapon(Weapon)) // (4) Weapons that fire-reload in one animation
	{
		if (Fire[Index] != none)
		{
			coeff = Fire[Index].default.FireRate / FireRate[Index];
			Fire[Index].default.FireAnimRate *= coeff;
			Fire[Index].default.FireLoopAnimRate *= coeff;
			Fire[Index].default.FireRate = FireRate[Index];
		}
	}
}
//--------------------------------------------------------------------------------------------------
static simulated function float GetFireRateBonus(Weapon W, class<KFVeterancyTypes> vet, float lvlmult)
{
	local int i,j;
	for (i=0; i<default.WeaponCFG.Length; i++)
			if (default.WeaponCFG[i].WeaponClass == string(W.default.Class))
				for (j=0;j<default.WeaponCFG[i].BonusFor.Length;j++)
					if (default.WeaponCFG[i].BonusFor[j] == vet)
						return GetCoeff(default.WeaponCFG[i].FireRate[0], lvlmult);
	return 1.f;
}
//--------------------------------------------------------------------------------------------------
/*simulated function GetRecoil(out float Recoil[2], optional int Index)
{
	Recoil[Index] = 0;
	if (Index == 0) GetRecoil(Recoil, 1);

	if (Fire[Index] != none)
	{
		if (class<KFFire>(Fire[Index]) != none) // HITSCAN
			Recoil[Index] = class<KFFire>(Fire[Index]).default.RecoilRate;
		else if (class<KFShotgunFire>(Fire[Index]) != none) // HITSCAN
			Recoil[Index] = class<KFShotgunFire>(Fire[Index]).default.RecoilRate;
	}
}
//--------------------------------------------------------------------------------------------------
simulated function SetRecoil(out float Recoil[2], optional int Index)
{
	if (Index == 0) SetRecoil(Recoil, 1);
	if (Recoil[Index] == 0.f) return;

	if (Fire[Index] != none)
	{
		if (class<KFFire>(Fire[Index]) != none) // HITSCAN
			class<KFFire>(Fire[Index]).default.RecoilRate = Recoil[Index];
		else if (class<KFShotgunFire>(Fire[Index]) != none) // HITSCAN
			class<KFShotgunFire>(Fire[Index]).default.RecoilRate = Recoil[Index];
	}
}*/
//--------------------------------------------------------------------------------------------------
simulated function SetRecoilX(float Recoil[2], optional int Index)
{
	if (Index == 0) SetRecoilX(Recoil, 1);
	if (Recoil[Index] == 0)
		return;
	if (Fire[Index] != none)
	{
		if (class<KFFire>(Fire[Index]) != none)
			class<KFFire>(Fire[Index]).default.maxHorizontalRecoilAngle = Recoil[Index];
		else if (class<KFShotgunFire>(Fire[Index]) != none)
			class<KFShotgunFire>(Fire[Index]).default.maxHorizontalRecoilAngle = Recoil[Index];
	}
}
//--------------------------------------------------------------------------------------------------
simulated function GetRecoilX(out float Recoil[2], optional int Index)
{
	Recoil[Index] = 0;
	if (Index == 0) GetRecoilX(Recoil, 1);
	if (Fire[Index] != none)
	{
		if (class<KFFire>(Fire[Index]) != none)
			Recoil[Index] = class<KFFire>(Fire[Index]).default.maxHorizontalRecoilAngle;
		else if (class<KFShotgunFire>(Fire[Index]) != none)
			Recoil[Index] = class<KFShotgunFire>(Fire[Index]).default.maxHorizontalRecoilAngle;
	}
}
//--------------------------------------------------------------------------------------------------
simulated function SetRecoilY(float Recoil[2], optional int Index)
{
	if (Index == 0) SetRecoilY(Recoil, 1);
	if (Recoil[Index] == 0)
		return;
	if (Fire[Index] != none)
	{
		if (class<KFFire>(Fire[Index]) != none)
			class<KFFire>(Fire[Index]).default.maxVerticalRecoilAngle = Recoil[Index];
		else if (class<KFShotgunFire>(Fire[Index]) != none)
			class<KFShotgunFire>(Fire[Index]).default.maxVerticalRecoilAngle = Recoil[Index];
	}
}
//--------------------------------------------------------------------------------------------------
simulated function GetRecoilY(out float Recoil[2], optional int Index)
{
	Recoil[Index] = 0;
	if (Index == 0) GetRecoilY(Recoil, 1);
	if (Fire[Index] != none)
	{
		if (class<KFFire>(Fire[Index]) != none)
			Recoil[Index] = class<KFFire>(Fire[Index]).default.maxVerticalRecoilAngle;
		else if (class<KFShotgunFire>(Fire[Index]) != none)
			Recoil[Index] = class<KFShotgunFire>(Fire[Index]).default.maxVerticalRecoilAngle;
	}
}
//--------------------------------------------------------------------------------------------------
simulated function SetSpread(float Spread[2], optional int Index)
{
	if (Index == 0) SetSpread(Spread, 1);
	if (Spread[Index] == 0)
		return;
	if (Fire[Index] != none)
		(Fire[Index]).default.Spread = Spread[Index];
}
//--------------------------------------------------------------------------------------------------
simulated function GetSpread(out float Spread[2], optional int Index)
{
	Spread[Index] = 0;
	if (Index == 0) GetSpread(Spread, 1);
	if (Fire[Index] != none)
		Spread[Index] = (Fire[Index]).default.Spread;
}
//--------------------------------------------------------------------------------------------------
static simulated function float GetSpreadBonus(Weapon W, class<KFVeterancyTypes> vet, float lvlmult)
{
	local int i,j;
	for (i=0; i<default.WeaponCFG.Length; i++)
			if (default.WeaponCFG[i].WeaponClass == string(W.default.Class))
				for (j=0;j<default.WeaponCFG[i].BonusFor.Length;j++)
					if (default.WeaponCFG[i].BonusFor[j] == vet)
						return GetCoeff(default.WeaponCFG[i].Spread[0], lvlmult, true);
	return 1.f;
}
//--------------------------------------------------------------------------------------------------
simulated function SetReloadRate(float ReloadRate)
{
	if (ReloadRate==0.f) return;
	//if (class<KFWeapon>(Weapon) != none)
	(Weapon).default.ReloadRate = ReloadRate;
}
//--------------------------------------------------------------------------------------------------
simulated function GetReloadRate(out float ReloadRate)
{
	//if (class<KFWeapon>(Weapon) != none)
	ReloadRate = (Weapon).default.ReloadRate;
}
//--------------------------------------------------------------------------------------------------
static simulated function float GetReloadRateBonus(Weapon W, class<KFVeterancyTypes> vet, float lvlmult)
{
	local int i,j;
	for (i=0; i<default.WeaponCFG.Length; i++)
			if (default.WeaponCFG[i].WeaponClass == string(W.default.Class))
				for (j=0;j<default.WeaponCFG[i].BonusFor.Length;j++)
					if (default.WeaponCFG[i].BonusFor[j] == vet)
						return GetCoeff(default.WeaponCFG[i].ReloadRate, lvlmult);
	return 1.f;
}
//--------------------------------------------------------------------------------------------------
simulated function GetFireRate(out float FireRate[2], optional int Index)
{
	FireRate[Index] = 0;
	if (Index == 0) GetFirerate(FireRate, 1);

	if (IsAutoReloadingWeapon(Weapon)) // (4) Weapons that fire-reload in one animation
		FireRate[Index] = 0;
	else
	{
		if (Fire[Index] != none)
			FireRate[Index] = Fire[Index].default.FireRate;
	}
}
//--------------------------------------------------------------------------------------------------
simulated function GetReloadSpeed(out float ReloadSpeed[2], optional int Index)
{
	ReloadSpeed[Index] = 0;
	if (Index == 0) GetReloadSpeed(ReloadSpeed, 1);

	if (IsAutoReloadingWeapon(Weapon)) // (4) Weapons that fire-reload in one animation
		if (Fire[Index] != none)
			ReloadSpeed[Index] = Fire[Index].default.FireRate;
	else
	{
		if (Fire[Index] != none)
			ReloadSpeed[Index] = Weapon.default.ReloadRate; // (3)
	}
}
//--------------------------------------------------------------------------------------------------
simulated function SetDamage(int Damage[2], optional int Index)
{
	local float diff;
	if (Index == 0) SetDamage(Damage, 1);

	if (Damage[Index] == 0)
		return;

	if (Fire[Index] != none)
	{
		if (class<InstantFire>(Fire[Index]) != none) // HITSCAN
		{
			diff = float(class<InstantFire>(Fire[Index]).default.DamageMin) / float(class<InstantFire>(Fire[Index]).default.DamageMax);
			class<InstantFire>(Fire[Index]).default.DamageMax = Damage[Index];
			class<InstantFire>(Fire[Index]).default.DamageMin = FMax(Round(diff * float(Damage[Index])),0.1f);
		}
		else if(class<BaseProjectileFire>(Fire[Index]) != none) // PROJECTILE
		{
			if (class<MP7MMedicGun>(Weapon) != none)
				class<MP7MMedicGun>(Weapon).default.HealBoostAmount = Damage[Index];
			else if (class<M7A3MMedicGun>(Weapon) != none)
				class<M7A3MMedicGun>(Weapon).default.HealBoostAmount = Damage[Index];
			else
				class<BaseProjectileFire>(Fire[Index]).default.ProjectileClass.default.Damage = Damage[Index];
		}
		else if (class<KFMeleeFire>(Fire[Index]) != none) // MELEE
		{
			//diff = class<KFMeleeFire>(Fire[Index]).default.MaxAdditionalDamage / class<KFMeleeFire>(Fire[Index]).default.MeleeDamage;
			class<KFMeleeFire>(Fire[Index]).default.MeleeDamage = Damage[Index];
			//class<KFMeleeFire>(Fire[Index]).default.MaxAdditionalDamage = Damage[Index] * diff;
		}
	}
}
//--------------------------------------------------------------------------------------------------
simulated function GetDamage(out int Damage[2], optional int Index)
{
	Damage[Index] = 0;
	if (Index == 0) GetDamage(Damage, 1);

	if (Fire[Index] != none)
	{
		if (class<InstantFire>(Fire[Index]) != none) // HITSCAN
			Damage[Index] = class<InstantFire>(Fire[Index]).default.DamageMax;
		else if(class<BaseProjectileFire>(Fire[Index]) != none) // PROJECTILE
		{
			if (class<MP7MMedicGun>(Weapon) != none)
				Damage[Index] = class<MP7MMedicGun>(Weapon).default.HealBoostAmount;
			else if (class<M7A3MMedicGun>(Weapon) != none)
				Damage[Index] = class<M7A3MMedicGun>(Weapon).default.HealBoostAmount;
			else
				Damage[Index] = class<BaseProjectileFire>(Fire[Index]).default.ProjectileClass.default.Damage;
		}
		else if (class<KFMeleeFire>(Fire[Index]) != none) // MELEE
		{
			Damage[Index] = class<KFMeleeFire>(Fire[Index]).default.MeleeDamage;
			//+class<KFMeleeFire>(Fire[Index]).default.MaxAdditionalDamage;
		}
	}
}
//--------------------------------------------------------------------------------------------------
simulated function GetDamageRadius(out float DamageRadius[2], optional int Index)
{
	local class<DamageType> DT;

	DamageRadius[Index] = 0;
	if (Index == 0) GetDamageRadius(DamageRadius, 1);

	if (Fire[Index] != none && class<BaseProjectileFire>(Fire[Index]) != none)
	{
		DT = class<BaseProjectileFire>(Fire[Index]).default.ProjectileClass.default.MyDamageType;
		if (class<KFWeaponDamageType>(DT) != none)
		{
			if (class<KFWeaponDamageType>(DT).default.bIsExplosive)
				DamageRadius[Index] = class<BaseProjectileFire>(Fire[Index]).default.ProjectileClass.default.DamageRadius;
		}
	}
}
//--------------------------------------------------------------------------------------------------
simulated function SetHeadMultiplier(float HeadMultiplier[2], optional int Index)
{
	local class<Projectile> P;

	if (Index == 0) SetHeadMultiplier(HeadMultiplier, 1);

	if (HeadMultiplier[Index] == 0)
		return;

	if (Fire[Index] != none)
	{
		if (class<InstantFire>(Fire[Index]) != none) // HITSCAN
		{
			if (class<KFWeaponDamageType>(class<InstantFire>(Fire[Index]).default.DamageType) != none)
				class<KFWeaponDamageType>(
					class<InstantFire>(Fire[Index]).default.DamageType).default.HeadShotDamageMult = HeadMultiplier[Index];
		}
		else if (class<BaseProjectileFire>(Fire[Index]) != none) // PROJECTILE
		{
			P = class<BaseProjectileFire>(Fire[Index]).default.ProjectileClass;

			if (P == class'CrossbuzzsawBlade') // Buzzsaw bow
				class<CrossbuzzsawBlade>(P).default.HeadShotDamageMult = HeadMultiplier[Index];
			else if (P == class'CrossbowArrow') // CROSSBOW
				class<CrossbowArrow>(P).default.HeadShotDamageMult = HeadMultiplier[Index];
			else if (P == class'M99Bullet') // M99
				class<M99Bullet>(P).default.HeadShotDamageMult = HeadMultiplier[Index];
			else if ( P.default.MyDamageType != none &&
				class<KFWeaponDamageType>(P.default.MyDamageType) != none ) // ANY OTHER PROJECTILES USE DAMAGETYPE
					class<KFWeaponDamageType>(P.default.MyDamageType).default.HeadShotDamageMult = HeadMultiplier[Index];
		}
		else if (class<KFMeleeFire>(Fire[Index]) != none) // MELEE
		{
			if (class<DamTypeMelee>(class<KFMeleeFire>(Fire[Index]).default.hitDamageClass) != none)
				class<DamTypeMelee>(class<KFMeleeFire>(Fire[Index]).default.hitDamageClass).default.HeadShotDamageMult = HeadMultiplier[Index];
		}
	}
}
//--------------------------------------------------------------------------------------------------
simulated function GetHeadMultiplier(out float HeadMultiplier[2], optional int Index)
{
	local class<Projectile> P;

	HeadMultiplier[Index] = 1.0;
	if (Index == 0) GetHeadMultiplier(HeadMultiplier, 1);

	if (Fire[Index] != none)
	{
		if (class<InstantFire>(Fire[Index]) != none) // HITSCAN
		{
			if (class<KFWeaponDamageType>(class<InstantFire>(Fire[Index]).default.DamageType) != none)
				HeadMultiplier[Index] = class<KFWeaponDamageType>(
					class<InstantFire>(Fire[Index]).default.DamageType).default.HeadShotDamageMult;
		}
		else if (class<BaseProjectileFire>(Fire[Index]) != none) // PROJECTILE
		{
			P = class<BaseProjectileFire>(Fire[Index]).default.ProjectileClass;

			if (P == class'CrossbuzzsawBlade') // Buzzsaw bow
				HeadMultiplier[Index] = class<CrossbuzzsawBlade>(P).default.HeadShotDamageMult;
			else if (P == class'CrossbowArrow') // CROSSBOW
				HeadMultiplier[Index] = class<CrossbowArrow>(P).default.HeadShotDamageMult;
			else if (P == class'M99Bullet') // M99
				HeadMultiplier[Index] = class<M99Bullet>(P).default.HeadShotDamageMult;
			else if ( P.default.MyDamageType != none &&
				class<KFWeaponDamageType>(P.default.MyDamageType) != none ) // ANY OTHER PROJECTILES USE DAMAGETYPE
					HeadMultiplier[Index] = class<KFWeaponDamageType>(P.default.MyDamageType).default.HeadShotDamageMult;
		}
		else if (class<KFMeleeFire>(Fire[Index]) != none) // MELEE
		{
			if (class<DamTypeMelee>(class<KFMeleeFire>(Fire[Index]).default.hitDamageClass) != none)
				HeadMultiplier[Index] = class<DamTypeMelee>(class<KFMeleeFire>(Fire[Index]).default.hitDamageClass).default.HeadShotDamageMult;
		}
	}
}
//--------------------------------------------------------------------------------------------------
simulated function GetPellets(out int Pellets[2], optional int Index)
{
	Pellets[Index] = 0;
	if (Index == 0) GetPellets(Pellets, 1);

	if (Fire[Index] != none && class<KFShotgunFire>(Fire[Index]) != none)
	{
		if (IgnoresLoad(Fire[Index])) // (1) see note
			Pellets[Index] = class<BaseProjectileFire>(Fire[Index]).default.ProjPerFire;
		else
		Pellets[Index] = class<BaseProjectileFire>(Fire[Index]).default.ProjPerFire *
			class<BaseProjectileFire>(Fire[Index]).default.AmmoPerFire;
	}
}

simulated function GetMaxPens(out int MaxPens[2], optional int Index)
{
	local class<Projectile> P;

	MaxPens[Index] = 0;
	if (Index == 0) GetMaxPens(MaxPens, 1);

	if (class<InstantFire>(Fire[Index]) != none) // HITSCAN
	{
		// (2) Deagle, MK23, 44Magnum
	}
	else if (class<BaseProjectileFire>(Fire[Index]) != none) // PROJECTILE
	{
		P = class<BaseProjectileFire>(Fire[Index]).default.ProjectileClass;

		if (class<ShotgunBullet>(P) != none)
			MaxPens[Index] = class<ShotgunBullet>(P).default.MaxPenetrations;
	}
}

simulated function GetPenReduction(out float PenReduction[2], optional int Index)
{
	local class<Projectile> P;

	PenReduction[Index] = 0;
	if (Index == 0) GetPenReduction(PenReduction, 1);

	if (class<BaseProjectileFire>(Fire[Index]) != none)
	{
		P = class<BaseProjectileFire>(Fire[Index]).default.ProjectileClass;
		if (class<ShotgunBullet>(P) != none)
			PenReduction[Index] = class<ShotgunBullet>(P).default.PenDamageReduction;
	}
}

simulated function GetRange(out float Range)
{
	if (class<KFMeleeFire>(Fire[0]) != none)
		Range = class<KFMeleeFire>(Fire[0]).default.WeaponRange;
	else
		Range = 0;
}

// Utilities

simulated function bool IsTrueFire(class<WeaponFire> Fire)
{
	if (Fire.Name == 'NoFire'
		|| Fire.Name == 'ShotgunLightFire'
		|| Fire.Name == 'SingleALTFire'
		)
		return false;

	return true;
}

simulated function bool IsMeleeFire(class<WeaponFire> Fire)
{
	if (Fire == none)
		return false;
	if (class<KFMeleeFire>(Fire) != none)
		return true;
	return false;
}

simulated function bool IgnoresLoad(class<WeaponFire> Fire)
{
	if (class<MP7MAltFire>(Fire) != none
		|| class<M7A3MAltFire>(Fire) != none)

		return true;

	return false;
}

simulated function bool IsAutoReloadingWeapon(class<Weapon> Weapon) // (4)
{
	if (Weapon == class'KFMod.Boomstick')
		return true;
	else if (Weapon == class'KFMod.M79GrenadeLauncher')
		return true;
	else if (Weapon == class'KFMod.Crossbow')
		return true;
	else if (Weapon == class'KFMod.LAW')
		return true;
	else if (Weapon == class'KFMod.M99SniperRifle')
		return true;
	else if (Weapon == class'KFMod.Crossbuzzsaw')
		return true;

	return false;
}
//--------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------
defaultproperties
{
	GroupName="WeaponConfigMut"
	FriendlyName"WeaponConfig"
	Description="..."
	GameDifficulty=(1.0, 2.0, 4.0, 5.0, 7.0)
	BountyMultiplier=(2.0, 1.0, 0.85, 0.65, 0.65)
	HealthMultiplier=(0.5, 1.0, 1.35, 1.55, 1.75)
	HeadHealthMultiplier=(0.5, 1.0, 1.35, 1.55, 1.75)
	SpeedMultiplier=(0.95, 1.0, 1.15, 1.22, 1.3)
	DamageMultiplier=(0.3, 1.0, 1.25, 1.50, 1.75)

	bNetNotify = true
	bAlwaysRelevant = true
	RemoteROLE = ROLE_SimulatedProxy
	rDataDelim = "***"
}