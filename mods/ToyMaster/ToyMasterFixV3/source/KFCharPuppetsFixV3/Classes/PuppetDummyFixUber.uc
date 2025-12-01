//================
//Code fixes and balancing by Skell*.
//Original content is by Alex Quick and David Hensley.
//================
//Ventriloquist Puppet (Uber)
//================
class PuppetDummyFixUber extends PuppetDummyUber;

#exec obj load file="KFPuppetsFixV3_T.utx"
#exec obj load file="KFPuppetsFixV3_A.ukx"

//Let's make the Uber a little... more uber?
simulated function PostBeginPlay()
{
    //ZED Gun difficulty scaling
    if (Level.Game != none && !bDiffAdjusted)
    {
        if( Level.Game.GameDifficulty < 2.0 )
        {
            ZapThreshold = default.ZapThreshold * 1.0;
        }
        else if( Level.Game.GameDifficulty < 4.0 )
        {
            ZapThreshold = default.ZapThreshold * 1.25;
        }
        else if( Level.Game.GameDifficulty < 5.0 )
        {
            ZapThreshold = default.ZapThreshold * 1.50;
        }
        else if( Level.Game.GameDifficulty < 7.0 )
        {
            ZapThreshold = default.ZapThreshold * 1.75;
        }
        else
        {
            ZapThreshold = default.ZapThreshold * 2.0;
        }
    }

    super.PostBeginPlay();
}

//Overwritten to change HitF as that's not an animation for puppet_ventriloquist.
function RemoveHead()
{
    local int i;

    Intelligence = BRAINS_Retarded;

    bDecapitated  = true;
    DECAP = true;
    DecapTime = Level.TimeSeconds;

    Velocity = vect(0,0,0);
    SetAnimAction('Hit_reaction_F'); //Changed from HitF
    SetGroundSpeed(GroundSpeed *= 0.80);
    AirSpeed *= 0.8;
    WaterSpeed *= 0.8;

    AmbientSound = MiscSound;

    if ( Controller != none )
    {
        MonsterController(Controller).Accuracy = -5;
    }

    if( KFPawn(LastDamagedBy)!=None )
    {
        TakeDamage( LastDamageAmount + 0.25 * HealthMax , LastDamagedBy, LastHitLocation, LastMomentum, LastDamagedByType);

        if ( BurnDown > 0 )
        {
            KFSteamStatsAndAchievements(KFPawn(LastDamagedBy).PlayerReplicationInfo.SteamStatsAndAchievements).AddBurningDecapKill(class'KFGameType'.static.GetCurrentMapName(Level));
        }
    }

    if( Health > 0 )
    {
        BleedOutTime = Level.TimeSeconds +  BleedOutDuration;
    }

    if (MeleeAnims[2] == 'Claw3')
        MeleeAnims[2] = 'Claw2';
    if (MeleeAnims[1] == 'Claw3')
        MeleeAnims[1] = 'Claw1';

    for( i = 0; i < 4; i++ )
    {
        if( HeadlessWalkAnims[i] != '' && HasAnim(HeadlessWalkAnims[i]) )
        {
            MovementAnims[i] = HeadlessWalkAnims[i];
            WalkAnims[i]     = HeadlessWalkAnims[i];
        }
    }

    PlaySound(DecapitationSound, SLOT_Misc,1.30,true,525);
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
        RemoveHead();
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
        GoTo('CheckCharge');
    }
    else
    {
        GoToState('');
    }
}

defaultproperties
{
     ZapThreshold=1.500000
     ColOffset=(Z=58.000000)
     ColRadius=32.000000
     ColHeight=48.000000
     LeftShoulderBone="CHR_LCollarbone"
     RightShoulderBone="CHR_RCollarbone"
     LeftThighBone="CHR_LThigh"
     RightThighBone="CHR_RThigh"
     LeftFArmBone="CHR_LForearm"
     RightFArmBone="CHR_RForearm"
     LeftFootBone="CHR_LFoot"
     RightFootBone="CHR_RFoot"
     LeftHandBone="CHR_LPalm"
     RightHandBone="CHR_RPalm"
     OnlineHeadshotOffset=(Z=86.000000)
     OnlineHeadshotScale=1.400000
     HeadHealth=800.000000
     MotionDetectorThreat=5.000000
     HealthMax=1600.000000
     Health=1600
     MovementAnims(0)="WalkF"
     MovementAnims(1)="WalkB"
     MovementAnims(2)="WalkL"
     MovementAnims(3)="WalkR"
     SwimAnims(0)="WalkF"
     SwimAnims(1)="WalkB"
     SwimAnims(2)="WalkL"
     SwimAnims(3)="WalkR"
     WalkAnims(0)="WalkF"
     WalkAnims(1)="WalkB"
     WalkAnims(2)="WalkL"
     WalkAnims(3)="WalkR"
     Mesh=SkeletalMesh'KFPuppetsFixV3_A.puppet_ventriloquist_fix'
     CollisionRadius=22.000000
     CollisionHeight=58.000000
}
