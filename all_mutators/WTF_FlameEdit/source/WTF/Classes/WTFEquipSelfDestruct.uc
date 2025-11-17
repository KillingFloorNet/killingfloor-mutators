class WTFEquipSelfDestruct extends PipeBombExplosive;

var bool bBeingDestroyed;
var texture ArmedSkin1;
var texture ArmedSkin2;
simulated function ArmDevice()
{
	Skins[1] = ArmedSkin1;
	Skins[2] = ArmedSkin2;
}

simulated function UnArmDevice()
{
	Skins[1] = default.Skins[1];
	Skins[2] = default.Skins[2];
}

defaultproperties
{
	FireModeClass(0)=Class'WTFEquipSelfDestructFire'
	AmmoClass(0)=Class'WTFEquipSelfDestructAmmo'
	Description="A deadly weapon"
	Priority=0
	InventoryGroup=1
	GroupOffset=0
	PickupClass=Class'WTFEquipSelfDestructPickup'
	AttachmentClass=Class'WTFEquipSelfDestructAttachment'
	ItemName="Self Destruct!"
	Skins(0)=Texture'WTF_A.Selfdestruct.Selfdestruct'
	Skins(1)=Texture'KF_Weapons2_Trip_T.Special.Pipebomb_RLight_OFF'
	Skins(2)=Shader'KF_Weapons2_Trip_T.Special.Pipebomb_GLight_shdr'
	SkinRefs(0)="WTF_A.Selfdestruct.Selfdestruct"
	SkinRefs(1)="KF_Weapons2_Trip_T.Special.Pipebomb_RLight_OFF"
	SkinRefs(2)="KF_Weapons2_Trip_T.Special.Pipebomb_GLight_shdr"
}