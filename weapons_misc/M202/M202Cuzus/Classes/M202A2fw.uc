class M202A2fw extends M202A1fw;

#exec OBJ LOAD FILE=M202_T.utx
#exec OBJ LOAD FILE=M202_SM.usx
#exec OBJ LOAD FILE=M202_A.ukx

var RocketAttachmentFirstPerson ERockets;

var() class<InventoryAttachment> RocketAttachmentClass;
var Actor RocketAttachment;

simulated function PostBeginPlay()
{
	super.PostBeginPlay();

	if( Level.Netmode != NM_DedicatedServer)
		SpawnRocket();
}

simulated function SpawnRocket()
{
	local Rotator RotationVect;
	
	SetBoneScale (4, 0.0, 'Rocket01');
	SetBoneScale (5, 0.0, 'Rocket02');
	SetBoneScale (6, 0.0, 'Rocket03');
	SetBoneScale (7, 0.0, 'Rocket04');
	
	if ( RocketAttachment == none )
	{
		RocketAttachment = Spawn(RocketAttachmentClass,,,,);
		AttachToBone(RocketAttachment,'RocketBlock');		
		RotationVect.Yaw=0;
		RotationVect.Pitch=-32768;
		RotationVect.Roll=-16384;
		RocketAttachment.SetRelativeRotation(RotationVect);
	}
}

simulated function Notify_ShowMeRockets(int Kolvo)
{
	SetBoneScale (4, 0.0, 'Rocket01');
	SetBoneScale (5, 0.0, 'Rocket02');
	SetBoneScale (6, 0.0, 'Rocket03');
	SetBoneScale (7, 0.0, 'Rocket04');

	if ( RocketAttachment != none )
	{
		if(Kolvo == 0)
		{
			RocketAttachment.SetBoneScale (0, 0.0, 'ERocket01');
			RocketAttachment.SetBoneScale (1, 0.0, 'ERocket02');
			RocketAttachment.SetBoneScale (2, 0.0, 'ERocket03');
			RocketAttachment.SetBoneScale (3, 0.0, 'ERocket04');
		}
		else
		if(Kolvo == 1)
		{
			RocketAttachment.SetBoneScale (0, 0.0, 'ERocket01');
			RocketAttachment.SetBoneScale (1, 0.0, 'ERocket02');
			RocketAttachment.SetBoneScale (2, 0.0, 'ERocket03');
			RocketAttachment.SetBoneScale (3, 1.0, 'ERocket04');
		}
		else
		if(Kolvo == 2)
		{
			RocketAttachment.SetBoneScale (0, 0.0, 'ERocket01');
			RocketAttachment.SetBoneScale (1, 0.0, 'ERocket02');
			RocketAttachment.SetBoneScale (2, 1.0, 'ERocket03');
			RocketAttachment.SetBoneScale (3, 1.0, 'ERocket04');
		}
		else
		if(Kolvo == 3)
		{
			RocketAttachment.SetBoneScale (0, 0.0, 'ERocket01');
			RocketAttachment.SetBoneScale (1, 1.0, 'ERocket02');
			RocketAttachment.SetBoneScale (2, 1.0, 'ERocket03');
			RocketAttachment.SetBoneScale (3, 1.0, 'ERocket04');
		}
	
		else
		if(Kolvo >= 4)
		{
			RocketAttachment.SetBoneScale (0, 1.0, 'ERocket01');
			RocketAttachment.SetBoneScale (1, 1.0, 'ERocket02');
			RocketAttachment.SetBoneScale (2, 1.0, 'ERocket03');
			RocketAttachment.SetBoneScale (3, 1.0, 'ERocket04');
		}
	}
}


simulated function WeaponTick(float dt)
{
    if( bAimingRifle && ForceZoomOutTime > 0 && Level.TimeSeconds - ForceZoomOutTime > 0 )
    {
	    ForceZoomOutTime = 0;

    	ZoomOut(false);

    	if( Role < ROLE_Authority)
			ServerZoomOut(false);
	}
	else
	{
		if( !bAimingRifle || (ForceZoomOutTime > 0 && Level.TimeSeconds - ForceZoomOutTime > 0) )
		{
			super.WeaponTick(dt);
		}
	}
}

simulated function bool StartFire(int Mode)
{
    if( super.StartFire(Mode) )
    {
	if(Mode==0)
	{
        	ForceZoomOutTime = Level.TimeSeconds + 0.4;
	}
	else
	{
		ForceZoomOutTime = Level.TimeSeconds + MagAmmoRemaining*FireMode[Mode].FireRate + 0.4;
	}
        return true;
    }

    return false;
}

defaultproperties
{    
    ZoomMat=FinalBlend'M202_T.HUD.ScopeA2'
    HudImage=Texture'M202_T.HUD.M202_Black_unselected'
    SelectedHudImage=Texture'M202_T.HUD.M202_Black'
    TraderInfoTexture=Texture'M202_T.HUD.Trader_M202_Black'
    FireModeClass(0)=Class'M202A2Fire'
    FireModeClass(1)=Class'M202A2AltFire'
    Description="The M202 A2 Grim Reaper"
    InventoryGroup=4
    GroupOffset=9
    PickupClass=Class'M202A2Pickup'  
    AttachmentClass=Class'M202A2Attachment'
    ItemName="M202A2 Grim Reaper"
    Mesh=SkeletalMesh'M202_A.M202'
    Skins(1)=Shader'M202_T.items.M202_Color_BlackDT_sh'
    Skins(2)=Texture'M202_T.HUD.PricelA2'
    ScopeTexMat=Texture'M202_T.HUD.PricelA2'
    RocketAttachmentClass=class'RocketAttachmentFirstPerson'
}