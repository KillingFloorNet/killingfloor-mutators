class AmmoTurretMessage extends LocalMessage;

var localized string Message[3];

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject )
{
	
	return Default.Message[Switch];
}

defaultproperties
{
     Message(0)="No se puede instalar"
     Message(1)="Activado y listo para dar munición"
     Message(2)="Caja de munición destruída"
     bIsUnique=Verdadero
     bFadeMessage=Verdadero
     Lifetime=4
     DrawColor=(B=170,G=170,R=170)
     StackMode=SM_Down
     PosY=0.800000
}
