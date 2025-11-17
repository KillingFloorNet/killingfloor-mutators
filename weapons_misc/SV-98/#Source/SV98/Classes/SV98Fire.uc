class SV98Fire extends KFFire;

function DoTrace(Vector Start, Rotator Dir)
{
	local Vector X,Y,Z, End, HitLocation, HitNormal, ArcEnd;
	local Actor Other;
	local byte HitCount,HCounter;
	local float HitDamage;
	local array<int>	HitPoints;
	local KFPawn HitPawn;
	local array<Actor>	IgnoreActors;
	local Actor DamageActor;
	local int i;

	MaxRange();

	Weapon.GetViewAxes(X, Y, Z);
	if ( Weapon.WeaponCentered() )
	{
		ArcEnd = (Instigator.Location + Weapon.EffectOffset.X * X + 1.5 * Weapon.EffectOffset.Z * Z);
	}
	else
	{
		ArcEnd = (Instigator.Location + Instigator.CalcDrawOffset(Weapon) + Weapon.EffectOffset.X * X +
		Weapon.Hand * Weapon.EffectOffset.Y * Y + Weapon.EffectOffset.Z * Z);
	}

	X = Vector(Dir);
	End = Start + TraceRange * X;
	HitDamage = DamageMax;
	While( (HitCount++)<4 )
	{
		DamageActor = none;

		Other = Instigator.HitPointTrace(HitLocation, HitNormal, End, HitPoints, Start,, 1);
		if( Other==None )
		{
			Break;
		}
		else if( Other==Instigator || Other.Base == Instigator )
		{
			IgnoreActors[IgnoreActors.Length] = Other;
			Other.SetCollision(false);
			Start = HitLocation;
			Continue;
		}

		if( ExtendedZCollision(Other)!=None && Other.Owner!=None )
		{
			IgnoreActors[IgnoreActors.Length] = Other;
			IgnoreActors[IgnoreActors.Length] = Other.Owner;
			Other.SetCollision(false);
			Other.Owner.SetCollision(false);
			DamageActor = Pawn(Other.Owner);
		}

		if ( !Other.bWorldGeometry && Other!=Level )
		{
			HitPawn = KFPawn(Other);

			if ( HitPawn != none )
			{
				if(!HitPawn.bDeleteMe)
					HitPawn.ProcessLocationalDamage(int(HitDamage), Instigator, HitLocation, Momentum*X,DamageType,HitPoints);

				IgnoreActors[IgnoreActors.Length] = Other;
				IgnoreActors[IgnoreActors.Length] = HitPawn.AuxCollisionCylinder;
				Other.SetCollision(false);
				HitPawn.AuxCollisionCylinder.SetCollision(false);
				DamageActor = Other;
			}
			else
			{
				if( KFMonster(Other)!=None )
				{
					IgnoreActors[IgnoreActors.Length] = Other;
					Other.SetCollision(false);
					DamageActor = Other;
				}
				else if( DamageActor == none )
				{
					DamageActor = Other;
				}
				Other.TakeDamage(int(HitDamage), Instigator, HitLocation, Momentum*X, DamageType);
			}
			if( (HCounter++)>=4 || Pawn(DamageActor)==None )
			{
				Break;
			}
			HitDamage*=0.7;
			Start = HitLocation;
		}
		else if ( HitScanBlockingVolume(Other)==None )
		{
			if( KFWeaponAttachment(Weapon.ThirdPersonActor)!=None )
			KFWeaponAttachment(Weapon.ThirdPersonActor).UpdateHit(Other,HitLocation,HitNormal);
			Break;
		}
	}

	if ( IgnoreActors.Length > 0 )
	{
		for (i=0; i<IgnoreActors.Length; i++)
		{
			if(IgnoreActors[i]!=None)
				IgnoreActors[i].SetCollision(true);
		}
	}
}

defaultproperties
{
	FireAimedAnim=Fire
	FireSound=Sound'SV98_A.SV98_fire'
	StereoFireSound=Sound'SV98_A.SV98_fire'
	NoAmmoSound=Sound'KF_M14EBRSnd.M14EBR_DryFire'
	DamageType=Class'DamTypeSV98SniperRifle'
	DamageMax=400
	Momentum=9500.000000
	bPawnRapidFireAnim=True
	TransientSoundVolume=1.8
	FireLoopAnim="Fire"
	FireForce="AssaultRifleFire"
	FireRate=1.700000
	RecoilRate=0.085
	maxVerticalRecoilAngle=2000
	maxHorizontalRecoilAngle=500
	TweenTime=0.025
	bWaitForRelease=true

	AmmoClass=Class'SV98Ammo'
	AmmoPerFire=1
	BotRefireRate=0.990000
	FlashEmitterClass=Class'ROEffects.MuzzleFlash1stSTG'
	aimerror=42.000000
	Spread=0.005
	SpreadStyle=SS_Random

	ShakeOffsetMag=(X=6.0,Y=3.0,Z=7.5)
	ShakeOffsetRate=(X=1000.0,Y=1000.0,Z=1000.0)
	ShakeOffsetTime=1.15
	ShakeRotMag=(X=50.0,Y=50.0,Z=300.0)
	ShakeRotRate=(X=7500.0,Y=7500.0,Z=7500.0)
	ShakeRotTime=0.65

	ShellEjectClass=class'ROEffects.KFShellEjectEBR'
	ShellEjectBoneName=Shell_eject
}
