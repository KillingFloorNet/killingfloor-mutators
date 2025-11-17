//=============================================================================
// UTRHUD.
//
// Author: Francesco Biscazzo
// Date: 2019
// ©copyright Francesco Biscazzo. All rights reserved.
//
// Description: Displays a radar and other features to improve UTRoyale gameplay.
//=============================================================================
class UTRHUD extends ChallengeHUD;

#exec TEXTURE IMPORT NAME=Radar FILE=TEXTURES\Radar.bmp GROUP="Radar" MIPS=OFF
#exec TEXTURE IMPORT NAME=Blip FILE=TEXTURES\Blip.bmp GROUP="Blips" MIPS=OFF
#exec TEXTURE IMPORT NAME=BlipDown FILE=TEXTURES\BlipDown.bmp GROUP="Blips" MIPS=OFF
#exec TEXTURE IMPORT NAME=BlipUp FILE=TEXTURES\BlipUp.bmp GROUP="Blips" MIPS=OFF
#exec TEXTURE IMPORT NAME=Circle FILE=TEXTURES\Circle.bmp GROUP="Blips" MIPS=OFF
#exec TEXTURE IMPORT NAME=XIcon FILE=TEXTURES\XIcon.bmp GROUP="Blips" MIPS=OFF

var Color BlankColor, OrangeColor;

var UTRZone zone;

var UTRArrow arrow;
var bool bHideArrow;

var UTRReplicationInfo UTRReplication;
var() globalconfig bool bHideRadar;
var Actor viewingActor; // The actor the owner of the HUD is viewing.
var() globalconfig bool bRadarTop, bRadarBottom, bRadarLeft, bRadarRight; // Radar positions.
var() globalconfig float radarMarginMulByScreenX, radarMarginMulByScreenY;
var float radarMarginX, radarMarginY; // Margins from the screen borders to the radar.
var float radarCenterX, radarCenterY; // Radar's center coordinates.
var float defaultRadarSize; // Used to reset the radar size to its default size.
var() globalconfig float radarSize;
var float actualRadarSize; // Scaled radar size by the screen resolution.
var float mapRadarProportion; // The proportion between the map and the radar.
var() globalconfig float blipSize;
var float actualBlipSize; // Scaled blip size by actualRadarSize;

var float initialZoneRadius;
var vector zoneCenter;
var float maxZoneRadius;
var float nearOutOfRadarMaxDist; // The maximum distance the viewingActor can be from the center of the radar before its blip gradually disappears.
var float minDistToShowZLevel; // The minimum distance on the Z axis an actor can be from the viewingActor before its blip gradually disappears.
var float headerDist; // The distance from the player blip and its direction pointer.
var float sightDist; // The maximum distance an actor can be from the viewingActor before its blip gradually disappears.

var String offRadarText, zoneCountdownText;

var() globalconfig int cmdInfoInterval; // If 0 the player will be informed about the commands only once, every commandsInfoInterval seconds otherwise.
var bool bCmdInfoFirstTime;
var int cmdInfoCounter;

var Actor pendingKiller; // Last actor who killed this HUD owner.
var bool bTakingScreenshot, bScreenshotTaken; // sshot command takes sometime to take a screenshot.
var Sound screenshotSound;

// Debug
var bool bWallHack;
var bool bHideMap;

struct Cursor {
	var float x, y, LClickX, LClickY, MClickX, MClickY, RClickX, RClickY;
};

simulated event Spawned() {
	super.Spawned();
	
	SaveConfig();
	
	defaultRadarSize = radarSize;
}

