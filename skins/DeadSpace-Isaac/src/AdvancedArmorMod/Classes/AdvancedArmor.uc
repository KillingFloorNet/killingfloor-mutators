class AdvancedArmor extends PlayerRecordClass;

#exec obj load file="DSAdvArmor.ukx"

simulated static function xUtil.PlayerRecord FillPlayerRecord()
{
	local xUtil.PlayerRecord PRE;

	PRE.Species = Class'IsaacSpecies';
	PRE.MeshName = string(Mesh'Isaac_Clarke');
	PRE.BodySkinName = string(Shader'RigShader');
	PRE.FaceSkinName = string(Material'GlowShader');
	PRE.Portrait = Texture'IsaacPortrait';
	PRE.TextName = "Isaac Clarke";
	PRE.VoiceClassName = string(Class'IsaacVoicePack');
	PRE.Sex = "Male";
	PRE.Menu = "SP";
	PRE.Skeleton = string(Mesh'Isaac_Clarke');
	PRE.Ragdoll = "British_Soldier1";
	return PRE;
}

defaultproperties
{
}
