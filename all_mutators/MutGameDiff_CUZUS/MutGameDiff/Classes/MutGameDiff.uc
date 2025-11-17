// Developed by Geekrainian (c) 2018
class MutGameDiff extends Mutator;

const GAME_DIFFICULTY_BEGINNER = 0;
const GAME_DIFFICULTY_NORMAL = 1;
const GAME_DIFFICULTY_HARD = 2;
const GAME_DIFFICULTY_SUICIDAL = 3;
const GAME_DIFFICULTY_HELL_ON_EARTH = 4;

var float _gameDifficulty;
var bool _isSetByAdmin;

var() config float DifficultyUpdateTimer;

struct ServerRule
{
	var globalconfig string Alias;
	var globalconfig int Port;
	var globalconfig float GameDiffMin;
	var globalconfig float GameDiffMax;
};

var globalconfig array<ServerRule> ServerRules;

var string _serverAlias;
var float _serverMinGameDiff;
var float _serverMaxGameDiff;

function LogStr(string message)
{
	log("[DEBUG]" @ Self.Class.Name @ message);
}

function MatchStarting()
{
	setGameDifficultyFromConst(GAME_DIFFICULTY_NORMAL);

	SetTimer(DifficultyUpdateTimer, true);
}

function InitRules()
{
	local int serverPort;
	local array<string> parts;
	local int i;

	if (ServerRules.Length > 0)
	{
		Split(Level.GetAddressURL(), ":", parts);

		serverPort = int(parts[1]);

		if (serverPort > 0)
		{
			for (i = 0; i < ServerRules.Length; i++)
			{
				if (ServerRules[i].Port == serverPort)
				{
					_serverAlias = ServerRules[i].Alias;
					_serverMinGameDiff = ServerRules[i].GameDiffMin;
					_serverMaxGameDiff = ServerRules[i].GameDiffMax;

          LogStr("Using" @ _serverAlias @ "rules");

					break;
				}
			}
		}
	}
}

function PostBeginPlay()
{
	super.PostBeginPlay();

	InitRules();
}

