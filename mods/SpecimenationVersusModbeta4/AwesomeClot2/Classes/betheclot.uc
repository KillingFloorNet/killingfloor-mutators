class BeTheclot extends mutator config (AwesomeClot);

var bool bmadebots,bhasinteraction;

var globalconfig int COOPMaxplayers,numbots,TraderCloseTime;

var globalconfig string specieclass;

var int Maxmonsters,lastmonsterkill;

static function FillPlayInfo(PlayInfo PlayInfo) {

	local array<string> rec;
	local string option;
	local int i;

	rec[0]="awesome_none";
	rec[1]="awesome_gorefast";
	rec[2]="awesome_bloat";
	rec[3]="awesome_crawler";
	rec[4]="awesome_stalker";
	rec[5]="awesome_siren";
	rec[6]="awesome_scrake";
	rec[7]="awesome_fleshpound";
	rec[8]="awesome_husk";

	for (i = 0; i < Rec.Length; i++)
	{

		if(option!="")
		option $= ";";

		option$=rec[i]$";"$rec[i];
	}


	  Super.FillPlayInfo(PlayInfo);  // Always begin with calling parent
	 
	PlayInfo.AddSetting("Max Players", "coopmaxplayers", "Max Players", 0, 0, "Text", "2;0:32",);
	PlayInfo.AddSetting("BotAmount", "numbots", "Bot Amount", 0, 0, "Text", "1;0:5",);
	PlayInfo.AddSetting("Specie Only Arena Class", "specieclass", "Specie Only Arena Class", 0, 0, "Select", option,);
	PlayInfo.AddSetting("Trader Door Wait Mins.", "TraderCloseTime", "Trader Door Wait Mins.", 0, 0, "Text", "2;1:10",);

}
function postBeginPlay()
{

	local string currentmap;



	if(zombiegametype(level.game)==none)
	{
		currentmap=GetURLMap(false);

		level.servertravel("?game=awesomeclot2.zombiegametype",true);

	}

	settimer(1.0,true);

}
final function Class<KFMonster> GetReplaceClass( Class<KFMonster> MC )
{
	if( zombiegametype(level.game)!= none && zombiegametype(level.game).specimennums > 1 )
		return Class'ZClot';
	
}
final function ReplaceMonsterStr( out string MC )
{
	if( zombiegametype(level.game).specimennums > 1 )
	MC = "awesomeclot2.ZClot";
}
function Tick(float delta)
{
	local kfinvasionbot c;



	foreach allactors(class'kfinvasionbot', c)
		if(c!=none&&c.pawn==none)
			Level.game.RestartPlayer(C);

}
function timer()
{
    local PlayerController P;
	local kfinvasionbot c;

	local KFGameType KF;
	local int i,j;

	KF = KFGameType(Level.Game);
	if ( KF!=None )
	{
		for( i=0; i<KF.InitSquads.Length; i++ )
		{
			for( j=0; j<KF.InitSquads[i].MSquad.Length; j++ )
				KF.InitSquads[i].MSquad[j] = GetReplaceClass(KF.InitSquads[i].MSquad[j]);
		}
		for( i=0; i<KF.SpecialSquads.Length; i++ )
		{
			for( j=0; j<KF.SpecialSquads[i].ZedClass.Length; j++ )
				ReplaceMonsterStr(KF.SpecialSquads[i].ZedClass[j]);
		}
		for( i=0; i<KF.FinalSquads.Length; i++ )
		{
			for( j=0; j<KF.FinalSquads[i].ZedClass.Length; j++ )
				ReplaceMonsterStr(KF.FinalSquads[i].ZedClass[j]);
		}
		KF.FallbackMonster = GetReplaceClass( Class<KFMonster>(KF.FallbackMonster) );

	}





	/*if(maxmonsters==kfgamereplicationinfo(level.game.gamereplicationinfo).maxmonsters&&lastmonsterkill>120&&kfgamereplicationinfo(level.game.gamereplicationinfo).maxmonsters>6&&zombiegametype(level.game).wavenum!=zombiegametype(level.game).finalwave&&zombiegametype(level.game).bwaveinprogress==true)
	{
		kfgamereplicationinfo(level.game.gamereplicationinfo).maxmonsters=0;
		zombiegametype(level.game).totalmaxmonsters=0;
		zombiegametype(level.game).nummonsters=0;
		zombiegametype(level.game).killzeds();
	}

	if(zombiegametype(level.game).bwaveinprogress==true)
		lastmonsterkill++;
	else 
		lastmonsterkill=0;*/

	if(bmadebots==false )
	{
		for(i=0;i<numbots;i++)
		{
			deathmatch(level.game).minplayers=numbots;
			deathmatch(level.game).numbots++;
			deathmatch(level.game).spawnbot();
		}


		foreach allactors(class'kfinvasionbot', c)
		if(c!=none)
		{
			Level.game.RestartPlayer(C);
			getsquad().AddBot(c);
			C.squad = getsquad();
			
			KFPlayerReplicationInfo(C.PlayerReplicationInfo).ClientVeteranSkillLevel = 1 + class'KFGameType'.default.gamedifficulty;


		}
		bmadebots=true;
	}

		foreach allactors(class'kfinvasionbot', c)
		if(c!=none && c.pawn != none && !zombiegametype(level.game).bwaveinprogress)
		{
			if(c.pawn.weapon.AmmoAmount(0) < 100)
			c.pawn.weapon.addammo(200,0);
		}
		
		
    ForEach allActors(class'playercontroller', P)
    {
       


        if(p != none && p.PlayerReplicationInfo.bOnlySpectator==false && !zombiegametype(level.game).isspecimen(p) &&  !zombiegametype(level.game).isplayer(p) && p.pawn != none && zombieplayercontroller(p).zname==none)
        {
			if(P.Player.GUIController.bActive && GUIController(P.Player.GUIController).ActivePage.Name != 'guiselectclass' || !p.player.GUIController.bactive)
			{
				zombieplayercontroller(p).zname=class'actor';
				P.ClientOpenMenu("awesomeclot2.guiselectclass");
			}
        }

    }



	settimer(2.0,true);

	zombiegametype(level.game).specimenclass=specieclass;
	maxmonsters=kfgamereplicationinfo(level.game.gamereplicationinfo).maxmonsters;
}

function SquadAI GetSquad()
{
	local SquadAI SQ;
	
	foreach allactors(class'squadai', sq)
	if( sq != none )
	   return sq;
	   
}

defaultproperties
{
     COOPMaxplayers=12
     NumBots=4
     TraderCloseTime=2
     specieclass="awesome_none"
     GroupName="KF-Thugman"
     FriendlyName="Killing Floor Specimenation Versus 200 b4"
     Description="This here them mutator that ya cans like be them specimen that ya know aint it, ya dig dog?"
}
