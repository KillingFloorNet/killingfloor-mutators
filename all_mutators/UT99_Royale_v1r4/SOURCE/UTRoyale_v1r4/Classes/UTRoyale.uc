//=============================================================================
// UTRoyale.
//
// Author: Francesco Biscazzo
// Date: 2019
// ©copyright Francesco Biscazzo. All rights reserved.
//
// Description: A last man standing gametype where players have only 1 life. A zone is spawned and shrinks through the match, every player outside of it will get hit.
//=============================================================================
class UTRoyale extends LastManStanding
	config;

var() config bool bDebug;
var() config bool bBotWeaponFix;

var UTRBaseMutator UTRBaseMut; // linked list of mutators which affect UTRoyale gameplay.

var() config bool bNoBots, bStartAlone; // If bStartAlone is True the match can be started even when only one player is on. (Used just because MinPlayers is globalconfig instead of config).
var() config bool bStealth; // If True, players will have their AmbientGlow set to 0.

// bUseCentroid - If True the zone's center will be at the centroid between all the PlayerStart locations.
// bUsePSNearCentroid - If True and if bUseCentroid is True then the zone's center will be at the PlayerStart which is the nearest to the centroid.
// bUseRandomPS - If True the zone's center will be at a random picked PlayerStart.
// bUseMostBottomPSLevel - If True the zone's center will be at the most bottom level a PlayerStart have been placed in the map. Can work in
//							conjunction with the above zone's center settings.
var() config bool bUseCentroid, bUsePSNearCentroid, bUseRandomPS, bUseMostBottomPSLevel;
var vector zoneCenter;
var float maxZoneRadius; // Distance between the zone's center and the farthest PlayerStart from it plus extraInitialRadiusMulByMapSize.

var bool bZoneCountDownStarted;
var() config float zoneCountDown; //Max countdown time in seconds before the zone spawns.
var int timerCountDown; // Current countdown time. If 0 is reached the zone will spawn.
var UTRZone zone;
var bool bStop; // If False the zone shrinks at every Tick.

var float shrinkingSpeed;
var() config bool bAdjSpeedByPlayersCount; // If true the shrinking speed of the zone may increase by the players count. (e.g. when a player logs out the shrinking speed will increase).
var() config float speedMulByMapSize, speedIncByMapSizeDivByPlayers;
var() config float offZoneCheckRate; // Interval time that has to pass before TakeDamage() is called on every actor outside of the zone.
var int collRateCounter; // When reaches offZoneCheckRate TakeDamage() will be called on every actor outside of the zone.

var float radius;
var() config float extraInitialRadiusMulByMapSize; // Extra radius to apply to the zone when spawned.
var() config float minRadius; // Minimum radius the zone can shrink to.
var() config float damageMulByDist; // Damage every actor outside of the zone gets depending on the distance from the zone's center.
var float radiusOnLastHit; // Used to determine the first time an actor goes out of the zone.

var() config bool bSpawnOutsideZone; // If True players will be able to spawn outside of the zone.
var int psCount;
var int actualMaxPlayers; // Specifies how many players should be able to spawn based on factors like the map size and the amount of PlayerStarts in the map.
var() config int initialHealth, initialArmor;

var() config bool bDrawItemsOnRadar, bDrawSoundsOnRadar;
var bool bActualDrawSoundsOnRadar;

var() config float radarStepHearingDistMulByMapSize, radarOtherHearingDistMulByMapSize;
var() config float radarStepLoudnessAddTo, radarOtherLoudnessAddTo;
var() config float radarSightDistMulByMapSize, radarMulBySightDistZ;
var() config float radarMinDistToShowZLevel;
var() config float nearOutOfRadarMaxDist;

var() config float deathBlipTime;
var() config bool bEnableKillCam;
var() config float killCamResolution, killCamSpeed; // killCamResolution is inversely proportional to the killcam's zoom fps.

event Spawned() {
	super.Spawned();
	
	SaveConfig();
}

function registerUTRMutator(UTRBaseMutator mut) {
	mut.nextUTRMutator = UTRBaseMut;
	UTRBaseMut = mut;
}

