//=============================================================================
// UTRSoundManager.
//
// Author: Francesco Biscazzo
// Date: 2019
// ©copyright Francesco Biscazzo. All rights reserved.
//
// Description: Represents sounds as blips in the radar.
// NOTE: Some functions are not overriden to let the pawn chain workflow work.
//=============================================================================
class UTRSoundManager extends Pawn;

simulated event RenderOverlays(Canvas canvas) {}

function String GetHumanName() {
	return "";
}

function ClientPutDown(Weapon Current, Weapon Next) {}

function SetDisplayProperties(ERenderStyle NewStyle, texture NewTexture, bool bLighting, bool bEnviroMap ) {}

function SetDefaultDisplayProperties() {}

function BecomeViewTarget() {
	local PlayerPawn pp;

	foreach AllActors(class'PlayerPawn', pp)
		if (pp.viewTarget == self)
			pp.viewClass(class'Pawn');
}

event FellOutOfWorld() {}

function PlayRecoil(float Rate);

//function TeamBroadcast( coerce string Msg) {}

function SendGlobalMessage(PlayerReplicationInfo Recipient, name MessageType, byte MessageID, float Wait) {}


function SendTeamMessage(PlayerReplicationInfo Recipient, name MessageType, byte MessageID, float Wait) {}

//function SendVoiceMessage(PlayerReplicationInfo Sender, PlayerReplicationInfo Recipient, name messagetype, byte messageID, name broadcasttype) {}

function float GetRating() {
	return 0;
}

function AddVelocity( vector NewVelocity) {}

function ClientDying(name DamageType, vector HitLocation) {}

function ClientReStart() {}

function ClientGameEnded() {}

function TossWeapon() {}

exec function NextItem() {}

function Inventory FindInventoryType( class DesiredClass ) {}

function bool AddInventory( inventory NewItem ) {
	return false;
}

function bool DeleteInventory( inventory Item ) {
	return true;
}

function ChangedWeapon() {}

event bool EncroachingOn( actor Other ) {
	return false;
}

event EncroachedBy( actor Other ) {}

function gibbedBy(actor Other) {}

event PlayerTimeOut() {}

function JumpOffPawn() {}

singular event BaseChange() {}

/*
simulated event Destroyed() {
	super(Actor).Destroyed();
}
*/

function PreSetMovement() {}

simulated function SetMesh() {}

static function SetMultiSkin( actor SkinActor, string SkinName, string FaceName, byte TeamNum ) {}

static function GetMultiSkin( Actor SkinActor, out string SkinName, out string FaceName ) {}

static function bool SetSkinElement(Actor SkinActor, int SkinNo, string SkinName, string DefaultSkinName) {
	return false;
}

function InitPlayerReplicationInfo() {}

function PlayWalking() {}

function PlayMovingAttack() {}

function PlayWaitingAmbush() {}

function TweenToRunning(float tweentime) {}

function TweenToWalking(float tweentime) {}

function TweenToPatrolStop(float tweentime) {}

function TweenToWaiting(float tweentime) {}

function PlayThreatening() {}

function PlayPatrolStop() {}

function PlayTurning() {}

function PlayDying(name DamageType, vector HitLoc) {}

function PlayGutHit(float tweentime) {}

function PlayHeadHit(float tweentime) {}

function PlayLeftHit(float tweentime) {}

function PlayRightHit(float tweentime) {}

function actor TraceShot(out vector HitLocation, out vector HitNormal, vector EndTrace, vector StartTrace) {
	return None;
}

simulated function bool AdjustHitLocation(out vector HitLocation, vector TraceDir) {
	return false;
}

function PlayTakeHit(float tweentime, vector HitLoc, int damage) {}

function PlayVictoryDance() {}

function PlayOutOfWater() {}

function PlayLanded(float impactVel) {}

function PlayTakeHitSound(int Damage, name damageType, int Mult) {}

function DropDecoration() {}

function GrabDecoration() {}

function TakeFallingDamage() {}

function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, name damageType) {}

//function Died(pawn Killer, name damageType, vector HitLocation) {}

function Carcass SpawnCarcass() {
	return None;
}

function HidePlayer() {}

function Killed(pawn Killer, pawn Other, name damageType) {}

function string KillMessage( name damageType, pawn Other ) {
	return "";
}

function Falling() {}

event Landed(vector HitNormal) {}

event FootZoneChange(ZoneInfo newFootZone) {}

event HeadZoneChange(ZoneInfo newHeadZone) {}

event PainTimer() {}

function bool CheckWaterJump(out vector WallNormal) {}

exec function bool SwitchToBestWeapon() {}

state Dying {}

state GameEnded {}

event HearNoise(float loudness, Actor noiseMaker) {
	local UTRBlip blip;
	
	if (noiseMaker.instigator == Owner) {
		if (UTRoyale(Level.Game).UTRBaseMut != None)
			UTRoyale(Level.Game).UTRBaseMut.manageNoise(noiseMaker, loudness);
	
		if (loudness != 0) {
			blip = spawn(class'UTRBlip',,, noiseMaker.location);
			blip.actorInstigator = Pawn(Owner);
			blip.type = 'NOISE';
			if (noiseMaker.IsA('PlayerPawn') || noiseMaker.IsA('Bot') || noiseMaker.IsA('Bots')) {
				blip.subtype = 'PLAYER';
				blip.initialLifeSpan = loudness + UTRoyale(Level.Game).radarStepLoudnessAddTo;
			} else {
				blip.subtype = 'OTHER';
				blip.initialLifeSpan = loudness + UTRoyale(Level.Game).radarOtherLoudnessAddTo;
			}
			
			blip.lifeSpan = blip.initialLifeSpan;
		}
	}
}

defaultproperties {
	RemoteRole=ROLE_None
    HearingThreshold=0.000000
	Physics=PHYS_None
	bCollideWorld=False;
	bCollideActors=False;
    bBlockActors=False
    bBlockPlayers=False
    bProjTarget=False
	PlayerReplicationInfoClass=None
	bHidden=True
}