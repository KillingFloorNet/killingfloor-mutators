class ZombieFirePound extends ZombieFleshPound;

var float NextMinigunTime;
var byte MGFireCounter;
var vector TraceHitPos;
var Emitter mTracer,mMuzzleFlash;
var bool bHadAdjRot;
var     float   NextFireProjectileTime; 
var()   float   ProjectileFireInterval; 
var()   float   BurnDamageScale;    


simulated function PostBeginPlay()
{
	// Difficulty Scaling
	if (Level.Game != none && !bDiffAdjusted)
	{
        if( Level.Game.GameDifficulty < 2.0 )
        {
            ProjectileFireInterval = default.ProjectileFireInterval * 1.25;
            BurnDamageScale = default.BurnDamageScale * 2.0;
        }
        else if( Level.Game.GameDifficulty < 4.0 )
        {
            ProjectileFireInterval = default.ProjectileFireInterval * 1.0;
            BurnDamageScale = default.BurnDamageScale * 1.0;
        }
        else if( Level.Game.GameDifficulty < 7.0 )
        {
            ProjectileFireInterval = default.ProjectileFireInterval * 0.75;
            BurnDamageScale = default.BurnDamageScale * 0.75;
        }
        else // Hardest difficulty
        {
            ProjectileFireInterval = default.ProjectileFireInterval * 0.60;
            BurnDamageScale = default.BurnDamageScale * 0.5;
        }
	}

	super.PostBeginPlay();
}


replication
{
	reliable if( Role==ROLE_Authority )
		TraceHitPos;
}

function TakeDamage( int Damage, Pawn InstigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> damageType, optional int HitIndex)
{
	// Reduced damage from fire
	if (DamageType == class 'DamTypeBurned' || DamageType == class 'DamTypeFlamethrower')
	{
		Damage *= BurnDamageScale;
	}

	Super.TakeDamage(Damage,instigatedBy,hitlocation,momentum,damageType,HitIndex);
}


function RangedAttack(Actor A)
{
	if ( bShotAnim )
		return;
	else if ( CanAttack(A) )
	{
		bShotAnim = true;
		DoAnimAction('TurnLeft');
		Controller.bPreparingMove = true;
		Acceleration = vect(0,0,0);
		MGFireCounter = Rand(4.000000);
		SpawnTwoShots();
		GoToState('Minigunning');
	}
	else if( VSize(A.Location - Location)<=1600 && NextMinigunTime<Level.TimeSeconds && !bDecapitated )
	{
		if( FRand()<0.25 )
		{
			NextMinigunTime = Level.TimeSeconds+FRand()*10;
			Return;
		}
		NextMinigunTime = Level.TimeSeconds+10+FRand()*60;
		bShotAnim = true;
		DoAnimAction('TurnLeft');
		Acceleration = vect(0,0,0);
		MGFireCounter = Rand(4.000000);
		SpawnTwoShots();
		GoToState('Minigunning');
	}
}
simulated function AnimEnd( int Channel )
{
	if( Channel==1 && Level.NetMode!=NM_DedicatedServer && bHadAdjRot )
	{
		bHadAdjRot = False;
		SetBoneDirection(LeftFArmBone, Rotation,, 0, 0);
	}
	if( Channel==1 && Level.NetMode!=NM_Client )
		bShotAnim = false;
	Super.AnimEnd(Channel);
}
simulated function int DoAnimAction( name AnimName )
{
	if( AnimName=='TurnLeft' )
	{
		AnimBlendParams(1, 1.0, 0.0,, SpineBone1);
		PlayAnim(AnimName,10.f, 0.1, 1);
		Return 1;
	}
	Return Super.DoAnimAction(AnimName);
}
State Minigunning
{
Ignores StartCharging,PlayTakeHit;

	function RangedAttack(Actor A)
	{
		Controller.Target = A;
		Controller.Focus = A;
	}
	function EndState()
	{
		TraceHitPos = vect(0,0,0);
		GroundSpeed = Default.GroundSpeed;
	}
	function BeginState()
	{
		GroundSpeed = 90;
	}
	function AnimEnd( int Channel )
	{
		if( Channel!=1 )
			Return;
		MGFireCounter++;
		if( Controller.Enemy!=None && Controller.Target==Controller.Enemy )
		{
			if( Controller.LineOfSightTo(Controller.Enemy) )
			{
				Controller.Focus = Controller.Enemy;
				Controller.FocalPoint = Controller.Enemy.Location;
			}
			else
			{
				Controller.Focus = None;
				Acceleration = vect(0,0,0);
				if( !Controller.IsInState('WaitForAnim') )
					Controller.GoToState('WaitForAnim');
			}
			Controller.Target = Controller.Enemy;
		}
		else
		{
			Controller.Focus = Controller.Target;
			Acceleration = vect(0,0,0);
			if( !Controller.IsInState('WaitForAnim') )
				Controller.GoToState('WaitForAnim');
		}
		SpawnTwoShots();
		bShotAnim = true;
		DoAnimAction('TurnLeft');
		bWaitForAnim = true;
		if( MGFireCounter>=4 || Controller.Target==None )
			GoToState('');
	}
Begin:
	While( True )
	{
		Acceleration = vect(0,0,0);
                Sleep(0.15);
	}
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
	FireStart = GetBoneCoords('CHR_L_Blade3').Origin;
        DoAnimAction('TurnLeft');
	if ( !SavedFireProperties.bInitialized )
	{
		SavedFireProperties.AmmoClass = Class'SkaarjAmmo';
                SavedFireProperties.ProjectileClass = Class'HuskFireProjectile';
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

    Spawn(Class'HuskFireProjectile',,,FireStart,FireRotation);
	// Turn extra collision back on
	ToggleAuxCollision(true);
}

simulated function float PointDistToLine(vector Point, vector Line, vector Origin, optional out vector OutClosestPoint)
{
	local vector SafeDir;

    SafeDir = Normal(Line);
	OutClosestPoint = Origin + (SafeDir * ((Point-Origin) dot SafeDir));
	return VSize(OutClosestPoint-Point);
}

simulated function DeviceGoRed();
simulated function DeviceGoNormal();

defaultproperties
{
     NextFireProjectileTime=5.000000
     ProjectileFireInterval=5.000000
     BurnDamageScale=0.100000
     ZombieFlag=1
     MeleeDamage=16
     damageForce=150000
     HeadHealth=20000000545128448.000000
     ScoringValue=24
     HealthMax=2000.000000
     Health=2000
     MenuName="Fire Pound"
     ControllerClass=Class'KFChar.HuskZombieController'
}
