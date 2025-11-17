Class KeyUseTrigger extends UseTrigger;

#exec AUDIO IMPORT FILE="Sounds\Dsdorcls.wav" NAME="Dsdorcls" GROUP="DoomGen"
#exec AUDIO IMPORT FILE="Sounds\Dsdoropn.wav" NAME="Dsdoropn" GROUP="DoomGen"
#exec AUDIO IMPORT FILE="Sounds\DSOOF.wav" NAME="DSOOF" GROUP="DoomGen"
#exec AUDIO IMPORT FILE="Sounds\Dspstart.wav" NAME="Dspstart" GROUP="DoomGen"
#exec AUDIO IMPORT FILE="Sounds\DSSWTCHN.wav" NAME="DSSWTCHN" GROUP="DoomGen"
#exec AUDIO IMPORT FILE="Sounds\Dspstop.wav" NAME="Dspstop" GROUP="DoomGen"

var() class<DKeysB> RequiredKey;
var() localized string RequiredMsg;
var() sound CantOpenSnd;
var() bool bFirstUseUnlocks;
var transient float TrigTime;
var bool bUnlocked;

function Touch( Actor Other )
{
	if( KFSPGameType(Level.Game)==None )
		Super.Touch(Other);
}
function UsedBy( Pawn user )
{
	local Inventory I;

	if( RequiredKey==None || bUnlocked )
	{
		Super.UsedBy(user);
		Return;
	}
	if( TrigTime>Level.TimeSeconds )
		Return;
	TrigTime = Level.TimeSeconds+0.25;
	For( I=user.Inventory; I!=None; I=I.Inventory )
	{
		if( I.Class==RequiredKey )
		{
			if( bFirstUseUnlocks )
				bUnlocked = True;
			Super.UsedBy(user);
			Return;
		}
	}
	user.ClientMessage(RequiredKey.Default.ItemName@RequiredMsg);
	if( CantOpenSnd!=None )
		user.PlaySound(CantOpenSnd,SLOT_Misc,1.5);
}
function Reset()
{
	bUnlocked = False;
}

defaultproperties
{
     RequiredKey=Class'DoomPawnsKF.DKeysB'
     RequiredMsg="is required to open this door."
     CantOpenSnd=Sound'DoomPawnsKF.DoomGen.DSOOF'
     bFirstUseUnlocks=True
}
