class DamagePopup extends xEmitter
	transient;

var bool bReady;
var int Damage;
var color FontColor,BackColor;
var ScriptedTexture STexture;
var TexRotator TexRot;
var Font DrawFont;

replication
{
	reliable if(Role==ROLE_Authority )
		Damage;
}

static final function ShowDamage( actor dest, vector ShowLocation, int sDamage )
{
	local DamagePopup p;

	if( sDamage < 0 || dest==none )
		return;
	p = dest.spawn(class'DamagePopup',,,ShowLocation,rot(16384,0,0));
	p.Damage = sDamage;
	if( dest.Level.NetMode!=NM_DedicatedServer )
		p.PostNetBeginPlay();
}
simulated function Destroyed()
{
	if( stexture!=none )
	{
		stexture.Client = none;
		Level.ObjectPool.FreeObject(STexture);
		STexture = None;
	}
	if( TexRot!=none )
	{
		TexRot.Material = None;
		Level.ObjectPool.FreeObject(TexRot);
		TexRot = None;
	}
	super.Destroyed();
}
simulated function PostNetBeginPlay()
{
	local rotator R;
	local float A;

	if( Level.NetMode==NM_DedicatedServer )
	{
		LifeSpan = 0.2f;
		return;
	}
	if( Level.NetMode!=NM_Client && !bReady )
	{
		bReady = true;
		return;
	}
	if( Damage<25 ) // Green
		FontColor = Class'Canvas'.Static.MakeColor(80,255,80,255);
	else if( Damage<75 ) // Green -> Yellow
	{
		A = (float(Damage)-25.f)*3.5;
		FontColor = Class'Canvas'.Static.MakeColor(80+A,255,80,255);
	}
	else if( Damage<125 ) // Yellow -> Red
	{
		A = (float(Damage)-75.f)*3.5;
		FontColor = Class'Canvas'.Static.MakeColor(255,255-A,80,255);
	}
	else FontColor = Class'Canvas'.Static.MakeColor(255,80,80,255); // Red

	STexture = ScriptedTexture(Level.ObjectPool.AllocateObject(class'ScriptedTexture'));
	TexRot = TexRotator(Level.ObjectPool.AllocateObject(class'TexRotator'));
	STexture.SetSize(64,64);
	STexture.Client = Self;
	STexture.Revision++;

	TexRot.Material=stexture;
	TexRot.Rotation.Yaw=8191;
	TexRot.UOffset=32;
	TexRot.VOffset=32;
	DrawFont = Font(DynamicLoadObject("ROFonts.ROArial16", class'Font'));
	if( DrawFont==None )
		DrawFont = Default.DrawFont;
	Texture=TexRot;
	Skins[0]=TexRot;
	R.Yaw = Rand(65536);
	R.Pitch = 12384+Rand(7000);
	setRotation(R);
	mStartParticles=1;
}
simulated function RenderTexture(ScriptedTexture Tex)
{
	local int SizeX, SizeY;
	local string text;

	text=string(Damage);
	Tex.TextSize(text, DrawFont, SizeX, SizeY);
	Tex.DrawTile(0, 0, Tex.USize, Tex.VSize, 0, 0, Tex.USize, Tex.VSize, None, BackColor);
	Tex.DrawText((Tex.USize - SizeX) * 0.5, (Tex.VSize - SizeY) * 0.5, text, DrawFont, FontColor);
}

defaultproperties
{
     FontColor=(B=255,G=255,R=255,A=255)
     DrawFont=Font'Engine.DefaultFont'
     mStartParticles=0
     mMaxParticles=1
     mSpeedRange(0)=250.000000
     mSpeedRange(1)=500.000000
     mMassRange(0)=1.500000
     mMassRange(1)=1.500000
     mAirResistance=1.000000
     mSizeRange(0)=25.000000
     mSizeRange(1)=25.000000
     mAttenuate=False
     DrawType=DT_Sprite
     bSkipActorPropertyReplication=True
     RemoteRole=ROLE_SimulatedProxy
     LifeSpan=1.000000
     Rotation=(Pitch=16383)
     Texture=None
     Skins(0)=None
     Style=STY_Alpha
}
