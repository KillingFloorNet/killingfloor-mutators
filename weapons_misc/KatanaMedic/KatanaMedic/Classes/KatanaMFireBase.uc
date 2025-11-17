class KatanaMFireBase extends KFMeleeFire;

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
	local KatanaMProjEnemy p;
	local KFPlayerReplicationInfo PRI;
	local int MedicReward;
	local KFHumanPawn Healed;
	local float HealSum;

	MyDamage = MeleeDamage;
	
	PRI = KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo);
	

    if (PRI.ClientVeteranSkill.Static.GetSyringeChargeRate(PRI) > 1.0)
	{
	   FireRate=FireRate - (0.60 * PRI.ClientVeteranSkill.Static.GetSyringeChargeRate(PRI) );
	}

	If( !KFWeapon(Weapon).bNoHit )
	{
		MyDamage = MeleeDamage;
		StartTrace = Instigator.Location + Instigator.EyePosition();

		if( Instigator.Controller!=None && PlayerController(Instigator.Controller)==None && Instigator.Controller.Enemy!=None )
		{
        	PointRot = rotator(Instigator.Controller.Enemy.Location-StartTrace); // Give aimbot for bots.
        }
		else
        {
            PointRot = Instigator.GetViewRotation();
        }

		EndTrace = StartTrace + vector(PointRot)*weaponRange;
		HitActor = Instigator.Trace( HitLocation, HitNormal, EndTrace, StartTrace, true);

        //Instigator.ClearStayingDebugLines();
        //Instigator.DrawStayingDebugLine( StartTrace, EndTrace,0, 255, 0);

		if (HitActor!=None)
		{
			ImpactShakeView();

			if( HitActor.IsA('ExtendedZCollision') && HitActor.Base != none &&
                HitActor.Base.IsA('KFMonster') )
            {
                HitActor = HitActor.Base;
            }

			if ( (HitActor.IsA('KFMonster') || HitActor.IsA('KFHumanPawn')) && KFMeleeGun(Weapon).BloodyMaterial!=none )
			{
				Weapon.Skins[KFMeleeGun(Weapon).BloodSkinSwitchArray] = KFMeleeGun(Weapon).BloodyMaterial;
				Weapon.texture = Weapon.default.Texture;
				
			}
			if( Level.NetMode==NM_Client )
            {
                Return;
            }
			
			if( (KFHumanPawn(HitActor) !=none) )
			{

    	         Healed = KFHumanPawn(HitActor);
				 
				if( Instigator != none && Healed != none && Healed.Health > 0 && Healed.Health <  Healed.HealthMax && Healed.bCanBeHealed )
                {

    		PRI = KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo);

    		if ( PRI != none && PRI.ClientVeteranSkill != none )
    		{
  
            
			 if (KatanaM(Weapon).GetAmmoe() > 9 && Healed.Health < (Healed.HealthMax*0.95))
			 {
			   HealSum = 1 + (10 * PRI.ClientVeteranSkill.Static.GetHealPotency(PRI) );
			   KatanaM(Weapon).SetAmmoe(36);
			   Healed.GiveHealth(HealSum, (Healed.HealthMax*1.2+(0.2*PRI.ClientVeteranSkill.Static.GetHealPotency(PRI))) );
               Spawn(Class'KatanaMedic.HPAlia', Healed);
			   if( KatanaM(Weapon) != none )
                {
                    KatanaM(Weapon).ClientSuccessfulHeal(Healed.GetPlayerName());
                }
			 }


			}
                	
            MedicReward = HealSum;					
			

    		if ( (Healed.Health + Healed.healthToGive + MedicReward) > Healed.HealthMax )
    		{
                MedicReward = Healed.HealthMax - (Healed.Health + Healed.healthToGive);
    			if ( MedicReward < 0 )
    			{
    				MedicReward = 0;
    			}
    		}


     		if ( PRI != None )
    		{
    			 if ( MedicReward > 0 && KFSteamStatsAndAchievements(PRI.SteamStatsAndAchievements) != none )
    			 {
	    			AddDamagedHealStats( MedicReward );
    			 }

                 // Give the medic reward money as a percentage of how much of the person's health they healed
    		 	 MedicReward = int((FMin(float(MedicReward),Healed.HealthMax)/Healed.HealthMax) * 60); // Increased to 80 in Balance Round 6, reduced to 60 in Round 7

    			 PRI.ReceiveRewardForHealing( MedicReward, Healed );

    			 if ( KFHumanPawn(Instigator) != none )
    			 {
    			 	KFHumanPawn(Instigator).AlphaAmount = 255;
    			 }
				
			    }
			  
             }
			}
			
			
			
			if( HitActor.IsA('Pawn') && !HitActor.IsA('Vehicle')
			 && (Normal(HitActor.Location-Instigator.Location) dot vector(HitActor.Rotation))>0 ) // Fixed in Balance Round 2
			{
				bBackStabbed = true;

				MyDamage*=2; // Backstab >:P
			}

			if( (KFMonster(HitActor)!=none) )
			{

				KFMonster(HitActor).bBackstabbed = bBackStabbed;

                HitActor.TakeDamage(MyDamage, Instigator, HitLocation, vector(PointRot), hitDamageClass) ;
				
                p = Spawn(Class'KatanaMedic.KatanaMProjEnemy', instigator,, HitLocation, PointRot);
				p.Stick(KFMonster(HitActor));
				p.SetOwningPlayer(KatanaM(Weapon));
				
				KatanaM(Weapon).SumeAmmoe();

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
			     p = Spawn(Class'KatanaMedic.KatanaMProjEnemy', instigator,, HitLocation, PointRot);
				p.Stick(KFMonster(HitActor));
				p.SetOwningPlayer(KatanaM(Weapon));
				HitActor.TakeDamage(MyDamage, Instigator, HitLocation, vector(PointRot), hitDamageClass) ;
				Spawn(HitEffectClass,,, HitLocation, rotator(HitLocation - StartTrace));
		}
		}

		if( WideDamageMinHitAngle > 0 )
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

    	           	if( DiffAngle > WideDamageMinHitAngle )
    	           	{
     					Victims.TakeDamage(MyDamage*DiffAngle, Instigator, (Victims.Location + Victims.CollisionHeight * vect(0,0,0.7)), vector(PointRot), hitDamageClass) ;
                        
                p = Spawn(Class'KatanaMedic.KatanaMProjEnemy', instigator,, HitLocation, PointRot);
				p.Stick(Victims);
				p.SetOwningPlayer(KatanaM(Weapon));
				KatanaM(Weapon).SumeAmmoe();
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


function AddDamagedHealStats( int MedicReward )
{
    local KFSteamStatsAndAchievements KFSteamStats;

	if ( Instigator == none || Instigator.PlayerReplicationInfo == none )
	{
		return;
	}

	KFSteamStats = KFSteamStatsAndAchievements( Instigator.PlayerReplicationInfo.SteamStatsAndAchievements );

	if ( KFSteamStats != none )
	{
	 	KFSteamStats.AddDamageHealed(MedicReward);
	}
}

defaultproperties
{
}