function InitGameReplicationInfo() {
	super.InitGameReplicationInfo();
	
	UTRReplicationInfo(GameReplicationInfo).bDebug = bDebug;
	
	UTRReplicationInfo(GameReplicationInfo).bDrawItemsOnRadar = bDrawItemsOnRadar;
	UTRReplicationInfo(GameReplicationInfo).bActualDrawSoundsOnRadar = bActualDrawSoundsOnRadar;
	UTRReplicationInfo(GameReplicationInfo).radarStepHearingDistMulByMapSize = radarStepHearingDistMulByMapSize;
	UTRReplicationInfo(GameReplicationInfo).radarOtherHearingDistMulByMapSize = radarOtherHearingDistMulByMapSize;
	UTRReplicationInfo(GameReplicationInfo).radarSightDistMulByMapSize = radarSightDistMulByMapSize;
	UTRReplicationInfo(GameReplicationInfo).radarMulBySightDistZ = radarMulBySightDistZ;
	UTRReplicationInfo(GameReplicationInfo).radarMinDistToShowZLevel = radarMinDistToShowZLevel;
	UTRReplicationInfo(GameReplicationInfo).nearOutOfRadarMaxDist = nearOutOfRadarMaxDist;
	UTRReplicationInfo(GameReplicationInfo).deathBlipTime = deathBlipTime;
	UTRReplicationInfo(GameReplicationInfo).killCamResolution = killCamResolution;
	UTRReplicationInfo(GameReplicationInfo).killCamSpeed = killCamSpeed;
}

event InitGame( string Options, out string Error ) {	
	super(DeathMatchPlus).InitGame(Options, Error);
	
	Lives = 1;
	FragLimit = 0;
	//MinPlayers = max(2, MinPlayers);
	
	if (bDebug)
		Warn("bDebug is set to True!");
	
	if (bNoMonsters) {
		Warn("bNoMonsters is set to True, noise won't be displayed on the radar!");
		bActualDrawSoundsOnRadar = false;
	} else {
		bActualDrawSoundsOnRadar = bDrawSoundsOnRadar;
	}
}

event PostBeginPlay() {
	super.PostBeginPlay();

	initUTRoyale();
	UTRReplicationInfo(GameReplicationInfo).zoneCenter = zoneCenter;
	UTRReplicationInfo(GameReplicationInfo).maxZoneRadius = maxZoneRadius;
	
	UTRReplicationInfo(GameReplicationInfo).bInitialized = true;
}

function initUTRoyale() {
	local PlayerStart ps, selectedPS, nearestPS;
	local float minPsLocZ;
	local bool bFirstIter;
	local float probAdjCumul;
	
	foreach AllActors(class'PlayerStart', ps)
		if (ps.bEnabled)
			psCount++;
	
	// Set the location where the zone will be spawned at.
	zoneCenter = vect(0, 0, 0);
	if (bUseRandomPS) {
		bFirstIter = true;
		// Give equal probabilities for each PlayerStart.
		probAdjCumul = 1 / psCount;
		foreach AllActors(class'PlayerStart', ps) {
			if (bFirstIter) {
				selectedPS = ps;
				
				bFirstIter = false;
			}
			if (ps.bEnabled) {
				if (FRand() > probAdjCumul) {
					selectedPS = ps;
					
					break;
				}
				
				probAdjCumul += 1 / psCount;
			}
		}
		zoneCenter = selectedPS.location;
	} else if (bUseCentroid) {
		foreach AllActors(class'PlayerStart', ps) {
			if (ps.bEnabled) {
				zoneCenter.x += ps.location.x;
				zoneCenter.y += ps.location.y;
				zoneCenter.z += ps.location.z;
			}
		}
		zoneCenter /= psCount;
		
		if (bUsePSNearCentroid) {
			bFirstIter = true;
			foreach AllActors(class'PlayerStart', ps) {
				if (bFirstIter) {
					nearestPS = ps;
					
					bFirstIter = false;
				} else
					if (ps.bEnabled)
						if (VSize(ps.location - zoneCenter) < VSize(nearestPS.location - zoneCenter))
							nearestPS = ps;
			}
			zoneCenter = nearestPS.location;
		}
	}
	
	if (bUseMostBottomPSLevel) {
		bFirstIter = true;
		foreach AllActors(class'PlayerStart', ps) {
			if (bFirstIter) {
				minPsLocZ = ps.location.z;
				bFirstIter = false;
			} else
				if (ps.bEnabled)
					minPsLocZ = min(minPsLocZ, ps.location.Z);
		}
		zoneCenter.z = minPsLocZ;
	}
	
	if (UTRBaseMut != None)
		UTRBaseMut.settingZoneLocation(zoneCenter);
	
	// Find out how many players should be able to spawn based on factors like the map size and the amount of PlayerStarts in the map.
	foreach AllActors(class'PlayerStart', ps)
		if (ps.bEnabled)
			maxZoneRadius = max(minRadius, max(maxZoneRadius, VSize(ps.Location - zoneCenter)));
	maxZoneRadius += maxZoneRadius * extraInitialRadiusMulByMapSize;
	radius = maxZoneRadius;
	if (UTRBaseMut != None)
		UTRBaseMut.settingInitialZoneRadius(radius);
	
	actualMaxPlayers = Min(psCount, MaxPlayers);
	
	// Base the shrinking speed of the zone on the map size.
	shrinkingSpeed = maxZoneRadius * speedMulByMapSize;
	if (UTRBaseMut != None)
		UTRBaseMut.settingInitialShrinkingSpeed(shrinkingSpeed);
}

