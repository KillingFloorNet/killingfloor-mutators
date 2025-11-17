class M134DTAttachment extends KFWeaponAttachment;

var byte NetBarrelSpeed;
var int BarrelTurn;
var float BarrelSpeed;

replication
{
	// Replication block:2
	reliable if(Role == ROLE_Authority)
		NetBarrelSpeed;
}

simulated function PostBeginPlay()
{
	SetTimer(0.2,true);
	Super.PostBeginPlay();
}

simulated function Timer()
{
	if(Instigator!=None)
	{
		if(!Instigator.HasAnim('Reload_M134_Y'))
		{
			Instigator.LinkSkelAnim(MeshAnimation'm134DT_A.Soldier_M134DT_anims');
			SetTimer(1.0,true);
		}
	}
	Super.Timer();
}

/*simulated function Timer()
{
	if(Instigator!=None)
	{
		if(Instigator.PlayerReplicationInfo!=None && !Instigator.HasAnim('Reload_M134_Y'))
		{
			//Log("3 person animation applied"@Instigator.PlayerReplicationInfo.PlayerName);
			Instigator.LinkSkelAnim(MeshAnimation'm134DT_A.Soldier_M134DT_anims');
			Instigator.PlayAnim('Idle_RPG_Y',0.1,0.1);
			SetTimer(1.0,true);
		}
	}
	Super.Timer();
}*/

simulated event Tick(float dt)
{
	local Rotator bt;

	super.Tick(dt);
	if(Role == ROLE_Authority)
	{
		NetBarrelSpeed = byte(BarrelSpeed * float(255));
	}
	else
	{
		BarrelSpeed = float(NetBarrelSpeed) / 255.00;
	}
	if(Level.NetMode != NM_DedicatedServer)
	{
		BarrelTurn += int(BarrelSpeed * float(655360) * dt);
		bt.Yaw = BarrelTurn;
		SetBoneRotation('wpn_block', bt);
	}
}

defaultproperties
{
     mMuzFlashClass=Class'ROEffects.MuzzleFlash3rdMP'
     mTracerClass=Class'KFMod.KFNewTracer'
     mShellCaseEmitterClass=Class'KFMod.KFShellSpewer'
	 ShellEjectBoneName="ShellEjector"
	 MovementAnims(0)="JogF_M134_Y"
     MovementAnims(1)="JogB_M134_Y"
     MovementAnims(2)="JogL_M134_Y"
     MovementAnims(3)="JogR_M134_Y"
     TurnLeftAnim="TurnL_M134_Y"
     TurnRightAnim="TurnR_M134_Y"
     CrouchAnims(0)="CHWalkF_M134_Y"
     CrouchAnims(1)="CHWalkB_M134_Y"
     CrouchAnims(2)="CHWalkL_M134_Y"
     CrouchAnims(3)="CHWalkR_M134_Y"
     CrouchTurnRightAnim="CH_TurnR_M134_Y"
     CrouchTurnLeftAnim="CH_TurnL_M134_Y"
     IdleCrouchAnim="CHIdle_M134_Y"
     IdleWeaponAnim="Idle_M134_Y"
     IdleRestAnim="Idle_M134_Y"
     IdleChatAnim="Idle_M134_Y"
     IdleHeavyAnim="Idle_M134_Y"
     IdleRifleAnim="Idle_M134_Y"
     FireAnims(0)="Fire_M134_Y"
     FireAnims(1)="Fire_M134_Y"
     FireAnims(2)="Fire_M134_Y"
     FireAnims(3)="Fire_M134_Y"
     FireAltAnims(0)="Fire_M134_Y"
     FireAltAnims(1)="Fire_M134_Y"
     FireAltAnims(2)="Fire_M134_Y"
     FireAltAnims(3)="Fire_M134_Y"
     FireCrouchAnims(0)="CHFire_M134_Y"
     FireCrouchAnims(1)="CHFire_M134_Y"
     FireCrouchAnims(2)="CHFire_M134_Y"
     FireCrouchAnims(3)="CHFire_M134_Y"
     FireCrouchAltAnims(0)="CHFire_M134_Y"
     FireCrouchAltAnims(1)="CHFire_M134_Y"
     FireCrouchAltAnims(2)="CHFire_M134_Y"
     FireCrouchAltAnims(3)="CHFire_M134_Y"
     HitAnims(0)="HitF_M134_Y"
     HitAnims(1)="HitB_M134_Y"
     HitAnims(2)="HitL_M134_Y"
     HitAnims(3)="HitR_M134_Y"
	 PostFireBlendStandAnim="Blend_M134_Y"
	 PostFireBlendCrouchAnim="CHBlend_M134_Y"
	 //
	 AirAnims(0)="JumpF_Mid_M134_Y"
     AirAnims(1)="JumpF_Mid_M134_Y"
     AirAnims(2)="JumpL_Mid_M134_Y"
     AirAnims(3)="JumpR_Mid_M134_Y"
     TakeoffAnims(0)="JumpF_Takeoff_M134_Y"
     TakeoffAnims(1)="JumpF_Takeoff_M134_Y"
     TakeoffAnims(2)="JumpL_Takeoff_M134_Y"
     TakeoffAnims(3)="JumpR_Takeoff_M134_Y"
     LandAnims(0)="JumpF_Land_M134_Y"
     LandAnims(1)="JumpF_Land_M134_Y"
     LandAnims(2)="JumpL_Land_M134_Y"
     LandAnims(3)="JumpR_Land_M134_Y"
     DodgeAnims(0)="JumpF_Takeoff_M134_Y"
     DodgeAnims(1)="JumpF_Takeoff_M134_Y"
     DodgeAnims(2)="JumpL_Takeoff_M134_Y"
     DodgeAnims(3)="JumpR_Takeoff_M134_Y"
     AirStillAnim="JumpF_Mid_M134_Y"
     TakeoffStillAnim="JumpF_Takeoff_M134_Y"
	 //
	 WeaponAmbientScale=2.000000
	 Mesh=SkeletalMesh'm134DT_A.m134dt_3rd'
	 DrawScale=0.5500000
	 bHeavy=True
     bRapidFire=True
     bAltRapidFire=True
     SplashEffect=Class'ROEffects.BulletSplashEmitter'
     CullDistance=5000.000000
}
