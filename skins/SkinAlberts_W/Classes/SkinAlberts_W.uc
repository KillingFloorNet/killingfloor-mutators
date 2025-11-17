class SkinAlberts_W extends PlayerRecordClass;

#exec obj load file="Alberts_W_T.utx" PACKAGE=SkinAlberts_W
#exec obj load file="KF_Soldier_Trip.ukx"

simulated static function xUtil.PlayerRecord FillPlayerRecord()
{
	local xUtil.PlayerRecord PRE;

	PRE.Species = Class'SkinAlberts_W.SkinAlberts_WSpecies';
	PRE.MeshName = string(Mesh'KF_Soldier_Trip.Priest');
	PRE.BodySkinName = string(Combiner'SkinAlberts_W.Alberts_W_cmb');
	PRE.FaceSkinName = string(Combiner'SkinAlberts_W.Alberts_W_cmb');
	PRE.Portrait = Texture'SkinAlberts_W.portret';
	PRE.TextName = "Alberts White skin";
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
