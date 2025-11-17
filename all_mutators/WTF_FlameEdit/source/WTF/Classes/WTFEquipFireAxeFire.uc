class WTFEquipFireAxeFire extends AxeFire;

simulated function Timer()
{
	local Actor HitActor;
	local vector StartTrace, EndTrace, HitLocation, HitNormal;
	local rotator PointRot;
	local int MyDamage;
	local KFPlayerReplicationInfo KFPRI;
	
	If( !KFWeapon(Weapon).bNoHit )
	{
		hitDamageClass=Class'KFMod.DamTypeAxe'; //set back to default in case it was changed by a firebug doing a death from above attack :P
		MyDamage = MeleeDamage;
		StartTrace = Instigator.Location + Instigator.EyePosition();

		if	(
				Instigator.Controller!=None
				&&	PlayerController(Instigator.Controller)==None
				&&	Instigator.Controller.Enemy!=None
			)
		{
			PointRot = rotator(Instigator.Controller.Enemy.Location-StartTrace); // Give aimbot for bots.
		}
		else
			PointRot = Instigator.GetViewRotation();
		EndTrace = StartTrace + vector(PointRot)*weaponRange;
		HitActor = Instigator.Trace( HitLocation, HitNormal, EndTrace, StartTrace, true);
		if (HitActor!=None)
		{
			ImpactShakeView();
			if	(
					HitActor.IsA('ExtendedZCollision')
					&&	HitActor.Base != none
					&&	HitActor.Base.IsA('KFMonster')
				)
			{
				HitActor = HitActor.Base;
			}

			if	(
					(HitActor.IsA('KFMonster') || HitActor.IsA('KFHumanPawn'))
					&&	KFMeleeGun(Weapon).BloodyMaterial!=none
				)
			{
				Weapon.Skins[KFMeleeGun(Weapon).BloodSkinSwitchArray] = KFMeleeGun(Weapon).BloodyMaterial;
				Weapon.texture = Weapon.default.Texture;
			}
			if(KFMonster(HitActor)!=none)
			{
				KFPRI = KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo);
				if(Level.NetMode!=NM_DedicatedServer)
				{
					if (Instigator.Velocity.Z < 0)
					{
						if (KFPRI != none)
						{
							Log("WFT.0");
							//Spawn(Class'KFIncendiaryExplosion',,, HitLocation, rotator(vect(0,0,1)));
							Weapon.PlayOwnedSound(Sound'KF_EnemiesFinalSnd.Husk.Husk_FireImpact',SLOT_Interact,2.0,,500.0,,false);
						}
					}
				}

				//only server deals the damage
				if(Level.NetMode==NM_Client)
					return;

				if	(
						HitActor.IsA('Pawn')
						&&	!HitActor.IsA('Vehicle')
						&&	(Normal(HitActor.Location-Instigator.Location) dot vector(HitActor.Rotation))<0
					)
				{
					MyDamage*=2;
				}
				Spawn(Class'WTFEquipFireAxeProj',Instigator, '', HitLocation, PointRot);
				if(Instigator.Velocity.Z < 0)
				{
					if (KFPRI != None)
					{
						MyDamage *= 1.15; //bonus damage for falling strike
						HitActor.TakeDamage(MyDamage * 0.5, Instigator, HitLocation, vector(PointRot), Class'KFMod.DamTypeBurned');
					}
				}
				HitActor.TakeDamage(MyDamage, Instigator, HitLocation, vector(PointRot), Class'KFMod.DamTypeBurned');
				if(MeleeHitSounds.Length > 0)
					Weapon.PlaySound(MeleeHitSounds[Rand(MeleeHitSounds.length)],SLOT_None,MeleeHitVolume,,,,false);
				if(VSize(Instigator.Velocity) > 300 && KFMonster(HitActor).Mass <= Instigator.Mass)
					KFMonster(HitActor).FlipOver();
			}
			else
			{
				HitActor.TakeDamage(MyDamage, Instigator, HitLocation, vector(PointRot), Class'KFMod.DamTypeBurned') ;
				Spawn(HitEffectClass,,, HitLocation, rotator(HitLocation - StartTrace));
			}
		}
	}
}