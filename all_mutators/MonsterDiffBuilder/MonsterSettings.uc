class MonsterSettings extends Object
    config(MonsterDiffBuilder)
    PerObjectConfig;
    
struct FloatRangeRecord
{
    var    float Min,Max;
};
    
struct PerPlayerHealthRecord
{
    var int    Health,MinPlayers,MaxPlayers;
};
/*
struct ResistRecord
{
    var    string    DamageType;
    var    bool        bIsChild;
    var    float        Modifer;
    var    FloatRangeRecord    DifficultyUsed;
};*/
    
var    config    string    MonsterClass;
var    config    bool        bMonsterClassIsChild;
var    config    int        Health,HeadHealth,StunDamage,Damage,ScreamDamage,ScoringValue;
var    config    float        Speed,Mass,BombDanger,ZapThreshold,ZappedDamageMod;
var    config    float        HealthMod,HeadHealthMod,SpeedMod,DamageMod,ScreamDamageMod;

var    config    array<PerPlayerHealthRecord>    PerPlayerHealth,PerPlayerHeadHealth;
//var    config    array<ResistRecord>            DamageModifer;
var    config    FloatRangeRecord            DifficultyUsed;

var class<KFMonster>    LoadedMonsterClass;
    
defaultproperties
{
}