/* FindPlayerStart()
returns the 'best' player start for this player to start from.
PlayerStarts inside the zone have a higher priority than the ones out of the zone.
*/
function NavigationPoint FindPlayerStart(Pawn Player, optional byte InTeam, optional String incomingName) {
	local PlayerStart Dest, Candidate[16], Best;
	local float Score[16], BestScore, NextDist;
	local pawn OtherPlayer;
	local int i, num;
	local Teleporter Tel;
	local NavigationPoint N, LastPlayerStartSpot;
	local float outDist;

	if ( bStartMatch && (Player != None) && Player.IsA('TournamentPlayer') 
		&& (Level.NetMode == NM_Standalone)
		&& (TournamentPlayer(Player).StartSpot != None) ) {
		outDist = VSize(TournamentPlayer(Player).StartSpot.Location - zoneCenter);
		if ((zone == None) || bSpawnOutsideZone || ((zone != None) && (outDist <= radius)))
			return TournamentPlayer(Player).StartSpot;
	}

	if( incomingName!="" )
		foreach AllActors( class 'Teleporter', Tel )
			if( string(Tel.Tag)~=incomingName ) {
				outDist = VSize(Tel.Location - zoneCenter);
				if ((zone == None) || bSpawnOutsideZone || ((zone != None) && (outDist <= radius)))
					return Tel;
			}

	//choose candidates	
	for ( N=Level.NavigationPointList; N!=None; N=N.NextNavigationPoint )
	{
		Dest = PlayerStart(N);
		if ( (Dest != None) && Dest.bEnabled && !Dest.Region.Zone.bWaterZone )
		{
			outDist = VSize(Dest.Location - zoneCenter);
			if ((zone == None) || bSpawnOutsideZone || ((zone != None) && (outDist <= radius))) {
				if (num<16)
					Candidate[num] = Dest;
				else if (Rand(num) < 16)
					Candidate[Rand(16)] = Dest;
				num++;
			}
		}
	}

	if (num == 0 )
		foreach AllActors( class 'PlayerStart', Dest )
		{
			outDist = VSize(Dest.Location - zoneCenter);
			if ((zone == None) || bSpawnOutsideZone || ((zone != None) && (outDist <= radius))) {
				if (num<16)
					Candidate[num] = Dest;
				else if (Rand(num) < 16)
					Candidate[Rand(16)] = Dest;
				num++;
			}
		}

	if (num>16) num = 16;
	else if (num == 0)
		return None;

	if ( (Player != None) && Player.IsA('TournamentPlayer') 
		&& (TournamentPlayer(Player).StartSpot != None) ) {
		outDist = VSize(TournamentPlayer(Player).StartSpot.Location - zoneCenter);
		if ((zone == None) || bSpawnOutsideZone || ((zone != None) && (outDist <= radius)))
			LastPlayerStartSpot = TournamentPlayer(Player).StartSpot;
	}

	//assess candidates
	for (i=0;i<num;i++)
	{
		if ( (Candidate[i] == LastStartSpot) || (Candidate[i] == LastPlayerStartSpot) )
			Score[i] = -10000.0;
		else
			Score[i] = 3000 * FRand(); //randomize
	}		
	for ( OtherPlayer=Level.PawnList; OtherPlayer!=None; OtherPlayer=OtherPlayer.NextPawn)	
		if ( OtherPlayer.bIsPlayer && (OtherPlayer.Health > 0) && !OtherPlayer.IsA('Spectator') )
			for ( i=0; i<num; i++ )
			{
				if ( OtherPlayer.Region.Zone == Candidate[i].Region.Zone )
				{
					Score[i] -= 1500;
					NextDist = VSize(OtherPlayer.Location - Candidate[i].Location);
					if ( NextDist < OtherPlayer.CollisionRadius + OtherPlayer.CollisionHeight )
						Score[i] -= 1000000.0;
					else if ( (NextDist < 2000) && FastTrace(Candidate[i].Location, OtherPlayer.Location) )
						Score[i] -= (10000.0 - NextDist);
				}
				else if ( NumPlayers + NumBots == 2 )
				{
					Score[i] += 2 * VSize(OtherPlayer.Location - Candidate[i].Location);
					if ( FastTrace(Candidate[i].Location, OtherPlayer.Location) )
						Score[i] -= 10000;
				}
			}
	
	BestScore = Score[0];
	Best = Candidate[0];
	for (i=1;i<num;i++)
		if (Score[i] > BestScore)
		{
			BestScore = Score[i];
			Best = Candidate[i];
		}

	LastStartSpot = Best;
	return Best;
}

