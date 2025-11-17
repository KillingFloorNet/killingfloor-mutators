Class VSHUD extends HUDKillingFloor;

#exec obj load file="KFMapEndTextures.utx"

// Static variables.
var bool bInitNearDeath,bHasMessagedInfo,bHasMessageMV;
var transient float DisplayTimer;

var Monster IDInfoPawn;
var ClientLight LightSrc;

simulated static final function DrawMonsterInfo( Canvas C, out Monster MMP )
{
	local Actor A;
	local vector HL,HN;
	local float T,XL,YL;
	local PlayerController PC;

	PC = C.Viewport.Actor;

	// Draw identification info.
	A = PC.ViewTarget.Trace(HL,HN,vector(PC.CalcViewRotation)*1000.f+PC.CalcViewLocation,PC.CalcViewLocation,true);
	if( ExtendedZCollision(A)!=None )
		A = A.Owner;
	if( Monster(A)!=None && A!=PC.ViewTarget )
	{
		MMP = Monster(A);
		Default.DisplayTimer = PC.Level.TimeSeconds;
		if( !Default.bHasMessagedInfo && MMP.Health>0 && MMP.PlayerReplicationInfo==None && PC.Pawn==None )
		{
			Default.bHasMessagedInfo = true;
			PC.ReceiveLocalizedMessage(class'VSInfoMessage');
		}
	}

	if( MMP!=None )
	{
		T = (PC.Level.TimeSeconds-Default.DisplayTimer);
		if( T>1.f )
			MMP = None;
		else
		{
			T = (1.f-T);
			C.Font = PC.MyHUD.GetConsoleFont(C);
			C.TextSize("TWAQ",XL,YL);
			XL = C.ClipY*0.7f;
			C.Style = ERenderStyle.STY_Translucent;
			C.SetDrawColor(80.f*T, 80.f*T, 255.f*T);
			C.bCenter = true;
			C.SetPos(0,C.ClipY*0.7f);
			C.DrawText(MMP.MenuName,true);
			C.CurY = XL+YL;
			C.DrawText("Health:"@MMP.Health,true);
			if( MMP.PlayerReplicationInfo!=None )
			{
				C.CurY = XL+YL*2;
				C.DrawText("Controller:"@MMP.PlayerReplicationInfo.PlayerName,true);
			}
			C.bCenter = false;
		}
	}
}
simulated static final function color GetHPColorScale( Pawn P )
{
	local color C;

	if( P.Health<25 ) // Red
		C.R = 255;
	else if( P.Health<75 ) // Yellow -> Red
	{
		C.G = (P.Health-25) * 5.1f;
		C.R = 255;
	}
	else if( P.Health<100 ) // Green -> Yellow
	{
		C.G = 255;
		C.R = (100-P.Health) * 10.2f;
	}
	else C.G = 255;
	C.B = 25;
	return C;
}
simulated static final function Draw3DPlayers( Canvas C )
{
	local PlayerController PC;
	local xPawn P;
	local vector X,Pos;
	local float DotDist,DotScale,Depth;
	local bool bNoMonsters;

	PC = C.Viewport.Actor;
	C.Style = ERenderStyle.STY_Translucent;
	X = vector(PC.CalcViewRotation);
	Depth = (X Dot PC.CalcViewLocation);
	DotScale = C.ClipX*0.2f;

	bNoMonsters = (PC.Pawn!=None);

	foreach PC.DynamicActors(Class'xPawn',P)
	{
		DotDist = (X Dot P.Location) - Depth;
		if( (!bNoMonsters || Monster(P)==None) && P.Health>0 && DotDist>0.f && DotDist<7000.f )
		{
			Pos = C.WorldToScreen(P.Location);
			if( Pos.X<-100 || Pos.Y<-100 || Pos.X>(C.ClipX+100) || Pos.Y>(C.ClipY+100) )
				continue;
			if( Monster(P)!=None )
			{
				if( PC.FastTrace(P.Location,PC.CalcViewLocation) )
					continue;
				C.SetDrawColor(25,25,255);
			}
			else
			{
				C.DrawColor = GetHPColorScale(P);
				if( PC.FastTrace(P.Location,PC.CalcViewLocation) )
					DotDist*=1.75f;
			}
			DotDist = (DotScale/DotDist)*256.f;
			C.SetPos(Pos.X-DotDist*0.25f,Pos.Y-DotDist*0.5f);
			C.DrawRect(Texture'Effects_Tex.BulletHits.glowfinal',DotDist*0.5f,DotDist);
		}
	}
}
simulated static final function DrawEndHUD( Canvas C, bool bVictory )
{
	local float Scalar;
	local PlayerController PC;

	PC = C.Viewport.Actor;

	// Inverse victory for the bad guys.
	if( PC.PlayerReplicationInfo!=None && PC.PlayerReplicationInfo.Team!=None && PC.PlayerReplicationInfo.Team.TeamIndex!=0 )
		bVictory = !bVictory;

	C.DrawColor.A = 255;
	C.DrawColor.R = 255;
	C.DrawColor.G = 255;
	C.DrawColor.B = 255;
	Scalar = FClamp(C.ClipY, 320, 1024);
	C.CurX = C.ClipX / 2 - Scalar / 2;
	C.CurY = C.ClipY / 2 - Scalar / 2;
	C.Style = ERenderStyle.STY_Alpha;

	if ( bVictory )
		C.DrawTile(Shader'VictoryShader', Scalar, Scalar, 0, 0, 1024, 1024);
	else C.DrawTile(Shader'DefeatShader', Scalar, Scalar, 0, 0, 1024, 1024);
}

