//=============================================================================
// DoomChainsaw.				Coded by .:..:
//=============================================================================
class DoomChainsaw extends DoomWeapon;

replication
{
	reliable if (Role < ROLE_Authority)
		ClientSawState;
}

simulated function RenderWeapon( Canvas C, int YPos, int XPos, Material M, float Scale )
{
	C.SetPos(int(XPos-(M.MaterialUSize()*Scale/2)+24*Scale),YPos);
	C.DrawTile(M,int(M.MaterialUSize()*Scale),int(M.MaterialVSize()*Scale),0,1,M.MaterialUSize(),(M.MaterialVSize()-1));
}
simulated function ClientSawState( bool bHitting )
{
	if( Level.NetMode!=NM_Client || Instigator==None )
		return;
	if( bHitting )
		Instigator.AmbientSound = Sound'DSSAWHIT';
	else Instigator.AmbientSound = Sound'DSSAWFUL';
}
function SpawnTheShot( vector Pos, Rotator Aim )
{
	local vector HitL,HitN,X,End;
	local Actor A;
	local rotator R;
	local byte c;

	R = DoAutoAim(Pos,Aim);
	if( Aim!=R )
	{
		Aim = R;
		Instigator.Controller.ClientSetRotation(R);
	}
	X = vector(Aim);
	End = Pos+X*(Instigator.CollisionRadius+55);
	A = Trace(HitL,HitN,End,Pos, true);
	if( A==None )
	{
		if( Instigator.AmbientSound!=Sound'DSSAWFUL' )
		{
			Instigator.AmbientSound = Sound'DSSAWFUL';
			ClientSawState(false);
		}
		Return;
	}
	while( A.IsA('KFBulletWhipAttachment') && c++<30 )
	{
		Pos = HitL;
		A = A.Trace(HitL,HitN,End,Pos, true);
		if( A==None )
		{
			if( Instigator.AmbientSound!=Sound'DSSAWFUL' )
			{
				Instigator.AmbientSound = Sound'DSSAWFUL';
				ClientSawState(false);
			}
			Return;
		}
	}
	if( Instigator.AmbientSound!=Sound'DSSAWHIT' )
	{
		Instigator.AmbientSound = Sound'DSSAWHIT';
		ClientSawState(true);
	}
	if( A.bWorldGeometry || A.IsA('Vehicle') )
		Spawn(TraceHitFX,,,HitL+HitN*8);
	if( !A.bWorldGeometry )
		A.TakeDamage(GetFromRange(InstaHitDamage), Instigator, HitL, InstaHitMom*X, InstaHitDamageType);
}
function rotator DoAutoAim( vector Start, rotator R )
{
	local Actor A;
	local float Aim,Dist;

	if( Instigator.Controller==None )
		Return R;
	Aim = 0.75;
	A = Instigator.Controller.PickTarget(Aim,Dist,vector(R),Start,100);
	if( A!=None )
		Return rotator(A.Location-(Instigator.Location+vect(0,0,1)*Instigator.BaseEyeHeight));
	else Return R;
}
simulated function bool HasTheNeededAmmo()
{
	Return True;
}
simulated State WeaponIsFiring
{
Ignores ClientStartFire;

	simulated function BeginState()
	{
		Instigator.AmbientSound = Sound'DSSAWFUL';
		Super.BeginState();
	}
	simulated function EndState()
	{
		Super.EndState();
		if( Instigator!=None )
			Instigator.AmbientSound = Sound'DSSAWIDL';
	}
}
simulated function HandelBringUp()
{
	Instigator.AmbientSound = Sound'DSSAWIDL';
	Instigator.SoundVolume = 255;
}

defaultproperties
{
     bUseStartEndReplic=True
     IdleAnimTex=Texture'DoomPawnsKF.Chainsaw.SAWGC0'
     FireAnim(0)=Texture'DoomPawnsKF.Chainsaw.SAWGA0'
     RefiringSpeed=0.100000
     InstaHitDamage=(Min=2,Max=8)
     bUseInstantHit=True
     InstaHitDamageType=Class'DoomPawnsKF.SawedDmg'
     AmmoPerFire=0
     HudImage=TexScaler'DoomPawnsKF.Icons.ChainsawIcon'
     SelectedHudImage=TexScaler'DoomPawnsKF.Icons.ChainsawIcon'
     TraderInfoTexture=Texture'DoomPawnsKF.Chainsaw.CSAWA0'
     SelectSound=Sound'DoomPawnsKF.Chainsaw.DSSAWUP'
     AIRating=0.125000
     Description="Chainsaw: Does damage like the normal fist, but four times faster."
     Priority=2
     HudColor=(B=128,G=128,R=128)
     CustomCrosshair=6
     CustomCrossHairColor=(A=0)
     CustomCrossHairScale=0.000000
     CustomCrossHairTextureName="Crosshairs.Hud.Crosshair_Pointer"
     PickupClass=Class'DoomPawnsKF.DoomChainsawPickup'
     AttachmentClass=Class'DoomPawnsKF.DChainsawAttachment'
     IconMaterial=Texture'DoomPawnsKF.Chainsaw.CSAWA0'
     IconCoords=(X2=64,Y2=32)
     ItemName="Chainsaw"
}