simulated function calcRadarPos(Canvas canvas) {
	actualRadarSize = radarSize * min(canvas.clipX, canvas.clipY);
	mapRadarProportion = actualRadarSize / maxZoneRadius;

	if (bRadarTop) {
		if (!bRadarBottom)
			radarMarginY = canvas.clipY * radarMarginMulByScreenY;
		else
			radarMarginY = (canvas.clipY / 2) - actualRadarSize;
	} else if (bRadarBottom)
		radarMarginY = canvas.clipY - (canvas.clipY * radarMarginMulByScreenY) - actualRadarSize;
	if (bRadarLeft) {
		if (!bRadarRight)
			radarMarginX = canvas.clipX * radarMarginMulByScreenX;
		else
			radarMarginX = (canvas.clipX / 2) - actualRadarSize;
	} else if (bRadarRight)
		radarMarginX = canvas.clipX - (canvas.clipX * radarMarginMulByScreenX) - actualRadarSize;
	
	radarCenterX = radarMarginX + (actualRadarSize / 2);
	radarCenterY = radarMarginY + (actualRadarSize / 2);
	
	/*
	// DEBUG
	canvas.DrawColor = WhiteColor;
	canvas.SetPos(radarCenterX - (actualBlipSize / 2), radarCenterY - (actualBlipSize / 2));
	canvas.DrawTile(Texture'Blip', actualBlipSize, actualBlipSize, 0, 0, Texture'Blip'.USize, Texture'Blip'.VSize);
	*/
	
}

simulated function calcActualBlipSize(Canvas canvas) {
	actualBlipSize = blipSize * actualRadarSize;
}

/*
 *	Get a cursor struct instance based on the mouse cursor coordinates.
 */
simulated function Cursor getCursor() {
	local UWindowRootWindow root;
	local Cursor cursor;
	
	playerOwner = PlayerPawn(Owner);
	
	root = WindowConsole(playerOwner.player.console).root;
	
	cursor.x = root.mouseX * root.GUIScale - root.MouseWindow.Cursor.HotX;
	cursor.y = root.mouseY * root.GUISCale - root.MouseWindow.Cursor.HotY;
	
	cursor.LClickX = WindowConsole(playerOwner.player.console).root.mouseWindow.clickX;
	cursor.LClickY = WindowConsole(playerOwner.player.console).root.mouseWindow.clickY;
	cursor.MClickX = WindowConsole(playerOwner.player.console).root.mouseWindow.MClickX;
	cursor.MClickY = WindowConsole(playerOwner.player.console).root.mouseWindow.MClickY;
	cursor.RClickX = WindowConsole(playerOwner.player.console).root.mouseWindow.RClickX;
	cursor.RClickX = WindowConsole(playerOwner.player.console).root.mouseWindow.RClickY;
	
	return cursor;
}

/*
 *	Locate a point on the screen to a location on the map.
 */
simulated function vector screenLocToMap(float x, float y) {
	local vector locOnMap;
	
	locOnMap.x = ((x - radarCenterX) * 2) / mapRadarProportion;
	locOnMap.y = ((y - radarCenterY) * 2) / mapRadarProportion;
	locOnMap += zoneCenter;
	
	return locOnMap;
}

exec function debugToggleRadarMap() {
	bHideMap = !bHideMap;
}

exec function debugToggleWallhack() {
	if (UTRReplication.bDebug)
		bWallHack = !bWallHack;
}

/*
 *	Teleport the player owning this HUD to the mouse cursor coordinates located on the map.
 *	NOTE: You must have the console open in order to make this function work.
 */
exec function debugTeleport() {
	local Cursor cursor;
	local vector locOnMap;
	
	playerOwner = PlayerPawn(Owner);

	if (UTRReplication.bDebug) {
		cursor = getCursor();
		
		locOnMap = screenLocToMap(cursor.x, cursor.y);
		locOnMap.z = playerOwner.location.z;
		
		playerOwner.consoleCommand("MUTATE"@"DEBUGTELEPORT"@locOnMap.x@locOnMap.y@locOnMap.z);
	}
}

/*
 *	Show a blip on the mouse cursor coordinates located on the map.
 *	NOTE: You must have the console open in order to make this function work.
 *	
 *	Parameters format: <lifeSpan> <type> <subtype>
 */
