class MHHUDKillingFloor extends HUDKillingFloor;

var bool bRandomItemSpawnMechanism,bTeamGame,bBossesHealthBar;

/*
simulated function PostBeginPlay()
{
	super.postBeginPlay();
	ShopDirPointer.bHidden = true;
}

exec function ShowHud()
{
	super.showHud();
	ShopDirPointer.bHidden = true;
}
*/

simulated function DrawKFHUDTextElements(Canvas C)
{
	local float    XL, YL;
	local string   S;
	local KFMonster KFEnemy;

	if ( PlayerOwner == none || KFGRI == none || !KFGRI.bMatchHasBegun || KFPlayerController(PlayerOwner).bShopping )
	{
		return;
	}

	if(bBossesHealthBar)
		foreach C.ViewPort.Actor.DynamicActors(class'KFMonster',KFEnemy)
			if ( KFEnemy.HealthMax > 1000 && KFEnemy.Health > 0 && !KFEnemy.Cloaked() && VSizeSquared(KFEnemy.Location - C.ViewPort.Actor.Pawn.Location) < 640000 )
				DrawHealthBar(C, KFEnemy, KFEnemy.Health, KFEnemy.HealthMax , 50.0);

	if( !bRandomItemSpawnMechanism )
	{
		super.DrawKFHUDTextElements( c );
		return;
	}

	// Countdown Text
	if( KFGRI.bWaveInProgress && KFGRI.WaveNumber + 1 == KFGRI.FinalWave && KFGRI.MaxMonsters <= 50 )
	{
		C.SetDrawColor(255, 255, 255, 255);
		C.SetPos(C.ClipX - 128, 2);
		C.DrawTile(Material'KillingFloorHUD.HUD.Hud_Bio_Circle', 128, 128, 0, 0, 256, 256);

		S = string(KFGRI.MaxMonsters);
		C.Font = LoadFont(1);
		C.Strlen(S, XL, YL);
		C.SetDrawColor(255, 50, 50, KFHUDAlpha);
		C.SetPos(C.ClipX - 64 - (XL / 2), 66 - (YL / 1.5));
		C.DrawText(S);
	}
}

