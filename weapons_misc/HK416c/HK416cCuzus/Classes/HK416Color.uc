class HK416Color extends HK416c
	config(user);

defaultproperties
{
	SelectedHudImage=Texture'HK416c_R.HUDSelectedIR'
	TraderInfoTexture=Texture'HK416c_R.HUDTraderIR'
	//Description="Now in iridesecent / opal / etc colors!"
	PickupClass=Class'HK416cCuzus.HK416ColorPickup'
	AttachmentClass=Class'HK416cCuzus.HK416ColorAttachment'
	//ItemName="H&K 416c (Ir)"
	Skins(1)=Combiner'HK416c_R.HK416_cmb_color'
	Skins(2)=Combiner'HK416c_R.Extras_cmb_color'
	Skins(5)=Combiner'HK416c_R.Sights_cmb_color'
}
