class MGP extends M79GrenadeLauncher;

#exec OBJ LOAD FILE=BOGPDTv2_A.ukx
#exec OBJ LOAD FILE=BOGPDTv2_T.utx
#exec OBJ LOAD FILE=MGP_T.utx

simulated function Notify_ShowBullets ()
{
	SetBoneScale(0, 1.0, 'GrenadePistolGrenade');
}

simulated function Notify_HideBullets ()
{
	SetBoneScale(0, 0.0, 'GrenadePistolGrenade');
}

defaultproperties
{
	FlashBoneName="Muzzle"
	HudImage=Texture'BOGPDTv2_A.bogp_unselected'
	SelectedHudImage=Texture'BOGPDTv2_A.bogp_selected'
	Weight=2.000000
	TraderInfoTexture=Texture'BOGPDTv2_A.bogp_unselected'
	FireModeClass(0)=Class'MGPFire'
	SelectAnim="Pullout"
	PutDownAnim="Putaway"
	Description=""
	Priority=105
	InventoryGroup=2
	GroupOffset=2
	PickupClass=Class'MGPPickup'
	AttachmentClass=Class'MGPAttachment'
	ItemName="Medic Grenade Pistol"
	Mesh=SkeletalMesh'BOGPDTv2_A.BOGP'
	Skins(0)=Texture'MGP_T.MGP'
}