exec function debugBlip(String params) {
	local Cursor cursor;
	local vector locOnMap;
	local float _lifeSpan;
	local String type, subtype;
	
	playerOwner = PlayerPawn(Owner);

	if (UTRReplication.bDebug) {
		cursor = getCursor();
		
		locOnMap = screenLocToMap(cursor.x, cursor.y);
		locOnMap.z = playerOwner.location.z;
		
		_lifeSpan = class'UTRUtils'.static.getFloatParameter(params, 0);
		type = class'UTRUtils'.static.getStringParameter(params, 1, false);
		subtype = class'UTRUtils'.static.getStringParameter(params, 2, false);
		if (subtype == "")
			subtype = "NONE";
		playerOwner.consoleCommand("MUTATE"@"DEBUGBLIP"@_lifeSpan@type@subtype@locOnMap.x@locOnMap.y@locOnMap.z);
	}
}

exec function CMD() {
	playerOwner = PlayerPawn(Owner);

	playerOwner.ClientMessage(" ");
	playerOwner.ClientMessage(" ");
	playerOwner.ClientMessage("["$Left(default.class, InStr(default.class, "."))$" Commands BEGIN]");
	playerOwner.ClientMessage(" ");
	playerOwner.ClientMessage("cmd - Display this thing.");
	playerOwner.ClientMessage("stopmusic - Stop the music which is currently being played.");
	playerOwner.ClientMessage("radarlegend - Show the legend for the icons displayed on the radar.");
	playerOwner.ClientMessage("radarpos <position> - Move the radar to the specified position that can be a mix between a pair of words from this list 'top', 'left', 'right', 'bottom', 'middle' or just 'center'.");
	playerOwner.ClientMessage("resetradarsize - Reset the size of the radar.");
	playerOwner.ClientMessage("radarsizedec [amount] - Decrease the radar size by the specified amount.");
	playerOwner.ClientMessage("radarsizeinc [amount] - Increase the radar size by the specified amount.");
	playerOwner.ClientMessage("togglePath - Toggle the visibility of the arrow that indicates the zone's center.");
	if (UTRReplication.bDebug) {
		playerOwner.ClientMessage(" ");
		playerOwner.ClientMessage("* DEBUG COMMANDS *");
		playerOwner.ClientMessage("[mutate] debugTeleport [<x> <y> <z>] - Teleport to a location, based on the radar and the mouse cursor coordinates unless 'mutate' is used.");
		playerOwner.ClientMessage("[mutate] debugBlip [<lifespan> <type> <subtype> <x> <y> <z>] - Spawn a blip on a location, based on the radar and the mouse cursor coordinates unless 'mutate' is used.");
		playerOwner.ClientMessage("debugToggleWallhack - Toggle wallhack.");
		playerOwner.ClientMessage("mutate debugkilled - Simulate the killing of the viewing actor by a random bot.");
	}
	playerOwner.ClientMessage(" ");
	playerOwner.ClientMessage("["$Left(default.class, InStr(default.class, "."))$" Commands END]");
	playerOwner.ClientMessage(" ");
	playerOwner.ClientMessage(" ");
}

exec function stopMusic() {
	playerOwner.ClientSetMusic(None, 0, 0, MTRAN_None);
}

exec function togglePath() {
	bHideArrow = !bHideArrow;
}

exec function radarLegend() {
	playerOwner.ClientMessage("[RADAR LEGEND BEGIN]");
	playerOwner.ClientMessage("* Info about blips *");
	playerOwner.ClientMessage("Up arrow - Something that is above the viewing player/actor");
	playerOwner.ClientMessage("Down arrow - Something that is below the viewing player/actor");
	playerOwner.ClientMessage("* Blips *");
	playerOwner.ClientMessage("Yellow(Big) - The viewing player/actor");
	playerOwner.ClientMessage("Yellow(Little) - The direction of the viewing player/actor");
	if (UTRReplication.bDrawItemsOnRadar)
		playerOwner.ClientMessage("Cyan - Weapon");
	if (UTRReplication.bActualDrawSoundsOnRadar) {
		playerOwner.ClientMessage("Orange - Step");
		playerOwner.ClientMessage("Red - Shooting");
	}
	playerOwner.ClientMessage("* Symbols *");
	playerOwner.ClientMessage("Red 'X' - Death event");
	playerOwner.ClientMessage("[RADAR LEGEND END]");
}

