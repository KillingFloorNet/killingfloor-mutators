//=============================================================================
// KFDoomPlayerPawn
//=============================================================================
class KFDoomPlayerPawn extends KFHumanPawn;

#exec AUDIO IMPORT FILE="Sounds\DSPLPAIN.wav" NAME="DSPLPAIN" GROUP="Marine"
#exec obj load file="DInvisSkin.utx" package="DoomPawnsKF.Invis"

var transient float NextVolumePainTime;

simulated function PostBeginPlay()
{
	Super(UnrealPawn).PostBeginPlay();

	AssignInitialPose();
	if( bActorShadows && bPlayerShadows && (Level.NetMode!=NM_DedicatedServer) )
	{
		if( bDetailedShadows )
			PlayerShadow = Spawn(class'KFShadowProject',Self,'',Location);
		else PlayerShadow = Spawn(class'ShadowProjector',Self,'',Location);
		PlayerShadow.ShadowActor = self;
		PlayerShadow.bBlobShadow = bBlobShadow;
		PlayerShadow.LightDirection = Normal(vect(1,1,3));
		PlayerShadow.InitShadow();
	}
}

simulated event ModifyVelocity(float DeltaTime, vector OldVelocity);

function TakeFallingDamage()
{
	if (Velocity.Z < -0.8 * MaxFallSpeed)
	{
		if( Level.NetMode!=NM_Client )
			MakeNoise(0.8);
		PlayOwnedSound(Sound'DSOOF',SLOT_Pain,1.2f);
	}
}
simulated function PlayDirectionalDeath(Vector HitLoc)
{
	LifeSpan = 1.f;
}
function PlayTakeHit(vector HitLocation, int Damage, class<DamageType> DamageType)
{
	PlayDirectionalHit(HitLocation);

	if( Level.TimeSeconds<LastPainSound )
		return;

	LastPainSound = Level.TimeSeconds+MinTimeBetweenPainSounds;
	PlaySound(Sound'DSPLPAIN', SLOT_Pain,2.f,,200);
}
function PlayDyingSound()
{
	if( FRand()<0.5 )
		PlaySound(Sound'DSPDIEHI', SLOT_Pain,2.5,,500);
	else PlaySound(Sound'DSPLDETH', SLOT_Pain,2.5,,500);
}
function Gasp();
function PlayMoverHitSound();
event TakeDamage(int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional int HitIndex )
{
	local PhysicsVolume P;

	if( Momentum==vect(0,0,0) && EventInstigator==None )
	{
		// Avoid super rapid damage bug.
		ForEach TouchingActors(Class'PhysicsVolume',P)
		{
			if( P.Location==HitLocation )
			{
				if( NextVolumePainTime>Level.TimeSeconds )
					Return;
				NextVolumePainTime = Level.TimeSeconds+0.8;
				break;
			}
		}
	}
	Super.TakeDamage(Damage,EventInstigator,HitLocation,Momentum,DamageType,HitIndex);
}

defaultproperties
{
     MaxCarryWeight=60.000000
     InvisMaterial=FinalBlend'DoomPawnsKF.Invis.InvisFB'
     MinTimeBetweenPainSounds=0.300000
     GroundSpeed=600.000000
     AccelRate=1400.000000
     TransientSoundVolume=1.000000
}
