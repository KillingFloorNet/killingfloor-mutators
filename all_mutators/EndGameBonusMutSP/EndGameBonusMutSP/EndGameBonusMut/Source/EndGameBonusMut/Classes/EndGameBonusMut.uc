Class EndGameBonusMut extends Mutator Config(EndGameBonusMut);

struct PerksStats
{
	// Стата
	var int RDamageHealedStat;
	var int RWeldingPointsStat;
	var int RShotgunDamageStat;
	var int RHeadshotKillsStat;
	var int RStalkerKillsStat;
	var int RBullpupDamageStat;
	var int RMeleeDamageStat;
	var int RFlameThrowerDamageStat;
	var int RExplosivesDamageStat;
	// ID игрока
	var string Hash;
};

var config float EasyMult, NormalMult, HardMult, SuicidalMult, HoEMult; // Множители опыта в зависимости от сложности
var array<PlayerController> PendingPlayers; // Массив игроков
var array<PerksStats> GameStartStats; // Массив стат
var EndGameBonusGameRules Rules; // Правила
var KFGameType KFGT; // Геймтайп
var float BonusMult; // Дополнительная переменная для вычисления множителя

function PostBeginPlay()
{
	KFGT=KFGameType(Level.Game);
	if(Rules==None) Rules=Spawn(Class'EndGameBonusGameRules');
	Rules.Mut=Self;
}

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	if(PlayerController(Other)!=None)
	{
		PendingPlayers[PendingPlayers.Length]=PlayerController(Other);
		SetTimer(1.0, False);
	}
	Return True;
}

function Timer()
{
	local PlayerController PC;
	local string Hash;
	local int i, N;
	for(i=PendingPlayers.Length-1;i>=0;i--)
	{
		PC=PendingPlayers[i];
		if(PC.PlayerReplicationInfo.PlayerID>0)
		{
			Hash=PC.GetPlayerIDHash();
			N=PlayerPosInList(Hash);
			if(N<0 && !KFGT.bWaveBossInProgress) BackupStats(PC);
		}
	}
	PendingPlayers.Length=0;
}

function BackupStats(PlayerController PC)
{
	local PerksStats PS;
	local ClientPerkRepLink L;

	L=Class'ClientPerkRepLink'.Static.FindStats(PC);
	if(L==None) Return;

	PS.Hash=PC.GetPlayerIDHash();
	PS.RDamageHealedStat=L.RDamageHealedStat;
	PS.RWeldingPointsStat=L.RWeldingPointsStat;
	PS.RShotgunDamageStat=L.RShotgunDamageStat;
	PS.RHeadshotKillsStat=L.RHeadshotKillsStat;
	PS.RStalkerKillsStat=L.RStalkerKillsStat;
	PS.RBullpupDamageStat=L.RBullpupDamageStat;
	PS.RMeleeDamageStat=L.RMeleeDamageStat;
	PS.RFlameThrowerDamageStat=L.RFlameThrowerDamageStat;
	PS.RExplosivesDamageStat=L.RExplosivesDamageStat;
	GameStartStats[GameStartStats.Length]=PS;
}

function GiveEndGameBonus()
{
	local KFSteamStatsAndAchievements KFStats;
	local ClientPerkRepLink L;
	local PlayerController PC;
	local int EndExpMult;
	local Controller C;
	local string Hash;
	local int N;

	if(Level.Game.GameDifficulty>=7.0)
	{
		BonusMult=HoEMult; // Hell on Earth
	}
	else if(Level.Game.GameDifficulty>=5.0)
	{
		BonusMult=SuicidalMult; // Suicidal
	}
	else if(Level.Game.GameDifficulty>=4.0)
	{
		BonusMult=HardMult; // Hard
	}
	else if(Level.Game.GameDifficulty>=2.0)
	{
		BonusMult=NormalMult; // Normal
	}
	else
	{
		BonusMult=EasyMult; // Beginner
	}

	for(C=Level.ControllerList; C!=None; C=C.NextController)
	{
		if(C.IsA('PlayerController') &&	C.PlayerReplicationInfo.PlayerID>0)
		{
			PC=PlayerController(C);
			Hash=PC.GetPlayerIDHash();
			N=PlayerPosInList(Hash);

			if(N<0)
			{
				PC.ClientMessage("Unable to give end game bonus! No stat backup found!");
				Continue;
			}

			KFStats=KFSteamStatsAndAchievements(PC.SteamStatsAndAchievements);
			if(KFStats==None) Continue;
			L=Class'ClientPerkRepLink'.Static.FindStats(PC);
			if(L==None) Continue;
			PC.ClientMessage("Stat Bonus (x"$BonusMult$")");

			EndExpMult=BonusMult*(L.RDamageHealedStat-GameStartStats[N].RDamageHealedStat);
			if(EndExpMult>0) KFStats.AddDamageHealed(EndExpMult);

			EndExpMult=BonusMult*(L.RWeldingPointsStat-GameStartStats[N].RWeldingPointsStat);
			if(EndExpMult>0) KFStats.AddWeldingPoints(EndExpMult);

			EndExpMult=BonusMult*(L.RShotgunDamageStat-GameStartStats[N].RShotgunDamageStat);
			if(EndExpMult>0) KFStats.AddShotgunDamage(EndExpMult);

			EndExpMult=BonusMult*(L.RHeadshotKillsStat-GameStartStats[N].RHeadshotKillsStat);
			While(--EndExpMult>0) KFStats.AddHeadshotKill(False);

			EndExpMult=BonusMult*(L.RStalkerKillsStat-GameStartStats[N].RStalkerKillsStat);
			While(--EndExpMult>0) KFStats.AddStalkerKill();

			EndExpMult=BonusMult*(L.RBullpupDamageStat-GameStartStats[N].RBullpupDamageStat);
			if(EndExpMult>0) KFStats.AddBullpupDamage(EndExpMult);

			EndExpMult=BonusMult*(L.RMeleeDamageStat-GameStartStats[N].RMeleeDamageStat);
			if(EndExpMult>0) KFStats.AddMeleeDamage(EndExpMult);

			EndExpMult=BonusMult*(L.RFlameThrowerDamageStat-GameStartStats[N].RFlameThrowerDamageStat);
			if(EndExpMult>0) KFStats.AddFlameThrowerDamage(EndExpMult);

			EndExpMult=BonusMult*(L.RExplosivesDamageStat-GameStartStats[N].RExplosivesDamageStat);
			if(EndExpMult>0) KFStats.AddExplosivesDamage(EndExpMult);
		}
	}
}

function int PlayerPosInList(string Hash)
{
	local int i;
	for(i=0;i<GameStartStats.Length;i++) if(Hash~=GameStartStats[i].Hash) Return i;
	Return -1;
}

defaultproperties
{
	EasyMult=1.0
	NormalMult=1.5
	HardMult=2.0
	SuicidalMult=2.5
	HoEMult=3.0
	GroupName="KF-EndGameBonusMut"
	FriendlyName="End Game Bonus"
	Description="In case of victory the experience, gained by players, is multiplied by modifier, which depends on the difficulty of the game."
}