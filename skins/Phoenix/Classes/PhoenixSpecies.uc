class PhoenixSpecies extends CivilianSpeciesReverend;

static function bool Setup(Pawn P, xUtil.PlayerRecord rec)
{
	P.Skins.Length = 1;
	P.Skins[0] = Texture'Phoenix.Phoe_Tors';
	return Super.Setup(P,rec);
}

defaultproperties
{
     DetachedArmClass=None
     DetachedLegClass=None
     SleeveTexture=Texture'Phoenix.PhoeHanda'
}
