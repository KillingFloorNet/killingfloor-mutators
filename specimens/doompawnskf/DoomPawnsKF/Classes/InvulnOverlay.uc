Class InvulnOverlay extends HudOverlay;

var bool bNoRenderIt;

simulated function Render(Canvas C)
{
	if( bNoRenderIt )
		return;
	C.DrawColor = class'HUD'.default.WhiteColor;
	C.DrawColor.A = 60;
	C.Style = ERenderStyle.STY_Alpha;
	C.SetPos(0, 0);
	C.DrawTile(Texture'KillingFloorHUD.HUD.WhiteTexture', C.ClipX, C.ClipY, 0, 0, 1, 1);
}
simulated function FlashIt()
{
	bNoRenderIt = true;
	SetTimer(0.5,false);
}
simulated function Timer()
{
	bNoRenderIt = false;
}

defaultproperties
{
}
