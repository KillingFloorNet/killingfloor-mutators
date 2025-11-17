class KatanaMedicMut extends Mutator;

function ModifyPlayer(Pawn Player)
{
     Super.ModifyPlayer(Player);
     Player.GiveWeapon("KatanaMedic.KatanaM");	 
}

defaultproperties
{
     GroupName="KF-KatanaMedic"
     FriendlyName="Add KatanaMedic"
     Description="Add KatanaMedic."
}
