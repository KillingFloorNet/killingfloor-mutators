class PuppetDummyLongRange extends ZombieHusk;

function DoorAttack(Actor A)
{
	if ( bShotAnim || Physics == PHYS_Swimming)
		return;
	else if ( A!=None )
	{
		bShotAnim = true;
		if( !bDecapitated && bDistanceAttackingDoor )
		{
			SetAnimAction('KnifeThrow');
		}
		else
		{
            SetAnimAction('DoorBash');
            GotoState('DoorBashing');
		}
	}
}

function RangedAttack(Actor A)
{
	local int LastFireTime;

	if ( bShotAnim )
		return;

	if ( Physics == PHYS_Swimming )
	{
		SetAnimAction('KnifeThrow');
		bShotAnim = true;
		LastFireTime = Level.TimeSeconds;
	}
	else if ( VSize(A.Location - Location) < MeleeRange + CollisionRadius + A.CollisionRadius )
	{
		bShotAnim = true;
		LastFireTime = Level.TimeSeconds;
		SetAnimAction('KnifeThrow');
		//PlaySound(sound'Claw2s', SLOT_Interact); KFTODO: Replace this
		Controller.bPreparingMove = true;
		Acceleration = vect(0,0,0);
	}
	else if ( (KFDoorMover(A) != none ||
        (!Region.Zone.bDistanceFog && VSize(A.Location-Location) <= 65535) ||
        (Region.Zone.bDistanceFog && VSizeSquared(A.Location-Location) < (Square(Region.Zone.DistanceFogEnd) * 0.8)))  // Make him come out of the fog a bit
        && !bDecapitated )
	{
        bShotAnim = true;

		SetAnimAction('KnifeThrow');
		Controller.bPreparingMove = true;
		Acceleration = vect(0,0,0);

		NextFireProjectileTime = Level.TimeSeconds + ProjectileFireInterval + (FRand() * 2.0);
	}
}

function bool FlipOver()
{
	Return False;
}

function SpawnTwoShots()
{
	local vector X,Y,Z, FireStart;
	local rotator FireRotation;
	local KFMonsterController KFMonstControl;

	if( Controller!=None && KFDoorMover(Controller.Target)!=None )
	{
		Controller.Target.TakeDamage(22,Self,Location,vect(0,0,0),Class'DamTypeVomit');
		return;
	}

	GetAxes(Rotation,X,Y,Z);
	FireStart = GetBoneCoords('Knife_L').Origin;
	if ( !SavedFireProperties.bInitialized )
	{
		SavedFireProperties.AmmoClass = Class'SkaarjAmmo';
		SavedFireProperties.ProjectileClass = Class'PuppetKnife';
		SavedFireProperties.WarnTargetPct = 1;
		SavedFireProperties.MaxRange = 65535;
		SavedFireProperties.bTossed = False;
		SavedFireProperties.bTrySplash = true;
		SavedFireProperties.bLeadTarget = True;
		SavedFireProperties.bInstantHit = False;
		SavedFireProperties.bInitialized = True;
	}

    // Turn off extra collision before spawning vomit, otherwise spawn fails
    ToggleAuxCollision(false);

	FireRotation = Controller.AdjustAim(SavedFireProperties,FireStart,600);

	foreach DynamicActors(class'KFMonsterController', KFMonstControl)
	{
        if( KFMonstControl != Controller )
        {
            if( PointDistToLine(KFMonstControl.Pawn.Location, vector(FireRotation), FireStart) < 75 )
            {
                KFMonstControl.GetOutOfTheWayOfShot(vector(FireRotation),FireStart);
            }
        }
	}

    Spawn(Class'PuppetKnife',,,FireStart,FireRotation);

	// Turn extra collision back on
	ToggleAuxCollision(true);
}

defaultproperties
{
     MeleeAnims(0)="attack_1"
     MeleeAnims(1)="attack_1"
     MeleeAnims(2)="attack_1"
     HitAnims(0)="hit_reaction_F"
     HitAnims(1)="hit_reaction_L"
     HitAnims(2)="hit_reaction_R"
     MoanVoice=SoundGroup'KF_EnemiesFinalSnd_Xmas.GoreFast.Gorefast_Talk'
     KFHitFront="hit_reaction_F"
     KFHitBack="hit_reaction_B"
     KFHitLeft="hit_reaction_L"
     KFHitRight="hit_reaction_R"
     bCannibal=True
     MeleeDamage=12
     damageForce=5000
     KFRagdollName="VentriloquistRagdoll"
     MeleeAttackHitSound=SoundGroup'KF_EnemiesFinalSnd_Xmas.GoreFast.Gorefast_HitPlayer'
     JumpSound=SoundGroup'KF_EnemiesFinalSnd_Xmas.GoreFast.Gorefast_Jump'
     CrispUpThreshhold=8
     ColOffset=(Z=30.000000)
     ColRadius=12.000000
     ColHeight=6.000000
     ExtCollAttachBoneName="Collision_Attach"
     SeveredHeadAttachScale=1.000000
     DetachedArmClass=Class'KFCharPuppets.SeveredArm_VentrilliquistLongRange'
     DetachedLegClass=Class'KFCharPuppets.SeveredLeg_VentrilliquistLongRange'
     DetachedHeadClass=Class'KFCharPuppets.SeveredHead_Ventrilliquist'
     PlayerCountHealthScale=0.250000
     OnlineHeadshotOffset=(X=5.000000,Z=53.000000)
     OnlineHeadshotScale=1.500000
     HeadHealth=25.000000
     PlayerNumHeadHealthScale=0.250000
     MotionDetectorThreat=0.500000
     HitSound(0)=SoundGroup'KF_EnemiesFinalSnd_Xmas.GoreFast.Gorefast_Pain'
     DeathSound(0)=SoundGroup'KF_EnemiesFinalSnd_Xmas.GoreFast.Gorefast_Death'
     ChallengeSound(0)=SoundGroup'KF_EnemiesFinalSnd_Xmas.GoreFast.Gorefast_Challenge'
     ChallengeSound(1)=SoundGroup'KF_EnemiesFinalSnd_Xmas.GoreFast.Gorefast_Challenge'
     ChallengeSound(2)=SoundGroup'KF_EnemiesFinalSnd_Xmas.GoreFast.Gorefast_Challenge'
     ChallengeSound(3)=SoundGroup'KF_EnemiesFinalSnd_Xmas.GoreFast.Gorefast_Challenge'
     ScoringValue=12
     GroundSpeed=120.000000
     WaterSpeed=100.000000
     HealthMax=130.000000
     Health=130
     HeadHeight=2.500000
     MenuName="Knifethower Dummy"
     MovementAnims(0)="Walk_F"
     TurnLeftAnim="Idle"
     TurnRightAnim="Idle"
     WalkAnims(0)="Walk_F"
     WalkAnims(1)="Walk_B"
     WalkAnims(2)="Walk_L"
     WalkAnims(3)="Walk_R"
     AmbientSound=Sound'KF_BaseGorefast_xmas.Gorefast_Idle'
     Mesh=SkeletalMesh'KF_Puppets.puppet_ventriloquist'
     DrawScale=1.000000
     PrePivot=(Z=12.000000)
     Skins(0)=Combiner'KF_Puppets_T.ventriloquist.ventriloquist_green_cmb'
     CollisionRadius=20.000000
     CollisionHeight=40.000000
     Mass=350.000000
}