simulated function DrawHudPassA (Canvas C)
{
	local KFHumanPawn KFHPawn;
	local Material TempMaterial, TempStarMaterial;
	local int i, TempLevel;
	local float TempX, TempY, TempSize;

	if( !bRandomItemSpawnMechanism )
	{
		super.DrawHudPassA( c );
		return;
	}

	KFHPawn = KFHumanPawn(PawnOwner);

	DrawDoorHealthBars(C);

	if ( !bLightHud )
	{
		DrawSpriteWidget(C, HealthBG);
	}

	DrawSpriteWidget(C, HealthIcon);
	DrawNumericWidget(C, HealthDigits, DigitsSmall);

	if ( !bLightHud )
	{
		DrawSpriteWidget(C, ArmorBG);
	}

	DrawSpriteWidget(C, ArmorIcon);
	DrawNumericWidget(C, ArmorDigits, DigitsSmall);

	if ( KFHPawn != none )
	{
		C.SetPos(C.ClipX * WeightBG.PosX, C.ClipY * WeightBG.PosY);

		if ( !bLightHud )
		{
			C.DrawTile(WeightBG.WidgetTexture, WeightBG.WidgetTexture.MaterialUSize() * WeightBG.TextureScale * 1.5 * HudCanvasScale * ResScaleX * HudScale, WeightBG.WidgetTexture.MaterialVSize() * WeightBG.TextureScale * HudCanvasScale * ResScaleY * HudScale, 0, 0, WeightBG.WidgetTexture.MaterialUSize(), WeightBG.WidgetTexture.MaterialVSize());
		}

		DrawSpriteWidget(C, WeightIcon);

		C.Font = LoadSmallFontStatic(5);
		C.FontScaleX = C.ClipX / 1024.0;
		C.FontScaleY = C.FontScaleX;
		C.SetPos(C.ClipX * WeightDigits.PosX, C.ClipY * WeightDigits.PosY);
		C.DrawColor = WeightDigits.Tints[0];
		C.DrawText(int(KFHPawn.CurrentWeight)$"/"$int(KFHPawn.MaxCarryWeight));
		C.FontScaleX = 1;
		C.FontScaleY = 1;
	}

	if ( !bLightHud )
	{
		DrawSpriteWidget(C, GrenadeBG);
	}

	DrawSpriteWidget(C, GrenadeIcon);
	DrawNumericWidget(C, GrenadeDigits, DigitsSmall);

	if ( PawnOwner != none && PawnOwner.Weapon != none )
	{
		if ( Syringe(PawnOwner.Weapon) != none )
		{
			if ( !bLightHud )
			{
				DrawSpriteWidget(C, SyringeBG);
			}

			DrawSpriteWidget(C, SyringeIcon);
			DrawNumericWidget(C, SyringeDigits, DigitsSmall);
		}
		else
		{
			if ( bDisplayQuickSyringe )
			{
				TempSize = Level.TimeSeconds - QuickSyringeStartTime;
				if ( TempSize < QuickSyringeDisplayTime )
				{
					if ( TempSize < QuickSyringeFadeInTime )
					{
						QuickSyringeBG.Tints[0].A = int((TempSize / QuickSyringeFadeInTime) * 255.0);
						QuickSyringeBG.Tints[1].A = QuickSyringeBG.Tints[0].A;
						QuickSyringeIcon.Tints[0].A = QuickSyringeBG.Tints[0].A;
						QuickSyringeIcon.Tints[1].A = QuickSyringeBG.Tints[0].A;
						QuickSyringeDigits.Tints[0].A = QuickSyringeBG.Tints[0].A;
						QuickSyringeDigits.Tints[1].A = QuickSyringeBG.Tints[0].A;
					}
					else if ( TempSize > QuickSyringeDisplayTime - QuickSyringeFadeOutTime )
					{
						QuickSyringeBG.Tints[0].A = int((1.0 - ((TempSize - (QuickSyringeDisplayTime - QuickSyringeFadeOutTime)) / QuickSyringeFadeOutTime)) * 255.0);
						QuickSyringeBG.Tints[1].A = QuickSyringeBG.Tints[0].A;
						QuickSyringeIcon.Tints[0].A = QuickSyringeBG.Tints[0].A;
						QuickSyringeIcon.Tints[1].A = QuickSyringeBG.Tints[0].A;
						QuickSyringeDigits.Tints[0].A = QuickSyringeBG.Tints[0].A;
						QuickSyringeDigits.Tints[1].A = QuickSyringeBG.Tints[0].A;
					}
					else
					{
						QuickSyringeBG.Tints[0].A = 255;
						QuickSyringeBG.Tints[1].A = 255;
						QuickSyringeIcon.Tints[0].A = 255;
						QuickSyringeIcon.Tints[1].A = 255;
						QuickSyringeDigits.Tints[0].A = 255;
						QuickSyringeDigits.Tints[1].A = 255;
					}

					if ( !bLightHud )
					{
						DrawSpriteWidget(C, QuickSyringeBG);
					}

					DrawSpriteWidget(C, QuickSyringeIcon);
					DrawNumericWidget(C, QuickSyringeDigits, DigitsSmall);
				}
				else
				{
					bDisplayQuickSyringe = false;
				}
			}

			if ( MP7MMedicGun(PawnOwner.Weapon) != none )
			{

				MedicGunDigits.Value = MP7MMedicGun(PawnOwner.Weapon).ChargeBar() * 100;

				if ( MedicGunDigits.Value < 50 )
				{
					MedicGunDigits.Tints[0].R = 128;
					MedicGunDigits.Tints[0].G = 128;
					MedicGunDigits.Tints[0].B = 128;

					MedicGunDigits.Tints[1] = SyringeDigits.Tints[0];
				}
				else if ( MedicGunDigits.Value < 100 )
				{
					MedicGunDigits.Tints[0].R = 192;
					MedicGunDigits.Tints[0].G = 96;
					MedicGunDigits.Tints[0].B = 96;

					MedicGunDigits.Tints[1] = SyringeDigits.Tints[0];
				}
				else
				{
					MedicGunDigits.Tints[0].R = 255;
					MedicGunDigits.Tints[0].G = 64;
					MedicGunDigits.Tints[0].B = 64;

					MedicGunDigits.Tints[1] = MedicGunDigits.Tints[0];
				}

				if ( !bLightHud )
				{
					DrawSpriteWidget(C, MedicGunBG);
				}

				DrawSpriteWidget(C, MedicGunIcon);
				DrawNumericWidget(C, MedicGunDigits, DigitsSmall);
			}

			if ( Welder(PawnOwner.Weapon) != none )
			{
				if ( !bLightHud )
				{
					DrawSpriteWidget(C, WelderBG);
				}

				DrawSpriteWidget(C, WelderIcon);
				DrawNumericWidget(C, WelderDigits, DigitsSmall);
			}
			else if ( PawnOwner.Weapon.GetAmmoClass(0) != none )
			{
				if ( !bLightHud )
				{
					DrawSpriteWidget(C, ClipsBG);
				}

				DrawNumericWidget(C, ClipsDigits, DigitsSmall);

				if ( LAW(PawnOwner.Weapon) != none )
				{
					DrawSpriteWidget(C, LawRocketIcon);
				}
				else if ( Crossbow(PawnOwner.Weapon) != none )
				{
					DrawSpriteWidget(C, ArrowheadIcon);
				}
				else if ( PipeBombExplosive(PawnOwner.Weapon) != none )
				{
					DrawSpriteWidget(C, PipeBombIcon);
				}
				else if ( M79GrenadeLauncher(PawnOwner.Weapon) != none )
				{
					DrawSpriteWidget(C, M79Icon);
				}
				else
				{
					if ( !bLightHud )
					{
						DrawSpriteWidget(C, BulletsInClipBG);
					}

					DrawNumericWidget(C, BulletsInClipDigits, DigitsSmall);

					if ( Flamethrower(PawnOwner.Weapon) != none )
					{
						DrawSpriteWidget(C, FlameIcon);
						DrawSpriteWidget(C, FlameTankIcon);
					}
				    else if ( Shotgun(PawnOwner.Weapon) != none || BoomStick(PawnOwner.Weapon) != none || Winchester(PawnOwner.Weapon) != none )
				    {
					    DrawSpriteWidget(C, SingleBulletIcon);
						DrawSpriteWidget(C, BulletsInClipIcon);
				    }
					else
					{
						DrawSpriteWidget(C, ClipsIcon);
						DrawSpriteWidget(C, BulletsInClipIcon);
					}
				}

				if ( KFWeapon(PawnOwner.Weapon) != none && KFWeapon(PawnOwner.Weapon).bTorchEnabled )
				{
					if ( !bLightHud )
					{
						DrawSpriteWidget(C, FlashlightBG);
					}

					DrawNumericWidget(C, FlashlightDigits, DigitsSmall);

					if ( KFWeapon(PawnOwner.Weapon).FlashLight != none && KFWeapon(PawnOwner.Weapon).FlashLight.bHasLight )
					{
						DrawSpriteWidget(C, FlashlightIcon);
					}
					else
					{
						DrawSpriteWidget(C, FlashlightOffIcon);
					}
				}
			}
		}
	}

	if ( KFPRI != none && KFPRI.ClientVeteranSkill != none )
	{
		KFPRI.ClientVeteranSkill.Static.SpecialHUDInfo(KFPRI, C);
	}
// KFGameReplicationInfo.bHUDShowCash doesn't seem to be replicating.
// Copypasted from superclass and commented for DMMH.
// TODO Erase this method by seeing why KFGameReplicationInfo.bHUDShowCash is not being replicated.
/*
	if ( KFSGameReplicationInfo(PlayerOwner.GameReplicationInfo) == none || KFSGameReplicationInfo(PlayerOwner.GameReplicationInfo).bHUDShowCash )
	{
		DrawSpriteWidget(C, CashIcon);
		DrawNumericWidget(C, CashDigits, DigitsBig);
	}
*/
	if ( KFPRI != none && KFPRI.ClientVeteranSkill != none && KFPRI.ClientVeteranSkill.default.OnHUDIcon != none )
	{
		if ( KFPRI.ClientVeteranSkillLevel > 5 )
		{
			TempMaterial = KFPRI.ClientVeteranSkill.default.OnHUDGoldIcon;
			TempStarMaterial = VetStarGoldMaterial;
			TempLevel = KFPRI.ClientVeteranSkillLevel - 5;
			C.SetDrawColor(255, 255, 255, 192);
		}
		else
		{
			TempMaterial = KFPRI.ClientVeteranSkill.default.OnHUDIcon;
			TempStarMaterial = VetStarMaterial;
			TempLevel = KFPRI.ClientVeteranSkillLevel;
		}

		TempSize = 36 * VeterancyMatScaleFactor * 1.4;
		TempX = C.ClipX * 0.007;
		TempY = C.ClipY * 0.93 - TempSize;

		C.SetPos(TempX, TempY);
		C.DrawTile(TempMaterial, TempSize, TempSize, 0, 0, TempMaterial.MaterialUSize(), TempMaterial.MaterialVSize());

		TempX += (TempSize - VetStarSize);
		TempY += (TempSize - (2.0 * VetStarSize));

		for ( i = 0; i < TempLevel; i++ )
		{
			C.SetPos(TempX, TempY);
			C.DrawTile(TempStarMaterial, VetStarSize, VetStarSize, 0, 0, TempStarMaterial.MaterialUSize(), TempStarMaterial.MaterialVSize());

			TempY -= VetStarSize;
		}
	}

	if ( Level.TimeSeconds - LastVoiceGainTime < 0.333 )
	{
		if ( !bUsingVOIP && PlayerOwner != None && PlayerOwner.ActiveRoom != None &&
			 PlayerOwner.ActiveRoom.GetTitle() == "Team" )
		{
			bUsingVOIP = true;
			PlayerOwner.NotifySpeakingInTeamChannel();
		}

		DisplayVoiceGain(C);
	}
	else
	{
		bUsingVOIP = false;
	}

	if ( bDisplayInventory || bInventoryFadingOut )
	{
		DrawInventory(C);
	}
}

