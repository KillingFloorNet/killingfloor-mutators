class Gremlin extends Lineage2Monster;


function RangedAttack(Actor A)
{
	local float Dist;

	if ( bShotAnim )
	{
		return;
	}

	Dist = VSize(A.Location - Location);
	if ( Dist > MeleeRange + CollisionRadius + A.CollisionRadius )
	{
		return;
	}

	bShotAnim = true;

	PlaySound(AttackSound);	
	SetAnimAction('Attack');
	MeleeDamageTarget(MeleeDamage, vect(0,0,0));
	Controller.bPreparingMove = true;
	Acceleration = vect(0,0,0);
}

	simulated function PlayDying(class<DamageType> DamageType, vector HitLoc)
	{
		Super.PlayDying(DamageType, Hitloc);

		LifeSpan = 30;
	}
	
simulated function PlayDirectionalDeath(Vector HitLoc)
{	
		PlayAnim('Death',, 0.1);
}

simulated function PlayDirectionalHit(Vector HitLoc)
{
	local float Decision;

	Decision = fRand();

	if(Decision < 0.25)
	{
		PlayAnim('Run',, 0.1);
	}
	else if ( Decision > 0.25 && Decision < 0.50)
	{
		PlayAnim('Run',, 0.1);
	}
	else if ( Decision > 0.50 && Decision < 0.75)
	{
		PlayAnim('Run',, 0.1);
	}
	else
	{
		PlayAnim('Run',, 0.1);
	}
}

defaultproperties
{
     AttackSound=Sound'Lineage2MonstersPack1v1.gremlin_atk'
     MeleeDamage=15
     DeathAnim(0)="Death"
     DeathAnim(1)="Death"
     DeathAnim(2)="Death"
     DeathAnim(3)="Death"
     HitSound(0)=Sound'Lineage2MonstersPack1v1.gremlin_dmg_3'
     HitSound(1)=Sound'Lineage2MonstersPack1v1.gremlin_dmg_3'
     HitSound(2)=Sound'Lineage2MonstersPack1v1.gremlin_dmg_3'
     HitSound(3)=Sound'Lineage2MonstersPack1v1.gremlin_dmg_3'
     DeathSound(0)=Sound'Lineage2MonstersPack1v1.gremlin_death'
     DeathSound(1)=Sound'Lineage2MonstersPack1v1.gremlin_death'
     DeathSound(2)=Sound'Lineage2MonstersPack1v1.gremlin_death'
     DeathSound(3)=Sound'Lineage2MonstersPack1v1.gremlin_death'
     ChallengeSound(0)=Sound'Lineage2MonstersPack1v1.gremlin_dmg_3'
     ChallengeSound(1)=Sound'Lineage2MonstersPack1v1.gremlin_dmg_3'
     ChallengeSound(2)=Sound'Lineage2MonstersPack1v1.gremlin_dmg_3'
     ChallengeSound(3)=Sound'Lineage2MonstersPack1v1.gremlin_dmg_3'
     ScoringValue=15
     WallDodgeAnims(0)="Run"
     WallDodgeAnims(1)="Run"
     WallDodgeAnims(2)="Run"
     WallDodgeAnims(3)="Run"
     bCanWalkOffLedges=True
     GroundSpeed=80.000000
     JumpZ=120.000000
     Health=250
     AmbientSoundScaling=8.000000
     MenuName="Gremlin"
     MovementAnims(0)="Run"
     MovementAnims(1)="Run"
     MovementAnims(2)="Run"
     MovementAnims(3)="Run"
     TurnLeftAnim="Run"
     TurnRightAnim="Run"
     SwimAnims(0)="Run"
     SwimAnims(1)="Run"
     SwimAnims(2)="Run"
     SwimAnims(3)="Run"
     WalkAnims(0)="Run"
     WalkAnims(1)="Run"
     WalkAnims(2)="Run"
     WalkAnims(3)="Run"
     AirAnims(0)="Run"
     AirAnims(1)="Run"
     AirAnims(2)="Run"
     LandAnims(0)="Run"
     LandAnims(1)="Run"
     LandAnims(3)="Run"
     AirStillAnim="Run"
     TakeoffStillAnim="Run"
     IdleCrouchAnim="Run"
     IdleRestAnim="Run"
     Mesh=SkeletalMesh'Lineage2MonstersPack1v1.Gremlin'
     DrawScale=2.000000
     Skins(0)=Texture'Lineage2MonstersPack1v1.Textures.gremlin_t00'
     SoundVolume=200
     CollisionRadius=30.000000
     CollisionHeight=30.000000
     Mass=400.000000
}
