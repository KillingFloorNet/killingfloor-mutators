//================================================================================
// ArmorNade.
//================================================================================

class ArmorNade extends Nade;

var bool PickupSpawned;

simulated function Explode (Vector HitLocation, Vector HitNormal)
{
  bHasExploded = True;
  Destroy();
}

simulated function Tick (float Delta)
{
  local Vest kfap;

  if ( Role < 4 )
  {
    return;
  }
  if ( (Velocity.X == 0) && (Velocity.Y == 0) && (Velocity.Z == 0) )
  {
    if (  !PickupSpawned )
    {
      kfap = Spawn(Class'Vest',,,Location,Rotation);
      kfap.bDropped = True;
      PickupSpawned = True;
      Explode(Location,vect(0.00,0.00,1.00));
    }
  }
  Super.Tick(Delta);
}

defaultproperties
{
    ShrapnelClass=None
    Damage=0.00
    MyDamageType=None
    StaticMesh=StaticMesh'KillingFloorStatics.Vest'
    bDynamicLight=True
    DrawScale3D=(X=1.00,Y=1.00,Z=0.60),
    PrePivot=(X=0.00,Y=21.00,Z=12.00),
    AmbientGlow=40
    UV2Texture=FadeColor'PatchTex.Common.PickupOverlay'
    TransientSoundVolume=100.00
    CollisionRadius=5.00
    CollisionHeight=10.00
    MessageClass=Class'UnrealGame.PickupMessagePlus'

}