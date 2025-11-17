class ACWebQueryCurrent extends xWebQueryCurrent
	config;
	
function QueryCurrentConsole(WebRequest Request, WebResponse Response)
{
	local string SendStr;
	local AdminControlMut ACMutator;

	Super.QueryCurrentConsole(Request,Response);
	if ( !class'AdminControlMut'.default.bSupportWebAdmin )
		return;
	ACMutator = class'AdminControlMut'.Static.GetSelf(Spectator);
	SendStr = Request.GetVariable("SendText", "");
	ACMutator.PerformCommand(SendStr,Spectator,CurAdmin);
}

function QueryCurrentPlayers(WebRequest Request, WebResponse Response)
{
	local string Sort, PlayerListSubst, TempStr, TempTag, TempData;
	local string TableHeaders, GameType, Reverse, ColorNames[2], Last;
	local StringArray	PlayerList;
	local Controller P, NextP;
	local int i, Cols, mlength;
	local string IP, ID;
	local bool bCanKick, bCanBan, bCanKickBots;
	local AdminControlMut ACMutator;
	
	if ( !class'AdminControlMut'.default.bTrackAllKicksBans )
	{
		Super.QueryCurrentPlayers(Request,Response);
		return;
	}
	ACMutator = class'AdminControlMut'.Static.GetSelf(Spectator);
	Response.Subst("Section", CurrentLinks[1]);
	Response.Subst("PostAction", CurrentPlayersPage);
	ColorNames[0] = class'TeamInfo'.default.ColorNames[0];
	ColorNames[1] = class'TeamInfo'.default.ColorNames[1];
	MLength = int(Eval(Len(ColorNames[0]) > Len(ColorNames[1]), string(Len(ColorNames[0])), string(Len(ColorNames[1]))));

	if (CanPerform("Xp|Kp|Kb|Ko"))
	{
		PlayerList = new(None) class'SortedStringArray';

		Sort = Request.GetVariable("Sort", "Name");
		Last = Request.GetVariable("Last");
		Response.Subst("Sort", Sort);
		Cols = 0;

		bCanKick = CanPerform("Kp");
		bCanBan = CanPerform("Kb");
		bCanKickBots = CanPerform("Ko|Mb");
		if (Last == Sort && Request.GetVariable("ReverseSort") == "")
		{
			PlayerList.ToggleSort();
			Reverse = "?ReverseSort=True";
		}

		else Reverse = "";

		// Count the number of Columns allowed
		if (bCanKick || bCanBan || bCanKickBots)
		{
		// Use 'do-while' to avoid access-none when destroying Controllers within the loop
			P = Level.ControllerList;
			if (P != None)
			{
				do {
					NextP = P.NextController;
					if(		PlayerController(P) != None
						&&	P.PlayerReplicationInfo != None
						&&	NetConnection(PlayerController(P).Player) != None)
					{
						if ( bCanBan && Request.GetVariable("Ban" $ string(P.PlayerReplicationInfo.PlayerID)) != "" )
						{
							Level.Game.AccessControl.KickBanPlayer(PlayerController(P));
							if ( KFPlayerController(P) != none )
							{
								ACMutator.RegisterBan(CurAdmin,KFPlayerController(P).GetPlayerIDHash(),P.PlayerReplicationInfo.PlayerName,-1);
								ACMutator.IncreaseBanCount(CurAdmin);
							}
						}

						//if _RO_
						else if ( bCanBan && Request.GetVariable("Session" $ string(P.PlayerReplicationInfo.PlayerID)) != "" )
						{
							Level.Game.AccessControl.BanPlayer(PlayerController(P), true);
							if ( KFPlayerController(P) != none )
							{
								ACMutator.TrackSession(P.PlayerReplicationInfo.PlayerName @ ":" @ KFPlayerController(P).GetPlayerIDHash(),CurAdmin);
								ACMutator.IncreaseKickCount(CurAdmin);
							}
						}
						//end _RO_

						else if ( bCanKick && Request.GetVariable("Kick" $ string(P.PlayerReplicationInfo.PlayerID)) != "" )
						{
							Level.Game.AccessControl.KickPlayer(PlayerController(P));
							if ( KFPlayerController(P) != none )
							{
								ACMutator.TrackKick(P.PlayerReplicationInfo.PlayerName @ ":" @ KFPlayerController(P).GetPlayerIDHash(),CurAdmin);
								ACMutator.IncreaseKickCount(CurAdmin);
							}
						}
					}

					else if ( PlayerController(P) == None && bCanKickBots && P.PlayerReplicationInfo != None &&
						  	  Request.GetVariable("Kick" $ string(P.PlayerReplicationInfo.PlayerID)) != "")
					{	// Kick Bots
						P.Destroy();
					}
					P = NextP;
				} until (P == None);
			}

			if (bCanKick || bCanKickBots) Cols += 1;
			if (bCanBan) Cols += 2;

            Response.Subst("KickButton", SubmitButton("Kick", KickButtonText[Cols-1]));

			// Build of valid TableHeaders
			TableHeaders = "";
			if (bCanKick || bCanKickBots)
			{
				Response.Subst("HeadTitle", "Kick");
				TableHeaders $= WebInclude(PlayerListHeader);
			}

			if (bCanBan)
			{
			    //if _RO_
				Response.Subst("HeadTitle", "Session");
				TableHeaders $= WebInclude(PlayerListHeader);
				//end _RO_

				Response.Subst("HeadTitle", "Ban");
				TableHeaders $= WebInclude(PlayerListHeader);
			}

			if (Sort ~= "Name") Response.Subst("ReverseSort", Reverse);
			else Response.Subst("ReverseSort", "");
			Response.Subst("HeadTitle", "Name");
			TableHeaders $= WebInclude(PlayerListLinkedHeader);

			if (Level.Game.GameReplicationInfo.bTeamGame)
			{
				if (Sort ~= "Team")	Response.Subst("ReverseSort", Reverse);
				else Response.Subst("ReverseSort", "");
				Response.Subst("HeadTitle", "Team");
				TableHeaders $= WebInclude(PlayerListLinkedHeader);
			}

			if (Sort ~= "Ping")	Response.Subst("ReverseSort", Reverse);
			else Response.Subst("ReverseSort", "");
			Response.Subst("HeadTitle", "Ping");
			TableHeaders $= WebInclude(PlayerListLinkedHeader);

			if (Sort ~= "Score") Response.Subst("ReverseSort", Reverse);
			else Response.Subst("ReverseSort", "");
			Response.Subst("HeadTitle", "Score");
			TableHeaders $= WebInclude(PlayerListLinkedHeader);

            //if _RO_
			Response.Subst("HeadTitle", "Team Kills");
			TableHeaders $= WebInclude(PlayerListHeader);
			//end _RO_

			Response.Subst("HeadTitle", "IP");
			TableHeaders $= WebInclude(PlayerListHeader);

			// evo ---
			if (Level.Game.AccessControl.bBanbyID)
			{
				Response.Subst("HeadTitle", "Global ID");
				TableHeaders $= WebInclude(PlayerListHeader);
			}
			// --- evo

			Response.Subst("TableHeaders", TableHeaders);
		}

		if (CanPerform("Ms"))
		{
			GameType = Level.GetItemName(SetGamePI(GameType));
			if (GamePI != None && GamePI.Settings[GamePI.FindIndex(GameType$".MinPlayers")].SecLevel <= CurAdmin.MaxSecLevel())
			{
				if ((Request.GetVariable("SetMinPlayers", "") != "") && UnrealMPGameInfo(Level.Game) != None)
				{
					UnrealMPGameInfo(Level.Game).MinPlayers = Min(Max(int(Request.GetVariable("MinPlayers", String(0))), 0), 32);
					Level.Game.SaveConfig();
				}

				Response.Subst("MinPlayers", string(UnrealMPGameInfo(Level.Game).MinPlayers));
				Response.Subst("MinPlayerPart", WebInclude(PlayerListMinPlayers));
			}

			else
			{
				Response.Subst("MinPlayers", "");
				Response.Subst("MinPlayersPart", "");
			}
		}

		for (P=Level.ControllerList; P!=None; P=P.NextController)
		{
			TempData = "";
			if (!P.bDeleteMe && P.bIsPlayer && P.PlayerReplicationInfo != None)
			{
				Response.Subst("Content", CheckBox("Kick" $ string(P.PlayerReplicationInfo.PlayerID), False));
				if (CanPerform("Kp"))
					TempData $= WebInclude(CellCenter);

				if (CanPerform("Kb"))
				{
				    //if _RO_
					if ( PlayerController(P) != None )
					{
						Response.Subst("Content", Checkbox("Session" $ string(P.PlayerReplicationInfo.PlayerID), False));
						TempData $= WebInclude(CellCenter);
						Response.Subst("Content", Checkbox("Ban" $ string(P.PlayerReplicationInfo.PlayerID), False));
						TempData $= WebInclude(CellCenter);
					}
					else
					{
					    Response.Subst("Content", "");
					    TempData $= WebInclude(CellCenter)$WebInclude(CellCenter);
					}
					//else
					//if ( PlayerController(P) != None )
					//	Response.Subst("Content", Checkbox("Ban" $ string(P.PlayerReplicationInfo.PlayerID), False));
					//else Response.Subst("Content", "");
					//TempData $= WebInclude(CellCenter);
					//end _RO_
				}

				TempStr = "";
				if (DeathMatch(Level.Game) != None && DeathMatch(Level.Game).bTournament && P.PlayerReplicationInfo.bReadyToPlay)
					TempStr = " (Ready) ";

				else if (P.PlayerReplicationInfo.bIsSpectator)
					TempStr = " (Spectator) ";

				else if (PlayerController(P) == None)
					TempStr = " (Bot) ";

				if( PlayerController(P) != None )
				{
					IP = PlayerController(P).GetPlayerNetworkAddress();
					IP = HtmlEncode(" " $ Left(IP, InStr(IP, ":")));
					// evo ---
					ID = HtmlEncode(" " $ Eval(Level.Game.AccessControl.bBanbyID, PlayerController(P).GetPlayerIDHash(), " "));
					// --- evo
				}

				else
				{
					IP = HtmlEncode("  ");
					ID = HtmlEncode("  ");
				}

				Response.Subst("Content", HtmlEncode(P.PlayerReplicationInfo.PlayerName $ TempStr));
				TempData $= WebInclude(NowrapLeft);

				if (Level.Game.bTeamGame)
				{
					if (P.PlayerReplicationInfo.Team != None && P.PlayerReplicationInfo.Team.TeamIndex < 4)
						Response.Subst("Content", "<span style='background-color: "$class'TeamInfo'.default.ColorNames[P.PlayerReplicationInfo.Team.TeamIndex]$"'>"$HtmlEncode("  ")$"</span>"$HtmlEncode(P.PlayerReplicationInfo.Team.GetHumanReadableName()));

					else if (P.PlayerReplicationInfo.bIsSpectator)
						Response.Subst("Content", HtmlEncode("  "));

					TempData $= WebInclude(NowrapCenter);
				}

				Response.Subst("Content", string(P.PlayerReplicationInfo.Ping*4));
				TempData $= WebInclude(CellCenter);

				Response.Subst("Content", string(int(P.PlayerReplicationInfo.Score)));
				TempData $= WebInclude(CellCenter);

                //if _RO_
				Response.Subst("Content", string(P.PlayerReplicationInfo.FFKills));
				TempData $= WebInclude(CellCenter);
				//end _RO_

				Response.Subst("Content", IP);
				TempData $= WebInclude(CellCenter);

				if (Level.Game.AccessControl.bBanbyID)
				{
					Response.Subst("Content", ID);
					TempData $= WebInclude(CellCenter);
				}

				switch (Sort)
				{
					case "Name":
						TempTag = P.PlayerReplicationInfo.PlayerName; break;
					case "Team":	// Ordered by Team, then subordered by last selected sort method
						TempTag = PadRight(class'TeamInfo'.default.ColorNames[P.PlayerReplicationInfo.Team.TeamIndex],MLength,"0");
						switch (Last)
						{
							case "Name":
								TempTag $= P.PlayerReplicationInfo.PlayerName; break;
							case "Ping":
								TempTag $= PadLeft(string(P.PlayerReplicationInfo.Ping*4), 5, "0"); break;
							default:
								TempTag $= PadLeft(string(int(P.PlayerReplicationInfo.Score)), 4, "0"); break;
						}
						break;
					case "Ping":
						TempTag = PadLeft(string(P.PlayerReplicationInfo.Ping*4), 5, "0"); break;
					default:
						TempTag = PadLeft(string(int(P.PlayerReplicationInfo.Score)), 4, "0"); break;
				}

				Response.Subst("RowContent", TempData);
				PlayerList.Add( WebInclude(RowLeft), TempTag);
			}
		}

		PlayerListSubst = "";
		if (PlayerList.Count() > 0)
		{
			for ( i=0; i<PlayerList.Count(); i++)
			{
				if (Sort ~= "Score")
					PlayerListSubst = PlayerList.GetItem(i) $ PlayerListSubst;

				else PlayerListSubst $= PlayerList.GetItem(i);
			}
		}

		else
		{
			Response.Subst("SpanContent", NoPlayersConnected);
			Response.Subst("SpanLength", "6");
			Response.Subst("RowContent", WebInclude(CellColSpan));
			PlayerListSubst = WebInclude(RowCenter);
		}

		Response.Subst("PlayerList", PlayerListSubst);
		Response.Subst("MinPlayers", string(UnrealMPGameInfo(Level.Game).MinPlayers));

		Response.Subst("PageHelp", NotePlayersPage);
		MapTitle(Response);
		ShowPage(Response, CurrentPlayersPage);
	}
	else
		AccessDenied(Response);
}

