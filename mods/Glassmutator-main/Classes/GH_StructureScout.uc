// --------------------------------------------------------------
// GH_StructureScout
// --------------------------------------------------------------

// Author :  Alex Quick

// --------------------------------------------------------------


class GH_StructureScout extends Actor;


event HitWall(vector HitNormal, actor HitWall)
{
  log(HitWall @ self);
}


event bool EncroachingOn(actor Other)
{
  return super.EncroachingOn(Other);
  log("encroaching on :" @ Other);
}


event EncroachedBy(actor Other)
{
  log("encroached by :" @ Other);
}


function array<GlassMoverPlus> GetSupportedTiles()
{
  local	GlassMoverPlus Tile;
  local	array<GlassMoverPlus>	TouchingTiles;

  foreach TouchingActors(class'GlassMoverPlus', Tile)
  {
    TouchingTiles[TouchingTiles.length] = Tile;
  }

  if (TouchingTiles.length == 0)
  {
    // log(self @ "returned no valid Support tiles for :" @ Owner);
  }

  return TouchingTiles;
}


defaultproperties
{
  DrawType=DT_StaticMesh
  bHidden=true
  Physics=PHYS_Falling
  RemoteRole=ROLE_None
  CollisionRadius=1.000000
  CollisionHeight=1.000000
  bBlockZeroExtentTraces=false
  bBlockNonZeroExtentTraces=false
}