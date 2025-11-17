class V94LLIPickup extends KFWeaponPickup;

defaultproperties
{
     Weight=14.000000
     cost=6000
     BuyClipSize=5
	 AmmoCost=300
     PowerValue=100
     SpeedValue=15
     RangeValue=100
     Description="Is a Russian large calibre semi-automatic sniper rifle chambered for the 12.7 x 108 mm round. The rifle is capable of engaging manpower at a distance of up to 1800 m and combat materiel at range up to 2500 m."
     ItemName="V-94 Volga"
     ItemShortName="V-94 Volga"
     AmmoItemName="Bullets 12,7x108mm(B32)"
     //showMesh=SkeletalMesh'V94LLI_A.V94LLI_3rd'
	 Mesh=SkeletalMesh'V94LLI_A.V94LLI_3rd'
     CorrespondingPerkIndex=2
     EquipmentCategoryID=2
     InventoryType=Class'V94LLImut.V94LLI'
     PickupMessage="You got the V-94 Volga"
     PickupSound=Sound'V94LLI_A.V94LLI_Snd.V94LLI_pickup'
     PickupForce="AssaultRiflePickup"
     StaticMesh=StaticMesh'V94LLI_A.V94LLI_st'
	 DrawScale=1.5
     CollisionRadius=30.000000
     CollisionHeight=5.000000
}