exec function radarPos(String pos) {
	bRadarLeft = false;
	bRadarRight = false;
	bRadarTop = false;
	bRadarBottom = false;

	if (Caps(pos) == "TOPLEFT" || Caps(pos) == "LEFTTOP") {
		bRadarTop = true;
		bRadarLeft = true;
	} else if (Caps(pos) == "TOPMIDDLE" || Caps(pos) == "MIDDLETOP") {
		bRadarTop = true;
		bRadarLeft = true;
		bRadarRight = true;
	} else if (Caps(pos) == "TOPRIGHT" || Caps(pos) == "RIGHTTOP") {
		bRadarTop = true;
		bRadarRight = true;
	} else if (Caps(pos) == "BOTTOMLEFT" || Caps(pos) == "LEFTBOTTOM") {
		bRadarBottom = true;
		bRadarLeft = true;
	} else if (Caps(pos) == "BOTTOMMIDDLE" || Caps(pos) == "MIDDLEBOTTOM") {
		bRadarBottom = true;
		bRadarLeft = true;
		bRadarRight = true;
	} else if (Caps(pos) == "BOTTOMRIGHT" || Caps(pos) == "RIGHTBOTTOM") {
		bRadarBottom = true;
		bRadarRight = true;
	} else if (Caps(pos) == "LEFTMIDDLE" || Caps(pos) == "MIDDLELEFT") {
		bRadarLeft = true;
		bRadarBottom = true;
		bRadarTop = true;
	} else if (Caps(pos) == "RIGHTMIDDLE" || Caps(pos) == "MIDDLERIGHT") {
		bRadarRight = true;
		bRadarBottom = true;
		bRadarTop = true;
	} else if (Caps(pos) == "CENTER") {
		bRadarLeft = true;
		bRadarRight = true;
		bRadarBottom = true;
		bRadarTop = true;
	}
		
	SaveConfig();
}

exec function resetRadarSize() {
	radarSize = defaultRadarSize;
	
	SaveConfig();
}

exec function radarSizeDec(optional float amount) {
	if (amount == 0)
		amount = 0.05;
		
	radarSize -= amount;
	
	SaveConfig();
}

exec function radarSizeInc(optional float amount) {
	if (amount == 0)
		amount = 0.05;
	
	radarSize += amount;
	
	SaveConfig();
}

exec function GrowHUD() {
	if ( bHideHUD )
		bHideHud = false;
	else if ( bHideAmmo )
		bHideAmmo = false;
	else if ( bHideFrags )
		bHideFrags = false;
	else if ( bHideTeamInfo )
		bHideTeamInfo = false;
	else if ( bHideAllWeapons )
		bHideAllWeapons = false;
	else if ( bHideRadar )
		bHideRadar = false;
	else if ( bHideStatus )
		bHideStatus = false;
	else 
		WeaponScale = 1.0;

	SaveConfig();
}

exec function ShrinkHUD() {
	if ( !bLowRes && (WeaponScale * HUDScale > 0.8) )
		WeaponScale = 0.8/HUDScale;
	else if ( !bHideStatus )
		bHideStatus = true;
	else if ( !bHideRadar )
		bHideRadar = true;
	else if ( !bHideAllWeapons )
		bHideAllWeapons = true;
	else if ( !bHideTeamInfo )
		bHideTeamInfo = true;
	else if ( !bHideFrags )
		bHideFrags = true;
	else if ( !bHideAmmo )
		bHideAmmo = true;
	else
		bHideHud = true;

	SaveConfig();
}

