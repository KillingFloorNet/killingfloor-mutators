/*=============================================================================
	UnPawn.cpp: APawn AI implementation
	Copyright 1997-2002 Epic MegaGames, Inc. This software is a trade secret.
=============================================================================*/

void APawn::PostRender(FLevelSceneNode* SceneNode, FRenderInterface* RI)
{
	guard(APawn::PostRender);

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

    if ( bNoTeamBeacon 
		|| ((SceneNode->Viewport->Actor->ViewTarget == this) && (SceneNode->Viewport->Actor->Pawn == this))
		|| ((SceneNode->Viewport->Actor->ViewTarget == DrivenVehicle) && (SceneNode->Viewport->Actor->Pawn == DrivenVehicle)) )
        return;

    APlayerController* pc = SceneNode->Viewport->Actor;
	UBOOL bSpectating = pc->PlayerReplicationInfo ? (pc->PlayerReplicationInfo->bOnlySpectator && !pc->bHideSpectatorBeacons) : false;

    int playerTeamIndex   = -1;

	if ( !bSpectating )
	{
		if (pc->PlayerReplicationInfo && pc->PlayerReplicationInfo->Team)
			playerTeamIndex = pc->PlayerReplicationInfo->Team->TeamIndex;

		if (playerTeamIndex < 0 || playerTeamIndex > 1)
			return;
	}
    int teamIndex = -1;

	APlayerReplicationInfo *MyPRI = PlayerReplicationInfo;
	if ( !MyPRI && DrivenVehicle )
		MyPRI = DrivenVehicle->PlayerReplicationInfo;
	if (MyPRI && MyPRI->Team)
		teamIndex = MyPRI->Team->TeamIndex;
	else if ( DrivenVehicle )
		teamIndex = DrivenVehicle->Team;

	if ( teamIndex == -1 )
		return;
	if ( !bSpectating && (teamIndex != playerTeamIndex) )
		return;
    UTexture* teamBeacon = pc->TeamBeaconTexture;

    if ( !teamBeacon )
        return;

	FVector ActorScreenLoc = SceneNode->WorldToScreen.TransformFVector(Location);
    FLOAT actorDist = pc->FOVBias * ActorScreenLoc.Z;
	FLOAT ScaledDist = pc->TeamBeaconMaxDist * ::Clamp(0.04f * CollisionRadius,1.f,2.f);

	if ( actorDist < 0.f )
		return;

	if ( actorDist > ScaledDist )
	{
		if ( actorDist > 2.f * ScaledDist )
			return;
		ActorScreenLoc.Z = 0.f;
		if ( ActorScreenLoc.SizeSquared() > 0.02f * actorDist * actorDist )
			return;
	}

    if (!pc->LineOfSightTo(this))
        return;

    FPlane color = (teamIndex == 0) ? FPlane(1.f,0.25f,0.25f,1.f) : FPlane(0.25f,0.35f,1.f,1.f);
	if ( teamIndex > 1 )
		color = (teamIndex == 2) ? FPlane(0.f,1.f,0.25f,1.f) : FPlane(1.f,1.f,0.f,1.f);
	// look for matching attachment
	FLOAT   xscale = Clamp(0.28f * (ScaledDist - actorDist)/ScaledDist,0.1f, 0.25f);

	if ( !DrivenVehicle && !bSpectating && pc->LinkBeaconTexture )
	{
		for ( INT i=0; i<Attached.Num(); i++ )
		{
			AWeaponAttachment* AttachedWeapon = Cast<AWeaponAttachment>(Attached(i));
			if ( AttachedWeapon && AttachedWeapon->bMatchWeapons )
			{
				teamBeacon = pc->LinkBeaconTexture;
				color = AttachedWeapon->BeaconColor;
				break;
			}
		}
	}
	if ( pc->myHUD && pc->myHUD->PortraitPRI && (pc->myHUD->PortraitPRI ==PlayerReplicationInfo) && pc->SpeakingBeaconTexture )
	{
		teamBeacon = pc->SpeakingBeaconTexture;
		xscale *= 3.f;
	}

	FLOAT farAwayInv = 1.f/pc->TeamBeaconPlayerInfoMaxDist;
    FLOAT height = CollisionHeight * Clamp(0.85f + actorDist * 0.85f * farAwayInv, 1.1f, 1.75f);
    FVector camLoc = SceneNode->WorldToCamera.TransformFVector(Location+FVector(0.0f,0.0f,height));

	FPlane  screenLoc = SceneNode->Project(SceneNode->CameraToWorld.TransformFVector(camLoc));

    screenLoc.X = (SceneNode->Viewport->Canvas->ClipX * 0.5f * (screenLoc.X + 1.f)) - 0.5*teamBeacon->USize*xscale;
    screenLoc.Y = (SceneNode->Viewport->Canvas->ClipY * 0.5f * (-screenLoc.Y + 1.f)) - 0.5*teamBeacon->VSize*xscale;
    SceneNode->Viewport->Canvas->Style = STY_AlphaZ;

	SceneNode->Viewport->Canvas->DrawTile(
		teamBeacon,
		screenLoc.X, 
		screenLoc.Y, 
		teamBeacon->USize*xscale,
		teamBeacon->VSize*xscale,
		0.f, 
		0.f, 
		teamBeacon->USize, 
		teamBeacon->VSize,
		0.f,
		color,
		FPlane(0.0f,0.0f,0.0f,0.0f));

	if ( !GIsPixomatic && (actorDist < pc->TeamBeaconPlayerInfoMaxDist) && (SceneNode->Viewport->Canvas->ClipX > 600) )
    {
        FLOAT xL, yL;
		FString info;
		if ( MyPRI )
		{
			if ( MyPRI->bBot )
				info +=(MyPRI->eventGetNameCallSign());
			else
 				info +=(MyPRI->PlayerName);
		}
       info += TEXT(" (");
		info += appItoa(Health);
        info += TEXT(")");
        SceneNode->Viewport->Canvas->ClippedStrLen(
            SceneNode->Viewport->Canvas->SmallFont,
            1.f, 1.f, xL, yL, *info);

        INT index = pc->PlayerNameArray.AddZeroed();
        pc->PlayerNameArray(index).mInfo  = info;
        pc->PlayerNameArray(index).mColor = color;
        pc->PlayerNameArray(index).mXPos  = screenLoc.X;
        pc->PlayerNameArray(index).mYPos  = screenLoc.Y - yL;
    }
	unguard;
}

