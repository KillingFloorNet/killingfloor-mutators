class AdvArena extends Mutator;

var() config array<string>	WeaponClassNames;
var() config bool			bRandomPickOne;
var() config bool			bRandomPerSpawn;
var   array<class<weapon> >	WeaponClasses;

function PreBeginPlay ()
{
	local int i;
	local class<weapon> W;

	super.PreBeginPlay();

	if (bRandomPickOne)
		DefaultWeaponName = WeaponClassNames[Rand(WeaponClassNames.length)];

	for (i=0;i<WeaponClassNames.length;i++)
	{
		W = class<weapon>(DynamicLoadObject(WeaponClassNames[i],class'Class'));
		if (W != None)
			WeaponClasses[WeaponClasses.length] = W;
	}
}
function ModifyPlayer(Pawn Other)
{
	local int i;
	local byte LP;
	local class<weapon> W;

	Super.ModifyPlayer(Other);

	if (bRandomPerSpawn)
	{
		W = WeaponClasses[Rand(WeaponClasses.length)];
		SpawnWeapon(W, Other);
		SpawnAmmo(W.default.FireModeClass[0].default.AmmoClass, Other);
		if (W.default.FireModeClass[1].default.AmmoClass != None && W.default.FireModeClass[0].default.AmmoClass != W.default.FireModeClass[1].default.AmmoClass)
			SpawnAmmo(W.default.FireModeClass[1].default.AmmoClass, Other);
		Other.Controller.ClientSwitchToBestWeapon();
		KFHumanPawn(Other).RequiredEquipment[0] = string(W);
		return;
	}
	if (bRandomPickOne)
		return;

	for (i=0;i<WeaponClasses.length;i++)
	{
		SpawnWeapon(WeaponClasses[i], Other);
		if (WeaponClasses[i].default.Priority > LP)
		{
			LP = WeaponClasses[i].default.Priority;
			KFHumanPawn(Other).RequiredEquipment[0] = string(WeaponClasses[i]);
		}
		if (KFHumanPawn(Other) != None)
		{
			SpawnAmmo(WeaponClasses[i].default.FireModeClass[0].default.AmmoClass, Other);
			if (WeaponClasses[i].default.FireModeClass[0].default.AmmoClass != WeaponClasses[i].default.FireModeClass[1].default.AmmoClass)
				SpawnAmmo(WeaponClasses[i].default.FireModeClass[1].default.AmmoClass, Other);
		}
	}
	Other.Controller.ClientSwitchToBestWeapon();
}
function class<Weapon> MyDefaultWeapon()
{
	if (!bRandomPickOne || bRandomPerSpawn)
		return None;
	return super.MyDefaultWeapon();
}
function string GetInventoryClassOverride(string InventoryClassName)
{
	return Super(Mutator).GetInventoryClassOverride(InventoryClassName);
}

function ItemPickedUp(Pickup Other);
function ItemChange(Pickup Other);

static function SpawnWeapon(class<weapon> newClass, Pawn P)
{
	local Weapon newWeapon;

    if( (newClass!=None) && P != None && (P.FindInventoryType(newClass)==None) )
    {
        newWeapon = P.Spawn(newClass,,,P.Location);
        if( newWeapon != None )
            newWeapon.GiveTo(P);
    }
}
static function SpawnAmmo(class<Ammunition> newClass, Pawn P, optional float Multiplier)
{
	local Ammunition Ammo;

	if (P==None || newClass == None)
		return;
	Ammo = Ammunition(P.FindInventoryType(newClass));
	if(Ammo == None)
    {
		Ammo = P.Spawn(newClass);
		P.AddInventory(Ammo);
    }
	if(Ammo == None)
		return;
    if (Multiplier > 0)
		Ammo.AddAmmo(Ammo.InitialAmount*Multiplier);
    else
		Ammo.AddAmmo(Ammo.InitialAmount);
	Ammo.GotoState('');
}

function bool CheckReplacement( Actor Other, out byte bSuperRelevant )
{
	local int i;

	bSuperRelevant = 0;
	if (Weapon(Other) != None)
	{
		for (i=0;i<WeaponClasses.length;i++)
			if (WeaponClasses[i] == Other.class)
				return true;
		return false;
	}
	else if (KFHumanPawn(Other) != None)
	{
		KFHumanPawn(Other).RequiredEquipment[0] = "";
		KFHumanPawn(Other).RequiredEquipment[1] = "";
		return true;
	}
	else if (WeaponPickup(Other) != None && Other.Owner == None)
	{
		return false;
	}


	return Super.CheckReplacement( Other, bSuperRelevant );
}

defaultproperties
{
     ConfigMenuClassName="ArenaMut.ArenaMenu"
     GroupName="KF-AdvArena"
     FriendlyName="Advanced Weapon Arena"
     Description="A highly advanced weapon arena"
}
