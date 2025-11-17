/*=============================================================================
	UnLevTic.cpp: Level timer tick function
	Copyright 1997-2004 Epic Games, Inc. All Rights Reserved.

=============================================================================*/

void AWeapon::TickAuthoritative( FLOAT DeltaSeconds )
{
	guardSlow(AWeapon::TickAuthoritative);

    AActor::TickAuthoritative( DeltaSeconds );

    if( bDeleteMe )
        return;

    if ( Instigator && Instigator->Weapon == this && !Instigator->bDeleteMe && Instigator->Controller != NULL && !Instigator->Controller->bDeleteMe 
		&& !Instigator->bNoWeaponFiring )
    {
        eventWeaponTick(DeltaSeconds);
        // client & server: update mode timing
        for (INT mode=0; mode<UCONST_NUM_FIRE_MODES; mode++ )
        {
            if (FireMode[mode] != NULL)
            {
				FireMode[mode]->ModeTick( DeltaSeconds );

                if (!Instigator || !Instigator->Controller) // pawn was killed during mode tick (ie: shieldgun against the wall)
                    return;

                if (Role == ROLE_Authority)
                {
                    if (FireMode[mode]->bServerDelayStartFire)
                    {
                        if (FireMode[mode]->NextFireTime <= Level->TimeSeconds + FireMode[mode]->PreFireTime)
                            eventServerStartFire(mode);
                    }
                    else if (FireMode[mode]->bServerDelayStopFire)
                    {
                        FireMode[mode]->bServerDelayStopFire = false;
                        //debugf(TEXT("ServerDelayStopFire %f"), Level->TimeSeconds);
                        eventStopFire(mode);
                    }
                }
            }
        }

        // client side only: determine when firing starts and stops
		if ( Instigator->IsLocallyControlled() && !bEndOfRound )
		{
			if ( (ClientState == WS_None) || (ClientState == WS_Hidden) )
			{
				debugf(TEXT("%s ClientState was WRONG! (%d)"),GetName(),ClientState);
				ClientState = WS_ReadyToFire;
			}
			
			if ( ClientState == WS_ReadyToFire )
			{
				UBOOL bAltFire = Instigator->Controller->bAltFire;
				UBOOL bFire = Instigator->Controller->bFire;
				AWeapon *MyDefault = Cast<AWeapon>(GetClass()->GetDefaultActor());
				if ( MyDefault && MyDefault->ExchangeFireModes )
				{
					Exchange(bFire,bAltFire);
				}

				if (FireMode[0] != NULL)
				{
					if (FireMode[0]->bIsFiring && !bFire)
					{
						eventClientStopFire(0);
					}
					else if (!FireMode[0]->bIsFiring && bFire)
					{
						eventClientStartFire(0);
					}
				}

				if (FireMode[1] != NULL)
				{
					if (FireMode[1]->bIsFiring && !bAltFire)
					{
						eventClientStopFire(1);
					}
					else if (!FireMode[1]->bIsFiring && bAltFire)
					{                                       
						eventClientStartFire(1);
					}
				}
			}
			else if ( TimerRate<=0.f )
			{
				debugf(TEXT("%s no timer running with clientstate %d"),GetName(),ClientState);
				TimerRate = 0.3f;
			}
		}
    }

    unguardSlow;
}

void UWeaponFire::ModeTick( FLOAT DeltaSeconds )
{
	guard(UWeaponFire::ModeTick);

	if ( !Weapon || Weapon->bDeleteMe || !Instigator || Instigator->bDeleteMe )
		return;

	// WeaponFire timer
	if ( TimerInterval != 0.f )
	{
		if ( NextTimerPop < Level->TimeSeconds )
		{
			eventTimer();
			if ( bTimerLoop )
				NextTimerPop = NextTimerPop + TimerInterval;
			else
				TimerInterval = 0.f;
		}
	}

	eventModeTick(DeltaSeconds);

	FLOAT CurrentTime = Weapon->Level->TimeSeconds;

    if ( (bIsFiring && !bFireOnRelease)
        || ((bInstantStop || !bIsFiring) && bFireOnRelease)
        || (HoldTime > MaxHoldTime && MaxHoldTime > 0.0f) )
    {
        if (CurrentTime > NextFireTime && (bInstantStop || !bNowWaiting) )
		{
           eventModeDoFire();

            if (bWaitForRelease)
                bNowWaiting = true;
		}
    }
    else if (bWaitForRelease && CurrentTime >= NextFireTime)
    {
        bNowWaiting = false;

        if (HoldTime == 0.0f)
            eventModeHoldFire();

        HoldTime += DeltaSeconds;
    }
	bInstantStop = false;
	unguard;
}

