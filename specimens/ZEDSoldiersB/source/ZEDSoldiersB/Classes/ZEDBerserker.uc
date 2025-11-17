Class ZEDBerserker extends ZEDSoldierBase;

function RangedAttack(Actor A)
{
	if( bShotAnim || VSizeSquared(A.Location-Location)>Square(CollisionRadius+A.CollisionRadius+120.f) )
		return;
	
	Acceleration = Normal(A.Location-Location)*GroundSpeed*1.5f;
	Controller.Target = A;
	Controller.MoveTarget = A;
	bShotAnim = true;
	SetAnimAction(FireAnim);
	
	SetTimer(0.9,false);
}

function Timer()
{
	ClawDamageTarget();
}

function bool ReadyToFire( Pawn Enemy )
{
	return false;
}

defaultproperties
{
	WAttachClass=Class'KFMod.AxeAttachment'
	AmmoPerClip=1
	FireAnim="AxeAttack"
	bFightOnSight=False
	bPickVisPointOnHunt=False
	bFreezeActionAnim=False
	MeleeAttackHitSound=SoundGroup'KF_AxeSnd.Axe_HitFlesh'
	IdleHeavyAnim="AxeIdle"
	IdleRifleAnim="AxeIdle"
	OriginalGroundSpeed=145.000000 //290.000000
	GroundSpeed=145.000000
	HealthMax=275.000000 //350.000000
	Health=275 //350
	HeadHealth=245.000000 //250.000000
	ScoringValue=25
	MenuName="Civil Berserker"
	IdleWeaponAnim="AxeIdle"
	IdleRestAnim="AxeIdle"
	Mesh=SkeletalMesh'KFSoldiers.Kara'
	Skins(0)=Texture'KFCharacters.KaraSkin'
	Skins(1)=Shader'KFCharacters.KaraHairaShadera'
}