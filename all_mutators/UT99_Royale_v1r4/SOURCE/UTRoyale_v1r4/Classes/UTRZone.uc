//=============================================================================
// UTRZone.
//
// Author: Francesco Biscazzo
// Date: 2019
// ©copyright Francesco Biscazzo. All rights reserved.
//
// Description: A cool zone mesh.
//=============================================================================
class UTRZone extends Decoration;

#exec MESH IMPORT MESH=BR_Icosphere ANIVFILE=Models\BR_Icosphere_a.3d DATAFILE=Models\BR_Icosphere_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=BR_Icosphere X=0 Y=0 Z=0 YAW=-64 PITCH=0 ROLL=0

#exec MESH SEQUENCE MESH=BR_Icosphere SEQ=ALL    STARTFRAME=0 NUMFRAMES=0 RATE=24
#exec MESH SEQUENCE MESH=BR_Icosphere SEQ=Still    STARTFRAME=0 NUMFRAMES=1 RATE=24

#exec MESHMAP SCALE MESHMAP=BR_Icosphere X=0.1 Y=0.1 Z=0.2
#exec TEXTURE IMPORT NAME=BR_Icosphere_Texture_0 FILE=Textures\BR_Icosphere_Texture_0.bmp GROUP=Skins
#exec MESHMAP SETTEXTURE MESHMAP=BR_Icosphere NUM=0 TEXTURE=BR_Icosphere_Texture_0

//var String package; // This class's package name.

// Animated Skin settings.
var String texturePrefix;
var int textureFrames;
var int textureCurrFrame;
var float textureFramesInterval;

var vector origLoc; // Server-side location of the zone.
var float meshRadius; // The radius that most matches the mesh's shape.

var PlayerPawn localPP; // The local PlayerPawn.

// About Texture animaton:
// A Texture animation could be done as the commented code below.
// Or probably with a transparent ScriptedTexture used as skin and a "Font" texture without transparent pixels, then looping ScriptedTexture.DrawColoredText() changing colors.
// Or by using ScriptedTexture.ReplaceTexture().

simulated event Spawned() {
	super.Spawned();
	
	origLoc = Location;
	
	//package = class'UTRUtils'.static.getPackageName(self);
	// XXX - A gradient animation would be nice. (But I think this would require too many textures depending on the gradient frequency).
	//setTimer(textureFramesInterval, true);
}

/*
simulated event Timer() {
	super.Timer();
	
	// Give the zone's Skin an animation.
	Skin = Texture(DynamicLoadObject(package$"."$texturePrefix$int(textureCurrFrame++ % textureFrames), class'Texture'));
}
*/

simulated event PostBeginPlay() {
	local PlayerPawn pp;
	
	super.PostBeginPlay();

	// Find the local player.
	foreach AllActors(class'PlayerPawn', pp)
		if((pp.player != None) && (Viewport(pp.player) != None)) {
			localPP = pp;
			
			break;
		}
}

simulated event Tick(float DeltaTime) {
	local Actor ViewActor;
	local vector CameraLocation;
	local rotator CameraRotation;
	
	super.Tick(DeltaTime);
	
	if (localPP != None) {
		// Let the zone be always visible by placing its PrePivot constantly next to the local player.
		/*
		Quote from Feralidragon: https://ut99.org/viewtopic.php?p=28062#p28062
		"
		PrePivot is an actual variable which can be used with several physics types and all it does is much simpler:
		makes the mesh being rendered with PrePivot constant and absolute offset (meaning it's not affected by rotation).
		Therefore to fix a mesh based actor with this all you have to do is making the mesh location X forward
		relative to the player location relative it's viewrotation (better yet, using the camera location and rotation,
		as that way you include this fix from any point of view), and the PrePivot X backward.
		"
		*/
		localPP.PlayerCalcView(ViewActor, CameraLocation, CameraRotation);
		SetLocation(CameraLocation + (vect(256, 0, 0) >> CameraRotation));
		PrePivot = origLoc - Location;
	}
}

defaultproperties {
	meshRadius=100
	bAlwaysRelevant=True
	RemoteRole=ROLE_SimulatedProxy
	DrawType=DT_Mesh
    Mesh=BR_Icosphere
	Skin=BR_Icosphere_Texture_0
	texturePrefix="BR_Icosphere_Texture_"
	textureFrames=2
	textureFramesInterval=0.1
	Style=STY_Translucent
	AmbientGlow=255
	bUnlit=True
	
	bStatic=False
	bStasis=False
}