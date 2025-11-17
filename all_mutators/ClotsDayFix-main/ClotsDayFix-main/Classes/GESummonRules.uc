class GESummonRules extends GameRules;


var ClotsDayFix clotsDayMutator;


function PostBeginPlay()
{
  if (Level.Game.GameRulesModifiers == none)
    Level.Game.GameRulesModifiers = self;
  else
    Level.Game.GameRulesModifiers.AddGameRules(self);
}


function AddGameRules(GameRules GR)
{
  if (GR != self)
    super.AddGameRules(GR);
}


function scoreKill(Controller killer , Controller killed)
{
  if (killed.pawn.class == class'ZombieClot_STANDARD')
    clotsDayMutator.surround(killed.Pawn, class'SummoneableZombieClot');

  if (nextGameRules != none)
    nextGameRules.scoreKill(killer, killed);
}