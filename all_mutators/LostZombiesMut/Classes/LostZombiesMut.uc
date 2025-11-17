class LostZombiesMut extends Mutator config(LostZombiesMut);

var config int CfgSecondsToWait;
var config int CfgSecondsToMutateKillEnabled;
var config int CfgNumberOfTries;
var config float CfgDistanceCoiff;
var config int CfgRegime;
var config array<string> CfgVipList;
var config array<string> CfgMapList;
var config bool CfgWorksOnBossWave;
var config int CfgTimerInterval;
var config bool CfgInstantActionEnabled;
var config bool CfgTimedActionEnabled;
var int lastMonsterKilledTime;
var int monsterCount;
var array<Monster> LostZombieList;
var LZGameRules RulesMod;
var float LastActionTime;

function PostBeginPlay()
{
	SaveConfig();
	if (RulesMod == None)
		RulesMod = Spawn(Class'LZGameRules');
	if (KFGameType(Level.Game) == None) Destroyed();
	Super.PostBeginPlay();
}

function MatchStarting()
{
	RulesMod.LastMosterKillTime = Level.TimeSeconds;
	SetTimer(CfgTimerInterval, true);
}

function Mutate(string MutateString, PlayerController Sender)
{
	local string Command;
	local string Parametr;
	local array<string> parts;
	local Monster M;

	if (!Sender.PlayerReplicationInfo.bAdmin && !InVipList(Sender) && Level.TimeSeconds - RulesMod.LastMosterKillTime<CfgSecondsToMutateKillEnabled)
		return;

	Split(MutateString, " ", parts);
	Command = parts[0];
	Parametr = parts[1];

	if (Command~= "KillZeds")
	{
		foreach DynamicActors(class'Monster', M)
		{
			if (!CfgWorksOnBossWave && KFGameType(Level.Game).bWaveBossInProgress) continue;
			AnnihilateZombie(M);
		}
	}

	if (NextMutator != None)
		NextMutator.Mutate(MutateString, Sender);
}

function Timer()
{
	if (InMapList())
		return;
	if (!CfgWorksOnBossWave && KFGameType(Level.Game).bWaveBossInProgress)
		return;
	if (!KFGameType(Level.Game).bWaveInProgress)
		return;

	LastActionTime = Max(LastActionTime, RulesMod.LastMosterKillTime);

	if (Level.TimeSeconds - LastActionTime>CfgSecondsToWait && CfgTimedActionEnabled)
	{
		FillLateZombiesArray();
		ManageLostZombies();
		LastActionTime = Level.TimeSeconds;
	}

	if (!CfgInstantActionEnabled) 
		return;

	FillLostZombiesArray();

	if (LostZombieList.Length>0)
		ManageLostZombies();
}

function FillLostZombiesArray()
{
	local Monster M;
	if (LostZombieList.Length>0) 
		LostZombieList.Length = 0;

	foreach DynamicActors(class'Monster', M)
		if (!HasPathToAnyPlayer(M))
			LostZombieList[LostZombieList.Length] = M;
}

function FillLateZombiesArray()
{
	local Monster M;

	if (LostZombieList.Length>0) 
		LostZombieList.Length = 0;

	foreach DynamicActors(class'Monster', M)
		LostZombieList[LostZombieList.Length] = M;
}

function bool HasPathToAnyPlayer(Monster M)
{
	local KFHumanPawn P;
	foreach DynamicActors(class'KFHumanPawn', P)
		if (M.Controller.FindPathToward(P) == None) 
			return false;
	return true;
}

function ManageLostZombies()
{
	local Vector teleportLocation;
	local bool sentenceIsExecuted;
	local int numberOfTries;

	while (LostZombieList.Length>0)
	{
		if (CfgRegime == 0)
		{
			teleportLocation = GetRandomSpawnLocation(numberOfTries);
			sentenceIsExecuted = Teleport(LostZombieList[0], teleportLocation);
		}
		else if (CfgRegime == 1)
		{
			teleportLocation = GetRandomPlayerLocation(LostZombieList[0], numberOfTries);
			sentenceIsExecuted = Teleport(LostZombieList[0], teleportLocation);
		}
		else
		{
			AnnihilateZombie(LostZombieList[0]);
			sentenceIsExecuted = true;
		}

		if (!sentenceIsExecuted && numberOfTries>CfgNumberOfTries)
		{
			AnnihilateZombie(LostZombieList[0]);
			sentenceIsExecuted = true;
		}

		numberOfTries++;

		if (sentenceIsExecuted)
		{
			numberOfTries = 0;
			sentenceIsExecuted = false;
			LostZombieList.Remove(0, 1);
		}
	}
}