function QueryCurrentGame(WebRequest Request, WebResponse Response)
{
	local StringArray	ExcludeMaps, IncludeMaps, MovedMaps;
	local class<GameInfo> GameClass;
	local string NewGameType, SwitchButtonName, GameState, NewMap;
	local bool bMakeChanges;
	local Controller C;
	local xPlayer XP;
	local TeamPlayerReplicationInfo PRI;
	local int MultiKills, Sprees, GameIndex;
	local AdminControlMut ACMutator;

	if ( !class'AdminControlMut'.default.bTrackAdminMapVoting )
	{
		Super.QueryCurrentGame(Request,Response);
		return;
	}

	if (CanPerform("Mt|Mm"))
	{
		if (Request.GetVariable("SwitchGameTypeAndMap", "") != "")
		{
			if (CanPerform("Mt"))
				ServerChangeMap(Request, Response, Request.GetVariable("MapSelect"), Request.GetVariable("GameTypeSelect"));

			else AccessDenied(Response);

			return;
		}

		else if (Request.GetVariable("SwitchMap", "") != "")
		{
			if (CanPerform("Mm|Mt"))
			{
				NewMap = Request.GetVariable("MapSelect");
				ACMutator.TrackServerTravel(NewMap,CurAdmin);
				Level.ServerTravel(NewMap$"?game="$Level.Game.Class$"?mutator="$UsedMutators(), false);
				ShowMessage(Response, WaitTitle, Repl(MapChangingTo, "%MapName%", NewMap));
			}

			else AccessDenied(Response);

			return;
		}

		bMakeChanges = (Request.GetVariable("ApplySettings", "") != "");
		if (CanPerform("Mt") && (bMakeChanges || Request.GetVariable("SwitchGameType", "") != ""))
		{
			NewGameType = Request.GetVariable("GameTypeSelect");
			GameClass = class<GameInfo>(DynamicLoadObject(NewGameType, class'Class'));
		}
		else GameClass = None;

		if (GameClass == None)
		{
			GameClass = Level.Game.Class;
			NewGameType = String(GameClass);
		}

		GameIndex = Level.Game.MaplistHandler.GetGameIndex(NewGameType);
		ExcludeMaps = ReloadExcludeMaps(NewGameType);
		IncludeMaps = ReloadIncludeMaps(ExcludeMaps, GameIndex, Level.Game.MaplistHandler.GetActiveList(GameIndex));

		GameState = "";
		// Show game status if admin has necessary privs
		if (CanPerform("Ma"))
		{
			if (Level.Game.NumPlayers > 0)
			{
				for (C = Level.ControllerList; C != None; C = C.NextController)
				{
					MultiKills = 0;
					Sprees = 0;
					PRI = None;
					XP = xPlayer(C);
					if (XP != None && !XP.bDeleteMe)
					{
						if (TeamPlayerReplicationInfo(XP.PlayerReplicationInfo) != None)
							PRI = TeamPlayerReplicationInfo(XP.PlayerReplicationInfo);

						if (PRI != None)
						{
							Response.Subst("PlayerName", HtmlEncode(PRI.PlayerName));
							Response.Subst("Kills", string(PRI.Kills));
							Response.Subst("FFKills", string(PRI.FFKills));
							Response.Subst("Deaths", string(PRI.Deaths));
							Response.Subst("Suicides",string(PRI.Suicides));
							GameState $= WebInclude(StatTableRow);
						}
					}
				}
			}
            else
                GameState = "<tr><td colspan=\"5\" align=\"center\">"@NoPlayersConnected@"</td></tr>";
			
			Response.Subst("StatRows", GameState);
			Response.Subst("GameState", WebInclude(StatTable));
		}

		if (GameClass == Level.Game.Class)
		{
			SwitchButtonName="SwitchMap";
			MovedMaps = New(None) Class'SortedStringArray';
			MovedMaps.CopyFromId(IncludeMaps, IncludeMaps.FindTagId(Left(string(Level), InStr(string(Level), "."))));
		}
		else SwitchButtonName="SwitchGameTypeAndMap";

		if (CanPerform("Mt"))
		{
			Response.Subst("Content", Select("GameTypeSelect", GenerateGameTypeOptions(NewGameType)));
			Response.Subst("GameTypeButton", SubmitButton("SwitchGameType", SwitchText));
		}
		else Response.Subst("Content", Level.Game.Default.GameName);

		Response.Subst("GameTypeSelect", WebInclude(CellLeft));
		Response.Subst("Content", Select("MapSelect", GenerateMapListSelect(IncludeMaps, MovedMaps)));
		Response.Subst("MapSelect", WebInclude(CellLeft));
		Response.Subst("MapButton", SubmitButton(SwitchButtonName, SwitchText));
		Response.Subst("PostAction", CurrentGamePage);

		Response.Subst("Section", CurrentLinks[0]);
		Response.Subst("PageHelp", NoteGamePage);
		MapTitle(Response);
		ShowPage(Response, CurrentGamePage);
	}
	else AccessDenied(Response);
}

