//=============================================================================
// BFGBallExp.
//=============================================================================
class BFGBallExp extends FlameExpSpid;

simulated Function Timer()
{
	CurAnimFrame++;
	if( CurAnimFrame>=TotalLen )
		Return;
	Texture = ExpAnimation[CurAnimFrame];
	if( CurAnimFrame==1 )
		SetDrawScale3D(vect(2,2,1));
	else if( CurAnimFrame==2 )
		SetDrawScale3D(vect(4,2,1));
	else if( CurAnimFrame==3 )
		SetDrawScale3D(vect(4,0.5,1));
	else if( CurAnimFrame==4 )
		SetDrawScale3D(vect(4,0.25,1));
}

defaultproperties
{
     EffectSound1=Sound'DoomPawnsKF.BFG.DSRXPLOD'
     ExploAnim=Texture'DoomPawnsKF.BFG.BFE1A0'
     LifeSpan=1.300000
     DrawScale=0.600000
     TransientSoundVolume=2.000000
}
