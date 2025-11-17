// --------------------------------------------------------------
// ZombieBloat_GH
// --------------------------------------------------------------

// Modified Type of Bloat for use in the glasshouse map.
// His puke melts through tiles.

// Author :  Alex Quick

// --------------------------------------------------------------


class ZombieBloat_GH extends ZombieBloat_STANDARD;


event HitWall(vector HitNormal, actor HitWall)
{
  local GlassMoverPlus BreakableWall;

  BreakableWall = GlassMoverPlus(HitWall);

  if (BreakableWall != none && BreakableWall.ObjMaterialType == OMT_Glass)
  {
    BreakableWall.DoTileDeath();
  }
}


// The Projectile class the Bloat spawns when he pukes appears to be hard coded
// to 'KFBloatVomit'  in not one but four different places in SpawnToShots().
// So if anyone's wondering why I C&Ped the whole function here ... that's why :)
function SpawnTwoShots()
{
  local vector X, Y, Z, FireStart;
  local rotator FireRotation;

  if (Controller != none && KFDoorMover(Controller.Target) != none)
  {
    // class'DamTypeVomit'
    Controller.Target.TakeDamage(22, Self, Location, vect(0, 0, 0), AmmunitionClass.default.ProjectileClass.default.MydamageType);
    return;
  }


  GetAxes(Rotation, X, Y, Z);
  FireStart = Location + (vect(30, 0, 64) >> Rotation) * DrawScale;
  if (!SavedFireProperties.bInitialized)
  {
    // class'SkaarjAmmo';   // < -  ?
    SavedFireProperties.AmmoClass = AmmunitionClass;
    SavedFireProperties.ProjectileClass = AmmunitionClass.default.ProjectileClass;
    SavedFireProperties.WarnTargetPct = 1;
    SavedFireProperties.MaxRange = 500;
    SavedFireProperties.bTossed = false;
    SavedFireProperties.bTrySplash = false;
    SavedFireProperties.bLeadTarget = true;
    SavedFireProperties.bInstantHit = true;
    SavedFireProperties.bInitialized = true;
  }

  // Turn off extra collision before spawning vomit, otherwise spawn fails
  ToggleAuxCollision(false);
  FireRotation = Controller.AdjustAim(SavedFireProperties, FireStart, 600);
  Spawn(AmmunitionClass.default.ProjectileClass,,, FireStart, FireRotation);

  FireStart -= (0.5 * CollisionRadius * Y);
  FireRotation.Yaw -= 1200;
  spawn(AmmunitionClass.default.ProjectileClass,,, FireStart, FireRotation);

  FireStart += (CollisionRadius * Y);
  FireRotation.Yaw += 2400;
  spawn(AmmunitionClass.default.ProjectileClass,,, FireStart, FireRotation);
  // Turn extra collision back on
  ToggleAuxCollision(true);
}


defaultproperties
{
  AmmunitionClass=class'BZombieAmmo_GH'
  bDirectHitWall=true
  ControllerClass=class'ctrl_KFMonster_GH'
}