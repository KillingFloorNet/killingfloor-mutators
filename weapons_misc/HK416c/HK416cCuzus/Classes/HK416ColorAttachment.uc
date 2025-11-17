class HK416ColorAttachment extends HK416cAttachment;

var array<string> SkinRefs;

static function PreloadAssets(optional KFWeaponAttachment Spawned)
{
    local int i;

    super.PreloadAssets(Spawned);

	for ( i = 0; i < default.SkinRefs.Length; i++ )
	{
		default.Skins[i] = Material(DynamicLoadObject(default.SkinRefs[i], class'Material'));

    	if ( Spawned != none )
    	{
        	Spawned.Skins[i] = default.Skins[i];
    	}
	}
}

defaultproperties
{
	SkinRefs(0)="HK416c_R.HK416c_R.Sights_cmb_color"
	SkinRefs(1)="HK416c_R.HK416c_R.HK416_cmb_color"
	SkinRefs(2)="HK416c_R.HK416c_R.Extras_cmb_color"
}
