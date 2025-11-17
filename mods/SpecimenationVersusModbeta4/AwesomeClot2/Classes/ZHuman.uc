class zHuman extends KFHumanPawn;


var( Held ) HeldWeapon rifleatt,meleeatt;

function destroyed()
{

	super.destroyed();

	if( meleeatt != none)
		meleeatt.destroy();
	if( rifleatt != none)
		rifleatt.destroy();
}

function Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{

	super.Died(Killer, damageType,HitLocation);

	if( meleeatt != none)
		meleeatt.destroy();
	if( rifleatt != none)
		rifleatt.destroy();
}
function Tick(float delta)
{
	local kfweapon KFW;
	local inventory inv;

	for ( inv = inventory; inv != none; inv = inv.Inventory )
    	{

		kfw = kfweapon(inv);

		if( kfw != none && kfw != weapon && !kfw.isa('welder') && !kfw.isa('syringe'))
		{

			if( kfw.isa('kfmeleegun') && !kfw.isa('knife') )
			{

				if( meleeatt == none )
				{
					meleeatt = spawn(class'HeldWeapon',self,,,rot(-16300,0,0));
					meleeatt.linkmesh(kfw.attachmentclass.default.mesh);
					meleeatt.setbase(self);
					meleeatt.weapon=kfw;
				}
				else if( meleeatt != none )
				{
					meleeatt.linkmesh(kfw.attachmentclass.default.mesh);
				}


			}

			else if( kfw.isa('bullpup')|| kfw.isa('katana')|| kfw.isa('m14ebrbattlerifle')
				 || kfw.isa('m32grenadelauncher')|| kfw.isa('m79grenadelauncher')|| kfw.isa('shotgun')
				|| kfw.isa('LAW')|| kfw.isa('scarmk17assaultrifle')|| kfw.isa('ak47assaultrifle')
				|| kfw.isa('boomstick')|| kfw.isa('winchester'))
			{

				if( rifleatt == none )
				{
					rifleatt = spawn(class'HeldWeapon',self,,,rot(-16300,16300,0));
					rifleatt.linkmesh(kfw.attachmentclass.default.mesh);
					rifleatt.setbase(self);
					rifleatt.weapon=kfw;
				}
				else if( rifleatt != none )
				{
					rifleatt.linkmesh(kfw.attachmentclass.default.mesh);
				}


			}
		}
	}
	HeldUpdate();
	super.tick(delta);
}

simulated function HeldUpdate()
{
	local vector X,Y,Z;

	local rotator Rot;


	Rot=getbonerotation('CHR_Spine1');
	Rot.roll=rotation.roll;
	rot.pitch=rotation.pitch;

	GetAxes(GetBoneRotation('CHR_Spine1'),X,Y,Z);

				if( rifleatt != none )
				{
					getaxes(rot,x,y,z);
					rifleatt.setlocation( GetBoneCoords('CHR_Spine3').origin + X*11 + Y*0 + Z);
					if( rifleatt.mesh==weapon.attachmentclass.default.mesh )
						rifleatt.linkmesh(none);
					if(rifleatt.mesh!=SkeletalMesh'KF_Weapons3rd_Trip.Katana_3rd')
					rifleatt.setrotation(rotation+rot(-16300,0,16300));
					else rifleatt.setrotation(rotation+rot(0,0,0));
					rifleatt.velocity=velocity*1.2;
				}
				if( meleeatt != none )
				{
					getaxes(rot,x,y,z);
					meleeatt.setlocation( GetBoneCoords('CHR_LThigh').origin + X * 5 + Y * 5 + Z * 4);
					if( meleeatt.mesh==weapon.attachmentclass.default.mesh )
						meleeatt.linkmesh(none);
					meleeatt.setrotation(rotation+rot(-32250,0,0));
					meleeatt.velocity=velocity*1.2;
				}


}

defaultproperties
{
}
