/*
Оружие просто не поднимается, но двойные пистолетики тоже не поднимаются
Я добавил исключения для классики (дигл, магнум, 9мм, мк23, ракетница)
Если у вас есть свои двойные пистолеты название Pickup классов которых отличаются от классики - правьте функцию PickupOverrideRules.InExceptionList
*/

// PickupOverrideMut.uc
class PickupOverrideMut extends Mutator;

var PickupOverrideRules Rules;

function PostBeginPlay()
{
if( Rules==None )
Rules = Spawn(Class'PickupOverrideRules');
}

defaultproperties
{
bAddToServerPackages=True
GroupName="KF-PickupOverride"
FriendlyName="PickupOverrideMut"
Description="PickupOverrideMut"
}


// PickupOverrideRules.uc
class PickupOverrideRules extends GameRules;

function PostBeginPlay()
{
	if(Level.Game.GameRulesModifiers == none)
		Level.Game.GameRulesModifiers = self;
	else
		Level.Game.GameRulesModifiers.AddGameRules(self);
}

function bool IsInInventoryExt(Pawn ItemOwner, Class Item)
{
	local Inventory CurInv;
	for ( CurInv = ItemOwner.Inventory; CurInv != none; CurInv = CurInv.Inventory )
	{
		if ( CurInv.default.PickupClass!=none && CurInv.default.PickupClass == Item )
			return true;
	}
	return false;
}

function bool InExceptionList(Class Item)
{
	if	(
			Item.Name=='DeaglePickup'
			||	Item.Name=='MK23Pickup'
			||	Item.Name=='FlareRevolverPickup'
			||	Item.Name=='SinglePickup'
			||	Item.Name=='Magnum44Pickup'
		)
	{
		return true;
	}
	return false;
}

function bool OverridePickupQuery(Pawn Other, Pickup Item, out byte bAllowPickup)
{
	if	(
			IsInInventoryExt(Other,Item.Class)
			&&	!InExceptionList(Item.Class)
			&&	WeaponPickup(Item)!=none
		)
	{
		bAllowPickup=0;
		PlayerController(Other.Controller).ReceiveLocalizedMessage(Class'KFMainMessages', 2);
		return true;
	}
	if(NextGameRules!=None) 
		return NextGameRules.OverridePickupQuery(Other, Item, bAllowPickup);
	return false;
}