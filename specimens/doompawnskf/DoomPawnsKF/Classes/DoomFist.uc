//=============================================================================
// DoomFist.				Coded by .:..:
//=============================================================================
class DoomFist extends DoomWeapon;

var BerserkInv MyBerserk;

simulated function RenderWeapon( Canvas C, int YPos, int XPos, Material M, float Scale )
{
	if( CurrentAnim==3 )
		C.SetPos(int(XPos-(M.MaterialUSize()*Scale/2)-40*Scale),YPos);
	else C.SetPos(int(XPos+2*Scale),YPos);
	C.DrawTile(M,int(M.MaterialUSize()*Scale),int(M.MaterialVSize()*Scale),0,1,M.MaterialUSize(),(M.MaterialVSize()-1));
}
function SpawnTheShot( vector Pos, Rotator Aim )
{
	local vector HitL,HitN,X,End;
	local Actor A;
	local rotator R;
	local byte c;
	local float Power;

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
		Return;
	while( A.IsA('KFBulletWhipAttachment') && c++<30 )
	{
		Pos = HitL;
		A = A.Trace(HitL,HitN,End,Pos, true);
		if( A==None ) Return;
	}
	if( A.bWorldGeometry || A.IsA('Vehicle') )
		Spawn(TraceHitFX,,,HitL+HitN*8);
	if( !A.bWorldGeometry )
	{
		Power = 1;
		if( MyBerserk!=None )
			Power = MyBerserk.GetDamageMulti(Self,A);
		A.TakeDamage(GetFromRange(InstaHitDamage)*Power, Instigator, HitL, InstaHitMom*X*Power, InstaHitDamageType);
		Instigator.PlaySound(Sound'DSPUNCH',SLOT_Misc,TransientSoundVolume,,TransientSoundRadius,GetSoundPitch());
	}
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
function AttachToPawn(Pawn P);

defaultproperties
{
     IdleAnimTex=Texture'DoomPawnsKF.Fist.PUNGA0'
     FireAnim(0)=Texture'DoomPawnsKF.Fist.PUNGB0'
     FireAnim(1)=Texture'DoomPawnsKF.Fist.PUNGC0'
     FireAnim(2)=Texture'DoomPawnsKF.Fist.PUNGD0'
     FireAnim(3)=Texture'DoomPawnsKF.Fist.PUNGC0'
     FireAnim(4)=Texture'DoomPawnsKF.Fist.PUNGB0'
     RefiringSpeed=0.500000
     InstaHitDamage=(Min=5)
     bUseInstantHit=True
     InstaHitMom=40000.000000
     InstaHitDamageType=Class'KFMod.DamTypeMelee'
     AmmoPerFire=0
     HudImage=TexScaler'DoomPawnsKF.Icons.FistIcon'
     SelectedHudImage=TexScaler'DoomPawnsKF.Icons.FistIcon'
     Weight=0.000000
     bKFNeverThrow=True
     TraderInfoTexture=Texture'Engine.S_Weapon'
     AIRating=0.050000
     bCanThrow=False
     Description="Fists: Extremely basic close-range weapon. Never runs out of ammo, but only about as powerful as a pistol shot; normally used only as a last resort or with a berserk pack."
     Priority=1
     HudColor=(B=255,G=150)
     CustomCrosshair=6
     CustomCrossHairColor=(A=0)
     CustomCrossHairScale=0.000000
     CustomCrossHairTextureName="Crosshairs.Hud.Crosshair_Pointer"
     PickupClass=Class'DoomPawnsKF.DoomFistPickup'
     AttachmentClass=Class'DoomPawnsKF.DFakeFistAttachment'
     IconMaterial=Texture'Engine.S_Weapon'
     IconCoords=(X2=32,Y2=32)
     ItemName="Fist"
}
