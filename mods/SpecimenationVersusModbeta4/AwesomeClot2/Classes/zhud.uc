class zhud extends Hudkillingfloor
	config(User);

#exec texture import file=dd.tga

var localized string usemsg;
var Actor Act;

struct SHitInfo
{
	var string Text;
	var float LastHit;	
};
var SHitInfo SHitText[4];
var byte SHitInt;

var float RY[20],RX[20];
var int Hunum,specinum;

var Texture CMaterial;

struct Damage
{
	var int Damage;
	var float LastHit;
};

var Damage Dam[20];

struct VersusInfo
{
	var Pawn	Pawn;
	var int ClotsKilled;
	var int BloatsKilled;
	var int GoreFastsKilled;
	var int HusksKilled;
	var int crawlersKilled;
	var int StalkersKilled;
	var int SirensKilled;
	var int ScrakesKilled;
	var int FleshPoundsKilled;
};
var	array<VersusInfo> PlayerVersusInfo;

var array<zombiepri> ZPri;
var Pawn UnSeenPawn[32];


var float LastVInfoUpdate;
var int PBIINT,Dint;

function postbeginplay()
{
	super.postbeginplay();
}

simulated function AddSHit(string msg)
{
	SHitText[SHitint].Text = msg;
	SHitText[SHitint].lasthit = Level.TimeSeconds + 0.1;
		
	if( SHitint > 0 && SHitint < 3 && SHitText[SHitint].lasthit - SHitText[SHitint-1].lasthit <= 1)
		SHitText[SHitint-1].lasthit = SHitText[SHitint-1].lasthit - 1;
	else if( SHitText[0].lasthit - SHitText[3].lasthit <= 1)
		SHitText[3].lasthit = SHitText[SHitint-1].lasthit - 1;
	SHitint++;

	if(SHitInt >= 3)
		SHitInt = 0;
}
simulated function SetDamage(int D, float LH)
{

	RX[Dint] = ( 0.4+(0.2*frand()) );
	RY[Dint] = ( 0.1+(0.2*frand()) );
	Dam[Dint].damage = D;
	Dam[Dint].LastHit = LH;
	Dint++;

	if(Dint > 20)
		Dint=0;
}
simulated function DrawNumbers(canvas C)
{

	C.Font = LoadFont(2);
	c.setpos(0*c.clipx,0.35*c.clipy);
	c.drawtext("S");

	c.setpos(0*c.clipx,0.4*c.clipy);
	c.drawtext(specinum);

	c.setpos(0*c.clipx,0.5*c.clipy);
	c.drawtext("H");

	c.setpos(0*c.clipx,0.55*c.clipy);
	c.drawtext(hunum);
}
simulated function HandleSHit(canvas c)
{	
	local int i;
	local float XPos,YPos, myfadetime;

	C.Font = GetConsoleFont(C);
	for( i=0;i<3;i++)
	{
		XPos = 0.7 * c.clipx;
		
		YPos = ( 0.9 - ((level.timeseconds - SHitText[i].lasthit)/20) ) * c.clipy;
		if( YPos <= 0.6 )
			YPos = 0.6;


		if( i < 2 && 0.9 - ((level.timeseconds - SHitText[i+1].lasthit)/20) <= 0.6 && SHitText[i+1].text != ""|| 
			i == 2 && 0.9 - ((level.timeseconds - SHitText[0].lasthit)/20) <= 0.6 && SHitText[0].text != "")
			SHitText[i].text="";

		if( 5 < level.timeseconds - SHitText[i].lasthit )
			{
				SHitText[i].lasthit = 0;
				SHitText[i].text = "";

			}
			else if( SHitText[i].text != "" )
			{
				c.Setpos(Xpos,Ypos);
				c.drawtext(SHitText[i].text);

			}
	}
	
	C.Font = LoadFont(7);
	for(i=0;i<20;i++)
	{
	
		if( 5 < level.timeseconds - Dam[i].lasthit )
			continue;

		c.style = Erenderstyle.sty_translucent;

		myfadetime = ((level.timeseconds - Dam[i].lasthit)*(255/5));

		c.SetPos( RX[i]* c.clipx, RY[i]* c.clipy);
		c.drawcolor.r=254-myFadetime;
		c.drawcolor.g=254-myFadetime;
		c.drawcolor.b=(100-myFadetime);
		c.drawcolor.b=Min(1,255);
		c.DrawText(Dam[i].damage);
	}		
}