function DrawPlayerInfo(Canvas C, Pawn P, float ScreenLocX, float ScreenLocY)
{
	local float XL, YL, TempX, TempY, TempSize;
	local string PlayerName;
	local float Dist, OffsetX;
	local byte BeaconAlpha;
	local float OldZ;
	local Material TempMaterial, TempStarMaterial;
	local int i, TempLevel;

	if ( KFPlayerReplicationInfo(P.PlayerReplicationInfo) == none || KFPRI == none || KFPRI.bViewingMatineeCinematic )
	{
		return;
	}

	if( !playerOwner.canSee( p ) )
		return;

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

	if( bTeamGame )
	{
		if( p.PlayerReplicationInfo.Team.TeamIndex == 0 )
			C.SetDrawColor(0, 0, 255, BeaconAlpha);
		else
			C.SetDrawColor(255, 0, 0, BeaconAlpha);
	}
	else
		C.SetDrawColor(255, 255, 255, BeaconAlpha);


	C.Font = GetConsoleFont(C);
	PlayerName = Left(P.PlayerReplicationInfo.PlayerName, 16);

	C.StrLen(PlayerName, XL, YL);
	C.SetPos(ScreenLocX - (XL * 0.5), ScreenLocY - (YL * 0.75));
	C.DrawTextClipped(PlayerName);

	OffsetX = (36.f * VeterancyMatScaleFactor * 0.6) - (HealthIconSize + 2.0);

	if ( KFPlayerReplicationInfo(P.PlayerReplicationInfo).ClientVeteranSkill != none &&
		 KFPlayerReplicationInfo(P.PlayerReplicationInfo).ClientVeteranSkill.default.OnHUDIcon != none )
	{
		if ( KFPlayerReplicationInfo(P.PlayerReplicationInfo).ClientVeteranSkillLevel > 5 )
		{
			TempMaterial = KFPlayerReplicationInfo(P.PlayerReplicationInfo).ClientVeteranSkill.default.OnHUDGoldIcon;
			TempStarMaterial = VetStarGoldMaterial;
			TempLevel = KFPlayerReplicationInfo(P.PlayerReplicationInfo).ClientVeteranSkillLevel - 5;
		}
		else
		{
			TempMaterial = KFPlayerReplicationInfo(P.PlayerReplicationInfo).ClientVeteranSkill.default.OnHUDIcon;
			TempStarMaterial = VetStarMaterial;
			TempLevel = KFPlayerReplicationInfo(P.PlayerReplicationInfo).ClientVeteranSkillLevel;
		}

		TempSize = 36.f * VeterancyMatScaleFactor;
		TempX = ScreenLocX + ((BarLength + HealthIconSize) * 0.5) - (TempSize * 0.25) - OffsetX;
		TempY = ScreenLocY - YL - (TempSize * 0.75);

		C.SetPos(TempX, TempY);
		C.DrawTile(TempMaterial, TempSize, TempSize, 0, 0, TempMaterial.MaterialUSize(), TempMaterial.MaterialVSize());

		TempX += (TempSize - (VetStarSize * 0.75));
		TempY += (TempSize - (VetStarSize * 1.5));

		for ( i = 0; i < TempLevel; i++ )
		{
			C.SetPos(TempX, TempY);
			C.DrawTile(TempStarMaterial, VetStarSize * 0.7, VetStarSize * 0.7, 0, 0, TempStarMaterial.MaterialUSize(), TempStarMaterial.MaterialVSize());

			TempY -= VetStarSize * 0.7;
		}
	}

// KFDMMH
/*
	// Health
	if ( P.Health > 0 )
		DrawKFBar(C, ScreenLocX - OffsetX, (ScreenLocY - YL) - 0.4 * BarHeight, FClamp(P.Health / P.HealthMax, 0, 1), BeaconAlpha);

	// Armor
	if ( P.ShieldStrength > 0 )
		DrawKFBar(C, ScreenLocX - OffsetX, (ScreenLocY - YL) - 1.5 * BarHeight, FClamp(P.ShieldStrength / 100.f, 0, 1), BeaconAlpha, true);
*/
	C.Z = OldZ;
}

