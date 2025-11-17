// --------------------------------------------------------------
// ZombieClot_GH
// --------------------------------------------------------------

// Modified Type of Clot for use in the glasshouse map.

// Author :  Alex Quick

// --------------------------------------------------------------


class ZombieClot_GH extends ZombieClot_STANDARD;


// event HitWall(vector HitNormal, actor HitWall)
// {
//   local GlassMoverPlus BreakableWall;

//   BreakableWall = GlassMoverPlus(HitWall);
//   if (BreakableWall != none && BreakableWall.ObjMaterialType == OMT_Glass)
//   {
//     BreakableWall.DoTileDeath();
//   }
// }


function ZombieMoan()
{
  PlaySound(MoanVoice, SLOT_Misc, MoanVolume,, 50); // 250.0
}


function PlayChallengeSound()
{
  PlaySound(ChallengeSound[Rand(4)], SLOT_Talk,,, 50);
}


defaultproperties
{
  MoanVolume=0.250000
}