event PlayerPawn Login (String Portal, String Options, out String Error, class<playerpawn> SpawnClass) {
	local playerpawn NewPlayer;
	local Pawn P;

	// if more than 15% of the game is over, must join as spectator
	if ( TotalKills > 0.15 * (NumPlayers + NumBots) * Lives || ((NumPlayers + NumBots) >= actualMaxPlayers))
	{
		bDisallowOverride = true;
		SpawnClass = class'CHSpectator';
		if ( (NumSpectators >= MaxSpectators)
			&& ((Level.NetMode != NM_ListenServer) || (NumPlayers > 0)) )
		{
			MaxSpectators++;
		}
	}
	NewPlayer = super(DeathMatchPlus).Login(Portal, Options, Error, SpawnClass);

	if ( (NewPlayer != None) && !NewPlayer.IsA('Spectator') && !NewPlayer.IsA('Commander') )
		NewPlayer.PlayerReplicationInfo.Score = Lives;

	return NewPlayer;
}

function Logout(Pawn exiting) {
	local UTRSoundManager soundMngr;

	super.Logout(exiting);
	
	// Destroy the sound manager of the exiting pawn.
	foreach AllActors(class'UTRSoundManager', soundMngr)
		if (soundMngr.Owner == exiting)
			soundMngr.destroy();
}

function bool AddBot() {
	local bot NewBot;
	local NavigationPoint StartSpot;
	
	if (!bNoBots) {
		NewBot = SpawnBot(StartSpot);
		if ( NewBot == None )
		{
			log("Failed to spawn bot.");
			return false;
		}

		StartSpot.PlayTeleportEffect(NewBot, true);

		NewBot.PlayerReplicationInfo.bIsABot = True;

		// Log it.
		if (LocalLog != None)
		{
			LocalLog.LogPlayerConnect(NewBot);
			LocalLog.FlushLog();
		}
		if (WorldLog != None)
		{
			WorldLog.LogPlayerConnect(NewBot);
			WorldLog.FlushLog();
		}

		if (bActualDrawSoundsOnRadar)
			giveSoundMngr(NewBot);
		
		return true;
	}
	
	return false;
}

