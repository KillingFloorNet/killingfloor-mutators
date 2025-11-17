class BlackKatana extends Katana;

#exec OBJ LOAD FILE=BlackK.utx

defaultproperties
{
     BloodyMaterial=Combiner'BlackK.Katana_Bloody_cmb'
     HudImage=Texture'KillingFloor2HUD.WeaponSelect.Katana_unselected'
     SelectedHudImage=Texture'KillingFloor2HUD.WeaponSelect.Katana'
     TraderInfoTexture=Texture'BlackK.Trader_Katana'
     FireModeClass(0)=Class'BlackK.BlackKatanaFire'
     FireModeClass(1)=Class'BlackK.BlackKatanaFireB'
     SelectSound=SoundGroup'KF_KatanaSnd.Katana_Select'
     PickupClass=Class'BlackK.BlackKatanaPickup'
     AttachmentClass=Class'BlackK.BlackKatanaAttachment'
     Mesh=SkeletalMesh'KF_Weapons2_Trip.katana_Trip'
     Skins(0)=Combiner'BlackK.Katana_cmb'
}
