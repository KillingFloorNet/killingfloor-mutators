class WeldBotHudOverlay extends HudOverlay;

var string someString;
var bool bTest;
var array<Font> Fonts;
var bool bRussian;
var float NDist, MDist,	MDistSq, DiffDist, tDist, tF;
var Pawn Pawn;
var PlayerController PC;
//--------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------
simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	bRussian = class'WeldBotLangSetup'.static.IsRussia(); // used in font selection
	NDist = 300**2;
	MDist = 600**2;
	MDistSq = 600;
	DiffDist = MDist - NDist;
}
//--------------------------------------------------------------------------------------------------
simulated function Destroyed()
{
	Level.GetLocalPlayerController().ClientMessage("HudOverlay Destroyed");
	super.Destroyed();
}
//--------------------------------------------------------------------------------------------------
simulated function Render(Canvas C)
{
	local string S;
	local float XL,YL,k;
	local vector CamDir, CameraLocation, TargetLocation, ScreenLoc;
	local rotator CameraRotation;
	local WeldBot WeldBot;
	local Font tFont;
	local byte Alpha;
	
	if (PC==none)
		PC = C.Viewport.Actor;
	if (Pawn==none && PC!=none)
		Pawn = PC.Pawn;
	
	if (PC!=none && PC.myHud.bHideHud)
		return;
	// Font setup
	if (default.Fonts[0]==none)
	{
		if (bRussian)
			tFont = Font(DynamicLoadObject("ROFonts_Rus.ROArial7",Class'Font'));
		else
			tFont = Font(DynamicLoadObject("ROFonts.ROArial7",Class'Font'));
		if (tFont==none)
			tFont = Font'DefaultFont';
		default.Fonts[0]=tFont;
	}
	if (default.Fonts[1]==none)
	{
		if (bRussian)
			tFont = Font(DynamicLoadObject("ROFonts_Rus.ROBtsrmVr12",Class'Font'));
		else
			tFont = Font(DynamicLoadObject("ROFonts.ROBtsrmVr12",Class'Font'));
		if (tFont==none)
			tFont = Font'DefaultFont';
		default.Fonts[1]=tFont;
	}
	if ( C.ClipY > 1024 )
		C.Font = default.Fonts[0];
	else
		C.Font = default.Fonts[1];
	C.Style = 5;

	C.GetCameraLocation(CameraLocation, CameraRotation);
	foreach VisibleCollidingActors(class'WeldBot', WeldBot, MDistSq, CameraLocation)
	{
		tDist = VSizeSquared(WeldBot.Location-CameraLocation);
		/*
		// Different colours if Owner or Other player
		if ( C.Viewport.Actor.PlayerReplicationInfo==WeldBot.PlayerReplicationInfo )
			C.SetDrawColor(0,200,0,alpha);
		else C.SetDrawColor(200,0,0,alpha);*/

		TargetLocation = WeldBot.Location;
		TargetLocation.Z += WeldBot.CollisionHeight;
		CamDir	= vector(CameraRotation);
		
		if ( Normal(TargetLocation - CameraLocation) dot Normal(CamDir) >= 0.1 )
		{
			ScreenLoc = C.WorldToScreen(TargetLocation);
			// calculate alpha
			if (tDist <= NDist)
				alpha=255;
			else
			{
				tF = tDist-NDist;
				tF = tF / DiffDist;
				tF = 1.f-tF;
				tF = tF * 255.f;
				alpha = tF;
			}
			k = float(Min(ScreenLoc.Y,C.ClipY-ScreenLoc.Y)) / C.ClipY;
			k = FMin(k, float(Min(ScreenLoc.X,C.ClipX-ScreenLoc.X)) / C.ClipX );
			alpha = FMin(alpha, float(alpha) * FClamp(3.f * k + 0.3f, 0.f, 1.f));
			if (alpha==0)
				continue;

			// Different colours if Owner or Other player
			if ( C.Viewport.Actor.PlayerReplicationInfo==WeldBot.PlayerReplicationInfo )
				C.SetDrawColor(0,200,0,alpha);
			else C.SetDrawColor(200,0,0,alpha);
			
			// ћед бот (100%)
			S=WeldBot.BotName; if (Len(S)==0) S=WeldBot.DefaultBotName;
			S=S@"("$int(FMax(WeldBot.GetHealth(),1))@"%"$")";
			C.TextSize(S,XL,YL);
			C.SetPos(ScreenLoc.X - XL * 0.5,ScreenLoc.Y - YL * 2.0);
			C.DrawTextClipped(S,False);

			// ’оз¤ин: “ело (состо¤ние)
			S = WeldBot.OwnerText $ ":"@WeldBot.PlayerReplicationInfo.PlayerName;
			if (WeldBot.BotState==Stay) S = S $ " (" $ WeldBot.MSG_ModeStay $ ")";
			else if (WeldBot.BotState==WeldDoors) S=S $ " (" $ WeldBot.MSG_ModeWeldDoors $ ")";
			C.TextSize(S,XL,YL);
			C.SetPos(ScreenLoc.X - XL * 0.5,ScreenLoc.Y - YL * 0.75);
			C.DrawTextClipped(S,False);
		}
	}
}
//--------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------

defaultproperties
{
     NDist=90000.000000
     MDist=360000.000000
     MDistSq=600.000000
     DiffDist=270000.000000
}