function StartMatch() {
	local int i;

	super.StartMatch();
	
	for (i = 0; i < (actualMaxPlayers - (NumPlayers + NumBots)); i++)
		// Make the game compensate the missing of the players that could have entered.
		onePlayerLess();
		
	bZoneCountDownStarted = true;
}

event PostLogin( playerpawn NewPlayer ) {
	super.PostLogin(NewPlayer);
	
	// Turn off the music for NewPlayer as it needs to pay attention to the noises without getting distracted.
	NewPlayer.ClientSetMusic(None, 0, 0, MTRAN_None);
}

event Timer() {
	local Actor actor;
	local float outDist;
	local int offZoneDamage;
	local vector offZoneHitLoc, offZoneMomentum;
	local name offZoneDmgType;
	
	super(DeathMatchPlus).Timer();
	
	if (bZoneCountDownStarted)
		if (zone == None) {
			if (++timerCountDown >= zoneCountDown) {
				zone = Spawn(class'UTRZone',,, zoneCenter);
				// Initialize the zone.
				radiusOnLastHit = radius;
				
				startShrinking();
				
				if (UTRBaseMut != None)
					UTRBaseMut.zoneSpawned();
					
				foreach AllActors(class'Actor', actor) {
					outDist = VSize(actor.Location - zoneCenter);
					if (outDist > radius) {
						if (UTRBaseMut != None)
							UTRBaseMut.actorOutOfZone(actor);
						if (caps(actor.tag) == "UTR_OUT_OF_ZONE")
							actor.trigger(zone, None);
					}
				}
				
				UTRReplicationInfo(GameReplicationInfo).timerCountDown = int(zoneCountDown - timerCountDown);
			} else
				if (int(zoneCountDown - timerCountDown) <= 10) {
					BroadcastMessage("Zone appears in:"@int(zoneCountDown - timerCountDown)$" seconds.");
					UTRReplicationInfo(GameReplicationInfo).timerCountDown = int(zoneCountDown - timerCountDown);
				}
		} else {
			if (!bGameEnded) {
				collRateCounter = ++collRateCounter % offZoneCheckRate;
				if (collRateCounter == 0) {
					foreach AllActors(class'Actor', actor) {
						if (class'UTRUtils'.static.getPackageName(actor) != class'UTRUtils'.static.getPackageName(self)) {
							outDist = VSize(actor.Location - zoneCenter);
							if (outDist > radius) {
								if (outDist < radiusOnLastHit) {
									if (UTRBaseMut != None)
										UTRBaseMut.actorOutOfZone(actor);
									if (caps(actor.tag) == "UTR_OUT_OF_ZONE")
										actor.trigger(zone, None);
								}
							
								offZoneDamage = max(1, (outDist - radius) * damageMulByDist);
								offZoneHitLoc = vect(0, 0, 0);
								offZoneMomentum = (zoneCenter - actor.location) / VSize(actor.location - zoneCenter);
								offZoneDmgType = '';
								if (UTRBaseMut != None)
									UTRBaseMut.takeDamageOutOfZone(offZoneDamage, actor, None, outDist, offZoneHitLoc, offZoneMomentum, offZoneDmgType);
								if (offZoneDamage != 0)
									actor.TakeDamage(offZoneDamage, None, offZoneHitLoc, offZoneMomentum, offZoneDmgType);
								
								if (actor.isA('PlayerPawn') && !actor.isA('Spectator') && !PlayerPawn(actor).playerReplicationInfo.bIsSpectator &&  !PlayerPawn(actor).playerReplicationInfo.bWaitingPlayer) {
									PlayerPawn(actor).ClearProgressMessages();
									PlayerPawn(actor).SetProgressTime(1);
									PlayerPawn(actor).SetProgressMessage("RETURN IN THE ZONE!", 0);
								} else if (actor.IsA('Inventory')) {
									// Help bots understand that they should stay in the zone.
									Inventory(actor).maxDesireability -= outDist * 0.01;
								} else if (actor.IsA('PlayerStart')) {
									if (!bSpawnOutsideZone)
										if (PlayerStart(actor).bEnabled)
											actualMaxPlayers = Min(--psCount, actualMaxPlayers);
								}
							}
						}
					}
					
					radiusOnLastHit = radius;
				}
			}
		}
}

