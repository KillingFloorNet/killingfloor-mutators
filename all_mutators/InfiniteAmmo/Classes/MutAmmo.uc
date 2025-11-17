//=============================================================================
// MutAmmo - Unlimited 9mm ammo - By EvilDooinz aka Bruce303lee
//=============================================================================
class MutAmmo extends Mutator;

event PreBeginPlay()
{
    SetTimer(1.0,true);
}
 
function Timer()
{
    local Controller C;
 
    for (C = Level.ControllerList; C != None; C = C.NextController)
    {
	ModifyPawn(C.Pawn);
    }
}

static simulated function ModifyPawn(Pawn Other)
{
	local int AddAmmo;
	AddAmmo = 10 + Rand(51);
	GiveAmmo(Other, AddAmmo);
}

static function GiveAmmo(Pawn pawn,float Percentage)
{
    local KFHumanPawn human;
    Local Inventory Inv;

    human =  KFHumanPawn(pawn);

	for (Inv = human.Inventory; Inv != None; Inv = Inv.Inventory)
	{
	       if (KFAmmunition(Inv).AmmoAmount < KFAmmunition(Inv).MaxAmmo)
	           KFAmmunition(Inv).AmmoAmount = KFAmmunition(Inv).MaxAmmo;
	    }
	}

defaultproperties
{
     GroupName="KF-Ammo"
     FriendlyName="Ammo Regen"
     Description="All weapons have unlimited ammunition"
}
