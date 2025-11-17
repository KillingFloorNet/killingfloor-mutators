class DJSYSpecies extends CivilianSpeciesThree;

#exec OBJ LOAD FILE=DJSY_H.ukx

static function bool Setup(Pawn P, xUtil.PlayerRecord rec)
{
	P.Skins.Length = 3;
	P.Skins[0] = Texture'DJSY_H.DJSY_Body';
	P.Skins[1] = Texture'DJSY_H.DJSY_Kapushon';
	P.Skins[1] = Shader'DJSY_H.DJSY_Head_Shdr';

	return Super.Setup(P,rec);
}

defaultproperties
{
	DetachedArmClass=None
	DetachedLegClass=None
	SleeveTexture=Texture'DJSY_H.DJSY_Hands'
}