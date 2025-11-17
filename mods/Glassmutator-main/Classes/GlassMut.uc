// --------------------------------------------------------------
// Glass Mutator
// --------------------------------------------------------------

// Simple mutator that replaces 'KFGlassMovers' with 'GlassMoverPlus'
// actors. These actors have additional functionality like the ability to
// respawn.

// Author :  Alex Quick

// --------------------------------------------------------------


class GlassMut extends Mutator;


// function PostBeginPlay()
// {
// 	local KFGameType KFGI;

//   KFGI = KFGameType(Level.Game);
//   if (KFGI != none)
//   {
//     KFGI.StandardMonsterClasses[0].MClassName = "GlassMutator.ZombieClot_GH";
//     KFGI.StandardMonsterClasses[1].MClassName = "GlassMutator.ZombieCrawler_GH";
//     KFGI.StandardMonsterClasses[2].MClassName = "GlassMutator.ZombieGorefast_GH";
//     KFGI.StandardMonsterClasses[3].MClassName = "GlassMutator.ZombieStalker_GH";
//     KFGI.StandardMonsterClasses[4].MClassName = "GlassMutator.ZombieScrake_GH";
//     KFGI.StandardMonsterClasses[5].MClassName = "GlassMutator.ZombieFleshPound_GH";
//     KFGI.StandardMonsterClasses[6].MClassName = "GlassMutator.ZombieBloat_GH";
//     KFGI.StandardMonsterClasses[7].MClassName = "GlassMutator.ZombieSiren_GH";
//     KFGI.StandardMonsterClasses[8].MClassName = "GlassMutator.ZombieHusk_GH";
//     KFGI.EndGameBossClass = "GlassMutator.ZombieBoss_GH";
//   }

//   // Copied from the KF Vehicle mutator code (SPGameMut.uc)
//   // Appears to be a hack that forces KF maps to re-load with a specified gametype.
//   // (changing the gametype in the map's levelinfo doesn't seem to work, so let's just
//   // go with this ...

//   if (GlasshouseGameInfo(level.game) == none)
//   {
//     level.servertravel("?game=GlassMutator.GlasshouseGameInfo", true);
//   }
// }


// function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
// {
//   local string ReplacementClass;

//   switch (Other.class.name)
//   {
//     case 'ZombieBoss'       : ReplacementClass = "GlassMutator.ZombieBoss_GH";        break;
//     case 'ZombieFleshPound' : ReplacementClass = "GlassMutator.ZombieFleshPound_GH";  break;
//     case 'ZombieScrake'     : ReplacementClass = "GlassMutator.ZombieScrake_GH";      break;
//     case 'ZombieClot'       : ReplacementClass = "GlassMutator.ZombieClot_GH";        break;
//   }

//   if (ReplacementClass != "")
//   {
//     log("~~~~~~~~~~ GlassMutator - replacing :" @ Other @ "with" @ ReplacementClass);
//     ReplaceWith(Other, ReplacementClass);

//     return true;
//   }

//   return super.CheckReplacement(Other,bSuperRelevant);
// }


// // Call this function to replace an actor Other with an actor of aClass.
// function bool ReplaceWith(actor Other, string aClassName)
// {
//   local bool Result;

//   Result = super.ReplaceWith(other, aClassName);
//   if (!Result)
//   {
//     log(" WARNING -  ATTEMPT TO SPAWN CLASS " @ aClassName @ "failed.");
//   }

//   return Result;
// }


// function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
// {
//   return true;
// }


defaultproperties
{
  GroupName="KFGlassMutator"
  FriendlyName="Glass Mutator"
  Description="smashy smashy!"
}