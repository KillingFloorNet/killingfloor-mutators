class ShieldFireB extends KFMeleeFire;

var() int MeleeDamageNew;
var float WideDamageMinHitAngleNew;
var float LastClickTime;

simulated event ModeDoFire()
{
	local float Rec;

	if (!AllowFire())
		return;

	Rec = GetFireSpeed();
	SetTimer(DamagedelayMin/Rec, False);
	FireRate = default.FireRate/Rec;
	FireAnimRate = default.FireAnimRate*Rec;
	ReloadAnimRate = default.ReloadAnimRate*Rec;

	if (MaxHoldTime > 0.0)
		HoldTime = FMin(HoldTime, MaxHoldTime);

	if (Weapon.Role == ROLE_Authority)
	{
		Weapon.ConsumeAmmo(ThisModeNum, Load);
		DoFireEffect();

		HoldTime = 0;
		if ( (Instigator == None) || (Instigator.Controller == None) )
			return;

		if ( AIController(Instigator.Controller) != None )
			AIController(Instigator.Controller).WeaponFireAgain(BotRefireRate, true);

		Instigator.DeactivateSpawnProtection();
	}

	if (Instigator.IsLocallyControlled())
	{
		ShakeView();
		PlayFiring();
		FlashMuzzleFlash();
		StartMuzzleSmoke();
		ClientPlayForceFeedback(FireForce);
	}
	else
		ServerPlayFiring();

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

	if( Weapon.Owner != none && Weapon.Owner.Physics != PHYS_Falling )
	{
		Weapon.Owner.Velocity.x *= 0.2;
		Weapon.Owner.Velocity.y *= 0.2;
	}
}

simulated function Timer()
{
	local Actor HitActor;
	local vector StartTrace, EndTrace, HitLocation, HitNormal;
	local rotator PointRot;
	local int MyDamage;
	local bool bBackStabbed;
	local Pawn Victims;
	local vector dir, lookdir;
	local float DiffAngle, VictimDist;

	MyDamage = MeleeDamageNew;
	if( !KFWeapon(Weapon).bNoHit )
	{
		MyDamage = MeleeDamageNew;
		StartTrace = Instigator.Location + Instigator.EyePosition();

		if( Instigator.Controller!=None && PlayerController(Instigator.Controller)==None && Instigator.Controller.Enemy!=None )
		{
			PointRot = rotator(Instigator.Controller.Enemy.Location-StartTrace);
		}
		else
		{
			PointRot = Instigator.GetViewRotation();
		}

		EndTrace = StartTrace + vector(PointRot)*weaponRange;
		HitActor = Instigator.Trace( HitLocation, HitNormal, EndTrace, StartTrace, true);

		if (HitActor!=None)
		{
			ImpactShakeView();

			if( HitActor.IsA('ExtendedZCollision') && HitActor.Base != none &&
				HitActor.Base.IsA('KFMonster') )
			{
				HitActor = HitActor.Base;
			}

			if( Level.NetMode==NM_Client )
			{
				return;
			}

			if( HitActor.IsA('Pawn') && !HitActor.IsA('Vehicle')
			&& (Normal(HitActor.Location-Instigator.Location) dot vector(HitActor.Rotation))>0 )
			{
				bBackStabbed = true;

				MyDamage*=2;
			}

			if( (KFMonster(HitActor)!=none) )
			{

				KFMonster(HitActor).bBackstabbed = bBackStabbed;

				HitActor.TakeDamage(MyDamage, Instigator, HitLocation, vector(PointRot), hitDamageClass) ;

				if(MeleeHitSounds.Length > 0)
				{
					Weapon.PlaySound(MeleeHitSounds[Rand(MeleeHitSounds.length)],SLOT_None,MeleeHitVolume,,,,false);
				}

				if(VSize(Instigator.Velocity) > 300 && KFMonster(HitActor).Mass <= Instigator.Mass)
				{
					KFMonster(HitActor).FlipOver();
				}

			}
			else
			{
				HitActor.TakeDamage(MyDamage, Instigator, HitLocation, vector(PointRot), hitDamageClass) ;
				Spawn(HitEffectClass,,, HitLocation, rotator(HitLocation - StartTrace));
			}
			Spawn(class'ShieldPush',,, HitLocation, PointRot);
		}

		if( WideDamageMinHitAngleNew > 0 )
		{
			foreach Weapon.VisibleCollidingActors( class 'Pawn', Victims, (weaponRange * 2), StartTrace ) //, RadiusHitLocation
			{
				if( (HitActor != none && Victims == HitActor) || Victims.Health <= 0 )
				{
					continue;
				}

				if( Victims != Instigator )
				{
					VictimDist = VSizeSquared(Instigator.Location - Victims.Location);

					if( VictimDist > (((weaponRange * 1.1) * (weaponRange * 1.1)) + (Victims.CollisionRadius * Victims.CollisionRadius)) )
					{
						continue;
					}

					lookdir = Normal(Vector(Instigator.GetViewRotation()));
					dir = Normal(Victims.Location - Instigator.Location);

					DiffAngle = lookdir dot dir;

					if( DiffAngle > WideDamageMinHitAngleNew )
					{
						Victims.TakeDamage(MyDamage*DiffAngle, Instigator, (Victims.Location + Victims.CollisionHeight * vect(0,0,0.7)), vector(PointRot), hitDamageClass) ;

						if(MeleeHitSounds.Length > 0)
						{
							Victims.PlaySound(MeleeHitSounds[Rand(MeleeHitSounds.length)],SLOT_None,MeleeHitVolume,,,,false);
						}
					}
				}
			}
		}
	}
}

simulated function bool AllowFire()
{
	if(KFWeapon(Weapon).bIsReloading)
		return false;
	if(KFPawn(Instigator).SecondaryItem!=none)
		return false;
	if(KFPawn(Instigator).bThrowingNade)
		return false;
	if ( KFWeapon(Weapon).bAimingRifle )
		return false;

	return Super.AllowFire();
}

simulated function DestroyEffects()
{
}

simulated function InitEffects()
{
}

function DrawMuzzleFlash(Canvas Canvas)
{
}

function FlashMuzzleFlash()
{
}

defaultproperties
{
	MeleeDamageNew=10
	WideDamageMinHitAngleNew=0.700000
	ProxySize=0.150000
	weaponRange=65.000000
	DamagedelayMin=0.330000
	DamagedelayMax=0.330000
	MeleeHitSounds(0)=SoundGroup'KF_ClaymoreSnd.Fire.Claymore_Swing'
	bWaitForRelease=True
	FireAnim="Fire_Iron"
	FireRate=1.100000
	BotRefireRate=1.100000
}