class Hitman extends PlayerRecordClass;

#exec OBJ LOAD FILE="Hitman.ukx" PACKAGE=Hitman

simulated static function xUtil.PlayerRecord FillPlayerRecord()
{
     local xUtil.PlayerRecord PRE;
     
     PRE.Species = Class'Hitman.HitmanSpecies'; 
     PRE.MeshName = string(Mesh'Hitman.sawHitmanMesh');  
     PRE.BodySkinName = string(Texture'Hitman.shirt');
     PRE.FaceSkinName = string(Texture'Hitman.head');
     PRE.Portrait = Texture'Hitman.portHitman';
     PRE.TextName = "Hitman";
     PRE.VoiceClassName = string(class'KFVoicePack');
     PRE.Sex = "Male"; 
     PRE.Menu = "SP";
     PRE.Skeleton = string(Mesh'KFSoldiers.Soldier');
     PRE.Ragdoll = "British_Soldier1";
     return PRE;

}

defaultproperties
{
}
