class MFWHumanPawn extends KFHumanPawn;

var MFWFragBase fragWeapons[3];
var int currFragIndex;

replication {
    reliable if (Role == ROLE_Authority)
        fragWeapons, currFragIndex, updateHUD;
}

simulated function updateHUD() {
    if (PlayerController(Controller) != none && HUDKillingFloor(PlayerController(Controller).myHud) != none) {
        HUDKillingFloor(PlayerController(Controller).myHud).PlayerGrenade= fragWeapons[currFragIndex];
        HUDKillingFloor(PlayerController(Controller).myHud).GrenadeIcon.WidgetTexture= fragWeapons[currFragIndex].grenadeTexture;
    }
}

function AddDefaultInventory() {
    local Inventory inv;
    local int index;

    super.AddDefaultInventory();
    for(inv= Inventory; inv != none; inv= inv.Inventory) {
        if (MFWFragBase(inv) != none) {
            fragWeapons[index]= MFWFragBase(inv);
            if (MFWFrag(inv) != none) {
                currFragIndex= index;
            }
            index++;
        }
    }
    updateHUD();
}

exec function switchGrenade() {
    local int nextFragIndex;

    nextFragIndex= currFragIndex;
    do {
        nextFragIndex++;
        if (nextFragIndex >= ArrayCount(fragWeapons)) {
            nextFragIndex= 0;
        }
    } until(fragWeapons[nextFragIndex] != none);

    currFragIndex= nextFragIndex;
    updateHUD();
}

function ThrowGrenade() {
    if (fragWeapons[currFragIndex] != none && fragWeapons[currFragIndex].HasAmmo() && !bThrowingNade) {
        if (KFWeapon(Weapon) == none || Weapon.GetFireMode(0).NextFireTime - Level.TimeSeconds > 0.1 ||
                 (KFWeapon(Weapon).bIsReloading && !KFWeapon(Weapon).InterruptReload())) {
                return;
        }

        //TODO: cache this without setting SecItem yet
        //SecondaryItem = aFrag;
        KFWeapon(Weapon).ClientGrenadeState = GN_TempDown;
        Weapon.PutDown();
    }
}

function WeaponDown() {
    if (fragWeapons[currFragIndex]!=none && fragWeapons[currFragIndex].HasAmmo()) {
        SecondaryItem = fragWeapons[currFragIndex];
        fragWeapons[currFragIndex].StartThrow();
    }
}


defaultproperties {
    RequiredEquipment(2)="MultiFragWeapon.MFWFrag"
    RequiredEquipment(5)="MultiFragWeapon.FlameFrag"
    RequiredEquipment(6)="MultiFragWeapon.MedicFrag"
}
