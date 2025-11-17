class LeatherfaceAddMut extends Mutator;

//NormalSquad Mods
//also used to mod special squads
const NS_NUM_NEW = 12;
var String NSOld[NS_NUM_NEW];
var String NSNew[NS_NUM_NEW];
var Float NSChance[NS_NUM_NEW];

function PostBeginPlay()
{
	SetTimer(5.0,False);
	Super.PostBeginPlay();
}

function Timer()
{
	local KFGameType KF;
	local byte squad,squadMem,replaceCounter,i,ii;
	local class<KFMonster> MC;
		
	KF = KFGameType(Level.Game);
	if ( KF!=None )
	{
		//normal squads
		for( squad=0; squad<KF.InitSquads.Length; squad++)
		{
			for( squadMem=0; squadMem < KF.InitSquads[squad].MSquad.Length; squadMem++ )
			{
				for (replaceCounter=0; replaceCounter < NS_NUM_NEW; replaceCounter++)
				{
					if ( String(KF.InitSquads[squad].MSquad[squadMem]) == NSOld[replaceCounter] && FRand() <= NSChance[replaceCounter])
					{
						MC = Class<KFMonster>(DynamicLoadObject(NSNew[replaceCounter],Class'Class'));
						KF.InitSquads[squad].MSquad[squadMem]=MC;
					}
				}
			}
		}
	
		//special squads
		for (i=0;i<KF.SpecialSquads.Length;i++)
		{
			for (ii=0; ii<KF.SpecialSquads[i].ZedClass.Length;ii++)
			{
				for (replaceCounter=0; replaceCounter < NS_NUM_NEW; replaceCounter++)
				{
					if (KF.SpecialSquads[i].ZedClass[ii]== NSOld[replaceCounter] && FRand() <= NSChance[replaceCounter])
						KF.SpecialSquads[i].ZedClass[ii]=NSNew[replaceCounter];
				}
			}
		}
	}
	
	//Destroy();
}

defaultproperties
{
     NSOld(0)="KFChar.ZombieClot"
     NSOld(1)="KFChar.ZombieBloat"
     NSOld(2)="KFChar.ZombieCrawler"
     NSOld(3)="KFChar.ZombieGorefast"
     NSOld(4)="KFChar.ZombieHusk"
     NSOld(5)="KFChar.ZombieStalker"
     NSOld(6)="KFChar.ZombieStalker"
     NSOld(7)="KFChar.ZombieStalker"
     NSOld(8)="KFChar.ZombieStalker"
     NSOld(9)="KFChar.ZombieSiren"
     NSOld(10)="KFChar.ZombieScrake"
     NSOld(11)="KFChar.ZombieFleshPound"
     NSNew(0)="KFChar.ZombieClot"
     NSNew(1)="KFChar.ZombieBloat"
     NSNew(2)="KFChar.ZombieCrawler"
     NSNew(3)="KFChar.ZombieGorefast"
     NSNew(4)="KFChar.ZombieHusk"
     NSNew(5)="KFChar.ZombieStalker"
     NSNew(6)="NewLeatherfaceZed.ZombieLeather"
     NSNew(7)="KFChar.ZombieStalker"
     NSNew(8)="KFChar.ZombieStalker"
     NSNew(9)="KFChar.ZombieSiren"
     NSNew(10)="KFChar.ZombieScrake"
     NSNew(11)="KFChar.ZombieFleshPound"
     NSChance(0)=0.300000
     NSChance(1)=0.300000
     NSChance(2)=0.300000
     NSChance(3)=0.300000
     NSChance(4)=0.300000
     NSChance(5)=0.300000
     NSChance(6)=0.400000
     NSChance(7)=0.500000
     NSChance(8)=0.300000
     NSChance(9)=0.300000
     NSChance(10)=0.300000
     NSChance(11)=0.300000
     bAddToServerPackages=True
     GroupName="KF-Add Leatherface"
     FriendlyName="Add Leatherface"
     Description="Leatherface from Texas Massacre!"
     bAlwaysRelevant=True
     RemoteRole=ROLE_SimulatedProxy
}
