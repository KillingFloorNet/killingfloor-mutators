//=============================================================================
// Doom rendering.
// Shortcut for checks...
//=============================================================================
class DRendering extends Object;

var Player LastReply;
var vector LastCamPos;
var float LastTimeStamp;
struct SavedAnimsType
{
	var texture MainFrame,AnimFrames[16];
	var int NumFrames;
};
var array<SavedAnimsType> SavedAnimations;

// Get the rotation for facing player
Static final function rotator GetMyYaw( vector End, vector Offset )
{
	local rotator Tmp;

	End.Z = 0;
	Offset.Z = 0;
	Tmp.Yaw = rotator(End-Offset).Yaw;
	Return Tmp;
}
// Get player's camera rotation.
Static final function vector GetPlayerCamLoc( PlayerController P )
{
	local rotator Tmp;
	local Actor A;
	
	if( P.Level.TimeSeconds!=Default.LastTimeStamp )
	{
		Default.LastTimeStamp = P.Level.TimeSeconds;
		P.PlayerCalcView(A,Default.LastCamPos,Tmp);
	}
	Return Default.LastCamPos;
}
// Get the animation rotation
Static final function byte GetAnimRot( int MonYaw, int ViewYaw )
{
	local int YawErr;
	
	YawErr = ((MonYaw & 65535) - (ViewYaw & 65535)) & 65535; // Get the yaw error.
	if( YawErr<3456 )
		Return 0;
	if( YawErr<11672 )
		Return 1;
	if( YawErr<19822 )
		Return 2;
	if( YawErr<27700 )
		Return 3;
	if( YawErr<36930 )
		Return 4;
	if( YawErr<44740 )
		Return 5;
	if( YawErr<53350 )
		Return 6;
	if( YawErr<60550 )
		Return 7;
	Return 0;
}
static final function array<Texture> GetAnimation( Texture Other )
{
	local int i,j,z;
	local array<Texture> Temp;
	local Texture T,TT;

	j = Default.SavedAnimations.Length;
	For( i=0; i<j; i++ )
	{
		if( Default.SavedAnimations[i].MainFrame==Other )
		{
			For( z=0; z<Default.SavedAnimations[i].NumFrames; z++ )
			{
				Temp.Length = z+1;
				Temp[z] = Default.SavedAnimations[i].AnimFrames[z];
			}
			Return Temp;
		}
	}
	Default.SavedAnimations.Length = j+1;
	Default.SavedAnimations[j].MainFrame = Other;
	T = Other;
	While( T!=None )
	{
		TT = T.AnimNext;
		T.AnimNext = None;
		Temp.Length = z+1;
		Temp[z] = T;
		Default.SavedAnimations[i].AnimFrames[z] = T;
		z++;
		if( z==16 ) Break;
		T = TT;
	}
	Default.SavedAnimations[i].NumFrames = z;
	//Log("Created new animation entry on slot"@j@"with"@z@"frames for"@Other); // FIXME - Only for debugging.
	Return Temp;
}

defaultproperties
{
}
