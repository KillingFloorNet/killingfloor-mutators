//=============================================================================
// UTRArrow.
//
// Author: Francesco Biscazzo
// Date: 2019
// ©copyright Francesco Biscazzo. All rights reserved.
//
// Description: An arrow used to indicate locations. E.g. The center of the zone.
//=============================================================================
class UTRArrow extends Info;

#exec MESH IMPORT MESH=BR_Arrow ANIVFILE=Models\BR_Arrow_a.3d DATAFILE=Models\BR_Arrow_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=BR_Arrow X=0 Y=0 Z=0 YAW=-64 PITCH=64 ROLL=64

#exec MESH SEQUENCE MESH=BR_Arrow SEQ=ALL    STARTFRAME=0 NUMFRAMES=0 RATE=24
#exec MESH SEQUENCE MESH=BR_Arrow SEQ=Still    STARTFRAME=0 NUMFRAMES=1 RATE=24

#exec MESHMAP SCALE MESHMAP=BR_Arrow X=0.1 Y=0.1 Z=0.2
#exec TEXTURE IMPORT NAME=BR_Arrow_Texture_0 FILE=Textures\BR_Arrow_Texture_0.bmp GROUP=Skins
#exec MESHMAP SETTEXTURE MESHMAP=BR_Arrow NUM=0 TEXTURE=BR_Arrow_Texture_0

defaultproperties
{
	RemoteRole=ROLE_None
	bHidden=False
	DrawType=DT_Mesh
	Mesh=BR_Arrow
	Skin=BR_Arrow_Texture_0
	bUnlit=True
	DrawScale=0.5
	Style=STY_Translucent
}