class ACVotingHandler extends KFMapVoteV2.KFVotingHandler;

var Actor KickInstigator;

function SubmitMapVote(int MapIndex, int GameIndex, Actor Voter)
{
	local int Index, VoteCount, PrevMapVote, PrevGameVote;
	local MapHistoryInfo MapInfo;
	local bool bAdminForce;
	local AdminControlMut ACMutator;
	
	if ( !class'AdminControlMut'.default.bTrackAdminMapVoting )
	{
		Super.SubmitMapVote(MapIndex,GameIndex,Voter);
		return;
	}

	if(bLevelSwitchPending)
		return;

	Index = GetMVRIIndex(PlayerController(Voter));
	if( GameIndex<0 )
	{
		bAdminForce = true;
		GameIndex = (-GameIndex) - 1;
	}
	if( GameIndex>=GameConfig.Length || MapIndex<0 || MapIndex>=MapList.Length )
		return; // Something is wrong...

	// check for invalid vote from unpatch players
	if( !IsValidVote(MapIndex, GameIndex) )
		return;

	if( bAdminForce && (PlayerController(Voter).PlayerReplicationInfo.bAdmin || PlayerController(Voter).PlayerReplicationInfo.bSilentAdmin) )  // Administrator Vote
	{
		TextMessage = lmsgAdminMapChange;
		TextMessage = Repl(TextMessage, "%mapname%", MapList[MapIndex].MapName $ "(" $ GameConfig[GameIndex].Acronym $ ")");
		Level.Game.Broadcast(self,TextMessage);

		log("Admin has forced map switch to " $ MapList[MapIndex].MapName $ "(" $ GameConfig[GameIndex].Acronym $ ")",'MapVote');
		

		CloseAllVoteWindows();

		bLevelSwitchPending = true;

		MapInfo = History.PlayMap(MapList[MapIndex].MapName);

		ServerTravelString = SetupGameMap(MapList[MapIndex], GameIndex, MapInfo);
		log("ServerTravelString = " $ ServerTravelString ,'MapVoteDebug');
		
		ACMutator = class'AdminControlMut'.Static.GetSelf(Voter);
		if ( ACMutator != none )
			ACMutator.TrackServerTravel(ServerTravelString,Voter);
		Level.ServerTravel(ServerTravelString, false);    // change the map

		settimer(1,true);
		return;
	}

	// check for invalid map, invalid gametype, player isnt revoting same as previous vote, and map choosen isnt disabled
	if(MapIndex < 0 ||
		MapIndex >= MapCount ||
		GameIndex >= GameConfig.Length ||
		(MVRI[Index].GameVote == GameIndex && MVRI[Index].MapVote == MapIndex) ||
		!MapList[MapIndex].bEnabled)
		return;

	log("___" $ Index $ " - " $ PlayerController(Voter).PlayerReplicationInfo.PlayerName $ " voted for " $ MapList[MapIndex].MapName $ "(" $ GameConfig[GameIndex].Acronym $ ")",'MapVote');

	PrevMapVote = MVRI[Index].MapVote;
	PrevGameVote = MVRI[Index].GameVote;
	MVRI[Index].MapVote = MapIndex;
	MVRI[Index].GameVote = GameIndex;

	if(bAccumulationMode)
	{
		if(bScoreMode)
		{
			VoteCount = GetAccVote(PlayerController(Voter)) + int(GetPlayerScore(PlayerController(Voter)));
			TextMessage = lmsgMapVotedForWithCount;
			TextMessage = repl(TextMessage, "%playername%", PlayerController(Voter).PlayerReplicationInfo.PlayerName );
			TextMessage = repl(TextMessage, "%votecount%", string(VoteCount) );
			TextMessage = repl(TextMessage, "%mapname%", MapList[MapIndex].MapName $ "(" $ GameConfig[GameIndex].Acronym $ ")" );
			Level.Game.Broadcast(self,TextMessage);
		}
		else
		{
			VoteCount = GetAccVote(PlayerController(Voter)) + 1;
			TextMessage = lmsgMapVotedForWithCount;
			TextMessage = repl(TextMessage, "%playername%", PlayerController(Voter).PlayerReplicationInfo.PlayerName );
			TextMessage = repl(TextMessage, "%votecount%", string(VoteCount) );
			TextMessage = repl(TextMessage, "%mapname%", MapList[MapIndex].MapName $ "(" $ GameConfig[GameIndex].Acronym $ ")" );
			Level.Game.Broadcast(self,TextMessage);
		}
	}
	else
	{
		if(bScoreMode)
		{
			VoteCount = int(GetPlayerScore(PlayerController(Voter)));
			TextMessage = lmsgMapVotedForWithCount;
			TextMessage = repl(TextMessage, "%playername%", PlayerController(Voter).PlayerReplicationInfo.PlayerName );
			TextMessage = repl(TextMessage, "%votecount%", string(VoteCount) );
			TextMessage = repl(TextMessage, "%mapname%", MapList[MapIndex].MapName $ "(" $ GameConfig[GameIndex].Acronym $ ")" );
			Level.Game.Broadcast(self,TextMessage);
		}
		else
		{
			VoteCount =  1;
			TextMessage = lmsgMapVotedFor;
			TextMessage = repl(TextMessage, "%playername%", PlayerController(Voter).PlayerReplicationInfo.PlayerName );
			TextMessage = repl(TextMessage, "%mapname%", MapList[MapIndex].MapName $ "(" $ GameConfig[GameIndex].Acronym $ ")" );
			Level.Game.Broadcast(self,TextMessage);
		}
	}
	UpdateVoteCount(MapIndex, GameIndex, VoteCount);
	if( PrevMapVote > -1 && PrevGameVote > -1 )
		UpdateVoteCount(PrevMapVote, PrevGameVote, -MVRI[Index].VoteCount); // undo previous vote
	MVRI[Index].VoteCount = VoteCount;
	TallyVotes(false);
}