/*
 *	Return true if the blip was drawn, false otherwise.
 *	NOTE: The opacity of the blip will be 0 if loc is off radar.
 *
 *	@loc the location of the actor in the map.
 *	@size the size of the blip.
 *	@color the color of the blip.
 *	@customTexture if not None the texture of the blip, otherwise the standard textures will be used.
 *	@bCheckZ if True and customTexture is None, BlipDown, Blip or BlipUp will be used respectively if loc is below, at the same z level or above sourceLocZ.
 *	@sourceLocZ if bCheckZ is True acts as a threshold to display BlipDown, Blip or BlipUp. (See @bCheckZ for more details).
 */
simulated function bool DrawBlip(Canvas canvas, vector loc, float size, Color color, optional Texture customTexture, optional bool bCheckZ, optional float sourceLocZ) {
	local Texture finalTexture;
	local vector locOnRadar;
	local float dist;

	// Not sure if blips should be visible when out of the radar only in the Z axis.
	
	dist = VSize(loc - zoneCenter);
	if (dist <= maxZoneRadius) {
		if (dist > (maxZoneRadius - nearOutOfRadarMaxDist))
			color = class'UTRUtils'.static.mapToColor(dist, maxZoneRadius - nearOutOfRadarMaxDist, maxZoneRadius, color, BlankColor);
		canvas.DrawColor = color;
		//rotatedLoc = Vector(viewingActor.rotation) * (loc - zoneCenter) + zoneCenter;
		locOnRadar = loc - zoneCenter;
		canvas.SetPos(radarCenterX - (size / 2) + ((locOnRadar.x * mapRadarProportion) / 2), radarCenterY - (size / 2) + ((locOnRadar.y * mapRadarProportion) / 2));
		
		finalTexture = customTexture;
		if (customTexture == None) {
			if (bCheckZ && (abs(sourceLocZ - loc.z) >= minDistToShowZLevel)) {
				if (loc.z < sourceLocZ)
					finalTexture = Texture'BlipDown';
				else if (loc.z > sourceLocZ)
					finalTexture = Texture'BlipUp';
			} else
				finalTexture = Texture'Blip';
		}
		
		canvas.DrawTile(finalTexture, size, size, 0, 0, finalTexture.USize, finalTexture.VSize);
		
		return true;
	}
	
	return false;
}

simulated function DrawArrow(Canvas canvas) {
	local Rotator axisAngleRot;

	if (zone != None) {
		if (arrow == None)
				arrow = spawn(class'UTRArrow');
		else
			if (viewingActor.isA('Pawn')) {
				arrow.setLocation(Pawn(viewingActor).location + 200 * Vector(Pawn(viewingActor).viewRotation) + vect(0,0,1) * 15);
				axisAngleRot = Rotator(zoneCenter - arrow.location);
				arrow.setRotation(axisAngleRot);
				canvas.DrawActor(arrow, false, true);
			}
	}
}

simulated function DrawMap(Canvas canvas) {
	local vector loc;
	local rotator rot;
	local bool bOldHidden;
	
	if (UTRReplication.bDebug)
		if (zone != None) {
			loc = zoneCenter;
			loc.z += maxZoneRadius;
			//loc.z = viewingActor.location.z;
			//if (viewingActor.IsA('Pawn'))
			//	loc.z += Pawn(viewingActor).baseEyeHeight;
			
			//rot = viewingActor.ViewRotation;
			rot.yaw = -(32768 / 2);
			rot.pitch = -(32768 / 2);

			bOldHidden = zone.bHidden;
			zone.bHidden = true;
			canvas.DrawPortal(radarMarginX, radarMarginY, actualRadarSize, actualRadarSize, viewingActor, loc, rot);
			zone.bHidden = bOldHidden;
		}
}

/*
 *	Draw the radar and represent the actors location using blips.
 */