function Vector GetRandomPlayerLocation(Monster M, int counter)
{
	local array<KFHumanPawn> pList;
	local KFHumanPawn P;
	local Vector randV;
	local Vector rLocation;
	local KFHumanPawn randP;
	foreach DynamicActors(class'KFHumanPawn', P)
		pList[pList.Length] = P;
	randP = pList[Rand(pList.Length)];

	if (randP == None) 
		return rLocation;

	randV = VRand();

	if (randV.X>0) 
		randV.X += 1;
	else 
		randV.X -= 1;

	if (randV.Y>0) 
		randV.Y += 1;
	else 
		randV.Y -= 1;
	randV.Z = 0;

	rLocation = randP.Location +
		randV*(M.CollisionRadius + randP.CollisionRadius) * 2 * CfgDistanceCoiff +
		randV * 100 * (counter % 10);

	return rLocation;
}

function Vector GetRandomSpawnLocation(int counter)
{
	local Vector randV;
	local Vector rLocation;
	local ZombieVolume randZV;
	local int volumeListLength;
	volumeListLength = KFGameType(Level.Game).ZedSpawnList.Length;
	randZV = KFGameType(Level.Game).ZedSpawnList[Rand(volumeListLength)];

	if (randZV == None) 
		return rLocation;

	randV = VRand();

	if (randV.X>0) 
		randV.X += 1;
	else 
		randV.X -= 1;

	if (randV.Y>0) 
		randV.Y += 1;
	else 
		randV.Y -= 1;

	randV.Z = 0;
	rLocation = randZV.Location + 200 * randV + 100 * (counter % 10)*randV;
	return rLocation;
}

function AnnihilateZombie(Monster M)
{
	if (M != None)
	{
		M.Destroyed();
		M.Destroy();
	}
}

function bool Teleport(Monster M, vector newSpawnLoc)
{
	if (M.SetLocation(newSpawnLoc))
	{
		M.SetPhysics(PHYS_Walking);
		if (M.Controller.PointReachable(newSpawnLoc))
		{
			M.Velocity = vect(0, 0, 0);
			M.Acceleration = vect(0, 0, 0);
			M.SetRotation(rotator(newSpawnLoc - M.Location));
			M.Controller.GotoState('');
			MonsterController(M.Controller).WhatToDoNext(0);
		}
	}
	if (VSizeSq(M.Location - newSpawnLoc)<100)
	{
		return true;
	}
	return false;
}

static final function float VSizeSq(vector A)
{
	return Sqrt(Square(A.X) + Square(A.Y) + Square(A.Z));
}

function bool InVipList(Controller C)
{
	local string hash;
	local int i;
	hash = PlayerController(C).GetPlayerIDHash();
	for (i = 0; i<CfgVipList.Length; i++)
		if (hash~= CfgVipList[i]) return true;
	return false;
}

function bool InMapList()
{
	local string currentMap;
	local int i;
	currentMap = GetShortUrl(Level.GetLocalURL());;
	for (i = 0; i<CfgMapList.Length; i++)
		if (currentMap~= CfgMapList[i]) return true;
	return false;
}

static function string GetShortUrl(string s)
{
	local int qPos, slashPos, startPos;
	local string result;
	qPos = InStr(s, "?");
	slashPos = InStr(s, "/");
	startPos = Max(slashPos, 0);
	result = Mid(s, startPos + 1, qPos - startPos - 1);
	return result;
}

defaultproperties
{
	CfgSecondsToWait = 25
	CfgSecondsToMutateKillEnabled = 55
	CfgNumberOfTries = 10
	CfgDistanceCoiff = 4
	CfgRegime = 1
	CfgWorksOnBossWave = false
	CfgTimerInterval = 15
	CfgInstantActionEnabled = true
	CfgTimedActionEnabled = true
	CfgVipList(0) = 111111111
	CfgVipList(1) = 222222222
	CfgMapList(0) = KF - TheHiveV1
	bAddToServerPackages = True
	GroupName = "LostZombiesMut"
	FriendlyName = "LostZombiesMut"
	Description = "LostZombiesMut"
}