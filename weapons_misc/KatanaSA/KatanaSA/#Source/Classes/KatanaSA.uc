class KatanaSA extends KFMeleeGun;

defaultproperties
{
     weaponRange=90.000000
     BloodSkinSwitchArray=0
     BloodyMaterial=Material'KatanaSA_A.Katana_Tex.KatanaBody_Env_cmb'
     bSpeedMeUp=True
     Weight=3.000000
     StandardDisplayFOV=50.000000
     TraderInfoTexture=Texture'KatanaSA_A.Katana_Tex.KatanaSA_Trader'
     bIsTier2Weapon=True
     Mesh=SkeletalMesh'KatanaSA_A.KatanaSADT_Mesh'
     Skins(0)=Combiner'KatanaSA_A.Katana_Tex.KatanaBody_cmb'
	 Skins(1)=Combiner'KF_Weapons_Trip_T.hands.hands_1stP_military_cmb'
	 SleeveNum=1
	 BringUpTime=1.1
     SelectSound=Sound'KatanaSA_A.Katana_SND.katana_draw'
     HudImage=Texture'KatanaSA_A.Katana_Tex.KatanaSA_Unselect'
     SelectedHudImage=Texture'KatanaSA_A.Katana_Tex.KatanaSA_Select'
     FireModeClass(0)=Class'KatanaSA.KatanaSAFire'
     FireModeClass(1)=Class'KatanaSA.KatanaSAFireB'
     AIRating=0.400000
     CurrentRating=0.600000
     Description="An incredibly sharp katana sword."
     DisplayFOV=50.000000
     Priority=110
     GroupOffset=4
     PickupClass=Class'KatanaSA.KatanaSAPickup'
     BobDamping=8.000000
     AttachmentClass=Class'KatanaSA.KatanaSAAttachment'
     IconCoords=(X1=246,Y1=80,X2=332,Y2=106)
	 PlayerViewOffset=(X=18.000000,Y=0.500000,Z=-4.000000)
     ItemName="Katana SA"
}
