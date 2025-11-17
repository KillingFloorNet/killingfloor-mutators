//=============================================================================
// IsaacSpecies
//=============================================================================
class IsaacSpecies extends SPECIES_KFMaleHuman;

static function bool Setup(Pawn P, xUtil.PlayerRecord rec)
{
	local XPawn XP;

	// Cast the pawn to an XPawn
	XP = XPawn(P);

	if ( XP == none )
	{
		log("SpeciesType setup error.");
		return false;
	}

	if ( XP.bAlreadySetup )
		return true;

	XP.bAlreadySetup = true;
	XP.LinkMesh(Mesh'Isaac_Clarke');
	XP.SkeletonMesh = Mesh'Isaac_Clarke';
	XP.AssignInitialPose();

	if ( XP.PlayerReplicationInfo != None )
		XP.PlayerReplicationInfo.bIsFemale = false;

	XP.SoundGroupClass = Class'IsaacSoundGroup';

	if ( XP.Level.NetMode != NM_DedicatedServer )
		SetTeamSkin(XP,rec,255);

	if ( XP.PlayerReplicationInfo != None )
		XP.PlayerReplicationInfo.VoiceType = Class'IsaacVoicePack';

	XP.VoiceClass = Class'IsaacVoicePack';
	XP.VoiceType = default.MaleVoice;

	return true;
}

defaultproperties
{
     DetachedArmClass=Class'KFMod.SeveredArmPolice'
     DetachedLegClass=Class'KFMod.SeveredLegPolice'
     SleeveTexture=Texture'KF_Weapons_Trip_T.hands.hands_1stP_riot_D'
     MaleVoice="AdvancedArmorMod.IsaacVoicePack"
     FemaleVoice="AdvancedArmorMod.IsaacVoicePack"
     MaleSoundGroup="AdvancedArmorMod.IsaacSoundGroup"
     FemaleSoundGroup="AdvancedArmorMod.IsaacSoundGroup"
     SpeciesName="Police"
     RaceNum=4
}
