//=============================================================================
// UTRInterpolationTimer.
//
// Author: Francesco Biscazzo
// Date: 2019
// ©copyright Francesco Biscazzo. All rights reserved.
//
// Description: Interpolates the owner to the target location.
//=============================================================================
class UTRInterpolationTimer extends UTRTimerInfo;

var Actor interpolator;

var name oldState;
var bool bOldCollideWorld, bOldCollideActors, bOldBlockActors, bOldBlockPlayers;
var EPhysics oldPhysics;
var bool bRotate;

function initInterpolationTimer(Actor _interpolator, Actor _target, optional bool _bRotate) {
	interpolator = _interpolator;
	target = _target;
	bRotate = _bRotate;
}

function startTimer(float interval, int _maxIters) {
	oldState = interpolator.GetStateName();
	interpolator.GotoState('');
	bOldCollideWorld = interpolator.bCollideWorld;
	interpolator.bCollideWorld = false;
	bOldCollideActors = interpolator.bCollideActors;
	bOldBlockActors = interpolator.bBlockActors;
	bOldBlockPlayers = interpolator.bBlockPlayers;
	interpolator.SetCollision(false, false, false);
	oldPhysics = interpolator.Physics;
	interpolator.SetPhysics(PHYS_None);

	super.startTimer(interval, _maxIters);
}

function maxItersNotReached() {
	/*
	local Rotator rotTarget;
	
	interpolator.setLocation(interpolator.location + (target.location - interpolator.location) / remainingIters);
	interpolator.setRotation(interpolator.rotation + (target.rotation - interpolator.rotation) / remainingIters);
	newRot.yaw = interpolator.rotation.yaw;
	interpolator.setRotation(newRot);
	if (interpolator.IsA('Pawn')) {
		if (!target.IsA('Pawn'))
			Pawn(interpolator).viewRotation = Pawn(interpolator).viewRotation + (target.rotation - Pawn(interpolator).viewRotation) / remainingIters;
		else
			Pawn(interpolator).viewRotation = Pawn(interpolator).viewRotation + (Pawn(target).viewRotation - Pawn(interpolator).viewRotation) / remainingIters;
			
		Pawn(interpolator).viewRotation.pitch = 0;
		Pawn(interpolator).viewRotation.roll = 0;
	}
	*/
	if ((interpolator != None) && (target != None)) {
		interpolator.setLocation(interpolator.location + (target.location - interpolator.location) / remainingIters);
		if (bRotate) {
			interpolator.setRotation(rotator(target.location - interpolator.location));
			if (interpolator.IsA('Pawn'))
				Pawn(interpolator).viewRotation = rotator(target.location - interpolator.location);
		}
	} else {
		counter = maxIters;
	}
}

function maxItersReached() {
	if (String(oldState) != class'UTRUtils'.static.getClassName(interpolator))
		interpolator.gotoState(oldState);
	interpolator.bCollideWorld = bOldCollideWorld;
	interpolator.setCollision(bOldCollideActors, bOldBlockActors, bOldBlockPlayers);
	interpolator.setPhysics(oldPhysics);
}
