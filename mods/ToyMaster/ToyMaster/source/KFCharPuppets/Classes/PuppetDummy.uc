class PuppetDummy extends ZombieGoreFast;

function bool FlipOver()
{
	Return False;
}

state RunningState
{
    // Don't override speed in this state
    function bool CanSpeedAdjust()
    {
        return false;
    }

	function BeginState()
	{
		GroundSpeed = OriginalGroundSpeed * 1.6;
		bRunning = true;
		if( Level.NetMode!=NM_DedicatedServer )
			PostNetReceive();

		NetUpdateTime = Level.TimeSeconds - 1;
	}

	function EndState()
	{
		GroundSpeed = GetOriginalGroundSpeed();
		bRunning = False;
		if( Level.NetMode!=NM_DedicatedServer )
			PostNetReceive();

		RunAttackTimeout=0;

		NetUpdateTime = Level.TimeSeconds - 1;
	}

	function RemoveHead()
	{
		GoToState('');
		Global.RemoveHead();
	}

    function RangedAttack(Actor A)
    {
        local float ChargeChance;

        // Decide what chance the gorefast has of charging during an attack
        if( Level.Game.GameDifficulty < 2.0 )
        {
            ChargeChance = 0.1;
        }
        else if( Level.Game.GameDifficulty < 4.0 )
        {
            ChargeChance = 0.2;
        }
        else if( Level.Game.GameDifficulty < 7.0 )
        {
            ChargeChance = 0.3;
        }
        else // Hardest difficulty
        {
            ChargeChance = 0.4;
        }

    	if ( bShotAnim || Physics == PHYS_Swimming)
    		return;
    	else if ( CanAttack(A) )
    	{
    		bShotAnim = true;

    		// Randomly do a moving attack so the player can't kite the zed
            if( FRand() < ChargeChance )
    		{
        		SetAnimAction('attack_1');
        		RunAttackTimeout = GetAnimDuration('attack_1', 1.0);
    		}
    		else
    		{
        		SetAnimAction('attack_1');
        		Controller.bPreparingMove = true;
        		Acceleration = vect(0,0,0);
                // Once we attack stop running
        		GoToState('');
    		}
    		return;
    	}
    }

    simulated function Tick(float DeltaTime)
    {
		// Keep moving toward the target until the timer runs out (anim finishes)
        if( RunAttackTimeout > 0 )
		{
            RunAttackTimeout -= DeltaTime;

            if( RunAttackTimeout <= 0 && !bZedUnderControl )
            {
                RunAttackTimeout = 0;
                GoToState('');
            }
		}

        // Keep the gorefast moving toward its target when attacking
    	if( Role == ROLE_Authority && bShotAnim && !bWaitForAnim )
    	{
    		if( LookTarget!=None )
    		{
    		    Acceleration = AccelRate * Normal(LookTarget.Location - Location);
    		}
        }

        global.Tick(DeltaTime);
    }


Begin:
    GoTo('CheckCharge');
CheckCharge:
    if( Controller!=None && Controller.Target!=None && VSize(Controller.Target.Location-Location)<700 )
    {
        Sleep(0.5+ FRand() * 0.5);
        //log("Still charging");
        GoTo('CheckCharge');
    }
    else
    {
        //log("Done charging");
        GoToState('');
    }
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
     MeleeDamage=6
     KFRagdollName="VentriloquistRagdoll"
     MeleeAttackHitSound=SoundGroup'KF_EnemiesFinalSnd_Xmas.GoreFast.Gorefast_HitPlayer'
     JumpSound=SoundGroup'KF_EnemiesFinalSnd_Xmas.GoreFast.Gorefast_Jump'
     ColOffset=(Z=30.000000)
     ColRadius=12.000000
     ColHeight=6.000000
     DetachedArmClass=Class'KFCharPuppets.SeveredArm_Ventrilliquist'
     DetachedLegClass=Class'KFCharPuppets.SeveredLeg_Ventrilliquist'
     DetachedHeadClass=Class'KFCharPuppets.SeveredHead_Ventrilliquist'
     PlayerCountHealthScale=0.250000
     PlayerNumHeadHealthScale=0.250000
     HitSound(0)=SoundGroup'KF_EnemiesFinalSnd_Xmas.GoreFast.Gorefast_Pain'
     DeathSound(0)=SoundGroup'KF_EnemiesFinalSnd_Xmas.GoreFast.Gorefast_Death'
     ChallengeSound(0)=SoundGroup'KF_EnemiesFinalSnd_Xmas.GoreFast.Gorefast_Challenge'
     ChallengeSound(1)=SoundGroup'KF_EnemiesFinalSnd_Xmas.GoreFast.Gorefast_Challenge'
     ChallengeSound(2)=SoundGroup'KF_EnemiesFinalSnd_Xmas.GoreFast.Gorefast_Challenge'
     ChallengeSound(3)=SoundGroup'KF_EnemiesFinalSnd_Xmas.GoreFast.Gorefast_Challenge'
     ScoringValue=10
     IdleHeavyAnim="Idle"
     IdleRifleAnim="Idle"
     WaterSpeed=100.000000
     HealthMax=130.000000
     Health=130
     MenuName="Ventriloquist Dummy"
     MovementAnims(0)="Walk_F"
     TurnLeftAnim="Idle"
     TurnRightAnim="Idle"
     WalkAnims(0)="Walk_F"
     WalkAnims(1)="Walk_B"
     WalkAnims(2)="Walk_L"
     WalkAnims(3)="Walk_R"
     DodgeAnims(0)="hit_reaction_F"
     DodgeAnims(1)="hit_reaction_B"
     DodgeAnims(2)="hit_reaction_L"
     DodgeAnims(3)="hit_reaction_R"
     IdleCrouchAnim="Idle"
     IdleWeaponAnim="Idle"
     IdleRestAnim="Idle"
     AmbientSound=Sound'KF_BaseGorefast_xmas.Gorefast_Idle'
     Mesh=SkeletalMesh'KF_Puppets.puppet_ventriloquist'
     DrawScale=1.000000
     PrePivot=(Z=12.000000)
     Skins(0)=Combiner'KF_Puppets_T.ventriloquist.ventriloquist_cmb'
     CollisionRadius=20.000000
     CollisionHeight=40.000000
}