function SubmitKickVote(int PlayerID, Actor Voter)
{
	local int VoterID, VictumID, i, PreviousVote;
	local bool bFound;
	local string PlayerName;
	
	if ( !class'AdminControlMut'.default.bTrackAllKicksBans )
	{
		Super.SubmitKickVote(PlayerID,Voter);
		return;
	}

	log("SubmitKickVote " $ PlayerID, 'MapVoteDebug');

	if(bLevelSwitchPending || !bKickVote)
		return;

	VoterID = GetMVRIIndex(PlayerController(Voter));

	// Find Player
	bFound = false;
	for(i=0;i < MVRI.Length;i++)
	{
		if(MVRI[i] != none && MVRI[i].PlayerOwner.PlayerReplicationInfo.PlayerID == PlayerID)
		{
			bFound = true;
			VictumID = i;
			PlayerName = MVRI[i].PlayerOwner.PlayerReplicationInfo.PlayerName;
			break;
		}
	}
	if(!bFound)
		return;

	if( MVRI[VoterID].KickVote == VictumID ) // if vote is for same player stop
		return;

    if( PlayerController(Voter).PlayerReplicationInfo.bAdmin || PlayerController(Voter).PlayerReplicationInfo.bSilentAdmin )  // Administrator Vote
	{
		log("___Admin " $ PlayerController(Voter).PlayerReplicationInfo.PlayerName $ " kicked " $ PlayerName,'MapVote');
		KickInstigator = Voter;
		KickPlayer(VictumID);
		KickInstigator = none;
		return;
	}

	if( PlayerController(Voter).PlayerReplicationInfo.bOnlySpectator )
	{
		PlayerController(Voter).ClientMessage(lmsgSpectatorsCantVote);
		return;
	}

	if( MVRI[VictumID].PlayerOwner.PlayerReplicationInfo.bAdmin || MVRI[VictumID].PlayerOwner.PlayerReplicationInfo.bSilentAdmin ||
        NetConnection(MVRI[VictumID].PlayerOwner.Player) == None)
	{
		TextMessage = lmsgKickVoteAdmin;
		TextMessage = repl(TextMessage,"%playername%",PlayerController(Voter).PlayerReplicationInfo.PlayerName);
		Level.Game.Broadcast(self,TextMessage);
		return;
	}

	log("___" $ PlayerController(Voter).PlayerReplicationInfo.PlayerName $ " placed a kick vote against " $ PlayerName,'MapVote');
	if(bAnonymousKicking)
	{
		TextMessage = lmsgAnonymousKickVote;
		TextMessage = repl(TextMessage,"%playername%",PlayerName);
		Level.Game.Broadcast(self,TextMessage);
	}
	else
	{
		TextMessage = lmsgKickVote;
		TextMessage = repl(TextMessage,"%playername1%",PlayerController(Voter).PlayerReplicationInfo.PlayerName);
		TextMessage = repl(TextMessage,"%playername2%",PlayerName);
		Level.Game.Broadcast(self,TextMessage);
	}
	PreviousVote = MVRI[VoterID].KickVote;
	MVRI[VoterID].KickVote = VictumID;

  	UpdateKickVoteCount(MVRI[VictumID].PlayerID, 1);
	if( PreviousVote > -1 )
		UpdateKickVoteCount(MVRI[PreviousVote].PlayerID, -1); // undo previous vote

	TallyKickVotes();
}


function KickPlayer(int PlayerIndex)
{
	local int i;
	local AdminControlMut ACMutator;
	local AdminRecord AdminVoter;
	
	if ( !class'AdminControlMut'.default.bTrackAllKicksBans )
	{
		Super.KickPlayer(PlayerIndex);
		return;
	}

	if( MVRI[PlayerIndex] == none || MVRI[PlayerIndex].PlayerOwner == none )
		return;

	TextMessage = "%playername% has been kicked.";
	TextMessage = repl(TextMessage,"%playername%",MVRI[PlayerIndex].PlayerOwner.PlayerReplicationInfo.PlayerName);
	Level.Game.Broadcast(self,TextMessage);

	if(bKickVote)
	{
		// Reset votes
		for(i=0;i < MVRI.Length;i++)
		{
			if(MVRI[i] != None && MVRI[i].KickVote != -1)
				MVRI[i].KickVote = -1;
		}
	}

	//close his/her voting window if open
	if(MVRI[PlayerIndex] != None)
		MVRI[PlayerIndex].CloseWindow();

	log("___" $ MVRI[PlayerIndex].PlayerOwner.PlayerReplicationInfo.PlayerName $ " has been kicked.",'MapVote');
	
	if ( KickInstigator != none )
	{
		ACMutator = class'AdminControlMut'.Static.GetSelf(KickInstigator);
		AdminVoter = ACMutator.FindAdminRecord(KickInstigator);
		if ( ACMutator != none && AdminVoter != none )
		{
			ACMutator.TrackSession(MVRI[PlayerIndex].PlayerOwner.PlayerReplicationInfo.PlayerName,KickInstigator);
			ACMutator.IncreaseKickCount(AdminVoter);
		}
	}
	Level.Game.AccessControl.BanPlayer(MVRI[PlayerIndex].PlayerOwner, True); // session type ban
}

defaultproperties
{
}
