// --------------------------------------------------------------
// GH_RoofTileProjector
// --------------------------------------------------------------

// Special type of Projector spawned at runtime by GlassMoverPlus actors
// with the 'bRoofLightTile' flag. They are activated when the tile is destroyed
// and de-activated when it respawns. Initially off.

// Author :  Alex Quick

// --------------------------------------------------------------


class GH_RoofTileProjector extends Projector
  placeable;


#exec OBJ LOAD FILE=GlassHouse_Tex.utx


var vector InitialLoc;

var int NumProjectors;

var float MergeRadius;

var float MaxMergeRange;


simulated function PostBeginPlay()
{
  super.PostBeginPlay();
  InitialLoc = Location;
}


simulated function ActivateLight()
{
  // bHidden = false ;
  bProjectStaticMesh = true;
  MergeNearbyProjectors();
  RefreshProjection();
}


simulated function DisableLight()
{
  bProjectStaticMesh = false;
  RefreshProjection();
  // bHidden = true;
}


simulated function ResetLight()
{
  NumProjectors = default.NumProjectors;

  MergeRadius = default.MergeRadius;
  SetDrawScale(default.DrawScale);
  SetLocation(InitialLoc);

  DisableLight();
}


simulated function MergeNearbyProjectors()
{
  local GH_RoofTileProjector Proj;

  foreach AllActors(class'GH_RoofTileProjector', Proj)
  {
    if (Proj != self && Proj.bProjectStaticMesh && NumProjectors >= Proj.NumProjectors && VSize(Proj.Location - Location) <= Proj.MergeRadius + MergeRadius)
    {
      MergeWith(Proj);
    }
  }
}


simulated function MergeWith(GH_RoofTileProjector Proj)
{
  local vector AdjustedLoc;
  local vector Dir;
  local float Dist, AdjustedDist;
  local float SizeScale;

  // Find a comfortable middle point between the two projectors
  // Weighted in favor of whichever one is larger ..
  Dir = Normal(Proj.Location - Location);
  Dist = VSize(Proj.Location - Location);

  SizeScale = FClamp(FMin(NumProjectors, Proj.NumProjectors) / FMax(NumProjectors, Proj.NumProjectors), 0.f ,0.5f);
  AdjustedDist = Dist * SizeScale;
  AdjustedLoc =  Location + Dir * AdjustedDist;

  if (VSize(AdjustedLoc - InitialLoc) > MaxMergeRange)
  {
    return;
  }

  SetLocation(AdjustedLoc);

  NumProjectors += Proj.NumProjectors;
  SetDrawScale(FMin((NumProjectors * default.DrawScale) / 2, default.DrawScale * 5));
  MergeRadius += AdjustedDist;
  // log("MergeRadius of" @ self @ "is :" @ MergeRadius);

  Proj.DisableLight();
}


simulated function RefreshProjection()
{
  DetachProjector();
  AttachProjector();
}


defaultproperties
{
  NumProjectors=1
  MergeRadius=250.000000
  MaxMergeRange=1500.000000
  MaterialBlendingOp=PB_Modulate
  FrameBufferBlendingOp=PB_Add
  ProjTexture=Texture'GlassHouse_Tex.Projectors.Tile_LightSpotTex'
  FOV=15
  MaxTraceDistance=2500
  bProjectBSP=false
  bProjectStaticMesh=false
  bProjectActor=false
  bGradient=true
  bDynamicAttach=true
  CullDistance=3000.000000
  bStatic=false
  RemoteRole=ROLE_SimulatedProxy
  Rotation=(Pitch=-16384)
  DrawScale=2.000000
}