class MHPlayerController extends KFPlayerController;

var bool bRandomItemSpawnMechanism,bAllowRespawn,bTeamGame,bBossesHealthBar;
var Inventory lastPawnsInventory;

replication
{
	reliable if( Role == ROLE_Authority ) bRandomItemSpawnMechanism,bTeamGame,bBossesHealthBar;
}

simulated function ClientSetHUD(class<HUD> newHUDClass, class<Scoreboard> newScoringClass )
{
	super.clientSetHUD( newHUDClass,newScoringClass );
	MHHUDKillingFloor( myHUD ).bRandomItemSpawnMechanism = bRandomItemSpawnMechanism;
	MHHUDKillingFloor( myHUD ).bTeamGame = bTeamGame;
	MHHUDKillingFloor( myHUD ).bBossesHealthBar = bBossesHealthBar;
}

function setPawnClass( string inClass,string inCharacter )
{
	super.setPawnClass( inClass,inCharacter );
	PawnClass = Class'KFDMMayhem.MHHumanPawn';
}

state Dead
{
	simulated function Timer()
	{
		bAllowRespawn = true;
		super.Timer();
	}

	exec function Fire( optional float F )
	{
		if( bAllowRespawn )
		{
			if(Level.Game != none)
				PlayerReplicationInfo.Score =
					Max(KFGameType(Level.Game).MinRespawnCash, int(PlayerReplicationInfo.Score));
			SetViewTarget(self);
			ClientSetBehindView(false);
			bBehindView = False;
			ClientSetViewTarget(Pawn);
			PlayerReplicationInfo.bOutOfLives = false;
			Pawn = none;
			ServerReStartPlayer();
		}
	}

	simulated function BeginState()
	{
		super.BeginState();
		SetTimer(2.0, false);
		bAllowRespawn = false;
	}
}

exec function Speech( name Type, int Index, string Callsign )
{
	if(Type != 'AUTO')
		super.ServerSpeech(Type,Index,Callsign);
}

defaultproperties
{
     PlayerReplicationInfoClass=Class'KFDMMayhem.MHPlayerReplicationInfo'
}
