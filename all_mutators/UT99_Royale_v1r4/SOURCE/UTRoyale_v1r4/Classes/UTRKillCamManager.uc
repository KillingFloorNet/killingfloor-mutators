//=============================================================================
// UTRKillCamManager.
//
// Author: Francesco Biscazzo
// Date: 2019
// ©copyright Francesco Biscazzo. All rights reserved.
//
// Description: Manages the interpolation an dolly zoom for the killcam.
//=============================================================================
class UTRKillCamManager extends UTRInterpolationTimer;

var UTRReplicationInfo UTRReplication;
var Actor killed, killer;
var UTRDummyActor dummyInterpolator, dummyTarget;

var bool bKillCamStarted;

replication {
	reliable if (Role == ROLE_Authority)
		UTRReplication, killed, killer, dummyInterpolator, dummyTarget, bKillCamStarted;

	reliable if (Role == ROLE_Authority)
		spawnKillCamTimer;
	
	reliable if (Role < ROLE_Authority)
		setOwnerViewTarget, serverBecomeViewTarget, setOwnerFOVAngle, killCamFinished;
}

simulated function killCamFinished() {
	dummyInterpolator.destroy();
	dummyTarget.destroy();
	destroy();
}

simulated function setOwnerViewTarget(Actor actor, bool bBehindview) {
	PlayerPawn(owner).viewTarget = actor;
	Pawn(owner).bBehindview = bBehindview;
}

simulated function serverBecomeViewTarget(Pawn pawn) {
	pawn.becomeViewTarget();
}

simulated function setOwnerFOVAngle(float FOV) {
	PlayerPawn(owner).setFOVAngle(FOV);
}

function initKillCamManager(Actor _killed, Actor _killer) {
	UTRReplication = UTRReplicationInfo(level.game.gameReplicationInfo);
	killed = _killed;
	killer = _killer;
	
	if (owner.isA('PlayerPawn')) {
		// Killer may be None because killed in the process.
		if ((killed != None) && (killer != None)) {
			dummyInterpolator = spawn(class'UTRDummyActor',,, killed.location);
			dummyTarget = spawn(class'UTRDummyActor');/*,,, killer.location + 72 * vector(killer.rotation) + vect(0,0,1) * 15);
			dummyTarget.setRotation(rotator(killer.location - dummyTarget.location));
			dummyTarget.setBase(killer);*/
		}
	}
}

simulated function spawnKillCamTimer() {
	local UTRKillCamTimer killCamTimer;
	
	killCamTimer = spawn(class'UTRKillCamTimer', owner);
	killCamTimer.initKillCamTimer(self, dummyInterpolator, dummyTarget);
	// A distance lower than 400 gives a bad resolution.
	killCamTimer.startKillCamTimer(killed, killer, UTRReplication.killCamResolution, UTRReplication.killCamSpeed);
}

simulated event Tick(float deltaTime) {
	super.Tick(deltaTime);
	
	if ((role < ROLE_Authority) || (level.netmode == NM_Standalone))
		if (!bKillCamStarted)
			if ((UTRReplication != None) && (dummyInterpolator != None) && (dummyTarget != None) && (killed != None) && (killer != None)) {
				spawnKillCamTimer();
				bKillCamStarted = true;
			}
}

defaultproperties {
	RemoteRole=ROLE_SimulatedProxy
}
