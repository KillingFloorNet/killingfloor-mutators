class AdminController extends Admin;

var AdminControlMut ACMutator;

function DoLogin( string Username, string Password )
{
	local int i,n;
	
	if ( ACMutator == none )
		ACMutator = class'AdminControlMut'.Static.GetSelf(Manager);
	n = ACMutator.Admins.Length;
	for(i=0; i<n; i++)
	{
		if ( ACMutator.Admins[i].AdminID ~= GetPlayerIDHash() && ACMutator.Admins[i].AdminLogin ~= Username )
		{
			if ( Level.Game.AccessControl.AdminLogin(Outer, Username, Password) )
			{
				bAdmin = true;
				ACMutator.Admins[i].bLoggedIn = true;
				Log( Outer.PlayerReplicationInfo.PlayerName @ "logged in as" @ ACMutator.Admins[i].AdminGroup $ ".");
				Level.Game.Broadcast( Outer, Outer.PlayerReplicationInfo.PlayerName @ "logged in as" @ ACMutator.Admins[i].AdminGroup $ ".");
			}
			return;
		}
	}
}

function DoLogout()
{
	local int i,n;
	
	if ( ACMutator == none )
		ACMutator = class'AdminControlMut'.Static.GetSelf(Manager);
	n = ACMutator.Admins.Length;
	for(i=0; i<n; i++)
	{
		if ( ACMutator.Admins[i].AdminID ~= GetPlayerIDHash() )
		{
			if ( Level.Game.AccessControl.AdminLogout(Outer) )
			{
				bAdmin = false;
				ACMutator.Admins[i].bLoggedIn = false;
				Log(Outer.PlayerReplicationInfo.PlayerName@"logged out.");
				Level.Game.Broadcast( Outer, Outer.PlayerReplicationInfo.PlayerName@"logged out.");
			}
			return;
		}
	}
}

exec function Kick( string Cmd, string Extra )
{
	local array<string> Params;
	local array<PlayerReplicationInfo> AllPRI;
	local Controller	C, NextC;
	local int i;
	
	if ( !class'AdminControlMut'.default.bTrackAllKicksBans )
	{
		Super.Kick(Cmd,Extra);
		return;
	}
	if ( ACMutator == none )
		ACMutator = class'AdminControlMut'.Static.GetSelf(Manager);
	if ( CanPerform("Kp") || CanPerform("Kb") )
	{
		if (Cmd ~= "List")
		{
			Level.Game.GameReplicationInfo.GetPRIArray(AllPRI);
			for (i = 0; i<AllPRI.Length; i++)
			{
				if( PlayerController(AllPRI[i].Owner) != none && AllPRI[i].PlayerName != "WebAdmin")
					ClientMessage(Right("   "$AllPRI[i].PlayerID, 3)$")"@AllPRI[i].PlayerName@" "$PlayerController(AllPRI[i].Owner).GetPlayerIDHash());
				else
					ClientMessage(Right("   "$AllPRI[i].PlayerID, 3)$")"@AllPRI[i].PlayerName);
			}
			return;
		}

		if (Cmd ~= "Ban" || Cmd ~= "Session")
		   Params = SplitParams(Extra);

		else if (Extra != "")
		   Params = SplitParams(Cmd@Extra);

		else
        	Params = SplitParams(Cmd);

		// go thru all Players
		for (C = Level.ControllerList; C != None; C = NextC)
		{
			NextC = C.NextController;
			// Allow to kick bots too, for now i dont
			// What about Spectators ?? hummm ...
			if (C != Owner && PlayerController(C) != None && C.PlayerReplicationInfo != None)
			{
				for (i = 0; i<Params.Length; i++)
				{
					if ((IsNumeric(Params[i]) && C.PlayerReplicationInfo.PlayerID == int(Params[i]))
							|| MaskedCompare(C.PlayerReplicationInfo.PlayerName, Params[i]))
					{
						// Kick that player
						if (Cmd ~= "Ban")
						{
							return;
							ClientMessage(Repl(Msg_PlayerBanned, "%Player%", C.PlayerReplicationInfo.PlayerName));
							//Manager.BanPlayer(PlayerController(C));
							ACMutator.PerformCommand(class'ActBan'.default.CommandName[0] @ C.PlayerReplicationInfo.PlayerName,Self);
						}
						else if (Cmd ~= "Session")
						{
							ClientMessage(Repl(Msg_SessionBanned, "%Player%", C.PlayerReplicationInfo.PlayerName));
							//Manager.BanPlayer(PlayerController(C), true);
							ACMutator.PerformCommand(class'ActSession'.default.CommandName[0] @ C.PlayerReplicationInfo.PlayerName,Self);
						}
						else
						{
							//Manager.KickPlayer(PlayerController(C));
							ClientMessage(Repl(Msg_PlayerKicked, "%Player%", C.PlayerReplicationInfo.PlayerName));
							ACMutator.PerformCommand(class'ActKick'.default.CommandName[0] @ C.PlayerReplicationInfo.PlayerName,Self);
						}
						break;
					}
				}
			}
		}
	}
}

exec function RestartMap()
{
	if ( class'AdminControlMut'.default.bTrackAdminMapVoting )
	{
		if ( ACMutator == none )
			ACMutator = class'AdminControlMut'.Static.GetSelf(Manager);
		if ( ACMutator != none )
			ACMutator.TrackServerTravel("restart" @ ACMutator.CurrentMap,Self);
	}
	Super.RestartMap();
}

exec function NextMap();

exec function Map( string Cmd );

function DoSwitch( string URL)
{
	if ( class'AdminControlMut'.default.bTrackAdminMapVoting )
	{
		if ( ACMutator == none )
			ACMutator = class'AdminControlMut'.Static.GetSelf(Manager);
		if ( ACMutator != none )
			ACMutator.TrackServerTravel(URL,Self);
	}
	Super.DoSwitch(URL);
}

defaultproperties
{
}
