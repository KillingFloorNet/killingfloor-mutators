class Molotov extends M79GrenadeLauncher;

#exec OBJ LOAD FILE="Molotov.utx"

defaultproperties
{
     ReloadAnim="Select"
     FlashBoneName="Hands_R_wrist"
     WeaponReloadAnim="Select"
     HudImage=Texture'Molotov.Molotov_T.Molotov_unselected'
     SelectedHudImage=Texture'Molotov.Molotov_T.Molotov_selected'
     Weight=0.000000
     bHasAimingMode=False
     IdleAimAnim="Idle"
     TraderInfoTexture=Texture'Molotov.Molotov_T.Trader_Molotov'
     MeshRef="Molotov.Molotov_A.Molotov_Trip"
     SkinRefs(0)="Molotov.Molotov_T.Molotov_cmb"
     SkinRefs(2)="Molotov.Molotov_T.v_eq_molotov_cmb"
     SkinRefs(3)="Molotov.Molotov_T.FBFlameOrange"
     FireModeClass(0)=Class'Molotov.MolotovFire'
     Description="A deadly weapon"
     Priority=4
     InventoryGroup=5
     GroupOffset=4
     PickupClass=Class'Molotov.MolotovPickup'
     PlayerViewOffset=(X=0.000000,Y=0.000000,Z=0.000000)
     AttachmentClass=Class'Molotov.MolotovAttachment'
     ItemName="Molotov Cocktail"
     Mesh=SkeletalMesh'Molotov.Molotov_A.Molotov_Trip'
     Skins(0)=Combiner'Molotov.Molotov_T.Molotov_cmb'
     Skins(2)=Combiner'Molotov.Molotov_T.v_eq_molotov_cmb'
     Skins(3)=FinalBlend'Molotov.Molotov_T.FBFlameOrange'
}
