// --------------------------------------------------------------
// ZombieFleshPoundBase_GH
// --------------------------------------------------------------

// Modified Type of Fleshpound for use in the glasshouse map.
// Able to smash tiles when enraged.

// Author :  Alex Quick

// --------------------------------------------------------------


class ZombieFleshPound_GH extends ZombieFleshPound_STANDARD;


simulated function Tick(float DeltaTime)
{
  super.Tick(DeltaTime);

  if (bChargingPlayer)
  {
    BashNearbyTiles(MeleeDamage * 100, CollisionRadius * 3, CurrentDamType, 0, Location);
  }
}


function ClawDamageTarget()
{
  super.ClawDamageTarget();

  // Have the fleshpound smash surrounding tiles when he's attacking players
  BashNearbyTiles(MeleeDamage * 100, CollisionRadius * 3, CurrentDamType, 0, Location);
}


simulated function BashNearbyTiles(float DamageAmount, float DamageRadius, class<DamageType> DamageType, float Momentum, vector HitLocation)
{
  local GlassMoverPlus Victims;

  foreach RadiusActors(class'GlassMoverPlus', Victims, DamageRadius, HitLocation)
  {
    if (Victims != Base)
    {
      Victims.TakeDamage(DamageAmount, Instigator, Victims.Location - Location, vect(0, 0, 0), DamageType);
    }
  }
}


// event HitWall(vector HitNormal, actor HitWall)
// {
//   local GlassMoverPlus BreakableWall;

//   BreakableWall = GlassMoverPlus(HitWall);

//   if (BreakableWall != none && ( bChargingPlayer || BreakableWall.ObjMaterialType == OMT_Glass))
//   {
//     // If we've run into a wall destroy it
//     if (Abs(Hitnormal.Z) <= 0.25)
//     {
//       BreakableWall.DoTileDeath();
//     }
//   }
// }


function ZombieMoan()
{
  PlaySound(MoanVoice, SLOT_Misc, MoanVolume,, 50); //250.0
}


function PlayChallengeSound()
{
  PlaySound(ChallengeSound[Rand(4)], SLOT_Talk,,, 50);
}


// Scales the damage this Zed deals by the difficulty level
function float DifficultyDamageModifer()
{
  return 1.0;
}


// Scales the health this Zed has by the difficulty level
function float DifficultyHealthModifer()
{
  return 1.0;
}


function float DifficultyHeadHealthModifer()
{
  return 1.0;
}


defaultproperties
{
  bDirectHitWall=true
  GroundSpeed=250.000000
}