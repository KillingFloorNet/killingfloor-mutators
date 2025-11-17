/*=============================================================================
	UnGame.cpp: Unreal game engine.
	Copyright 1997-2003 Epic Games, Inc. All Rights Reserved.

=============================================================================*/

	GLevel->iFirstDynamicActor = 0;
	if( !Info->bBegunPlay )
	{
        appResetTimer(); // sjs

		// fix up level problems
		FixUpLevel();

		// Update draw distance.
		if (GIsClient)
		{
			GLevel->GetLevelInfo()->InitDistanceFogLOD();
			GLevel->GetLevelInfo()->UpdateDistanceFogLOD( Client->DrawDistanceLOD );
		}

		// Lock the level.
		debugf( NAME_Log, TEXT("Bringing %s up for play (%i) appSeconds: %f..."), GLevel->GetFullName(), appRound(GetMaxTickRate()), appSeconds() ); // sjs
		GLevel->FinishedPrecaching = 0;
		GLevel->TimeSeconds = 0;
		GLevel->GetLevelInfo()->TimeSeconds = 0;
		GLevel->GetLevelInfo()->GetDefaultPhysicsVolume()->bNoDelete = true;

		// Kill off actors that aren't interesting to the client.
		if( !GLevel->IsServer() )
		{
			for( INT i=0; i<GLevel->Actors.Num(); i++ )
			{
				AActor* Actor = GLevel->Actors(i);
				if( Actor )
				{
					if( Actor->bStatic || Actor->bNoDelete || Actor->IsA(AxEmitter::StaticClass()) ) 
					{
						if ( !Actor->bClientAuthoritative )
							Exchange( Actor->Role, Actor->RemoteRole );
					}
					else
						GLevel->DestroyActor( Actor );
				}
			}
		}

		// Init touching actors & clear LastRenderTime
		for( INT i=0; i<GLevel->Actors.Num(); i++ )
			if( GLevel->Actors(i) )
			{
				GLevel->Actors(i)->LastRenderTime = 0.f;
				GLevel->Actors(i)->Touching.Empty();
				GLevel->Actors(i)->PhysicsVolume = GLevel->GetLevelInfo()->GetDefaultPhysicsVolume();
			}


		// Init scripting.
		for( INT i=0; i<GLevel->Actors.Num(); i++ )
			if( GLevel->Actors(i) )
				GLevel->Actors(i)->InitExecution();

		// Enable actor script calls.
		Info->bBegunPlay = 1;
		Info->bStartup = 1;
		Info->TimeDilation = ((ALevelInfo *)(Info->GetClass()->GetDefaultActor()))->TimeDilation;

#ifdef WITH_KARMA
		if(!GIsEditor && !GLevel->GetLevelInfo()->bKNoInit)
		{
			KInitLevelKarma(GLevel);

			for( INT i=0; i<GLevel->Actors.Num(); i++ )
				if( GLevel->Actors(i) )
					KInitActorKarma( GLevel->Actors(i) );
		}
#endif

		// Init the game.
		if( Info->Game )
		{		
			Info->Game->eventInitGame( Options, Error );
			Info->Game->eventSetGrammar();
		}

		// Send PreBeginPlay.
		for( INT i=0; i<GLevel->Actors.Num(); i++ )
			if( GLevel->Actors(i) && !GLevel->Actors(i)->bScriptInitialized )
				GLevel->Actors(i)->eventPreBeginPlay();

		// Set BeginPlay.
		for( INT i=0; i<GLevel->Actors.Num(); i++ )
			if( GLevel->Actors(i) && !GLevel->Actors(i)->bScriptInitialized )
				GLevel->Actors(i)->eventBeginPlay();

		// Set zones && gather volumes.
		TArray<AVolume*> LevelVolumes;
		for( INT i=0; i<GLevel->Actors.Num(); i++ )
		{
			if( GLevel->Actors(i) && !GLevel->Actors(i)->bScriptInitialized )
				GLevel->Actors(i)->SetZone( 1, 1 );

			AVolume* Volume = Cast<AVolume>(GLevel->Actors(i));
			if( Volume )
				LevelVolumes.AddItem(Volume);
		}
		
		// Set appropriate volumes for each actor.
		for( INT i=0; i<GLevel->Actors.Num(); i++ )
			if( GLevel->Actors(i) && !GLevel->Actors(i)->bScriptInitialized )
				GLevel->Actors(i)->SetVolumes( LevelVolumes );

		// Post begin play.
		for( INT i=0; i<GLevel->Actors.Num(); i++ )
			if( GLevel->Actors(i) && !GLevel->Actors(i)->bScriptInitialized )
			{
				GLevel->Actors(i)->eventPostBeginPlay();

				if(GLevel->Actors(i))
					GLevel->Actors(i)->PostBeginPlay();
			}

		// Post net begin play.
		for( INT i=0; i<GLevel->Actors.Num(); i++ )
			if( GLevel->Actors(i) && !GLevel->Actors(i)->bScriptInitialized )
				GLevel->Actors(i)->eventPostNetBeginPlay();

		// Begin scripting.
		for( INT i=0; i<GLevel->Actors.Num(); i++ )
			if( GLevel->Actors(i) && !GLevel->Actors(i)->bScriptInitialized )
				GLevel->Actors(i)->eventSetInitialState();

		// Find bases
		for( INT i=0; i<GLevel->Actors.Num(); i++ )
		{
			if( GLevel->Actors(i) ) 
			{
				if ( GLevel->Actors(i)->AttachTag != NAME_None )
				{
					//find actor to attach self onto
					for( INT j=0; j<GLevel->Actors.Num(); j++ )
					{
						if( GLevel->Actors(j) 
							&& ((GLevel->Actors(j)->Tag == GLevel->Actors(i)->AttachTag) || (GLevel->Actors(j)->GetFName() == GLevel->Actors(i)->AttachTag))  )
						{
							GLevel->Actors(i)->SetBase(GLevel->Actors(j), FVector(0,0,1), 0);
							break;
						}
					}
				}
				else if( GLevel->Actors(i)->bCollideWorld && GLevel->Actors(i)->bShouldBaseAtStartup
				 &&	((GLevel->Actors(i)->Physics == PHYS_None) || (GLevel->Actors(i)->Physics == PHYS_Rotating)) )
				{
					 GLevel->Actors(i)->FindBase();
				}
			}
		}

		for( INT i=0; i<GLevel->Actors.Num(); i++ ) 
		{
			if(GLevel->Actors(i))
			{
				if( GLevel->Actors(i)->IsA(AProjector::StaticClass())) // sjs - why is this needed?!!
				{
					GLevel->Actors(i)->PostEditChange();
				}

#ifdef WITH_KARMA
				AActor* actor = GLevel->Actors(i);

				if(actor->Physics != PHYS_Karma || !actor->KParams || !actor->KParams->IsA(UKarmaParams::StaticClass()))
					continue;

				UKarmaParams* kparams = Cast<UKarmaParams>(actor->KParams);

				// If running below HighDetailPhysics, turn off karma dynamics for actors with bHighDetailOnly set true.
				if(	GLevel->GetLevelInfo()->PhysicsDetailLevel < PDL_High && kparams->bHighDetailOnly )
					KTermActorDynamics(actor);

				// If dedicated server, turn off karma for actors with bHighDetailOnly or bClientsOnly
				if(	GLevel->GetLevelInfo()->NetMode == NM_DedicatedServer && (kparams->bHighDetailOnly || kparams->bClientOnly) )					
					KTermActorDynamics(actor);
#endif
			}
		}

		Info->bStartup = 0;
	}
