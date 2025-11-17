//=============================================================================
// BFGRayFX.
//=============================================================================
class BFGRayFX extends FlameExpSpid;

simulated Function Timer()
{
	CurAnimFrame++;
	if( CurAnimFrame>=TotalLen )
		Return;
	Texture = ExpAnimation[CurAnimFrame];
	if( CurAnimFrame==3 )
		SetDrawScale(0.25);
}

defaultproperties
{
     EffectSound1=None
     ExploAnim=Texture'DoomPawnsKF.BFG.BFE2A0'
     RemoteRole=ROLE_SimulatedProxy
     LifeSpan=0.500000
     DrawScale=0.700000
}
