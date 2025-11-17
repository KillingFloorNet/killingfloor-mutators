/**
 * Author:      Marco
 * Home repo:   https://github.com/InsultingPros/BitCore
 */
class BitMut extends Mutator
    config(BitCore);

struct FPlacementEntry {
    var config string M;
    var config vector P;
    var config int Y;
};
var config array<FPlacementEntry> Placement;
var transient array<name> PackageList;

function PreBeginPlay() {
    local int i;
    local rotator R;

    for (i = 0; i < Placement.Length; ++i) {
        if (Placement[i].M ~= string(Outer.name)) {
            ListPackage(class);
            R.Yaw = Placement[i].Y + 16384;
            Spawn(
                class'BitTripArcade',,,
                Placement[i].P + vect(0, 0, 1) * class'BitTripArcade'.default.CollisionHeight,
                R
            );
        }
    }

    for (i = (PackageList.Length - 1); i >= 0; --i) {
        AddToPackageMap(string(PackageList[i]));
    }

    PackageList.Length = 0;
}

final function ListPackage(Object O) {
    local int i;

    while (O.Outer != none) {
        O = O.Outer;
    }

    for (i = (PackageList.Length - 1); i >= 0; --i) {
        if (PackageList[i] == O.name) {
            return;
        }
    }

    PackageList[PackageList.Length] = O.name;
}

function Mutate(string MutateString, PlayerController Sender) {
    if (Sender.PlayerReplicationInfo.bAdmin || Level.NetMode == NM_StandAlone) {
        if (MutateString ~= "AddBitGame" && Sender.Pawn != none) {
            AddGame(Sender);
            return;
        } else if (MutateString ~= "RemoveBitGame") {
            RemoveGame(Sender);
            return;
        }
    }

    if (NextMutator != none) {
        NextMutator.Mutate(MutateString, Sender);
    }
}

final function AddGame(PlayerController PC) {
    local int i;
    local vector HL, HN;
    local actor traceResult;

    traceResult = PC.Pawn.Trace(HL, HN, PC.Pawn.Location - vect(0, 0, 500), PC.Pawn.Location, false);
    if (traceResult == none) {
        PC.ClientMessage("Can't add game here.");
        return;
    }

    i = Placement.Length;
    Placement.Length = i+1;

    Placement[i].M = string(Outer.name);
    Placement[i].P = HL;
    Placement[i].Y = ((PC.Rotation.Yaw + 2042) / 4095) * 4095;
    SaveConfig();
    PC.ClientMessage("Added game at" @ HL);
}

final function RemoveGame(PlayerController PC) {
    local int i, Best;
    local vector V;
    local float D, BestD;

    if (PC.Pawn != none) {
        V = PC.Pawn.Location;
    } else {
        V = PC.Location;
    }

    Best = -1;

    for (i = 0; i < Placement.Length; ++i) {
        if (Placement[i].M ~= string(Outer.name)) {
            D = VSize(V - Placement[i].P);

            if (Best == -1 || BestD > D) {
                Best = i;
                BestD = D;
            }
        }
    }

    if (Best == -1) {
        PC.ClientMessage("No more BIT.TRIP games in this map.");
        return;
    }

    PC.ClientMessage("Removed game at " $ Placement[Best].P $ " with " $ BestD $ " distance from you.");
    Placement.Remove(Best, 1);
    SaveConfig();
}

defaultproperties {
    FriendlyName="BIT.TRIP Mutator"
    Description="Add BIT arcade machines to maps."
    GroupName="KF-BitArcade"
}