class StunNade extends Nade;

#exec OBJ LOAD FILE=KF_GrenadeSnd.uax
#exec OBJ LOAD FILE=Inf_WeaponsTwo.uax

var     int     TotalHeals;     // The total number of times this nade has healed (or hurt enemies)
var()   int     MaxHeals;       // The total number of times this nade will heal (or hurt enemies) until its done healing
var     float   NextHealTime;   // The next time that this nade will heal friendlies or hurt enemies
var()   float   HealInterval;   // How often to do healing

var()   sound   ExplosionSound; // The sound of the rocket exploding

var     bool    bNeedToPlayEffects; // Whether or not effects have been played yet

replication
{
    reliable if (Role==ROLE_Authority)
        bNeedToPlayEffects;
}

simulated function PostNetReceive()
{
    super.PostNetReceive();
    if( !bHasExploded && bNeedToPlayEffects )
    {
        bNeedToPlayEffects = false;
        Explode(Location, vect(0,0,1));
    }
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
	bHasExploded = True;
	BlowUp(HitLocation);

	PlaySound(ExplosionSound,,TransientSoundVolume);

	if( Role == ROLE_Authority )
	{
        bNeedToPlayEffects = true;
        AmbientSound=Sound'Inf_WeaponsTwo.smoke_loop';
	}

	if ( EffectIsRelevant(Location,false) )
	{
		Spawn(Class'StunNade.StunNadeEffect',,, HitLocation, rotator(vect(0,0,1)));
		Spawn(ExplosionDecal,self,,HitLocation, rotator(-HitNormal));
	}
}

function Timer()
{
    if( !bHidden )
    {
        if( !bHasExploded )
        {
            Explode(Location, vect(0,0,1));
        }
    }
    else if( bDisintegrated )
    {
        AmbientSound=none;
        Destroy();
    }
}

simulated function BlowUp(vector HitLocation)
{
	HealOrHurt(Damage,DamageRadius, MyDamageType, MomentumTransfer, HitLocation);
	if ( Role == ROLE_Authority )
		MakeNoise(1.0);
}

function HealOrHurt(float DamageAmount, float DamageRadius, class<DamageType> DamageType, float Momentum, vector HitLocation)
{
	local actor Victims;
	local float damageScale;
	local vector dir;
	local int NumKilled;
	local KFMonster KFMonsterVictim;
	local Pawn P;
	local KFPawn KFP;
	local array<Pawn> CheckedPawns;
	local int i;
	local bool bAlreadyChecked;

	if ( bHurtEntry )
		return;

    NextHealTime = Level.TimeSeconds + HealInterval;

	bHurtEntry = true;

	if( Fear != none )
	{
		Fear.StartleBots();
	}

	foreach CollidingActors (class 'Actor', Victims, DamageRadius, HitLocation)
	{
		// don't let blast damage affect fluid - VisibleCollisingActors doesn't really work for them - jag
		if( (Victims != self) && (Hurtwall != Victims) && (Victims.Role == ROLE_Authority) && !Victims.IsA('FluidSurfaceInfo')
		 && ExtendedZCollision(Victims)==None )
		{
			if( (Instigator==None || Instigator.Health<=0) && KFPawn(Victims)!=None )
				Continue;

			damageScale = 1.0;

			if ( Instigator == None || Instigator.Controller == None )
			{
				Victims.SetDelayedDamageInstigatorController( InstigatorController );
			}

			P = Pawn(Victims);

			if( P != none )
			{
		        for (i = 0; i < CheckedPawns.Length; i++)
				{
		        	if (CheckedPawns[i] == P)
					{
						bAlreadyChecked = true;
						break;
					}
				}

				if( bAlreadyChecked )
				{
					bAlreadyChecked = false;
					P = none;
					continue;
				}

                KFMonsterVictim = KFMonster(Victims);

    			if( KFMonsterVictim != none && KFMonsterVictim.Health <= 0 )
    			{
                    KFMonsterVictim = none;
    			}

                KFP = KFPawn(Victims);

                if( KFMonsterVictim != none )
                {
                    if(KFMonsterVictim.Health <= 0)
                    {
                        Destroy();
                    }

                    if(Role == ROLE_Authority)
                    {
						KFMonsterVictim.bStunned = LifeSpan >= 0.5;

						if(KFMonsterVictim.OriginalGroundSpeed > 50)
						{
							KFMonsterVictim.OriginalGroundSpeed = 50;
						}
						if(LifeSpan <= 0.10)
						{
							KFMonsterVictim.OriginalGroundSpeed = KFMonsterVictim.default.GroundSpeed;
						}
                    }
                    damageScale *= KFMonsterVictim.GetExposureTo(Location + 15 * -Normal(PhysicsVolume.Gravity));
                }
                else if( KFP != none )
                {
				    damageScale *= KFP.GetExposureTo(Location + 15 * -Normal(PhysicsVolume.Gravity));
                }

				CheckedPawns[CheckedPawns.Length] = P;

				if ( damageScale <= 0)
				{
					P = none;
					continue;
				}
				else
				{
					P = none;
				}
			}
			else
			{
                continue;
			}

            if( KFP == none )
            {
    			//log(Level.TimeSeconds@"Hurting "$Victims$" for "$(damageScale * DamageAmount)$" damage");

    			if( Pawn(Victims) != none && Pawn(Victims).Health > 0 )
    			{
                    Victims.TakeDamage(damageScale * DamageAmount,Instigator,Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius)
        			 * dir,(damageScale * Momentum * dir),DamageType);

        			if( Role == ROLE_Authority && KFMonsterVictim != none && KFMonsterVictim.Health <= 0 )
                    {
                        NumKilled++;
                    }
			    }
			KFP = none;
            }
	    }  
	bHurtEntry = false;
    }
}