void APawn::UpdateMovementAnimation( FLOAT DeltaSeconds )
{
	guard(APawn::UpdateMovementAnimation);

    if ( Level->NetMode == NM_DedicatedServer )
		return;

    if( bPlayedDeath )
        return;

    if (Level->TimeSeconds - LastRenderTime > 1.0)
    {
        FootRot = Rotation.Yaw;
        FootTurning = false;
        FootStill = false;
        return;
    }

	Mesh->MeshGetInstance(this);
    if (MeshInstance == NULL)
        return;

    BaseEyeHeight = ((APawn *)(GetClass()->GetDefaultActor()))->BaseEyeHeight;

    if ( bIsIdle && Physics != OldPhysics )
    {
        bWaitForAnim = false;
    }

    if ( !bWaitForAnim )
    {
        if ( Physics == PHYS_Swimming )
	    {
            BaseEyeHeight *= 0.7f;
            UpdateSwimming();
	    }
        else if ( Physics == PHYS_Falling || Physics == PHYS_Flying )
        {
            BaseEyeHeight *= 0.7f;
            UpdateInAir();
        }
        else if ( Physics == PHYS_Walking || Physics == PHYS_Ladder || Physics == PHYS_Spider )
        {
            UpdateOnGround();
        }
    }
	else if ( !IsAnimating(0) )
		bWaitForAnim = false;
    
    if ( Physics != PHYS_Walking )
        bIsIdle = false;

    OldPhysics = Physics;
    OldVelocity = Velocity;

    if (bDoTorsoTwist)
        UpdateTwistLook( DeltaSeconds );

    unguard;
}

void APawn::UpdateSwimming( void )
{
    if ( (Velocity.X*Velocity.X + Velocity.Y*Velocity.Y) < 2500.0f )
        PlayAnim(0, IdleSwimAnim, 1.0f, 0.1f, true);
    else
	    PlayAnim(0, SwimAnims[Get4WayDirection()], 1.0f, 0.1f, true);
}

