class dmhud extends Hudkillingfloor
	config(User);

function PostRender( canvas Canvas )
{
	local float Dist;
	local kfPawn P;
	local int XPos, YPos,f,d,i;
	local Vector X,Y,Z, Dir;



super.postrender(canvas);


Canvas.SetDrawColor(255,255,255);


XPos = 0.0 * Canvas.ClipX;
YPos = 0.9 * Canvas.ClipY;

if ( KFGameType(PlayerOwner.Level.Game)!=none)
	{canvas.setpos(XPos,ypos);
Canvas.Drawtext("Changerace in console to change teams",true);

}


Canvas.SetDrawColor(255,0,0);

	
}
simulated function DrawKFHUDTextElements(Canvas C)
{
	local float    XL, YL;
	local int      NumZombies, Min;
	local string   S;
	local vector   Pos, FixedZPos;
	local rotator  ShopDirPointerRotation;

	if ( PlayerOwner == none || KFGRI == none || !KFGRI.bMatchHasBegun || KFPlayerController(PlayerOwner).bShopping || KFGameType(PlayerOwner.Level.Game)==none)
	{
		return;
	}

	// Countdown Text
	if( !KFGRI.bWaveInProgress )
	{
		C.SetDrawColor(255, 255, 255, 255);
		C.SetPos(C.ClipX - 130, 2);
		C.DrawTile(Material'KillingFloorHUD.HUD.Hud_Bio_Clock_Circle', 128, 128, 0, 0, 256, 256);

		if ( KFGRI.TimeToNextWave <= 5 )
		{
			// Hints
		   	if ( bIsSecondDowntime )
		   	{
				KFPlayerController(PlayerOwner).CheckForHint(40);
			}
		}

		Min = KFGRI.TimeToNextWave / 60;
		NumZombies = KFGRI.TimeToNextWave - (Min * 60);

		S = Eval((Min >= 10), string(Min), "0" $ Min) $ ":" $ Eval((NumZombies >= 10), string(NumZombies), "0" $ NumZombies);
		C.Font = LoadFont(2);
		C.Strlen(S, XL, YL);
		C.SetDrawColor(255, 50, 50, KFHUDAlpha);
		C.SetPos(C.ClipX - 66 - (XL / 2), 66 - YL / 2);
		C.DrawText(S, False);
	}
	else
	{
		//Hints
		if ( KFPlayerController(PlayerOwner) != none )
		{
			KFPlayerController(PlayerOwner).CheckForHint(30);

			if ( !bHint_45_TimeSet && KFGRI.WaveNumber == 1)
			{
				Hint_45_Time = Level.TimeSeconds + 5;
				bHint_45_TimeSet = true;
			}
		}

		C.SetDrawColor(255, 255, 255, 255);
		C.SetPos(C.ClipX - 128, 2);
		C.DrawTile(Material'KillingFloorHUD.HUD.Hud_Bio_Circle', 128, 128, 0, 0, 256, 256);

		S = string(KFGRI.MaxMonsters);
		C.Font = LoadFont(1);
		C.Strlen(S, XL, YL);
		C.SetDrawColor(255, 50, 50, KFHUDAlpha);
		C.SetPos(C.ClipX - 64 - (XL / 2), 66 - (YL / 1.5));
		C.DrawText(S);

		// Show the number of waves
		S = WaveString @ string(KFGRI.WaveNumber + 1) $ "/" $ string(KFGRI.FinalWave);
		C.Font = LoadFont(5);
		C.Strlen(S, XL, YL);
		C.SetPos(C.ClipX - 64 - (XL / 2), 66 + (YL / 2.5));
		C.DrawText(S);

   		//Needed for the hints showing up in the second downtime
		bIsSecondDowntime = true;
	}

	if ( KFPRI == None || KFPRI.bOnlySpectator || KFGRI.CurrentShop == none || PawnOwner == none )
	{
		return;
	}

	// Draw the shop pointer
	if ( ShopDirPointer == None )
	{
		ShopDirPointer = Spawn(Class'KFShopDirectionPointer');
		ShopDirPointer.bHidden = bHideHud;
	}

	Pos.X = C.SizeX / 18.0;
	Pos.Y = C.SizeX / 18.0;
	Pos = PlayerOwner.Player.Console.ScreenToWorld(Pos) * 10.f * (PlayerOwner.default.DefaultFOV / PlayerOwner.FovAngle) + PlayerOwner.CalcViewLocation;
	ShopDirPointer.SetLocation(Pos);

	// Let's check for a real Z difference (i.e. different floor) doesn't make sense to rotate the arrow
	// only because the trader is a midget or placed slightly wrong
	if ( KFGRI.CurrentShop.Location.Z > PawnOwner.Location.Z + 50.f || KFGRI.CurrentShop.Location.Z < PawnOwner.Location.Z - 50.f )
	{
	    ShopDirPointerRotation = rotator(KFGRI.CurrentShop.Location - PawnOwner.Location);
	}
	else
	{
	    FixedZPos = KFGRI.CurrentShop.Location;
	    FixedZPos.Z = PawnOwner.Location.Z;
	    ShopDirPointerRotation = rotator(FixedZPos - PawnOwner.Location);
	}

   	ShopDirPointer.SetRotation(ShopDirPointerRotation);

	if ( Level.TimeSeconds > Hint_45_Time && Level.TimeSeconds < Hint_45_Time + 2 )
	{
		if ( KFPlayerController(PlayerOwner) != none )
		{
			KFPlayerController(PlayerOwner).CheckForHint(45);
		}
	}

	C.DrawActor(None, False, True); // Clear Z.
	ShopDirPointer.bHidden = false;
	C.DrawActor(ShopDirPointer, False, false);
	ShopDirPointer.bHidden = true;
	DrawTraderDistance(C);
}
simulated function DrawHud(Canvas C)
{
	local KFGameReplicationInfo CurrentGame;
	local KFMonster KFEnemy;
	local KFPawn KFBuddy;
	local rotator CamRot;
	local vector CamPos, ViewDir;
	local int i;
	local bool bBloom;

	if ( KFGameType(PlayerOwner.Level.Game) != none )
		CurrentGame = KFGameReplicationInfo(PlayerOwner.Level.GRI);

	if ( FontsPrecached < 2 )
		PrecacheFonts(C);

	UpdateHud();

	PassStyle = STY_Modulated;
	DrawModOverlay(C);

	bBloom = bool(ConsoleCommand("get ini:Engine.Engine.ViewportManager Bloom"));
	if ( bBloom )
	{
		PlayerOwner.PostFX_SetActive(0, true);
	}

	if( bHideHud )
	{
	   return;
	}

	//if( bShowEnemyDebug && class'ROEngine.ROLevelInfo'.static.RODebugMode() )
	//{
		if ( C.ViewPort.Actor.Pawn != none )
		{
			foreach C.ViewPort.Actor.DynamicActors(class'KFMonster',KFEnemy)
			{
				if ( KFEnemy.Health > 0 && !KFEnemy.Cloaked() )
				{
					DrawEnemyInfo(C, KFEnemy, 50.0);
				}
			}
		}
	//}

	//if( bShowBuddyDebug && class'ROEngine.ROLevelInfo'.static.RODebugMode() )
	//{
		if ( C.ViewPort.Actor.Pawn != none )
		{
			foreach C.ViewPort.Actor.DynamicActors(class'KFPawn',KFBuddy)
			{
				if ( KFBuddy.Health > 0 )
				{
					DrawBuddyInfo(C, KFBuddy, 50.0);
				}
			}
		}
	//}

	//if ( !KFPlayerReplicationInfo(PlayerOwner.PlayerReplicationInfo).bViewingMatineeCinematic )
	//{
		if ( bShowTargeting )
			DrawTargeting(C);

		// Grab our View Direction
		C.GetCameraLocation(CamPos,CamRot);
		ViewDir = vector(CamRot);

		// Draw the Name, Health, Armor, and Veterancy above other players
		for ( i = 0; i < PlayerInfoPawns.Length; i++ )
		{
			if ( PlayerInfoPawns[i].Pawn != none && PlayerInfoPawns[i].Pawn.Health > 0 && (PlayerInfoPawns[i].Pawn.Location - PawnOwner.Location) dot ViewDir > 0.8 &&
				 PlayerInfoPawns[i].RendTime > Level.TimeSeconds )
			{
				DrawPlayerInfo(C, PlayerInfoPawns[i].Pawn, PlayerInfoPawns[i].PlayerInfoScreenPosX, PlayerInfoPawns[i].PlayerInfoScreenPosY);
			}
			else
			{
				PlayerInfoPawns.Remove(i--, 1);
			}
		}

		PassStyle = STY_Alpha;
		DrawDamageIndicators(C);
		DrawHudPassA(C);
		DrawHudPassC(C);

		if ( KFPlayerController(PlayerOwner)!= None && KFPlayerController(PlayerOwner).ActiveNote!= None )
		{
			if( PlayerOwner.Pawn == none )
				KFPlayerController(PlayerOwner).ActiveNote = None;
			else KFPlayerController(PlayerOwner).ActiveNote.RenderNote(C);
		}

		PassStyle = STY_None;
		DisplayLocalMessages(C);
		DrawWeaponName(C);
		DrawVehicleName(C);

		PassStyle = STY_Modulated;

		if ( KFGameReplicationInfo(Level.GRI)!= None && KFGameReplicationInfo(Level.GRI).EndGameType > 0 )
		{
			if ( KFGameReplicationInfo(Level.GRI).EndGameType == 2 )
			{
				DrawEndGameHUD(C, True);
				Return;
			}
			else
			{
				DrawEndGameHUD(C, False);
			}
		}

		DrawKFHUDTextElements(C);
	//}

	if ( KFPlayerReplicationInfo(PlayerOwner.PlayerReplicationInfo).bViewingMatineeCinematic )
	{
		PassStyle = STY_Alpha;
		DrawCinematicHUD(C);
	}

	if ( bShowNotification )
	{
		DrawPopupNotification(C);
	}
}
function DrawPlayerInfo(Canvas C, Pawn P, float ScreenLocX, float ScreenLocY)
{
	local float XL, YL, TempX, TempY, TempSize;
	local string PlayerName;
	local float Dist, OffsetX;
	local byte BeaconAlpha;
	local float OldZ;
	local Material TempMaterial;
	local int i;

	if ( kfgametype(level.game)==none&& P.PlayerReplicationInfo.team.teamindex != playerowner.playerreplicationinfo.team.teamindex)
	{
		return;
	}

	Dist = vsize(P.Location - PlayerOwner.CalcViewLocation);
	Dist -= HealthBarFullVisDist;
	Dist = FClamp(Dist, 0, HealthBarCutoffDist-HealthBarFullVisDist);
	Dist = Dist / (HealthBarCutoffDist - HealthBarFullVisDist);
	BeaconAlpha = byte((1.f - Dist) * 255.f);

	if ( BeaconAlpha == 0 )
	{
		return;
	}

	OldZ = C.Z;
	C.Z = 1.0;
	C.Style = ERenderStyle.STY_Alpha;
	C.SetDrawColor(255, 255, 255, BeaconAlpha);
	C.Font = GetConsoleFont(C);
	PlayerName = Left(P.PlayerReplicationInfo.PlayerName, 16);
	C.StrLen(PlayerName, XL, YL);
	C.SetPos(ScreenLocX - (XL * 0.5), ScreenLocY - (YL * 0.75));
	C.DrawTextClipped(PlayerName);

	OffsetX = (36.f * VeterancyMatScaleFactor * 0.6) - (HealthIconSize + 2.0);

	/*if ( KFPlayerReplicationInfo(P.PlayerReplicationInfo).ClientVeteranSkill != none &&
		 KFPlayerReplicationInfo(P.PlayerReplicationInfo).ClientVeteranSkill.default.OnHUDIcon != none )
	{
		TempMaterial = KFPlayerReplicationInfo(P.PlayerReplicationInfo).ClientVeteranSkill.default.OnHUDIcon;

		TempSize = 36.f * VeterancyMatScaleFactor;
		TempX = ScreenLocX + ((BarLength + HealthIconSize) * 0.5) - (TempSize * 0.25) - OffsetX;
		TempY = ScreenLocY - YL - (TempSize * 0.75);

		C.SetPos(TempX, TempY);
		C.DrawTile(TempMaterial, TempSize, TempSize, 0, 0, TempMaterial.MaterialUSize(), TempMaterial.MaterialVSize());

		TempX += (TempSize - (VetStarSize * 0.75));
		TempY += (TempSize - (VetStarSize * 1.5));

		for ( i = 0; i < KFPlayerReplicationInfo(P.PlayerReplicationInfo).ClientVeteranSkillLevel; i++ )
		{
			C.SetPos(TempX, TempY);
			C.DrawTile(VetStarMaterial, VetStarSize * 0.7, VetStarSize * 0.7, 0, 0, VetStarMaterial.MaterialUSize(), VetStarMaterial.MaterialVSize());

			TempY -= VetStarSize * 0.7;
		}
	}*/

	// Health
	if ( P.Health > 0 )
		DrawKFBar(C, ScreenLocX - OffsetX, (ScreenLocY - YL) - 0.4 * BarHeight, FClamp(P.Health / P.HealthMax, 0, 1), BeaconAlpha);

	// Armor
	if ( P.ShieldStrength > 0 )
		DrawKFBar(C, ScreenLocX - OffsetX, (ScreenLocY - YL) - 1.5 * BarHeight, FClamp(P.ShieldStrength / 100.f, 0, 1), BeaconAlpha, true);

	C.Z = OldZ;
}
simulated function DrawModOverlay( Canvas C )
{
	local float MaxRBrighten, MaxGBrighten, MaxBBrighten;

	C.SetPos(0, 0);

	// We want the overlay to start black, and fade in, almost like the player opened their eyes
	// BrightFactor = 1.5;   // Not too bright.  Not too dark.  Livens things up just abit
	// Hook for Optional Vision overlay.  - Alex
	if ( VisionOverlay != none )
	{
		if( PlayerOwner == none || PlayerOwner.PlayerReplicationInfo == none )
		{
			return;
		}

		// if critical, pulsate.  otherwise, dont.
		if ( PlayerOwner.Pawn != none && PlayerOwner.Pawn.Health > 0 )
		{
			if ( PlayerOwner.pawn.Health < PlayerOwner.pawn.HealthMax * 0.25 )
			{
				VisionOverlay = NearDeathOverlay;
			}
			else if ( kfpawn(playerowner.pawn)!=none&&KFPawn(PlayerOwner.pawn).BurnDown > 0 )
			{
				//Chris: disabled for now, can't see shit in single or listen server
				//VisionOverlay = FireOverlay;
			}
			else
			{
				VisionOverlay = default.VisionOverlay;
			}
		}

		// Dead Players see Red
		if( PlayerOwner.PlayerReplicationInfo.bOutOfLives || PlayerOwner.PlayerReplicationInfo.bIsSpectator )
		{
/*			if( !bDisplayDeathScreen )
			{
				Return;
			}
			if ( PlayerOwner.ViewTarget != GoalTarget || GoalTarget == None )
			{
				bDisplayDeathScreen = False;
			}

*/			C.SetDrawColor(255, 255, 255, GrainAlpha);
			//C.DrawTile(SpectatorOverlay, C.SizeX, C.SizeY, 0, 0, 1024, 1024);
			return;
		}
		// So Do Lobby players
/*		else if ( CurrentZone == none && PlayerOwner.PlayerReplicationInfo.bWaitingPlayer )
		{
			C.SetDrawColor(255, 255, 255, GrainAlpha);
			C.DrawTile(GhostMat, C.SizeX, C.SizeY, 0, 0, 1024, 1024);
		}
*/
		// Hook for fade in from black at the start.
		if ( !bInitialDark && PlayerOwner.PlayerReplicationInfo.bReadyToPlay )
		{
			C.SetDrawColor(0, 0, 0, 255);
			C.DrawTile(VisionOverlay, C.SizeX, C.SizeY, 0, 0, 1024, 1024);
			bInitialDark = true;
			return;
		}

		// Players can choose to turn this feature off completely.
		// conversely, setting bDistanceFog = false in a Zone
		//will cause the code to ignore that zone for a shift in RGB tint
		if ( KFLevelRule != none && !KFLevelRule.bUseVisionOverlay )
		{
			return;
		}

		// here we determine the maximum "brighten" amounts for each value.  CANNOT exceed 255
		MaxRBrighten = Round(LastR* (1.0 - (LastR / 255)) - 2) ;
		MaxGBrighten = Round(LastG* (1.0 - (LastG / 255)) - 2) ;
		MaxBBrighten = Round(LastB* (1.0 - (LastB / 255)) - 2) ;

		C.SetDrawColor(LastR + MaxRBrighten, LastG + MaxGBrighten, LastB + MaxBBrighten, GrainAlpha);
		C.DrawTileScaled(VisionOverlay, C.SizeX, C.SizeY);  //,0,0,1024,1024);

		/*
				// Added Canvas Modulation
				C.ColorModulate.X = LastR;  //R
				C.ColorModulate.Y = LastG;  //G
				C.ColorModulate.Z = LastB;  //B
				*/

		// Here we change over the Zone.
		// What happens of importance is
		// A.  Set Old Zone to current
		// B.  Set New Zone
		// C.  Set Color info up for use by Tick()

		// if we're in a new zone or volume without distance fog...just , dont touch anything.
		// the physicsvolume check is abit screwy because the player is always in a volume called "DefaultPhyicsVolume"
		// so we've gotta make sure that the return checks take this into consideration.

		if ( PlayerOwner != none && PlayerOwner.Pawn != none )
		{
			// This block of code here just makes sure that if we've already got a tint, and we step into a zone/volume without
			// bDistanceFog, our current tint is not affected.
			// a.  If I'm in a zone and its not bDistanceFog. AND IM NOT IN A PHYSICSVOLUME. Just a zone.
			// b.  If I'm in a Volume
			if ( PlayerOwner.PlayerReplicationInfo.PlayerZone != none && !PlayerOwner.PlayerReplicationInfo.PlayerZone.bDistanceFog &&
				 PlayerOwner.PlayerReplicationInfo.PlayerVolume == none || DefaultPhysicsVolume(PlayerOwner.pawn.PhysicsVolume)==None &&
				 !PlayerOwner.pawn.PhysicsVolume.bDistanceFog )
			{
				return;
			}
		}

		if ( PlayerOwner != none && !bZoneChanged && PlayerOwner.Pawn != none )
		{
			// Grab the most recent zone info from our PRI
			// Only update if it's different
			// EDIT:  AND HAS bDISTANCEFOG true
			if ( CurrentZone != PlayerOwner.PlayerReplicationInfo.PlayerZone || DefaultPhysicsVolume(PlayerOwner.pawn.PhysicsVolume) == None &&
				 CurrentVolume != PlayerOwner.pawn.PhysicsVolume )
			{
				if ( CurrentZone != none )
				{
				    LastZone = CurrentZone;
				}
				else if ( CurrentVolume != none )
				{
					LastVolume = CurrentVolume;
				}

				// This is for all occasions where we're either in a Levelinfo handled zone
				// Or a zoneinfo.
				// If we're in a LevelInfo / ZoneInfo  and NOT touching a Volume.  Set current Zone
				if ( PlayerOwner.PlayerReplicationInfo.PlayerZone != none && PlayerOwner.PlayerReplicationInfo.PlayerZone.bDistanceFog &&
					 DefaultPhysicsVolume(PlayerOwner.pawn.PhysicsVolume)!= none && !PlayerOwner.PlayerReplicationInfo.PlayerZone.bNoKFColorCorrection )
				{
					CurrentVolume = none;
					CurrentZone = PlayerOwner.PlayerReplicationInfo.PlayerZone;
				}
				else if ( DefaultPhysicsVolume(PlayerOwner.pawn.PhysicsVolume) == None && PlayerOwner.pawn.PhysicsVolume.bDistanceFog &&
					!PlayerOwner.pawn.PhysicsVolume.bNoKFColorCorrection)
				{
					CurrentZone = none;
					CurrentVolume = PlayerOwner.pawn.PhysicsVolume;
				}

				if ( CurrentVolume != none )
				{
					LastZone = none;
				}
				else if ( CurrentZone != none )
				{
					LastVolume = none;
				}

				if ( LastZone != none )
				{
					LastR = LastZone.DistanceFogColor.R;
					LastG = LastZone.DistanceFogColor.G;
					LastB = LastZone.DistanceFogColor.B;
				}
				else if ( LastVolume != none )
				{
					LastR = LastVolume.DistanceFogColor.R;
					LastG = LastVolume.DistanceFogColor.G;
					LastB = LastVolume.DistanceFogColor.B;
				}
				else if ( LastZone != none && LastVolume != none )
				{
					return;
				}

				if ( LastZone != CurrentZone || LastVolume != CurrentVolume )
				{
					bZoneChanged = true;
					SetTimer(OverlayFadeSpeed, false);
				}
			}
		}
		if ( !bTicksTurn && bZoneChanged )
		{
			// Pass it off to the tick now
			// valueCheckout signifies that none of the three values have been
			// altered by Tick() yet.

			// BOUNCE IT BACK! :D
			ValueCheckOut = 0;
			bTicksTurn = true;
			SetTimer(OverlayFadeSpeed, false);
		}
	}
}

defaultproperties
{
}
