//=============================================================================
// Doom Deco Display Base. (Client side actor)
//=============================================================================
class DoomDecoDisplay extends Actor
	Transient;

var bool bChecked,bRenderDisabled;
var PlayerController RenderObject;

simulated function Tick( float D )
{
	local rotator TheNewRot;
	
	// Check for render object
	if( !bChecked )
	{
		bChecked = True;
		RenderObject = Level.GetLocalPlayerController();
		if( RenderObject==None ) // Could be an dedicated server... cancel everything.
		{
			Disable('Tick');
			Return;
		}
	}
	// To improve CPU useage.
	if( bRenderDisabled )
	{
		if( (LastRenderTime+1)>Level.TimeSeconds )
		{
			bRenderDisabled = False;
			SetDrawType(DT_StaticMesh);
		}
		else Return;
	}
	else if( (LastRenderTime+1)<Level.TimeSeconds )
	{
		bRenderDisabled = True;
		SetDrawType(DT_None);
		Return;
	}

	// Always face the player.
	TheNewRot = Class'DRendering'.Static.GetMyYaw(Class'DRendering'.Static.GetPlayerCamLoc(RenderObject),Owner.Location);

	// Update animation (rotation).
	if( Rotation!=TheNewRot )
		SetRotation(TheNewRot);
}

defaultproperties
{
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'DoomPawnsKF.NormalMesh'
     bTrailerAllowRotation=True
     Physics=PHYS_Trailer
     RemoteRole=ROLE_None
     Style=STY_Masked
     bAlwaysTick=True
}
