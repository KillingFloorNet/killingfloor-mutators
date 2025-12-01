//================
//Code fixes and balancing by Skell*.
//Original content is by Alex Quick and David Hensley.
//================
//Ventriloquist Puppet (Runner)
//================
class PuppetDummyFixRunner extends PuppetDummy_Runner;

#exec obj load file="KFPuppetsFixV3_A.ukx"

//Overwritten to change HitF as that's not an animation for puppet_ventriloquist.
function RemoveHead()
{
	local int i;

	Intelligence = BRAINS_Retarded;

	bDecapitated  = true;
	DECAP = true;
	DecapTime = Level.TimeSeconds;

	Velocity = vect(0,0,0);
	SetAnimAction('Hit_reaction_F'); //Changed from HitF
	SetGroundSpeed(GroundSpeed *= 0.80);
	AirSpeed *= 0.8;
	WaterSpeed *= 0.8;

	AmbientSound = MiscSound;

	if ( Controller != none )
	{
		MonsterController(Controller).Accuracy = -5;
	}

	if( KFPawn(LastDamagedBy)!=None )
	{
		TakeDamage( LastDamageAmount + 0.25 * HealthMax , LastDamagedBy, LastHitLocation, LastMomentum, LastDamagedByType);

		if ( BurnDown > 0 )
		{
			KFSteamStatsAndAchievements(KFPawn(LastDamagedBy).PlayerReplicationInfo.SteamStatsAndAchievements).AddBurningDecapKill(class'KFGameType'.static.GetCurrentMapName(Level));
		}
	}

	if( Health > 0 )
	{
		BleedOutTime = Level.TimeSeconds +  BleedOutDuration;
	}

	if (MeleeAnims[2] == 'Claw3')
		MeleeAnims[2] = 'Claw2';
	if (MeleeAnims[1] == 'Claw3')
		MeleeAnims[1] = 'Claw1';

	for( i = 0; i < 4; i++ )
	{
		if( HeadlessWalkAnims[i] != '' && HasAnim(HeadlessWalkAnims[i]) )
		{
			MovementAnims[i] = HeadlessWalkAnims[i];
			WalkAnims[i]     = HeadlessWalkAnims[i];
		}
	}

	PlaySound(DecapitationSound, SLOT_Misc,1.30,true,525);
}

defaultproperties
{
     ColOffset=(Z=36.000000)
     ColRadius=20.000000
     ColHeight=26.000000
     LeftShoulderBone="CHR_LCollarbone"
     RightShoulderBone="CHR_RCollarbone"
     LeftThighBone="CHR_LThigh"
     RightThighBone="CHR_RThigh"
     LeftFArmBone="CHR_LForearm"
     RightFArmBone="CHR_RForearm"
     LeftFootBone="CHR_LFoot"
     RightFootBone="CHR_RFoot"
     LeftHandBone="CHR_LPalm"
     RightHandBone="CHR_RPalm"
     OnlineHeadshotOffset=(X=2.500000,Z=44.000000)
     OnlineHeadshotScale=1.250000
     HeadHealth=65.000000
     HealthMax=325.000000
     Health=325
     MovementAnims(0)="WalkF"
     MovementAnims(1)="WalkB"
     MovementAnims(2)="WalkL"
     MovementAnims(3)="WalkR"
     SwimAnims(0)="WalkF"
     SwimAnims(1)="WalkB"
     SwimAnims(2)="WalkL"
     SwimAnims(3)="WalkR"
     WalkAnims(0)="WalkF"
     WalkAnims(1)="WalkB"
     WalkAnims(2)="WalkL"
     WalkAnims(3)="WalkR"
     Mesh=SkeletalMesh'KFPuppetsFixV3_A.puppet_ventriloquist_fix'
     CollisionRadius=16.000000
     CollisionHeight=29.000000
}