function Timer()
{
	local Controller C;
	local KFPlayerReplicationInfo KFPRI;
	local int playersTotal;
	local int levelSum;
	local int midLevel;
	local bool hasOneFieldMedic;
	local bool hasOneBerserker;
	local bool hasOneSharpshooter8LvlOrHigher;
	local bool hasOneBerserker8LvlOrHigher;
	local int berserkersWith10LvlCount;

	if (_isSetByAdmin)
	{
		return;
	}

	if (Level.Game.bGameEnded || !KFGameReplicationInfo(Level.Game.GameReplicationInfo).bMatchHasBegun)
	{
		return;
	}

	for (C = Level.ControllerList; C != None; C = C.nextController)
	{
		if ((C.IsA('PlayerController') || C.IsA('KFInvBots')) && C.Pawn != none) // && C.PlayerReplicationInfo.PlayerID > 0 && C.Pawn.Health > 0
		{
			KFPRI = KFPlayerReplicationInfo(C.PlayerReplicationInfo);

			if (KFPRI != none)
			{
				levelSum += KFPRI.ClientVeteranSkillLevel;
				playersTotal++;

				if (KFPRI.ClientVeteranSkill.default.VeterancyName ~= "Field Medic")
				{
					hasOneFieldMedic = true;
				}

				if (KFPRI.ClientVeteranSkill.default.VeterancyName ~= "Sharpshooter" && KFPRI.ClientVeteranSkillLevel >= 8)
				{
					hasOneSharpshooter8LvlOrHigher = true;
				}

				if (KFPRI.ClientVeteranSkill.default.VeterancyName ~= "Berserker")
				{
					hasOneBerserker = true;

					if (KFPRI.ClientVeteranSkillLevel >= 10)
					{
						berserkersWith10LvlCount++;
					}

					if (KFPRI.ClientVeteranSkillLevel >= 8)
					{
						hasOneBerserker8LvlOrHigher = true;
					}
				}
			}
		}
	}

	if (playersTotal == 0)
	{
		return;
	}

	midLevel = levelSum / playersTotal;

	//LogStr("players:" @ playersTotal);
	//LogStr("levelSum:" @ levelSum);
	//LogStr("Mid. perks level:" @ midLevel);

	if (playersTotal <= 6)
	{
		if (midLevel >= 9 && !(playersTotal == 1 && hasOneFieldMedic))
		{
			setGameDifficultyFromConst(GAME_DIFFICULTY_SUICIDAL);
		}
		else if (midLevel >= 6 && midLevel < 9) // midLevel >= 7 - 21.07.2017
		{
			setGameDifficultyFromConst(GAME_DIFFICULTY_HARD);
		}
		else
		{
			if (playersTotal <= 3 && (hasOneSharpshooter8LvlOrHigher || hasOneBerserker8LvlOrHigher))
			{
				setGameDifficultyFromConst(GAME_DIFFICULTY_HARD);
			}
			else
			{
				setGameDifficultyFromConst(GAME_DIFFICULTY_NORMAL);
			}
		}
	}
	else if (playersTotal > 6 && playersTotal < 10)
	{
		if (midLevel >= 9 && (hasOneFieldMedic || hasOneBerserker8LvlOrHigher))
		{
			setGameDifficultyFromConst(GAME_DIFFICULTY_HELL_ON_EARTH);
		}
		// && hasOneFieldMedic - 09.10.2019
		else if (midLevel >= 7 && midLevel < 9)
		{
			setGameDifficultyFromConst(GAME_DIFFICULTY_SUICIDAL);
		}
		else if (midLevel >= 5 && midLevel < 7)
		{
			setGameDifficultyFromConst(GAME_DIFFICULTY_HARD);
		}
		else
		{
			setGameDifficultyFromConst(GAME_DIFFICULTY_NORMAL);
		}
	}
	else if (playersTotal >= 10)
	{
		if (midLevel >= 9)
		{
			setGameDifficultyFromConst(GAME_DIFFICULTY_HELL_ON_EARTH);
		}
		else if (midLevel >= 6 && midLevel < 9) //berserkersWith10LvlCount >= 3
		{
			setGameDifficultyFromConst(GAME_DIFFICULTY_SUICIDAL);
		}
		else
		{
			setGameDifficultyFromConst(GAME_DIFFICULTY_HARD);
		}
	}
}

function float GetDiffFromConst(int diff)
{
	if (diff == GAME_DIFFICULTY_NORMAL)
	{
		return 2.0;
	}
	else if (diff == GAME_DIFFICULTY_HARD)
	{
		return 4.0;
	}
	else if (diff == GAME_DIFFICULTY_SUICIDAL)
	{
		return 5.0;
	}
	else if (diff == GAME_DIFFICULTY_HELL_ON_EARTH)
	{
		return 7.0;
	}

	//if (diff == GAME_DIFFICULTY_BEGINNER)
	//{
	return 1.0;
	//}
}

function float GetDiffCorrectedByServerRule(float currentGameDiff)
{
	if (_serverMinGameDiff > 0 && currentGameDiff < _serverMinGameDiff)
	{
		return _serverMinGameDiff;
	}
	else if (_serverMaxGameDiff > 0 && currentGameDiff > _serverMaxGameDiff)
	{
		return _serverMaxGameDiff;
	}

	return currentGameDiff;
}

function setGameDifficultyFromConst(int difficulty)
{
	local float prevGameDiff;
	local float nextGameDiff;
	local string temp1, temp2;

	prevGameDiff = _gameDifficulty;

	nextGameDiff = GetDiffFromConst(difficulty);

	LogStr("Set from const" @ GetDiffStringValue(nextGameDiff));

	if (!_isSetByAdmin)
	{
		nextGameDiff = GetDiffCorrectedByServerRule(nextGameDiff);
	}

	if (nextGameDiff != prevGameDiff)
	{
		temp1 = GetDiffStringValue(nextGameDiff);
		temp2 = GetDiffStringValue(_gameDifficulty);

		_gameDifficulty = nextGameDiff;

		updateGameDifficulty();

		LogStr("Changed difficulty to" @ nextGameDiff @ temp1 @ "from" @ prevGameDiff @ temp2);
	}

  // эта функция необязательна, использовалась для определенных махинаций 
  // чтобы дополнительно хранить ур. сложности в репликации каждого клиента
	// replicateGameDifficulty();
}

