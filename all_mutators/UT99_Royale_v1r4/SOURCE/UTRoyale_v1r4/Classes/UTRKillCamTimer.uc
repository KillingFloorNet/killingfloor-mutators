//=============================================================================
// UTRKillCamTimer.
//
// Author: Francesco Biscazzo
// Date: 2019
// ©copyright Francesco Biscazzo. All rights reserved.
//
// Description: Lets the owner view an interpolator until it reaches a killer and then lets the owner view the killer directly.
// NOTE: Got the dolly zoom formulas from here: https://docs.unity3d.com/2018.4/Documentation/Manual/DollyZoom.html
//=============================================================================
class UTRKillCamTimer extends UTRInterpolationTimer;

var UTRKillCamManager killCamManager;

var Actor killed, killer;
var float initialFOV;
var float initHeightAtDist;
var bool bStarted, bEnd;

replication {
	reliable if (Role == ROLE_Authority)
		startKillCamTimer;
}

simulated function calcTargetLoc() {
	target.setLocation(killer.location + 72 * vector(killer.rotation) + vect(0,0,1) * 15);
}

// Calculate the frustum height at a given distance from the camera.
simulated function float frustumHeightAtDistance(float dist) {
    return 2 * dist * Tan(PlayerPawn(owner).FOVAngle * 0.5);
}

// Calculate the FOV needed to get a given frustum height at a given distance.
simulated function float FOVForHeightAndDistance(float height, float dist) {
    return 2 * Atan(height * 0.5 / dist);
}

simulated function float dollyZoom(float dist) {
    return FOVForHeightAndDistance(initHeightAtDist, dist);
}

simulated function initKillCamTimer(UTRKillCamManager _killCamManager, Actor _interpolator, Actor _target) {
	killCamManager = _killCamManager;
	
	initInterpolationTimer(_interpolator, _target);
}

simulated function initInterpolationTimer(Actor _interpolator, Actor _target, optional bool bRotate) {
	super.initInterpolationTimer(_interpolator, _target, bRotate);
}

simulated function startKillCamTimer(Actor _killed, Actor _killer, float interval, int _maxIters) {
	killed = _killed;
	killer = _killer;
	initialFOV = PlayerPawn(owner).FOVAngle;
	calcTargetLoc();
    initHeightAtDist = frustumHeightAtDistance(VSize(killer.location - target.location));
	
	startTimer(interval, _maxIters);
	
	bStarted = true;
}

simulated function startTimer(float interval, int _maxIters) {
	super.startTimer(interval, _maxIters);
}

simulated function maxItersNotReached() {
	local float FOV;

	super.maxItersNotReached();
	
	interpolator.setRotation(rotator(killer.location - interpolator.location));
	
	// When a player dies its view is focused on its carcass with bBehindview set to True, so handle it.
	killCamManager.setOwnerViewTarget(interpolator, false);
	
	//PlayerPawn(owner).viewRotation = rotator(killer.location - interpolator.location);
	
	if (owner.isA('PlayerPawn')) {
		FOV = abs(dollyZoom(VSize(killer.location - interpolator.location))) * 100;
		// FOV is limited from 0 to 170.
		FOV = min(max(0, FOV), 170);
		FOV = min(initialFOV, FOV);
		// setFOVAngle() doesn't save the FOV config unlike setDesiredFOV(), so it's just a temporary change to the FOV.
		PlayerPawn(owner).setFOVAngle(FOV);
	}
}

simulated function maxItersReached() {
	super.maxItersReached();
	
	if (owner.IsA('PlayerPawn'))
		killCamManager.setOwnerViewTarget(target, false);
	bEnd = true;
	if ((owner == killed) && !UTRHUD(PlayerPawn(owner).myHUD).isInState('KillCam')) {
		UTRHUD(PlayerPawn(owner).myHUD).pendingKiller = killer;
		UTRHUD(PlayerPawn(owner).myHUD).gotoState('KillCam');
	}
	setTimer(3, false);
}

simulated event Timer() {
	if (!bEnd) {
		super.Timer();
	} else {
		super(Info).Timer();
	
		if (owner.isA('PlayerPawn')) {
			if (UTRHUD(PlayerPawn(owner).myHUD).isInState('KillCam'))
				UTRHUD(PlayerPawn(owner).myHUD).gotoState('');
			PlayerPawn(owner).setFOVAngle(initialFOV);
			if (killer != None)
				killCamManager.setOwnerViewTarget(killer, true);
			else
				killCamManager.setOwnerViewTarget(None, false);
			
			if (killer.isA('Pawn'))
				killCamManager.serverBecomeViewTarget(Pawn(killer));
		}
		
		killCamManager.killCamFinished();
	}
}

simulated function stopTimer() {
	super.stopTimer();
}

simulated event Tick(float DeltaTime) {
	super.Tick(DeltaTime);
	
	if (bStarted)
		if (killer == None) {
			stopTimer();
			maxItersReached();
			stopTimer();
			destroy();
		} else {
			if (target != None) {
				// FIXME - The killer may not be replicated and may disappear while the client is viewing the target.
				calcTargetLoc();
				target.setRotation(rotator(killer.location - target.location));
			}
		}
}

defaultproperties {
	RemoteRole=ROLE_SimulatedProxy
}
