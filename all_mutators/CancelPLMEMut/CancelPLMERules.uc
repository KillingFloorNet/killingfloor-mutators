class CancelPLMERules extends GameRules;

function PostBeginPlay()
{
    if(Level.Game.GameRulesModifiers == none)
        Level.Game.GameRulesModifiers = self;
    else
        Level.Game.GameRulesModifiers.AddGameRules(self);
}

function AddGameRules(GameRules GR)
{
    if(GR != self)
        super.AddGameRules(GR);
}

function bool CheckEndGame(PlayerReplicationInfo Winner, string Reason)
{
    if(Level.Game.IsInState('PendingMatch'))
        return false;
    if ( NextGameRules != None )
        return NextGameRules.CheckEndGame(Winner,Reason);
    return true;
}