//=============================================================================
// PlasmaBallExp.
//=============================================================================
class PlasmaBallExp extends FlameExpSpid;

simulated Function Timer()
{
	local float S;

	CurAnimFrame++;
	if( CurAnimFrame>=TotalLen )
		Return;
	Texture = ExpAnimation[CurAnimFrame];
	if( CurAnimFrame==1 || CurAnimFrame==2 )
		S = Default.DrawScale*2;
	else S = Default.DrawScale;
	if( DrawScale!=S )
		SetDrawScale(S);
}

defaultproperties
{
     ExploAnim=Texture'DoomPawnsKF.PlasmaGun.PLSEA0'
     DrawScale=0.600000
}
