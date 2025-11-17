//=============================================================================
// UTRReplicationInfo.
//
// Author: Francesco Biscazzo
// Date: 2019
// ©copyright Francesco Biscazzo. All rights reserved.
//
// Description: Manages UTRoyale's variables that need to be replicated.
//=============================================================================
class UTRReplicationInfo extends TournamentGameReplicationInfo;

var bool bDebug;

var bool bInitialized;
var int timerCountDown;
var bool bDrawItemsOnRadar, bActualDrawSoundsOnRadar;
var float radarStepHearingDistMulByMapSize, radarOtherHearingDistMulByMapSize;
var float radarSightDistMulByMapSize, radarMulBySightDistZ;
var float radarMinDistToShowZLevel;
var float deathBlipTime;
var float killCamResolution, killCamSpeed;
var vector zoneCenter;
var float maxZoneRadius;
var float nearOutOfRadarMaxDist;

replication
{
	reliable if (bNetInitial && (Role == ROLE_Authority))
		bDebug, bInitialized, bDrawItemsOnRadar, bActualDrawSoundsOnRadar, radarStepHearingDistMulByMapSize, radarOtherHearingDistMulByMapSize
		, radarSightDistMulByMapSize, radarMulBySightDistZ, radarMinDistToShowZLevel, deathBlipTime, zoneCenter
		, maxZoneRadius, nearOutOfRadarMaxDist, killCamResolution, killCamSpeed;

	reliable if (Role == ROLE_Authority)
		timerCountDown;
}