simulated function DrawRadar(Canvas canvas) {
	local float currZoneRadius;
	local Weapon weapon;
	local Color color;
	local float dist;
	local UTRBlip utrBlip;
	local float XL, YL;
	
	/* sidenote: I would've liked to constraint blips inside the circle, but I'm tired. */
	calcRadarPos(canvas);
	calcActualBlipSize(canvas);
	
	canvas.Style = ERenderStyle.STY_Translucent;
	
	if (!bHideMap)
		DrawMap(canvas);
	
	if (zone != None) {
		// Draw zone (as circle).
		currZoneRadius = zone.DrawScale * class'UTRZone'.default.meshRadius;
		
		canvas.DrawColor = RedColor;
		canvas.SetPos(radarCenterX - ((currZoneRadius * mapRadarProportion) / 2), radarCenterY - ((currZoneRadius * mapRadarProportion) / 2));
		canvas.DrawTile(Texture'Circle', currZoneRadius * mapRadarProportion, currZoneRadius * mapRadarProportion, 0, 0, Texture'Circle'.USize, Texture'Circle'.VSize);
	}
	
	// Draw weapons and base their opacity on the distance from the viewingActor.
	if (UTRReplication.bDrawItemsOnRadar)
		foreach AllActors(class'Weapon', weapon)
			if ((weapon.Owner == None) && (!weapon.IsInState('Sleeping'))) {
				dist = VSize(viewingActor.location - weapon.location);
				if (!viewingActor.fastTrace(weapon.location, viewingActor.location))
					dist += (abs(viewingActor.location.z - weapon.location.z) * UTRReplication.radarMulBySightDistZ);
				if (dist <= sightDist) {
					color = class'UTRUtils'.static.mapToColor(dist, sightDist, 0, BlankColor, CyanColor);
					DrawBlip(canvas, weapon.location, actualBlipSize / 1.3, color,, true, viewingActor.location.z);
				}
			}
	
	foreach AllActors(class'UTRBlip', utrBlip)
		if (utrBlip.type == 'DEATH') {
			// Draw frag.
			color = class'UTRUtils'.static.mapToColor(utrBlip.clientLifeSpan, 0, utrBlip.initialLifeSpan, BlankColor, RedColor);
			DrawBlip(canvas, utrBlip.location, actualBlipSize / 0.75, color, Texture'XIcon');
		} else if (utrBlip.type == 'NOISE')
			if (utrBlip.actorInstigator != viewingActor)
				if (UTRReplication.bActualDrawSoundsOnRadar)
					if (utrBlip.subtype == 'OTHER') {
						if (VSize(utrBlip.location - viewingActor.location) <= (maxZoneRadius * UTRReplication.radarOtherHearingDistMulByMapSize)) {
							// Draw misc noise.
							// Set opacity by lifeSpan.
							color = class'UTRUtils'.static.mapToColor(utrBlip.clientLifeSpan, 0, utrBlip.initialLifeSpan, BlankColor, RedColor);
							// Set opacity by distance.
							color = class'UTRUtils'.static.mapToColor(VSize(utrBlip.location - viewingActor.location), 0, maxZoneRadius * UTRReplication.radarOtherHearingDistMulByMapSize, color, BlankColor);
							DrawBlip(canvas, utrBlip.location, actualBlipSize / 1.315, color);
						}
					} else if (utrBlip.subtype == 'PLAYER') {
						if (VSize(utrBlip.location - viewingActor.location) <= (maxZoneRadius * UTRReplication.radarStepHearingDistMulByMapSize)) {
							// Draw player noise, like steps.
							// Set opacity by lifeSpan.
							color = class'UTRUtils'.static.mapToColor(utrBlip.clientLifeSpan, 0, utrBlip.initialLifeSpan, BlankColor, OrangeColor);
							// Set opacity by distance.
							color = class'UTRUtils'.static.mapToColor(VSize(utrBlip.location - viewingActor.location), 0, maxZoneRadius * UTRReplication.radarStepHearingDistMulByMapSize, color, BlankColor);
							DrawBlip(canvas, utrBlip.location, actualBlipSize / 1.35, color);
						}
					}
	
	// Draw player.
	DrawBlip(canvas, viewingActor.location, actualBlipSize, GoldColor);
	// Draw player's header.
	DrawBlip(canvas, viewingActor.location + ((headerDist / mapRadarProportion) * actualRadarSize) * Vector(viewingActor.rotation), actualBlipSize / 2, GoldColor);
	
	if (VSize(viewingActor.location - zoneCenter) > maxZoneRadius) {
		// The player is out of the zone, draw the "OFF RADAR" text.
		canvas.DrawColor = WhiteColor;
		canvas.Font = class'UTRUtils'.static.getFont(min(canvas.clipX, canvas.clipY));
		canvas.StrLen(offRadarText, XL, YL);
		canvas.SetPos(radarCenterX - (XL / 2), radarCenterY - (YL / 2));
		canvas.DrawText(offRadarText);
	} else {
		if (UTRReplication.timerCountDown > 0) {
			// Draw the zone countdown text.
			canvas.DrawColor = WhiteColor;
			canvas.Font = class'UTRUtils'.static.getFont(min(canvas.clipX, canvas.clipY));
			canvas.StrLen(zoneCountdownText, XL, YL);
			canvas.SetPos(radarCenterX - (XL / 2), radarCenterY - (YL / 2) - YL);
			canvas.DrawText(zoneCountdownText);
			canvas.Font = class'UTRUtils'.static.getFont(min(canvas.clipX, canvas.clipY), false, true);
			canvas.StrLen(UTRReplication.timerCountDown, XL, YL);
			canvas.SetPos(radarCenterX - (XL / 2), radarCenterY - (YL / 2) + YL);
			canvas.DrawText(UTRReplication.timerCountDown);
		}
	}
	
	// Draw radar shape.
	canvas.DrawColor = GreenColor;
	canvas.SetPos(radarMarginX, radarMarginY);
	canvas.DrawTile(Texture'Radar', actualRadarSize, actualRadarSize, 0, 0, Texture'Radar'.USize, Texture'Radar'.VSize);
}

