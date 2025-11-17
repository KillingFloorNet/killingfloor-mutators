class GESummonRules extends GameRules;

var ClotsDay clotsDayMutator;

function scoreKill (Controller killer , Controller killed)
{
	if (killed.pawn.Class == class'KFChar.ZombieClot')
		clotsDayMutator.surround (killed.Pawn , Class'ClotsDay.SummoneableZombieClot');

	if (nextGameRules != none)
		nextGameRules.scoreKill (killer , killed);
}

defaultproperties
{
}
