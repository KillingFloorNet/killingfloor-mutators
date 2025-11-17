// --------------------------------------------------------------
// KFBloatVomit_GH
// --------------------------------------------------------------

// Special type of bloat vomit that deals damage to Static actors

// Author :  Alex Quick

// --------------------------------------------------------------


class KFBloatVomit_GH extends KFBloatVomit;


auto state Flying
{
  simulated function HitWall(Vector HitNormal, Actor Wall)
  {
    Landed(HitNormal);
    if ((!Wall.bStatic && !Wall.bWorldGeometry) || Wall.IsA('GlassMoverPlus'))
    {
      Wall.TakeDamage(Damage, instigator, Location, MomentumTransfer * Normal(Velocity), MyDamageType);

      bOnMover = true;
      SetBase(Wall);
      if (Base == none)
        BlowUp(Location);
    }
  }
}


defaultproperties{}