simulated function DrawWallHack(Canvas canvas) {
	local Pawn pawn;

	if (UTRReplication.bDebug)
		foreach AllActors(class'Pawn', pawn)
			if (pawn != Owner)
				if (pawn.IsA('Bots') || pawn.IsA('Bot') || pawn.IsA('PlayerPawn')) {
					//if (!pawn.bHidden && !pawn.IsInState('Dying') && (!pawn.playerReplicationInfo.bFeigningDeath && ((Caps(Left(pawn.AnimSequence, 5)) != "DEATH") && (Caps(Left(pawn.AnimSequence, 4)) != "DEAD"))))
					//if (!pawn.bHidden)
					canvas.DrawActor(pawn, false, true);
				}
}

simulated function PostRender(Canvas canvas) {
	local UTRZone foundZone;
	local String pendingKillerName;

	super.PostRender(canvas);
	
	HUDSetup(canvas);
	// Initialize the HUD vars that don't rely on the zone.
	// Get the actor we are viewing (it doesn't have to necessarly be a pawn).
	viewingActor = playerOwner;
	if (playerOwner.ViewTarget != None)
		viewingActor = playerOwner.ViewTarget;
	
	if ((UTRReplication == None) && ((playerOwner.GameReplicationInfo != None) && UTRReplicationInfo(playerOwner.GameReplicationInfo).bInitialized)) {
		UTRReplication = UTRReplicationInfo(playerOwner.GameReplicationInfo);
		
		// Initialize the HUD vars that rely on the zone.
		
		nearOutOfRadarMaxDist = UTRReplication.nearOutOfRadarMaxDist;
		
		zoneCenter = UTRReplication.zoneCenter;
		maxZoneRadius = UTRReplication.maxZoneRadius;
		sightDist = maxZoneRadius * UTRReplication.radarSightDistMulByMapSize;
		initialZoneRadius = maxZoneRadius;
		
		minDistToShowZLevel = UTRReplication.radarMinDistToShowZLevel;
	}
	
	if (zone == None) {
		// Find the zone.
		foreach AllActors(class'UTRZone', zone) {
			foundZone = zone;
			
			break;
		}
	}
	
	if (bWallHack)
		DrawWallHack(canvas);
	
	if (!bHideArrow)
		DrawArrow(canvas);
	
	if (UTRReplication != None)
		if(!bHideHUD)
			if (!viewingActor.isA('Pawn')
				|| (viewingActor.isA('Pawn') && ((Pawn(viewingActor).playerReplicationInfo != None)
				&& ((!Pawn(viewingActor).playerReplicationInfo.bIsSpectator
				|| ((Pawn(viewingActor).playerReplicationInfo.bIsSpectator && (viewingActor.isA('PlayerPawn') && (PlayerPawn(viewingActor).ViewTarget != None)))))))))
				if (!bHideRadar)
					DrawRadar(canvas);
	
	if (pendingKiller != None) {
		canvas.Font = myFonts.getSmallFont(canvas.clipX);
		canvas.bCenter = true;
		canvas.Style = ERenderStyle.STY_Normal;
		canvas.DrawColor = cyanColor;
		canvas.SetPos(4, canvas.ClipY - 96 * Scale);
		if (pendingKiller.isA('Pawn') && (Pawn(pendingKiller).playerReplicationInfo != None))
			pendingKillerName = Pawn(pendingKiller).playerReplicationInfo.playerName;
		else
			pendingKillerName = String(pendingKiller.name);
		canvas.DrawText("You have been killed by"@pendingKillerName, true);
	}
	
	if (bTakingScreenshot) {
		takeScreenshot(canvas);
		
		bTakingScreenshot = false;
		bScreenshotTaken = true;
	}
}

