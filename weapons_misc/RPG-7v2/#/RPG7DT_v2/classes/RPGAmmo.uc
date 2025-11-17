class RPGAmmo extends KFAmmunition;

//Flame. При покупке в магазине ракет. Отображаем изменения в сумке
/* function bool AddAmmo(int AmmoToAdd)
{
	local Inventory Inv;
	local RPG W;
	if(Instigator.Inventory==none) return Super.AddAmmo(AmmoToAdd);
	for(inv=Instigator.Inventory; inv!=None; inv=inv.Inventory )
		if(RPG(inv)!=none) W=RPG(inv);
	if(W==none) return Super.AddAmmo(AmmoToAdd);
	W.UpdateBackpack();
	return Super.AddAmmo(AmmoToAdd);
} */

defaultproperties
{
	AmmoPickupAmount=1
	MaxAmmo=4
	InitialAmount=4
	IconMaterial=Texture'KillingFloorHUD.Generic.HUD'
	IconCoords=(X1=458,Y1=34,X2=511,Y2=78)
	ItemName="ПГ-7"
}