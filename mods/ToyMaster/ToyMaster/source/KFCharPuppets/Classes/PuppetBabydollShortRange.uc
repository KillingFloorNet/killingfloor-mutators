class PuppetBabydollShortRange extends ZombieBloat;

// For Puppets replaced any reference of ZombieBarf with BurnBaby animation
function DoorAttack(Actor A)
{
	if ( bShotAnim || Physics == PHYS_Swimming)
		return;
	else if ( A!=None )
	{
		bShotAnim = true;
		if( !bDecapitated && bDistanceAttackingDoor )
		{
			SetAnimAction('BurnBaby');
		}
		else
		{
            SetAnimAction('DoorBash');
            GotoState('DoorBashing');
		}
	}
}

// For Puppets replaced any reference of ZombieBarf with BurnBaby animation
function RangedAttack(Actor A)
{
	local int LastFireTime;
    local float ChargeChance;

	if ( bShotAnim )
		return;

	if ( Physics == PHYS_Swimming )
	{
		SetAnimAction('Claw');
		bShotAnim = true;
		LastFireTime = Level.TimeSeconds;
	}
	else if ( VSize(A.Location - Location) < MeleeRange + CollisionRadius + A.CollisionRadius )
	{
		bShotAnim = true;
		LastFireTime = Level.TimeSeconds;
		SetAnimAction('Claw');
		//PlaySound(sound'Claw2s', SLOT_Interact); KFTODO: Replace this
		Controller.bPreparingMove = true;
		Acceleration = vect(0,0,0);
	}
	else if ( (KFDoorMover(A) != none || VSize(A.Location-Location) <= 250) && !bDecapitated )
	{
		bShotAnim = true;

        // Decide what chance the bloat has of charging during a puke attack
        if( Level.Game.GameDifficulty < 2.0 )
        {
            ChargeChance = 0.2;
        }
        else if( Level.Game.GameDifficulty < 4.0 )
        {
            ChargeChance = 0.4;
        }
        else if( Level.Game.GameDifficulty < 7.0 )
        {
            ChargeChance = 0.6;
        }
        else // Hardest difficulty
        {
            ChargeChance = 0.8;
        }

		// Randomly do a moving attack so the player can't kite the zed
        if( FRand() < ChargeChance )
		{
    		SetAnimAction('ZombieBarfMoving');
    		RunAttackTimeout = GetAnimDuration('BurnBaby', 1.0);
    		bMovingPukeAttack=true;
		}
		else
		{
    		SetAnimAction('BurnBaby');
    		Controller.bPreparingMove = true;
    		Acceleration = vect(0,0,0);
		}


		// Randomly send out a message about Bloat Vomit burning(3% chance)
		if ( FRand() < 0.03 && KFHumanPawn(A) != none && PlayerController(KFHumanPawn(A).Controller) != none )
		{
			PlayerController(KFHumanPawn(A).Controller).Speech('AUTO', 7, "");
		}
	}
}

// Handle playing the anim action on the upper body only if we're attacking and moving
// for Puppets replaced any reference of ZombieBarf with BurnBaby animation
simulated function int AttackAndMoveDoAnimAction( name AnimName )
{
    if( AnimName=='ZombieBarfMoving' )
	{
		AnimBlendParams(1, 1.0, 0.0,, FireRootBone);
		PlayAnim('BurnBaby',, 0.1, 1);

		return 1;
	}

	return super.DoAnimAction( AnimName );
}

function SpawnTwoShots()
{
	local vector X,Y,Z, FireStart;
	local rotator FireRotation;

	if( Controller!=None && KFDoorMover(Controller.Target)!=None )
	{
		Controller.Target.TakeDamage(22,Self,Location,vect(64,0,0),Class'DamTypeFlamethrower');
		return;
	}

	GetAxes(Rotation,X,Y,Z);
	FireStart = Location+(vect(64,0,0) >> Rotation)*DrawScale;
	if ( !SavedFireProperties.bInitialized )
	{
		SavedFireProperties.AmmoClass = Class'SkaarjAmmo';
		SavedFireProperties.ProjectileClass = Class'FlameTendril';
		SavedFireProperties.WarnTargetPct = 1;
		SavedFireProperties.MaxRange = 500;
		SavedFireProperties.bTossed = False;
		SavedFireProperties.bTrySplash = False;
		SavedFireProperties.bLeadTarget = True;
		SavedFireProperties.bInstantHit = True;
		SavedFireProperties.bInitialized = True;
	}

    // Turn off extra collision before spawning vomit, otherwise spawn fails
    ToggleAuxCollision(false);
	FireRotation = Controller.AdjustAim(SavedFireProperties,FireStart,600);
	Spawn(Class'FlameTendril',,,FireStart,FireRotation);

//	FireStart-=(0.5*CollisionRadius*Y);
//	FireRotation.Yaw -= 1200;
//	spawn(Class'FlameTendril',,,FireStart, FireRotation);
//
//	FireStart+=(CollisionRadius*Y);
//	FireRotation.Yaw += 2400;
//	spawn(Class'FlameTendril',,,FireStart, FireRotation);
	// Turn extra collision back on
	ToggleAuxCollision(true);
}