simulated event Timer() {
	super.Timer();
	
	playerOwner = PlayerPawn(Owner);
	if (playerOwner != None) {
		if (((cmdInfoInterval <= 0) && bCmdInfoFirstTime) || ((cmdInfoInterval > 0) && ((cmdInfoCounter++ % cmdInfoInterval) == 0))) {
			playerOwner.ClientMessage(Left(default.class, InStr(default.class, "."))$" - Type cmd in console to display all the available commands.");
			
			bCmdInfoFirstTime = false;
		}
	}
}

simulated function takeScreenshot(Canvas canvas) {
	playerOwner.ClearProgressMessages();
	
	playerOwner.consoleCommand("shot");
	
	playerOwner.PlaySound(screenshotSound, SLOT_None, 32.0, false);
	playerOwner.PlaySound(screenshotSound, SLOT_Interface, 32.0, false);
	playerOwner.PlaySound(screenshotSound, SLOT_Misc, 32.0, false);
	playerOwner.PlaySound(screenshotSound, SLOT_Talk, 32.0, false);
}

simulated state KillCam {
	simulated event PostRender(Canvas canvas) {
		global.PostRender(canvas);
		
		if (!bTakingScreenshot && !bScreenshotTaken) {
			canvas.Font = myFonts.getMediumFont(canvas.clipX);
			canvas.bCenter = true;
			canvas.Style = ERenderStyle.STY_Normal;
			canvas.DrawColor = whiteColor;
			canvas.SetPos(4, 25 * scale);
			canvas.DrawText("Press 'Jump' to take a screenshot!", true);
		}
	}

	exec function Jump() {
		bTakingScreenshot = true;
	}
	
	simulated event EndState() {
		super.EndState();
		
		bScreenshotTaken = false;
		pendingKiller = None;
	}
}

defaultproperties {
	radarMarginMulByScreenX=0.02
	radarMarginMulByScreenY=0.02
	radarSize=0.225
	blipSize=0.08
	headerDist=0.1
	bRadarTop=True
	bRadarBottom=True
	bRadarLeft=True
	bRadarRight=False
	OrangeColor=(R=255,G=127,B=0)
	offRadarText="OFF RADAR"
	zoneCountdownText="ZONE APPEARS IN"
	bHideArrow=True
	bHideMap=True
	bCmdInfoFirstTime=True
	cmdInfoInterval=120
	screenshotSound=Botpack.ASMD.Click
}