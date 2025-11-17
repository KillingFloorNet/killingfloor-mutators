class CSCrossbowAttachment extends KFWeaponAttachment;

simulated event ThirdPersonEffects()
{
	
	PlayAnim('Fire');

	Super.ThirdPersonEffects();
}

simulated function WeaponLight(){}
simulated function DoFlashEmitter(){}


defaultproperties
{
    mMuzFlashClass=None
    mTracerClass=None
    mShellCaseEmitterClass=None
    bRapidFire=True
    bAltRapidFire=True
    SplashEffect=Class'ROEffects.BulletSplashEmitter'
    CullDistance=5000.000000
    MeshRef="CSCrossbow_A.cs_xbow_3rd"

    WeaponAmbientScale=1.5

    MovementAnims(0)="JogF_Thompson"
    MovementAnims(1)="JogB_Thompson"
    MovementAnims(2)="JogL_Thompson"
    MovementAnims(3)="JogR_Thompson"
    CrouchAnims(0)="CHWalkF_Thompson"
    CrouchAnims(1)="CHWalkB_Thompson"
    CrouchAnims(2)="CHWalkL_Thompson"
    CrouchAnims(3)="CHWalkR_Thompson"
    WalkAnims(0)="WalkF_Thompson"
    WalkAnims(1)="WalkB_Thompson"
    WalkAnims(2)="WalkL_Thompson"
    WalkAnims(3)="WalkR_Thompson"
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

    TurnLeftAnim="TurnL_Thompson"
    TurnRightAnim="TurnR_Thompson"
    CrouchTurnRightAnim="CH_TurnR_Thompson"
    CrouchTurnLeftAnim="CH_TurnL_Thompson"
    IdleRestAnim="Idle_Thompson"
    IdleCrouchAnim="CHIdle_Thompson"
    IdleSwimAnim=Swim_Tread
    IdleWeaponAnim="Idle_Thompson"
    IdleHeavyAnim="Idle_Thompson"
    IdleRifleAnim="Idle_Thompson"
    IdleChatAnim="Idle_Thompson"
    FireAnims(0)="Fire_Thompson"
    FireAnims(1)="Fire_Thompson"
    FireAnims(2)="Fire_Thompson"
    FireAnims(3)="Fire_Thompson"
    FireAltAnims(0)="Fire_Thompson"
    FireAltAnims(1)="Fire_Thompson"
    FireAltAnims(2)="Fire_Thompson"
    FireAltAnims(3)="Fire_Thompson"
    FireCrouchAnims(0)="CHFire_Thompson"
    FireCrouchAnims(1)="CHFire_Thompson"
    FireCrouchAnims(2)="CHFire_Thompson"
    FireCrouchAnims(3)="CHFire_Thompson"
    FireCrouchAltAnims(0)="CHFire_Thompson"
    FireCrouchAltAnims(1)="CHFire_Thompson"
    FireCrouchAltAnims(2)="CHFire_Thompson"
    FireCrouchAltAnims(3)="CHFire_Thompson"
    HitAnims(0)="HitF_Thompson"
    HitAnims(1)="HitB_Thompson"
    HitAnims(2)="HitL_Thompson"
    HitAnims(3)="HitR_Thompson"
    PostFireBlendStandAnim="Blend_Thompson"
    PostFireBlendCrouchAnim="CHBlend_Thompson"
}
