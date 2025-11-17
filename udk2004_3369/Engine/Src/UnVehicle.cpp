/*=============================================================================
	UnVehicle.cpp: Vehicle physics implementation

	Copyright 2000-2003 Epic Games, Inc. All Rights Reserved.

=============================================================================*/

void AVehicle::PostRender(FLevelSceneNode* SceneNode, FRenderInterface* RI)
{
	guard(AVehicle::PostRender);

    // Render team beacon
    if ( !SceneNode || !SceneNode->Viewport || !SceneNode->Viewport->Actor )
        return;

	if ( bScriptPostRender )
	{
		FVector camLoc = SceneNode->WorldToCamera.TransformFVector(Location + FVector(0.f,0.f,CollisionHeight));
		FPlane  screenLoc = SceneNode->Project(SceneNode->CameraToWorld.TransformFVector(camLoc));
		screenLoc.X = (SceneNode->Viewport->Canvas->ClipX * 0.5f * (screenLoc.X + 1.f));
		screenLoc.Y = (SceneNode->Viewport->Canvas->ClipY * 0.5f * (-screenLoc.Y + 1.f));
		eventPostRender2D(SceneNode->Viewport->Canvas,screenLoc.X, screenLoc.Y);
		return;
	}
    if ( bNoTeamBeacon || ((SceneNode->Viewport->Actor->ViewTarget == this) && (SceneNode->Viewport->Actor->Pawn == this)) )
        return;

    APlayerController* pc = SceneNode->Viewport->Actor;
	UBOOL bSpectating = pc->PlayerReplicationInfo ? (pc->PlayerReplicationInfo->bOnlySpectator && !pc->bHideSpectatorBeacons) : false;

    INT playerTeamIndex   = -1;

	// Draw 'No Entry' indicator.
	if ( !bSpectating && !SceneNode->Viewport->Actor->bHideVehicleNoEntryIndicator )
	{
		if (pc->PlayerReplicationInfo && pc->PlayerReplicationInfo->Team)
			playerTeamIndex = pc->PlayerReplicationInfo->Team->TeamIndex;

		if (playerTeamIndex < 0 || playerTeamIndex > 1)
			return;

		if ( bTeamLocked && (playerTeamIndex != Team) && !PlayerReplicationInfo )
		{
			FLOAT actorDist = SceneNode->WorldToScreen.TransformFVector(Location).Z;

			if ( (actorDist < 0.f) || (actorDist > 2.f * pc->TeamBeaconPlayerInfoMaxDist) || !NoEntryTexture )
				return;

			FCheckResult Hit(1.f);
			GetLevel()->SingleLineCheck( Hit, this, Location, SceneNode->ViewOrigin, TRACE_World|TRACE_StopAtFirstHit );
			if ( Hit.Actor )
			{
				GetLevel()->SingleLineCheck( Hit, this, Location + FVector(0.f,0.f,0.5f*CollisionHeight), SceneNode->ViewOrigin, TRACE_World|TRACE_StopAtFirstHit );
				if ( Hit.Actor )
					return;
			}
			GetLevel()->SingleLineCheck( Hit, pc->Pawn, Location, SceneNode->ViewOrigin, TRACE_Pawns );
			if ( Hit.Actor && (Hit.Actor != this) && !Hit.Actor->bWorldGeometry )
			{
				if ( Hit.Actor->Physics == PHYS_Karma )
					return;
				FVector Projected = (Hit.Actor->Location - Hit.Location);
				FVector ViewDir = (Hit.Actor->Location - SceneNode->ViewOrigin).SafeNormal();
				Projected = Projected - ViewDir * (ViewDir | Projected);
				if ( Abs(Projected.Z) < 0.8f * Hit.Actor->CollisionHeight )
					return;
				Projected.Z = 0.f;
				if ( Projected.SizeSquared() < 0.25f * Hit.Actor->CollisionRadius * Hit.Actor->CollisionRadius )
					return;
			}

			// draw locked symbol
			FVector camLoc = SceneNode->WorldToCamera.TransformFVector(Location);
			FPlane  screenLoc = SceneNode->Project(SceneNode->CameraToWorld.TransformFVector(camLoc));
			SceneNode->Viewport->Canvas->Style = STY_AlphaZ;
			FLOAT   xscale = ::Clamp( (2.f*pc->TeamBeaconPlayerInfoMaxDist - actorDist)/(2.f*pc->TeamBeaconPlayerInfoMaxDist), 0.55f, 1.f);
			xscale = xscale * xscale;
			screenLoc.X = (SceneNode->Viewport->Canvas->ClipX * 0.5f * (screenLoc.X + 1.f)) - 0.5*NoEntryTexture->USize*xscale;
			screenLoc.Y = (SceneNode->Viewport->Canvas->ClipY * 0.5f * (-screenLoc.Y + 1.f)) - 0.5*NoEntryTexture->VSize*xscale;

			SceneNode->Viewport->Canvas->DrawTile(
				NoEntryTexture,
				screenLoc.X, 
				screenLoc.Y, 
				NoEntryTexture->USize*xscale,
				NoEntryTexture->VSize*xscale,
				0.f, 
				0.f, 
				NoEntryTexture->USize, 
				NoEntryTexture->VSize,
				0.f,
				FPlane(1.f,0.f,0.f,1.f),
				FPlane(0.0f,0.0f,0.0f,0.0f));
			return;
		}
	}

    INT teamIndex = -1;

	if (PlayerReplicationInfo && PlayerReplicationInfo->Team)
		teamIndex = PlayerReplicationInfo->Team->TeamIndex;
	else
		teamIndex = Team;

	if ( teamIndex == -1 )
		return;
	if ( !bSpectating && (teamIndex != playerTeamIndex) )
		return;
    UTexture* teamBeacon = TeamBeaconTexture;
	UMaterial* teamBeaconBorder = TeamBeaconBorderMaterial;

    if ( !teamBeacon )
	{
		if ( !bDrawDriverInTP || (Driver && ((Location - SceneNode->ViewOrigin).SizeSquared() > Square(Driver->CullDistance))) )
			Super::PostRender(SceneNode,RI);
        return;
	}

    FLOAT actorDist = pc->FOVBias * SceneNode->WorldToScreen.TransformFVector(Location).Z;
	FLOAT ScaledDist = pc->TeamBeaconMaxDist * ::Clamp(0.04f * CollisionRadius,1.f,3.f);

	if ( (actorDist < 0.f) || (actorDist > ScaledDist) )
        return;

    if (!pc->LineOfSightTo(this))
        return;

    FPlane color = (teamIndex == 0) ? FPlane(1.f,0.25f,0.25f,1.f) : FPlane(0.25f,0.35f,1.f,1.f);
	if ( teamIndex > 1 )
		color = (teamIndex == 2) ? FPlane(0.f,1.f,0.25f,1.f) : FPlane(1.f,1.f,0.f,1.f);
    FVector camLoc = SceneNode->WorldToCamera.TransformFVector(Location+FVector(0.0f,0.0f,1.75f * CollisionHeight));
    FPlane  screenLoc = SceneNode->Project(SceneNode->CameraToWorld.TransformFVector(camLoc));

	SceneNode->Viewport->Canvas->Style = STY_AlphaZ;
	FLOAT   xscale = ::Clamp( (pc->TeamBeaconMaxDist - actorDist)/pc->TeamBeaconMaxDist, 0.7f, 1.f);
	xscale = xscale * xscale * 0.5f;
	if ( actorDist < 10.f*CollisionRadius)
		xscale *= 3.f * ::Max( 0.333f, (10.f*CollisionRadius - actorDist)/(10.f*CollisionRadius));
	else if ( actorDist > 1.5f * pc->TeamBeaconMaxDist )
		xscale *= ::Max( 0.5f, (ScaledDist - actorDist)/(ScaledDist - 1.5f * pc->TeamBeaconMaxDist));

	FLOAT   yscale = 0.25f * xscale;
	screenLoc.X = (SceneNode->Viewport->Canvas->ClipX * 0.5f * (screenLoc.X + 1.f)) - 0.5*teamBeacon->USize*xscale;
	screenLoc.Y = (SceneNode->Viewport->Canvas->ClipY * 0.5f * (-screenLoc.Y + 1.f)) - 0.5*teamBeacon->VSize*xscale;

	if ( !bHUDTrackVehicle )
	{
		if ( teamBeaconBorder )
		{
			SceneNode->Viewport->Canvas->DrawTile(
				teamBeaconBorder,
				screenLoc.X, 
				screenLoc.Y, 
				teamBeacon->USize*xscale,
				teamBeacon->VSize*yscale,
				0.f, 
				0.f, 
				teamBeacon->USize, 
				teamBeacon->VSize,
				0.f,
				FPlane(1.f,1.f,1.f,1.f),
				FPlane(0.0f,0.0f,0.0f,0.0f));
		}

		if ( teamBeacon )
		{
			FPlane HealthColor;
			if (Health / HealthMax > 0.5)
			{
				HealthColor = FPlane(::Clamp(1.f - (HealthMax - (HealthMax - Health) * 2)/HealthMax,0.f,1.f),
									1.f,
									0.f,
									1.f);
			}
			else
			{
				HealthColor = FPlane(1.f,
									::Clamp(2.f*Health/HealthMax,0.f,1.f),
									0.f,
									1.f);
			}
			SceneNode->Viewport->Canvas->DrawTile(
				teamBeacon,
				screenLoc.X, 
				screenLoc.Y, 
				teamBeacon->USize*xscale * Health/HealthMax,
				teamBeacon->VSize*yscale,
				0.f, 
				0.f, 
				teamBeacon->USize, 
				teamBeacon->VSize,
				0.f,
				HealthColor,
				FPlane(0.0f,0.0f,0.0f,0.0f));
		}
	}

	if ( PlayerReplicationInfo && (!bDrawDriverInTP  || (Driver && ((Location - SceneNode->ViewOrigin).SizeSquared() > Square(Driver->CullDistance)))) )
	{
		FLOAT xL, yL;
		FString info;

		UTexture* PCteamBeacon = pc->TeamBeaconTexture;
		if ( PCteamBeacon )
		{
			//FLOAT   xscale = Clamp(0.28f * (ScaledDist - actorDist)/ScaledDist,0.1f, 0.25f);
			if ( pc->myHUD && pc->myHUD->PortraitPRI && (pc->myHUD->PortraitPRI ==PlayerReplicationInfo) && pc->SpeakingBeaconTexture )
			{
				teamBeacon = pc->SpeakingBeaconTexture;
				xscale = 3.f * Clamp(0.28f * (ScaledDist - actorDist)/ScaledDist,0.1f, 0.25f);;
			}
			screenLoc.X -= teamBeacon->USize*xscale;
			screenLoc.Y -= 0.5*teamBeacon->VSize*xscale;
			SceneNode->Viewport->Canvas->Style = STY_AlphaZ;

			SceneNode->Viewport->Canvas->DrawTile(
				PCteamBeacon,
				screenLoc.X, 
				screenLoc.Y, 
				PCteamBeacon->USize*xscale,
				PCteamBeacon->VSize*xscale,
				0.f, 
				0.f, 
				PCteamBeacon->USize, 
				PCteamBeacon->VSize,
				0.f,
				color,
				FPlane(0.0f,0.0f,0.0f,0.0f));
		}
		if ( !GIsPixomatic && (actorDist < 2.f*pc->TeamBeaconPlayerInfoMaxDist) && (SceneNode->Viewport->Canvas->ClipX > 600) )
		{
			if ( PlayerReplicationInfo->bBot )
				info +=(PlayerReplicationInfo->eventGetNameCallSign());
			else
 				info +=(PlayerReplicationInfo->PlayerName);
			SceneNode->Viewport->Canvas->ClippedStrLen(
				SceneNode->Viewport->Canvas->SmallFont,
				1.f, 1.f, xL, yL, *info);

			INT index = pc->PlayerNameArray.AddZeroed();
			pc->PlayerNameArray(index).mInfo  = info;
			pc->PlayerNameArray(index).mColor = color;
			pc->PlayerNameArray(index).mXPos  = screenLoc.X;
			pc->PlayerNameArray(index).mYPos  = screenLoc.Y - yL;
		}
	}
	unguard;
}
