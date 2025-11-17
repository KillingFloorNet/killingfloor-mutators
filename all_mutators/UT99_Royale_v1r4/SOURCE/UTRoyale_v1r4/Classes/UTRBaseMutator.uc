//=============================================================================
// UTRBaseMutator.
//
// Author: Francesco Biscazzo
// Date: 2019
// ©copyright Francesco Biscazzo. All rights reserved.
//
// Description: The base mutator of all the UTRoyale mutators.
//=============================================================================
class UTRBaseMutator extends Mutator;

var UTRBaseMutator nextUTRMutator;

event spawned() {
	super.spawned();
	
	UTRoyale(Level.Game).registerUTRMutator(self);
}

function settingZoneLocation(out vector loc) {
	if (nextUTRMutator != None)
		nextUTRMutator.settingZoneLocation(loc);
}

function settingInitialZoneRadius(out float radius) {
	if (nextUTRMutator != None)
		nextUTRMutator.settingInitialZoneRadius(radius);
}

function settingInitialShrinkingSpeed(out float speed) {
	if (nextUTRMutator != None)
		nextUTRMutator.settingInitialShrinkingSpeed(speed);
}

function zoneSpawned() {
	if (nextUTRMutator != None)
		nextUTRMutator.zoneSpawned();
}

function zoneShrinkingStart() {
	if (nextUTRMutator != None)
		nextUTRMutator.zoneShrinkingStart();
}

function zoneShrinkingStop() {
	if (nextUTRMutator != None)
		nextUTRMutator.zoneShrinkingStop();
}

/*
 *	Called for any actor that stays right out of the zone and close to it.
 *	NOTE: A moving actor may move too fast and skip the trigger zone or may move inside the trigger zone multiple times.
 */
function actorOutOfZone(Actor actor) {
	if (nextUTRMutator != None)
		nextUTRMutator.actorOutOfZone(actor);
}

/*
 *	Called everytime an actor takes damage cause of being out of the zone.
 *
 *	@outDist the distance between the end-point of the zone radius toward the victim and the victim location.
 */
function takeDamageOutOfZone(out int actualDamage, Actor victim, Actor instigatedBy, float outDist, out Vector hitLocation, out Vector momentum, name damageType) {
	if (nextUTRMutator != None)
		nextUTRMutator.takeDamageOutOfZone(actualDamage, victim, instigatedBy, outDist, hitLocation, momentum, damageType);
}

function manageNoise(Actor noiseMaker, out float actualLoudness) {
	if (nextUTRMutator != None)
		nextUTRMutator.manageNoise(noiseMaker, actualLoudness);
}