Class KFCustomShopMutB extends Mutator
    Config(KFCustomShopMutv2);  

var() globalconfig array<string> WeaponForSale;    
var localized string WeaponForSaleGroup;

function PostBeginPlay()
{
    SetTimer(0.2,False);
}

function Timer()
{
    local int i;
    local KFLevelRules KFLR;

    KFLR = KFGameType(Level.Game).KFLRules;
        
    if ( KFLR!=None )
    {
        for( i=0; i<KFLR.MAX_BUYITEMS; ++i )
            KFLR.ItemForSale[i] = None;
        for( i=0; i<WeaponForSale.Length; i++ )
            KFLR.ItemForSale[i] = class<Pickup>(DynamicLoadObject(WeaponForSale[i], Class'Class'));
    }
}
function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
    if( PlayerController(Other)!=None )
        Spawn(Class'RepWeaponList',Other).Mut = Self;
    return true;
}

static function FillPlayInfo(PlayInfo PlayInfo)
{
    Super.FillPlayInfo(PlayInfo);
    PlayInfo.AddSetting(default.WeaponForSaleGroup,"WeaponForSale","Shop Items",1,1,"Text","55",,,True);
}

static event string GetDescriptionText(string PropName)
{
    switch (PropName)
    {
        case "WeaponForSale":            return "Add or change any weapon to a weapon of your choice.  Whether they are custom weapon from the community or newly released weapons by TWI.";
    }
    return Super.GetDescriptionText(PropName);
}

defaultproperties
{
     WeaponForSale(0)="KFMod.MP7MPickup"
     WeaponForSale(1)="KFMod.ShotgunPickup"
     WeaponForSale(2)="KFMod.BoomStickPickup"
     WeaponForSale(3)="KFMod.LAWPickup"
     WeaponForSale(4)="KFMod.AA12Pickup"
     WeaponForSale(5)="KFMod.SinglePickup"
     WeaponForSale(6)="KFMod.DualiesPickup"
     WeaponForSale(7)="KFMod.DeaglePickup"
     WeaponForSale(8)="KFMod.DualDeaglePickup"
     WeaponForSale(9)="KFMod.WinchesterPickup"
     WeaponForSale(10)="KFMod.CrossbowPickup"
     WeaponForSale(11)="KFMod.M14EBRPickup"
     WeaponForSale(12)="KFMod.BullpupPickup"
     WeaponForSale(13)="KFMod.AK47Pickup"
     WeaponForSale(14)="KFMod.SCARMK17Pickup"
     WeaponForSale(15)="KFMod.KnifePickup"
     WeaponForSale(16)="KFMod.MachetePickup"
     WeaponForSale(17)="KFMod.AxePickup"
     WeaponForSale(18)="KFMod.ChainsawPickup"
     WeaponForSale(19)="KFMod.KatanaPickup"
     WeaponForSale(20)="KFMod.FlameThrowerPickup"
     WeaponForSale(21)="KFMod.MAC10Pickup"
     WeaponForSale(22)="KFMod.PipeBombPickup"
     WeaponForSale(23)="KFMod.M79Pickup"
     WeaponForSale(24)="KFMod.M32Pickup"
     WeaponForSaleGroup="WeaponForSale"
     bAddToServerPackages=True
     GroupName="KFCustomShopMutB"
     FriendlyName="Custom Shop Menu Final"
     Description="Allows custom WeaponForSale to be added at trader."
}
