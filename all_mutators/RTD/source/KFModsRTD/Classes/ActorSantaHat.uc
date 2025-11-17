//-----------------------------------------------------------
// Found at
//  http://angelmapper.com/gamedev/ut2004/infosantahats.htm
//-----------------------------------------------------------
class ActorSantaHat extends Actor;
#exec obj load file=Textures/KFModsGenerics.utx package=KFModsRTD
#exec obj load file=StaticMeshes/SantaHatMesh.usx package=KFModsRTD

var xPawn OwnerPawn;
var bool bDying;

simulated function PostBeginPlay()
{
    super.PostBeginPlay();
    if(xPawn(Owner) != none)
        OwnerPawn = xPawn(Owner);
    SetTimer(1,True);
}

simulated function Timer()
{
    if(OwnerPawn == none)
        Destroy();

    if(OwnerPawn != none && OwnerPawn.IsInState('Dying') && !bDying)
    {
        bTearOff = true;
        bDying = true;
        LifeSpan = 10;
        bUnlit = true;
        DetachFromBone(Owner);
    }
}

defaultproperties
{
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'SantaHatMesh.SantaHatMesh'
     DrawScale=0.500000
}
