class JavikSpecies extends CivilianSpeciesThree;

#exec OBJ LOAD FILE=Javik_H.ukx

static function bool Setup(Pawn P, xUtil.PlayerRecord rec)
{
	P.Skins.Length = 3;
	P.Skins[0] = Texture'Javik_H.J_Head';
	P.Skins[1] = Texture'Javik_H.J_Body';
	P.Skins[2] = Texture'Javik_H.J_Eye_L';
	P.Skins[3] = Texture'Javik_H.J_Eye_R';

	return Super.Setup(P,rec);
}

defaultproperties
{
	DetachedArmClass=None
	DetachedLegClass=None
	SleeveTexture=Texture'Javik_H.J_Hands'
}