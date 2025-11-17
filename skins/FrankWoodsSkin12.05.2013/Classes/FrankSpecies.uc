class FrankSpecies extends CivilianSpeciesThree;

static function bool Setup(Pawn P, xUtil.PlayerRecord rec)
{
	P.Skins.Length = 10;
	P.Skins[0] = Texture'FrankWoodsDT_A.c_gen_eye_blue_c';
	P.Skins[1] = Texture'FrankWoodsDT_A.c_gen_insidemouth_c';
	P.Skins[2] = Texture'FrankWoodsDT_A.c_usa_marine_barnes_head_c';
	P.Skins[3] = Texture'FrankWoodsDT_A.c_usa_specops_barnes_body_c';
	P.Skins[4] = Texture'FrankWoodsDT_A.c_usa_specops_barnes_gear_c';
	P.Skins[5] = Shader'FrankWoodsDT_A.gc_usa_marine_barnes_head_hair__sh';
	P.Skins[6] = Texture'FrankWoodsDT_A.c_usa_jungmar_barnes_pris_nb_body_c';
	P.Skins[7] = Texture'FrankWoodsDT_A.c_usa_jungle_marine_gear4_c';
	P.Skins[8] = Texture'FrankWoodsDT_A.c_gen_arm_clean_c';
	P.Skins[9] = Texture'FrankWoodsDT_A.c_usa_jungmar_barnes_arms_left_c';
	return Super.Setup(P,rec); // Base function sets Skins[0] and [1]
}

defaultproperties
{
     DetachedArmClass=None
     DetachedLegClass=None
     SleeveTexture=Texture'FrankWoodsDT_A.Frank_Hands'
}
