class DoomSecretMessage extends LocalMessage;

#exec AUDIO IMPORT FILE="Sounds\DSGETPOW.wav" NAME="DSGETPOW" GROUP="DoomGen"

static function string GetString(
    optional int Switch,
    optional PlayerReplicationInfo RelatedPRI_1,
    optional PlayerReplicationInfo RelatedPRI_2,
    optional Object OptionalObject
    )
{
	if( RelatedPRI_1!=None )
	{
		if( Switch>=100 )
			return RelatedPRI_1.PlayerName@"found a secret! (All secrets found)";
		return RelatedPRI_1.PlayerName@"found a secret! ("$Switch@"prc of secrets found)";
	}
	if( Switch>=100 )
		return "Secret found! (All secrets found)";
	return "Secret found! ("$Switch@"prc of secrets found)";
}
static function ClientReceive(
	PlayerController P,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	P.ClientPlaySound(Sound'DSGETPOW');
	Super.ClientReceive(P,Switch,RelatedPRI_1,RelatedPRI_2,OptionalObject);
}

defaultproperties
{
     bIsUnique=True
     bFadeMessage=True
     Lifetime=5
     DrawColor=(B=50,G=230,R=230)
     PosY=0.150000
     FontSize=3
}