// function replicateGameDifficulty()
// {
// 	local Controller C;
// 	local SRPlayerReplicationInfo SRPRI;

// 	for (C = Level.ControllerList; C != none; C = C.nextController)
// 	{
// 		if (C.IsA('PlayerController') && !C.IsA('KFInvBots'))
// 		{
// 			SRPRI = SRPlayerReplicationInfo(KFPlayerReplicationInfo(C.PlayerReplicationInfo));

// 			if (SRPRI != none)
// 			{
// 				SRPRI.ChangedGameDiff = _gameDifficulty;
// 			}
// 		}
// 	}
// }

function updateGameDifficulty()
{
	/// Sir Arthur
	local Controller C;
	local SRPlayerReplicationInfo SRPRI;
	///

	if (Level.Game.GameReplicationInfo != none)
	{
		Level.Game.GameDifficulty = _gameDifficulty;
		KFGameReplicationInfo(Level.Game.GameReplicationInfo).GameDiff = _gameDifficulty;
		InvasionGameReplicationInfo(Level.Game.GameReplicationInfo).BaseDifficulty = _gameDifficulty;

		/// Sir Arthur
		for(C = Level.ControllerList; C != None; C = C.nextController) {
			if(KFPlayerController(C) != None) {
				SRPRI = SRPlayerReplicationInfo(C.PlayerReplicationInfo);

				SRPRI.BaseDifficulty = _gameDifficulty;
			}
		}
		///

		LogStr("updateGameDifficulty() Update OK");
	}

	else
	{
		LogStr("updateGameDifficulty() GRI is none");
	}

	Timer();
}

function string GetDiffStringValue(float diff)
{
	if (diff == 1.0)
	{
		return "Beginner";
	}
	else if (diff == 2.0)
	{
		return "Normal";
	}
	else if (diff == 4.0)
	{
		return "Hard";
	}
	else if (diff == 5.0)
	{
		return "Suicidal";
	}
	else if (diff == 7.0)
	{
		return "Hell On Earth";
	}

	return string(diff);
}

// Админ команда чтобы поменять уровень сложности в любой момент игры
// После смены, динамический уровень сложности отключается и больше не будет автоматически менятся
// Пример: mutate setgamediff 4
// Доступные значения см. в константах типа GAME_DIFFICULTY_BEGINNER
function Mutate(string MutateString, PlayerController Sender)
{
	local string command;
	local array<string> parts;
	local int arg2;

	Split(MutateString, " ", parts);

	command = parts[0];

	if (parts.Length > 1)
		arg2 = int(parts[1]);

	if (command ~= "setgamediff")
	{
		LogStr("Game diff change attempt via command" @ arg2);
		Sender.ClientMessage("Game diff <0-4> changed to" @ arg2);
		setGameDifficultyFromConst(arg2);
		_isSetByAdmin = true;
	}

	if (NextMutator != none)
		NextMutator.Mutate(MutateString, Sender);
}

defaultproperties
{
	GroupName="KF-MutGameDiff"
	FriendlyName="MutGameDiff"
	Description="Developed by Geekrainian (c) 2018"

  // Как часто идет проверка на разные условия чтобы поменять на лету уровень сложности
	DifficultyUpdateTimer=15.0

  ServerRules(0)=(Alias="Noob Camp",Port=7907,GameDiffMin=2.0,GameDiffMax=5.0)
  ServerRules(1)=(Alias="Mass Suicide",Port=7707,GameDiffMin=4.0,GameDiffMax=7.0)
  ServerRules(2)=(Alias="Monster Evo",Port=7807,GameDiffMin=5.0,GameDiffMax=7.0)
  ServerRules(3)=(Alias="Boss Wave",Port=8207,GameDiffMin=5.0,GameDiffMax=7.0)
}
