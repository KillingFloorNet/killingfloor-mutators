class CommFixRules extends GameRules;

function PostBeginPlay()
{
    if(Level.Game.GameRulesModifiers==None)
        Level.Game.GameRulesModifiers=Self;
    else
        Level.Game.GameRulesModifiers.AddGameRules(Self);
}

function AddGameRules(GameRules GR)
{
    if(GR!=Self)
        Super.AddGameRules(GR);
}

function int NetDamage(int OriginalDamage, int Damage, Pawn Injured, Pawn InstigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType)
{
    local KFPlayerReplicationInfo KFPRI;
    if(Injured==None || InstigatedBy==None)
    {
        if(NextGameRules!=None)
            return NextGameRules.NetDamage(OriginalDamage, Damage, Injured, InstigatedBy, HitLocation, Momentum, DamageType);
        return Damage;
    }
    if    (
            Injured.IsA('KFMonster')                        &&
            InstigatedBy.IsA('KFHumanPawn')                    &&
            InstigatedBy.Controller.IsA('PlayerController')    &&
            Damage>0
        )
    {
        KFPRI=KFPlayerReplicationInfo(InstigatedBy.PlayerReplicationInfo);
        if(KFPRI==None)
        {
            if(NextGameRules!=None)
                return NextGameRules.NetDamage(OriginalDamage, Damage, Injured, InstigatedBy, HitLocation, Momentum, DamageType);
            return Damage;
        }
        if
            (
                KFPRI.ClientVeteranSkill==Class'KFVetCommando'            &&
                KFPRI.ClientVeteranSkillLevel==6                        &&
                (
                    DamageType.Name=='DamTypeBullpup'                    ||
                    DamageType.Name=='DamTypeAK47AssaultRifle'            ||
                    DamageType.Name=='DamTypeFNFALAssaultRifle'            ||
                    DamageType.Name=='DamTypeSCARMK17AssaultRifle'        ||
                    DamageType.Name=='DamTypeM4AssaultRifle'            ||
                    DamageType.Name=='DamTypeThompson'                    ||
                    DamageType.Name=='DamTypeMKb42AssaultRifle'            ||
                    DamageType.Name=='DamTypeThompsonDrum'                ||
                    DamageType.Name=='DamTypeSPThompson'
                )
            )
        {
            Damage*=1.067;
        }
    }
    if(NextGameRules!=None)
        return NextGameRules.NetDamage(OriginalDamage, Damage, Injured, InstigatedBy, HitLocation, Momentum, DamageType );
    return Damage;
}    