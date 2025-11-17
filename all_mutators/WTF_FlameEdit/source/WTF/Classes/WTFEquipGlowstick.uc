class WTFEquipGlowstick extends M79GrenadeLauncher;



defaultproperties
{
     ReloadAnim="Select"
     FlashBoneName="Hands_R_wrist"
     WeaponReloadAnim="Select"
     Weight=0.000000
     bHasAimingMode=False
     IdleAimAnim="Idle"
     FireModeClass(0)=Class'WTFEquipGlowstickFire'
     FireModeClass(1)=Class'WTFEquipGlowstickAltFire'
     Description="A deadly weapon"
     Priority=4
     InventoryGroup=5
     GroupOffset=4
     PickupClass=Class'WTFEquipGlowstickPickup'
     PlayerViewOffset=(X=0.000000,Y=0.000000,Z=0.000000)
     AttachmentClass=Class'WTFEquipGlowstickAttachment'
     ItemName="Glowstick"
     Mesh=SkeletalMesh'KF_Weapons_Trip.Pipe_Trip'
     Skins(0)=Texture'WTF_A.Glowstick.Glowstick'
}
