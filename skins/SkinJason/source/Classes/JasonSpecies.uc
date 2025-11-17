class SkinJasonSpecies extends CivilianSpeciesThree;

static function bool Setup(Pawn P, xUtil.PlayerRecord rec)
{
	P.Skins.Length = 1;
	P.Skins[0] = Combiner'SkinJason.SkinJason_cmb';
	return Super.Setup(P,rec);
}

defaultproperties
{
     DetachedArmClass=None
     DetachedLegClass=None
     SleeveTexture=Texture'SkinJason.SkinJason'
}
