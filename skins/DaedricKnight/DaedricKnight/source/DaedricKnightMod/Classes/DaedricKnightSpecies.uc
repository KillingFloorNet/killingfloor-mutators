class DaedricKnightSpecies extends CivilianSpeciesThree;

#exec OBJ LOAD FILE=daedricknight_a.ukx
static function bool Setup(Pawn P, xUtil.PlayerRecord rec)
{
	P.Skins.Length = 5;
	P.Skins[2] = Combiner'daedricknight_a.gloves_cmb';
	P.Skins[3] = Combiner'daedricknight_a.boots_cmb';
	P.Skins[4] = Combiner'daedricknight_a.helmet_cmb';
	return Super.Setup(P,rec); // Base function sets Skins[0] and [1]
}

defaultproperties
{
	DetachedArmClass=None
	DetachedLegClass=None
	SleeveTexture=Combiner'daedricknight_a.sleeve_cmb'
}