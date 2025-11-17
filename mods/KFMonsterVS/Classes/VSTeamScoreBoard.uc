class VSTeamScoreBoard extends KFScoreBoard;

var localized string TeamNames[2];

function DrawTitle(Canvas Canvas, float HeaderOffsetY, float PlayerAreaY, float PlayerBoxSizeY)
{
	local string TitleString, ScoreInfoString, RestartString;
	local float TitleXL, ScoreInfoXL, YL, TitleY, TitleYL;

	TitleString = SkillLevel[Clamp(InvasionGameReplicationInfo(GRI).BaseDifficulty, 0, 7)] @ "|" @ WaveString @ (InvasionGameReplicationInfo(GRI).WaveNumber + 1) @ "|" @ Level.Title;

	Canvas.Font = class'ROHud'.static.GetSmallMenuFont(Canvas);

	Canvas.StrLen(TitleString, TitleXL, TitleYL);

	if ( GRI.TimeLimit != 0 )
	{
		ScoreInfoString = TimeLimit $ FormatTime(GRI.RemainingTime);
	}
	else
	{
		ScoreInfoString = FooterText @ FormatTime(GRI.ElapsedTime);
	}

	Canvas.DrawColor = HUDClass.default.RedColor;

	if ( UnrealPlayer(Owner).bDisplayLoser )
	{
		ScoreInfoString = class'HUDBase'.default.YouveLostTheMatch;
	}
	else if ( UnrealPlayer(Owner).bDisplayWinner )
	{
		ScoreInfoString = class'HUDBase'.default.YouveWonTheMatch;
	}
	else if ( PlayerController(Owner).IsDead() )
	{
		if ( PlayerController(Owner).PlayerReplicationInfo.bOutOfLives )
			RestartString = OutFireText;
		else RestartString = Restart;

		ScoreInfoString = RestartString;
	}

	TitleY = Canvas.ClipY * 0.13;
	Canvas.SetPos(0.5 * (Canvas.ClipX - TitleXL), TitleY);
	Canvas.DrawText(TitleString);

	Canvas.StrLen(ScoreInfoString, ScoreInfoXL, YL);
	Canvas.SetPos(0.5 * (Canvas.ClipX - ScoreInfoXL), TitleY + TitleYL);
	Canvas.DrawText(ScoreInfoString);
}
simulated final function DrawTeamScores( byte Team, Canvas Canvas, float XOfs )
{
	local PlayerReplicationInfo PRI, OwnerPRI;
	local byte PlayerCount;
	local int i, FontReduction, NetXPos, HeaderOffsetY, HeadFoot, MessageFoot, PlayerBoxSizeY, BoxSpaceY, NameXPos, BoxTextOffsetY, HealthXPos, BoxXPos,KillsXPos, TitleYPos, BoxWidth, VetXPos, Stars;
	local float XL,YL, MaxScaling;
	local float deathsXL, KillsXL, netXL,HealthXL, MaxNamePos, KillWidthX, HealthWidthX;
	local bool bNameFontReduction,bSameTeam;
	local Material VeterancyBox;

	OwnerPRI = KFPlayerController(Owner).PlayerReplicationInfo;
	bSameTeam = (OwnerPRI.bOnlySpectator || (OwnerPRI.Team!=None && OwnerPRI.Team.TeamIndex==Team));
	for ( i = 0; i < GRI.PRIArray.Length; i++)
	{
		PRI = GRI.PRIArray[i];
		if ( !PRI.bOnlySpectator && PRI.Team!=None && PRI.Team.TeamIndex==Team )
		{
			PRIArray[PlayerCount++] = PRI;
			if( PlayerCount==MAXPLAYERS )
				break;
		}
	}

	// Select best font size and box size to fit as many players as possible on screen
	Canvas.Font = class'ROHud'.static.GetSmallMenuFont(Canvas);
	Canvas.StrLen("Test", XL, YL);
	BoxSpaceY = 0.25 * YL;
	PlayerBoxSizeY = 1.2 * YL;
	HeadFoot = 7 * YL;
	MessageFoot = 1.5 * HeadFoot;

	if ( PlayerCount > (Canvas.ClipY - 1.5 * HeadFoot) / (PlayerBoxSizeY + BoxSpaceY) )
	{
		BoxSpaceY = 0.125 * YL;
		PlayerBoxSizeY = 1.25 * YL;
		if ( PlayerCount > (Canvas.ClipY - 1.5 * HeadFoot) / (PlayerBoxSizeY + BoxSpaceY) )
			PlayerBoxSizeY = 1.125 * YL;
	}

	if ( Canvas.ClipX < 512 )
		PlayerCount = Min(PlayerCount, 1+(Canvas.ClipY - HeadFoot) / (PlayerBoxSizeY + BoxSpaceY) );
	else PlayerCount = Min(PlayerCount, (Canvas.ClipY - HeadFoot) / (PlayerBoxSizeY + BoxSpaceY) );

	if ( FontReduction > 2 )
		MaxScaling = 3;
	else MaxScaling = 2.125;

	PlayerBoxSizeY = FClamp((1.25 + (Canvas.ClipY - 0.67 * MessageFoot)) / PlayerCount - BoxSpaceY, PlayerBoxSizeY, MaxScaling * YL);

	bDisplayMessages = (PlayerCount <= (Canvas.ClipY - MessageFoot) / (PlayerBoxSizeY + BoxSpaceY));

	HeaderOffsetY = 11.f * YL;
	BoxWidth = 0.45 * Canvas.ClipX;
	BoxXPos = 0.5*(Canvas.ClipX*0.5f-BoxWidth)+XOfs;
	VetXPos = BoxXPos + 0.00005 * BoxWidth;
	NameXPos = VetXPos + PlayerBoxSizeY*1.25f;
	KillsXPos = BoxXPos + 0.60 * BoxWidth;
	HealthXpos = BoxXPos + 0.75 * BoxWidth;
	NetXPos = BoxXPos + 0.90 * BoxWidth;

	// draw background boxes
	Canvas.Style = ERenderStyle.STY_Alpha;
	if( Team==0 )
		Canvas.DrawColor = Class'Hud'.Default.RedColor;
	else Canvas.DrawColor = Class'Hud'.Default.BlueColor;
	Canvas.DrawColor.A = 128;

	for ( i = 0; i < PlayerCount; i++ )
	{
		Canvas.SetPos(BoxXPos, HeaderOffsetY + (PlayerBoxSizeY + BoxSpaceY) * i);
		Canvas.DrawTileStretched( BoxMaterial, BoxWidth, PlayerBoxSizeY);
	}

	// draw title
	Canvas.Style = ERenderStyle.STY_Normal;
	DrawTitle(Canvas, HeaderOffsetY, (PlayerCount + 1) * (PlayerBoxSizeY + BoxSpaceY), PlayerBoxSizeY);

	// Draw headers
	TitleYPos = HeaderOffsetY - 1.1 * YL;
	Canvas.DrawColor = HUDClass.default.WhiteColor;
	if( GRI!=None && GRI.Teams[Team]!=None )
	{
		Canvas.SetPos(BoxXPos+0.1f*BoxWidth, TitleYPos-1.25f*YL);
		Canvas.DrawText(TeamNames[Team]@int(GRI.Teams[Team].Score),true);
	}

	Canvas.StrLen(HealthText, HealthXL, YL);
	Canvas.StrLen(DeathsText, DeathsXL, YL);
	Canvas.StrLen(KillsText, KillsXL, YL);
	Canvas.StrLen("HEA", HealthWidthX, YL);

	Canvas.SetPos(NameXPos, TitleYPos);
	Canvas.DrawText(PlayerText,true);

	Canvas.SetPos(KillsXPos - 0.5 * KillsXL, TitleYPos);
	Canvas.DrawText(KillsText,true);

	Canvas.SetPos(HealthXPos - 0.5 * HealthXL, TitleYPos);
	Canvas.DrawText(HealthText,true);

	// draw player names
	MaxNamePos = 0.9 * (KillsXPos - NameXPos);

	for ( i = 0; i < PlayerCount; i++ )
	{
		Canvas.StrLen(PRIArray[i].PlayerName, XL, YL);

		if ( XL > MaxNamePos )
		{
			bNameFontReduction = true;
			break;
		}
	}

	if ( bNameFontReduction )
	{
		Canvas.Font = GetSmallerFontFor(Canvas, FontReduction + 1);
	}

	Canvas.Style = ERenderStyle.STY_Normal;
	Canvas.DrawColor = HUDClass.default.WhiteColor;
	Canvas.SetPos(0.5 * Canvas.ClipX, HeaderOffsetY + 4);
	BoxTextOffsetY = HeaderOffsetY + 0.5 * (PlayerBoxSizeY - YL);

	Canvas.DrawColor = HUDClass.default.WhiteColor;
	MaxNamePos = Canvas.ClipX;
	Canvas.ClipX = KillsXPos - 4.f;

	for ( i = 0; i < PlayerCount; i++ )
	{
		Canvas.SetPos(NameXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY);

		if( PRIArray[i]==OwnerPRI )
		{
			Canvas.DrawColor.G = 0;
			Canvas.DrawColor.B = 0;
		}
		else
		{
			Canvas.DrawColor.G = 255;
			Canvas.DrawColor.B = 255;
		}

		Canvas.DrawTextClipped(PRIArray[i].PlayerName);
	}

	Canvas.ClipX = MaxNamePos;
	Canvas.DrawColor = HUDClass.default.WhiteColor;

	if ( bNameFontReduction )
	{
		Canvas.Font = GetSmallerFontFor(Canvas, FontReduction);
	}

	Canvas.Style = ERenderStyle.STY_Normal;
	MaxScaling = FMax(PlayerBoxSizeY,30.f);

	// Draw the player informations.
	for ( i = 0; i < PlayerCount; i++ )
	{
		PRI = PRIArray[i];
		if( KFPlayerReplicationInfo(PRI)==None )
			continue;
		Canvas.DrawColor = HUDClass.default.WhiteColor;

		// Display perks.
		if ( KFPlayerReplicationInfo(PRI).ClientVeteranSkill != none )
		{
			Stars = KFPlayerReplicationInfo(PRI).ClientVeteranSkillLevel;
			if( Stars<=5 )
				VeterancyBox = KFPlayerReplicationInfo(PRI).ClientVeteranSkill.Default.OnHUDIcon;
			else VeterancyBox = KFPlayerReplicationInfo(PRI).ClientVeteranSkill.Default.OnHUDGoldIcon;

			if ( VeterancyBox != None )
				DrawPerkWithStars(Canvas,VetXPos,HeaderOffsetY+(PlayerBoxSizeY+BoxSpaceY)*i,PlayerBoxSizeY,Stars,VeterancyBox);
		}

		// draw kills
		Canvas.TextSize(PRI.Kills, KillWidthX, YL);
		Canvas.SetPos(KillsXPos - 0.5 * KillWidthX, (PlayerBoxSizeY + BoxSpaceY) * i + BoxTextOffsetY);
		Canvas.DrawText(PRI.Kills, true);

		// draw deaths
		Canvas.SetPos(HealthXpos - HealthWidthX, (PlayerBoxSizeY + BoxSpaceY) * i + BoxTextOffsetY);
		if( PRI.bOutOfLives || KFPlayerReplicationInfo(PRI).PlayerHealth<=0 )
		{
			Canvas.DrawColor = HUDClass.default.RedColor;
			Canvas.DrawText(OutText, true);
		}
		else if( bSameTeam )
		{
			if( KFPlayerReplicationInfo(PRI).PlayerHealth>=90 )
				Canvas.DrawColor = HUDClass.default.GreenColor;
			else if( KFPlayerReplicationInfo(PRI).PlayerHealth>=50 )
				Canvas.DrawColor = HUDClass.default.GoldColor;
			else Canvas.DrawColor = HUDClass.default.RedColor;
			Canvas.DrawText(KFPlayerReplicationInfo(PRI).PlayerHealth@HealthyString,true);
		}
	}

	if ( Level.NetMode == NM_Standalone )
		return;

	Canvas.StrLen(NetText, NetXL, YL);
	Canvas.DrawColor = HUDClass.default.WhiteColor;
	Canvas.SetPos(NetXPos - 0.5 * NetXL, TitleYPos);
	Canvas.DrawText(NetText,true);

	DrawNetInfo(Canvas, FontReduction, HeaderOffsetY, PlayerBoxSizeY, BoxSpaceY, BoxTextOffsetY, -1, PlayerCount, NetXPos);
	DrawMatchID(Canvas, FontReduction);
}
simulated event UpdateScoreBoard(Canvas Canvas)
{
	DrawTeamScores(0,Canvas,0.f);
	DrawTeamScores(1,Canvas,Canvas.ClipX*0.5f);
}
simulated final function DrawPerkWithStars( Canvas C, float X, float Y, float Scale, int Stars, Material PerkIcon )
{
	local byte i;
	local Material StarIcon;

	if( Stars<=5 )
		StarIcon = Class'HudKillingFloor'.Default.VetStarMaterial;
	else
	{
		StarIcon = Class'HudKillingFloor'.Default.VetStarGoldMaterial;
		Stars = Min(Stars-5,5);
	}
	C.SetPos(X,Y);
	C.DrawTile(PerkIcon, Scale, Scale, 0, 0, PerkIcon.MaterialUSize(), PerkIcon.MaterialVSize());
	Y+=Scale*0.9f;
	X+=Scale*0.8f;
	Scale*=0.2f;

	for( i=1; i<=Stars; ++i )
	{
		C.SetPos(X,Y-(i*Scale*0.8f));
		C.DrawTile(StarIcon, Scale, Scale, 0, 0, StarIcon.MaterialUSize(), StarIcon.MaterialVSize());
	}
}

defaultproperties
{
     TeamNames(0)="PLAYERS SCORE:"
     TeamNames(1)="MONSTERS KILLS:"
     HealthyString="HP"
}
