/**
 * Author:      Marco
 * Home repo:   https://github.com/InsultingPros/BitCore
 */
class BitTripArcade extends StaticMeshActor
    placeable;

#exec obj load file="KillingFloorLabStatics.usx"

var BitTrigger MyTrigger;

function PostBeginPlay() {
    MyTrigger = Spawn(class'BitTrigger');
    MyTrigger.Arcade = self;
}

function StartGame(PlayerController Other) {
    local BitGameRep R;

    foreach DynamicActors(class'BitGameRep', R) {
        if (R.Owner == Other)   return;
    }

    Spawn(class'BitGameRep', Other);
}

function Destroyed() {
    if (MyTrigger != none) {
        MyTrigger.Destroy();
    }
}

defaultproperties {
    RemoteRole=ROLE_SimulatedProxy
    bAlwaysRelevant=true
    bSkipActorPropertyReplication=true
    NetUpdateFrequency=1
    bOnlyDirtyReplication=true
    bNetInitialRotation=true
    bStatic=false
    bNoDelete=false

    StaticMesh=StaticMesh'KillingFloorLabStatics.ControlsLit'
    PrePivot=(X=-29.000000,Y=24.000000,Z=20.000000)
    bStaticLighting=false
    CollisionHeight=20
}