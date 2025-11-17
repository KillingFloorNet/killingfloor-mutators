// --------------------------------------------------------------
// HUD_Glasshouse
// --------------------------------------------------------------

// Custom HUD class for Glasshouse gameplay .
// Displays remaining spawn locations for each team.

// Author :  Alex Quick

// --------------------------------------------------------------


class HUD_Glasshouse extends HUDKillingFloor;


simulated function DrawKFHUDTextElements(Canvas C)
{
  local float PosX, PosY;
  local float YourStringX, YourStringY, TheirStringX, TheirStringY;
  local string YourHealth, TheirHealth;
  local int YourHealthVal, TheirHealthVal;
  local GH_GRI GlasshouseGRI;
  local Color DrawClr;

  GlasshouseGRI = GH_GRI(PlayerOwner.GameReplicationInfo);

  // Countdown Text
  if (GlasshouseGRI != none && GlasshouseGRI.bMatchHasBegun)
  {
    YourHealthVal = Int(GlasshouseGRI.GetRemainingSpawns(PlayerOwner.GetTeamNum()));
    TheirHealthVal = Int(GlasshouseGRI.GetRemainingSpawns(1-PlayerOwner.GetTeamNum()));

    YourHealth  = "Your building  :"$YourHealthVal$"%" ;
    TheirHealth = "Their building :"$TheirHealthVal$"%";

    // Draw ViewTarget's team's building health
    PosX = C.ClipX * 0.9;
    PosY = C.ClipY * 0.1;

    C.Font = LoadFont(2);
    C.StrLen(YourHealth, YourStringX, YourStringY);
    C.SetPos(PosX - (YourStringX * 0.5), PosY);

    DrawClr = GetHealthDrawClr(C, YourHealthVal);
    C.SetDrawColor(DrawClr.R, DrawClr.G, DrawClr.B, KFHUDAlpha);
    C.DrawText(YourHealth, false);

    // And the opposing team's ...
    C.Font = LoadFont(2);
    C.StrLen(TheirHealth, TheirStringX, TheirStringY);

    PosY -= TheirStringY * 1.5;
    C.SetPos(PosX - (TheirStringX * 0.5), PosY);

    DrawClr = GetHealthDrawClr(C, TheirHealthVal);
    C.SetDrawColor(DrawClr.R, DrawClr.G, DrawClr.B, KFHUDAlpha);
    C.DrawText(TheirHealth, false);
  }

  // Hints
  if (KFPlayerController(PlayerOwner) != none)
  {
    KFPlayerController(PlayerOwner).CheckForHint(10);
  }
}


function Color GetHealthDrawClr(Canvas C, int HealthPct)
{
  if (HealthPct >= 80)
  {
    return C.static.MakeColor(0, 255, 0);
  }
  else
  {
    if (HealthPct < 80 && HealthPct > 30)
    {
      return C.static.MakeColor(255, 255, 0);
    }
  }

  return C.static.MakeColor(255, 0, 0);
}


defaultproperties{}