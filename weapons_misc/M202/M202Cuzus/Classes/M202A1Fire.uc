class M202A1Fire extends LAWFire;

var() class<Projectile> BackBurnProjectileClass;
var() int BackBurnProjPerFire;
var() int BackBurnPlusMinusCount;
var() float BackBurnSpread;
var() Vector BackBurnProjSpawnOffset;
var() name FireAnimIron;
var() name FireAnimSimple;

simulated function bool AllowFire()
{
	if(KFWeapon(Weapon).bIsReloading)
		return false;
	if(KFPawn(Instigator).SecondaryItem!=none)
		return false;
	if(KFPawn(Instigator).bThrowingNade)
		return false;

	if(KFWeapon(Weapon).MagAmmoRemaining < 1)
	{
    	if( Level.TimeSeconds - LastClickTime>FireRate )
    	{
    		LastClickTime = Level.TimeSeconds;
    	}

		if( AIController(Instigator.Controller)!=None )
			KFWeapon(Weapon).ReloadMeNow();
		return false;
	}

	return true;
}

function projectile SpawnProjectileBack(Vector Start, Rotator Dir, Rotator BaseDir)
{
    local Projectile p;

    if( BackBurnProjectileClass != None )
        p = Weapon.Spawn(BackBurnProjectileClass,,, Start, Dir);

    if( p == None )
        return None;

    p.Damage *= DamageAtten;

    return p;
}

event ModeDoFire()
{
	local float Rec;
	
	if (!AllowFire())
		return;
	
	Spread = Default.Spread;
	
	Rec = GetFireSpeed();
	FireRate = default.FireRate/Rec;
	FireAnimRate = default.FireAnimRate*Rec;
	if(KFWeapon(Weapon).bAimingRifle)
	{		
		FireAnim = FireAnimIron;
	}
	else
	{
		FireAnim = FireAnimSimple;
	}

	Rec = 1;
	
	if ( KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo) != none && KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill != none )
	{
		Spread *= KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill.Static.ModifyRecoilSpread(KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo), self, Rec);
	}
	
	if( !bFiringDoesntAffectMovement )
	{
		if (FireRate > 0.25)
		{
			Instigator.Velocity.x *= 0.1;
			Instigator.Velocity.y *= 0.1;
		}
		else
		{
			Instigator.Velocity.x *= 0.5;
			Instigator.Velocity.y *= 0.5;
		}
	}
	if (!AllowFire())
	return;
	
	if (MaxHoldTime > 0.0)
	HoldTime = FMin(HoldTime, MaxHoldTime);
	
	if (Level.NetMode != NM_Client)
	{
	Load = KFWeapon(Weapon).MagAmmoRemaining;
	Weapon.ConsumeAmmo(ThisModeNum, AmmoPerFire);
	DoFireEffectN(Load);
		HoldTime = 0;
	if ( (Instigator == None) || (Instigator.Controller == None) )
			return;
	
	if ( AIController(Instigator.Controller) != None )
	    AIController(Instigator.Controller).WeaponFireAgain(BotRefireRate, true);
	
	Instigator.DeactivateSpawnProtection();
	}
	if (Instigator.IsLocallyControlled())
	{
	        if( Weapon.Role < ROLE_Authority )
			{
	        }
	ShakeView();
	PlayFiring();
	FlashMuzzleFlash();
	StartMuzzleSmoke();
	}
	else
	{
	ServerPlayFiring();
	}
	
	Weapon.IncrementFlashCount(ThisModeNum);
	
	if (bFireOnRelease)
	{
	if (bIsFiring)
	    NextFireTime += MaxHoldTime + FireRate;
	else
	    NextFireTime = Level.TimeSeconds + FireRate;
	}
	else
	{
	NextFireTime += FireRate;
	NextFireTime = FMax(NextFireTime, Level.TimeSeconds);
	}
	
	Load = AmmoPerFire;
	HoldTime = 0;
	
	if (Instigator.PendingWeapon != Weapon && Instigator.PendingWeapon != None)
	{
	bIsFiring = false;
	Weapon.PutDown();
	}
	if (Instigator.IsLocallyControlled())
	{
	HandleRecoil(Rec);
	}
}

function DoFireEffectN(int nomer)
{	
	local Vector offsetsXYZ;

 	offsetsXYZ = BackBurnProjSpawnOffset;

	if(nomer==4)
	{
		offsetsXYZ.Y = -offsetsXYZ.Y;
		offsetsXYZ.z =  offsetsXYZ.Z;
	}
	if(nomer==3)
	{
		offsetsXYZ.Y =  offsetsXYZ.Y;
		offsetsXYZ.z =  offsetsXYZ.Z;	
	}
	if(nomer==2)
	{
		offsetsXYZ.Y = -offsetsXYZ.Y;
		offsetsXYZ.z = -offsetsXYZ.Z;
	}
	if(nomer==1)
	{
		offsetsXYZ.Y =  offsetsXYZ.Y;
		offsetsXYZ.z = -offsetsXYZ.Z;
	}		
	DoFireEffectWithOffsets(offsetsXYZ);		
}

