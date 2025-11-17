//-----------------------------------------------------------
//
//-----------------------------------------------------------
class Mutaddbots extends Mutator 
	config(addbots);

var config int NumBots;

static function FillPlayInfo(PlayInfo PlayInfo)
{
	Super.FillPlayInfo(PlayInfo);

	PlayInfo.AddSetting("AddBots", "NumBots", "Number of Bots", 0, 0, "Text", "0;1:32");
}

static event string GetDescriptionText(string PropName)
{
	switch (PropName)
	{
		case "NumBots":	return "Sets how many bots you want to spawn with";
	}
}

function PostBeginPlay()
{
	SetTimer(5.0,False);
}

function Timer()
{
	local int i;
	local kfinvasionbot c;

	for( i = 0;i < numbots;i++ )
	{
		deathmatch(level.game).minplayers = numbots;
		deathmatch(level.game).numbots++;
		deathmatch(level.game).spawnbot();
	}


	foreach allactors(class'kfinvasionbot', c)
		if( c != None )
			Level.game.RestartPlayer(C);

}

function Tick(float delta)
{

	local kfinvasionbot c;


	foreach allactors(class'kfinvasionbot', c)
		if( c != None && c.pawn == None )
			Level.game.RestartPlayer(C);

}

defaultproperties
{
	NumBots=1
	GroupName="KF-Adding"
	FriendlyName="Add bots!"
	Description="Depending on numbots in config, a number of human AI is added to game!"
}
