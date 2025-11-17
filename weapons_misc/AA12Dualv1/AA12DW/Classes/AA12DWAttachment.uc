class AA12DWAttachment extends DualiesAttachment;

simulated function UpdateTacBeam( float Dist );
simulated function TacBeamGone();

simulated function DoFlashEmitter()
{
	if(bIsOffHand)
		return;
	if( FiringMode==1 )
	{
		brother.ActuallyFlash();
		ActuallyFlash();	
	}
	else
	{	
		if(bMyFlashTurn)
			ActuallyFlash();
		else if(brother != None)
			brother.ActuallyFlash();
		bMyFlashTurn = !bMyFlashTurn;
	}
}

//Muzzle flash for both primary and alternate fire
simulated event ThirdPersonEffects()
{
	if( FiringMode==1 )
	{
		DoFlashEmitter();
	}
	Super.ThirdPersonEffects();
}

defaultproperties
{
    Mesh=SkeletalMesh'AA12DW_R.Mesh3rd'
    MeshRef="AA12DW_R.Mesh3rd"
	mMuzFlashClass=Class'ROEffects.MuzzleFlash3rdKar'
    mTracerClass=none
    mShellCaseEmitterClass=Class'KFMod.KFShotgunShellSpewer'

    BrotherMesh=SkeletalMesh'AA12DW_R.Mesh3rd'

    MovementAnims(0)=JogF_Dual9mm
    MovementAnims(1)=JogB_Dual9mm
    MovementAnims(2)=JogL_Dual9mm
    MovementAnims(3)=JogR_Dual9mm
    CrouchAnims(0)=CHwalkF_Dual9mm
    CrouchAnims(1)=CHwalkB_Dual9mm
    CrouchAnims(2)=CHwalkL_Dual9mm
    CrouchAnims(3)=CHwalkR_Dual9mm
    WalkAnims(0)=WalkF_Dual9mm
    WalkAnims(1)=WalkB_Dual9mm
    WalkAnims(2)=WalkL_Dual9mm
    WalkAnims(3)=WalkR_Dual9mm
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

    TurnRightAnim=TurnR_Dual9mm
    TurnLeftAnim=TurnL_Dual9mm
    CrouchTurnRightAnim=CH_TurnR_Dual9mm
    CrouchTurnLeftAnim=CH_TurnL_Dual9mm
    IdleRestAnim=Idle_Dual9mm
    IdleCrouchAnim=CHIdle_Dual9mm
    IdleSwimAnim=Swim_Tread
    IdleWeaponAnim=Idle_Dual9mm
    IdleHeavyAnim=Idle_Dual9mm
    IdleRifleAnim=Idle_Dual9mm
    IdleChatAnim=Idle_Dual9mm
    FireAnims(0)=DualiesAttackRight
    FireAnims(1)=DualiesAttackRight
    FireAnims(2)=DualiesAttackRight
    FireAnims(3)=DualiesAttackRight
    FireAltAnims(0)=DualiesAttackLeft
    FireAltAnims(1)=DualiesAttackLeft
    FireAltAnims(2)=DualiesAttackLeft
    FireAltAnims(3)=DualiesAttackLeft
    FireCrouchAnims(0)=CHDualiesAttackRight
    FireCrouchAnims(1)=CHDualiesAttackRight
    FireCrouchAnims(2)=CHDualiesAttackRight
    FireCrouchAnims(3)=CHDualiesAttackRight
    FireCrouchAltAnims(0)=CHDualiesAttackLeft
    FireCrouchAltAnims(1)=CHDualiesAttackLeft
    FireCrouchAltAnims(2)=CHDualiesAttackLeft
    FireCrouchAltAnims(3)=CHDualiesAttackLeft
    HitAnims(0)=HitF_Dual9mmm
    HitAnims(1)=HitB_Dual9mm
    HitAnims(2)=HitL_Dual9mm
    HitAnims(3)=HitR_Dual9mm
    PostFireBlendStandAnim=Blend_Dual9mm
    PostFireBlendCrouchAnim=CHBlend_Dual9mm
}