simulated function Tick(float deltatime)
{
    local vector BileExplosionLoc;
    local FleshHitEmitter GibPuppetExplosion;

//    Super.tick(deltatime);
    Super(KFMonster).Tick(deltaTime) ;


    if( Role == ROLE_Authority && bMovingPukeAttack )
    {
		// Keep moving toward the target until the timer runs out (anim finishes)
        if( RunAttackTimeout > 0 )
		{
            RunAttackTimeout -= DeltaTime;

            if( RunAttackTimeout <= 0 )
            {
                RunAttackTimeout = 0;
                bMovingPukeAttack=false;
            }
		}

        // Keep the gorefast moving toward its target when attacking
    	if( bShotAnim && !bWaitForAnim )
    	{
    		if( LookTarget!=None )
    		{
    		    Acceleration = AccelRate * Normal(LookTarget.Location - Location);
    		}
        }
    }

    // Hack to force animation updates on the server for the bloat if he is relevant to someone
    // He has glitches when some of his animations don't play on the server. If we
    // find some other fix for the glitches take this out - Ramm
    if( Level.NetMode != NM_Client && Level.NetMode != NM_Standalone )
    {
        if( (Level.TimeSeconds-LastSeenOrRelevantTime) < 1.0  )
        {
            bForceSkelUpdate=true;
        }
        else
        {
            bForceSkelUpdate=false;
        }
    }

    if ( Level.NetMode!=NM_DedicatedServer && /*Gored>0*/Health <= 0 && !bPlayBileSplash &&
        HitDamageType != class'DamTypeBleedOut' )
    {
        if ( !class'GameInfo'.static.UseLowGore() )
        {
			BileExplosionLoc = self.Location;
	        BileExplosionLoc.z += (CollisionHeight - (CollisionHeight * 0.5));

	        GibPuppetExplosion = Spawn(class 'PuppetExplosion',self,, BileExplosionLoc );
	        bPlayBileSplash = true;
	    }
	    else
	    {
			BileExplosionLoc = self.Location;
	        BileExplosionLoc.z += (CollisionHeight - (CollisionHeight * 0.5));

	        GibPuppetExplosion = Spawn(class 'PuppetExplosion',self,, BileExplosionLoc );
	        bPlayBileSplash = true;
		}
    }
}

function BileBomb()
{
	BloatJet = spawn(class'PuppetFlameJet', self,,Location,Rotator(-PhysicsVolume.Gravity));
}

function PlayDyingAnimation(class<DamageType> DamageType, vector HitLoc)
{
//    local bool AttachSucess;

    super.PlayDyingAnimation(DamageType, HitLoc);

    // Don't blow up with bleed out
    if( bDecapitated && DamageType == class'DamTypeBleedOut' )
    {
        return;
    }

    if ( !class'GameInfo'.static.UseLowGore() )
    {
		HideBone(SpineBone2);
	}

    if(Role == ROLE_Authority)
    {
        BileBomb();
    }
}


state Dying
{
  function tick(float deltaTime)
  {
   if (BloatJet != none)
   {
    BloatJet.SetLocation(location);

    BloatJet.SetRotation(GetBoneRotation(FireRootBone));
   }
    super.tick(deltaTime);
  }
}

function bool FlipOver()
{
	Return False;
}

defaultproperties
{
     MeleeAnims(0)="Strike"
     MeleeAnims(1)="Strike"
     MeleeAnims(2)="Strike"
     MoanVoice=SoundGroup'KF_EnemiesFinalSnd.siren.Siren_Talk'
     MeleeDamage=10
     KFRagdollName="babydollRagdoll"
     MeleeAttackHitSound=SoundGroup'KF_EnemiesFinalSnd.Bloat.Bloat_HitPlayer'
     JumpSound=SoundGroup'KF_EnemiesFinalSnd.siren.Siren_Jump'
     Intelligence=BRAINS_Mammal
     ColOffset=(Z=36.000000)
     ColRadius=30.000000
     ColHeight=33.000000
     SeveredArmAttachScale=0.900000
     SeveredLegAttachScale=0.900000
     SeveredHeadAttachScale=0.900000
     PlayerCountHealthScale=0.100000
     OnlineHeadshotOffset=(X=0.000000,Z=0.000000)
     OnlineHeadshotScale=1.000000
     HeadHealth=175.000000
     PlayerNumHeadHealthScale=0.050000
     HitSound(0)=SoundGroup'KF_EnemiesFinalSnd.siren.Siren_Pain'
     DeathSound(0)=SoundGroup'KF_EnemiesFinalSnd.siren.Siren_Death'
     ChallengeSound(0)=SoundGroup'KF_EnemiesFinalSnd.siren.Siren_Challenge'
     ChallengeSound(1)=SoundGroup'KF_EnemiesFinalSnd.siren.Siren_Challenge'
     ChallengeSound(2)=SoundGroup'KF_EnemiesFinalSnd.siren.Siren_Challenge'
     ChallengeSound(3)=SoundGroup'KF_EnemiesFinalSnd.siren.Siren_Challenge'
     SoundGroupClass=Class'KFMod.KFFemaleZombieSounds'
     IdleHeavyAnim="Idle"
     IdleRifleAnim="Idle"
     GroundSpeed=120.000000
     WaterSpeed=120.000000
     HealthMax=175.000000
     Health=175
     HeadHeight=1.000000
     MenuName="Baby Face"
     MovementAnims(0)="Walk_F"
     MovementAnims(1)="Walk_B"
     MovementAnims(2)="Walk_L"
     MovementAnims(3)="Walk_R"
     WalkAnims(0)="Walk_F"
     WalkAnims(1)="Walk_B"
     WalkAnims(2)="Walk_L"
     WalkAnims(3)="Walk_R"
     IdleCrouchAnim="Idle"
     IdleWeaponAnim="Idle"
     IdleRestAnim="Idle"
     AmbientSound=Sound'KF_BaseSiren.Siren_IdleLoop'
     Mesh=SkeletalMesh'KF_Puppets.puppet_babydoll'
     DrawScale=1.250000
     PrePivot=(Z=10.000000)
     Skins(0)=Shader'KF_Puppets_T.babydoll.babydoll_shdr'
}
