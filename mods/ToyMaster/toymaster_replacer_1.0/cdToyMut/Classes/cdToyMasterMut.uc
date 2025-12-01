/* I SHOULD COMMENT THIS BUT IM LAZY - CAKEDOG */
/* Killing Floor Toy Replacement Mutator - Created by Cakedog */
/* "Good if you like spooky toys trying to shank you, otherwise I wouldn't recommend it" - Mel Gibson, 2014 */


class cdToyMasterMut extends Mutator;

#exec load obj file=KFCharPuppets.u
var globalconfig bool bNoBigToys;

static function FillPlayInfo(PlayInfo PlayInfo)
{
	Super.FillPlayInfo(PlayInfo);
	PlayInfo.AddSetting(default.RulesGroup,"bNoBigToys","No Large Toys",1,0, "Check");
}
static event string GetDescriptionText(string PropName)
{
	switch (PropName)
	{
		case "bNoBigToys":		return "Removes big toys, allows normal big zeds to spawn. Useful for small maps.";
	}
	return Super.GetDescriptionText(PropName);
}

function PostBeginPlay() 
{
	if (Level.NetMode != NM_Standalone)
	{
		AddToPackageMap("KFCharPuppets");
		AddToPackageMap("cdToyMasterMut");
	}
    SetTimer(0.1, false);

} 
      
    function Timer()
    {
        InitMut();
        Destroy();
    }
     
    final function InitMut()
    {
            local KFGameType KF;
            local int i,j;
     
            KF = KFGameType(Level.Game);
            if ( KF!=None && bNoBigToys != True)
            {
            	    for( i=0; i<KF.MonsterCollection.default.SpecialSquads.Length; i++ )
		{
			for( j=0; j<KF.MonsterCollection.default.SpecialSquads[i].ZedClass.Length; j++ )
				ReplaceMonsterStr(KF.MonsterCollection.default.SpecialSquads[i].ZedClass[j]);
		}
                    for( i=0; i<KF.InitSquads.Length; i++ )
                    {
                            for( j=0; j<KF.InitSquads[i].MSquad.Length; j++ )
                                    KF.InitSquads[i].MSquad[j] = GetReplaceClass(KF.InitSquads[i].MSquad[j]);
                    }
                    
                    for( i=0; i<KF.ShortSpecialSquads.Length; i++ )
                    {
                            for( j=0; j<KF.ShortSpecialSquads[i].ZedClass.Length; j++ )
                                    ReplaceMonsterStr(KF.ShortSpecialSquads[i].ZedClass[j]);
                    }
                    
                    for( i=0; i<KF.NormalSpecialSquads.Length; i++ )
                    {
                            for( j=0; j<KF.NormalSpecialSquads[i].ZedClass.Length; j++ )
                                    ReplaceMonsterStr(KF.NormalSpecialSquads[i].ZedClass[j]);
                    }
                    
                    for( i=0; i<KF.LongSpecialSquads.Length; i++ )
                    {
                            for( j=0; j<KF.LongSpecialSquads[i].ZedClass.Length; j++ )
                                    ReplaceMonsterStr(KF.LongSpecialSquads[i].ZedClass[j]);
                    }
                    for( i=0; i<KF.FinalSquads.Length; i++ )
                    {
                            for( j=0; j<KF.FinalSquads[i].ZedClass.Length; j++ )
                                    ReplaceMonsterStr(KF.FinalSquads[i].ZedClass[j]);
                    }
                    
                    KF.FallbackMonster = GetReplaceClass( Class<KFMonster>(KF.FallbackMonster) );
            }
            else if ( KF!=None && bNoBigToys != False)
            {
            	    for( i=0; i<KF.MonsterCollection.default.SpecialSquads.Length; i++ )
		{
			for( j=0; j<KF.MonsterCollection.default.SpecialSquads[i].ZedClass.Length; j++ )
				ReplaceMonsterStrNBT(KF.MonsterCollection.default.SpecialSquads[i].ZedClass[j]);
		}
                    for( i=0; i<KF.InitSquads.Length; i++ )
                    {
                            for( j=0; j<KF.InitSquads[i].MSquad.Length; j++ )
                                    KF.InitSquads[i].MSquad[j] = GetReplaceClassNBT(KF.InitSquads[i].MSquad[j]);
                    }
                    
                    for( i=0; i<KF.ShortSpecialSquads.Length; i++ )
                    {
                            for( j=0; j<KF.ShortSpecialSquads[i].ZedClass.Length; j++ )
                                    ReplaceMonsterStrNBT(KF.ShortSpecialSquads[i].ZedClass[j]);
                    }
                    
                    for( i=0; i<KF.NormalSpecialSquads.Length; i++ )
                    {
                            for( j=0; j<KF.NormalSpecialSquads[i].ZedClass.Length; j++ )
                                    ReplaceMonsterStrNBT(KF.NormalSpecialSquads[i].ZedClass[j]);
                    }
                    
                    for( i=0; i<KF.LongSpecialSquads.Length; i++ )
                    {
                            for( j=0; j<KF.LongSpecialSquads[i].ZedClass.Length; j++ )
                                    ReplaceMonsterStrNBT(KF.LongSpecialSquads[i].ZedClass[j]);
                    }
                    for( i=0; i<KF.FinalSquads.Length; i++ )
                    {
                            for( j=0; j<KF.FinalSquads[i].ZedClass.Length; j++ )
                                    ReplaceMonsterStrNBT(KF.FinalSquads[i].ZedClass[j]);
                    }
                    
                    KF.FallbackMonster = GetReplaceClassNBT( Class<KFMonster>(KF.FallbackMonster) );
            }
    }
    final function Class<KFMonster> GetReplaceClass( Class<KFMonster> MC )
    {
            switch( MC )
            {
            // Begin HALLOWEEN Zeds	    
            case class'KFChar.ZombieClot_HALLOWEEN':
                    return class'KFCharPuppets.PuppetDummy_Runner';
            case class'KFChar.ZombieBloat_HALLOWEEN':
            	    return class'KFCharPuppets.PuppetPinwheel';
            case class'KFChar.ZombieGorefast_HALLOWEEN':
            	    return class'KFCharPuppets.PuppetPinwheel_Runner';
            case class'KFChar.ZombieCrawler_HALLOWEEN':
                    return class'KFCharPuppets.PuppetBabydoll_Runner';
            case class'KFChar.ZombieStalker_HALLOWEEN':
            	    return class'KFCharPuppets.PuppetDummyLongRange';
            case class'KFChar.ZombieHusk_HALLOWEEN':
            	    return class'KFCharPuppets.PuppetBabydollLongRange';
             case class'KFChar.ZombieSiren_HALLOWEEN':
                    return class'cdToyMut.cdPuppetSuperBabydoll';
            case class'KFChar.ZombieScrake_HALLOWEEN':
            	    return class'KFCharPuppets.PuppetDummyUber';
            case class'KFChar.ZombieFleshpound_HALLOWEEN':
            	    return class'cdToyMut.cdPuppetSuperPinwheel';
            // Begin STANDARD Zeds	    
            case class'KFChar.ZombieClot_STANDARD':
                    return class'KFCharPuppets.PuppetDummy_Runner';
            case class'KFChar.ZombieBloat_STANDARD':
            	    return class'KFCharPuppets.PuppetPinwheel';
            case class'KFChar.ZombieGorefast_STANDARD':
            	    return class'KFCharPuppets.PuppetPinwheel_Runner';
            case class'KFChar.ZombieCrawler_STANDARD':
                    return class'KFCharPuppets.PuppetBabydoll_Runner';
            case class'KFChar.ZombieStalker_STANDARD':
            	    return class'KFCharPuppets.PuppetDummyLongRange';
            case class'KFChar.ZombieHusk_STANDARD':
            	    return class'KFCharPuppets.PuppetBabydollLongRange';
             case class'KFChar.ZombieSiren_STANDARD':
                    return class'cdToyMut.cdPuppetSuperBabydoll';
            case class'KFChar.ZombieScrake_STANDARD':
            	    return class'KFCharPuppets.PuppetDummyUber';
            case class'KFChar.ZombieFleshpound_STANDARD':
            	    return class'cdToyMut.cdPuppetSuperPinwheel';  
            // Begin XMAS Zeds
            case class'KFChar.ZombieCLot_XMas':
                    return class'KFCharPuppets.PuppetDummy_Runner';
            case class'KFChar.ZombieBloat_XMas':
            	    return class'KFCharPuppets.PuppetPinwheel';
            case class'KFChar.ZombieGorefast_XMas':
            	    return class'KFCharPuppets.PuppetPinwheel_Runner';
            case class'KFChar.ZombieCrawler_XMas':
                    return class'KFCharPuppets.PuppetBabydoll_Runner';
            case class'KFChar.ZombieStalker_XMas':
            	    return class'KFCharPuppets.PuppetDummyLongRange';
            case class'KFChar.ZombieHusk_XMas':
            	    return class'KFCharPuppets.PuppetBabydollLongRange';
             case class'KFChar.ZombieSiren_XMas':
                    return class'cdToyMut.cdPuppetSuperBabydoll';
            case class'KFChar.ZombieScrake_XMas':
            	    return class'KFCharPuppets.PuppetDummyUber';
            case class'KFChar.ZombieFleshpound_XMas':
            	    return class'cdToyMut.cdPuppetSuperPinwheel';
            default:
                    return class'KFCharPuppets.PuppetDummyUber';
            }
    }
     
     final function Class<KFMonster> GetReplaceClassNBT( Class<KFMonster> MC )
    {
            switch( MC )
            {
            //Begin HALLOWEEN Zeds	    
            case class'KFChar.ZombieClot_HALLOWEEN':
                    return class'KFCharPuppets.PuppetDummy_Runner';
            case class'KFChar.ZombieBloat_HALLOWEEN':
            	    return class'KFCharPuppets.PuppetPinwheel';
            case class'KFChar.ZombieGorefast_HALLOWEEN':
            	    return class'KFCharPuppets.PuppetPinwheel_Runner';
            case class'KFChar.ZombieCrawler_HALLOWEEN':
                    return class'KFCharPuppets.PuppetBabydoll_Runner';
            case class'KFChar.ZombieStalker_HALLOWEEN':
            	    return class'KFCharPuppets.PuppetDummyLongRange';
            case class'KFChar.ZombieHusk_HALLOWEEN':
            	    return class'KFCharPuppets.PuppetBabydollLongRange';
            case class'KFChar.ZombieSiren_HALLOWEEN':
                    return class'KFChar.ZombieSiren_HALLOWEEN';
            case class'KFChar.ZombieScrake_HALLOWEEN':
            	    return class'KFChar.ZombieScrake_HALLOWEEN';
            case class'KFChar.ZombieFleshpound_HALLOWEEN':
            	    return class'KFChar.ZombieFleshpound_HALLOWEEN';
            //Begin STANDARD Zeds	    
            case class'KFChar.ZombieClot_STANDARD':
                    return class'KFCharPuppets.PuppetDummy_Runner';
            case class'KFChar.ZombieBloat_STANDARD':
            	    return class'KFCharPuppets.PuppetPinwheel';
            case class'KFChar.ZombieGorefast_STANDARD':
            	    return class'KFCharPuppets.PuppetPinwheel_Runner';
            case class'KFChar.ZombieCrawler_STANDARD':
                    return class'KFCharPuppets.PuppetBabydoll_Runner';
            case class'KFChar.ZombieStalker_STANDARD':
            	    return class'KFCharPuppets.PuppetDummyLongRange';
            case class'KFChar.ZombieHusk_STANDARD':
            	    return class'KFCharPuppets.PuppetBabydollLongRange';
            case class'KFChar.ZombieSiren_STANDARD':
                    return class'KFChar.ZombieSiren_STANDARD';
            case class'KFChar.ZombieScrake_STANDARD':
            	    return class'KFChar.ZombieScrake_STANDARD';
            case class'KFChar.ZombieFleshpound_STANDARD':
            	    return class'KFChar.ZombieFleshpound_STANDARD';
            //Begin XMAS Zeds
             case class'KFChar.ZombieCLot_XMas':
                    return class'KFCharPuppets.PuppetDummy_Runner';
            case class'KFChar.ZombieBloat_XMas':
            	    return class'KFCharPuppets.PuppetPinwheel';
            case class'KFChar.ZombieGorefast_XMas':
            	    return class'KFCharPuppets.PuppetPinwheel_Runner';
            case class'KFChar.ZombieCrawler_XMas':
                    return class'KFCharPuppets.PuppetBabydoll_Runner';
            case class'KFChar.ZombieStalker_XMas':
            	    return class'KFCharPuppets.PuppetDummyLongRange';
            case class'KFChar.ZombieHusk_XMas':
            	    return class'KFCharPuppets.PuppetBabydollLongRange';
             case class'KFChar.ZombieSiren_XMas':
                    return class'KFChar.ZombieSiren_XMas';
            case class'KFChar.ZombieScrake_XMas':
            	    return class'KFChar.ZombieScrake_XMas';
            case class'KFChar.ZombieFleshpound_XMas':
            	    return class'KFChar.ZombieFleshpound_XMas';
            default:
                    return class'KFCharPuppets.PuppetPinwheel';
            }
    }
    
    final function ReplaceMonsterStr( out string MC )
    {
            MC = string(GetReplaceClass(Class<KFMonster>(DynamicLoadObject(MC,Class'Class'))));     	   
    }
    final function ReplaceMonsterStrNBT( out string MC )
    {
            MC = string(GetReplaceClassNBT(Class<KFMonster>(DynamicLoadObject(MC,Class'Class'))));     	   
    }

defaultproperties
{
     bAddToServerPackages=True
     GroupName="KF-ToyMasterReplacer"
     FriendlyName="Toymaster Replacer - CD"
     Description="Zeds are replaced with toys from the Toy Master mod! Mutator created by Cakedog. Original Toymaster Mod created by David Hensley and Alex Quick."
     bAlwaysRelevant=True
     RemoteRole=ROLE_Authority
}