simulated function DrawKFHUDTextElements(Canvas C)
{
	local float    XL, YL;
	local int      NumZombies, Min;
	local string   S;



		if ( PlayerOwner == none || KFGRI == none || !KFGRI.bMatchHasBegun || KFPlayerController(PlayerOwner).bShopping )
		{
			return;
		}

		// Countdown Text
		if( !KFGRI.bWaveInProgress )
		{
			C.SetDrawColor(255, 255, 255, 255);
			C.SetPos(C.ClipX - 130, 2);
			//C.DrawTile(Material'KillingFloorHUD.HUD.Hud_Bio_Clock_Circle', 128, 128, 0, 0, 256, 256);

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
			//C.DrawText(S, False);
		}
		else
		{
			/*//Hints
			if ( KFPlayerController(PlayerOwner) != none )
			{
				KFPlayerController(PlayerOwner).CheckForHint(30);

				if ( !bHint_45_TimeSet && KFGRI.WaveNumber == 1)
				{
					Hint_45_Time = Level.TimeSeconds + 5;
					bHint_45_TimeSet = true;
				}
			}

			C.SetPos(C.ClipX - 128, 2);
			C.DrawTile(Material'KillingFloorHUD.HUD.Hud_Bio_Circle', 128, 128, 0, 0, 256, 256);

			S = string(KFGRI.MaxMonsters);
			C.Font = LoadFont(1);
			C.Strlen(S, XL, YL);
			C.SetDrawColor(255, 50, 50, KFHUDAlpha);
			C.SetPos(C.ClipX - 64 - (XL / 2), 66 - (YL / 1.5));
			C.DrawText(S);*/
			C.SetDrawColor(255, 255, 255, 255);
			// Show the number of waves
			S = WaveString @ string(KFGRI.WaveNumber + 1) $ "/" $ string(KFGRI.FinalWave);
			C.Font = LoadFont(5);
			C.Strlen(S, XL, YL);
			C.SetPos(C.ClipX - 64 - (XL / 2), 66 + (YL / 2.5));
			C.DrawText(S);

   			//Needed for the hints showing up in the second downtime
			bIsSecondDowntime = true;
		}

		if ( KFPRI == none || KFPRI.Team == none || KFPRI.bOnlySpectator || PawnOwner == none )
		{
			return;
		}

		// Draw the shop pointer
		/*if ( ShopDirPointer == None )
		{
			//ShopDirPointer = Spawn(Class'KFShopDirectionPointer');
			ShopDirPointer.bHidden = bHideHud;
		}

		Pos.X = C.SizeX / 18.0;
		Pos.Y = C.SizeX / 18.0;
		Pos = PlayerOwner.Player.Console.ScreenToWorld(Pos) * 10.f * (PlayerOwner.default.DefaultFOV / PlayerOwner.FovAngle) + PlayerOwner.CalcViewLocation;
		ShopDirPointer.SetLocation(Pos);

		if ( KFGRI.CurrentShop != none )
		{
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
		}
		else
		{
			ShopDirPointer.bHidden = true;
			return;
		}

   		ShopDirPointer.SetRotation(ShopDirPointerRotation);

		if ( Level.TimeSeconds > Hint_45_Time && Level.TimeSeconds < Hint_45_Time + 2 )
		{
			if ( KFPlayerController(PlayerOwner) != none )
			{
				KFPlayerController(PlayerOwner).CheckForHint(45);
			}
		}*/

		C.DrawActor(None, False, True); // Clear Z.
		//ShopDirPointer.bHidden = false;
		//C.DrawActor(ShopDirPointer, False, false);
		//ShopDirPointer.bHidden = true;
		//DrawTraderDistance(C);
	
}

function vector NextPlayerLocation()
{
	local kfpawn ztarget;
	
	foreach dynamicactors(class'kfpawn', ztarget)
	{
		if(ztarget != none)
		   {return Ztarget.location;}
		  
		  
	}
	
	return Ztarget.location;
	
}
function DrawCustomBeacon(Canvas C, Pawn P, float ScreenLocX, float ScreenLocY)
{
	local KFPawn KFP;
	local int i;

	//Drawpawn(P);

	KFP = KFPawn(P);


	if( KFP == none )
	   return;


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
		PlayerInfoPawns[i].Pawn = kfP;
		PlayerInfoPawns[i].PlayerInfoScreenPosX = ScreenLocX;
		PlayerInfoPawns[i].PlayerInfoScreenPosY = ScreenLocY;
		PlayerInfoPawns[i].RendTime = Level.TimeSeconds + 0.1;
		
	
}