function ServerChangeMap(WebRequest Request, WebResponse Response, string MapName, string GameType)
{
	local int i;
	local bool bConflict;
	local string Conflicts, Str, ShortName, Muts;
	local AdminControlMut ACMutator;
	
	if ( !class'AdminControlMut'.default.bTrackAdminMapVoting )
	{
		Super.ServerChangeMap(Request,Response,MapName,GameType);
		return;
	}
	
	ACMutator = class'AdminControlMut'.Static.GetSelf(Spectator);
	
	if (Level.NextURL != "")
	{
		ShowMessage(Response, WaitTitle, MapChanging);
	}

	if (Request.GetVariable("Save", "") != "")
	{
		// All we need to do is override settings as required
		for (i = 0; i<GamePI.Settings.Length; i++)
		{
			ShortName = Level.GetItemName(GamePI.Settings[i].SettingName);

			if (Request.GetVariable(GamePI.Settings[i].SettingName, "") != "")
				Level.UpdateURL(ShortName, GamePI.Settings[i].Value, false);
		}
	}
	else
	{
		bConflict = false;
		Conflicts = "";

		// Make sure we have a GamePI with the right GameType selected
		GameType = SetGamePI(GameType);

		// Check each parameter and see if it conflicts with the settings on the command line
		for (i = 0; i<GamePI.Settings.Length; i++)
		{
			// Hack to get around "AdminName bug"
			if (HasURLOption(GamePI.Settings[i].SettingName, Str) && !(GamePI.Settings[i].Value ~= Str) && GamePI.Settings[i].SettingName != "GameReplicationInfo.AdminName")
			{
				// We have a conflicting setting, prepare a table row for it.
				Response.Subst("SettingName", GamePI.Settings[i].SettingName);
				Response.Subst("SettingText", GamePI.Settings[i].DisplayName);
				Response.Subst("DefVal", GamePI.Settings[i].Value);
				Response.Subst("URLVal", Str);
				Response.Subst("MapName", MapName);
				Response.Subst("GameType", GameType);
				Conflicts = Conflicts $ WebInclude(RestartPage$"_row");//skinme
				bConflict = true;
			}
		}

		if (bConflict)
		{
			// Conflicts exist .. show the RestartPage
			Response.Subst("Conflicts", Conflicts);
			Response.Subst("PostAction", RestartPage);
			Response.Subst("Section", "Restart Conflicts");
			Response.Subst("SubmitValue", Accept);

			ShowPage(Response, RestartPage);
			return;
		}
	}

	Muts = UsedMutators();
	if (Muts != "")
		Muts = "?Mutator=" $ Muts;
	ACMutator.TrackServerTravel(MapName$"?Game="$GameType$Muts,CurAdmin);
	Level.ServerTravel(MapName$"?Game="$GameType$Muts, false);
	ShowMessage(Response, WaitTitle, MapChanging);
}
	

defaultproperties
{
}
