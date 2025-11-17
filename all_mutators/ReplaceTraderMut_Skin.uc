class ReplaceTraderMut extends Mutator;

var SkeletalMesh NewTrader;
var int NewPrePivot;
var bool bAnimated;

simulated function PostBeginPlay()
{
    local WeaponLocker wl;
    //Заменяем модельку. Нет нужды делать это на клиенте
    if(Role<ROLE_AUTHORITY)
        return;
    foreach Level.DynamicActors(class'WeaponLocker', wl)
        wl.LinkMesh(NewTrader, true);
}

simulated function Tick(float delta)
{
    local WeaponLocker wl;
    //Цепляем анимацию shopkeeper_anim. В случае выделенного сервера нет смысла делать это на сервере
    if(Level.NetMode == NM_DedicatedServer)
        return;
    foreach Level.DynamicActors(class'WeaponLocker', wl)
    {
        if(!wl.HasAnim('Idle'))
            wl.LinkSkelAnim(MeshAnimation'KF_Soldier_Trip.shopkeeper_anim');
        //В классе WeaponLocker есть автоматическое продолжение проигрывания анимации Idle
        //В функции отслеживания конца анимации AnimEnd заново запускается анимация Idle
        wl.LoopAnim('Idle');
        //Меш стандартной торговки расположен ниже, чем обычные модельки. Преподнимаем модель над землёй
        wl.PrePivot.Z=NewPrePivot;
        //Отрубаем тик. В принципе не очень красиво, ибо мы несколько раз в цикле вызываем этот Disable. Но в общем то пофик
        Disable('Tick');
    }
}

defaultproperties
{
    NewTrader=SkeletalMesh'KF_Soldier_Trip.Female_Soldier'
    NewPrePivot=12

    GroupName="KF-ReplaceTrader"
    FriendlyName="ReplaceTrader"
    Description="ReplaceTrader"

    bAlwaysRelevant=true
    RemoteRole=ROLE_SimulatedProxy
    bAddToServerPackages=true
}