function Drawpawn(Pawn P)
{
	local int i;
	local KFPawn KFP;
	local ZombiePRI PawnZPRI;
	local bool T,  addzpri;
	
	KFP = KFPawn(P);
	
	//**************
	if (kfhumanpawn(playerowner.pawn)==none)
		return;

	PawnZPRI = zombiepri(p.playerreplicationinfo);
	
	
	for ( i = 0; i < 32; i++ )
	{
		if ( UnseenPawn[i] == P )
		{
			T = true;
			break;
		} 
		else if( Unseenpawn[i] == none || Unseenpawn[i]!=none && Unseenpawn[i].health <= 0)
			UnseenPawn[i] = none;
	}
	
	if( T == false)
	for ( i = 0; i < 32; i++ )
	{

		if( Unseenpawn[i] == none )
		{	
			UnseenPawn[i] = p;
			break;
		}
	}
	

	if(  PawnZPRI == none )
		return;

	
	for ( i = 0; i < ZPri.Length; i++ )
	{
		
		if( Zpri[i] == PawnZpri || !p.isa('kfmonster'))
			break;
		else if( ZPri[i]==none )
			Zpri.Remove(i--, 1);
		else if( ZPri[i] !=none )
			continue;
		else addzpri = true;
		
	}
			if( addzpri || Zpri.Length <= 0 && p.isa('kfmonster'))
			{
				i=Zpri.length;
				Zpri.length = i + 1;
				Zpri[i] = PawnZPRI;
			}


	if( KFP == none )
	   return;
	
		
		for ( i = 0; i < PlayerVersusInfo.Length; i++ )
	{
		if ( PlayerVersusInfo[i].Pawn == P && pawnzpri != none)
		{
			PlayerVersusInfo[i].clotskilled = pawnZPRI.clotskilled;
			PlayerVersusInfo[i].bloatskilled = pawnZPRI.bloatskilled;
			PlayerVersusInfo[i].crawlerskilled = pawnZPRI.crawlerskilled;
			PlayerVersusInfo[i].stalkerskilled = pawnZPRI.stalkerskilled;
			PlayerVersusInfo[i].sirenskilled = pawnZPRI.sirenskilled;
			PlayerVersusInfo[i].gorefastskilled = pawnZPRI.gorefastskilled;
			PlayerVersusInfo[i].huskskilled = pawnZPRI.huskskilled;
			PlayerVersusInfo[i].scrakeskilled = pawnZPRI.scrakeskilled;
			PlayerVersusInfo[i].fleshpoundskilled = pawnZPRI.fleshpoundskilled;			
			return;
		}
	}

	
		
		if( Pawnzpri == none)
		   return;
		
	i = PlayerVersusInfo.Length;
	PlayerVersusInfo.Length = i + 1;
	PlayerVersusInfo[i].Pawn = KFP;
	PlayerVersusInfo[i].clotskilled = pawnZPRI.clotskilled;
	PlayerVersusInfo[i].bloatskilled = pawnZPRI.bloatskilled;
	PlayerVersusInfo[i].crawlerskilled = pawnZPRI.crawlerskilled;
	PlayerVersusInfo[i].stalkerskilled = pawnZPRI.stalkerskilled;
	PlayerVersusInfo[i].sirenskilled = pawnZPRI.sirenskilled;
	PlayerVersusInfo[i].gorefastskilled = pawnZPRI.gorefastskilled;
	PlayerVersusInfo[i].huskskilled = pawnZPRI.huskskilled;
	PlayerVersusInfo[i].scrakeskilled = pawnZPRI.scrakeskilled;
	PlayerVersusInfo[i].fleshpoundskilled = pawnZPRI.fleshpoundskilled;
}

