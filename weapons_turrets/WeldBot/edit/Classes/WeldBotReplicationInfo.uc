class WeldBotReplicationInfo extends ReplicationInfo
	dependson(WeldBot);
/*
var int Health;
var WeldBotGun WeaponOwner;
var KFHumanPawn OwnerPawn;

var bool bWelding;
var vector wPStart, wPEnd;
*/

var WeldBot WeldBot;
var PlayerController OwnerPC;
var WeldBot.EState BotState;
var float Distance;
var string BotName;
var int revision;

replication
{
	reliable if (ROLE == Role_Authority)
		BotState, Distance, BotName, revision, OwnerPC, WeldBot;
		//Health, WeaponOwner, OwnerPawn, bWelding, wPStart, wPEnd;

	reliable if (ROLE < Role_Authority)
		SetParams;
}

simulated function SetParams(WeldBot.EState State, optional float D, optional string S)
{
    WeldBot.SetParams(State, D, S);
}

function SetOwnerPC(PlayerController PC)
{
    SetOwner(PC);
    OwnerPC = PC;
}

defaultproperties
{
}
