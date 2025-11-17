class WTFEquipGlowstickPickup extends M79Pickup;

#exec OBJ LOAD FILE=Asylum_SM.usx
#exec OBJ LOAD FILE=Asylum_T.utx

defaultproperties
{
     Weight=0.000000
     cost=5
     PowerValue=0
     Description="A deadly weapon."
     ItemName="Glowstick"
     ItemShortName="Glowstick"
     InventoryType=Class'WTF.WTFEquipGlowstick'
     PickupMessage="You got the Glowstick."
     StaticMesh=StaticMesh'Asylum_SM.Lighting.glow_sticks_green_pile'
     DrawScale=2.000000
}
