// --------------------------------------------------------------
// PlayerPawn_GH
// --------------------------------------------------------------

// Base pawn class for 'Glasshouse' maps.  Takes reduced damage from
// enemy weapons and comes equipped with a grenade launcher instead of
// a pistol.

// Author :  Alex Quick

// --------------------------------------------------------------


class	PlayerPawn_GH extends KFHumanPawn;

// this var controls the pawn's resistance to explosive damage. a value of 1.0 means he takes no damage from explosive damagetypes
var float ExpDamageAbsorption;


// When flying through the air, smash directly through weakened walls
event HitWall(vector HitNormal, actor HitWall)
{
  local GlassMoverPlus BreakableWall;
  local int DamageToWall;

  BreakableWall = GlassMoverPlus(HitWall);

  if (BreakableWall != none && Physics == PHYS_Falling && VSize(Velocity) >= 750.f)
  {
    DamageToWall = VSize(Velocity);
    BreakableWall.TakeDamage(DamageToWall, self, HitWall.Location - Location, Velocity, class'KFMod.DamTypeM79Grenade');
    TakeDamage(DamageToWall / 50, self, HitWall.Location - Location, Velocity, class'Gibbed');
  }
}


simulated function TakeDamage(int Damage, Pawn InstigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> damageType, optional int HitIndex)
{
  local class<KFWeaponDamageType> KFDamage;
  local int AdjustedDmg;

  AdjustedDmg = Damage;

  KFDamage = class<KFWeaponDamageType>(damageType);
  if (KFDamage != none)
  {
    if (KFDamage.default.bIsExplosive)
    {
      AdjustedDmg = Max(Damage * (1.f - ExpDamageAbsorption), 1);
      // because the superclass zeroes momentum out if the damage is coming from another human player..
      AddVelocity(Momentum / Mass);
    }
  }

  super.TakeDamage(AdjustedDmg, InstigatedBy, HitLocation, Momentum, damageType, HitIndex);
}


singular event BaseChange()
{
  super.BaseChange();

  if (Role == Role_Authority && Base == none && Physics != PHYS_Falling)
  {
    SetPhysics(PHYS_Falling);
  }
}


defaultproperties
{
  ExpDamageAbsorption=0.900000
  MaxCarryWeight=999.000000
  RequiredEquipment(0)="Glassmutator.M79GrenadeLauncher_GH"
  RequiredEquipment(1)="KFMod.Frag"
  RequiredEquipment(2)="KFMod.Syringe"
  RequiredEquipment(3)=""
  RequiredEquipment(4)=""
  bCanWalkOffLedges=true
  bDirectHitWall=true
  GroundSpeed=300.000000
  MaxFallSpeed=500.000000
}