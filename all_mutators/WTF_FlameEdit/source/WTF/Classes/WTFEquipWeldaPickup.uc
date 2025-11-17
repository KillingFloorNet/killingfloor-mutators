class WTFEquipWeldaPickup extends KFWeaponPickup;

#exec obj load file="..\StaticMeshes\NewPatchSM.usx"

defaultproperties
{
     cost=500
     Description="A deadly weapon."
     ItemName="Welda profession"
     ItemShortName="Welda profession"
     InventoryType=Class'WTFEquipWelda'
     PickupMessage="The Legend of Welda Begins..."
     Skins(0)=Texture'WTF_A.Welda.Welda_3rd'
}
