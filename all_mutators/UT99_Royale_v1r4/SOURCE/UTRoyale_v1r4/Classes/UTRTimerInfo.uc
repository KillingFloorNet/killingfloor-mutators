//=============================================================================
// UTRTimerInfo.
//
// Author: Francesco Biscazzo
// Date: 2016-2019
// ©copyright Francesco Biscazzo. All rights reserved.
//
// Description: Basically a timer that stops after the specified maxIter(ation)s, unless they are set to 0 then it will loop forever until stopTimer() will be called.
//=============================================================================
class UTRTimerInfo extends Info
	abstract;

var int counter, maxIters;
var int remainingIters; // For countdown timers.
var bool bLoop;

//To implement in subclasses.
function maxItersNotReached();
function maxItersReached();

/*
 * If maxIters is 0 then the timer will loop forever until stopTimer() will be called.
 */
function startTimer(float interval, int _maxIters) {
	counter = 0;
	bLoop = (_maxIters == 0);
	maxIters = max(_maxIters, 1);
	
	//The timer has to start immediately with no delay.
	Timer();
	if ((counter <= maxIters) || bLoop)
		setTimer(interval, true);
}

function stopTimer() {
	setTimer(0, false);
}

event Timer() {
	super.Timer();

	if (!bLoop && (counter >= maxIters)) {
		stopTimer();
		maxItersReached();
	} else {
		remainingIters = maxIters - counter;
		maxItersNotReached();
		counter++;
	}
}