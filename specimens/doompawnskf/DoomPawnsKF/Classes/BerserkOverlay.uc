Class BerserkOverlay extends HudOverlay;

simulated function Render(Canvas C)
{
	C.DrawColor = class'HUD'.default.RedColor;
	C.DrawColor.A = int((LifeSpan/Default.LifeSpan)*100.f);
	C.Style = ERenderStyle.STY_Alpha;
	C.SetPos(0, 0);
	C.DrawTile(Texture'KillingFloorHUD.HUD.WhiteTexture', C.ClipX, C.ClipY, 0, 0, 1, 1);
}

defaultproperties
{
     LifeSpan=40.000000
}