simulated function PostRender( canvas Canvas )
{
	ZRender(Canvas);
	if( kfgri.CurrentShop != none && !KFGRI.bwaveinprogress )
		DrawVersusInfo( Canvas );
	super.postrender(canvas);
	//DrawNumbers(canvas);
	DrawHud(Canvas);
	HandleSHit(canvas);
	DrawPlayerUnseen(Canvas);	
}

simulated function DrawVersusInfo( canvas Canvas )
{
	local int i;
	//local zombiepri Pawnzpri;
	
		canvas.Font = GetFontSizeIndex(canvas, -1);
		
		/*if( PBIINT < playerversusinfo.length &&  playerowner.pawn != none && playerowner.pawn.isa('kfhumanpawn') )
		{
				if ( PlayerVersusInfo[PBIINT].Pawn == none || PlayerVersusInfo[PBIINT].Pawn != none && PlayerVersusInfo[PBIINT].Pawn.Health < 0 )
				{
					PlayerVersusInfo.Remove(i--, 1);
				}
			if( playerversusinfo.length > 0 )    
			PawnZPRI = ZombiePRI(playerversusinfo[PBIINT].pawn.playerreplicationinfo);
		
			if( LastVInfoUpdate == 0 )
			{
				LastVInfoUpdate = level.timeseconds;
			}
			

				Canvas.SetDrawColor(100,255,100);
				canvas.setpos( 0.1 * Canvas.ClipX, 0.2 * Canvas.ClipY);
				canvas.DrawText("Name",true);
				canvas.setpos( 0.1 * Canvas.ClipX, 0.25 * Canvas.ClipY);
				canvas.DrawText("Clot",true);
				canvas.setpos( 0.1 * Canvas.ClipX, 0.3 * Canvas.ClipY);
				canvas.DrawText("Bloat",true);
				canvas.setpos( 0.1 * Canvas.ClipX, 0.35 * Canvas.ClipY);
				canvas.DrawText("GoreFast",true);
				canvas.setpos( 0.1 * Canvas.ClipX, 0.4 * Canvas.ClipY);
				canvas.DrawText("Crawler",true);
				canvas.setpos( 0.1 * Canvas.ClipX, 0.45 * Canvas.ClipY);
				canvas.DrawText("Stalker",true);
				canvas.setpos( 0.1 * Canvas.ClipX, 0.5 * Canvas.ClipY);
				canvas.DrawText("Siren",true);
				canvas.setpos( 0.1 * Canvas.ClipX, 0.55 * Canvas.ClipY);
				canvas.DrawText("Husk",true);
				canvas.setpos( 0.1 * Canvas.ClipX, 0.6 * Canvas.ClipY);
				canvas.DrawText("Scrake",true);
				canvas.setpos( 0.1 * Canvas.ClipX, 0.65 * Canvas.ClipY);
				canvas.DrawText("FleshPound",true);
			

				
						
			if( PawnZpri != none )
			{
				Canvas.SetDrawColor(100,100,255);
				canvas.setpos( 0.5 * Canvas.ClipX, 0.2 * Canvas.ClipY);
				canvas.DrawText(""$playerversusinfo[PBIINT].pawn.gethumanreadablename(),true);
				canvas.setpos( 0.5 * Canvas.ClipX, 0.25 * Canvas.ClipY);
				canvas.DrawText(""$PawnZPRI.Clotskilled,true);
				canvas.setpos( 0.5 * Canvas.ClipX, 0.3 * Canvas.ClipY);
				canvas.DrawText(""$PawnZPRI.Bloatskilled,true);
				canvas.setpos( 0.5 * Canvas.ClipX, 0.35 * Canvas.ClipY);
				canvas.DrawText(""$PawnZPRI.GoreFastskilled,true);
				canvas.setpos( 0.5 * Canvas.ClipX, 0.4 * Canvas.ClipY);
				canvas.DrawText(""$PawnZPRI.Crawlerskilled,true);
				canvas.setpos( 0.5 * Canvas.ClipX, 0.45 * Canvas.ClipY);
				canvas.DrawText(""$PawnZPRI.Stalkerskilled,true);
				canvas.setpos( 0.5 * Canvas.ClipX, 0.5 * Canvas.ClipY);
				canvas.DrawText(""$PawnZPRI.Sirenskilled,true);
				canvas.setpos( 0.5 * Canvas.ClipX, 0.55 * Canvas.ClipY);
				canvas.DrawText(""$PawnZPRI.Huskskilled,true);
				canvas.setpos( 0.5 * Canvas.ClipX, 0.6 * Canvas.ClipY);
				canvas.DrawText(""$PawnZPRI.Scrakeskilled,true);
				canvas.setpos( 0.5 * Canvas.ClipX, 0.65 * Canvas.ClipY);
				canvas.DrawText(""$PawnZPRI.FleshPoundskilled,true);
				
			
			}

			PawnZPRI = ZombiePRI(playerowner.playerreplicationinfo);
				Canvas.SetDrawColor(255,100,100);
					
			canvas.setpos( 0.8 * Canvas.ClipX, 0.2 * Canvas.ClipY);
			canvas.DrawText("YOU",true);
			canvas.setpos( 0.8 * Canvas.ClipX, 0.25 * Canvas.ClipY);
			canvas.DrawText(""$PawnZPRI.Clotskilled,true);
			canvas.setpos( 0.8 * Canvas.ClipX, 0.3 * Canvas.ClipY);
			canvas.DrawText(""$PawnZPRI.Bloatskilled,true);
			canvas.setpos( 0.8 * Canvas.ClipX, 0.35 * Canvas.ClipY);
			canvas.DrawText(""$PawnZPRI.GoreFastskilled,true);
			canvas.setpos( 0.8 * Canvas.ClipX, 0.4 * Canvas.ClipY);
			canvas.DrawText(""$PawnZPRI.Crawlerskilled,true);
			canvas.setpos( 0.8 * Canvas.ClipX, 0.45 * Canvas.ClipY);
			canvas.DrawText(""$PawnZPRI.Stalkerskilled,true);
			canvas.setpos( 0.8 * Canvas.ClipX, 0.5 * Canvas.ClipY);
			canvas.DrawText(""$PawnZPRI.Sirenskilled,true);
			canvas.setpos( 0.8 * Canvas.ClipX, 0.55 * Canvas.ClipY);
			canvas.DrawText(""$PawnZPRI.Huskskilled,true);
			canvas.setpos( 0.8 * Canvas.ClipX, 0.6 * Canvas.ClipY);
			canvas.DrawText(""$PawnZPRI.Scrakeskilled,true);
			canvas.setpos( 0.8 * Canvas.ClipX, 0.65 * Canvas.ClipY);
			canvas.DrawText(""$PawnZPRI.FleshPoundskilled,true);
		}*/
		/*if( playerowner.pawn != none && playerowner.pawn.isa('monster') )
		{
					canvas.setpos( 0.2 * Canvas.ClipX, (0.2) * Canvas.ClipY);
					canvas.drawText("Name          Damage Score");

			for( i = 0; i<zpri.length; i++)
			{
				if( Zpri[i] != none)
				{		
					canvas.setpos( 0.2 * Canvas.ClipX, (0.3 + (i/10)) * Canvas.ClipY);
					canvas.drawText(""$Zpri[i].playername$"          "$Zpri[i].damage);
				}
			}
		}	*/
		if( 1 < level.timeseconds - LastVInfoUpdate)
		{
			PBIINT++;
			
			if( PBIINT >= playerversusinfo.length )
			   PBIINT = 0;
			   
			LastVInfoUpdate = level.timeseconds;
			
		}
}
simulated function ZRender( canvas Canvas )
{	
	local int XPos, YPos;
	
	/*if( kfmonster(playerowner.pawn) != none )
	{
		
		XPos = 0 * Canvas.ClipX;
		YPos = 0 * Canvas.ClipY;

        
		canvas.setpos(XPos,ypos);
		canvas.style = ERenderStyle.STY_modulated;
		if( awesomeclot(playerowner.pawn) != none )
			 Canvas.SetDrawColor(100,100,255);
		else 
			 Canvas.SetDrawColor(255,100,0);
		Canvas.DrawIcon( texture'dd',20);
		canvas.style = ERenderStyle.STY_Normal;

		Canvas.SetDrawColor(255,255,255);
		canvas.Font = GetFontSizeIndex(canvas, 2);
		
		XPos = 0.0 * Canvas.ClipX;
		YPos = 0.3 * Canvas.ClipY;
		canvas.setpos(XPos,ypos);
		canvas.DrawText(pawnowner.menuname,true);
				
	}*/
		/*	Canvas.SetDrawColor(255,255,255);
		canvas.Font = GetFontSizeIndex(canvas, -2);
		XPos = 0.0 * Canvas.ClipX;
		YPos = 0.1 * Canvas.ClipY;

		canvas.setpos(XPos,ypos);
		Canvas.Drawtext("(When Alive) Type 'Changerace' in console to change teams",true);*/

	if( ZombieGamereplicationinfo(kfgri).bkillthezeds && ZombieGamereplicationinfo(kfgri).killtimer <= 60)
	{
		XPos = 0.8 * Canvas.ClipX;
	   YPos = 0.5 * Canvas.ClipY;

		canvas.setpos(XPos,ypos);
		Canvas.Drawtext("Seconds left",true);	
		
		YPos = 0.55 * Canvas.ClipY;

		canvas.setpos(XPos,ypos);
		Canvas.Drawtext(""$(60-ZombieGametype(PlayerOwner.level.game).killtimer),true);	
	}
		if( ZombieGamereplicationinfo(kfgri).Bossname != "")
	{
		XPos = 0.8 * Canvas.ClipX;
	   YPos = 0.7 * Canvas.ClipY;

		canvas.setpos(XPos,ypos);
		Canvas.Drawtext(""$ZombieGamereplicationinfo(kfgri).Bossname,true);	
		
		YPos = 0.75 * Canvas.ClipY;

		canvas.setpos(XPos,ypos);
		Canvas.Drawtext(""$int(100/(ZombieGamereplicationinfo(kfgri).Bossmaxhealth/ZombieGamereplicationinfo(kfgri).Bosshealth))$"%",true);	
	}
	if( awesomeclot(playerowner.pawn) != none )
	{
			
		XPos = 0.40 * Canvas.ClipX;
		YPos = 0.80 * Canvas.ClipY;

        canvas.Font = GetFontSizeIndex(canvas, 2);
		
		if(playerowner.playerreplicationinfo.bonlyspectator)
		{
			XPos = 0.40 * Canvas.ClipX;
		    	YPos = 0.80 * Canvas.ClipY;
		
			canvas.setpos(XPos,ypos);
			Canvas.SetDrawColor(255,255,255);
			Canvas.Drawtext("You are Spectating (Join Game? press esc)", true);
		}
		else if( !zombiepri(playerowner.playerreplicationinfo).bseen && kfgri.bwaveinprogress )
		{
		
			XPos = 0.40 * Canvas.ClipX;
		    YPos = 0.80 * Canvas.ClipY;
		
			canvas.setpos(XPos,ypos);
			Canvas.SetDrawColor(50,50,255);
			Canvas.Drawtext(usemsg, true);
		}
		else if( kfgri.bwaveinprogress )
		{
			XPos = 0.30 * Canvas.ClipX;
		    YPos = 0.80 * Canvas.ClipY;
		
			canvas.setpos(XPos,ypos);
			Canvas.SetDrawColor(255,50,50);
			Canvas.Drawtext(" You are in Player's sight ", true);
		}
	}	
}
simulated function DrawEnemyInfo(Canvas C, KFMonster A, float Height)
{
	if( !A.isa('awesomeclot') )
	super.DrawEnemyInfo(C, A, Height);
}

