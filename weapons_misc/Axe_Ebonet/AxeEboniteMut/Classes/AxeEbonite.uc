class AxeEbonite extends KFMeleeGun;

#exec OBJ LOAD FILE="AxeEbonite_A.ukx"

defaultproperties
{
    Skins(0)=Texture'AxeEbonite_A.exe_skurim'
	Skins(1)=Texture'KF_Weapons3_Trip_T.hands.Priest_Hands_1st_P'	
	
    weaponRange=115.000000

    BloodyMaterialRef="KF_IJC_Halloween_Weapons.Scythe.scythe_blood_cmb"
    bSpeedMeUp=True

    Weight=6.000000
    FireModeClass(0)=Class'AxeEboniteMut.AxeEboniteFire'
    FireModeClass(1)=Class'AxeEboniteMut.AxeEboniteFireB'
    Description="It's a AxeEbonite. Long handle. Long blade. Good for reaping corn, wheat - or shambling monsters."
    Priority=125
    GroupOffset=6
    PickupClass=Class'AxeEboniteMut.AxeEbonitePickup'
    BobDamping=8.000000
    AttachmentClass=Class'AxeEboniteMut.AxeEboniteAttachment'
    IconCoords=(X1=169,Y1=39,X2=241,Y2=77)
    ItemName="AxeEbonite"
    Mesh=SkeletalMesh'AxeEbonite_A.EXE_wsb_M'    
    SleeveNum=1

    AIRating=0.300000
    CurrentRating=0.5

    ChopSlowRate=0.200000

    BloodSkinSwitchArray=0

    DisplayFOV=75.000000
    StandardDisplayFOV=75.000000

    HudImage="AxeEbonite_A.in2"
    SelectedHudImage="AxeEbonite_A.in1"
    SelectSoundRef="KF_KatanaSnd.Katana_Select"
    TraderInfoTexture=Texture'AxeEbonite_A.trede'

    bIsTier2Weapon=True
}
