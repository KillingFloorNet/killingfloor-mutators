class Kayako extends PlayerRecordClass;

#exec obj load file="Kayako_A.ukx" PACKAGE=Kayako

simulated static function xUtil.PlayerRecord FillPlayerRecord()
{
	local xUtil.PlayerRecord PRE;

	PRE.Species = Class'KayakoSpecies'; // Species (can be used to replace sounds or misc stuff)
	PRE.MeshName = string(Mesh'KayakoMesh'); // Name of the mesh.
	PRE.BodySkinName = string(Texture'kyk_b'); // Body skin name (Material #0)
	PRE.FaceSkinName = string(Texture'eyeshadow'); // Face skin name (Material #1)
	PRE.Portrait = Texture'kayako_portrait'; // Portrait texture
	PRE.TextName = "Kayako Saeki is the main antagonist appearing in the Ju-On franchise. Although her background is significantly different between them, in all versions Kayako is an onryo - the furious, spiteful spirit of a Japanese housewife who was brutally murdered by her husband. His insane act gathered a grudge curse at the murder setting, their house, that condemns anyone who steps inside to succumb under Kayako's spreading anger."; // Description text.
	PRE.VoiceClassName = string(Class'KFVoicePackFemale'); // Voice pack
	PRE.Sex = "F"; // M = Male, F = Female
	PRE.Menu = "SP"; // Not needed to modify.
	PRE.Skeleton = string(Mesh'Soldier'); // Unused in KF
	PRE.Ragdoll = "British_Soldier1"; // Should be this only.
	return PRE;
}

defaultproperties
{
}
