class HitmanSpecies extends CivilianSpeciesReverend;

static function bool Setup(Pawn P, xUtil.PlayerRecord rec)
{
	P.Skins.Length = 1;
	P.Skins[0] = Texture'Hitman.shirt';
	return Super.Setup(P,rec);
}

defaultproperties
{
     DetachedArmClass=None
     DetachedLegClass=None
     SleeveTexture=Texture'Hitman.Hero_Hands'
}
