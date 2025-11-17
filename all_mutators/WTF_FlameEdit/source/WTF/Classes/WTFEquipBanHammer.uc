class WTFEquipBanHammer extends Axe;

var bool bIsBlown;
var float NextIronTime;
replication
{
	reliable if(Role == ROLE_Authority)
		bIsBlown;
	reliable if(Role < ROLE_Authority)
		ResetBlown;
	reliable if(Role < ROLE_Authority)
		DoLunge;
}
function ResetBlown()
{
	bIsBlown=false;
}

simulated function BringUp(optional Weapon PrevWeapon)
{
	if (ROLE == ROLE_AUTHORITY)
		bIsBlown=False;
	super.BringUp(PrevWeapon);
}

simulated function AltFire(float F)
{
	//if (bIsBlown)
	//{
		ResetBlown();
		PlayAnim(SelectAnim, SelectAnimRate, 0.0);
		Skins[BloodSkinSwitchArray] = default.Skins[BloodSkinSwitchArray];
		Texture = default.Texture;
	//}
}
simulated function DoLunge()
{
	local rotator VR; //ViewRotation
	local vector DirMomentum;

	VR = Instigator.Controller.GetViewRotation();
	DirMomentum.X=325.0;
	DirMomentum.Y=0.0;
	DirMomentum.Z= 275.0; //325.0; //default kfhumanpawn jump height
	VR.Pitch=0;
	FireMode[0].ModeDoFire();
	Instigator.AddVelocity(DirMomentum >> VR);
}

simulated exec function ToggleIronSights()
{
	if	(
			NextIronTime <= Level.TimeSeconds
			&&	!FireMode[0].bIsFiring && FireMode[0].NextFireTime < Level.TimeSeconds
		)
	{
		if (Instigator != none && Instigator.Physics != PHYS_Falling)
		{
			DoLunge();
			if (ROLE < ROLE_AUTHORITY) //client-side fx, essentially
				FireMode[0].ModeDoFire();
			NextIronTime=Level.TimeSeconds+3.0;
		}
	}
}

defaultproperties
{
	BloodyMaterial=Texture'WTF_A.BanHammer.Banhammer_bloody'
	BloodyMaterialRef="WTF_A.BanHammer.Banhammer_bloody"
	Weight=2.000000
	FireModeClass(0)=Class'WTFEquipBanHammerFire'
	FireModeClass(1)=Class'KFMod.NoFire'
	Description="A deadly weapon"
	PickupClass=Class'WTFEquipBanHammerPickup'
	AttachmentClass=Class'WTFEquipBanHammerAttachment'
	ItemName="Ban Hammer"
	Skins(0)=Texture'WTF_A.BanHammer.BanHammer'
	SkinRefs(0)="WTF_A.BanHammer.BanHammer"
}