function DrawCustomBeacon(Canvas C, Pawn P, float ScreenLocX, float ScreenLocY)
{
	local int i;
	local KFPawn KFP;

	KFP = KFPawn(P);

//	KFDMMH.
	if ( KFP == none || PawnOwner == none ||
		 KFP.PlayerReplicationInfo == none || PawnOwner.PlayerReplicationInfo == none )
//		 KFP.PlayerReplicationInfo.Team != PawnOwner.PlayerReplicationInfo.Team )
	{
		return;
	}

	for ( i = 0; i < PlayerInfoPawns.Length; i++ )
	{
		if ( PlayerInfoPawns[i].Pawn == P )
		{
			PlayerInfoPawns[i].PlayerInfoScreenPosX = ScreenLocX;
			PlayerInfoPawns[i].PlayerInfoScreenPosY = ScreenLocY;
			PlayerInfoPawns[i].RendTime = Level.TimeSeconds + 0.1;
			return;
		}
	}

	i = PlayerInfoPawns.Length;
	PlayerInfoPawns.Length = i + 1;
	PlayerInfoPawns[i].Pawn = KFP;
	PlayerInfoPawns[i].PlayerInfoScreenPosX = ScreenLocX;
	PlayerInfoPawns[i].PlayerInfoScreenPosY = ScreenLocY;
	PlayerInfoPawns[i].RendTime = Level.TimeSeconds + 0.1;
}

simulated function DrawKFBar(Canvas C, float XCentre, float YCentre, float BarPercentage, byte BarAlpha, optional bool bArmor);

defaultproperties
{
}