void APawn::UpdateInAir( void )
{
	FName NewAnim;
    bool bUp, bDodge;
    float DodgeSpeedThresh;
    int Dir;
    float XYVelocitySquared;

    XYVelocitySquared = (Velocity.X*Velocity.X)+(Velocity.Y*Velocity.Y);

    bDodge = false;
    if ( OldPhysics == PHYS_Walking )
    {
        DodgeSpeedThresh = ((GroundSpeed*DodgeSpeedFactor) + GroundSpeed) * 0.5f;
        if ( XYVelocitySquared > DodgeSpeedThresh*DodgeSpeedThresh )
        {
            bDodge = true;
        }
    }

    bUp = (Velocity.Z >= 0.0f);

    if (XYVelocitySquared >= 20000.0f)
    {
        Dir = Get4WayDirection();

        if (bDodge)
        {
            NewAnim = DodgeAnims[Dir];
            bWaitForAnim = true;
        }
        else if (bUp)
        {
            NewAnim = TakeoffAnims[Dir];
        }
        else
        {
            NewAnim = AirAnims[Dir];
        }
    }
    else
    {
        if (bUp)
        {
            NewAnim = TakeoffStillAnim;
        }
        else
        {
            NewAnim = AirStillAnim;
        }
    }

	if ( NewAnim != MeshInstance->GetActiveAnimSequence(0) )
    {
		if ( PhysicsVolume->Gravity.Z > 0.8f * (Cast<APhysicsVolume>(PhysicsVolume->GetClass()->GetDefaultActor()))->Gravity.Z )
    		PlayAnim(0, NewAnim, 0.5f, 0.2f, false);
		else
    		PlayAnim(0, NewAnim, 1.0f, 0.1f, false);
    }
}

void APawn::UpdateOnGround( void )
{
    // just landed
    if ( OldPhysics == PHYS_Falling || OldPhysics == PHYS_Flying )
    {
        PlayLand();
    }
    // standing still
    else if ( Velocity.SizeSquared() < 2500.0f /*&& Acceleration.SizeSquared() < 0.01f*/ )
    {
        if (!bIsIdle || FootTurning || bIsCrouched != bWasCrouched)
        {
            IdleTime = Level->TimeSeconds;
            PlayIdle();
        }
        bWasCrouched = bIsCrouched;
        bIsIdle = true;
    }
    // running
    else
    {
        if ( bIsIdle  )
            bWaitForAnim = false;

        PlayRunning();
        bIsIdle = false;
    }
}

void APawn::PlayIdle( void )
{
    if (FootTurning)
    {
        if (TurnDir == 1)
        {
            if (bIsCrouched)
    		    PlayAnim(0, CrouchTurnRightAnim, 1.0f, 0.1f, true);
            else
    		    PlayAnim(0, TurnRightAnim, 1.0f, 0.1f, true);
        }
        else
        {
            if (bIsCrouched)
    		    PlayAnim(0, CrouchTurnLeftAnim, 1.0f, 0.1f, true);
            else
        	    PlayAnim(0, TurnLeftAnim, 1.0f, 0.1f, true);
        }
    }
    else
    {
        if (bIsCrouched)
        {
            PlayAnim(0, IdleCrouchAnim, 1.0f, 0.1f, true);
        }
        else
        {
			if ( bIsTyping )
	            PlayAnim(0, IdleChatAnim, 1.0f, 0.2f, true);
            else if (Level->TimeSeconds - IdleTime < 5.0f && IdleWeaponAnim != NAME_None)
            {
                PlayAnim(0, IdleWeaponAnim, 1.0f, 0.25f, true);
            }
            else
            {
	            PlayAnim(0, IdleRestAnim, 1.0f, 0.25f, true);
            }
        }
    }
}

void APawn::PlayRunning( void )
{
	FName NewAnim;
    int NewAnimDir;
    float AnimSpeed;

    NewAnimDir = Get4WayDirection();

    AnimSpeed = 1.1f * ((APawn *)(GetClass()->GetDefaultActor()))->GroundSpeed;
    if (bIsCrouched)
    {
        NewAnim = CrouchAnims[NewAnimDir];
        AnimSpeed *= CrouchedPct;
    }
    else if (bIsWalking)
    {
        NewAnim = WalkAnims[NewAnimDir];
        AnimSpeed *= WalkingPct;
    }
    else
    {
        NewAnim = MovementAnims[NewAnimDir];
    }

    PlayAnim(0, NewAnim, Velocity.Size() / AnimSpeed, 0.1f, true);
    OldAnimDir = NewAnimDir;
}

void APawn::PlayLand( void )
{
    if (!bIsCrouched)
    {
        PlayAnim(0, LandAnims[Get4WayDirection()], 1.0f, 0.1f, false);
        bWaitForAnim = true;
    }
}


void APawn::execGet4WayDirection( FFrame& Stack, RESULT_DECL )
{
	guardSlow(AActor::execGet4WayDirection);
	P_FINISH;
    *(int*)Result = Get4WayDirection();
    unguardSlow;
}

int APawn::Get4WayDirection( void )
{
    float forward, right;
    FVector V;
    int dir;

    V = Velocity;
    V.Z = 0.0f;

    if ( V.IsNearlyZero() )
		return 0;

	FCoords Coords = GMath.UnitCoords / Rotation;
    V.Normalize();
    forward = Coords.XAxis | V;
    if (forward > 0.82f) // 55 degrees
        dir = 0;
    else if (forward < -0.82f)
        dir = 1;
    else
    {
        right = Coords.YAxis | V;
        if (right > 0.0f)
            dir = 3;
        else
            dir = 2;
    }
	return dir;
}


