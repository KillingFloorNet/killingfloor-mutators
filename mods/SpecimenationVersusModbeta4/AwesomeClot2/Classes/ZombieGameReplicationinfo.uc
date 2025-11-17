class zombiegamereplicationinfo extends kfgamereplicationinfo;

var float BossHealth;
var float BossMaxHealth;
var string BossName;
var bool bkillthezeds;
var int killtimer;

replication
{

	reliable if(Role == Role_authority)
				BossHealth,BossMaxHealth,Bossname,killtimer,bkillthezeds;
}

	
simulated function Timer()
{
	local controller C;

	super.timer();


	For(C = Level.ControllerList; C != none; C = C.nextcontroller)
	{
	
		if(C.isa('playercontroller') && c.isa('zombieplayercontroller'))
		{
			ZombieGametype(level.game).PlayerUpdate(playercontroller(C));
			zombieplayercontroller(C).canseeme();
 
		}

	}
}

defaultproperties
{
}
