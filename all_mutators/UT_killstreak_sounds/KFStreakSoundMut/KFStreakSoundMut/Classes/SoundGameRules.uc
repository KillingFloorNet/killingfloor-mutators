class SoundGameRules extends GameRules;

#exec AUDIO IMPORT FILE="Sounds\firstblood.wav" NAME="FirstBlood" GROUP="FX"
#exec AUDIO IMPORT FILE="Sounds\humiliation.wav" NAME="Humiliation" GROUP="FX"
#exec AUDIO IMPORT FILE="Sounds\rampage.wav" NAME="Rampage" GROUP="FX"
#exec AUDIO IMPORT FILE="Sounds\killingspree.wav" NAME="KillingSpree" GROUP="FX"
#exec AUDIO IMPORT FILE="Sounds\monsterkill.wav" NAME="MonsterKill" GROUP="FX"
#exec AUDIO IMPORT FILE="Sounds\unstoppable.wav" NAME="Unstoppable" GROUP="FX"
#exec AUDIO IMPORT FILE="Sounds\ultrakill.wav" NAME="UltraKill" GROUP="FX"
#exec AUDIO IMPORT FILE="Sounds\godlike.wav" NAME="GodLike" GROUP="FX"
#exec AUDIO IMPORT FILE="Sounds\wickedsick.wav" NAME="WickedSick" GROUP="FX"
#exec AUDIO IMPORT FILE="Sounds\ludicrouskill.wav" NAME="Ludicrous" GROUP="FX"
#exec AUDIO IMPORT FILE="Sounds\holyshit.wav" NAME="HolyShit" GROUP="FX"
#exec AUDIO IMPORT FILE="Sounds\headshot.wav" NAME="Headshot" GROUP="FX"
#exec AUDIO IMPORT FILE="Sounds\multikill.wav" NAME="MultiKill" GROUP="FX"

var int FirstBloodWave;
var int FinishedWave;
var array<KFMonster> Humiliated;

struct WaveKills
{
	var PlayerController PC;
	var int K;
	var array<float> KT;
};
var array<WaveKills> WKills;

function PostBeginPlay()
{
	if( Level.Game.GameRulesModifiers==None )
		Level.Game.GameRulesModifiers = Self;
	else Level.Game.GameRulesModifiers.AddGameRules(Self);
}

function AddGameRules(GameRules GR)
{
	if ( GR!=Self )
		Super.AddGameRules(GR);
}

function int NetDamage( int OriginalDamage, int Damage, pawn injured, pawn instigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType )
{
	local int i;

	if( KFMonster(injured) != None && KFMonster(injured).bDecapitated && KFHumanPawn(instigatedBy) != None )
	{
		for(i=0; i<Humiliated.Length; i++)
		{
        	if(Humiliated[i] == KFMonster(injured))
        	{
            	if ( NextGameRules != None )
					return NextGameRules.NetDamage( OriginalDamage,Damage,injured,instigatedBy,HitLocation,Momentum,DamageType );
				return Damage;
        	}
		}
    	Humiliated[Humiliated.Length] = KFMonster(injured);

		if(class<DamTypeMelee>(DamageType) == None && Class'KFStreakSoundMut.StreakSoundMut'.default.bActivateHeadshot)
        	PlaySoundForAll(PlayerController(instigatedBy.Controller),"Headshot",0);

    	if(class<DamTypeKnife>(DamageType) != None && Class'KFStreakSoundMut.StreakSoundMut'.default.bActivateHumiliation)
    		PlaySoundForAll(PlayerController(instigatedBy.Controller),"Humiliation",0);
	}

	if ( NextGameRules != None )
		return NextGameRules.NetDamage( OriginalDamage,Damage,injured,instigatedBy,HitLocation,Momentum,DamageType );
	return Damage;
}

