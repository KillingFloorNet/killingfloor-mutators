class ClotsDayFix extends Mutator;


var config int amountOfClotsToSpawn;
var config int distanceToObjetive;
var localized string GUIDisplayText[2];	// Config property label names
var localized string GUIDescText[2];	// Config property long descriptions

var array<float> monsterLocationsAngle;
var GESummonRules rules;


event PostBeginPlay()
{
  super.PostBeginPlay();

  if (rules == none)
  {
    rules = spawn(class'GESummonRules');
    rules.clotsDayMutator = self;
  }
}


static function string getDisplayText (string propName)
{
  switch (propName)
  {
    case "amountOfClotsToSpawn": return default.GUIDisplayText[0];
    case "distanceToObjetive": return default.GUIDisplayText[1];
  }
}


static function FillPlayInfo (PlayInfo playInfo)
{
  super.fillPlayInfo(playInfo);

  playInfo.AddSetting(default.GameGroup , "amountOfClotsToSpawn" , GetDisplayText("amountOfClotsToSpawn") , 0 , 0 , "Text" , "1;0:8" , "" , false , false);
  playInfo.AddSetting(default.GameGroup , "distanceToObjetive" , GetDisplayText("distanceToObjetive") , 0 , 0 , "Text" , "1;50:800" , "" , false , false);
}


simulated function surround(Pawn objetive,class<Monster> monsterClass)
{
  local int amountOfMonstersSpawned , index;
  local vector monsterLocation;
  local Monster monster;
  local KFGameType game;

  monsterLocation.Z = objetive.Location.Z;

  for (index = 0 ; index < monsterLocationsAngle.Length && amountOfMonstersSpawned < amountOfClotsToSpawn ; ++index)
  {
    monsterLocation.X = objetive.Location.X + (distanceToObjetive * cos(monsterLocationsAngle[index]));
    monsterLocation.Y = objetive.Location.Y + (distanceToObjetive * sin(monsterLocationsAngle[index]));
    if (objetive.fastTrace(monsterLocation))
      monster = spawn(monsterClass , , , monsterLocation ,);
    if (monster != none)
      amountOfMonstersSpawned++;
  }

  game = KFGameType(level.game);
  if (game != none)
    KFGameReplicationInfo(game.GameReplicationInfo).MaxMonsters = Max(game.totalMaxMonsters + game.numMonsters + amountOfMonstersSpawned,0);
}


function Mutate(string MutateString, PlayerController Sender)
{
  local KFHumanPawn player;

  if (MutateString == "summon")
  {
    player = KFHumanPawn(Sender.Pawn);
    if (player != none)
      surround (player, class'SummoneableZombieClot');
  }

  super.Mutate(MutateString,Sender);
}


defaultproperties
{
  GroupName="KFMutators"
  FriendlyName="Clots Day Fix."
  Description="Welcome to Clot's day, hope you didn't forget the ammo box."

  amountOfClotsToSpawn=4
  distanceToObjetive=200
  GUIDisplayText[0]="Amount of Clots"
  GUIDisplayText[1]="Distance to spawn"
  GUIDescText[0]="The amount of clots to summon for each level's original clot killed."
  GUIDescText[1]="The distance from the killed clot to the spawn points."
  monsterLocationsAngle(0)=0.0
  monsterLocationsAngle(1)=3.140
  monsterLocationsAngle(2)=1.570
  monsterLocationsAngle(3)=4.710
  monsterLocationsAngle(4)=0.780
  monsterLocationsAngle(5)=3.920
  monsterLocationsAngle(6)=5.490
  monsterLocationsAngle(7)=2.350
}