class VoodooDoll extends KFWeapon config(VoodooDoll);

var cache class<InventoryAttachment> NeedleAttachmentClass;
var Actor altThirdPersonActor;
var MeshAnimation CustomAnim;

function AttachToPawn(Pawn P)
{
	local name BoneName;

	super(Inventory).AttachToPawn(P);
	// End:0x41 Loop:False
	if(altThirdPersonActor == none)
	{
		altThirdPersonActor = Spawn(NeedleAttachmentClass, Owner);
		InventoryAttachment(altThirdPersonActor).InitFor(self);
	}
	// End:0x63
	else
	{
		altThirdPersonActor.NetUpdateTime = Level.TimeSeconds - float(1);
	}
	BoneName = P.GetOffhandBoneFor(self);
	// End:0xb6 Loop:False
	if(BoneName == 'None')
	{
		altThirdPersonActor.SetLocation(P.Location);
		altThirdPersonActor.SetBase(P);
	}
	// End:0xcf
	else
	{
		P.AttachToBone(altThirdPersonActor, BoneName);
	}
}

simulated function WeaponTick(float dt)
{
	super.WeaponTick(dt);
	// End:0x42 Loop:False
	if(MagAmmoRemaining != AmmoAmount(0))
	{
		MagAmmoRemaining = AmmoAmount(0);
		NetUpdateTime = Level.TimeSeconds - float(1);
	}
}

simulated function bool ConsumeAmmo(int Mode, float load, optional bool bAmountNeededIsMax)
{
	// End:0x3e Loop:False
	if(super(Weapon).ConsumeAmmo(0, load, bAmountNeededIsMax))
	{
		MagAmmoRemaining -= int(load);
		NetUpdateTime = Level.TimeSeconds - float(1);
		return true;
	}
	return false;
}

simulated function int AmmoAmount(int Mode)
{
	// End:0x1e Loop:False
	if(Ammo[0] != none)
	{
		return Ammo[0].AmmoAmount;
	}
	return 0;
}

simulated function bool StartFire(int Mode)
{
	// End:0x17 Loop:False
	if(Mode == 1)
	{
		return super.StartFire(Mode);
	}
	// End:0x29 Loop:False
	if(!super.StartFire(Mode))
	{
		return false;
	}
	// End:0x38 Loop:False
	if(AmmoAmount(0) <= 0)
	{
		return false;
	}
	AnimStopLooping();
	// End:0x83 Loop:False
	if(!FireMode[Mode].IsInState('FireLoop') && (AmmoAmount(0) > 0))
	{
		FireMode[Mode].StartFiring();
		return true;
	}
	// End:0x85
	else
	{
		return false;
	}
	return true;
}

simulated function AnimEnd(int Channel)
{
	// End:0x23 Loop:False
	if(!FireMode[0].IsInState('FireLoop'))
	{
		super(Weapon).AnimEnd(Channel);
	}
}

defaultproperties
{
	NeedleAttachmentClass=class'VoodooDollAttachmentNeedle'
	CustomAnim=MeshAnimation'VoodooDoll_A.3rd_doll_anims'
	MagCapacity=200
	HudImage=Texture'VoodooDoll_T.DollUnselected'
	SelectedHudImage=Texture'VoodooDoll_T.DollSelected'
	bSteadyAim=true
	Weight=4.00
	StandardDisplayFOV=75.00
	TraderInfoTexture=Texture'VoodooDoll_T.DollTrader'
	FireModeClass[0]=class'VoodooDollFire'
	FireModeClass[1]=class'VoodooDollFireSecondary'
	SelectSound=Sound'KFPlayerSound.getweaponout'
	AIRating=0.25
	CurrentRating=0.25
	Description="Voodoo Doll"
	DisplayFOV=75.00
	Priority=3
	SmallViewOffset=(X=13.00,Y=18.00,Z=-10.00)
	InventoryGroup=4
	GroupOffset=6
	PickupClass=class'VoodooDollPickup'
	PlayerViewOffset=(X=1.79,Y=3.61,Z=1.15)
	AttachmentClass=class'VoodooDollAttachment'
	IconCoords=(X1=434,Y1=253,X2=506,Y2=292)
	ItemName="Voodoo-Doll"
	Mesh=SkeletalMesh'VoodooDoll_A.VoodooDoll'
	Skins=/* Cannot find this array's type.
		DataSize:5 */
}