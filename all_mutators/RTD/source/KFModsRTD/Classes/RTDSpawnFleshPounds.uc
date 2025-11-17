//-----------------------------------------------------------
// Spawns a bunch of cloths near when triggered
// by Sinnerg - sinnerg@kfmods.com - Copyright 2009
//-----------------------------------------------------------
class RTDSpawnFleshPounds extends RTDFaceBase;

var localized string AlmostAttrackedMsg;
var localized string PersonalAlmostAttrackedMsg;

// The function gets triggered when a player gets this face
// up
static simulated function ModifyPawn(Pawn Other)
{
    local int AmountToSpawn, i;
	local ZombieVolume ZV;

    // Check if we are running on the server side
    if (Other.Role != ROLE_Authority)
        return;

    // Check if a wave is in progress if not tell them they just evaded some mobs :P
    if ((!GetGame(Other.Controller).bWaveBossInProgress) && (!GetGame(Other.Controller).bWaveInProgress))
    {
        // Set the message to be shown in the chat box
        SetMessage(default.AlmostAttrackedMsg);

        // Set the message to be shown in the center of the screen
        // of the triggering player
        SetPersonalMessage(default.PersonalAlmostAttrackedMsg);

        return;
    }

    // Calculate the amount of Zombs to spawn
    AmountToSpawn = 2 + Rand(1);

    // Find a ZombieVolume
    for (i=0;i < AmountToSpawn;i++)
    {
        ZV = FindSpawningVolume(Other.Controller, true);

        SpawnZombie(Other.Controller, None, class'KFChar.ZombieFleshPound', Other.Location, Other.Rotation);
    }

    // Set the message to be shown in the chat box
    SetMessage(default.Message);

    // Set the message to be shown in the center of the screen
    // of the triggering player
    SetPersonalMessage(default.PersonalMessage);
}

static function SpawnZombie(Controller C, ZombieVolume zone, class<KFMonster> zombie, vector location, rotator rotation)
{
    local int NumTries, j;
	local rotator RandRot;
	local vector TrySpawnPoint;
    local KFMonster Act;
    local KFGameType Game;
    Game = GetGame(C);
	RandRot.Yaw = Rand(65536);

    if (zone == None)
        zone = FindSpawningVolume(C, false);

    NumTries = zone.SpawnPos.Length;

    for( j=0; j<NumTries; j++ )
    {
        TrySpawnPoint = zone.SpawnPos[Rand(zone.SpawnPos.Length)];

        //if ((zone.PlayerCanSeePoint(TrySpawnPoint, zombie))  && (j+1 < NumTries))
        //    continue; // Only allow to spawn if the player can see it! EXCEPT if it is the last try!

        Act = C.Pawn.Spawn(zombie,,,TrySpawnPoint,RandRot);

        Game.TotalPossibleMatchMoney += Act.ScoringValue;
        Game.TotalPossibleWaveMoney += Act.ScoringValue;

        Game.NumMonsters++;
        Game.WaveMonsters++;
        break;
    }
}

static function KFGameType GetGame(Controller C)
{
    return KFGameType(C.Pawn.Level.Game);
}
static function ZombieVolume FindSpawningVolume(Controller C, optional bool bIgnoreFailedSpawnTime)
{
	local ZombieVolume BestZ;
	local float BestScore,tScore;
	local int i,l;
    local KFGameType Game;

    Game= KFGameType(C.Pawn.Level.Game);

	// Second pass, figure out best spawning point.
	l = Game.ZedSpawnList.Length;

	for( i=0; i<l; i++ )
	{
        tScore = Game.ZedSpawnList[i].RateZombieVolume(Game,Game.LastSpawningVolume ,C,bIgnoreFailedSpawnTime);
		if (( tScore<0 ) && (i+1 <l))
			continue;
		if( BestZ==None || (tScore>BestScore) )
		{
			BestScore = tScore;
			BestZ = Game.ZedSpawnList[i];
		}
	}

	return BestZ;
}

// Override the properties

defaultproperties
{
     AlmostAttrackedMsg="almost lured in a group of Flesh Pounds! Good lord, that was close!"
     PersonalAlmostAttrackedMsg="You almost lured in a group of Flesh Pounds! Watch it next time!"
     Message="has lured in a group of Flesh Pounds! Ruuuun!!!"
     PersonalMessage="You lured in a group Flesh Pounds! Kill them! Kill them now!"
     FaceType=6
}
