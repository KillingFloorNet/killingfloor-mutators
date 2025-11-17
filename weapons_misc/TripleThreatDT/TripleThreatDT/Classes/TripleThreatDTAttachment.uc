class TripleThreatDTAttachment extends KFWeaponAttachment;

simulated function vector GetTracerStart()
{
	local Pawn p;

	p = Pawn(Owner);

	if ( (p != None) && p.IsFirstPerson() && p.Weapon != None )
		return p.Weapon.GetEffectStart();

	if( Instigator!=None && (Level.TimeSeconds-LastRenderTime)>2 )
		Return Instigator.Location;
	// 3rd person
	if ( mMuzFlash3rd != None )
		return mMuzFlash3rd.Location;
	else return Location;
}

simulated function DoFlashEmitter()
{
    if (mMuzFlash3rd == None)
    {
        mMuzFlash3rd = Spawn(mMuzFlashClass);
        AttachToBone(mMuzFlash3rd, 'tip');
    }
    if(mMuzFlash3rd != None)
        mMuzFlash3rd.SpawnParticle(1);
}
simulated event ThirdPersonEffects()
{
	local PlayerController PC;

	if ( (Level.NetMode == NM_DedicatedServer) || (Instigator == None) )
		return;

	if (FiringMode == 0)
	{
		if ( OldSpawnHitCount != SpawnHitCount )
		{
			OldSpawnHitCount = SpawnHitCount;
			GetHitInfo();
			PC = Level.GetLocalPlayerController();
			if ( ((Instigator != None) && (Instigator.Controller == PC)) || (VSize(PC.ViewTarget.Location - mHitLocation) < 4000) )
			{
				if( mHitActor!=None )
					Spawn(class'ROBulletHitEffect',,, mHitLocation, Rotator(-mHitNormal));
				CheckForSplash();
				SpawnTracer();
			}
		}
	}

	if( FiringMode==1 )
	{
		if ( FlashCount>0 )
		{
			if( KFPawn(Instigator)!=None )
			{
				if (FiringMode == 0)
				{
					KFPawn(Instigator).StartFiringX(false,bRapidFire);
				}
				else
				{
					KFPawn(Instigator).StartFiringX(true,bRapidFire);
				}
			}
		}
		else
		{
			GotoState('');
			if( KFPawn(Instigator)!=None )
				KFPawn(Instigator).StopFiring();
		}
	}
	else
	{
			if ( FlashCount>0 )
		{
			if( KFPawn(Instigator)!=None )
			{
				if (FiringMode == 0)
				{
					KFPawn(Instigator).StartFiringX(false,bRapidFire);
				}
				else
				{
					KFPawn(Instigator).StartFiringX(true,bRapidFire);
				}
			}

			if( bDoFiringEffects )
			{
				PC = Level.GetLocalPlayerController();

				if ( (Level.TimeSeconds - LastRenderTime > 0.2) && (Instigator.Controller != PC) )
					return;

				WeaponLight();

				DoFlashEmitter();

				if ( (mShellCaseEmitter == None) && (Level.DetailMode != DM_Low) && !Level.bDropDetail )
				{
					mShellCaseEmitter = Spawn(mShellCaseEmitterClass);
					if ( mShellCaseEmitter != None )
						AttachToBone(mShellCaseEmitter, ShellEjectBoneName);
				}
				if (mShellCaseEmitter != None)
					mShellCaseEmitter.mStartParticles++;
			}
		}
		else
		{
			GotoState('');
			if( KFPawn(Instigator)!=None )
				KFPawn(Instigator).StopFiring();
		}
	}
}

defaultproperties
{
     mMuzFlashClass=Class'ROEffects.MuzzleFlash3rdNadeL'
     MovementAnims(0)="JogF_M32_MGL"
     MovementAnims(1)="JogB_M32_MGL"
     MovementAnims(2)="JogL_M32_MGL"
     MovementAnims(3)="JogR_M32_MGL"
     TurnLeftAnim="TurnL_M32_MGL"
     TurnRightAnim="TurnR_M32_MGL"
     CrouchAnims(0)="CHWalkF_M32_MGL"
     CrouchAnims(1)="CHWalkB_M32_MGL"
     CrouchAnims(2)="CHWalkL_M32_MGL"
     CrouchAnims(3)="CHWalkR_M32_MGL"
     WalkAnims(0)="WalkF_M32_MGL"
     WalkAnims(1)="WalkB_M32_MGL"
     WalkAnims(2)="WalkL_M32_MGL"
     WalkAnims(3)="WalkR_M32_MGL"
     CrouchTurnRightAnim="CH_TurnR_M32_MGL"
     CrouchTurnLeftAnim="CH_TurnL_M32_MGL"
     IdleCrouchAnim="CHIdle_M32_MGL"
     IdleWeaponAnim="Idle_M32_MGL"
     IdleRestAnim="Idle_M32_MGL"
     IdleChatAnim="Idle_M32_MGL"
     IdleHeavyAnim="Idle_M32_MGL"
     IdleRifleAnim="Idle_M32_MGL"
     FireAnims(0)="Fire_M32_MGL"
     FireAnims(1)="Fire_M32_MGL"
     FireAnims(2)="Fire_M32_MGL"
     FireAnims(3)="Fire_M32_MGL"
     FireAltAnims(0)="FastAttack4_Machete"
     FireAltAnims(1)="FastAttack4_Machete"
     FireAltAnims(2)="FastAttack4_Machete"
     FireAltAnims(3)="FastAttack4_Machete"
     FireCrouchAnims(0)="CHFire_M32_MGL"
     FireCrouchAnims(1)="CHFire_M32_MGL"
     FireCrouchAnims(2)="CHFire_M32_MGL"
     FireCrouchAnims(3)="CHFire_M32_MGL"
     FireCrouchAltAnims(0)="CHFastAttack4_machete"
     FireCrouchAltAnims(1)="CHFastAttack4_machete"
     FireCrouchAltAnims(2)="CHFastAttack4_machete"
     FireCrouchAltAnims(3)="CHFastAttack4_machete"
     HitAnims(0)="HitF_M32_MGL"
     HitAnims(1)="HitB_M32_MGL"
     HitAnims(2)="HitL_M32_MGL"
     HitAnims(3)="HitR_M32_MGL"
     PostFireBlendStandAnim="Blend_M32_MGL"
     PostFireBlendCrouchAnim="CHBlend_M32_MGL"
     Mesh=SkeletalMesh'TripleThreatDT_A.TripleThreatDT_3rd'
	 DrawScale=0.35
}
