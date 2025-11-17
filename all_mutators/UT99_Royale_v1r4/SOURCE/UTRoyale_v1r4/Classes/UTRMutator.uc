//=============================================================================
// UTRMutator.
//
// Author: Francesco Biscazzo
// Date: 2019
// ©copyright Francesco Biscazzo. All rights reserved.
//
// Description: Shows a blip of type 'DEATH' on the radar when players die, also destroys the sound managers of the bots who died as they won't respawn anymore.
//=============================================================================
class UTRMutator extends Mutator;

var name convertedString; // Used for String to Name conversions within the function 'stringToName()'.

/*
 * Parse a string to a name and return it.
 */
function name stringToName(String str)
{
	setPropertyText("convertedString", str);
	return convertedString;
}

function Mutate(string MutateString, PlayerPawn Sender) {
	local String params;
	local vector loc;
	local UTRBlip blip;
	local name subtype;
	local UTRKillCamTimer killCamTimer;
	local Actor viewingActor;
	local Bot bot, selectedBot;
	local UTRDummyActor dummyInterpolator, dummyTarget;

	super.Mutate(MutateString, Sender);
	
	if (Caps(Left(MutateString, Len("DEBUGTELEPORT"))) == "DEBUGTELEPORT") {
		if (UTRoyale(Level.Game).bDebug){
			params = Mid(MutateString, Len("DEBUGTELEPORT") + 1, Len(MutateString));
			loc.x = class'UTRUtils'.static.getFloatParameter(params, 0);
			loc.y = class'UTRUtils'.static.getFloatParameter(params, 1);
			loc.z = class'UTRUtils'.static.getFloatParameter(params, 2);
			Sender.setLocation(loc);
		}
	} else if (Caps(Left(MutateString, Len("DEBUGBLIP"))) == "DEBUGBLIP") {
		if (UTRoyale(Level.Game).bDebug) {
			params = Mid(MutateString, Len("DEBUGBLIP") + 1, Len(MutateString));
			loc.x = class'UTRUtils'.static.getFloatParameter(params, 3);
			loc.y = class'UTRUtils'.static.getFloatParameter(params, 4);
			loc.z = class'UTRUtils'.static.getFloatParameter(params, 5);
			blip = Spawn(class'UTRBlip',,, loc);
			blip.type = stringToName(class'UTRUtils'.static.getStringParameter(params, 1, false));
			blip.subtype = stringToName(class'UTRUtils'.static.getStringParameter(params, 2, false));
			blip.initialLifeSpan = class'UTRUtils'.static.getFloatParameter(params, 0);
			blip.lifeSpan = blip.initialLifeSpan;
		}
	} else if (Caps(Left(MutateString, Len("DEBUGKILLED"))) == "DEBUGKILLED") {
		if (UTRoyale(Level.Game).bDebug) {
			viewingActor = Sender;
			if (Sender.viewTarget != None)
				viewingActor = Sender.viewTarget;
		
			if (viewingActor.isA('PlayerPawn') || viewingActor.isA('Bot') || viewingActor.isA('Bots')) {
				foreach AllActors(class'Bot', bot)
					if (bot != viewingActor) {
						selectedBot = bot;
						
						break;
					}
				
				Pawn(viewingActor).health = 1;
				Pawn(viewingActor).TakeDamage(1, bot, vect(0,0,0), vect(0,0,0), '');
			}
		}
	}
}

function bool PreventDeath(Pawn Killed, Pawn Killer, name damageType, vector HitLocation) {
	local bool bPrevented;
	local UTRBlip blip;
	local UTRSoundManager soundMngr;
	
	local PlayerPawn viewer;
	
	bPrevented = super.PreventDeath(Killed, Killer, damageType, HitLocation);
	if (Killed.IsA('PlayerPawn') || Killed.IsA('Bot') || Killed.IsA('Bots'))
		if (!bPrevented) {
			// There have been a frag, represent it with a blip on the radar.
			blip = Spawn(class'UTRBlip',,, Killed.location);
			blip.type = 'DEATH';
			blip.subtype = damageType;
			blip.initialLifeSpan = UTRoyale(Level.Game).deathBlipTime;
			blip.lifeSpan = blip.initialLifeSpan;
			
			if (Killed.IsA('Bot') || Killed.IsA('Bots'))
				foreach AllActors(class'UTRSoundManager', soundMngr)
					if (soundMngr.Owner == Killed)
						soundMngr.destroy();
		}
	
	return bPrevented;
}