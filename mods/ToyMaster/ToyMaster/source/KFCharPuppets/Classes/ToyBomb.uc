class ToyBomb extends Nade;

var     Emitter     FlameTrail;
var     class<Emitter> FlameTrailEmitterClass;

// cut-n-paste to remove grenade smoke trail
simulated function PostBeginPlay()
{
	if ( Role == ROLE_Authority )
	{
		Velocity = Speed * VRand() ;
		RandSpin(25000);
		bCanHitOwner = false;
		if (Instigator.HeadVolume.bWaterVolume)
		{
			bHitWater = true;
			Velocity = 0.6*Velocity;
		}
		if ( !PhysicsVolume.bWaterVolume )
		{
			FlameTrail = Spawn(FlameTrailEmitterClass,self);
		}
	}
}

simulated function Destroyed()
{
	if ( FlameTrail != none )
	{
        FlameTrail.Kill();
        FlameTrail.SetPhysics(PHYS_None);
	}

	Super.Destroyed();
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
	local PlayerController  LocalPlayer;
	local Projectile P;
	local byte i;

	bHasExploded = True;
	BlowUp(HitLocation);

	PlaySound(ExplodeSounds[rand(ExplodeSounds.length)],,2.0);

	// Shrapnel
	for( i=Rand(6); i<10; i++ )
	{
		P = Spawn(ShrapnelClass,,,,RotRand(True));
		if( P!=None )
			P.RemoteRole = ROLE_None;
	}
	if ( EffectIsRelevant(Location,false) )
	{
		Spawn(Class'KFEffectsPuppets.ToyBombExplosion',,, HitLocation, rotator(vect(0,0,1)));
		Spawn(ExplosionDecal,self,,HitLocation, rotator(-HitNormal));
	}

	// Shake nearby players screens
	LocalPlayer = Level.GetLocalPlayerController();
	if ( (LocalPlayer != None) && (VSize(Location - LocalPlayer.ViewTarget.Location) < (DamageRadius * 1.5)) )
		LocalPlayer.ShakeView(RotMag, RotRate, RotTime, OffsetMag, OffsetRate, OffsetTime);

	Destroy();
}

defaultproperties
{
     FlameTrailEmitterClass=Class'KFEffectsPuppets.ToyBombTrail'
     ShrapnelClass=None
     Speed=2000.000000
     MaxSpeed=2500.000000
     Damage=100.000000
     ExplosionDecal=Class'KFEffectsPuppets.ToyBombMark'
     DrawScale=2.000000
}
