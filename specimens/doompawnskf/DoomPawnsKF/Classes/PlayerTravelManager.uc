// Written by Marco
Class PlayerTravelManager extends Object;

struct TravelWeaponInfo
{
	var string WeaponClass;
	var int AmmoCount[2],ClipLeft;
};
struct TravelPlayerInfo
{
	var array<TravelWeaponInfo> Weapons;
	var int Health,Armor;
	var string PlayerName;
};
var array<TravelPlayerInfo> TravelInfo;

static final function ResetTravel()
{
	Default.TravelInfo.Length = 0;
}
static final function SaveTravel( LevelInfo Level, bool bNoSaveNew )
{
	local Controller C;
	local int i,l;
	local bool bRes;
	local GameEngine GE;

	foreach Level.AllObjects(Class'GameEngine',GE)
	{
		l = GE.DummyArray.Length;
		for( i=0; i<l; i++ )
			if( GE.DummyArray[i]==Class'PlayerTravelManager' )
			{
				bRes = true;
				break;
			}
		if( !bRes )
			GE.DummyArray[GE.DummyArray.Length] = Class'PlayerTravelManager';
		break;
	}
	if( bNoSaveNew )
		return;
	l = Default.TravelInfo.Length;
	for( C=Level.ControllerList; C!=None; C=C.NextController )
	{
		if( PlayerController(C)!=None && C.Pawn!=None && C.Pawn.Health>0 && KFPawn(C.Pawn)!=None )
		{
			bRes = false;
			for( i=0; i<l; i++ )
				if( Default.TravelInfo[i].PlayerName==C.PlayerReplicationInfo.PlayerName )
				{
					bRes = true;
					SavePlayerInv(KFPawn(C.Pawn),i);
					break;
				}
			if( bRes )
				continue;
			i = l;
			Default.TravelInfo.Length = ++l;
			Default.TravelInfo[i].PlayerName = C.PlayerReplicationInfo.PlayerName;
			SavePlayerInv(KFPawn(C.Pawn),i);
		}
	}
	//DebugLogData();
}
static final function SavePlayerInv( KFPawn Other, int Index )
{
	local Inventory Inv;
	local int i;

	Default.TravelInfo[Index].Health = Other.Health;
	Default.TravelInfo[Index].Armor = int(Other.ShieldStrength);
	Default.TravelInfo[Index].Weapons.Length = 0;
	for( Inv=Other.Inventory; Inv!=None; Inv=Inv.Inventory )
	{
		if( KFWeapon(Inv)!=None )
		{
			Default.TravelInfo[Index].Weapons.Length = (i+1);
			Default.TravelInfo[Index].Weapons[i].WeaponClass = string(Inv.Class);
			Default.TravelInfo[Index].Weapons[i].ClipLeft = KFWeapon(Inv).MagAmmoRemaining;
			Default.TravelInfo[Index].Weapons[i].AmmoCount[0] = Weapon(Inv).AmmoAmount(0);
			Default.TravelInfo[Index].Weapons[i].AmmoCount[1] = Weapon(Inv).AmmoAmount(1);
			i++;
		}
	}
}
static final function LoadPlayerInv( KFPawn Other, bool bNoCleanup )
{
	local int i,l,j;

	if( Other.PlayerReplicationInfo==None )
		return;
	l = Default.TravelInfo.Length;
	for( i=0; i<l; i++ )
		if( Default.TravelInfo[i].PlayerName==Other.PlayerReplicationInfo.PlayerName )
		{
			Other.Health = Default.TravelInfo[i].Health;
			Other.ShieldStrength = Default.TravelInfo[i].Armor;
			for( j=0; j<Default.TravelInfo[i].Weapons.Length; j++ )
				GivePlayerWeapon(Other,Default.TravelInfo[i].Weapons[j]);
			if( !bNoCleanup )
				Default.TravelInfo.Remove(i,1);
			return;
		}
}
static final function GivePlayerWeapon( KFPawn Other, TravelWeaponInfo WeaponInfo )
{
	local class<KFWeapon> WC;
	local KFWeapon W;
	local byte i;
	local int c;

	WC = class<KFWeapon>(DynamicLoadObject(WeaponInfo.WeaponClass,Class'Class',true));
	if( WC==None )
		return;
	W = KFWeapon(Other.FindInventoryType(WC));
	if( W==None || W.Class!=WC )
	{
		W = Other.Spawn(WC);
		if( W==None )
			return;
		W.GiveTo(Other);
	}
	for( i=0; i<2; i++ )
	{
		c = W.AmmoAmount(i);
		if( c<WeaponInfo.AmmoCount[i] )
			W.AddAmmo(WeaponInfo.AmmoCount[i]-c,i);
		else if( c>WeaponInfo.AmmoCount[i] )
			W.ConsumeAmmo(i,c-WeaponInfo.AmmoCount[i]);
	}
	W.MagAmmoRemaining = WeaponInfo.ClipLeft;
}
static final function DebugLogData()
{
	local int i,l,j;

	Log("*********** TRAVEL DATA REPORT *****************");
	l = Default.TravelInfo.Length;
	Log("Travel list length"@l);
	for( i=0; i<l; i++ )
	{
		Log("--> Entry"@i@"for"@Default.TravelInfo[i].PlayerName@"health:"@Default.TravelInfo[i].Health@"armor:"@Default.TravelInfo[i].Armor);
		for( j=0; j<Default.TravelInfo[i].Weapons.Length; j++ )
			Log("Weapon"@Default.TravelInfo[i].Weapons[j].WeaponClass@"Ammo(0):"@Default.TravelInfo[i].Weapons[j].AmmoCount[0]);
	}
	Log("************************************************");
}

defaultproperties
{
}
