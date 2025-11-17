//=============================================================================
// KFpubShowDmgPC
//=============================================================================
// Created by r1v3t
// © 2011, KFpub :: www.kfpub.com
//=============================================================================
class KFpubShowDmgPC extends KFPCServ;

replication
{
	reliable if(Role == ROLE_Authority)
		OnPlayerDamaged;
}

simulated function OnPlayerDamaged(int Damage)
{
	KFpubShowDmgHUD(myHUD).ShowDamage(Damage, Level.TimeSeconds);
}