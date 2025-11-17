class DaedricKnight extends PlayerRecordClass;

#exec OBJ LOAD FILE=daedricknight_a.ukx
simulated static function xUtil.PlayerRecord FillPlayerRecord()
{
	local xUtil.PlayerRecord PRE;

	PRE.Species = Class'DaedricKnightSpecies';
	PRE.MeshName = "daedricknight_a.KnightSM";
	PRE.BodySkinName = "daedricknight_a.armor_cmb";
	PRE.FaceSkinName = "daedricknight_a.glow_fb";
	PRE.Portrait = Texture'daedricknight_a.Portrait';
	PRE.TextName = "Daedric Knight";
	PRE.VoiceClassName = "KFMod.KFVoicePackTwo";
	PRE.Sex = "M";
	PRE.Menu = "SP";
	PRE.Skeleton = "KFSoldiers.Soldier";
	PRE.Ragdoll = "British_Soldier1";
	return PRE;
}