function ScoreKill(Controller Killer, Controller Killed)
{
	local int i;
	local int Index;

    if(KFGameType(Level.Game).WaveNum>FinishedWave)
    {
    	FinishedWave = KFGameType(Level.Game).WaveNum;
    	for(i=0;i<WKills.Length;i++)
    		WKills[i].K = 0;
    }

    if(KFMonster(Killed.Pawn)!=None && PlayerController(Killer)!=None)
    {
    	Index = FindPlayerC(PlayerController(Killer));
    	WKills[Index].KT[WKills[Index].KT.Length] = Level.TimeSeconds;
    	WKills[Index].K++;

    	switch( WKills[Index].K )
		{
			case Class'KFStreakSoundMut.StreakSoundMut'.default.RampageKills:
    			PlaySoundForAll(PlayerController(Killer),"Rampage",2,1,Killer.PlayerReplicationInfo);
    			break;
    		case Class'KFStreakSoundMut.StreakSoundMut'.default.KillingSpreeKills:
    			PlaySoundForAll(PlayerController(Killer),"KillingSpree",2,2,Killer.PlayerReplicationInfo);
    			break;
    		case Class'KFStreakSoundMut.StreakSoundMut'.default.MonsterKillKills:
    			PlaySoundForAll(PlayerController(Killer),"MonsterKill",2,3,Killer.PlayerReplicationInfo);
    			break;
    		case Class'KFStreakSoundMut.StreakSoundMut'.default.UnstoppableKills:
    			PlaySoundForAll(PlayerController(Killer),"Unstoppable",2,4,Killer.PlayerReplicationInfo);
    			break;
    		case Class'KFStreakSoundMut.StreakSoundMut'.default.UltraKillKills:
    			PlaySoundForAll(PlayerController(Killer),"UltraKill",2,5,Killer.PlayerReplicationInfo);
    			break;
    		case Class'KFStreakSoundMut.StreakSoundMut'.default.GodLikeKills:
    			PlaySoundForAll(PlayerController(Killer),"GodLike",2,6,Killer.PlayerReplicationInfo);
    			break;
    		case Class'KFStreakSoundMut.StreakSoundMut'.default.WickedSickKills:
    			PlaySoundForAll(PlayerController(Killer),"WickedSick",2,7,Killer.PlayerReplicationInfo);
    			break;
    		case Class'KFStreakSoundMut.StreakSoundMut'.default.LudicrousKills:
    			PlaySoundForAll(PlayerController(Killer),"Ludicrous",2,8,Killer.PlayerReplicationInfo);
    			break;
    		case Class'KFStreakSoundMut.StreakSoundMut'.default.HolyShitKills:
    			PlaySoundForAll(PlayerController(Killer),"HolyShit",2,9,Killer.PlayerReplicationInfo);
    			break;
    	}

    }

	if(KFGameType(Level.Game).WaveNum>FirstBloodWave && PlayerController(Killer)!=None && PlayerController(Killed)==None)
	{
		FirstBloodWave = KFGameType(Level.Game).WaveNum;
		PlaySoundForAll(PlayerController(Killer),"FirstBlood",2,0,Killer.PlayerReplicationInfo);
	}

	if( KFMonster(Killed.Pawn) != None && KFMonster(Killed.Pawn).bDecapitated)
	{
		for(i=0; i<Humiliated.Length; i++)
		{
			if(Humiliated[i]==KFMonster(Killed.Pawn))
				Humiliated.Remove(i,1);
		}
	}
	else if( KFMonster(Killed.Pawn) != None && class<DamTypeKnife>(KFMonster(Killed.Pawn).LastDamagedByType) != None )
		PlaySoundForAll(PlayerController(Killer),"Humiliation",0);

	if ( NextGameRules != None )
		NextGameRules.ScoreKill(Killer,Killed);
}

function PlaySoundForAll( PlayerController PCC, string S, byte Msg, optional int Switch, optional PlayerReplicationInfo PRI)
{
	local Controller C;
	local Sound PS;
	
	S = "KFStreakSoundMut."$S;
	PS = sound(DynamicLoadObject(S, class'sound'));

	if(Msg==0)
		PCC.ClientPlaySound(PS,true,2.f,SLOT_None);
    else if(Msg==1)
    {
    	PCC.ClientPlaySound(PS,true,2.f,SLOT_None);
    	PCC.ReceiveLocalizedMessage(Class'StreakMessage',Switch,PRI);
    }
    else if(Msg==2)
    {
    	for( C=PCC.Level.ControllerList; C!=None; C=C.nextController )
		{
			if( C.bIsPlayer && PlayerController(C)!=None )
			{
				PlayerController(C).ClientPlaySound(PS,true,2.f,SLOT_None);
				PlayerController(C).ReceiveLocalizedMessage(Class'StreakMessage',Switch,PRI);
			}
		}
    }
}

function int FindPlayerC(PlayerController PCC)
{
	local int i;
	local WaveKills InitWK;
	
	for(i=0; i<WKills.Length; i++)
	{
		if(WKills[i].PC == PCC)
			return i;
	}
	
	//Player not found
	InitWK.PC = PCC;
	InitWK.K = 0;
	
	i = WKills.Length;
	WKills[i] = InitWK;
	return i;
}

function Tick(float delta)
{
	local int i;

	for(i=0; i<WKills.Length; i++)
	{
		if(WKills[i].KT.Length >= Class'KFStreakSoundMut.StreakSoundMut'.default.MultiKillKills)
		{
			PlaySoundForAll(WKills[i].PC,"MultiKill",0);
			WKills[i].KT.Remove(0,WKills[i].KT.Length);
		}
    	else if(WKills[i].KT.Length>0 && WKills[i].KT[0]+Class'KFStreakSoundMut.StreakSoundMut'.default.MultiKillTime<Level.TimeSeconds)
    		WKills[i].KT.Remove(0,1);
	}
}

defaultproperties
{
     FirstBloodWave=-1
     FinishedWave=-1
}
