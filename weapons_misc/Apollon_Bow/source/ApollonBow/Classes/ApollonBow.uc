class ApollonBow extends KFWeapon;

// This puts the .ukx into the .u ;)
#exec obj load file="ApollonBow_H.ukx" package="ApollonBow"

//=============================================================================
// Animations

var				name					IdleAnimE, LoadAnim, SelectAnimE, PutdownAnimE;
var				Apollon1PFlame			FlameOn;

//=============================================================================
// Functions
//=============================================================================

function float GetAIRating()
{
	local AIController B;

	B = AIController(Instigator.Controller);
	if ( (B == None) || (B.Enemy == None) )
		return AIRating;

	return (AIRating + 0.0003 * FClamp(1500 - VSize(B.Enemy.Location - Instigator.Location),0,1000));
}

function byte BestMode()
{
	return 0;
}

function bool RecommendRangedAttack()
{
	return true;
}

//TODO: LONG ranged?
function bool RecommendLongRangedAttack()
{
	return true;
}

function float SuggestAttackStyle()
{
	return -1.0;
}

simulated function AnimEnd(int channel)
{
	local name anim;
    local float frame, rate;
	
	// Figure out what animation we are playing
	GetAnimParams(0, anim, frame, rate);
	
    if (FireMode[0].bIsFiring)
    {
    	if( bAimingRifle )
    	{
    		LoopAnim('ChargeLoop');
    	}
    	else
    	{
    		LoopAnim('ChargeLoop');
    	}
    }
    else
    {
		if (anim == LoadAnim)
			PlayIdle();
		else
			Super.AnimEnd(channel);
    }
}

// When we pick up ammo
simulated function WeaponTick(float dt)
{
	local name anim;
    local float frame, rate;
	
	// If we find ammunition
	if (MagAmmoRemaining + AmmoAmount(0) > 0)
	{
		GetAnimParams(0, anim, frame, rate);
		if (anim == IdleAnimE || anim == SelectAnimE)
			PlayAnim(LoadAnim, 1.0, 0.1);
	}
	
	// If we have no flame
	if (FlameOn == None)
		SpawnFlame();
		
	Super.WeaponTick(dt);
}

simulated function SpawnFlame()
{
	FlameOn = Spawn(Class'Apollon1PFlame',Self);
	AttachToBone(FlameOn,'fx_bone');
}

simulated function BringUp(optional Weapon PrevWeapon)
{
	if (MagAmmoRemaining + AmmoAmount(0) > 0)
		SelectAnim = default.SelectAnim;
	else
		SelectAnim = SelectAnimE;
	
	super.BringUp(PrevWeapon);
}

simulated function bool PutDown()
{
	if (MagAmmoRemaining + AmmoAmount(0) > 0)
		PutDownAnim = default.PutDownAnim;
	else
		PutDownAnim = PutDownAnimE;
		
	// Destroy flame
	if (FlameOn != None)
		FlameOn.Destroy();
	
	return Super.PutDown();
}

simulated function Destroyed()
{
	if (FlameOn != None)
		FlameOn.Destroy();
	Super.Destroyed();
}

simulated function PlayIdle()
{
	if (MagAmmoRemaining + AmmoAmount(0) > 0)
		LoopAnim(IdleAnim, IdleAnimRate, 0.2);
	else
		LoopAnim(IdleAnimE, IdleAnimRate, 0.2);
}

simulated event OnZoomOutFinished()
{
	local name anim;
	local float frame, rate;

	GetAnimParams(0, anim, frame, rate);

	if (ClientState == WS_ReadyToFire)
	{
		// Play the regular idle anim when we're finished zooming out
		if (anim == IdleAimAnim)
		{
            PlayIdle();
		}
		else if(anim == 'ChargeLoop')
		{
            LoopAnim('ChargeLoop');
		}
	}
}

simulated event OnZoomInFinished()
{
	local name anim;
	local float frame, rate;

	GetAnimParams(0, anim, frame, rate);

	if (ClientState == WS_ReadyToFire)
	{
		// Play the iron idle anim when we're finished zooming in
		if (anim == IdleAnim)
		{
		   PlayIdle();
		}
		else if( anim == 'ChargeLoop' )
		{
            LoopAnim('ChargeLoop');
		}
	}
}

defaultproperties
{
	// Empties
	IdleAnimE = Idle_E
	PutdownAnimE = Putdown_E
	SelectAnimE = Select_E
	
	// Select slower
	SelectAnimRate=1.0
	BringUpTime=0.5
	//BringUpTime = 1.0
	
	// When we pick up ammo
	LoadAnim = load
	
	//-------------------------------
	
    IdleAimAnim=Idle

    Skins(0)=Texture'ApollonBow.Bow'
	Skins(1)=Texture'ApollonBow.Arrow'
    SleeveNum=2

    Weight=4.000000
    MagCapacity=1
    ReloadRate=0.010000
    FireModeClass(0)=Class'ApollonBow.ApollonBowFire'
    FireModeClass(1)=Class'KFMod.NoFire'
    PutDownAnim="PutDown"
    SelectSound=Sound'KF_XbowSnd.Xbow_Select'
    SelectForce="SwitchToAssaultRifle"
    AIRating=0.650000
    CurrentRating=0.650000
    Description="The bow is capable of firing mighty energy arrows of mass destruction. Force of the arrows full-charged is sufficient to destroy big cities and even states. According to legend this bow was used in the destruction of the Tower of Babel."
    Priority=180
    InventoryGroup=4
    GroupOffset=7
    PickupClass=Class'ApollonBow.ApollonBowPickup'
    PlayerViewOffset=(X=18.000000,Y=20.000000,Z=-6.000000)
    BobDamping=6.000000
    AttachmentClass=Class'ApollonBow.ApollonAttachment'
    IconCoords=(X1=253,Y1=146,X2=333,Y2=181)
    ItemName="Apollon Bow"
    LightType=LT_None
    LightBrightness=0.000000
    LightRadius=0.000000
    Mesh=SkeletalMesh'ApollonBow.ApollonBow'
    DrawScale=1.000000
    AmbientGlow=0

    ZoomTime=0.25
    FastZoomOutTime=0.2
    ZoomInRotation=(Pitch=-910,Yaw=0,Roll=2910)
    bHasAimingMode=true

    DisplayFOV=65.000000
    StandardDisplayFOV=65.0
    PlayerIronSightFOV=70
    ZoomedDisplayFOV=45

	HudImage=Texture'ApollonBow_H.Apollon_unselected'
	SelectedHudImage=Texture'ApollonBow_H.Apollon_Selected'
	TraderInfoTexture=Texture'ApollonBow_H.Apollon_Trader'

	bIsTier3Weapon=true
}
