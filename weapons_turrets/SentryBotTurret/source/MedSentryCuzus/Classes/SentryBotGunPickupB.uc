// Armor Sentry Bot
class SentryBotGunPickupB extends KFWeaponPickup;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	TweenAnim('Folded',0.01f);
}

defaultproperties
{
	Weight=1.000000
	cost=5000
	AmmoCost=5000
	BuyClipSize=1
	PowerValue=100
	SpeedValue=20
	RangeValue=50
	Description="A heavy armed machine gun sentry bot you can purchase to aid you in the combat."
	ItemName="Sentry Bot (Armor)"
	ItemShortName="Sentry Bot (Armor)"
	AmmoItemName="Sentry Bot (Armor)"
	CorrespondingPerkIndex=3
	EquipmentCategoryID=3
	InventoryType=Class'SentryBotGunB'
	PickupMessage="You got a Sentry Bot (Armor)."
	PickupSound=Sound'KF_AA12Snd.AA12_Pickup'
	PickupForce="AssaultRiflePickup"
	DrawType=DT_Mesh
	Mesh=SkeletalMesh'SentryBot_A.SentryMesh'
	CollisionRadius=22.000000
	CollisionHeight=23.000000
}
