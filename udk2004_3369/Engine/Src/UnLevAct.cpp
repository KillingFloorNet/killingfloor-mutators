/*=============================================================================
	UnLevAct.cpp: Level actor functions
	Copyright 1997-2001 Epic Games, Inc. All Rights Reserved.

=============================================================================*/

//
// Create a new actor. Returns the new actor, or NULL if failure.
//
AActor* ULevel::SpawnActor
(
	UClass*			Class,
	FName			InName,
	FVector			Location,
	FRotator		Rotation,
	AActor*			Template,
	UBOOL			bNoCollisionFail,
	UBOOL			bRemoteOwned,
	AActor*			Owner,
	APawn*			Instigator,
	UBOOL			bNoFail
)
{
	guard(ULevel::SpawnActor);

    if( GetFlags() & RF_Unreachable )
        return NULL;

	// Make sure this class is spawnable.
	if( !Class )
	{
		debugf( NAME_Warning, TEXT("SpawnActor failed because no class was specified") );
		return NULL;
	}
	if( Class->ClassFlags & CLASS_Abstract )
	{
		debugf( NAME_Warning, TEXT("SpawnActor failed because class %s is abstract"), Class->GetName() );
		return NULL;
	}
	else if( !Class->IsChildOf(AActor::StaticClass()) )
	{
		debugf( NAME_Warning, TEXT("SpawnActor failed because %s is not an actor class"), Class->GetName() );
		return NULL;
	}
	else if( !GIsEditor && (Class->GetDefaultActor()->bStatic || Class->GetDefaultActor()->bNoDelete) )
	{
		debugf( NAME_Warning, TEXT("SpawnActor failed because class %s has bStatic or bNoDelete"), Class->GetName() );
		if ( !bNoFail )
			return NULL;		
	}

	// don't spawn bHighDetail actors if not wanted
	if( !GIsEditor && Class->GetDefaultActor()->bHighDetail && !bNoFail )
	{
	    if( GetLevelInfo()->DetailMode == DM_Low || GetLevelInfo()->bDropDetail || (GetLevelInfo()->NetMode == NM_DedicatedServer) )
		{
			//debugf(TEXT("%s not spawned"),Class->GetName());
			return NULL;
		}
    }
#if 1
    // sjs - level's outer is not transient so we must do this
    // doing this is a huge benefit for long running names, as the name table grows > 40 megs after long multiplayer games.
    if( !GTransientNaming && InName==NAME_None)
        InName = NAME_Transient;
#endif

	// Use class's default actor as a template.
	if( !Template )
		Template = Class->GetDefaultActor();
	check(Template!=NULL);

	// Make sure actor will fit at desired location, and adjust location if necessary.
	if( (Template->bCollideWorld || (Template->bCollideWhenPlacing && (GetLevelInfo()->NetMode != NM_Client))) && !bNoCollisionFail )
		if( !FindSpot( Template->GetCylinderExtent(), Location ) )
			return NULL;

	// Add at end of list.
	INT iActor = Actors.Add();
    AActor* Actor = Actors(iActor) = (AActor*)StaticConstructObject( Class, GetOuter(), InName, 0, Template );

	Actor->SetFlags( RF_Transactional );

	// Set base actor properties.
	Actor->Tag		= Class->GetFName();
	Actor->Region	= FPointRegion( GetLevelInfo() );
	Actor->Level	= GetLevelInfo();
	Actor->bTicked  = !Ticked;
	Actor->XLevel	= this;

	// Set network role.
	check(Actor->Role==ROLE_Authority);
	if( bRemoteOwned )
		Exchange( Actor->Role, Actor->RemoteRole );

	// Remove the actor's brush, if it has one, because moving brushes are not duplicatable.
	if( Actor->Brush )
		Actor->Brush = NULL;

	// Set the actor's location and rotation.
	Actor->Location = Location;
	Actor->Rotation = Rotation;
	if( Actor->bCollideActors && Hash  )
		Hash->AddActor( Actor );

	// init actor's physics volume
	Actor->PhysicsVolume = 	GetLevelInfo()->PhysicsVolume; 

	// Set owner.
	Actor->SetOwner( Owner );

	// Set instigator
	Actor->Instigator = Instigator;

#ifdef WITH_KARMA
    // Initilise Karma physics for this actor (if there are any)
    KInitActorKarma(Actor);
#endif

	// Send messages.
	Actor->InitExecution();
	Actor->Spawned();
	Actor->eventPreBeginPlay();
	if( Actor->bDeleteMe && !bNoFail )
		return NULL;
	Actor->eventBeginPlay();
	if( Actor->bDeleteMe && !bNoFail )
		return NULL;

	// Set the actor's zone.
	Actor->SetZone( iActor==0, 1 );

	// Update the list of leaves this actor is in.
	Actor->ClearRenderData();

	// Check for encroachment.
	if( !bNoCollisionFail )
	{
		if( Actor->bCollideActors && Hash )
			Hash->RemoveActor( Actor );

		if( CheckEncroachment( Actor, Actor->Location, Actor->Rotation, 1 ) )
		{
			DestroyActor( Actor );
			return NULL;
		}
		if( Actor->bCollideActors && Hash )
			Hash->AddActor( Actor );
	}
	//if ( Actor->bCollideActors && !Actor->bBlockActors && !Actor->bUseCylinderCollision && (Actor->DrawType == DT_StaticMesh) )
	//	debugf(TEXT("%s shouldn't be using static mesh collision"),Actor->GetName());

	// Send PostBeginPlay.
	Actor->eventPostBeginPlay();
	if( Actor->bDeleteMe && !bNoFail )
		return NULL;

	Actor->PostBeginPlay();

	// Init scripting.
	Actor->eventSetInitialState();

	// Find Base
	if( !GIsEditor && !Actor->Base && Actor->bCollideWorld && Actor->bShouldBaseAtStartup 
		 && ((Actor->Physics == PHYS_None) || (Actor->Physics == PHYS_Rotating)) )
		Actor->FindBase();

	// Success: Return the actor.
	if( InTick )
		NewlySpawned = new(GEngineMem)FActorLink(Actor,NewlySpawned);

	// replicated actors will have postnetbeginplay() called in net code, after initial properties are received
	if ( !bRemoteOwned )
		Actor->eventPostNetBeginPlay();

	return Actor;
	unguardf(( TEXT("(%s)"), Class->GetName() ));
}
