class AK12LLIFire extends KFFire;

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
    
	while ( (HitCount++)<10 )
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
                if ( KFMonster(Other)!=None )
                {
                    IgnoreActors[IgnoreActors.Length] = Other;
                    Other.SetCollision(false);
                    DamageActor = Other;
                }
                else if ( DamageActor == none )
                {
                    DamageActor = Other;
                }
                
                Other.TakeDamage(int(HitDamage), Instigator, HitLocation, Momentum*X, DamageType);
            }
            
			if ( (HCounter++)>=4 || Pawn(DamageActor)==None )
			{
				break;
            }
            
			HitDamage *= 0.8;
			Start = HitLocation;
		}
		else if ( HitScanBlockingVolume(Other)==None )
		{
			if ( KFWeaponAttachment(Weapon.ThirdPersonActor)!=None )
                KFWeaponAttachment(Weapon.ThirdPersonActor).UpdateHit(Other,HitLocation,HitNormal);
            
			break;
		}
    }
        
	for (i = 0; i < IgnoreActors.Length; i++)
	{
		if (IgnoreActors[i] != none)
			IgnoreActors[i].SetCollision(true);
	}
}

defaultproperties
{
    FireAimedAnim="Fire_Iron"
    RecoilRate=0.040000
    maxVerticalRecoilAngle=250
    maxHorizontalRecoilAngle=150
    bRecoilRightOnly=True
    ShellEjectClass=Class'KFShellEjectAK12LLI'
    ShellEjectBoneName="Shell_eject"
    bAccuracyBonusForSemiAuto=True
    StereoFireSound=Sound'AK12LLI_A.AK12LLI_Snd.AK12LLI_shot'
    bRandomPitchFireSound=False
    // DamageType=Class'KFMod.DamTypeAK47AssaultRifle'
    DamageType=Class'DamTypeAK12LLI'
    // DamageMax=70
    DamageMax=65
    Momentum=18500.000000
    bPawnRapidFireAnim=True
    TransientSoundVolume=3.800000
    FireLoopAnim="Fire"
    TweenTime=0.025000
    FireSound=Sound'AK12LLI_A.AK12LLI_Snd.AK12LLI_shot'
    NoAmmoSound=Sound'AK12LLI_A.AK12LLI_Snd.AK12LLI_empty'
    FireForce="AssaultRifleFire"
    FireRate=0.095000
    // AmmoClass=Class'KFMod.AK47Ammo'
    AmmoClass=Class'AK12LLIAmmo'
    AmmoPerFire=1
    ShakeRotMag=(X=50.000000,Y=50.000000,Z=350.000000)
    ShakeRotRate=(X=5000.000000,Y=5000.000000,Z=5000.000000)
    ShakeRotTime=0.750000
    ShakeOffsetMag=(X=6.000000,Y=3.000000,Z=7.500000)
    ShakeOffsetRate=(X=1000.000000,Y=1000.000000,Z=1000.000000)
    ShakeOffsetTime=1.250000
    BotRefireRate=0.990000
    FlashEmitterClass=Class'MuzzleFlashAK12LLI'
    aimerror=42.000000
    Spread=0.008000
    SpreadStyle=SS_Random
}
