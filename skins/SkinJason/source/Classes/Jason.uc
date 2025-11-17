class SkinJason extends PlayerRecordClass;

#exec obj load file="SkinJason_T.utx" PACKAGE=SkinJason
#exec obj load file="KF_Soldier_Trip.ukx"

simulated static function xUtil.PlayerRecord FillPlayerRecord()
{
	local xUtil.PlayerRecord PRE;

	PRE.Species = Class'SkinJason.SkinJasonSpecies';
	PRE.MeshName = string(Mesh'KF_Soldier_Trip.Priest');
	PRE.BodySkinName = string(Combiner'SkinJason.SkinJason_cmb');
	PRE.FaceSkinName = string(Combiner'SkinJason.SkinJason_cmb');
	PRE.Portrait = Texture'SkinJason.portrait';
	PRE.TextName = "Skin Jason";
	PRE.VoiceClassName = string(Class'KFVoicePack');
	PRE.Sex = "M";
	PRE.Menu = "SP";
	PRE.Skeleton = string(Mesh'KFSoldiers.Soldier');
	PRE.Ragdoll = "British_Soldier1";
	return PRE;
}

defaultproperties
{
}
