class SkinAlberts_WSpecies extends CivilianSpeciesThree;

static function bool Setup(Pawn P, xUtil.PlayerRecord rec)
{
	P.Skins.Length = 1;
	P.Skins[0] = Combiner'SkinAlberts_W.Alberts_W_cmb';
	return Super.Setup(P,rec);
}

defaultproperties
{
     DetachedArmClass=None
     DetachedLegClass=None
     SleeveTexture=Texture'SkinAlberts_W.Albert_W_Hands'
}
