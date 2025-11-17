class SpawnWeapons extends Mutator
  config(SpawnWeapons)
  abstract;


struct ReplaceStruct
{
  var string Perk;
  var string OldWeapon;
  var array<string> NewWeapon;
};
var config array<ReplaceStruct> ReplaceList;

var config bool bGiveArmor;	
var array<KFHumanPawn> PendingPlayers;


function PostBeginPlay()
{
  //SaveConfig();
  //class'KFMod.Single'.default.bKFNeverThrow=False;
  super.PostBeginPlay();
}


function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
  if (KFHumanPawn(Other) != none)
  {
    PendingPlayers[PendingPlayers.Length] = KFHumanPawn(Other);
    SetTimer(0.1, false);
  }
  return true;
}


function Timer()
{
  while (PendingPlayers.Length > 0)
  {
    if (PendingPlayers[0] != none && PendingPlayers[0].PlayerReplicationInfo.PlayerID > 0)
      ReplaceWeapons(PendingPlayers[0]);
    PendingPlayers.Remove(0,1);
  }
}


function ReplaceWeapons(KFHumanPawn P)
{
  local KFPlayerReplicationInfo KFPRI;
  local playerController PC;
  local Inventory Inv;
  local name Veterancy;
  local int i, k;

  if (P != none)
    KFPRI = KFPlayerReplicationInfo(P.PlayerReplicationInfo);
  if (KFPRI != none)
    Veterancy = KFPRI.ClientVeteranSkill.Name;
  pc = PlayerController(P.Controller);
  
  if (bGiveArmor)
    P.ShieldStrength = 100;

  for (i = 0; i < ReplaceList.Length; i++)
  {
    if (ReplaceList[i].Perk == "") //ReplaceList[i] == none ||
      continue;

    if (ReplaceList[i].Perk ~= string(Veterancy))
    {
      for (k = 0; k < ReplaceList[i].NewWeapon.Length; k++)
      {
        if (ReplaceList[i].NewWeapon[k] == "")
          continue;
        // p.GiveWeapon(ReplaceList[i].NewWeapon[k]);
        p.CreateInventoryVeterancy(ReplaceList[i].NewWeapon[k], 0);
      }

      if (ReplaceList[i].OldWeapon == "")
        continue;
      for (Inv = P.Inventory; Inv != none; Inv=Inv.Inventory)
      {
        if (string(Inv.Class) ~= ReplaceList[i].OldWeapon && Inv.Class != none)
        {
          Inv.Destroyed();
          Inv.Destroy();
          break;
        }
      }
      if (pc.Pawn.Weapon == none)
        pc.SwitchToBestWeapon();
    }
  }
  AllAmmo(pc);
}


function AllAmmo(PlayerController pc)
{
  local Inventory Inv;
  local KFHumanPawn PlayerPawn;
  local KFAmmunition AmmoToUpdate;
  local KFWeapon WeaponToFill;
  local KFPlayerReplicationInfo KFPRI;
  local class<KFVeterancyTypes> PlayerVeterancy;

  PlayerPawn = KFHumanPawn(pc.Pawn);
  if (PlayerPawn == none)
    return;
  // refill armor meanwhile
  
  KFPRI = KFPlayerReplicationInfo(PlayerPawn.PlayerReplicationInfo);
  if (KFPRI != none)
    PlayerVeterancy = KFPRI.ClientVeteranSkill;

  for (Inv = PlayerPawn.Inventory; Inv != none; Inv = Inv.Inventory)
  {
    WeaponToFill = KFWeapon(Inv);
    if (WeaponToFill != none)
      WeaponToFill.MagAmmoRemaining = WeaponToFill.MagCapacity;
    AmmoToUpdate = KFAmmunition(Inv);
    if (AmmoToUpdate != none && AmmoToUpdate.AmmoAmount < AmmoToUpdate.MaxAmmo)
    {
      if (PlayerVeterancy != none)
      {
        AmmoToUpdate.MaxAmmo = AmmoToUpdate.default.MaxAmmo;
        AmmoToUpdate.MaxAmmo = float(AmmoToUpdate.MaxAmmo) * PlayerVeterancy.static.AddExtraAmmoFor(KFPRI, AmmoToUpdate.class);
      }
      AmmoToUpdate.AmmoAmount = AmmoToUpdate.MaxAmmo;
    }
  }
}


defaultproperties
{
  GroupName="KF-Spawn Weapons"
  FriendlyName="Spawn Weapons"
  Description="Replaces the weapons players spawn with."
  bGiveArmor=true
}