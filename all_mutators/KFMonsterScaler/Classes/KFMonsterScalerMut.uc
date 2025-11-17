///////////////////////////////////////////////////
//                                               //
//  KFMonsterScaler v.1.0 Mutator (c) by Mutant  //
//                                               //
///////////////////////////////////////////////////
class KFMonsterScalerMut extends Mutator;

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
     local float factor;
     local KFMonster zed;
     local float z1, z2, height;

     zed = KFMonster(Other);

     if ( zed != None && ZombieBoss(zed) == None )
     {
          height = zed.OnlineHeadshotOffset.Z;
          factor = 0.95; //Start with 95% as base

          /*
          * Make the saling factor more dynamic, depending on how large the monster already is.
          * Each monster has 26 different scalings (0-25).
          */
          if ( height < 55 )
               factor += (Rand(26)/166.0); //Min: 0.95, Max: ~1.1
          else if ( height < 65 )
               factor += (Rand(26)/178.0); //Min: 0.95, Max: ~1.09
          else
               factor += (Rand(26)/208.0); //Min:0.95, Max: ~1.07

          z1 = zed.CollisionHeight; //Save original height

          //Scale all the stuff related
          zed.SetDrawScale(zed.DrawScale*factor);
          zed.ColOffset.Z *= factor;
          zed.ColRadius *= factor;
          zed.ColHeight *= factor;
          zed.SeveredArmAttachScale *= factor;
          zed.SeveredLegAttachScale *= factor;
          zed.SeveredHeadAttachScale *= factor;
          zed.OnlineHeadshotOffset.Z *= factor;
          zed.OnlineHeadshotScale *= factor;
          zed.SetCollisionSize(zed.CollisionRadius*factor, zed.CollisionHeight*factor);

          z2 = zed.CollisionHeight; //Save new height

          zed.PrePivot.Z += (z2-z1)*1.22; //Adjust the pivot so the monsters don't extend into the floor, 1.22 is a correction factor
          zed.NetUpdateTime = Level.TimeSeconds - 1;
     }

     return true;
}

defaultproperties
{
     GroupName="KF-MonsterScaler"
     FriendlyName="Monster Scaler"
     Description="This gives each specimen a slight random size, excluding Patriarch."
}
