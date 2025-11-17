Class DoomSPMapSetup extends KFSPLevelInfo;

var(KFSPLevelInfo) bool bCarryUnlimited;

function ModifyPlayer( Pawn Other )
{
	Super.ModifyPlayer(Other);
	if( bCarryUnlimited && KFHumanPawn(Other)!=None )
		KFHumanPawn(Other).MaxCarryWeight = 60;
}

defaultproperties
{
     bCarryUnlimited=True
     RequiredPlayerEquipment(0)=Class'DoomPawnsKF.DoomFist'
     RequiredPlayerEquipment(1)=Class'DoomPawnsKF.DoomPistol'
     MissionObjectives(0)="Find 'Exit'"
}
