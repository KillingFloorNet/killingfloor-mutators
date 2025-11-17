class MinimumLevelGameRules extends GameRules;

var MinimumLevel ParentMutator;

function bool CheckEndGame(PlayerReplicationInfo Winner, string Reason) {
	ParentMutator.SetTimer(0, False);
	if (NextGameRules != None)
		return NextGameRules.CheckEndGame(Winner, Reason);
	return True;
}