simulated function Drawplayerunseen(canvas C)
{
	local int i;
	local pawn P;
	
	For(i = 0; i < 32; i++)
	{		
			P = zombiepri(playerowner.playerreplicationinfo).UnseenPawn[i];
			if( playerowner.pawn != none && P != none && zombieplayercontroller(playerowner).CantSeeMe(P)/* && P!=playerowner.pawn */)
				if((vector(C.Viewport.Actor.CalcViewRotation) Dot (C.Viewport.Actor.CalcViewLocation-P.Location)) <=0 )
				drawTheUnseen(C, P);					
	}
}


simulated function drawTheUnseen(Canvas C, pawn A)
{
	local vector TargetLocation, HBScreenPos;
	local color OldDrawColor;

	//**************
	if (kfhumanpawn(playerowner.pawn)!=none)
		return;
	
	if ( PlayerOwner.Player.GUIController.bActive && GUIController(PlayerOwner.Player.GUIController).ActivePage.Name != 'GUIVeterancyBinder' || A == playerowner.pawn)
	{
		return;
	}

	if( Act != none)
	   Act.destroy();
	   
	OldDrawColor = C.DrawColor;

	TargetLocation = A.Location + vect(0, 0, 1) * (A.CollisionHeight * 2);


	// Target is located behind camera
	HBScreenPos = C.WorldToScreen(TargetLocation);

	if ( HBScreenPos.X <= 0 || HBScreenPos.X >= C.SizeX || HBScreenPos.Y <= 0 || HBScreenPos.Y >= C.SizeY)
	{
		return;
	}

		Act = zombieplayercontroller(playerowner).createactor(A);


			

	if( kfpawn(playerowner.pawn) != none &&  A.isa('kfpawn') || kfmonster(playerowner.pawn) != none)
		C.drawActor( Act, true);	
}
function DrawDoorHealthBars(Canvas C)
{
	local KFDoorMover DamageDoor;
	local vector CameraLocation, CamDir, TargetLocation, HBScreenPos;
	local rotator CameraRotation;
	local name DoorTag;
	local int i;


	if ( Level.TimeSeconds > LastDoorBarHealthUpdate + 0.2 )
	{
		DoorCache.Remove(0, DoorCache.Length);

		C.GetCameraLocation(CameraLocation, CameraRotation);
		foreach CollidingActors(class'KFDoorMover', DamageDoor, 300.00, CameraLocation)//PlayerOwner.Pawn.Location)
		{
			if ( DamageDoor.WeldStrength > 0 )
			{
				DoorCache.Insert(0, 1);
				DoorCache[0] = DamageDoor;

				
				TargetLocation = DamageDoor.WeldIconLocation /*+ vect(0, 0, 1) * Height*/;
				TargetLocation.Z = CameraLocation.Z;
				CamDir	= vector(CameraRotation);

				if ( Normal(TargetLocation - CameraLocation) dot Normal(CamDir) >= 0.1 && DamageDoor.Tag != DoorTag && FastTrace(DamageDoor.WeldIconLocation - ((DoorCache[i].WeldIconLocation - CameraLocation) * 0.25), CameraLocation) )
				{
					HBScreenPos = C.WorldToScreen(TargetLocation);
					DrawDoorBar(C, HBScreenPos.X, HBScreenPos.Y, DamageDoor.WeldStrength / DamageDoor.MaxWeld, 255);
					DoorTag = DamageDoor.Tag;
				}
			}
		}

		LastDoorBarHealthUpdate = Level.TimeSeconds;
	}
	else
	{
		for ( i = 0; i < DoorCache.Length; i++ )
		{
	 		C.GetCameraLocation(CameraLocation, CameraRotation);
			TargetLocation = DoorCache[i].WeldIconLocation /*+ vect(0, 0, 1) * Height*/;
			TargetLocation.Z = CameraLocation.Z;
			CamDir	= vector(CameraRotation);

			if ( Normal(TargetLocation - CameraLocation) dot Normal(CamDir) >= 0.1 && DoorCache[i].Tag != DoorTag && FastTrace(DoorCache[i].WeldIconLocation - ((DoorCache[i].WeldIconLocation - CameraLocation) * 0.25), CameraLocation) )
			{
				HBScreenPos = C.WorldToScreen(TargetLocation);
				DrawDoorBar(C, HBScreenPos.X, HBScreenPos.Y, DoorCache[i].WeldStrength / DoorCache[i].MaxWeld, 255);
				DoorTag = DoorCache[i].Tag;
			}
		}
	}
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
			if ( PlayerInfoPawns[i].Pawn != none && PlayerInfoPawns[i].Pawn.Health > 0 &&
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
	
	if((Awesomepat(PlayerOwner.Pawn)!=none || awesomeHusk(PlayerOwner.Pawn)!=none))
	{
		//CMaterial = Texture'2K4Menus.Controls.Plus_b';
		C.Style = ERenderStyle.STY_Alpha;
		C.SetDrawColor(255, 255, 255, 255);
		C.SetPos(C.ClipX/2-2, C.ClipY/2-2);
		C.DrawTile(CMaterial, 4, 4, 0, 0, CMaterial.MaterialUSize(), CMaterial.MaterialVSize());
	}
}

/*DrawHudPassA(Canvas C)
{
	super.DrawHudPassA(C)
}*/


function DrawPlayerInfo(Canvas C, Pawn P, float ScreenLocX, float ScreenLocY)
{
	local float XL, YL, TempX, TempY, TempSize;
	local string PlayerName;
	local float Dist, OffsetX;
	local byte BeaconAlpha;
	local float OldZ;
	local Material TempMaterial;
	local int i;

	if ( pawnowner == none)
	{
		return;
	}
	
	if((vector(C.Viewport.Actor.CalcViewRotation) Dot (C.Viewport.Actor.CalcViewLocation-P.Location)) >0 )
		return;

	Dist = vsize(P.Location - PawnOwner.Location);
	Dist -= HealthBarFullVisDist;
	Dist = FClamp(Dist, 0, HealthBarCutoffDist-HealthBarFullVisDist);
	Dist = Dist / (HealthBarCutoffDist - HealthBarFullVisDist);
	BeaconAlpha = byte((1.f - Dist) * 255.f);

	//if ( BeaconAlpha == 0 )
	//{
	//	return;
	//}

	OldZ = C.Z;
	C.Z = 1.0;
	C.Style = ERenderStyle.STY_Alpha;
	C.SetDrawColor(255, 255, 255, BeaconAlpha);
	C.Font = GetConsoleFont(C);
	if (P.PlayerReplicationInfo!=none)
	PlayerName = Left(P.PlayerReplicationInfo.PlayerName, 16);
	C.StrLen(PlayerName, XL, YL);
	C.SetPos(ScreenLocX - (XL * 0.5), ScreenLocY - (YL * 0.75));
	C.DrawTextClipped(PlayerName);

	OffsetX = (36.f * VeterancyMatScaleFactor * 0.6) - (HealthIconSize + 2.0);

	if ( KFPlayerReplicationInfo(P.PlayerReplicationInfo)!=none && KFPlayerReplicationInfo(P.PlayerReplicationInfo).ClientVeteranSkill != none &&
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
	}

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
simulated function DrawHealthBar(Canvas C, Actor A, int Health, int MaxHealth, float Height)
{
	local vector CameraLocation, CamDir, TargetLocation, HBScreenPos;
	local rotator CameraRotation;
	local float Dist, HealthPct;
	local color OldDrawColor;

	// rjp --  don't draw the health bar if menus are open
	// exception being, the Veterancy menu

	if ( PlayerOwner.Player.GUIController.bActive && GUIController(PlayerOwner.Player.GUIController).ActivePage.Name != 'GUIVeterancyBinder' || A.isa('awesomeclot') )
	{
		return;
	}

	OldDrawColor = C.DrawColor;

	C.GetCameraLocation(CameraLocation, CameraRotation);
	TargetLocation = A.Location + vect(0, 0, 1) * (A.CollisionHeight * 2);
	Dist = VSize(TargetLocation - CameraLocation);

	CamDir  = vector(CameraRotation);

	// Check Distance Threshold / behind camera cut off
	if ( Dist > HealthBarCutoffDist || (Normal(TargetLocation - CameraLocation) dot CamDir) < 0 )
	{
		//return;
	}

	// Target is located behind camera
	HBScreenPos = C.WorldToScreen(TargetLocation);

	if ( HBScreenPos.X <= 0 || HBScreenPos.X >= C.SizeX || HBScreenPos.Y <= 0 || HBScreenPos.Y >= C.SizeY)
	{
		return;
	}

	if ( FastTrace(TargetLocation, CameraLocation) )
	{
		C.SetDrawColor(192, 192, 192, 255);
		C.SetPos(HBScreenPos.X - EnemyHealthBarLength * 0.5, HBScreenPos.Y);
		C.DrawTileStretched(WhiteMaterial, EnemyHealthBarLength, EnemyHealthBarHeight);

		HealthPct = 1.0f * Health / MaxHealth;

		C.SetDrawColor(255, 0, 0, 255);
		C.SetPos(HBScreenPos.X - EnemyHealthBarLength * 0.5 + 1.0, HBScreenPos.Y + 1.0);
		C.DrawTileStretched(WhiteMaterial, (EnemyHealthBarLength - 2.0) * HealthPct, EnemyHealthBarHeight - 2.0);
	}

	C.DrawColor = OldDrawColor;
}

defaultproperties
{
     usemsg="Press Door Key"
	 CMaterial = Texture'KillingFloorHUD.HUD.WhiteTexture'
}
