//Super Babydoll, based upon Babydoll Uber from the Toymaster mod.
//Created by Cakedog, based upon original code from the Toymaster mod.

class cdPuppetSuperBabydoll extends ZombieCrawler;

#exec load obj file=KF_Puppets_T.utx

simulated function ZombieSpringAnim()
{
	SetAnimAction('Jump');
}

// Blend his attacks so he can hit you in mid air.
simulated function int DoAnimAction( name AnimName )
{
    if( AnimName=='Strike' || AnimName=='Strike' )
	{
		AnimBlendParams(1, 1.0, 0.0,, FireRootBone);
		PlayAnim(AnimName,, 0.0, 1);
		return 1;
	}
    //changed below aninmation from Hit_F
    if( AnimName=='Jump2' )
	{
		AnimBlendParams(1, 1.0, 0.0,, NeckBone);
		PlayAnim(AnimName,, 0.0, 1);
		return 1;
	}

	if( AnimName=='Jump' )
	{
        PlayAnim(AnimName,,0.02);
        return 0;
	}

	return Super.DoAnimAction(AnimName);
}

// The animation is full body and should set the bWaitForAnim flag
simulated function bool AnimNeedsWait(name TestAnim)
{
    if( TestAnim == 'Jump' || TestAnim == 'DoorBash' )
    {
        return true;
    }

    return false;
}

defaultproperties
{
     PounceSpeed=350.000000
     MeleeAirAnims(0)="Strike"
     MeleeAirAnims(1)="Strike"
     MeleeAnims(0)="Strike"
     MeleeAnims(1)="Strike"
     HitAnims(0)="HitReactionF"
     HitAnims(1)="HitReactionL"
     HitAnims(2)="HitReactionR"
     MoanVoice=SoundGroup'PuppetDoll_SND.Talk.BabyTalk'
     KFHitFront="HitReactionF"
     KFHitBack="HitReactionB"
     KFHitLeft="HitReactionL"
     KFHitRight="HitReactionR"
     bCannibal=False
     MeleeDamage=25
     KFRagdollName="babydollRagdoll"
     MeleeAttackHitSound=SoundGroup'PuppetDoll_SND.Talk.BabyTalk'
     JumpSound=SoundGroup'PuppetDoll_SND.Talk.BabyTalk'
     bUseExtendedCollision=True
     ColOffset=(Z=30.000000)
     ColRadius=12.000000
     ColHeight=8.000000
     SeveredArmAttachScale=0.500000
     SeveredLegAttachScale=0.500000
     DetachedArmClass=Class'KFCharPuppets.SeveredArm_Puppet'
     DetachedLegClass=Class'KFCharPuppets.SeveredLeg_Puppet'
     DetachedHeadClass=Class'KFCharPuppets.SeveredHead_Puppet'
     PlayerCountHealthScale=0.250000
     HeadHealth=880.000000
     PlayerNumHeadHealthScale=0.250000
     HitSound(0)=SoundGroup'PuppetDoll_SND.Pain.DollPain'
     DeathSound(0)=SoundGroup'PuppetDoll_SND.Death.BabyDie'
     ChallengeSound(0)=SoundGroup'PuppetDoll_SND.Talk.BabyTalk'
     ChallengeSound(1)=SoundGroup'PuppetDoll_SND.Talk.BabyTalk'
     ChallengeSound(2)=SoundGroup'PuppetDoll_SND.Talk.BabyTalk'
     ChallengeSound(3)=SoundGroup'PuppetDoll_SND.Talk.BabyTalk'
     ScoringValue=100
     SoundGroupClass=Class'KFMod.KFFemaleZombieSounds'
     IdleHeavyAnim="Idle"
     IdleRifleAnim="Idle"
     bCrawler=False
     GroundSpeed=110.000000
     WaterSpeed=100.000000
     HealthMax=1550.000000
     Health=1550
     HeadHeight=3.500000
     HeadScale=1.500000
     MenuName="Super Baby Face"
     MovementAnims(0)="Walk_F"
     MovementAnims(1)="Walk_B"
     MovementAnims(2)="Walk_L"
     MovementAnims(3)="Walk_R"
     WalkAnims(0)="Walk_F"
     WalkAnims(1)="Walk_B"
     WalkAnims(2)="Walk_L"
     WalkAnims(3)="Walk_R"
     AirAnims(0)="InAir"
     AirAnims(1)="InAir"
     AirAnims(2)="InAir"
     AirAnims(3)="InAir"
     TakeoffAnims(0)="Jump"
     TakeoffAnims(1)="Jump"
     TakeoffAnims(2)="Jump"
     TakeoffAnims(3)="Jump"
     AirStillAnim="Jump2"
     TakeoffStillAnim="Jump2"
     IdleCrouchAnim="Idle"
     IdleWeaponAnim="Idle"
     IdleRestAnim="Idle"
     bOrientOnSlope=False
     AmbientSound=SoundGroup'PuppetDoll_SND.Talk.BabyTalk'
     Mesh=SkeletalMesh'KF_Puppets.puppet_babydoll'
     DrawScale=2.550000
     PrePivot=(Z=56.000000)
     Skins(0)=Combiner'KF_Puppets_T.babydoll.babydoll_uber_cmb'
     CollisionRadius=48.000000
     CollisionHeight=64.000000
}
