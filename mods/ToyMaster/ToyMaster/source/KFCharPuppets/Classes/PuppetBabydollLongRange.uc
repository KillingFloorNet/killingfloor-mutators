class PuppetBabydollLongRange extends ZombieHusk;

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

function RangedAttack(Actor A)
{
	local int LastFireTime;

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
	else if ( (KFDoorMover(A) != none ||
        (!Region.Zone.bDistanceFog && VSize(A.Location-Location) <= 65535) ||
        (Region.Zone.bDistanceFog && VSizeSquared(A.Location-Location) < (Square(Region.Zone.DistanceFogEnd) * 0.8)))  // Make him come out of the fog a bit
        && !bDecapitated )
	{
        bShotAnim = true;

		SetAnimAction('BurnBaby');
		Controller.bPreparingMove = true;
		Acceleration = vect(0,0,0);

		NextFireProjectileTime = Level.TimeSeconds + ProjectileFireInterval + (FRand() * 2.0);
	}
}

function bool FlipOver()
{
	Return False;
}

defaultproperties
{
     MoanVoice=SoundGroup'KF_EnemiesFinalSnd.siren.Siren_Talk'
     MeleeDamage=10
     KFRagdollName="babydollRagdoll"
     MeleeAttackHitSound=SoundGroup'KF_EnemiesFinalSnd.Bloat.Bloat_HitPlayer'
     JumpSound=SoundGroup'KF_EnemiesFinalSnd.siren.Siren_Jump'
     PuntAnim="BloatPunt"
     OnlineHeadshotOffset=(X=0.000000,Z=0.000000)
     HeadHealth=100.000000
     HitSound(0)=SoundGroup'KF_EnemiesFinalSnd.siren.Siren_Pain'
     DeathSound(0)=SoundGroup'KF_EnemiesFinalSnd.siren.Siren_Death'
     ChallengeSound(0)=SoundGroup'KF_EnemiesFinalSnd.siren.Siren_Challenge'
     ChallengeSound(1)=SoundGroup'KF_EnemiesFinalSnd.siren.Siren_Challenge'
     ChallengeSound(2)=SoundGroup'KF_EnemiesFinalSnd.siren.Siren_Challenge'
     ChallengeSound(3)=SoundGroup'KF_EnemiesFinalSnd.siren.Siren_Challenge'
     SoundGroupClass=Class'KFMod.KFFemaleZombieSounds'
     GroundSpeed=120.000000
     WaterSpeed=120.000000
     HealthMax=175.000000
     Health=175
     MenuName="Baby Face"
     MovementAnims(0)="Walk_F"
     MovementAnims(1)="Walk_B"
     MovementAnims(2)="Walk_L"
     MovementAnims(3)="Walk_R"
     WalkAnims(0)="Walk_F"
     WalkAnims(1)="Walk_B"
     WalkAnims(2)="Walk_L"
     WalkAnims(3)="Walk_R"
     AmbientSound=Sound'KF_BaseSiren.Siren_IdleLoop'
     Mesh=SkeletalMesh'KF_Puppets.puppet_babydoll'
     DrawScale=1.250000
     PrePivot=(Z=10.000000)
     Skins(0)=Shader'KF_Puppets_T.babydoll.babydoll_shdr'
}