/*
 *	Shows the victim who killed it.
 */
function showKillCam(PlayerPawn viewer, Pawn _killed, Pawn killer) {
	local UTRKillCamManager killCamManager;
	
	killCamManager = spawn(class'UTRKillCamManager', viewer);
	killCamManager.initKillCamManager(_killed, killer);
}

function killed(Pawn killer, Pawn other, name damageType ) {
	local PlayerPawn viewer;

	super.Killed(killer, other, damageType);
	
	if (!bEnableKillCam) {
		// Use a simple KillCam without dolly zoom.
		if (!other.isA('PlayerPawn')) {
			foreach AllActors(class'PlayerPawn', viewer)
				if (viewer.viewTarget == other) {
					if (viewer != killer) {
						viewer.viewTarget = killer;
						killer.becomeViewTarget();
					} else
						viewer.viewSelf();
				}
		}
	} else {
		if ((killer != None) && (killer != other))
			foreach AllActors(class'PlayerPawn', viewer)
				if ((viewer == other) || (viewer.viewTarget == other))
					if (viewer != killer)
						showKillCam(viewer, other, killer);
					else
						viewer.viewSelf();
	}
	
	onePlayerLess();
}

function scoreKill(Pawn killer, Pawn other) {
	other.DieCount++;
	if ((other.PlayerReplicationInfo != None) && (other.PlayerReplicationInfo.Score > 0))
		other.PlayerReplicationInfo.Score -= 1;
	if( (killer != other) && (killer != None) )
		killer.killCount++;
	BaseMutator.ScoreKill(killer, other);
}	

function bool IsRelevant(Actor other) {
	return super(DeathMatchPlus).IsRelevant(other);
}

event tick(float deltaTime) {
	super.tick(deltaTime);
	
	if (!bStop && (zone != None)) {
		// Shrink the zone.
		radius = FMax(minRadius, radius - (shrinkingSpeed * Level.TimeDilation));
		zone.DrawScale = radius / class'UTRZone'.default.meshRadius;
	}
}

function AddDefaultInventory(Pawn pawn) {
	local Inventory inv;
	local Weapon newWeapon;
	
	if ( pawn.IsA('Spectator') || (bRequireReady && (CountDown > 0)) )
		return;

	super(GameInfo).AddDefaultInventory(pawn);
	
	if (bUseTranslocator && (!bRatedGame || bRatedTranslocator)) {
		// Spawn Translocator.
		if (pawn.FindInventoryType(class'Translocator')== None) {
			newWeapon = Spawn(class'Translocator');
			if (newWeapon != None) {
				newWeapon.instigator = pawn;
				newWeapon.BecomeItem();
				pawn.AddInventory(newWeapon);
				newWeapon.GiveAmmo(pawn);
				newWeapon.SetSwitchPriority(pawn);
				newWeapon.WeaponSet(pawn);
			}
		}
	}
	
	if (bBotWeaponFix)
		// Give a weapon to the bots so that there won't be Accessed None's.
		if (pawn.isA('Bot') || pawn.isA('Bots'))
			if (pawn.FindInventoryType(class'Enforcer') == None) {
				newWeapon = Spawn(class'Enforcer');
				if (newWeapon != None) {
					newWeapon.instigator = pawn;
					newWeapon.BecomeItem();
					pawn.AddInventory(newWeapon);
					newWeapon.SetSwitchPriority(pawn);
					newWeapon.WeaponSet(pawn);
					
					//if (newWeapon.ammoType != None)
					//	newWeapon.ammoType.ammoAmount = 0;
				}
			}
	
	if (initialHealth > 0)
		pawn.Health = initialHealth;
	
	if (initialArmor > 0) {
		inv = Spawn(class'Armor2');
		if (inv != None) {
			inv.charge = initialArmor;
			inv.bHeldItem = true;
			inv.RespawnTime = 0.0;
			inv.GiveTo(pawn);
		}
	}
}

