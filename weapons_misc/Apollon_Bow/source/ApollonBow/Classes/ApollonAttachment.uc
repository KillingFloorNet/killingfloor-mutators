class ApollonAttachment extends KFWeaponAttachment;

// No flash, this is a bow
simulated function DoFlashEmitter();

simulated function Destroyed()
{
	AmbientSound=None;
	SoundVolume=0;
	Super.Destroyed();
}

defaultproperties
{
    mMuzFlashClass=None
    Mesh=SkeletalMesh'ApollonBow_H.ApollonBow_3rd'
	
	SoundRadius=100
    SoundVolume=100
    WeaponAmbientScale=2.0
	
	AmbientSound=Sound'ApollonBow.abow_whisper'

    MovementAnims(0)=JogF_AK47
    MovementAnims(1)=JogB_AK47
    MovementAnims(2)=JogL_AK47
    MovementAnims(3)=JogR_AK47
    CrouchAnims(0)=CHwalkF_AK47
    CrouchAnims(1)=CHwalkB_AK47
    CrouchAnims(2)=CHwalkL_AK47
    CrouchAnims(3)=CHwalkR_AK47
    WalkAnims(0)=WalkF_AK47
    WalkAnims(1)=WalkB_AK47
    WalkAnims(2)=WalkL_AK47
    WalkAnims(3)=WalkR_AK47
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

    TurnRightAnim=TurnR_AK47
    TurnLeftAnim=TurnL_AK47
    CrouchTurnRightAnim=CH_TurnR_AK47
    CrouchTurnLeftAnim=CH_TurnL_AK47
    IdleRestAnim=Idle_AK47//Idle_Rest
    IdleCrouchAnim=CHIdle_AK47
    IdleSwimAnim=Swim_Tread
    IdleWeaponAnim=Idle_AK47//Idle_Rifle
    IdleHeavyAnim=Idle_AK47//Idle_Biggun
    IdleRifleAnim=Idle_AK47//Idle_Rifle
    IdleChatAnim=Idle_AK47
    FireAnims(0)=Fire_AK47
    FireAnims(1)=Fire_AK47
    FireAnims(2)=Fire_AK47
    FireAnims(3)=Fire_AK47
    FireAltAnims(0)=Fire_AK47
    FireAltAnims(1)=Fire_AK47
    FireAltAnims(2)=Fire_AK47
    FireAltAnims(3)=Fire_AK47
    FireCrouchAnims(0)=CHFire_AK47
    FireCrouchAnims(1)=CHFire_AK47
    FireCrouchAnims(2)=CHFire_AK47
    FireCrouchAnims(3)=CHFire_AK47
    FireCrouchAltAnims(0)=CHFire_AK47
    FireCrouchAltAnims(1)=CHFire_AK47
    FireCrouchAltAnims(2)=CHFire_AK47
    FireCrouchAltAnims(3)=CHFire_AK47
    HitAnims(0)=HitF_AK47
    HitAnims(1)=HitB_AK47
    HitAnims(2)=HitL_AK47
    HitAnims(3)=HitR_AK47
    PostFireBlendStandAnim=Blend_AK47
    PostFireBlendCrouchAnim=CHBlend_AK47

	// Just to be safe :)
    LightBrightness=0
}
