class Beretta96FSDTAttachment extends KFWeaponAttachment;

var class<Emitter>      AltmMuzFlashClass;
var Emitter             AltmMuzFlash3rd;

var() name WFireAnim;
var() name WReloadAnim;
var() name WIdleAnim;
var() name WFireEmptyAnim;
var() name WReloadEmptyAnim;
var() name WIdleEmptyAnim;

//Flame
var bool bSilencerOn;
var int ClientMagAmmoRemaining;

replication
{
	reliable if(Role == ROLE_AUTHORITY)
		bSilencerOn,ClientMagAmmoRemaining;
}
//

simulated function Destroyed()
{
	if (AltmMuzFlash3rd != None)
		AltmMuzFlash3rd.Destroy();
	Super.Destroyed();
}

simulated function Vector GetTipLocation()
{
	local coords C;
	C = GetBoneCoords('LightBone');
	return C.Origin;
}

simulated function vector GetTracerStart()
{
	local Pawn p;

	p = Pawn(Owner);

	if(p != None && p.IsFirstPerson() && p.Weapon != None)
		return p.Weapon.GetEffectStart();

	if(Instigator!=None && Level.TimeSeconds-LastRenderTime>2)
		return Instigator.Location;
	// 3rd person
	if ( mMuzFlash3rd != None )
		return mMuzFlash3rd.Location;
		
	if ( AltmMuzFlash3rd != None )
		return AltmMuzFlash3rd.Location;
		
	else return Location;
}

simulated event ThirdPersonEffects()
{
	//Log("Attachment.ThirdPersonEffects.0"@ClientMagAmmoRemaining);
	if( FiringMode==1 )
		return;
	if( FiringMode==0)
	{
		if(ClientMagAmmoRemaining>0)//Flame
			PlayAnim(WFireAnim, 1.5, 0.0);
		else
			PlayAnim(WFireEmptyAnim, 1.5, 0.0);
	}
	Super.ThirdPersonEffects();
}

simulated function WeaponLight()
{
	//Log("Attachment.WeaponLight.0"@Instigator@Instigator.Weapon@bSilencerOn);
	if(bSilencerOn)//Flame
		return;
	Super.WeaponLight();
}

simulated function DoFlashEmitter()
{
	//Log("Attachment.DoFlashEmitter.0"@Instigator@Instigator.Weapon@bSilencerOn);
	if (!bSilencerOn)//Flame
	{
		if (mMuzFlash3rd == None)
		{
			mMuzFlash3rd = Spawn(mMuzFlashClass);
			AttachToBone(mMuzFlash3rd, 'tip');
		}
		if(mMuzFlash3rd != None)
			mMuzFlash3rd.SpawnParticle(1);
	}
	else
	{
		if(AltmMuzFlash3rd == None)
		{
			AltmMuzFlash3rd = Spawn(AltmMuzFlashClass);
			AttachToBone(AltmMuzFlash3rd, 'tip_S');
		}
		if(AltmMuzFlash3rd != None)
			AltmMuzFlash3rd.SpawnParticle(1);
	}
}
//Flame
simulated function Tick(float dt)
{
	////Log("Tick.0"@Role@Level.NetMode@bSilencerOn);
	if(Level.NetMode != NM_DedicatedServer)
	{
		////Log("Tick.0"@bSilencerOn);
		if(bSilencerOn)
			SetBoneScale(0, 1.0, 'supp');
		else
			SetBoneScale(0, 0.0, 'supp');
	}
	Super.Tick(dt);
}
//
defaultproperties
{
	WFireAnim="Fire"
	WReloadAnim="Reload"
	WIdleAnim="Idle" 
	WFireEmptyAnim="Fire_Last"
	WReloadEmptyAnim="Reload_Empty"
	WIdleEmptyAnim="Idle_Empty"
	AltmMuzFlashClass=Class'Beretta96FSDTMuzzleFlash3rdS'
	mMuzFlashClass=Class'ROEffects.MuzzleFlash3rdPistol'
	mTracerClass=none //Class'KFMod.KFNewTracer'
	mShellCaseEmitterClass=Class'KFMod.KFShellSpewer'
	ShellEjectBoneName="Shell_eject"
	MovementAnims(0)="JogF_Single9mm"
	MovementAnims(1)="JogB_Single9mm"
	MovementAnims(2)="JogL_Single9mm"
	MovementAnims(3)="JogR_Single9mm"
	TurnLeftAnim="TurnL_Single9mm"
	TurnRightAnim="TurnR_Single9mm"
	CrouchAnims(0)="CHwalkF_Single9mm"
	CrouchAnims(1)="CHwalkB_Single9mm"
	CrouchAnims(2)="CHwalkL_Single9mm"
	CrouchAnims(3)="CHwalkR_Single9mm"
	CrouchTurnRightAnim="CH_TurnR_Single9mm"
	CrouchTurnLeftAnim="CH_TurnL_Single9mm"
	IdleCrouchAnim="CHIdle_Single9mm"
	IdleWeaponAnim="Idle_Single9mm"
	IdleRestAnim="Idle_Single9mm"
	IdleChatAnim="Idle_Single9mm"
	IdleHeavyAnim="Idle_Single9mm"
	IdleRifleAnim="Idle_Single9mm"
	FireAnims(0)="Fire_Single9mm"
	FireAnims(1)="Fire_Single9mm"
	FireAnims(2)="Fire_Single9mm"
	FireAnims(3)="Fire_Single9mm"
	FireAltAnims(0)="Fire_Single9mm"
	FireAltAnims(1)="Fire_Single9mm"
	FireAltAnims(2)="Fire_Single9mm"
	FireAltAnims(3)="Fire_Single9mm"
	FireCrouchAnims(0)="CHFire_Single9mm"
	FireCrouchAnims(1)="CHFire_Single9mm"
	FireCrouchAnims(2)="CHFire_Single9mm"
	FireCrouchAnims(3)="CHFire_Single9mm"
	FireCrouchAltAnims(0)="CHFire_Single9mm"
	FireCrouchAltAnims(1)="CHFire_Single9mm"
	FireCrouchAltAnims(2)="CHFire_Single9mm"
	FireCrouchAltAnims(3)="CHFire_Single9mm"
	HitAnims(0)="HitF_Single9mm"
	HitAnims(1)="HitB_Single9mm"
	HitAnims(2)="HitL_Single9mm"
	HitAnims(3)="HitR_Single9mm"
	PostFireBlendStandAnim="Blend_Single9mm"
	PostFireBlendCrouchAnim="CHBlend_Single9mm"
	SplashEffect=Class'ROEffects.BulletSplashEmitter'
	LightType=LT_Pulse
	LightRadius=0.000000
	CullDistance=5000.000000
	Mesh=SkeletalMesh'Beretta96FS_DT_A.Beretta96FS_DT_3rd'
	DrawScale=1.5
	LODBias=2
}
