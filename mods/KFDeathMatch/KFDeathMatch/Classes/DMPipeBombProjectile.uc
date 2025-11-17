//=============================================================================
// PipeBombProjectile
//=============================================================================
class DMPipeBombProjectile extends PipeBombProjectile;

var byte PlacementTeam;
var Controller ControllerOwner;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	if( Level.NetMode!=NM_Client && Instigator!=None )
	{
		PlacementTeam = Instigator.GetTeamNum();
		ControllerOwner = Instigator.Controller;
	}
}
function Timer()
{
	local Pawn CheckPawn;
	local bool bFriendOn;

	if( !bHidden && !bTriggered )
	{
		if( ArmingCountDown >= 0 )
		{
			ArmingCountDown -= 0.1;
			if( ArmingCountDown <= 0 )
				SetTimer(1.0,True);
		}
    		else
    		{
			// Check for enemies
			if( !bEnemyDetected )
			{
				bAlwaysRelevant=false;
				PlaySound(BeepSound,,0.5,,50.0);

				if( Instigator==None ) // Set off if owner dies.
				{
					bEnemyDetected = true;
					SetTimer(0.15,True);
					return;
				}
				foreach VisibleCollidingActors( class 'Pawn', CheckPawn, DetectionRadius, Location )
				{
					if( CheckPawn!=Instigator && (!Level.Game.bTeamGame || CheckPawn.GetTeamNum()!=PlacementTeam) )
					{
						bEnemyDetected=true;
						SetTimer(0.15,True);
						break;
					}
					else bFriendOn = true;
				}
				if( !bEnemyDetected )
				{
					if( bFriendOn )
						SetTimer(0.5,True);
					else SetTimer(1.f,True);
				}
			}
			else // Play some fast beeps and blow up
			{
				bAlwaysRelevant=true;
				Countdown--;

				if( CountDown > 0 )
					PlaySound(BeepSound,SLOT_Misc,2.0,,150.0);
				else Explode(Location, vector(Rotation));
			}
		}
	}
	else Destroy();
}

/* HurtRadius()
 Hurt locally authoritative actors within the radius.
*/
simulated function HurtRadius( float DamageAmount, float DamageRadius, class<DamageType> DamageType, float Momentum, vector HitLocation )
{
	local actor Victims;
	local float damageScale, dist;
	local vector dir;
	local KFMonster KFMonsterVictim;
	local Pawn P;
	local KFPawn KFP;

	if ( bHurtEntry )
		return;

	bHurtEntry = true;

	if( Instigator==None && ControllerOwner!=None )
		Instigator = ControllerOwner.Pawn;

	foreach CollidingActors (class 'Actor', Victims, DamageRadius, HitLocation)
	{
		// don't let blast damage affect fluid - VisibleCollisingActors doesn't really work for them - jag
		if( (Victims != self) && (Hurtwall != Victims) && (Victims.Role == ROLE_Authority) && !Victims.IsA('FluidSurfaceInfo')
		 && ExtendedZCollision(Victims)==None )
		{
			if( Victims!=Instigator && Level.Game!=None && Level.Game.bTeamGame && Pawn(Victims)!=None && Pawn(Victims).GetTeamNum()==PlacementTeam )
				continue;

			dir = Victims.Location - HitLocation;
			dist = FMax(1,VSize(dir));
			dir = dir/dist;
			damageScale = 1 - FMax(0,(dist - Victims.CollisionRadius)/DamageRadius);

			if ( Instigator == None || Instigator.Controller == None )
				Victims.SetDelayedDamageInstigatorController( InstigatorController );

			P = Pawn(Victims);

			if( P != none )
			{
				KFMonsterVictim = KFMonster(Victims);

				if( KFMonsterVictim != none && KFMonsterVictim.Health <= 0 )
					KFMonsterVictim = none;
				KFP = KFPawn(Victims);
				if( KFMonsterVictim != none )
					damageScale *= KFMonsterVictim.GetExposureTo(Location + 15 * -Normal(PhysicsVolume.Gravity));
				else if( KFP != none )
					damageScale *= KFP.GetExposureTo(Location + 15 * -Normal(PhysicsVolume.Gravity));

				if ( damageScale <= 0)
				{
					P = none;
					continue;
				}
				else
				{
					//Victims = P;
					P = none;
				}
			}

			Victims.TakeDamage(damageScale * DamageAmount,Instigator,Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius)
				 * dir,(damageScale * Momentum * dir),DamageType);

			if (Vehicle(Victims) != None && Vehicle(Victims).Health > 0)
				Vehicle(Victims).DriverRadiusDamage(DamageAmount, DamageRadius, InstigatorController, DamageType, Momentum, HitLocation);
		}
	}
	bHurtEntry = false;
}

function TakeDamage( int Damage, Pawn InstigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> damageType, optional int HitIndex)
{
	if( damageType==class'DamTypePipeBomb' || (Damage < 20) || bTriggered || (Level.Game.bTeamGame && (InstigatedBy==None || InstigatedBy.GetTeamNum()==PlacementTeam)) )
		return;
	Explode(HitLocation, vect(0,0,1));
}

defaultproperties
{
     Damage=500.000000
}