function TakeDamage( int Damage, Pawn InstigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> damageType, optional int HitIndex)
{
}

simulated function HitWall( vector HitNormal, actor Wall )
{
    local Vector VNorm;
	local PlayerController PC;

	if ( (Pawn(Wall) != None) || (GameObjective(Wall) != None) )
	{
		Explode(Location, HitNormal);
		return;
	}

    if (!bTimerSet)
    {
        SetTimer(ExplodeTimer, false);
        bTimerSet = true;
    }

    // Reflect off Wall w/damping
    VNorm = (Velocity dot HitNormal) * HitNormal;
    Velocity = -VNorm * DampenFactor + (Velocity - VNorm) * DampenFactorParallel;

    RandSpin(100000);
    DesiredRotation.Roll = 0;
    RotationRate.Roll = 0;
    Speed = VSize(Velocity);

    if ( Speed < 20 )
    {
        bBounce = False;
        PrePivot.Z = -1.5;
		SetPhysics(PHYS_None);
        Timer();
        SetTimer(0.0,False);
		DesiredRotation = Rotation;
		DesiredRotation.Roll = 0;
		DesiredRotation.Pitch = 0;
		SetRotation(DesiredRotation);

		if( Fear == none )
		{
		    //(jc) Changed to use MedicNade-specific grenade that's overridden to not make the ringmaster fear it
		    Fear = Spawn(class'AvoidMarker_MedicNade');
    		Fear.SetCollisionSize(DamageRadius,DamageRadius);
    		Fear.StartleBots();
		}

        if ( Trail != None )
        Trail.mRegen = false; // stop the emitter from regenerating
    }
    else
    {
		if ( (Level.NetMode != NM_DedicatedServer) && (Speed > 50) )
		PlaySound(ImpactSound, SLOT_Misc );
		else
		{
			bFixedRotationDir = false;
			bRotateToDesired = true;
			DesiredRotation.Pitch = 0;
			RotationRate.Pitch = 50000;
		}
        if ( !Level.bDropDetail && (Level.DetailMode != DM_Low) && (Level.TimeSeconds - LastSparkTime > 0.5) && EffectIsRelevant(Location,false) )
        {
			PC = Level.GetLocalPlayerController();
			if ( (PC.ViewTarget != None) && VSize(PC.ViewTarget.Location - Location) < 6000 )
				Spawn(HitEffectClass,,, Location, Rotator(HitNormal));
            LastSparkTime = Level.TimeSeconds;
        }
    }
}

function Tick( float DeltaTime )
{
    if( Role < ROLE_Authority )
    {
        return;
    }

    if( TotalHeals < MaxHeals && NextHealTime > 0 &&  NextHealTime < Level.TimeSeconds )
    {
        TotalHeals += 1;

        HealOrHurt(Damage,DamageRadius, MyDamageType, MomentumTransfer, Location);

        if( TotalHeals >= MaxHeals )
        {
            AmbientSound=none;
        }
    }
}

defaultproperties
{
     MaxHeals=10
     HealInterval=1.000000
     ExplosionSound=SoundGroup'KF_GrenadeSnd.NadeBase.MedicNade_Explode'
     Damage=50.000000
     DamageRadius=200.000000
     MyDamageType=Class'StunNade.DamTypeStunNade'
     ExplosionDecal=Class'StunNade.StunNadeDecal'
     StaticMesh=StaticMesh'KF_pickups5_Trip.nades.MedicNade_Pickup'
     DrawScale=1.000000
     SoundVolume=150
     SoundRadius=100.000000
     TransientSoundVolume=2.000000
     TransientSoundRadius=200.000000
}