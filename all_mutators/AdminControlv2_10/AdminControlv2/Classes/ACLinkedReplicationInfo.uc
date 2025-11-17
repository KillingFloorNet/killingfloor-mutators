class ACLinkedReplicationInfo extends LinkedReplicationInfo;

var bool bShutUp;

replication
{
	reliable if ( Role == ROLE_Authority )
		bShutUp;
}

defaultproperties
{
}
