class MHPlayerReplicationInfo extends KFPlayerReplicationInfo;

var int fragCount;

replication
{
	// Things the server should send to the client.
	reliable if ( bNetDirty && ( Role == Role_Authority ) ) fragCount;
}

defaultproperties
{
}
