Class DoomTriggerTeleport extends KeyPoint;

var() bool bTriggerOnceOnly;
var bool bDisabled;

event Trigger( Actor Other, Pawn EventInstigator )
{
	if( !bDisabled && EventInstigator!=None && EventInstigator.Health>0 && EventInstigator.SetLocation(Location) )
	{
		Spawn(class'TeleportEffects');
		EventInstigator.SetRotation(Rotation);
		EventInstigator.ClientSetRotation(Rotation);
		bDisabled = bTriggerOnceOnly;
	}
}

defaultproperties
{
     bStatic=False
     bNoDelete=True
     Style=STY_Modulated
     bDirectional=True
}
