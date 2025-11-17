//-----------------------------------------------------------
//
//-----------------------------------------------------------
class KFFakedPlayers extends Mutator
	Config(KFFakedPlayers);

var() config bool bPatrikOnlyRealPlayers;
var() config float nPlayersCoeff;
var() config int nPlayersPlus;
var() config bool bDebug;

function MatchStarting()
{
	if (bDebug)
		log("StarcMatch + settimer");
	SetTimer(1.0,True);
}

// Returns the number of players
function float GetNumPlayers()
{
	local int NumPlayers;
	local Controller C;
	For( C=Level.ControllerList; C!=None; C=C.NextController /*&& C.Pawn.Health > 0*/ )
	{
		if( C.bIsPlayer /*&& C.Pawn!=None*/ )
		{
			NumPlayers++;
		}
	}
	return NumPlayers;
}

function Timer()
{
	local float nPlayers;
	nPlayers=GetNumPlayers(); //кол-во реальных игроков
	
	if (bDebug)
		log("nPlayers"@nPlayers);
		
	if( (nPlayers>0)
		&& (nPlayers*nPlayersCoeff+nPlayersPlus > 1)
		&& !Level.Game.bGameEnded 
		&& !(bPatrikOnlyRealPlayers && (KFGameType(Level.Game).WaveNum>=KFGameType(Level.Game).FinalWave))
		&& (nPlayers<Level.Game.MaxPlayers-1)		)
	{
		if ((nPlayers*nPlayersCoeff+nPlayersPlus)>=Level.Game.MaxPlayers)
			KFGameType(Level.Game).NumPlayers=Level.Game.MaxPlayers-1;
		else
			KFGameType(Level.Game).NumPlayers=nPlayers*nPlayersCoeff+nPlayersPlus;
	}
	else if (nPlayers==0)
		KFGameType(Level.Game).NumPlayers=1;
	else
		KFGameType(Level.Game).NumPlayers=nPlayers;
	
	if (bDebug) 
		log("numPlayers"@KFGameType(Level.Game).NumPlayers);
}

defaultproperties
{
	bDebug=false;
	nPlayersCoeff=2;
	nPlayersPlus=0;
	bPatrikOnlyRealPlayers=true;
	GroupName="KF-Custom"
	FriendlyName="Faked Players_v3"
	Description="Simulate extras players to get a bit harder game."
}
