// Ported and improved for KF by Marco
class mutDamagePopup extends Mutator
	transient;

var() bool bMsgPlayersDamage,bMsgZedsDamage;

function PostBeginPlay()
{
	local GameRules G;

	Super.PostBeginPlay();
	G = spawn(class'DamagePopupGameRules');
	if ( Level.Game.GameRulesModifiers == None )
		Level.Game.GameRulesModifiers = G;
	else Level.Game.GameRulesModifiers.AddGameRules(G);
}

defaultproperties
{
     bMsgPlayersDamage=True
     bMsgZedsDamage=True
     bAddToServerPackages=True
     GroupName="KFDamagePopup"
     FriendlyName="Damagepopup"
     Description="Show Damage value."
     LifeSpan=0.100000
}