// ----- torso twisting ----- //

void APawn::execSetTwistLook( FFrame& Stack, RESULT_DECL )
{
	P_GET_INT(twist);
	P_GET_INT(look);
	P_FINISH;
    SetTwistLook(twist, look);
}

void APawn::SetTwistLook( int twist, int look )
{
    if (!bDoTorsoTwist)
        return;

	FRotator r(0,-twist + SmoothViewYaw - Rotation.Yaw,0);
    MeshInstance->SetBoneRotation(RootBone, r, 0, 1.0f);

    r.Yaw = -twist / 3;
    r.Pitch = 0;
    r.Roll = look / 4;
    ((USkeletalMeshInstance*)MeshInstance)->SetBoneDirection(HeadBone, r, FVector(0.0f,0.0f,0.0f), 1.0f, 0);
    ((USkeletalMeshInstance*)MeshInstance)->SetBoneDirection(SpineBone1, r, FVector(0.0f,0.0f,0.0f), 1.0f, 0);
    ((USkeletalMeshInstance*)MeshInstance)->SetBoneDirection(SpineBone2, r, FVector(0.0f,0.0f,0.0f), 1.0f, 0);
}

void APawn::UpdateTwistLook( float DeltaTime )
{
    if ( !bDoTorsoTwist || (Level->TimeSeconds - LastRenderTime > 0.5f) )
    {
		SmoothViewPitch = ViewPitch;
		SmoothViewYaw = Rotation.Yaw;
        FootRot = Rotation.Yaw;
        FootTurning = false;
        FootStill = false;
    }
    else
    {
 		INT YawDiff = (Rotation.Yaw - SmoothViewYaw) & 65535;
		if ( YawDiff != 0 )
		{
			if ( YawDiff > 32768 )
				YawDiff -= 65536;

			INT Update = INT(YawDiff * 15.f * DeltaTime);
			if ( Abs(YawDiff) > 12000 )
			{
				if ( YawDiff > 12000 )
				{
					SmoothViewYaw = SmoothViewYaw + YawDiff - 12000;
					YawDiff = 12000;
				}
				else
				{
					SmoothViewYaw = SmoothViewYaw + YawDiff + 12000;
					YawDiff = -12000;
				}
			}
			if ( Update == 0 )
				Update = (YawDiff > 0) ? 1 : -1;
			SmoothViewYaw = (SmoothViewYaw + Update) & 65535;
		}
		INT t = (SmoothViewYaw - FootRot) & 65535;
        if (t > 32768) 
			t -= 65536;
        
        if ((Velocity.X * Velocity.X + Velocity.Y * Velocity.Y) < 1000 && Physics == PHYS_Walking)
        {
            if (!FootStill)
            {
                FootStill = true;
				SmoothViewYaw = Rotation.Yaw;
                FootRot = Rotation.Yaw;
				t = 0;
            }
        }
        else
        {
            if (FootStill)
            {
                FootStill = false;
                FootTurning = true;
            }
        }

        if (FootTurning)
        {
           if (t > 10000)
            {
                FootRot = SmoothViewYaw - 10000;
                t = 10000;
            }
            else if (t > 2048)
            {
                FootRot += 16384*DeltaTime;
            }
            else if (t < -10000)
            {
                FootRot = SmoothViewYaw + 10000;
                t = -10000;
            }
            else if (t < -2048)
            {
                FootRot -= 16384*DeltaTime;
            }
            else
            {
                if (!FootStill)
                    t = 0;
                FootTurning = false;
            }
            FootRot = FootRot & 65535;
        }
        else if (FootStill)
        {
            if (t > 10923)
            {
                TurnDir = 1;
                FootTurning = true;
            }
            else if (t < -10923)
            {
                TurnDir = -1;
                FootTurning = true;
            }
        }
        else
        {
            t = 0;
        }
		INT PitchDiff = (256*ViewPitch - SmoothViewPitch) & 65535;
		if ( PitchDiff != 0 )
		{
			if ( PitchDiff > 32768 )
				PitchDiff -= 65536;

			INT Update = INT(PitchDiff * 5.f * DeltaTime);
			if ( Update == 0 )
				Update = (PitchDiff > 0) ? 1 : -1;
			SmoothViewPitch = (SmoothViewPitch + Update) & 65535;
		}
		INT look = SmoothViewPitch;
        if (look > 32768) 
			look -= 65536;
        SetTwistLook(t, look);
    }
}
