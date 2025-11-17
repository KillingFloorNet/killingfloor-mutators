class PickupFixMut extends Mutator
dependson(PFRandomItemSpawn)
config(PickupFix);

struct ReplacementPair
{
var class<Pickup> OldPickup,NewPickup;
};

var config bool	  bUseAmmoFix;
var config int	  MaxSellValue;
var config array<string>	Pickups;
var config array<ReplacementPair> Replacement;

var KFGameType KFGT;
var array<PFRandomItemSpawn.WavePickupsType> WavePickupData;
simulated function PostBeginPlay()
{
Super.PostBeginPlay();

KFGT = KFGameType(Level.Game);

if ( KFGT == none )
{
  Destroy();
  return;
}

InitPickupsArray();
}
function InitPickupsArray()
{
local int i,j,n,index,k,m;
local array<string> TS,PickupsArray,PickupInfo;
local string T,TW;
local PFRandomItemSpawn.WavePickupsType TPickups;

TS = Pickups;
n = Max(KFGT.FinalWave,Pickups.Length);
j = 0;

if ( WavePickupData.Length > 0 )
{
  WavePickupData.Remove(0,WavePickupData.Length);
}

WavePickupData.Insert(0,n);

for(i=0; i<n; i++)
{
  if ( j > 0 && TS[j] == "" )
  {
   TS[j] = TS[j-1];
  }

  if ( PickupsArray.Length > 0 )
  {
   PickupsArray.Remove(0,PickupsArray.Length);
  }

  Split(TS[j],";",PickupsArray);

  m = PickupsArray.Length;

  for(k=0; k<m; k++)
  {
   Split(PickupsArray[k],":",PickupInfo);
   WavePickupData[i].Pickups.Insert(0,1);
   WavePickupData[i].Pickups[0].Pickup = class<Pickup>(DynamicLoadObject(PickupInfo[0],Class'Class'));
   WavePickupData[i].Pickups[0].Weight = int(PickupInfo[1]);
  }

  j = Min(j+1,Pickups.Length-1);
}
}

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
local KFAmmoPickup KFAP,KFAP1;
local KFRandomItemSpawn KFRIS,KFRIS1;
local int i,n;

n = Replacement.Length;

for(i=0; i<n; i++)
{
  if ( Replacement[i].OldPickup != none && Replacement[i].NewPickup != none
   && Replacement[i].OldPickup == Other.Class )
  {
   ReplaceWith(Other,string(Replacement[i].NewPickup));
   return false;
  }
}

if ( bUseAmmoFix && Other.Class == class'KFAmmoPickup' )
{
  KFAP = KFAmmoPickup(Other);
  KFAP1 = Spawn(class'PFAmmoPickup',,,KFAP.Location,KFAP.Rotation);
  KFAP1.bSleeping = KFAP.bSleeping;
  KFAP1.bShowPickup = KFAP.bShowPickup;
  KFAP1.AmmoAmount = KFAP.AmmoAmount;
  KFAP1.RespawnTime = KFAP.RespawnTime;
  KFAP1.MaxDesireability = KFAP.MaxDesireability;
  KFAP1.MyMarker = KFAP.MyMarker;
  KFAP1.bInstantRespawn = KFAP.bInstantRespawn;
  KFAP.Destroy();
  SetTimer(0.1,false);

  return false;
}

if ( Other.Class == class'KFRandomItemSpawn' )
{
  KFRIS = KFRandomItemSpawn(Other);
  KFRIS1 = Spawn(class'PFRandomItemSpawn',,,KFRIS.Location,KFRIS.Rotation);
  KFRIS.InitialWaitTime = KFRIS1.InitialWaitTime;
  KFRIS.Destroy();
  SetTimer(0.1,false);

  return false;
}

if ( Other.Class == class'PFRandomItemSpawn' )
{
  PFRandomItemSpawn(Other).InitPickupsArray(WavePickupData);
  PFRandomItemSpawn(Other).MaxSellValue = MaxSellValue;
  return Super.CheckReplacement(Other,bSuperRelevant);
}
return Super.CheckReplacement(Other,bSuperRelevant);
}
function Timer()
{
local int i,n;

n = KFGT.AmmoPickups.Length;

for(i=0; i<n; i++)
{
  if ( KFGT.AmmoPickups[i] == none )
  {
   KFGT.AmmoPickups.Remove(i,1); // Очистка гейм тайпа от уничтоженных аммо пикапов
   i--;
   n--;
  }
}

n = KFGT.WeaponPickups.Length;

for(i=0; i<n; i++)
{
  if ( KFGT.WeaponPickups[i] == none )
  {
   KFGT.WeaponPickups.Remove(i,1); // Очистка гейм тайпа от уничтоженных веапон пикапов
   i--;
   n--;
  }
}
}
defaultproperties
{
bUseAmmoFix = true
MaxSellValue = 500
Pickups(0) = "KFMod.DualiesPickup:3;KFMod.ShotgunPickup:1;KFMod.BullpupPickup:3;KFMod.DeaglePickup:3;KFMod.WinchesterPickup:2;KFMod.AxePickup:1;KFMod.MachetePickup:1;KFMod.Vest:3"

GroupName="KF-PickupFixMut"
FriendlyName="PickupFixMut"
Description="Fixes ammo and weapon pickups."
}