//======================================================================
// Spectre bites you Very hard.
//======================================================================
class Spectre extends Demon;

var SpectreColor MyInvisShader;

simulated function SetShaderSkin( Material OverlayMat );
simulated function ResetShaderSkin()
{
	if( MyInvisShader==None )
		Return;
	MyInvisShader.Material = None;
	Level.ObjectPool.FreeObject(MyInvisShader);
	MyInvisShader = None;
	if( Render!=None )
		Render.Skins[0] = OrginalSkins[0];
}
simulated function UpdateSkin( Material NewSkin )
{
	if( Render==None ) Return;
	if( MyInvisShader==None )
	{
		MyInvisShader = SpectreColor(Level.ObjectPool.AllocateObject(Class'SpectreColor'));
		OrginalSkins.Length = 1;
	}
	MyInvisShader.Material = NewSkin;
	Render.Skins[0] = MyInvisShader;
	OrginalSkins[0] = NewSkin;
}
simulated function PostNetBeginPlay()
{
	Super.PostNetBeginPlay();
	bHandelShading = False; // No overlays for spectres.
}

defaultproperties
{
     MeleeDamageType=Class'DoomPawnsKF.SpectreAte'
     PawnHealth=180
     DeMeleeDamage=(Min=10,Max=45)
     ScoringValue=22
     Visibility=10
     Health=180
     MenuName="Spectre"
     ScaleGlow=0.350000
}
