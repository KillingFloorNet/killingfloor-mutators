Class ToxinOverlay extends InvulnOverlay;

simulated function Render(Canvas C)
{
	if( bNoRenderIt )
		return;
	C.DrawColor = class'HUD'.default.GreenColor;
	C.DrawColor.A = 60;
	C.Style = ERenderStyle.STY_Alpha;
	C.SetPos(0, 0);
	C.DrawTile(Texture'KillingFloorHUD.HUD.WhiteTexture', C.ClipX, C.ClipY, 0, 0, 1, 1);
}

defaultproperties
{
}
