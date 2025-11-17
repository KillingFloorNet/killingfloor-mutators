Class RepWeaponList extends Info;

var KFCustomShopMutB Mut;
var int Index;
var array<string> InvList;

replication
{
    reliable if (Role == ROLE_Authority)
        ReplicateItem,ClientFinishSetup;
}

simulated function ReplicateItem( string S )
{
    InvList[InvList.Length] = S;
}
simulated function ClientFinishSetup()
{
    local KFLevelRules R;
    local int i;

    foreach AllActors(Class'KFLevelRules',R)
        Break;
    if( R==None )
        return;
    for( i=0; i<R.MAX_BUYITEMS; ++i )
        R.ItemForSale[i] = None;
    for( i=0; i<InvList.Length; ++i )
        R.ItemForSale[i] = class<Pickup>(DynamicLoadObject(InvList[i], Class'Class'));
}

Auto State RepList
{
Begin:
    Sleep(1.f);
    if( PlayerController(Owner)==None || PlayerController(Owner).Player==None )
        Destroy();
    Sleep(7.f); // Allow client to connect.
    for( Index=0; Index<Mut.WeaponForSale.Length; ++Index )
    {
        if( PlayerController(Owner)==None )
            Destroy();
        ReplicateItem(Mut.WeaponForSale[Index]);
        Sleep(0.1f);
    }
    ClientFinishSetup();
    Sleep(3.f);
    Destroy();
}

defaultproperties
{
     bOnlyRelevantToOwner=True
     RemoteRole=ROLE_SimulatedProxy
}
