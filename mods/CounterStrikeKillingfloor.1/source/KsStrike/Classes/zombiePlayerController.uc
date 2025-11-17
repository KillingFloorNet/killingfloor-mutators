class zombiePlayerController extends KFplayercontroller;

var class<weapon> boughtweapon1,boughtweapon2;
var int zshieldstrength;

var bool bbuy2,bistrader;

replication
{
	// Things the server should send to the client.
	reliable if ( bNetDirty && (Role == Role_Authority) )
            bistrader;
}

exec function use()
{

if(pawn.physics==phys_projectile)
showbuymenu("Weaponlocker", 15);
else super.use();


}

defaultproperties
{
     SelectedVeterancy=Class'KFMod.KFVetBerserker'
     bBehindView=False
     PawnClass=None
}
