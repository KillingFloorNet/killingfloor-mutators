class MultiplePatHPBarMut extends Mutator
	config(MultiplePatHPBar);

var config string DisplayString;

var bool bAffectSpectators;
var bool bAffectPlayers;
var bool bHasInteraction;
var string BossString;
var Interaction Inter;
var PlayerController PC;

var int Health[3];
var int HealthMax[3];
var int SyringeCount[3];
var int HealingLevels[9];
var int Type[3];

replication
{
	reliable if( Role == Role_Authority )
		Type, Health, HealthMax, SyringeCount, HealingLevels, BossString;
}

function MatchStarting()
{
	BossString = DisplayString;
	SetTimer(0.25, true);
}

simulated function PostNetReceive()
{
	if( Level.NetMode != NM_DedicatedServer )
		BossHUDInteraction(Inter).SetBossStats(Type, Health, HealthMax, SyringeCount, HealingLevels, BossString);
}

simulated function Tick(float DeltaTime)
{
	if( bHasInteraction )
		return;

	PC = Level.GetLocalPlayerController();

	if( PC != none && ((PC.PlayerReplicationInfo.bIsSpectator && bAffectSpectators) || (bAffectPlayers && !PC.PlayerReplicationInfo.bIsSpectator)) )
	{
		Inter = PC.Player.InteractionMaster.AddInteraction("MultiplePatHPBar.BossHUDInteraction", PC.Player);
		bHasInteraction = true;
	}
}

function Timer()
{
	RemoveBoss();
	SaveBossStats();

	if ( Level.Game.IsInState('MatchOver') )
		SetTimer(0.0, false);
}

function RemoveBoss()
{
	local int i;

	for( i = 0; i < 3; i++ )
		Health[i] = 0;
}

function SaveBossStats()
{
	local ZombieBoss Boss;
	local Controller C;
	local int i, j;

	i = 0;

	foreach DynamicActors(class'ZombieBoss', Boss)
	{
		if (Boss.Name == 'ZombieBossWeak')
		{
			Type[i] = 1;
		}

		Health[i] = Boss.Health;
		HealthMax[i] = Boss.HealthMax;
		SyringeCount[i] = Boss.SyringeCount;

		for (j = 0; j < 3; j++)
			HealingLevels[3 * i + j] = Boss.HealingLevels[j];

		i++;

		if (i == 3)
			break;
	}

	// for ( C = Level.ControllerList; C != none; C = C.NextController )
	// {
	// 	if ( KFMonsterController(C) != none && KFMonsterController(C).KFM.IsA('ZombieBoss') )
	// 	{
	// 		Boss = ZombieBoss(KFMonsterController(C).KFM);
	// 		Health[i] = Boss.Health;
	// 		HealthMax[i] = Boss.HealthMax;
	// 		SyringeCount[i] = Boss.SyringeCount;

	// 		for( j = 0; j < 3; j++ )
	// 			HealingLevels[3 * i + j] = Boss.HealingLevels[j];

	// 		i++;
	// 	}

	// 	if( i == 3 )
	// 		break;
	// }
}

defaultproperties
{
	DisplayString="%t: %p% Syringe: %s" //"Health: %h/%m %p% Syringes: %s"
	bAffectSpectators=True
	bAffectPlayers=True
	bAddToServerPackages=True
	GroupName="MultiplePatHPBar"
	FriendlyName="Multiple Pat HP Bar"
	Description="It shows the remaining health of patriarchs."
	bAlwaysRelevant=True
	RemoteRole=ROLE_SimulatedProxy
	bNetNotify=True
}