simulated function DrawEndGameHUD(Canvas C, bool bVictory)
{
	DrawEndHUD(C,bVictory);
	if ( bShowScoreBoard && ScoreBoard != None )
		ScoreBoard.DrawScoreboard(C);
}

simulated function DrawModOverlay( Canvas C )
{
	local float MaxRBrighten, MaxGBrighten, MaxBBrighten;

	if( !bInitNearDeath )
	{
		bInitNearDeath = true;
		C.DrawTile(NearDeathOverlay, 1, 1, 0, 0, 1, 1);
		C.DrawTile(Shader'VictoryShader', 1, 1, 0, 0, 1, 1);
		C.DrawTile(Shader'DefeatShader', 1, 1, 0, 0, 1, 1);
	}
	
	if( PlayerOwner.IsInState('PreySpec') || (PlayerOwner.PlayerReplicationInfo!=None && PlayerOwner.PlayerReplicationInfo.Team!=None && PlayerOwner.PlayerReplicationInfo.Team.TeamIndex!=0) )
	{
		Draw3DPlayers(C);
		DrawMonsterInfo(C,IDInfoPawn);
	}

	if( Monster(PawnOwner)!=None && PawnOwner.Health>0 )
	{
		if( VSPC(PlayerOwner)==None || VSPC(PlayerOwner).bMonsterVision )
		{
			if( LightSrc==None )
				LightSrc = Spawn(Class'ClientLight');
			LightSrc.SetLocation(PawnOwner.Location);
			LightSrc.bDynamicLight = true;
		}
		else
		{
			if( LightSrc!=None )
				LightSrc.bDynamicLight = false;
			if( !bHasMessageMV )
			{
				bHasMessageMV = true;
				PlayerOwner.ReceiveLocalizedMessage(class'VSInfoMessage',2);
			}
		}
	}
	else if( LightSrc!=None )
		LightSrc.bDynamicLight = false;

	C.Style = ERenderStyle.STY_Alpha;

	// We want the overlay to start black, and fade in, almost like the player opened their eyes
	// BrightFactor = 1.5;   // Not too bright.  Not too dark.  Livens things up just abit
	// Hook for Optional Vision overlay.  - Alex
	C.SetPos(0, 0);

	if( PawnOwner==None )
	{
		if( CurrentZone!=None || CurrentVolume!=None ) // Reset everything.
		{
			LastR = 0;
    		LastG = 0;
    		LastB = 0;
			CurrentZone = None;
			LastZone = None;
			CurrentVolume = None;
			LastVolume = None;
			bZoneChanged = false;
			SetTimer(0.f, false);
		}
		VisionOverlay = default.VisionOverlay;

		// Dead Players see Red
		if( !PlayerOwner.IsSpectating() )
		{
			C.SetDrawColor(255, 255, 255, GrainAlpha);
			C.DrawTile(SpectatorOverlay, C.SizeX, C.SizeY, 0, 0, 1024, 1024);
		}
		return;
	}

	// if critical, pulsate.  otherwise, dont.
	if ( (PlayerOwner.Pawn==PawnOwner || !PlayerOwner.bBehindView) && Vehicle(PawnOwner)==None && PawnOwner.Health>0 && PawnOwner.Health<(PawnOwner.HealthMax*0.25) )
		VisionOverlay = NearDeathOverlay;
	else VisionOverlay = default.VisionOverlay;

	// Players can choose to turn this feature off completely.
	// conversely, setting bDistanceFog = false in a Zone
	// will cause the code to ignore that zone for a shift in RGB tint
	if ( KFLevelRule != none && !KFLevelRule.bUseVisionOverlay )
		return;

	// here we determine the maximum "brighten" amounts for each value.  CANNOT exceed 255
	MaxRBrighten = Round(LastR* (1.0 - (LastR / 255)) - 2) ;
	MaxGBrighten = Round(LastG* (1.0 - (LastG / 255)) - 2) ;
	MaxBBrighten = Round(LastB* (1.0 - (LastB / 255)) - 2) ;

	C.SetDrawColor(LastR + MaxRBrighten, LastG + MaxGBrighten, LastB + MaxBBrighten, GrainAlpha);
	C.DrawTileScaled(VisionOverlay, C.SizeX, C.SizeY);  //,0,0,1024,1024);

	// Here we change over the Zone.
	// What happens of importance is
	// A.  Set Old Zone to current
	// B.  Set New Zone
	// C.  Set Color info up for use by Tick()

	// if we're in a new zone or volume without distance fog...just , dont touch anything.
	// the physicsvolume check is abit screwy because the player is always in a volume called "DefaultPhyicsVolume"
	// so we've gotta make sure that the return checks take this into consideration.

	// This block of code here just makes sure that if we've already got a tint, and we step into a zone/volume without
	// bDistanceFog, our current tint is not affected.
	// a.  If I'm in a zone and its not bDistanceFog. AND IM NOT IN A PHYSICSVOLUME. Just a zone.
	// b.  If I'm in a Volume
	if ( !PawnOwner.Region.Zone.bDistanceFog &&
		 DefaultPhysicsVolume(PawnOwner.PhysicsVolume)==None && !PawnOwner.PhysicsVolume.bDistanceFog )
		return;

	if ( !bZoneChanged )
	{
		// Grab the most recent zone info from our PRI
		// Only update if it's different
		// EDIT:  AND HAS bDISTANCEFOG true
		if ( CurrentZone!=PawnOwner.Region.Zone || (DefaultPhysicsVolume(PawnOwner.PhysicsVolume) == None &&
			 CurrentVolume != PawnOwner.PhysicsVolume) )
		{
			if ( CurrentZone != none )
				LastZone = CurrentZone;
			else if ( CurrentVolume != none )
				LastVolume = CurrentVolume;

			// This is for all occasions where we're either in a Levelinfo handled zone
			// Or a zoneinfo.
			// If we're in a LevelInfo / ZoneInfo  and NOT touching a Volume.  Set current Zone
			if ( PawnOwner.Region.Zone.bDistanceFog && DefaultPhysicsVolume(PawnOwner.PhysicsVolume)!= none && !PawnOwner.Region.Zone.bNoKFColorCorrection )
			{
				CurrentVolume = none;
				CurrentZone = PawnOwner.Region.Zone;
			}
			else if ( DefaultPhysicsVolume(PawnOwner.PhysicsVolume) == None && PawnOwner.PhysicsVolume.bDistanceFog && !PawnOwner.PhysicsVolume.bNoKFColorCorrection)
			{
				CurrentZone = none;
				CurrentVolume = PawnOwner.PhysicsVolume;
			}

			if ( CurrentVolume != none )
				LastZone = none;
			else if ( CurrentZone != none )
				LastVolume = none;

			if ( LastZone != none )
			{
				if( LastZone.bNewKFColorCorrection )
				{
					LastR = LastZone.KFOverlayColor.R;
					LastG = LastZone.KFOverlayColor.G;
					LastB = LastZone.KFOverlayColor.B;
				}
				else
				{
					LastR = LastZone.DistanceFogColor.R;
					LastG = LastZone.DistanceFogColor.G;
					LastB = LastZone.DistanceFogColor.B;
				}
			}
			else if ( LastVolume != none )
			{
				if( LastVolume.bNewKFColorCorrection )
				{
					LastR = LastVolume.KFOverlayColor.R;
					LastG = LastVolume.KFOverlayColor.G;
					LastB = LastVolume.KFOverlayColor.B;
				}
				else
				{
					LastR = LastVolume.DistanceFogColor.R;
					LastG = LastVolume.DistanceFogColor.G;
					LastB = LastVolume.DistanceFogColor.B;
				}
			}
			else if ( LastZone != none && LastVolume != none )
				return;

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
simulated function DrawDamageIndicators(Canvas C)
{
	local class<DamTypeZombieAttack> ZHUDDam;
	local float DltA;
	local Material M;

	C.Style = ERenderStyle.STY_Alpha;

	if ( DamageHUDTimer>Level.TimeSeconds )
	{
		C.SetPos(0, 0);
		DltA = DamageHUDTimer - Level.TimeSeconds;
		C.SetDrawColor(255, 255, 255, clamp((DltA / DamageStartTime * 200.f), 0, 200));

		ZHUDDam = class<DamTypeZombieAttack>(HUDHitDamage);

		if ( ZHUDDam == none )
			M = Texture'KillingFloorHUD.GoreSplash';
		else if( DamageIsUber )
			M = ZHUDDam.default.HUDUberDamageTex;
		else M = ZHUDDam.default.HUDDamageTex;
		
		if( M!=None )
			C.DrawTile( M, C.SizeX, C.SizeY, 0.0, 0.0, M.MaterialUSize(), M.MaterialVSize());
	}
}

defaultproperties
{
}
