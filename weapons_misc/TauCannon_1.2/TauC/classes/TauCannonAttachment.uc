class TauCannonAttachment extends KFWeaponAttachment;

var byte TauCannonCharge, OldTauCannonCharge;
var() class<Emitter> ChargeEmitterClass;
var() Emitter ChargeEmitter;

var byte NetChamberSpeed;
var int ChamberSpin;
var float ChamberSpeed;

replication
{
	// Things the server should send to the client.
	reliable if( bNetDirty && (!bNetOwner || bDemoRecording || bRepClientDemo) && (Role==ROLE_Authority) )
	//reliable if(Role == ROLE_Authority)
		NetChamberSpeed,TauCannonCharge;
}

simulated event Tick(float dt)
{
	local Rotator ChamberBn;

	super.Tick(dt);
	
	if(Role == ROLE_Authority)
	{
		NetChamberSpeed = byte(ChamberSpeed * float(255));
	}
	else
	{
		ChamberSpeed = float(NetChamberSpeed) / 255.00;
	}
	if(Level.NetMode != NM_DedicatedServer)
	{
		ChamberSpin += int(ChamberSpeed * float(655360) * dt);
		ChamberBn.Roll = ChamberSpin;
		SetBoneRotation('Chamber', ChamberBn);
	}
}

simulated function PostNetReceive()
{
	if( TauCannonCharge!=OldTauCannonCharge )
	{
		OldTauCannonCharge = TauCannonCharge;
		UpdateTauCannonCharge();
	}
}

simulated function UpdateTauCannonCharge()
{
    local float ChargeScale;

    if( Level.NetMode == NM_DedicatedServer )
    {
        return;
    }

    if( TauCannonCharge == 0 )
    {
        DestroyChargeEffect();
    }
    else
    {
        InitChargeEffect();

        ChargeScale = float(TauCannonCharge)/255.0;

        ChargeEmitter.Emitters[0].StartVelocityRadialRange.Min = Lerp( ChargeScale, 10, 75 );
        ChargeEmitter.Emitters[0].StartVelocityRadialRange.Max = Lerp( ChargeScale, 10, 75 );
        ChargeEmitter.Emitters[0].SizeScale[0].RelativeSize = Lerp( ChargeScale, 1, 3 );
    }
}

simulated function Destroyed()
{
    DestroyChargeEffect();

	Super.Destroyed();
}

simulated function InitChargeEffect()
{
    // don't even spawn on server
    if ( Level.NetMode == NM_DedicatedServer)
		return;

    if ( (ChargeEmitterClass != None) && ((ChargeEmitter == None) || ChargeEmitter.bDeleteMe) )
    {
        ChargeEmitter = Spawn(ChargeEmitterClass);
        if ( ChargeEmitter != None )
    		AttachToBone(ChargeEmitter, 'tip');
    }
}

simulated function DestroyChargeEffect()
{
    if (ChargeEmitter != None)
        ChargeEmitter.Destroy();
}

// Prevents tracers from spawning if player is using the flashlight function of the 9mm
simulated event ThirdPersonEffects()
{
	Super.ThirdPersonEffects();
}

defaultproperties
{
    mMuzFlashClass=Class'ROEffects.MuzzleFlash3rdNadeL'
	MeshRef="TC_R.TC3rdMesh"
    Mesh=SkeletalMesh'TC_R.TC3rdMesh'
    ChargeEmitterClass=Class'TauC.TauChargeNormal3rd'
    //mShellCaseEmitterClass=Class'KFMod.KFShotgunShellSpewer'
    mShellCaseEmitterClass=none

    MovementAnims(0)=JogF_M14
    MovementAnims(1)=JogB_M14
    MovementAnims(2)=JogL_M14
    MovementAnims(3)=JogR_M14
    CrouchAnims(0)=CHwalkF_M14
    CrouchAnims(1)=CHwalkB_M14
    CrouchAnims(2)=CHwalkL_M14
    CrouchAnims(3)=CHwalkR_M14
    WalkAnims(0)=WalkF_M14
    WalkAnims(1)=WalkB_M14
    WalkAnims(2)=WalkL_M14
    WalkAnims(3)=WalkR_M14
    AirStillAnim=JumpF_Mid
    AirAnims(0)=JumpF_Mid
    AirAnims(1)=JumpF_Mid
    AirAnims(2)=JumpL_Mid
    AirAnims(3)=JumpR_Mid
    TakeoffStillAnim=JumpF_Takeoff
    TakeoffAnims(0)=JumpF_Takeoff
    TakeoffAnims(1)=JumpF_Takeoff
    TakeoffAnims(2)=JumpL_Takeoff
    TakeoffAnims(3)=JumpR_Takeoff
    LandAnims(0)=JumpF_Land
    LandAnims(1)=JumpF_Land
    LandAnims(2)=JumpL_Land
    LandAnims(3)=JumpR_Land

    TurnRightAnim=TurnR_M14
    TurnLeftAnim=TurnL_M14
    CrouchTurnRightAnim=CH_TurnR_M14
    CrouchTurnLeftAnim=CH_TurnL_M14
    IdleRestAnim=Idle_M14//Idle_Rest
    IdleCrouchAnim=CHIdle_M14
    IdleSwimAnim=Swim_Tread
    IdleWeaponAnim=Idle_M14//Idle_Rifle
    IdleHeavyAnim=Idle_M14//Idle_Biggun
    IdleRifleAnim=Idle_M14//Idle_Rifle
    IdleChatAnim=Idle_M14
    FireAnims(0)=Fire_M14
    FireAnims(1)=Fire_M14
    FireAnims(2)=Fire_M14
    FireAnims(3)=Fire_M14
    FireAltAnims(0)=Fire_M14
    FireAltAnims(1)=Fire_M14
    FireAltAnims(2)=Fire_M14
    FireAltAnims(3)=Fire_M14
    FireCrouchAnims(0)=CHFire_M14
    FireCrouchAnims(1)=CHFire_M14
    FireCrouchAnims(2)=CHFire_M14
    FireCrouchAnims(3)=CHFire_M14
    FireCrouchAltAnims(0)=CHFire_M14
    FireCrouchAltAnims(1)=CHFire_M14
    FireCrouchAltAnims(2)=CHFire_M14
    FireCrouchAltAnims(3)=CHFire_M14
    HitAnims(0)=HitF_M14
    HitAnims(1)=HitB_M14
    HitAnims(2)=HitL_M14
    HitAnims(3)=HitR_M14
    PostFireBlendStandAnim=Blend_M14
    PostFireBlendCrouchAnim=CHBlend_M14
}
