class DMHUDKillingFloor extends HUDKillingFloor;

var byte PLCount,PLPosition;
var float NextPosUpdate;
var localized string LostMatchStr,WonMatchStr,OtherWinnerStr;

simulated function DrawKFHUDTextElements(Canvas C)
{
	local float    XL, YL;
	local string   S;

	if ( PlayerOwner == none || KFGRI == none || !KFGRI.bMatchHasBegun || KFPlayerController(PlayerOwner).bShopping || PlayerOwner.PlayerReplicationInfo==None
		|| PlayerOwner.PlayerReplicationInfo.bOnlySpectator )
		return;

	if( NextPosUpdate<Level.TimeSeconds )
	{
		NextPosUpdate = Level.TimeSeconds+0.5f;
		UpdatePosition();
	}

	// Position
	C.SetDrawColor(255, 255, 255, 255);
	C.SetPos(C.ClipX - 128, 2);
	C.DrawTile(Material'KillingFloorHUD.HUD.Hud_Bio_Circle', 128, 128, 0, 0, 256, 256);

	S = PLPosition$"/"$PLCount;
	C.Font = LoadFont(1);
	C.Strlen(S, XL, YL);
	C.SetDrawColor(255, 50, 50, 255);
	C.SetPos(C.ClipX - 64 - (XL*0.5f), 66 - (YL*0.5f));
	C.DrawText(S);
}
simulated final function UpdatePosition()
{
	local int i;
	local PlayerReplicationInfo PRI;

	PLCount = 1;
	PLPosition = 1;
	PRI = PlayerOwner.PlayerReplicationInfo;
	for( i=0; i<KFGRI.PRIArray.Length; i++ )
	{
		if( KFGRI.PRIArray[i]==None || KFGRI.PRIArray[i]==PRI || KFGRI.PRIArray[i].bOnlySpectator )
			continue;
		PLCount++;
		if( KFGRI.PRIArray[i].Kills>PRI.Kills )
			PLPosition++;
	}
}

simulated function DrawEndGameHUD(Canvas C, bool bVictory)
{
	C.SetDrawColor(255, 255, 255, 255);
	C.Font = LoadFont(1);
	C.SetPos(0,C.ClipY*0.7f);
	C.bCenter = true;
	if( PlayerReplicationInfo(KFGRI.Winner)==None )
		C.DrawText(LostMatchStr,false);
	else if( KFGRI.Winner==PlayerOwner.PlayerReplicationInfo )
		C.DrawText(WonMatchStr,false);
	else C.DrawText(PlayerReplicationInfo(KFGRI.Winner).PlayerName$OtherWinnerStr,false);
	C.bCenter = false;
	if ( bShowScoreBoard && ScoreBoard != None )
		ScoreBoard.DrawScoreboard(C);
}

simulated function DrawHud(Canvas C)
{
	local KFGameReplicationInfo CurrentGame;
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
		return;

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
			DrawPlayerInfo(C, PlayerInfoPawns[i].Pawn, PlayerInfoPawns[i].PlayerInfoScreenPosX, PlayerInfoPawns[i].PlayerInfoScreenPosY);
		else PlayerInfoPawns.Remove(i--, 1);
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
			DrawEndGameHUD(C, True);
		else DrawEndGameHUD(C, False);
	}
	else DrawKFHUDTextElements(C);

	if ( bShowNotification )
		DrawPopupNotification(C);
}
function DrawDoorHealthBars(Canvas C)
{
	if( PlayerOwner.Pawn!=None )
		Super.DrawDoorHealthBars(C);
}

defaultproperties
{
     LostMatchStr="You've have lost the match!"
     WonMatchStr="You've have won the match!"
     OtherWinnerStr=" is the winner!"
}