function bool NeedPlayers() {
	if (bStartAlone)
		return false;
	
	return super.NeedPlayers();
}

/*
 *	"Attach" a UTRSoundManager to an actor.
 */
function giveSoundMngr(Actor actor) {
	local UTRSoundManager soundMngr;
	
	if (!actor.IsA('Pawn') || (actor.IsA('Pawn') && !Pawn(actor).playerReplicationInfo.bIsSpectator)) {
		soundMngr = spawn(class'UTRSoundManager', actor,, actor.location);
		soundMngr.setBase(actor);
	}
}

function bool RestartPlayer(Pawn pawn)	 {
	local bool bResult;
	
	bResult = super.RestartPlayer(pawn);
	
	// It is never a spectator, this check is just to be sure.
	if (!pawn.isA('Spectator')) {
		if (bStealth)
			pawn.AmbientGlow = 0;
		
		if (bActualDrawSoundsOnRadar)
			giveSoundMngr(pawn);
	}
	
	return bResult;
}

/*
 * Make the shrinking of the zone faster basing on speedIncByMapSizeDivByPlayers.
 */
function onePlayerLess() {
	if (bAdjSpeedByPlayersCount)
		shrinkingSpeed += maxZoneRadius / speedIncByMapSizeDivByPlayers;
}

/*
 *	Start the shrinking of the zone.
 */
function startShrinking() {
	bStop = false;

	class'UTRUtils'.static.triggerActorsWithTag("UTR_ZONE_SHRINKING_START", Level);
	if (UTRBaseMut != None)
		UTRBaseMut.zoneShrinkingStart();
}

/*
 *	Stop the shrinking of the zone.
 */
function stopShrinking() {
	bStop = true;
	
	class'UTRUtils'.static.triggerActorsWithTag("UTR_ZONE_SHRINKING_STOP", Level);
	if (UTRBaseMut != None)
		UTRBaseMut.zoneShrinkingStop();
}

function EndGame(String Reason) {
	super.EndGame(reason);
	
	stopShrinking();
}

//MinPlayers=2
defaultproperties {
	Lives=0
	HUDType=Class'UTRHUD'
	StartUpMessage="UT Royale.  How long can you live?"
	BeaconName="UTR"
	GameName="UT Royale"
	DefaultWeapon=None
	GameReplicationInfoClass=Class'UTRReplicationInfo'
	MutatorClass=Class'UTRMutator'
	
	bStop=True
	
	bDebug=False
	bBotWeaponFix=True
	
	bNoBots=False
	bStartAlone=False
	bSpawnOutsideZone=False
	bStealth=True
	bUseCentroid=False
	bUsePSNearCentroid=False
	bUseMostBottomPSLevel=True
	bUseRandomPS=True
	zoneCountDown=20
	speedMulByMapSize=0.0000175
	bAdjSpeedByPlayersCount=True
	speedIncByMapSizeDivByPlayers=1000000
	offZoneCheckRate=0.5
	minRadius=150
	extraInitialRadiusMulByMapSize=0.1
	damageMulByDist=0.035
	initialHealth=200
	initialArmor=100
	bDrawItemsOnRadar=True
	bDrawSoundsOnRadar=True
	radarStepHearingDistMulByMapSize=0.35
	radarOtherHearingDistMulByMapSize=0.65
	radarStepLoudnessAddTo=0.1
	radarOtherLoudnessAddTo=1
	radarSightDistMulByMapSize=1
	radarMulBySightDistZ=5
	radarMinDistToShowZLevel=75
	nearOutOfRadarMaxDist=100
	deathBlipTime=5
	bEnableKillCam=True
	killCamResolution=0.004
	killCamSpeed=90
	
	bHighDetailGhosts=False
	FragLimit=0
	TimeLimit=0
	bMultiWeaponStay=True
	bForceRespawn=False
	bUseTranslocator=False
	MaxCommanders=0
	bNoMonsters=False
	bHumansOnly=False
	bCoopWeaponMode=False
	bClassicDeathMessages=False
	bCoopWeaponMode=False
}