function DoFireEffectWithOffsets(vector offsetsXYZ)
{
    local Vector StartProj, StartTrace, X,Y,Z;
    local Rotator R, Aim;
    local Vector HitLocation, HitNormal;
    local Actor Other;
    local int p;
    local int SpawnCount;
    local float theta;
    local float shag;

    Instigator.MakeNoise(1.0);
    Weapon.GetViewAxes(X,Y,Z);

    StartTrace = Instigator.Location + Instigator.EyePosition();// + X*Instigator.CollisionRadius;
    StartProj = StartTrace + X*ProjSpawnOffset.X;
    if ( !Weapon.WeaponCentered() && !KFWeap.bAimingRifle )
	    StartProj = StartProj + Weapon.Hand * Y*ProjSpawnOffset.Y+Y*offsetsXYZ.Y+ Z*ProjSpawnOffset.Z+Z*offsetsXYZ.Z;

    Other = Weapon.Trace(HitLocation, HitNormal, StartProj, StartTrace, false);

    if (Other != None)
    {
        StartProj = HitLocation;
    }

    Aim = AdjustAim(StartProj, AimError);

    SpawnCount = Max(1, ProjPerFire * int(Load));

    switch (SpreadStyle)
    {
    case SS_Random:
        X = Vector(Aim);
        for (p = 0; p < SpawnCount; p++)
        {
            R.Yaw = Spread * (FRand()-0.5);
            R.Pitch = Spread * (FRand()-0.5);
            R.Roll = Spread * (FRand()-0.5);
            SpawnProjectile(StartProj, Rotator(X >> R));
        }
        break;
    case SS_Line:
        for (p = 0; p < SpawnCount; p++)
        {
            theta = Spread*PI/32768*(p - float(SpawnCount-1)/2.0);
            X.X = Cos(theta);
            X.Y = Sin(theta);
            X.Z = 0.0;
            SpawnProjectile(StartProj, Rotator(X >> Aim));
        }
        break;
    default:
        SpawnProjectile(StartProj, Aim);
    }

	if (Instigator != none && Instigator.Physics != PHYS_Falling)
		Instigator.AddVelocity(KickMomentum >> Instigator.GetViewRotation());
	
	Instigator.MakeNoise(1.0);
	Weapon.GetViewAxes(X,Y,Z);	
	
	StartTrace = Instigator.Location + Instigator.EyePosition();// + X*Instigator.CollisionRadius;
	StartProj = StartTrace + X*BackBurnProjSpawnOffset.X;
	if ( !Weapon.WeaponCentered() && !KFWeap.bAimingRifle )
	    StartProj = StartProj + Weapon.Hand * Y*ProjSpawnOffset.Y+Y*offsetsXYZ.Y+ Z*ProjSpawnOffset.Z+Z*offsetsXYZ.Z;
	
	Other = Weapon.Trace(HitLocation, HitNormal, StartProj, StartTrace, false);
	
	if (Other != None)
	{
	StartProj = HitLocation;
	}
	
	Aim = AdjustAim(StartProj, AimError);
	Aim.Pitch = Aim.Pitch+65536/2;
	SpawnCount = Max(1, BackBurnProjPerFire+Rand(BackBurnPlusMinusCount));
	
	X = Vector(Aim);

	shag = 65536/12;
	for (p = 0; p < 12; p++)
	{
	    R.Pitch = 4091*sin((shag*p + (shag/8)*(FRand()-0.5))*PI/32768);
	    R.Yaw = 4091*cos((shag*p + (shag/8)*(FRand()-0.5))*PI/32768);
	    R.Roll = 0;
	    SpawnProjectileBack(StartProj, Aim + R, Rotator(X));
	}
	shag = 65536/8;
	for (p = 0; p < 8; p++)
	{
	    R.Pitch = 2047*sin((shag*p + (shag/8)*(FRand()-0.5))*PI/32768);
	    R.Yaw = 2047*cos((shag*p + (shag/8)*(FRand()-0.5))*PI/32768);
	    R.Roll = 0;
	    SpawnProjectileBack(StartProj, Aim + R, Rotator(X));
	}
	R.Pitch = 0;
	R.Roll = 0;
	SpawnProjectileBack(StartProj, Aim + R, Rotator(X));
}


defaultproperties
{
     BackBurnProjectileClass=Class'M202BackBurnBackProj'
     BackBurnProjPerFire=20
     BackBurnPlusMinusCount=5
     BackBurnSpread=1125.000000
     BackBurnProjSpawnOffset=(X=-70.000000,Y=3.12,Z=3.12)
     FireRate=0.5
     AmmoPerFire=1
     AmmoClass=Class'M202A1Ammo'
     ProjectileClass=Class'M202A1Proj'
     FireAnim="IronFire"
     FireAnimIron="Fire"
     FireAnimSimple="IronFire"
}
