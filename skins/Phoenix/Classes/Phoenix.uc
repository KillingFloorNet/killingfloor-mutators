class Phoenix extends PlayerRecordClass;

#exec OBJ LOAD FILE="Phoenix.ukx" PACKAGE=Phoenix

simulated static function xUtil.PlayerRecord FillPlayerRecord()
{
     local xUtil.PlayerRecord PRE;
     
     PRE.Species = Class'Phoenix.PhoenixSpecies'; 
     PRE.MeshName = string(Mesh'Phoenix.sawPhoenixMesh');  
     PRE.BodySkinName = string(Texture'Phoenix.Phoe_Tors');
     PRE.FaceSkinName = string(Texture'KF_Soldier2_Trip_T.Uniforms.Civi_I_diff');
     PRE.Portrait = Texture'Phoenix.PhoePort';
     PRE.TextName = "Phoenix";
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
